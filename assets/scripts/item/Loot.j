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
        integer e = UnitProp.inst(u, SCOPE_PREFIX).getDropValue();
        real iteration;
        integer qlvl = 0;
        real rate;
        integer itid = 0;
        real x = GetUnitX(u);
        real y = GetUnitY(u);
        if (e < ILVL_THRESHOLD[0]) {
            qlvl = 0;
        } else if (e < ILVL_THRESHOLD[1]) {
            qlvl = 1;
        } else {
            qlvl = 2;
        }
        loot2 += e;
        iteration = 1;
        while (qlvl > -1) {
            rate = loot2 / ILVL_THRESHOLD_VALUE[qlvl] / iteration * ILVL_MAX_RATE;
            if (GetRandomReal(0, 0.999) < rate) {
                loot2 = 0.0;
                if (qlvl == 0) {
                    itid = uncommon.get();
                    CreateItemEx(itid, x, y, e);
                } else if (qlvl == 1) {
                    itid = rare.get();
                    CreateItemEx(itid, x, y, e);
                } else {
                    itid = relic.get();
                    CreateItemEx(itid, x, y, e);
                }
            }
            qlvl -= 1;
            iteration *= ILVL_MULTIPLE_REDUCTION;
        }
        if (itid == 0 && IsUnitChampion(u)) {
            itid = rare.get();
            loot2 = 0.0;
            CreateItemEx(itid, x, y, e);
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
                } else {
                    itid = rare.get();
                }
                CreateItemEx(itid, x, y, monsterDropValue);
                // 2. class spec gear
                itid = classSpec.get();
                if (itid > 0) {
                    classSpec.remove(itid);
                } else {
                    if (GetRandomReal(0, 0.999) < 0.2) {
                        itid = relic.get();
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
        
        relic.add(ITID_DYING_BREATH, 12);
        relic.add(ITID_CALL_TO_ARMS, 13);
        relic.add(ITID_DERANGEMENT_OF_CTHUN, 6);
        relic.add(ITID_ENIGMA, 2);
        relic.add(ITID_INFINITY, 9);
        relic.add(ITID_INSIGHT, 15);
        relic.add(ITID_MIGHT_OF_THE_ANGEL_OF_JUSTICE, 2);
        relic.add(ITID_GURUBASHI_VOODOO_VIALS, 9);
        relic.add(ITID_WOESTAVE, 13);
        relic.add(ITID_WINDFORCE, 6);
        relic.add(ITID_MOONLIGHT_GREATSWORD, 10);
        relic.add(ITID_ZULS_STAFF, 8);

        rare.add(ITID_MAUL, 30);
        rare.add(ITID_CLOAK, 30);
        rare.add(ITID_SCEPTER, 30);
        rare.add(ITID_EAGLE_GOD_GAUNTLETS, 20);
        rare.add(ITID_MOONSTONE, 28);
        rare.add(ITID_SHADOW_ORB, 24);
        rare.add(ITID_COLOSSUS_BLADE, 36);
        rare.add(ITID_THE_X_RING, 52);
        rare.add(ITID_GOBLIN_ROCKET_BOOTS_LIMITED_EDITION, 52);
        rare.add(ITID_WARSONG_BATTLE_DRUMS, 36);
        rare.add(ITID_TROLL_BANE, 24);
        rare.add(ITID_GOREHOWL, 24);
        rare.add(ITID_CORE_HOUND_TOOTH, 48);
        rare.add(ITID_VISKAG, 36);
        rare.add(ITID_LION_HORN, 48);
        rare.add(ITID_ARMOR_OF_THE_DAMNED, 6);
        rare.add(ITID_BULWARK_OF_THE_AMANI_EMPIRE, 6);
        rare.add(ITID_SIGNET_OF_THE_LAST_DEFENDER, 6);
        rare.add(ITID_ARANS_SOOTHING_EMERALD, 40);
        rare.add(ITID_PURE_ARCANE, 30);
        rare.add(ITID_HEX_SHRUNKEN_HEAD, 30);
        rare.add(ITID_STAFF_OF_THE_SHADOW_FLAME, 30);
        rare.add(ITID_TIDAL_LOOP, 50);
        rare.add(ITID_DRAKKARI_DECAPITATOR, 40);
        rare.add(ITID_SHINING_JEWEL_OF_TANARIS, 30);
        rare.add(ITID_ORB_OF_THE_SINDOREI, 1);
        rare.add(ITID_REFORGED_BADGE_OF_TENACITY, 1);
        rare.add(ITID_LIGHTS_JUSTICE, 1);
        rare.add(ITID_BENEDICTION, 1);
        rare.add(ITID_HORN_OF_CENARIUS, 1);
        rare.add(ITID_BANNER_OF_THE_HORDE, 1);
        rare.add(ITID_KELENS_DAGGER_OF_ASSASSINATION, 1);
        rare.add(ITID_RHOKDELAR, 1);
        rare.add(ITID_RAGE_WINTERCHILLS_PHYLACTERY, 1);
        rare.add(ITID_ANATHEMA, 1);
        rare.add(ITID_RARE_SHIMMER_WEED, 1);

        uncommon.add(ITID_BELT_OF_GIANT, 7);
        uncommon.add(ITID_BOOTS_OF_QUELTHALAS, 7);
        uncommon.add(ITID_ROBE_OF_MAGI, 15);
        uncommon.add(ITID_CIRCLET_OF_NOBILITY, 10);
        uncommon.add(ITID_BOOTS_OF_SPEED, 8);
        uncommon.add(ITID_HELM_OF_VALOR, 14);
        uncommon.add(ITID_MEDALION_OF_COURAGE, 19);
        uncommon.add(ITID_HOOD_OF_CUNNING, 22);
        uncommon.add(ITID_CLAWS_OF_ATTACK, 14);
        uncommon.add(ITID_GLOVES_OF_HASTE, 7);
        uncommon.add(ITID_SWORD_OF_ASSASSINATION, 7);
        uncommon.add(ITID_VITALITY_PERIAPT, 16);
        uncommon.add(ITID_RING_OF_PROTECTION, 2);
        uncommon.add(ITID_TALISMAN_OF_EVASION, 2);
        uncommon.add(ITID_MANA_PERIAPT, 13);
        uncommon.add(ITID_SOBI_MASK, 12);
        uncommon.add(ITID_MAGIC_BOOK, 15);
        uncommon.add(ITID_CRYSTAL_BALL, 8);
        uncommon.add(ITID_LONG_STAFF, 8);
        uncommon.add(ITID_HEALTH_STONE, 16);
        uncommon.add(ITID_MANA_STONE, 13);
        uncommon.add(ITID_ROMULOS_EXPIRED_POISON, 12);
        uncommon.add(ITID_MOROES_LUCKY_GEAR, 2);
        uncommon.add(ITID_RUNED_BELT, 8);
        uncommon.add(ITID_UNGLAZED_ICON_OF_THE_CRESCENT, 15);

        boss1.add(ITID_MAUL, 10);
        boss1.add(ITID_CLOAK, 10);
        boss1.add(ITID_SCEPTER, 10);
        boss1.add(ITID_COLOSSUS_BLADE, 10);
        boss1.add(ITID_THE_X_RING, 5);
        boss1.add(ITID_GOBLIN_ROCKET_BOOTS_LIMITED_EDITION, 15);
        boss1.add(ITID_ARMOR_OF_THE_DAMNED, 10);
        boss1.add(ITID_PURE_ARCANE, 10);
        boss1.add(ITID_STAFF_OF_THE_SHADOW_FLAME, 10);
        boss1.add(ITID_EAGLE_GOD_GAUNTLETS, 10);

        boss2.add(ITID_CLOAK, 10);
        boss2.add(ITID_TROLL_BANE, 10);
        boss2.add(ITID_LION_HORN, 15);
        boss2.add(ITID_ARMOR_OF_THE_DAMNED, 5);
        boss2.add(ITID_ARANS_SOOTHING_EMERALD, 10);
        boss2.add(ITID_HEX_SHRUNKEN_HEAD, 10);
        boss2.add(ITID_TIDAL_LOOP, 10);
        boss2.add(ITID_MOONSTONE, 10);

        boss3.add(ITID_MAUL, 10);
        boss3.add(ITID_GOBLIN_ROCKET_BOOTS_LIMITED_EDITION, 10);
        boss3.add(ITID_CORE_HOUND_TOOTH, 10);
        boss3.add(ITID_VISKAG, 10);
        boss3.add(ITID_SIGNET_OF_THE_LAST_DEFENDER, 10);
        boss3.add(ITID_ARANS_SOOTHING_EMERALD, 10);
        boss3.add(ITID_TIDAL_LOOP, 10);
        boss3.add(ITID_EAGLE_GOD_GAUNTLETS, 10);
        boss3.add(ITID_MOONSTONE, 10);

        boss4.add(ITID_SCEPTER, 15);
        boss4.add(ITID_ARANS_SOOTHING_EMERALD, 5);
        boss4.add(ITID_PURE_ARCANE, 15);
        boss4.add(ITID_HEX_SHRUNKEN_HEAD, 10);
        boss4.add(ITID_STAFF_OF_THE_SHADOW_FLAME, 15);
        boss4.add(ITID_SHADOW_ORB, 25);
        boss4.add(ITID_SHINING_JEWEL_OF_TANARIS, 15);

        boss5.add(ITID_MAUL, 5);
        boss5.add(ITID_COLOSSUS_BLADE, 10);
        boss5.add(ITID_WARSONG_BATTLE_DRUMS, 15);
        boss5.add(ITID_TROLL_BANE, 10);
        boss5.add(ITID_GOREHOWL, 10);
        boss5.add(ITID_CORE_HOUND_TOOTH, 10);
        boss5.add(ITID_LION_HORN, 10);
        boss5.add(ITID_ARMOR_OF_THE_DAMNED, 10);
        boss5.add(ITID_BULWARK_OF_THE_AMANI_EMPIRE, 15);
        boss5.add(ITID_SIGNET_OF_THE_LAST_DEFENDER, 5);

        boss6.add(ITID_CLOAK, 8);
        boss6.add(ITID_COLOSSUS_BLADE, 8);
        boss6.add(ITID_THE_X_RING, 15);
        boss6.add(ITID_WARSONG_BATTLE_DRUMS, 10);
        boss6.add(ITID_GOREHOWL, 10);
        boss6.add(ITID_CORE_HOUND_TOOTH, 5);
        boss6.add(ITID_VISKAG, 12);
        boss6.add(ITID_BULWARK_OF_THE_AMANI_EMPIRE, 10);
        boss6.add(ITID_SIGNET_OF_THE_LAST_DEFENDER, 10);
        boss6.add(ITID_HEX_SHRUNKEN_HEAD, 7);

        boss7.add(ITID_MAUL, 3);
        boss7.add(ITID_SCEPTER, 3);
        boss7.add(ITID_THE_X_RING, 8);
        boss7.add(ITID_GOBLIN_ROCKET_BOOTS_LIMITED_EDITION, 3);
        boss7.add(ITID_WARSONG_BATTLE_DRUMS, 3);
        boss7.add(ITID_TROLL_BANE, 8);
        boss7.add(ITID_GOREHOWL, 8);
        boss7.add(ITID_CORE_HOUND_TOOTH, 3);
        boss7.add(ITID_VISKAG, 6);
        boss7.add(ITID_LION_HORN, 3);
        boss7.add(ITID_ARMOR_OF_THE_DAMNED, 3);
        boss7.add(ITID_BULWARK_OF_THE_AMANI_EMPIRE, 3);
        boss7.add(ITID_SIGNET_OF_THE_LAST_DEFENDER, 3);
        boss7.add(ITID_ARANS_SOOTHING_EMERALD, 3);
        boss7.add(ITID_PURE_ARCANE, 3);
        boss7.add(ITID_HEX_SHRUNKEN_HEAD, 1);
        boss7.add(ITID_STAFF_OF_THE_SHADOW_FLAME, 3);
        boss7.add(ITID_TIDAL_LOOP, 8);
        boss7.add(ITID_EAGLE_GOD_GAUNTLETS, 8);
        boss7.add(ITID_MOONSTONE, 8);
        boss7.add(ITID_SHADOW_ORB, 3);
        boss7.add(ITID_SHINING_JEWEL_OF_TANARIS, 3);
        boss7.add(ITID_DRAKKARI_DECAPITATOR, 3);

    }

}
//! endzinc
