//! zinc
library Loot requires IntegerPool, ZAMCore {
constant integer RP_FACTOR = 200000;
constant integer TABLE_SIZE = 50;
constant real RP_RELIC = 1.0;
constant real RP_RARE = 10.0;
constant real RP_UNCOMMON = 0.0;
constant real RP_COMMON = 0.0;
    public IntegerPool classSpec;
    IntegerPool relic;
    IntegerPool rare;
    IntegerPool boss1, boss2, boss3, boss4, boss5, boss6, boss7;
    Table bossPools;
    real loot2;
    
    function minionsDrop(unit u) {
        integer monsterDropValue;
        real mdp, factor, rp0, rp1, rp2, rp3;
        real roll;
        integer itid;
        real x, y;
        integer dropped = 0;
        x = GetUnitX(u); y = GetUnitY(u);
        monsterDropValue = UnitProp[u].getDropValue();
        mdp = monsterDropValue + loot2;
        // print("MDP = " + R2S(mdp));
        while (mdp >= 0) {
            factor = mdp / I2R(RP_FACTOR);
            rp0 = factor * RP_RELIC;
            if (monsterDropValue < 50000) {
                rp0 = 0.0;
            }
            rp1 = factor * RP_RARE;
            rp2 = factor * RP_UNCOMMON;
            rp3 = factor * RP_COMMON;
            roll = GetRandomReal(0, 99.0);
            // print("Prob table: " + R2S(rp0) + ", " + R2S(rp1) + ", " + R2S(rp2) + ", " + R2S(rp3));
            // print("Roll: " + R2S(roll));
            if (roll < TABLE_SIZE) {
                if (roll < rp0) {
                    itid = relic.get();
                    if (itid > 0) {
                        relic.remove(itid);
                    } else {
                        itid = rare.get();
                    }
                    CreateItemEx(itid, x, y);
                    loot2 = 0.0;
                    dropped = 1;
                } else if (roll < rp0 + rp1) {
                    itid = rare.get();
                    CreateItemEx(itid, x, y);
                    loot2 = 0.0;
                    dropped = 1;
                } else if (roll < rp0 + rp1 + rp2) {

                } else if (roll < rp0 + rp1 + rp2 + rp3) {

                } else {
                    loot2 += monsterDropValue * 0.4;
                    // print("Loot2.0 = " + R2S(loot2));
                }
            }
            mdp -= RP_FACTOR;
        }
        if (dropped == 0 && IsUnitChampion(u)) {
            itid = rare.get();
            CreateItemEx(itid, x, y);
            loot2 = 0.0;
        }
    }
    
    function mobDeathDrop(unit u) {
        integer itid;
        IntegerPool ip;
        real x, y;
        if (GetPlayerId(GetOwningPlayer(u)) == MOB_PID) {
            x = GetUnitX(u); y = GetUnitY(u);
            if (IsUnitType(u, UNIT_TYPE_HERO)) {
                // boss drops
                // 1. 50% relic + 50% rare
                if (GetRandomInt(0, 99) < 50) { 
                    itid = relic.get();
                    if (itid > 0) {
                        relic.remove(itid);
                    } else {
                        itid = rare.get();
                    }
                } else {
                    itid = rare.get();
                }
                CreateItemEx(itid, x, y);
                // 2. class spec gear
                itid = classSpec.get();
                if (itid > 0) {
                    classSpec.remove(itid);
                } else {
                    itid = relic.get();
                    if (itid > 0) {
                        relic.remove(itid);
                    } else {
                        itid = rare.get();
                    }
                }
                CreateItemEx(itid, x, y);
                // 3. rare boss
                ip = IntegerPool(bossPools[GetUnitTypeId(u)]);
                itid = ip.get();
                if (itid > 0) {
                    boss1.remove(itid);
                    boss2.remove(itid);
                    boss3.remove(itid);
                    boss4.remove(itid);
                    boss5.remove(itid);
                    boss6.remove(itid);
                    boss7.remove(itid);
                } else {
                    itid = rare.get();
                }
                CreateItemEx(itid, x, y);
            } else if (CanUnitAttack(u) && !IsUnitSummoned(u)) {
                // Minions drop
                minionsDrop(u);
            }
        }
    }
    
    function onInit() {
        loot2 = 0.0;
        RegisterUnitDeath(mobDeathDrop);
    
        classSpec = IntegerPool.create();
        relic = IntegerPool.create();
        rare = IntegerPool.create();
        
        bossPools = Table.create();
        boss1 = IntegerPool.create();
        boss2 = IntegerPool.create();
        boss3 = IntegerPool.create();
        boss4 = IntegerPool.create();
        boss5 = IntegerPool.create();
        boss6 = IntegerPool.create();
        boss7 = IntegerPool.create();
        bossPools[UTID_ARCH_TINKER] = boss1;
        bossPools[UTID_ARCH_TINKER_MORPH] = boss1;
        bossPools[UTID_NAGA_SEA_WITCH] = boss2;
        bossPools[UTIDTIDEBARON] = boss3;
        bossPools[UTIDTIDEBARONWATER] = boss3;
        bossPools[UTIDWARLOCK] = boss4;
        bossPools[UTID_PIT_ARCHON] = boss5;
        bossPools[UTID_FEL_GUARD] = boss6;
        bossPools[UTIDHEXLORD] = boss7;
        
        relic.add(ITIDBREATHOFTHEDYING, 10);
        relic.add(ITIDCALLTOARMS, 10);
        relic.add(ITID_CTHUNS_DERANGEMENT, 10);
        relic.add(ITIDENIGMA, 10);
        relic.add(ITIDINFINITY, 10);
        relic.add(ITIDINSIGHT, 10);
        relic.add(ITID_TYRAELS_MIGHT, 10);
        relic.add(ITID_VOODOO_VIAL, 10);
        relic.add(ITIDWOESTAVE, 10);
        relic.add(ITIDWINDFORCE, 10);

        rare.add(ITID_ARANS_SOOTHING_AGATE, 10);
        rare.add(ITID_BULWARK_OF_THE_AMANI_EMPIRE, 10);
        rare.add(ITID_CORE_HOUND_TOOTH, 10);
        rare.add(ITID_CURSED_CUIRASS, 10);
        rare.add(ITID_DRUM, 10);
        rare.add(ITID_GOBLIN_ROCKET_BOOTS_LIMITED_EDITION, 10);
        rare.add(ITID_GORE_HOWL, 10);
        rare.add(ITID_HEX_SHRUNKEN_HEAD, 10);
        rare.add(ITID_LION_HORN, 10);
        rare.add(ITID_PURE_ARCANE, 10);
        rare.add(ITID_SIGNET_OF_THE_LAST_DEFENDER, 10);
        rare.add(ITID_STAFF_OF_THE_SHADOW_FLAME, 10);
        rare.add(ITID_THE_21_RING, 10);
        rare.add(ITID_TIDAL_LOOP, 10);
        rare.add(ITID_TROLL_BANE, 10);
        rare.add(ITID_VISKAG, 10);
        rare.add(ITID_CRUEL_COLOSSUS_BLADE_OF_QUICKNESS, 10);

        boss1.add(ITID_THE_21_RING, 15);
        boss1.add(ITID_GOBLIN_ROCKET_BOOTS_LIMITED_EDITION, 25);
        boss1.add(ITID_CORE_HOUND_TOOTH, 7);
        boss1.add(ITID_VISKAG, 11);
        boss1.add(ITID_CURSED_CUIRASS, 10);
        boss1.add(ITID_BULWARK_OF_THE_AMANI_EMPIRE, 11);
        boss1.add(ITID_PURE_ARCANE, 11);
        boss1.add(ITID_STAFF_OF_THE_SHADOW_FLAME, 10);

        boss2.add(ITID_THE_21_RING, 10);
        boss2.add(ITID_TROLL_BANE, 9);
        boss2.add(ITID_LION_HORN, 20);
        boss2.add(ITID_ARANS_SOOTHING_AGATE, 9);
        boss2.add(ITID_PURE_ARCANE, 13);
        boss2.add(ITID_HEX_SHRUNKEN_HEAD, 10);
        boss2.add(ITID_STAFF_OF_THE_SHADOW_FLAME, 13);
        boss2.add(ITID_TIDAL_LOOP, 16);

        boss3.add(ITID_THE_21_RING, 11);
        boss3.add(ITID_GOBLIN_ROCKET_BOOTS_LIMITED_EDITION, 11);
        boss3.add(ITID_VISKAG, 12);
        boss3.add(ITID_SIGNET_OF_THE_LAST_DEFENDER, 15);
        boss3.add(ITID_ARANS_SOOTHING_AGATE, 13);
        boss3.add(ITID_PURE_ARCANE, 13);
        boss3.add(ITID_HEX_SHRUNKEN_HEAD, 9);
        boss3.add(ITID_TIDAL_LOOP, 16);

        boss4.add(ITID_DRUM, 11);
        boss4.add(ITID_TROLL_BANE, 17);
        boss4.add(ITID_GORE_HOWL, 10);
        boss4.add(ITID_VISKAG, 14);
        boss4.add(ITID_SIGNET_OF_THE_LAST_DEFENDER, 14);
        boss4.add(ITID_HEX_SHRUNKEN_HEAD, 14);
        boss4.add(ITID_STAFF_OF_THE_SHADOW_FLAME, 14);
        boss4.add(ITID_TIDAL_LOOP, 6);

        boss5.add(ITID_DRUM, 13);
        boss5.add(ITID_TROLL_BANE, 12);
        boss5.add(ITID_GORE_HOWL, 12);
        boss5.add(ITID_CORE_HOUND_TOOTH, 14);
        boss5.add(ITID_LION_HORN, 10);
        boss5.add(ITID_CURSED_CUIRASS, 15);
        boss5.add(ITID_BULWARK_OF_THE_AMANI_EMPIRE, 15);
        boss5.add(ITID_SIGNET_OF_THE_LAST_DEFENDER, 9);

        boss6.add(ITID_DRUM, 12);
        boss6.add(ITID_GORE_HOWL, 15);
        boss6.add(ITID_CORE_HOUND_TOOTH, 17);
        boss6.add(ITID_LION_HORN, 7);
        boss6.add(ITID_CURSED_CUIRASS, 12);
        boss6.add(ITID_BULWARK_OF_THE_AMANI_EMPIRE, 12);
        boss6.add(ITID_ARANS_SOOTHING_AGATE, 15);
        boss6.add(ITID_HEX_SHRUNKEN_HEAD, 10);

        boss7.add(ITID_THE_21_RING, 7);
        boss7.add(ITID_GOBLIN_ROCKET_BOOTS_LIMITED_EDITION, 7);
        boss7.add(ITID_DRUM, 7);
        boss7.add(ITID_TROLL_BANE, 6);
        boss7.add(ITID_GORE_HOWL, 7);
        boss7.add(ITID_CORE_HOUND_TOOTH, 6);
        boss7.add(ITID_VISKAG, 7);
        boss7.add(ITID_LION_HORN, 7);
        boss7.add(ITID_CURSED_CUIRASS, 7);
        boss7.add(ITID_BULWARK_OF_THE_AMANI_EMPIRE, 6);
        boss7.add(ITID_SIGNET_OF_THE_LAST_DEFENDER, 6);
        boss7.add(ITID_ARANS_SOOTHING_AGATE, 7);
        boss7.add(ITID_PURE_ARCANE, 7);
        boss7.add(ITID_STAFF_OF_THE_SHADOW_FLAME, 7);
        boss7.add(ITID_TIDAL_LOOP, 6);

    }






}
//! endzinc
