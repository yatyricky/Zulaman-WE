//! zinc
library Loot requires IntegerPool, ZAMCore {
#define RP_FACTOR 4000
#define TABLE_SIZE 65
#define RP_RELIC 1.5
#define RP_RARE 4.0
#define RP_UNCOMMON 15.0
#define RP_COMMON 7.0
    IntegerPool relicGear, relicAll;
    public IntegerPool classSpec;
    IntegerPool rareAll;
    IntegerPool relicRareConsumable;
    IntegerPool uncomGear, uncomAll, uncomRnd;
    IntegerPool commonAll;
    IntegerPool boss1, boss2, boss3, boss4, boss5, boss6, boss7;
    Table bossPools;    
    
    function GetRandomPrefixGear() -> integer {
        integer prefix = GetRandomInt(1, 13);
        if (prefix > 9) {prefix += 39;}
        return uncomRnd.get() + prefix;
    }
    
    function minionsDrop(unit u) {
        integer monsterDropValue, mdp;
        real factor, rp0, rp1, rp2, rp3;
        real roll;
        integer itid;
        real x, y;
        x = GetUnitX(u); y = GetUnitY(u);
        monsterDropValue = UnitProp[u].getDropValue();
        mdp = monsterDropValue;
        //BJDebugMsg("MDP = " + I2S(mdp));
        while (mdp >= 0) {
            factor = I2R(mdp) / I2R(RP_FACTOR);
            rp0 = factor * RP_RELIC;
            rp1 = factor * RP_RARE;
            rp2 = factor * RP_UNCOMMON;
            rp3 = factor * RP_COMMON;
            roll = GetRandomReal(0, 99.0);
            //BJDebugMsg("Prob table: " + R2S(rp0) + ", " + R2S(rp1) + ", " + R2S(rp2) + ", " + R2S(rp3));
            //BJDebugMsg("Roll: " + R2S(roll));
            if (roll < TABLE_SIZE) {
                if (roll < rp0) {
                    itid = relicAll.get();
                    if (IsItemUnique(CreateItemEx(itid, x, y))) {
                        relicGear.remove(itid);
                        relicAll.remove(itid);
                    }
                } else if (roll < rp0 + rp1) {
                    itid = rareAll.get();
                    CreateItemEx(itid, x, y);
                } else if (roll < rp0 + rp1 + rp2) {
                    itid = uncomAll.get();
                    if (itid == 99) {itid = GetRandomPrefixGear();}
                    if (IsItemUnique(CreateItemEx(itid, x, y))) {
                        uncomGear.remove(itid);
                        uncomAll.remove(itid);
                    }
                } else if (roll < rp0 + rp1 + rp2 + rp3 && monsterDropValue < 9001) {
                    itid = commonAll.get();
                    CreateItemEx(itid, x, y);
                }
            }
            mdp -= RP_FACTOR;
        }
    }
    
    function mobDeathDrop(unit u) {
        integer itid;
        IntegerPool ip;
        real x, y;
        if (GetPlayerId(GetOwningPlayer(u)) == MOB_PID) {
            x = GetUnitX(u); y = GetUnitY(u);
            if (IsUnitType(u, UNIT_TYPE_HERO)) { // boss drops
                // 1. 35% relic gear + 65% relic rare consumable
                if (GetRandomInt(0, 99) < 35) { 
                    itid = relicGear.get();
                    relicGear.remove(itid);
                    relicAll.remove(itid);
                } else {
                    itid = relicRareConsumable.get();
                }
                CreateItemEx(itid, x, y);
//BJDebugMsg("Item 1: " + ID2S(itid));
                // 2. class spec gear
                itid = classSpec.get();
                if (itid > 0) {
                    classSpec.remove(itid);
                } else {
                    itid = rareAll.get();
                }
                CreateItemEx(itid, x, y);
//BJDebugMsg("Item 2: " + ID2S(itid));
                // 3. 25% uncom gear + 75% rare boss
                if (GetRandomInt(0, 99) < 25) { 
                    itid = uncomGear.get();
                    if (itid == 99) {itid = GetRandomPrefixGear();}
                } else {
                    ip = IntegerPool(bossPools[GetUnitTypeId(u)]);
                    itid = ip.get();
                    boss1.remove(itid);
                    boss2.remove(itid);
                    boss3.remove(itid);
                    boss4.remove(itid);
                    boss5.remove(itid);
                    boss6.remove(itid);
                    boss7.remove(itid);
                }
                if (IsItemUnique(CreateItemEx(itid, x, y))) {
                    uncomGear.remove(itid);
                    uncomAll.remove(itid);
                }
//BJDebugMsg("Item 3: " + ID2S(itid));
                // 4. 5% relic all + 95% uncom all
                if (GetRandomInt(0, 99) < 5) { 
                    itid = relicAll.get();
                } else {
                    itid = uncomAll.get();                    
                    if (itid == 99) {itid = GetRandomPrefixGear();}
                }
                if (IsItemUnique(CreateItemEx(itid, x, y))) {
                    relicGear.remove(itid);
                    relicAll.remove(itid);
                    uncomGear.remove(itid);
                    uncomAll.remove(itid);
                }      
//BJDebugMsg("Item 4: " + ID2S(itid));          
            } else if (CanUnitAttack(u) && !IsUnitSummoned(u)) {
                // Minions drop
                minionsDrop(u);
            }
        }
    }
    
    function onInit() {       
        RegisterUnitDeath(mobDeathDrop);
    
        relicGear = IntegerPool.create();
        relicAll = IntegerPool.create();
        classSpec = IntegerPool.create();
        rareAll = IntegerPool.create();
        relicRareConsumable = IntegerPool.create();
        uncomGear = IntegerPool.create();
        uncomAll = IntegerPool.create();
        uncomRnd = IntegerPool.create();
        commonAll = IntegerPool.create();
        
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
        bossPools[UTIDNAGASEAWITCH] = boss2;
        bossPools[UTIDTIDEBARON] = boss3;
        bossPools[UTIDTIDEBARONWATER] = boss3;
        bossPools[UTIDWARLOCK] = boss4;
        bossPools[UTID_PIT_ARCHON] = boss5;
        bossPools[UTID_FEL_GUARD] = boss6;
        bossPools[UTIDHEXLORD] = boss7;
        
        relicGear.add(ITIDBREATHOFTHEDYING, 10);
        relicGear.add(ITIDCALLTOARMS, 10);
        relicGear.add(ITID_CTHUNS_DERANGEMENT, 10);
        relicGear.add(ITIDENIGMA, 10);
        relicGear.add(ITIDINFINITY, 10);
        relicGear.add(ITIDINSIGHT, 10);
        relicGear.add(ITID_TYRAELS_MIGHT, 10);
        relicGear.add(ITID_VOODOO_VIAL, 10);
        relicGear.add(ITIDWOESTAVE, 10);
        relicGear.add(ITIDWINDFORCE, 10);
        
        relicAll.add(ITIDBREATHOFTHEDYING, 10);
        relicAll.add(ITIDCALLTOARMS, 10);
        relicAll.add(ITID_CTHUNS_DERANGEMENT, 10);
        relicAll.add(ITIDENIGMA, 10);
        relicAll.add(ITIDINFINITY, 10);
        relicAll.add(ITIDINSIGHT, 10);
        relicAll.add(ITID_TYRAELS_MIGHT, 10);
        relicAll.add(ITID_VOODOO_VIAL, 10);
        relicAll.add(ITIDWOESTAVE, 10);
        relicAll.add(ITIDWINDFORCE, 10);
        relicAll.add('I003', 10);   // 末日审判卷轴
        relicAll.add('I00D', 10);   // 虚弱诅咒卷轴
        relicAll.add('I00E', 10);   // 魔力之源
        
        relicRareConsumable.add('I003', 10);    // 末日审判卷轴
        relicRareConsumable.add('I00D', 10);    // 虚弱诅咒卷轴
        relicRareConsumable.add('I00E', 10);    // 魔力之源
        relicRareConsumable.add('shea', 10);    // 医疗卷轴
        relicRareConsumable.add('srrc', 10);    // 杀戮卷轴
        relicRareConsumable.add('I006', 10);    // 庇护所卷轴
        relicRareConsumable.add('I00C', 10);    // 女妖之嚎卷轴
        relicRareConsumable.add('I005', 10);    // 闪电链符咒
        relicRareConsumable.add('I00G', 10);    // 死亡之指符咒
        relicRareConsumable.add('I00J', 10);    // 魔导师药剂
        relicRareConsumable.add('I00N', 10);    // 战斗大师药剂
        relicRareConsumable.add('I00S', 10);    // 护盾药剂
        relicRareConsumable.add('I00V', 10);    // 壁垒药剂
        relicRareConsumable.add('pnvu', 10);    // 无敌药水
        relicRareConsumable.add('I010', 10);    // 不稳定的药剂
        /*
        classSpec.add(ITIDORBOFTHESINDOREI, 10);
        classSpec.add(ITIDREFORGEDBADGEOFTENACITY, 10);
        classSpec.add(ITIDLIGHTSJUSTICE, 10);
        classSpec.add(ITIDBENEDICTION, 10);
        classSpec.add(ITIDHORNOFCENARIUS, 10);
        classSpec.add(ITIDORCCAPTUREFLAG, 10);
        classSpec.add(ITIDDAGGEROFASSASSINATION, 10);
        classSpec.add(ITIDRHOKDELAR, 10);
        classSpec.add(ITIDRAGEWINTERCHILLSPHYLACTERY, 10);
        classSpec.add(ITIDANATHEMA, 10);
        classSpec.add(ITIDRARESHIMMERWEED, 10);*/
        
        rareAll.add(ITID_ARANS_SOOTHING_AGATE, 10);
        rareAll.add(ITID_BULWARK_OF_THE_AMANI_EMPIRE, 10);
        rareAll.add(ITID_CORE_HOUND_TOOTH, 10);
        rareAll.add(ITID_CURSED_CUIRASS, 10);
        rareAll.add(ITID_DRUM, 10);
        rareAll.add(ITID_GOBLIN_ROCKET_BOOTS_LIMITED_EDITION, 10);
        rareAll.add(ITID_GORE_HOWL, 10);
        rareAll.add(ITID_HEX_SHRUNKEN_HEAD, 10);
        rareAll.add(ITID_LION_HORN, 10);
        rareAll.add(ITID_PURE_ARCANE, 10);
        rareAll.add(ITID_SIGNET_OF_THE_LAST_DEFENDER, 10);
        rareAll.add(ITID_STAFF_OF_THE_SHADOW_FLAME, 10);
        rareAll.add(ITID_THE_21_RING, 10);
        rareAll.add(ITID_TIDAL_LOOP, 10);
        rareAll.add(ITID_TROLL_BANE, 10);
        rareAll.add(ITID_VISKAG, 10);        
        rareAll.add('shea', 10);    // 医疗卷轴
        rareAll.add('srrc', 10);    // 杀戮卷轴
        rareAll.add('I006', 10);    // 庇护所卷轴
        rareAll.add('I00C', 10);    // 女妖之嚎卷轴
        rareAll.add('I005', 10);    // 闪电链符咒
        rareAll.add('I00G', 10);    // 死亡之指符咒
        rareAll.add('I00J', 10);    // 魔导师药剂
        rareAll.add('I00N', 10);    // 战斗大师药剂
        rareAll.add('I00S', 10);    // 护盾药剂
        rareAll.add('I00V', 10);    // 壁垒药剂
        rareAll.add('pnvu', 10);    // 无敌药水
        rareAll.add('I010', 10);    // 不稳定的药剂
        
        uncomGear.add(ITID_CRUEL_COLOSSUS_BLADE_OF_QUICKNESS, 10);
        uncomGear.add(ITID_HEALTH_STONE, 10);
        uncomGear.add(ITID_ICON_OF_THE_UNGLAZED_CRESCENT, 10);
        uncomGear.add(ITID_MANA_STONE, 10);
        uncomGear.add(ITID_MOROES_LUCKY_GEAR, 10);
        uncomGear.add(ITID_ROMULOS_EXPIRED_POISON, 10);
        uncomGear.add(ITID_RUNED_BRACERS, 10);
        uncomGear.add(99, 1300);    // 随机词缀绿装
        
        uncomAll.add(ITID_CRUEL_COLOSSUS_BLADE_OF_QUICKNESS, 10);
        uncomAll.add(ITID_HEALTH_STONE, 10);
        uncomAll.add(ITID_ICON_OF_THE_UNGLAZED_CRESCENT, 10);
        uncomAll.add(ITID_MANA_STONE, 10);
        uncomAll.add(ITID_MOROES_LUCKY_GEAR, 10);
        uncomAll.add(ITID_ROMULOS_EXPIRED_POISON, 10);
        uncomAll.add(ITID_RUNED_BRACERS, 10);
        uncomAll.add(99, 1300);     // 随机词缀绿装
        uncomAll.add('Ial0', 10);   // 埃兰的反制卷轴
        uncomAll.add('shas', 10);   // 加速卷轴
        uncomAll.add('Ifz0', 10);   // 狂热卷轴
        uncomAll.add('spro', 10);   // 守护卷轴
        uncomAll.add('sman', 10);   // 魔法卷轴
        uncomAll.add('sror', 10);   // 野兽卷轴
        uncomAll.add('I00M', 10);   // 绝缘卷轴
        uncomAll.add('I017', 10);   // 大型驱魔卷轴
        uncomAll.add('I002', 10);   // 群体传送卷轴
        uncomAll.add('I004', 10);   // 腐蚀卷轴
        uncomAll.add('I01I', 10);   // 简易治疗符咒
        uncomAll.add('I01G', 10);   // 驱散术符咒
        uncomAll.add('I01F', 10);   // 治疗结界符咒
        uncomAll.add('I01E', 10);   // 心灵之火符咒
        uncomAll.add('I00A', 10);   // 吸血药水
        uncomAll.add('I00Q', 10);   // 再生药水
        uncomAll.add('I00R', 10);   // 清晰预兆药水
        uncomAll.add('I00F', 10);   // 宁静药水
        uncomAll.add('I00I', 10);   // 大生命药水
        uncomAll.add('I00O', 10);   // 皇帝的新药
        uncomAll.add('I01J', 10);   // 转换药剂
        uncomAll.add('I00W', 10);   // 闪避药水
        uncomAll.add('pnvl', 10);   // 小无敌药水
        uncomAll.add('I008', 10);   // 石皮药水
        uncomAll.add('I00B', 10);   // 法能药水
        uncomAll.add('I00X', 10);   // 法术掌控药水
        uncomAll.add('I01Q', 10);   // 秘法药水
        uncomAll.add('I007', 10);   // 愤怒施法药水
        uncomAll.add('I00Z', 10);   // 法术穿透药水
        uncomAll.add('I009', 10);   // 敏捷药水
        uncomAll.add('I011', 10);   // 敏锐药水
        uncomAll.add('I00Y', 10);   // 迅捷药水
        
        uncomRnd.add('Igz0', 10);
        uncomRnd.add('Ijs0', 10);
        uncomRnd.add('Ics0', 10);
        uncomRnd.add('Ixp0', 10);
        uncomRnd.add('Ish0', 10);
        uncomRnd.add('Isb0', 10);
        uncomRnd.add('Inl0', 10);
        uncomRnd.add('Imz0', 10);
        uncomRnd.add('Iwz0', 10);
        uncomRnd.add('Igh0', 10);
        
        commonAll.add(ITID_BOOTS_OF_SLOW, 10);
        commonAll.add(ITID_HELM_OF_VALOUR, 10);
        commonAll.add(ITID_HOOD_OF_CUNNING, 10);
        commonAll.add(ITID_MEDALION_OF_COURAGE, 10);        
        commonAll.add('Ics0', 10);  // 刺杀剑
        commonAll.add('Ijs0', 10);  // 加速手套
        commonAll.add('Ish0', 10);  // 守护指环
        commonAll.add('Iwz0', 10);  // 巫医法杖
        commonAll.add('Igz0', 10);  // 攻击之爪
        commonAll.add('Ixp0', 10);  // 生命护符
        commonAll.add('Inl0', 10);  // 能量垂饰
        commonAll.add('Imz0', 10);  // 艺人面罩
        commonAll.add('Igh0', 10);  // 贵族圆环
        commonAll.add('Isb0', 10);  // 闪避护符
        commonAll.add('Igh0', 10);  // 贵族圆环
        commonAll.add('Isb0', 10);  // 闪避护符
        commonAll.add('phea', 10);  // 生命药水
        commonAll.add('pman', 10);  // 魔法药水

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
#undef RP_COMMON
#undef RP_UNCOMMON
#undef RP_RARE
#undef RP_RELIC
#undef TABLE_SIZE
#undef RP_FACTOR
}
//! endzinc
