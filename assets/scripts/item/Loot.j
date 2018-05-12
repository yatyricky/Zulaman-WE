//! zinc
library Loot requires IntegerPool, ZAMCore, ItemAttributes {
constant integer RP_FACTOR = 20000;
constant integer TABLE_SIZE = 65;
constant real RP_RELIC = 1.0;
constant real RP_RARE = 6.0;
constant real RP_UNCOMMON = 15.0;
constant real RP_COMMON = 0.0;

public          real    ILVL_THRESHOLD[];
public          real    ILVL_THRESHOLD_VALUE[];
public constant real    ILVL_DROP_RATE = 0.33;
public constant real    ILVL_MULTIPLE_REDUCTION = 3.0;
public constant real    ILVL_MAX_RATE = 0.6;

    public IntegerPool classSpec;
    IntegerPool relic;
    IntegerPool rare;
    IntegerPool uncommon;
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
        monsterDropValue = UnitProp.inst(u, SCOPE_PREFIX).getDropValue();
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
                    CreateItemEx(itid, x, y, monsterDropValue);
                    loot2 = 0.0;
                    dropped = 1;
                } else if (roll < rp0 + rp1) {
                    itid = rare.get();
                    CreateItemEx(itid, x, y, monsterDropValue);
                    loot2 = 0.0;
                    dropped = 1;
                } else if (roll < rp0 + rp1 + rp2) {
                    itid = uncommon.get();
                    CreateItemEx(itid, x, y, monsterDropValue);
                    loot2 = 0.0;
                    dropped = 1;
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
            CreateItemEx(itid, x, y, monsterDropValue);
            loot2 = 0.0;
        }
    }
    
    function mobDeathDrop(unit u) {
        integer itid;
        IntegerPool ip;
        real x, y;
        integer monsterDropValue;
        if (GetPlayerId(GetOwningPlayer(u)) == MOB_PID) {
            x = GetUnitX(u); y = GetUnitY(u);
            if (IsUnitType(u, UNIT_TYPE_HERO)) {
                monsterDropValue = UnitProp.inst(u, SCOPE_PREFIX).getDropValue() / 10;
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
                CreateItemEx(itid, x, y, monsterDropValue);
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
                CreateItemEx(itid, x, y, monsterDropValue);
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
                CreateItemEx(itid, x, y, monsterDropValue);
            } else if (CanUnitAttack(u) && !IsUnitSummoned(u)) {
                // Minions drop
                minionsDrop(u);
            }
        }
    }
    
    function onInit() {
        ILVL_THRESHOLD[0] = 50000;
        ILVL_THRESHOLD[1] = 100000;
        ILVL_THRESHOLD[2] = 300000;
        ILVL_THRESHOLD_VALUE[0] = 50000;
        ILVL_THRESHOLD_VALUE[1] = 200000;
        ILVL_THRESHOLD_VALUE[2] = 1200000;
        loot2 = 0.0;
        RegisterUnitDeath(mobDeathDrop);
    
        classSpec = IntegerPool.create();
        relic = IntegerPool.create();
        rare = IntegerPool.create();
        uncommon = IntegerPool.create();
        
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
        bossPools[UTID_TIDE_BARON] = boss3;
        bossPools[UTID_TIDE_BARON_WATER] = boss3;
        bossPools[UTID_WARLOCK] = boss4;
        bossPools[UTID_PIT_ARCHON] = boss5;
        bossPools[UTID_FEL_GUARD] = boss6;
        bossPools[UTID_HEX_LORD] = boss7;
        
        relic.add(ITID_BREATH_OF_THE_DYING, 10);
        relic.add(ITID_CALL_TO_ARMS, 10);
        relic.add(ITID_DERANGEMENT_OF_CTHUN, 10);
        relic.add(ITID_ENIGMA, 10);
        relic.add(ITID_INFINITY, 10);
        relic.add(ITID_INSIGHT, 10);
        relic.add(ITID_MIGHT_OF_THE_ANGEL_OF_JUSTICE, 10);
        relic.add(ITID_VOODOO_VIALS, 10);
        relic.add(ITID_WOESTAVE, 10);
        relic.add(ITID_WINDFORCE, 10);

        rare.add(ITID_ARANS_SOOTHING_EMERALD, 10);
        rare.add(ITID_BULWARK_OF_THE_AMANI_EMPIRE, 10);
        rare.add(ITID_CORE_HOUND_TOOTH, 10);
        rare.add(ITID_ARMOR_OF_THE_DAMNED, 10);
        rare.add(ITID_WARSONG_BATTLE_DRUMS, 10);
        rare.add(ITID_GOBLIN_ROCKET_BOOTS_LIMITED_EDITION, 10);
        rare.add(ITID_GOREHOWL, 10);
        rare.add(ITID_HEX_SHRUNKEN_HEAD, 10);
        rare.add(ITID_LION_HORN, 10);
        rare.add(ITID_PURE_ARCANE, 10);
        rare.add(ITID_SIGNET_OF_THE_LAST_DEFENDER, 10);
        rare.add(ITID_STAFF_OF_THE_SHADOW_FLAME, 10);
        rare.add(ITID_THE_X_RING, 10);
        rare.add(ITID_TIDAL_LOOP, 10);
        rare.add(ITID_TROLL_BANE, 10);
        rare.add(ITID_VISKAG, 10);

        uncommon.add(ITID_COLOSSUS_BLADE, 20);
        uncommon.add(ITID_HEALTH_STONE, 20);
        uncommon.add(ITID_UNGLAZED_ICON_OF_THE_CRESCENT, 20);
        uncommon.add(ITID_MANA_STONE, 20);
        uncommon.add(ITID_MOROES_LUCKY_GEAR, 20);
        uncommon.add(ITID_ROMULOS_EXPIRED_POISON, 20);
        uncommon.add(ITID_RUNED_BELT, 20);

        uncommon.add(ITID_ARMAGEDDON_SCROLL, 2);
        uncommon.add(ITID_WEAKEN_CURSE_SCROLL, 2);

        uncommon.add(ITID_HEAL_SCROLL, 5);
        uncommon.add(ITID_SLAYER_SCROLL, 5);
        uncommon.add(ITID_SANCTUARY_SCROLL, 5);
        // uncommon.add(ITID_BANSHEE_SCROLL, 5);

        // uncommon.add(ITID_ARANS_COUNTER_SPELL_SCROLL, 10);
        // uncommon.add(ITID_SPEED_SCROLL, 10);
        uncommon.add(ITID_FRENZY_SCROLL, 10);
        uncommon.add(ITID_DEFEND_SCROLL, 10);
        uncommon.add(ITID_MANA_SCROLL, 10);
        // uncommon.add(ITID_ROAR_SCROLL, 10);
        uncommon.add(ITID_SPELL_REFLECTION_SCROLL, 10);
        uncommon.add(ITID_MASS_DISPEL_SCROLL, 10);
        // uncommon.add(ITID_MASS_TELEPORT_SCROLL, 10);
        // uncommon.add(ITID_CORRUPTION_SCROLL, 10);

        uncommon.add(ITID_MANA_SOURCE_POTION, 5);
        // uncommon.add(ITID_ARCH_MAGE_POTION, 5);
        // uncommon.add(ITID_COMBAT_MASTER_POTION, 5);
        // uncommon.add(ITID_SHIELD_POTION, 5);
        // uncommon.add(ITID_FORTRESS_POTION, 5);
        uncommon.add(ITID_INVUL_POTION, 5);
        // uncommon.add(ITID_UNSTABLE_POTION, 5);

        // uncommon.add(ITID_LEECH_POTION, 10);
        // uncommon.add(ITID_LIFE_REGEN_POTION, 10);
        // uncommon.add(ITID_MANA_REGEN_POTION, 10);
        // uncommon.add(ITID_TRANQUILITY_POTION, 10);
        uncommon.add(ITID_BIG_LIFE_POTION, 10);
        uncommon.add(ITID_EMPERORS_NEW_POTION, 10);
        // uncommon.add(ITID_TRANSFER_POTION, 10);
        // uncommon.add(ITID_DODGE_POTION, 10);
        // uncommon.add(ITID_SMALL_INVUL_POTION, 10);
        // uncommon.add(ITID_STONE_SKIN_POTION, 10);
        uncommon.add(ITID_SPELL_POWER_POTION, 10);
        // uncommon.add(ITID_SPELL_MASTER_POTION, 10);
        uncommon.add(ITID_ARCANE_POTION, 10);
        // uncommon.add(ITID_ANGRY_CAST_POTION, 10);
        // uncommon.add(ITID_SPELL_PIERCE_POTION, 10);
        // uncommon.add(ITID_AGILITY_POTION, 10);
        // uncommon.add(ITID_ACUTE_POTION, 10);
        // uncommon.add(ITID_DEXTERITY_POTION, 10);
        // uncommon.add(ITID_LIFE_POTION, 10);
        // uncommon.add(ITID_MANA_POTION, 10);

        boss1.add(ITID_THE_X_RING, 15);
        boss1.add(ITID_GOBLIN_ROCKET_BOOTS_LIMITED_EDITION, 25);
        boss1.add(ITID_CORE_HOUND_TOOTH, 7);
        boss1.add(ITID_VISKAG, 11);
        boss1.add(ITID_ARMOR_OF_THE_DAMNED, 10);
        boss1.add(ITID_BULWARK_OF_THE_AMANI_EMPIRE, 11);
        boss1.add(ITID_PURE_ARCANE, 11);
        boss1.add(ITID_STAFF_OF_THE_SHADOW_FLAME, 10);

        boss2.add(ITID_THE_X_RING, 10);
        boss2.add(ITID_TROLL_BANE, 9);
        boss2.add(ITID_LION_HORN, 20);
        boss2.add(ITID_ARANS_SOOTHING_EMERALD, 9);
        boss2.add(ITID_PURE_ARCANE, 13);
        boss2.add(ITID_HEX_SHRUNKEN_HEAD, 10);
        boss2.add(ITID_STAFF_OF_THE_SHADOW_FLAME, 13);
        boss2.add(ITID_TIDAL_LOOP, 16);

        boss3.add(ITID_THE_X_RING, 11);
        boss3.add(ITID_GOBLIN_ROCKET_BOOTS_LIMITED_EDITION, 11);
        boss3.add(ITID_VISKAG, 12);
        boss3.add(ITID_SIGNET_OF_THE_LAST_DEFENDER, 15);
        boss3.add(ITID_ARANS_SOOTHING_EMERALD, 13);
        boss3.add(ITID_PURE_ARCANE, 13);
        boss3.add(ITID_HEX_SHRUNKEN_HEAD, 9);
        boss3.add(ITID_TIDAL_LOOP, 16);

        boss4.add(ITID_WARSONG_BATTLE_DRUMS, 11);
        boss4.add(ITID_TROLL_BANE, 17);
        boss4.add(ITID_GOREHOWL, 10);
        boss4.add(ITID_VISKAG, 14);
        boss4.add(ITID_SIGNET_OF_THE_LAST_DEFENDER, 14);
        boss4.add(ITID_HEX_SHRUNKEN_HEAD, 14);
        boss4.add(ITID_STAFF_OF_THE_SHADOW_FLAME, 14);
        boss4.add(ITID_TIDAL_LOOP, 6);

        boss5.add(ITID_WARSONG_BATTLE_DRUMS, 13);
        boss5.add(ITID_TROLL_BANE, 12);
        boss5.add(ITID_GOREHOWL, 12);
        boss5.add(ITID_CORE_HOUND_TOOTH, 14);
        boss5.add(ITID_LION_HORN, 10);
        boss5.add(ITID_ARMOR_OF_THE_DAMNED, 15);
        boss5.add(ITID_BULWARK_OF_THE_AMANI_EMPIRE, 15);
        boss5.add(ITID_SIGNET_OF_THE_LAST_DEFENDER, 9);

        boss6.add(ITID_WARSONG_BATTLE_DRUMS, 12);
        boss6.add(ITID_GOREHOWL, 15);
        boss6.add(ITID_CORE_HOUND_TOOTH, 17);
        boss6.add(ITID_LION_HORN, 7);
        boss6.add(ITID_ARMOR_OF_THE_DAMNED, 12);
        boss6.add(ITID_BULWARK_OF_THE_AMANI_EMPIRE, 12);
        boss6.add(ITID_ARANS_SOOTHING_EMERALD, 15);
        boss6.add(ITID_HEX_SHRUNKEN_HEAD, 10);

        boss7.add(ITID_THE_X_RING, 7);
        boss7.add(ITID_GOBLIN_ROCKET_BOOTS_LIMITED_EDITION, 7);
        boss7.add(ITID_WARSONG_BATTLE_DRUMS, 7);
        boss7.add(ITID_TROLL_BANE, 6);
        boss7.add(ITID_GOREHOWL, 7);
        boss7.add(ITID_CORE_HOUND_TOOTH, 6);
        boss7.add(ITID_VISKAG, 7);
        boss7.add(ITID_LION_HORN, 7);
        boss7.add(ITID_ARMOR_OF_THE_DAMNED, 7);
        boss7.add(ITID_BULWARK_OF_THE_AMANI_EMPIRE, 6);
        boss7.add(ITID_SIGNET_OF_THE_LAST_DEFENDER, 6);
        boss7.add(ITID_ARANS_SOOTHING_EMERALD, 7);
        boss7.add(ITID_PURE_ARCANE, 7);
        boss7.add(ITID_STAFF_OF_THE_SHADOW_FLAME, 7);
        boss7.add(ITID_TIDAL_LOOP, 6);
    }

}
//! endzinc
