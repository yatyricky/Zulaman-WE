//! zinc
library ItemAttributes requires UnitProperty, List, BreathOfTheDying, WindForce, Infinity, ConvertAttackMagic, MagicPoison, VoodooVial, RomulosExpiredPoison, Drum, MoonlightExplosion, NonHeroExtraDamage, AttackChanceICC, AttackBleed, AttackStun, LethalMagicalDamage, ArthassCorruption, IconOfTheUnglazedCrescent, ArcanePotion {
    public constant real AFFIX_FACTOR_BASE = 15000;
    public constant real AFFIX_FACTOR_DELTA = 2500;
    public constant real SUFIX_MULTIPLIER = 4;
    public constant real PREFIX_STATIC_MOD = -0.5;
    public constant real SUFIX_STATIC_MOD = -0.2;
    public constant real PREFIX_MAX_PROB = 0.9;
    public constant real SUFIX_MAX_PROB = 0.75;

    public struct ItemColors {

    }

    public type ItemPropModType extends function(unit, item, integer);

    IntegerPool ipPrefix1;
    IntegerPool ipPrefix2;
    IntegerPool ipSufix;

    rect ApprenticeAnvil;
    rect ExpertAnvil;
    rect MasterAnvil;
    integer countReforge;
    boolean reforgeTypeCheck;
    integer reforgeClosureQlvl;
    item reforgingItem;
    ListObject shouldDestroy;

    public struct ItemExAttributes {
        static HandleTable ht;
        static item droppingItem;
        ListObject/*<AttributeEntry>*/ attributes;
        ListObject/*<ItemAffix>*/ affixes;
        real exp;
        item theItem;

        static integer n = 0;

        static method showAllItemInstances() {
            print("ItemExAttributes.n = " + I2S(ItemExAttributes.n));
            print("ItemAttributesMeta.n = " + I2S(ItemAttributesMeta.n));
            print("ItemAffix.n = " + I2S(ItemAffix.n));
            print("AttributeEntry.n = " + I2S(AttributeEntry.n));
            print("AttributeMetaEntry.n = " + I2S(AttributeMetaEntry.n));
            print("AffixMeta.n = " + I2S(AffixMeta.n));
            print("AttributeBehaviourMeta.n = " + I2S(AttributeBehaviourMeta.n));
        }

        static method inst(item it, string trace) -> thistype {
            if (thistype.ht.exists(it)) {
                return thistype.ht[it];
            } else {
                print("Unknown item: " + ID2S(GetItemTypeId(it)) + ", trace: " + trace);
                return 0;
            }
        }

        static method create(item theItem, real exp) -> thistype {
            thistype this = thistype.allocate();
            this.exp = exp;
            this.attributes = ListObject.create();
            this.affixes = ListObject.create();
            this.theItem = theItem;
            thistype.ht[theItem] = this;
            this.applyMetaData();
            thistype.n += 1;
            return this;
        }

        method destroyAllAffixes() {
            NodeObject it = this.affixes.head;
            while (it != 0) {
                ItemAffix(it.data).destroy();
                it = it.next;
            }
            this.affixes.empty();
        }

        method destroyAllAttributes() {
            NodeObject it = this.attributes.head;
            while (it != 0) {
                AttributeEntry(it.data).destroy();
                it = it.next;
            }
            this.attributes.empty();
        }

        method destroy() {
            this.destroyAllAttributes();
            this.destroyAllAffixes();
            this.attributes.destroy();
            this.affixes.destroy();
            thistype.ht.flush(this.theItem);
            this.theItem = null;
            thistype.n -= 1;
            this.deallocate();
        }

        method applyMetaData() {
            ItemAttributesMeta meta = ItemAttributesMeta.inst(GetItemTypeId(this.theItem), SCOPE_PREFIX + ".apply");
            AttributeMetaEntry ame;
            NodeObject it;
            it = meta.entries.head;
            while (it != 0) {
                ame = AttributeMetaEntry(it.data);
                this.append(ame.attrId, GetRandomReal(ame.lo, ame.hi) * this.exp);
                it = it.next;
            }
        }

        static method finderIdComp(integer obj, integer search) -> boolean {
            return (AttributeEntry(obj).attrId == search);
        }

        method append(integer id, real val) {
            AttributeEntry ae = this.attributes.findObject(thistype.finderIdComp, id);
            if (ae == 0) {
                this.attributes.push(AttributeEntry.create(id, val));
            } else {
                ae.value += val;
            }
        }

        method appendAffix(ItemAffix affix) {
            NodeObject it = affix.entries.head;
            AttributeEntry ae;
            this.affixes.push(affix);
            while (it != 0) {
                ae = AttributeEntry(it.data);
                this.append(ae.attrId, ae.value);
                it = it.next;
            }
        }

        private method getAttributeValue(integer id, string trace) -> real {
            AttributeEntry ae = this.attributes.findObject(thistype.finderIdComp, id);
            if (ae == 0) {
                return 0.0;
            } else {
                return ae.value;
            }
        }

        static method getItemAttrVal(item it, integer id, boolean inclLP, string trace) -> real {
            thistype this = thistype.inst(it, trace);
            real retValue = this.getAttributeValue(id, trace + ">getItemAttrVal1");
            real lp = this.getAttributeValue(IATTR_LP, trace + ">getItemAttrVal2");
            AttributeBehaviourMeta abm = AttributeBehaviourMeta[id];
            if (inclLP == true && abm.cate == 2) { // 2: improvable
                return retValue * (1 + lp * abm.lpAmp);
            } else {
                return retValue;
            }
        }

        static method getUnitAttrVal(unit u, integer id, string trace) -> real {
            item ti;
            integer ii = 0;
            real amt = 0;
            while (ii < 6) {
                ti = UnitItemInSlot(u, ii);
                if (ti != null && ti != thistype.droppingItem && GetItemLevel(ti) > 1) {
                    amt += thistype.getItemAttrVal(ti, id, true, trace + ">getUnitAttrVal");
                }
                ii += 1;
            }
            ti = null;
            return amt;
        }

        static method getUnitAttrValMax(unit u, integer id, string trace) -> real {
            item ti;
            integer ii = 0;
            real amt = 0;
            real sel = -99999;
            boolean found = false;
            while (ii < 6) {
                ti = UnitItemInSlot(u, ii);
                if (ti != null && ti != thistype.droppingItem) {
                    amt = thistype.getItemAttrVal(ti, id, true, trace + ">getUnitAttrValMAX");
                    if (sel < amt) {
                        sel = amt;
                        found = true;
                    }
                }
                ii += 1;
            }
            ti = null;
            if (found == true) {
                return sel;
            } else {
                return 0.00;
            }
        }

        static method getUnitAttrValMin(unit u, integer id, string trace) -> real {
            item ti;
            integer ii = 0;
            real amt = 0;
            real sel = 99999;
            boolean found = false;
            while (ii < 6) {
                ti = UnitItemInSlot(u, ii);
                if (ti != null && ti != thistype.droppingItem) {
                    amt = thistype.getItemAttrVal(ti, id, true, trace + ">getUnitAttrValMin");
                    if (sel > amt) {
                        sel = amt;
                        found = true;
                    }
                }
                ii += 1;
            }
            ti = null;
            if (sel < 0) {
                sel = 0.0;
            }
            if (found == true) {
                return sel;
            } else {
                return 0.00;
            }
        }

        static method sortAttributes(integer a, integer b) -> integer {
            return AttributeBehaviourMeta[AttributeEntry(a).attrId].sort - AttributeBehaviourMeta[AttributeEntry(b).attrId].sort;
        }

        method forgeUbertip() -> string {
            NodeObject it;
            string str;
            string valstr;
            real finalValue;
            real lp;
            boolean hasLP;
            AttributeBehaviourMeta abm;
            AttributeEntry ae;
            ItemAttributesMeta iam = ItemAttributesMeta.inst(GetItemTypeId(this.theItem), "add_lore");
            this.attributes.sort(thistype.sortAttributes);
            it = this.attributes.head;
            str = "";
            lp = 0.0;
            hasLP = false;
            while (it != 0) {
                ae = AttributeEntry(it.data);
                abm = AttributeBehaviourMeta[ae.attrId];
                if (abm.cate == 4) {
                    // is set item
                } else {
                    if (ae.attrId == IATTR_LP) {
                        hasLP = true;
                        lp = ae.value;
                    }
                    if (ae.value == 0) {
                        str = str + abm.str1 + abm.str2;
                    } else {
                        finalValue = ae.value;
                        if (hasLP == true && abm.cate == 2) { // 2: improvable
                            finalValue = ae.value * (1 + lp * abm.lpAmp);
                        }
                        if (finalValue < 0) {
                            finalValue = 0;
                        }
                        if (finalValue < 1 || ae.attrId == IATTR_USE_CTHUN || ae.attrId == IATTR_BM_VALOR) {
                            valstr = I2S(Rounding(finalValue * 100)) + "%";
                        } else {
                            valstr = I2S(Rounding(finalValue));
                        }
                        str = str + abm.str1 + valstr + abm.str2;
                    }
                }
                if (it.next != 0) {
                    str = str + "|N";
                }
                it = it.next;
            }

            if (StringLength(iam.loreText) > 0) {
                str = str + "|n" + iam.loreText;
            }

            return str;
        }

        method calculateName() -> string {
            string rawName = ItemAttributesMeta.inst(GetItemTypeId(this.theItem), "updateName").name;
            NodeObject it = this.affixes.head;
            ItemAffix ia;
            AffixMeta meta;
            string sufix = "";
            string prefix = "";
            while (it != 0) {
                meta = AffixMeta[ItemAffix(it.data).id];
                if (meta.slot == 1) {
                    prefix = prefix + meta.text;
                } else {
                    sufix = sufix + meta.text;
                }
                it = it.next;
            }
            return prefix + sufix + rawName;
        }

        method updateUbertip() {
            string uber = this.calculateName() + "|n" + this.forgeUbertip();
            BlzSetItemExtendedTooltip(this.theItem, uber);
            BlzSetItemDescription(this.theItem, uber);
            BlzSetItemTooltip(this.theItem, uber);
            uber = null;
        }

        method updateName() {
            // string rawName = ItemAttributesMeta.inst(GetItemTypeId(this.theItem), "updateName").name;
            // NodeObject it = this.affixes.head;
            // ItemAffix ia;
            // AffixMeta meta;
            // string sufix = "";
            // string prefix = "";
            // while (it != 0) {
            //     meta = AffixMeta[ItemAffix(it.data).id];
            //     if (meta.slot == 1) {
            //         prefix = prefix + meta.text;
            //     } else {
            //         sufix = sufix + meta.text;
            //     }
            //     it = it.next;
            // }
            // BlzSetItemName(this.theItem, prefix + rawName + sufix);
        }

        method reforge(integer level) {
            ItemAttributesMeta meta = ItemAttributesMeta.inst(GetItemTypeId(this.theItem), "reforge");
            real exp;
            // calculate the exp value
            exp = level + GetRandomReal(-0.5, 0.5);
            if (exp < 1) {exp = 1.0;}
            // destroy previs affix and reforge default attributes
            this.destroyAllAffixes();
            this.destroyAllAttributes();
            this.applyMetaData();
            // append new affixes
            if (level == 1) {
                this.appendAffix(ItemAffix.create(ipPrefix1.get()));
            } else {
                this.appendAffix(ItemAffix.create(ipPrefix2.get()));
                if (level == 3) {
                    this.appendAffix(ItemAffix.create(ipSufix.get()));
                }
            }
        }

        static method onInit() {
            thistype.ht = HandleTable.create();
            thistype.droppingItem = null;
        }
    }

    struct ItemAttributesMeta {
        static Table ht;
        string name;
        string loreText;
        ListObject entries;

        static integer n = 0;

        static method inst(integer itid, string trace) -> thistype {
            if (thistype.ht.exists(itid)) {
                return thistype.ht[itid];
            } else {
                print("Unknown ITID: " + ID2S(itid) + ", trace: " + trace);
                return 0;
            }
        }

        static method create(integer itid, string name, string lore) -> thistype {
            thistype this = thistype.allocate();
            thistype.ht[itid] = this;
            this.name = name;
            this.loreText = lore;
            this.entries = ListObject.create();
            thistype.n += 1;
            return this;
        }

        method append(integer id, real lo, real hi) -> thistype {
            this.entries.push(AttributeMetaEntry.create(id, lo, hi));
            return this;
        }

        static method onInit() {
            thistype.ht = Table.create();
            TimerStart(CreateTimer(), 0.7, false, function() {
                DestroyTimer(GetExpiredTimer());
                //:template.id = itemmeta
                //:template.indentation = 4
                thistype.create(ITID_BELT_OF_GIANT,"|cff11ff11巨人力量腰带|r","").append(4,5,10);
                thistype.create(ITID_BOOTS_OF_QUELTHALAS,"|cff11ff11奎尔萨拉斯之靴|r","").append(13,5,10);
                thistype.create(ITID_ROBE_OF_MAGI,"|cff11ff11法师长袍|r","").append(14,5,10);
                thistype.create(ITID_CIRCLET_OF_NOBILITY,"|cff11ff11贵族头环|r","").append(7,4,7);
                thistype.create(ITID_BOOTS_OF_SPEED,"|cff11ff11笨重靴子|r","").append(24,11,17);
                thistype.create(ITID_HELM_OF_VALOR,"|cff11ff11英勇面具|r","").append(4,4,7).append(13,4,7);
                thistype.create(ITID_MEDALION_OF_COURAGE,"|cff11ff11勇气勋章|r","").append(4,4,7).append(14,4,7);
                thistype.create(ITID_HOOD_OF_CUNNING,"|cff11ff11灵巧头巾|r","").append(13,4,7).append(14,4,7);
                thistype.create(ITID_CLAWS_OF_ATTACK,"|cff11ff11攻击之爪|r","").append(9,5,10);
                thistype.create(ITID_GLOVES_OF_HASTE,"|cff11ff11加速手套|r","").append(12,3,5);
                thistype.create(ITID_SWORD_OF_ASSASSINATION,"|cff11ff11刺杀剑|r","").append(11,0.03,0.05);
                thistype.create(ITID_VITALITY_PERIAPT,"|cff11ff11生命护身符|r","").append(21,75,150);
                thistype.create(ITID_RING_OF_PROTECTION,"|cff11ff11守护指环|r","").append(8,2,3);
                thistype.create(ITID_TALISMAN_OF_EVASION,"|cff11ff11闪避护符|r","").append(27,0.02,0.03);
                thistype.create(ITID_MANA_PERIAPT,"|cff11ff11法力护身符|r","").append(17,75,150);
                thistype.create(ITID_SOBI_MASK,"|cff11ff11艺人面罩|r","").append(72,1,2);
                thistype.create(ITID_MAGIC_BOOK,"|cff11ff11魔法书|r","").append(18,5,10);
                thistype.create(ITID_CRYSTAL_BALL,"|cff11ff11水晶球|r","").append(20,0.03,0.05);
                thistype.create(ITID_LONG_STAFF,"|cff11ff11长杖|r","").append(19,0.03,0.05);
                thistype.create(ITID_HEALTH_STONE,"|cff11ff11生命石|r","").append(73,2,4).append(31,400,800);
                thistype.create(ITID_MANA_STONE,"|cff11ff11法力石|r","").append(72,1,1).append(30,200,400);
                thistype.create(ITID_ROMULOS_EXPIRED_POISON,"|cff11ff11罗密欧的过期毒药|r","|cff999999还能用。|r").append(53,25,100);
                thistype.create(ITID_MOROES_LUCKY_GEAR,"|cff11ff11莫罗斯的幸运齿轮|r","|cff999999从莫罗斯的幸运怀表拆下来的。|r").append(35,8,12);
                thistype.create(ITID_RUNED_BELT,"|cff11ff11符文腰带|r","|cff999999原本是一个食人魔的手镯。|r").append(2,0.03,0.05);
                thistype.create(ITID_UNGLAZED_ICON_OF_THE_CRESCENT,"|cff11ff11无光的新月徽记|r","|cff999999还是可以模糊地看出原本是漂亮的银色。|r").append(33,15,45);
                thistype.create(ITID_MAUL_OF_WARLORD,"|cff8b66ff战争领主大锤|r","").append(4,10,20).append(21,75,150);
                thistype.create(ITID_CLOAK_OF_STEALTH,"|cff8b66ff潜行斗篷|r","").append(13,10,20).append(21,75,150);
                thistype.create(ITID_SCEPTER_OF_ARCHON,"|cff8b66ff执政官权杖|r","").append(14,10,20).append(21,75,150);
                thistype.create(ITID_COLOSSUS_BLADE,"|cff11ff11巨神之刃|r","|cff999999做工粗糙的巨剑，但这是哈洛加斯最受欢迎的量产武器。|r").append(9,8,15).append(12,4,8);
                thistype.create(ITID_THE_X_RING,"|cff8b66ff至尊21戒|r","|cffffdead前面20个都是渣！|r").append(7,12,21);
                thistype.create(ITID_GOBLIN_ROCKET_BOOTS_LIMITED_EDITION,"|cff8b66ff地精火箭靴限量版|r","|cffffdead虽说是限量版，但毕竟是地精产品，所以使用时还是小心。|r").append(21,100,200).append(17,100,200).append(24,13,25).append(36,8,12);
                thistype.create(ITID_WARSONG_BATTLE_DRUMS,"|cff8b66ff战歌战鼓|r","|cffffdead士气高涨|r").append(56,0.01,0.02).append(84,0.01,0.02);
                thistype.create(ITID_TROLL_BANE,"|cff8b66ff托尔贝恩|r","|cffffdead你认得这把斧头...|r").append(4,5,10).append(12,3,5).append(9,5,10);
                thistype.create(ITID_GOREHOWL,"|cff8b66ff血吼|r","|cffffdead这把格罗姆·地狱咆哮的战斧曾在无数的战场上令敌人闻风丧胆。|r").append(4,6,12).append(21,75,150).append(11,0.03,0.05);
                thistype.create(ITID_CORE_HOUND_TOOTH,"|cff8b66ff熔火犬牙|r","").append(21,75,150).append(12,3,5).append(11,0.03,0.05);
                thistype.create(ITID_VISKAG,"|cff8b66ff维斯卡格|r","|cffffdead血书|r").append(13,5,10).append(9,5,10).append(12,3,5);
                thistype.create(ITID_LION_HORN,"|cff8b66ff风暴狮角|r","|cffffdead比龙脊奖章好多了。|r").append(9,5,10).append(3,0.01,0.01).append(48,0.05,0.07);
                thistype.create(ITID_ARMOR_OF_THE_DAMNED,"|cff8b66ff诅咒铠甲|r","|cffffdead迟缓大法、诅咒、虚弱无力、大难临头|r").append(8,2,3).append(21,120,240).append(74,4,8).append(41,50,100);
                thistype.create(ITID_BULWARK_OF_THE_AMANI_EMPIRE,"|cff8b66ff阿曼尼帝国壁垒|r","|cff999999似乎还萦绕着兄弟工会首席战士的怨念。|r").append(8,2,3).append(4,5,10).append(15,14,28).append(98,0,0);
                thistype.create(ITID_SHINING_JEWEL_OF_TANARIS,"|cff8b66ff塔纳利斯明珠|r","").append(14,5,10).append(73,6,12).append(20,0.03,0.05).append(98,0,0);
                thistype.create(ITID_DRAKKARI_DECAPITATOR,"|cff8b66ff达卡莱斩首者|r","").append(21,75,150).append(11,0.03,0.05).append(54,0.35,0.7).append(98,0,0);
                thistype.create(ITID_SIGNET_OF_THE_LAST_DEFENDER,"|cff8b66ff末日防御者徽记|r","|cffffdead被一个兽人盗贼从某个恶魔领主身上偷走的徽记。|r").append(21,100,200).append(27,0.02,0.03).append(6,0.03,0.06);
                thistype.create(ITID_ARANS_SOOTHING_EMERALD,"|cff8b66ff埃兰的镇静玛瑙|r","|cffffdead埃兰制作过很多种镇静宝石，最受冒险者欢迎的应该是一种蓝宝石。|r").append(14,5,10).append(18,5,10).append(72,1,2);
                thistype.create(ITID_PURE_ARCANE,"|cff8b66ff纯净秘法|r","|cffffdead梅卡托克对此不屑一顾，他认为一个简单的电容器就能达到这个效果。|r").append(77,170,340);
                thistype.create(ITID_HEX_SHRUNKEN_HEAD,"|cff8b66ff妖术之颅|r","|cffffdead强大的妖术领主现在已经不需要这些小玩意了。|r").append(14,5,10).append(18,5,10).append(34,40,80);
                thistype.create(ITID_STAFF_OF_THE_SHADOW_FLAME,"|cff8b66ff暗影烈焰法杖|r","|cffffdead法杖尖端的暗影能量如此纯净，蕴藏着巨大的力量。|r").append(14,5,10).append(18,5,10).append(20,0.03,0.05);
                thistype.create(ITID_TIDAL_LOOP,"|cff8b66ff潮汐指环|r","|cffffdead这枚戒指原本是用来对抗炎魔之王的军团的，但现在其抵抗火焰的力量已经消逝。|r").append(4,5,10).append(72,2,4).append(87,60,90);
                thistype.create(ITID_EAGLE_GOD_GAUNTLETS,"|cff8b66ff猎鹰之王护手|r","").append(13,5,10).append(21,75,150).append(11,0.03,0.05);
                thistype.create(ITID_MOONSTONE,"|cff8b66ff月亮石|r","").append(14,5,10).append(72,1,2).append(19,0.03,0.05);
                thistype.create(ITID_SHADOW_ORB,"|cff8b66ff暗影宝珠|r","").append(18,5,10).append(19,0.03,0.05).append(21,75,150);
                thistype.create(ITID_ORB_OF_THE_SINDOREI,"|cff8b66ff辛多雷宝珠|r","|cffffdead杰出血精灵防御者的荣耀标志。|r").append(4,4,7).append(18,8,15).append(16,0.04,0.06).append(86,0.03,0.07);
                thistype.create(ITID_REFORGED_BADGE_OF_TENACITY,"|cff8b66ff重铸的坚韧徽章|r","|cffffdead原本由恶魔领主沙图尔铸造。|r").append(13,4,7).append(21,120,240).append(78,0.08,0.1).append(92,3,7);
                thistype.create(ITID_LIGHTS_JUSTICE,"|cff8b66ff圣光的正义|r","|cffffdead向圣光打开你的心扉。|r").append(14,4,7).append(20,0.03,0.05).append(79,0,0).append(91,0,0);
                thistype.create(ITID_BENEDICTION,"|cff8b66ff祈福|r","|cffffdead在光的背后，是阴影...|r").append(14,4,7).append(72,2,4).append(76,4,6).append(80,0,0);
                thistype.create(ITID_HORN_OF_CENARIUS,"|cff8b66ff塞纳留斯之角|r","|cffffdead这件暗夜精灵的神器据说具有召唤暗夜精灵灵魂的能力。|r").append(7,4,7).append(21,100,200).append(17,100,200).append(69,3,4.7);
                thistype.create(ITID_BANNER_OF_THE_HORDE,"|cff8b66ff部落战旗|r","|cffffdead为了部落的荣耀，敌人将尸横遍野|r").append(4,5,10).append(9,5,10).append(11,0.03,0.05).append(39,0.4,0.6);
                thistype.create(ITID_KELENS_DAGGER_OF_ASSASSINATION,"|cff8b66ff科勒恩的刺杀匕首|r","|cffffdead科勒恩不仅仅是逃脱大师。|r").append(13,5,10).append(12,3,5).append(66,0,0).append(65,0.04,0.06).append(90,0.03,0.06);
                thistype.create(ITID_RHOKDELAR,"|cff8b66ff伦鲁迪洛尔|r","|cffffdead上古守护者的长弓|r").append(13,5,8).append(12,3,5).append(11,0.03,0.05).append(24,10,20).append(94,0.7,1);
                thistype.create(ITID_RAGE_WINTERCHILLS_PHYLACTERY,"|cff8b66ff雷基冬寒的护命匣|r","|cffffdead对于一些人而言，他的护命匣比黑暗秘密编年史更重要。|r").append(14,5,10).append(19,0.03,0.05).append(96,0.02,0.04).append(70,0.01,0.02);
                thistype.create(ITID_ANATHEMA,"|cff8b66ff咒逐|r","|cffffdead在阴影的前面，是光明...|r").append(21,125,250).append(18,5,10).append(20,0.03,0.05).append(81,1.5,2);
                thistype.create(ITID_RARE_SHIMMER_WEED,"|cff8b66ff罕见的雷电花芯|r","|cffffdead从雷霆山脉采摘，蕴藏着真正的雷电力量。|r").append(7,4,7).append(12,3,5).append(19,0.03,0.05).append(93,0.01,0.03);
                thistype.create(ITID_CALL_TO_ARMS,"|cffff8c00战争召唤|r","|cffffdead萨卡兰姆被流放时，他和他的部下被恶魔围攻，正是这把斧头和他的圣盾使他带领大家杀出重围。|r").append(9,5,10).append(18,5,10).append(73,10,17).append(57,10,20).append(29,0.06,0.12);
                thistype.create(ITID_WOESTAVE,"|cffff8c00烦恼诗集|r","|cffffdead大瘟疫的源头。|r").append(9,5,15).append(63,0.01,0.03).append(62,0.02,0.04).append(61,1,2).append(60,0.03,0.04).append(64,0.01,0.01).append(59,0.11,0.17);
                thistype.create(ITID_ENIGMA,"|cffff8c00谜团|r","|cffffdead无记录|r").append(1,0.01,0.02).append(3,0.01,0.02).append(24,12,20).append(4,5,10).append(40,0.01,0.02).append(28,0,0);
                thistype.create(ITID_BREATH_OF_THE_DYING,"|cffff8c00死亡呼吸|r","|cffffdead被复活的格瑞斯华尔德的大师级作品，无光的枪柄上蚀刻着6个符文：伐克斯-海尔-艾尔-艾德-萨德-爱斯|r").append(7,4,7).append(9,5,10).append(12,3,5).append(44,0.02,0.04).append(50,18,23);
                thistype.create(ITID_WINDFORCE,"|cffff8c00风之力|r","|cffffdead顺风者，昌；逆风者，亡！|r").append(13,5,10).append(9,5,10).append(12,3,5).append(11,0.03,0.05).append(47,0.05,0.1);
                thistype.create(ITID_DERANGEMENT_OF_CTHUN,"|cffff8c00克苏恩的疯狂|r","|cffffdead尽管上古之神克苏恩的身体被封印，他的疯狂触须和无面者们依然遍布深渊。|r").append(4,6,12).append(9,6,12).append(11,0.03,0.05).append(74,3,30).append(44,0.03,0.06).append(46,0.04,0.06).append(37,0.05,0.5);
                thistype.create(ITID_MIGHT_OF_THE_ANGEL_OF_JUSTICE,"|cffff8c00正义天使之力|r","|cffffdead智慧大天使泰瑞尔还是正义天使的时候使用的装备。|r").append(8,2,3).append(1,0.01,0.02).append(2,0.02,0.04).append(24,12,24).append(42,2,5).append(38,25,35);
                thistype.create(ITID_INFINITY,"|cffff8c00无限|r","|cffffdead无限是薄暮之魂的精华，里面迸发的闪电能量令先知德雷克萨尔着迷。据说有一种带有绿色光环的苍白薄暮之魂是所有冒险者的噩梦！|r").append(14,5,10).append(21,100,200).append(18,5,10).append(82,0.01,0.02).append(89,60,100);
                thistype.create(ITID_INSIGHT,"|cffff8c00洞察|r","|cffffdead在对抗森林巨魔的战争中，血精灵游侠们靠着这件由肯瑞托打造的神器战无不胜，最终为奎尔萨拉斯的建立打下基础。|r").append(14,5,10).append(18,5,10).append(19,0.03,0.05).append(68,0,0).append(83,2,4);
                thistype.create(ITID_GURUBASHI_VOODOO_VIALS,"|cffff8c00古拉巴什巫毒瓶|r","|cffffdead赞吉尔自己*做*朋友。|r").append(14,5,10).append(19,0.03,0.05).append(88,12,20).append(32,15,30).append(98,0,0);
                thistype.create(ITID_MOONLIGHT_GREATSWORD,"|cffff8c00月光大剑|r","|cffffdead圣剑路德维希|r").append(4,5,10).append(57,10,20).append(43,0.02,0.04).append(75,30,60).append(49,100,250);
                thistype.create(ITID_ZULS_STAFF,"|cffff8c00祖尔的法杖|r","").append(21,100,200).append(14,5,10).append(20,0.03,0.05).append(99,120,270).append(98,0,0);
                thistype.create(ITID_MC_SWORD,"|cffff8c00MC剑|r","").append(24,100,100).append(71,3000,3000);
                thistype.create(ITID_THUNDERFURY_BLESSED_BLADE_OF_THE_WINDSEEKER,"|cffff8c00雷霆之怒，逐风者的祝福之剑|r","|cffffdead唤醒雷霆之怒吧！|r").append(13,5,10).append(21,75,150).append(11,0.03,0.05).append(57,10,30).append(89,50,120).append(62,0.03,0.07);
                thistype.create(ITID_DETERMINATION_OF_VENGEANCE,"|cff8b66ff复仇的决心|r","|cffffdead向梅尔甘尼斯复仇的决心无可动摇！|r").append(17,100,200).append(21,100,200).append(1,0.01,0.02).append(97,0,0);
                thistype.create(ITID_STRATHOLME_TRAGEDY,"|cff8b66ff斯坦索姆悲剧|r","|cffffdead不顾吉安娜的建议，斯坦索姆一夜之间成为人间炼狱。|r").append(9,10,20).append(24,11,17).append(67,0.05,0.09).append(97,0,0);
                thistype.create(ITID_PATRICIDE,"|cffff8c00弑父|r","|cffffdead最后一步。|r").append(9,5,10).append(52,26,48).append(55,0.05,0.1).append(12,3,5).append(97,0,0);
                thistype.create(ITID_FROSTMOURNE,"|cffff8c00霜之哀伤|r","|cffffdead来自巫妖王的礼物。|r").append(4,5,10).append(71,7,12).append(43,0.01,0.025).append(58,24,55).append(97,0,0);
                //:template.end
            });
        }
    }

    struct ItemAffix {
        integer id;
        ListObject entries;

        static integer n = 0;

        method destroy() {
            NodeObject it = this.entries.head;
            while (it != 0) {
                AttributeEntry(it.data).destroy();
                it = it.next;
            }
            this.entries.destroy();
            thistype.n -= 1;
            this.deallocate();
        }

        static method create(integer affixId) -> thistype {
            thistype this;
            AttributeMetaEntry ame;
            NodeObject it;

            this = thistype.allocate();
            this.entries = ListObject.create();
            this.id = affixId;
            it = AffixMeta[affixId].entries.head;
            while (it != 0) {
                ame = AttributeMetaEntry(it.data);
                this.entries.push(AttributeEntry.create(ame.attrId, GetRandomReal(ame.lo, ame.hi)));
                it = it.next;
            }
            thistype.n += 1;
            return this;
        }
    }

    struct AttributeEntry {
        integer attrId;
        real value;

        static integer n = 0;

        method destroy() {
            thistype.n -= 1;
            this.deallocate();
        }

        static method create(integer attrId, real value) -> thistype {
            thistype this = thistype.allocate();
            this.attrId = attrId;
            this.value = value;
            thistype.n += 1;
            return this;
        }
    }

    struct AttributeMetaEntry {
        integer attrId;
        real lo, hi;

        static integer n = 0;

        static method create(integer attrId, real lo, real hi) -> thistype {
            thistype this = thistype.allocate();
            this.attrId = attrId;
            this.lo = lo;
            this.hi = hi;
            thistype.n += 1;
            return this;
        }
    }

    struct AffixMeta[] {
        ListObject entries;
        string text;
        integer qlvl;
        integer slot;

        static integer n = 0;

        static method put(integer id, integer qlvl, integer slot, integer attrType, real lo, real hi, string text) -> thistype {
            thistype[id].qlvl = qlvl;
            thistype[id].slot = slot;
            thistype[id].text = text;
            thistype[id].entries = ListObject.create();
            thistype[id].addAttribute(attrType, lo, hi);
            thistype.n += 1;
            return thistype[id];
        }

        method addAttribute(integer attrId, real lo, real hi) {
            this.entries.push(AttributeMetaEntry.create(attrId, lo, hi));
        }

        static method onInit() {
            thistype.put(SUFIX_LETHALITY, 1, 2, IATTR_CRIT, 0.03, 0.07, "致命的");
            thistype.put(SUFIX_SNAKE, 1, 2, IATTR_SCRIT, 0.03, 0.07, "蛇的");
            thistype.put(SUFIX_QUICKNESS, 1, 2, IATTR_IAS, 3, 7, "快速的");
            thistype.put(SUFIX_WIND_SERPENT, 1, 2, IATTR_SHASTE, 0.03, 0.07, "风蛇的");
            thistype.put(SUFIX_BRUTE, 1, 2, IATTR_STR, 8, 15, "野蛮的");
            thistype.put(SUFIX_DEXTERITY, 1, 2, IATTR_AGI, 8, 15, "灵巧的");
            thistype.put(SUFIX_WISDOM, 1, 2, IATTR_INT, 8, 15, "智慧的");
            thistype.put(SUFIX_VITALITY, 1, 2, IATTR_HP, 113, 225, "耐力的");
            thistype.put(SUFIX_CHAMPION, 1, 2, IATTR_STR, 5, 9, "冠军的").addAttribute(IATTR_AP, 6, 11);
            thistype.put(SUFIX_BUTCHER, 1, 2, IATTR_STR, 5, 9, "屠夫的").addAttribute(IATTR_CRIT, 0.02, 0.05);
            thistype.put(SUFIX_ASSASSIN, 1, 2, IATTR_AGI, 5, 9, "刺客的").addAttribute(IATTR_CRIT, 0.02, 0.05);
            thistype.put(SUFIX_RANGER, 1, 2, IATTR_AGI, 5, 9, "射手的").addAttribute(IATTR_AP, 6, 11);
            thistype.put(SUFIX_WIZARD, 1, 2, IATTR_INT, 5, 9, "巫师的").addAttribute(IATTR_SHASTE, 0.02, 0.05);
            thistype.put(SUFIX_PRIEST, 1, 2, IATTR_INT, 5, 9, "牧师的").addAttribute(IATTR_MREG, 1, 2);
            thistype.put(SUFIX_GUARDIAN, 1, 2, IATTR_HP, 68, 135, "护卫的").addAttribute(IATTR_DODGE, 0.02, 0.03);
            thistype.put(SUFIX_MASTERY, 1, 2, IATTR_LP, 1, 3, "精通的");
            thistype.put(SUFIX_BLUR, 1, 2, IATTR_DODGE, 0.02, 0.05, "模糊的");
            thistype.put(SUFIX_STRONGHOLD, 1, 2, IATTR_DEF, 2, 5, "据点的");
            thistype.put(SUFIX_DEEP_SEA, 1, 2, IATTR_MREG, 2, 3, "深海的");
            thistype.put(SUFIX_VOID, 1, 2, IATTR_SP, 10, 20, "虚空的");
            thistype.put(SUFIX_VAMPIRE, 1, 2, IATTR_ATK_LL, 0.01, 0.02, "吸血鬼的");
            thistype.put(SUFIX_SUCCUBUS, 1, 2, IATTR_ATK_ML, 0.01, 0.02, "魅魔的");
            thistype.put(PREFIX_HEAVY, 1, 1, IATTR_STR, 4, 7, "厚重之");
            thistype.put(PREFIX_STRONG, 2, 1, IATTR_STR, 8, 15, "强壮之");
            thistype.put(PREFIX_SHARP, 1, 1, IATTR_AGI, 4, 7, "锋利之");
            thistype.put(PREFIX_AGILE, 2, 1, IATTR_AGI, 8, 15, "敏捷之");
            thistype.put(PREFIX_SHIMERING, 1, 1, IATTR_INT, 4, 7, "微光之");
            thistype.put(PREFIX_INTELLIGENT, 2, 1, IATTR_INT, 8, 15, "智力之");
            thistype.put(PREFIX_ENDURABLE, 1, 1, IATTR_HP, 57, 112, "耐久之");
            thistype.put(PREFIX_VIBRANT, 2, 1, IATTR_HP, 113, 225, "活力之");
            thistype.put(PREFIX_SKILLED, 1, 1, IATTR_AP, 5, 10, "技巧之");
            thistype.put(PREFIX_CRUEL, 2, 1, IATTR_AP, 10, 20, "残忍之");
            thistype.put(PREFIX_ENCHANTED, 1, 1, IATTR_SP, 8, 12, "附魔之");
            thistype.put(PREFIX_SORCEROUS, 2, 1, IATTR_SP, 13, 20, "巫术之");
            thistype.put(PREFIX_MYSTERIOUS, 1, 1, IATTR_MREG, 1, 1, "神秘之");
            thistype.put(PREFIX_ETERNAL, 2, 1, IATTR_MREG, 2, 3, "永恒之");
            thistype.put(PREFIX_STEADY, 1, 1, IATTR_DEF, 1, 2, "稳固之");
            thistype.put(PREFIX_TOUGH, 2, 1, IATTR_DEF, 3, 5, "坚韧之");
            thistype.put(PREFIX_HEALTHY, 1, 1, IATTR_HREG, 2, 4, "强健之");
            thistype.put(PREFIX_EVERLASTING, 2, 1, IATTR_HREG, 4, 8, "持久之");
        }
    }

    public type AttributeBehaviourMetaCallback extends function(unit, real, integer);
    public struct AttributeBehaviourMeta[] {
        integer sort;
        integer cate;
        string str1, str2;
        real lpAmp;
        AttributeBehaviourMetaCallback callback;

        static integer n = 0;

        static method put(integer id, integer cate, integer sort, real lpAmp, string str1, string str2, AttributeBehaviourMetaCallback callback) {
            thistype[id].cate = cate;
            thistype[id].sort = sort;
            thistype[id].lpAmp = lpAmp;
            thistype[id].str1 = str1;
            thistype[id].str2 = str2;
            thistype[id].callback = callback;
            thistype.n += 1;
        }

        static method callbackSTR(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackSTR").ModStr(Rounding(val) * polar);
        }
        static method callbackSTRPL(unit u, real val, integer polar) {
            print("[Warn] callbackSTRPL not implemented");
        }
        static method callbackAGI(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackAGI").ModAgi(Rounding(val) * polar);
        }
        static method callbackINT(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackINT").ModInt(Rounding(val) * polar);
        }
        static method callbackALLSTAT(unit u, real val, integer polar) {
            UnitProp up = UnitProp.inst(u, "AttributeBehaviourMeta.callback7");
            up.ModStr(Rounding(val) * polar);
            up.ModAgi(Rounding(val) * polar);
            up.ModInt(Rounding(val) * polar);
        }
        static method callbackHP(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackHP").ModLife(Rounding(val) * polar);
        }
        static method callbackHPPCT(unit u, real val, integer polar) {
            print("[Warn] callbackHPPCT not implemented");
        }
        static method callbackHPPL(unit u, real val, integer polar) {
            print("[Warn] callbackHPPL not implemented");
        }
        static method callbackMP(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackMP").ModMana(Rounding(val) * polar);
        }
        static method callbackAP(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackAP").ModAP(Rounding(val) * polar);
        }
        static method callbackAPPL(unit u, real val, integer polar) {
            print("[Warn] callbackAPPL not implemented");
        }
        static method callbackCRIT(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackAP").attackCrit += val * polar;
        }
        static method callbackIAS(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackIAS").ModAttackSpeed(Rounding(val) * polar);
        }
        static method callbackSP(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackAP").spellPower += val * polar;
        }
        static method callbackSCRIT(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackAP").spellCrit += val * polar;
        }
        static method callbackSHASTE(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackAP").spellHaste += val * polar;
        }
        static method callbackDEF(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackIAS").ModArmor(Rounding(val) * polar);
        }
        static method callbackDEFPL(unit u, real val, integer polar) {
            print("[Warn] callbackDEFPL not implemented");
        }
        static method callbackBR(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackAP").blockRate += val * polar;
        }
        static method callbackBP(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackAP").blockPoint += val * polar;
        }
        static method callbackDODGE(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackAP").dodge += val * polar;
        }
        static method callbackDR(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackAP").damageTaken -= val * polar;
        }
        static method callbackMDR(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackAP").spellTaken -= val * polar;
        }
        static method callbackAMP(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackAP").damageDealt += val * polar;
        }
        static method callbackHAMP(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackAP").healTaken += val * polar;
        }
        static method callbackMREG(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackAP").manaRegen += val * polar;
        }
        static method callbackHREG(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackAP").lifeRegen += val * polar;
        }
        static method callbackHLOST(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackAP").lifeRegen -= val * polar;
        }
        static method callbackMS(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackIAS").ModSpeed(Rounding(val) * polar);
        }
        static method callbackMSPL(unit u, real val, integer polar) {
            print("[Warn] callbackMSPL not implemented");
        }
        static method callbackLP(unit u, real val, integer polar) {}
        static method callbackBM_VALOR(unit u, real val, integer polar) {}
        static method callbackRG_ONESHOT(unit u, real val, integer polar) {
            EquipedOneshotLowHealth(u, polar);
        }
        static method callbackRG_RUSH(unit u, real val, integer polar) {}
        static method callbackCRKILLER(unit u, real val, integer polar) {
            EquipedNonHeroExtraDamage(u, polar);
        }
        static method callbackMCVT(unit u, real val, integer polar) {
            EquipedConvertAttackMagic(u, polar);
        }
        static method callbackKG_REGRCD(unit u, real val, integer polar) {}
        static method callbackLEECHAURA(unit u, real val, integer polar) {
            EquipedLeechAura(u, polar);
        }
        static method callbackPR_POHDEF(unit u, real val, integer polar) {}
        static method callbackDR_MAXHP(unit u, real val, integer polar) {}
        static method callbackPL_SHOCK(unit u, real val, integer polar) {}
        static method callbackPR_SHIELD(unit u, real val, integer polar) {}
        static method callbackCT_PAIN(unit u, real val, integer polar) {}
        static method callbackBD_SHIELD(unit u, real val, integer polar) {}
        static method callbackRG_PARALZ(unit u, real val, integer polar) {}
        static method callbackPL_LIGHT(unit u, real val, integer polar) {}
        static method callbackDR_CDR(unit u, real val, integer polar) {
            EquipedReforgedBadgeOfTenacity(u, polar);
        }
        static method callbackSM_LASH(unit u, real val, integer polar) {}
        static method callbackDK_ARROW(unit u, real val, integer polar) {}
        static method callbackMG_FDMG(unit u, real val, integer polar) {}
        static method callbackMG_BLZ(unit u, real val, integer polar) {}
        static method callbackATK_ML(unit u, real val, integer polar) {
            UnitProp.inst(u, "AttributeBehaviourMeta.callback45").ml += val * polar;
        }
        static method callbackATK_LL(unit u, real val, integer polar) {
            UnitProp.inst(u, "AttributeBehaviourMeta.callback45").ll += val * polar;
        }
        static method callbackATK_LLML(unit u, real val, integer polar) {
            UnitProp up = UnitProp.inst(u, "AttributeBehaviourMeta.callback45");
            up.ll += val * polar;
            up.ml += val * polar;
        }
        static method callbackATK_CTHUN(unit u, real val, integer polar) {
            EquipedAttackStackableIAS(u, polar);
        }
        static method callbackATK_WF(unit u, real val, integer polar) {
            EquipedWindforce(u, polar);
        }
        static method callbackATK_LION(unit u, real val, integer polar) {
            EquipedLionHorn(u, polar);
        }
        static method callbackATK_MOONWAVE(unit u, real val, integer polar) {
            EquipedMoonlightBurst(u, polar);
        }
        static method callbackATK_POISNOVA(unit u, real val, integer polar) {
            EquipedBOTD(u, polar);
        }
        static method callbackATK_COIL(unit u, real val, integer polar) {}
        static method callbackATK_BLEED(unit u, real val, integer polar) {
            EquipedAttackBleed(u, polar);
        }
        static method callbackATK_MDC(unit u, real val, integer polar) {
            EquipedChanceMagicDamage(u, polar);
        }
        static method callbackATK_STUN(unit u, real val, integer polar) {
            EquipedAttackStun(u, polar);
        }
        static method callbackATK_CRIT(unit u, real val, integer polar) {
            EquipedAttackChanceICC(u, polar);
        }
        static method callbackATK_AMP(unit u, real val, integer polar) {
            EquipedAttackAmplifiedDamage(u, polar);
        }
        static method callbackATK_MD(unit u, real val, integer polar) {
            EquipedExtraMagicDamage(u, polar);
        }
        static method callbackATK_MDK(unit u, real val, integer polar) {
            EquipedLethalMagicalDamage(u, polar);
        }
        static method callbackATK_MORTAL(unit u, real val, integer polar) {
            EquipedAttackDecreaseHealed(u, polar);
        }
        static method callbackATK_MISS(unit u, real val, integer polar) {
            EquipedAttackDecreaseAttackRate(u, polar);
        }
        static method callbackATK_DDEF(unit u, real val, integer polar) {
            EquipedAttackDecreaseArmor(u, polar);
        }
        static method callbackATK_DAS(unit u, real val, integer polar) {
            EquipedAttackDecreaseAttackSpeed(u, polar);
        }
        static method callbackATK_DMS(unit u, real val, integer polar) {
            EquipedAttackDecreaseMoveSpeed(u, polar);
        }
        static method callbackATK_WEAK(unit u, real val, integer polar) {
            EquipedAttackDecreaseDamage(u, polar);
        }
        static method callback3ATK_MOONEXP(unit u, real val, integer polar) {
            EquipedMoonlightExplosion(u, polar);
        }
        static method callbackMD_MREGEN(unit u, real val, integer polar) {
            EquipedTidalLoop(u, polar);
        }
        static method callbackMD_POISON(unit u, real val, integer polar) {
            EquipedMagicPoison(u, polar);
        }
        static method callbackMD_CHAIN(unit u, real val, integer polar) {
            EquipedMagicChainLightning(u, polar);
        }
        static method callbackMDC_ARCANE(unit u, real val, integer polar) {
            EquipedPureArcane(u, polar);
        }
        static method callbackDT_MREGEN(unit u, real val, integer polar) {
            UnitProp.inst(u, "AttributeBehaviourMeta.callback45").damageGoesMana += val * polar;
        }
        static method callbackATKED_WEAK(unit u, real val, integer polar) {
            EquipedCursedCuirass(u, polar);
        }
        static method callbackHEAL_HOLY(unit u, real val, integer polar) {
            EquipedHealedStackHoly(u, polar);
        }
        static method callbackAURA_CONVIC(unit u, real val, integer polar) {
            EquipedConvictionAura(u, polar);
        }
        static method callbackAURA_MEDITA(unit u, real val, integer polar) {
            EquipedInsightAura(u, polar);
        }
        static method callbackAURA_WARSONG(unit u, real val, integer polar) {
            EquipedWarsongAura(u, polar);
        }
        static method callbackAURA_UNHOLY(unit u, real val, integer polar) {}
        static method callbackUSE_TP(unit u, real val, integer polar) {}
        static method callbackUSE_BATTLE(unit u, real val, integer polar) {}
        static method callbackUSE_MREGEN(unit u, real val, integer polar) {}
        static method callbackUSE_HREGEN(unit u, real val, integer polar) {}
        static method callbackUSE_VOODOO(unit u, real val, integer polar) {
            EquipedVoodooVials(u, polar);
        }
        static method callbackUSE_INT(unit u, real val, integer polar) {
            EquipedUnglazedCrescent(u, polar);
        }
        static method callbackMD_ARCANE(unit u, real val, integer polar) {
            EquipedArcanePotion(u, polar);
        }
        static method callbackUSE_SP(unit u, real val, integer polar) {}
        static method callbackUSE_DODGE(unit u, real val, integer polar) {}
        static method callbackUSE_MS(unit u, real val, integer polar) {}
        static method callbackUSE_CTHUN(unit u, real val, integer polar) {}
        static method callbackUSE_HOLYHEAL(unit u, real val, integer polar) {}
        static method callbackSET_ARTHAS(unit u, real val, integer polar) {
            EquipedArthassCorruption(u, polar);
        }
        static method callbackSET_ZANDALARI(unit u, real val, integer polar) {
            EquipedRiseOfZandalari(u, polar);
        }

        static method onInit() {
            //:template.id = attributeMeta
            //:template.indentation = 3
            thistype.put(IATTR_STR,1,100,0,"+","力量",thistype.callbackSTR);
            thistype.put(IATTR_STRPL,1,101,0,"+","力量/级",thistype.callbackSTRPL);
            thistype.put(IATTR_AGI,1,102,0,"+","敏捷",thistype.callbackAGI);
            thistype.put(IATTR_INT,1,104,0,"+","智力",thistype.callbackINT);
            thistype.put(IATTR_ALLSTAT,1,106,0,"+","全属性",thistype.callbackALLSTAT);
            thistype.put(IATTR_HP,1,110,0,"+","生命",thistype.callbackHP);
            thistype.put(IATTR_HPPCT,1,111,0,"+","生命",thistype.callbackHPPCT);
            thistype.put(IATTR_HPPL,1,112,0,"+","生命/级",thistype.callbackHPPL);
            thistype.put(IATTR_MP,1,114,0,"+","法力",thistype.callbackMP);
            thistype.put(IATTR_AP,1,120,0,"+","攻击",thistype.callbackAP);
            thistype.put(IATTR_APPL,1,121,0,"+","攻击/级",thistype.callbackAPPL);
            thistype.put(IATTR_CRIT,1,122,0,"+","暴击",thistype.callbackCRIT);
            thistype.put(IATTR_IAS,1,124,0,"+","攻速",thistype.callbackIAS);
            thistype.put(IATTR_SP,1,130,0,"+","法术强度",thistype.callbackSP);
            thistype.put(IATTR_SCRIT,1,132,0,"+","法术暴击",thistype.callbackSCRIT);
            thistype.put(IATTR_SHASTE,1,134,0,"+","法术急速",thistype.callbackSHASTE);
            thistype.put(IATTR_DEF,1,140,0,"+","护甲",thistype.callbackDEF);
            thistype.put(IATTR_DEFPL,1,141,0,"+","护甲/级",thistype.callbackDEFPL);
            thistype.put(IATTR_BR,1,142,0,"+","格挡率",thistype.callbackBR);
            thistype.put(IATTR_BP,1,144,0,"+","格挡值",thistype.callbackBP);
            thistype.put(IATTR_DODGE,1,146,0,"+","闪避",thistype.callbackDODGE);
            thistype.put(IATTR_DR,1,150,0,"-","受到的所有伤害",thistype.callbackDR);
            thistype.put(IATTR_MDR,1,152,0,"-","受到的法术伤害",thistype.callbackMDR);
            thistype.put(IATTR_AMP,1,154,0,"+","伤害和治疗",thistype.callbackAMP);
            thistype.put(IATTR_HAMP,1,156,0,"+","受到的治疗",thistype.callbackHAMP);
            thistype.put(IATTR_MREG,1,160,0,"恢复","法力/秒",thistype.callbackMREG);
            thistype.put(IATTR_HREG,1,162,0,"恢复","生命/秒",thistype.callbackHREG);
            thistype.put(IATTR_HLOST,1,164,0,"流失","生命/秒",thistype.callbackHLOST);
            thistype.put(IATTR_MS,1,170,0,"+","移动速度",thistype.callbackMS);
            thistype.put(IATTR_MSPL,1,171,0,"+","移动速度/级",thistype.callbackMSPL);
            thistype.put(IATTR_LP,1,195,0,"增强物品|cff33ff33特效|r + ","",thistype.callbackLP);
            thistype.put(IATTR_ATK_ML,3,200,0,"|cff87ceeb+","法力吸取|r",thistype.callbackATK_ML);
            thistype.put(IATTR_ATK_LL,3,202,0,"|cff87ceeb+","生命吸取|r",thistype.callbackATK_LL);
            thistype.put(IATTR_ATK_LLML,3,204,0,"|cff87ceeb+","生命和法力吸取|r",thistype.callbackATK_LLML);
            thistype.put(IATTR_ATK_MD,3,210,0,"|cff87ceeb造成 ","额外法术伤害/击|r",thistype.callbackATK_MD);
            thistype.put(IATTR_ATK_MDK,3,211,0,"|cff87ceeb造成 ","额外法术伤害/击，目标生命越少伤害越高|r",thistype.callbackATK_MDK);
            thistype.put(IATTR_RG_ONESHOT,3,250,0,"|cff87ceeb秒杀生命值少于你的目标","|r",thistype.callbackRG_ONESHOT);
            thistype.put(IATTR_MCVT,3,253,0,"|cff87ceeb普通攻击转化为法术攻击","|r",thistype.callbackMCVT);
            thistype.put(IATTR_PL_SHOCK,3,256,0,"|cff87ceeb神圣冲击必定造成极效治疗","|r",thistype.callbackPL_SHOCK);
            thistype.put(IATTR_PR_SHIELD,3,259,0,"|cff87ceeb移除护盾的灵魂虚弱效果","|r",thistype.callbackPR_SHIELD);
            thistype.put(IATTR_PL_LIGHT,3,262,0,"|cff87ceeb圣光闪现可以驱散一个有害法术效果","|r",thistype.callbackPL_LIGHT);
            thistype.put(IATTR_DT_MREGEN,3,266,0,"|cff87ceeb受伤的","转化为法力|r",thistype.callbackDT_MREGEN);
            thistype.put(IATTR_USE_TP,3,268,0,"|cff87ceeb使用：传送到一个友军位置","|r",thistype.callbackUSE_TP);
            thistype.put(IATTR_BM_VALOR,2,300,0.33,"|cff33ff33产生","更多的勇气点数|r",thistype.callbackBM_VALOR);
            thistype.put(IATTR_RG_RUSH,2,302,0.16,"|cff33ff33邪恶攻击和剔骨对低于30%生命的目标造成","额外伤害|r",thistype.callbackRG_RUSH);
            thistype.put(IATTR_CRKILLER,2,303,0.5,"|cff33ff33对非英雄目标造成","额外伤害|r",thistype.callbackCRKILLER);
            thistype.put(IATTR_KG_REGRCD,2,305,0.33,"|cff33ff33减少瞬发愈合的冷却时间","秒(唯一)|r",thistype.callbackKG_REGRCD);
            thistype.put(IATTR_LEECHAURA,2,307,0.33,"|cff33ff33每秒从附近敌人吸收","点生命|r",thistype.callbackLEECHAURA);
            thistype.put(IATTR_PR_POHDEF,2,308,0.2,"|cff33ff33治疗祷言提高","点护甲|r",thistype.callbackPR_POHDEF);
            thistype.put(IATTR_DR_MAXHP,2,310,0.16,"|cff33ff33求生本能可以提供","额外的生命和生命上限|r",thistype.callbackDR_MAXHP);
            thistype.put(IATTR_CT_PAIN,2,313,0.4,"|cff33ff33骨髓榨取可以延长痛的持续时间","秒|r",thistype.callbackCT_PAIN);
            thistype.put(IATTR_BD_SHIELD,2,314,0.33,"|cff33ff33辛多雷之盾提供","额外免伤，并嘲讽附近所有目标|r",thistype.callbackBD_SHIELD);
            thistype.put(IATTR_RG_PARALZ,2,315,0.33,"|cff33ff33邪恶攻击有","概率麻痹敌人，降低20%法术急速并获得一个额外连击点|r",thistype.callbackRG_PARALZ);
            thistype.put(IATTR_DR_CDR,2,317,0.16,"|cff33ff33降低生存本能冷却时间","秒(唯一)|r",thistype.callbackDR_CDR);
            thistype.put(IATTR_SM_LASH,2,318,0.1,"|cff33ff33风暴鞭笞有","额外概率冷却地震术(唯一)|r",thistype.callbackSM_LASH);
            thistype.put(IATTR_DK_ARROW,2,319,0.12,"|cff33ff33黑箭数量增加","(唯一)|r",thistype.callbackDK_ARROW);
            thistype.put(IATTR_MG_FDMG,2,320,0.2,"|cff33ff33冰系法术伤害增加","|r",thistype.callbackMG_FDMG);
            thistype.put(IATTR_MG_BLZ,2,322,0.16,"|cff33ff33","概率对暴风雪击中的目标立即施放寒冰箭|r",thistype.callbackMG_BLZ);
            thistype.put(IATTR_ATK_CTHUN,2,403,0.15,"|cff33ff33攻击时：每击增加1%攻速，最多叠加","，层，持续3秒|r",thistype.callbackATK_CTHUN);
            thistype.put(IATTR_ATK_WF,2,404,0.2,"|cff33ff33攻击时：","概率击退目标|r",thistype.callbackATK_WF);
            thistype.put(IATTR_ATK_LION,2,405,0.16,"|cff33ff33攻击时：","概率增加30%攻速，持续5秒|r",thistype.callbackATK_LION);
            thistype.put(IATTR_ATK_MOONWAVE,2,406,0.7,"|cff33ff33攻击时：10%概率消耗5%法力，对直线目标造成","魔法伤害|r",thistype.callbackATK_MOONWAVE);
            thistype.put(IATTR_ATK_POISNOVA,2,407,0.7,"|cff33ff33攻击时：15%概率施展剧毒新星，对600范围内敌人造成","持续魔法伤害|r",thistype.callbackATK_POISNOVA);
            thistype.put(IATTR_ATK_COIL,2,408,0.7,"|cff33ff33攻击时：15%概率施展死亡缠绕","|r",thistype.callbackATK_COIL);
            thistype.put(IATTR_ATK_BLEED,2,409,0.7,"|cff33ff33攻击时：20%概率在成","流血伤害|r",thistype.callbackATK_BLEED);
            thistype.put(IATTR_ATK_MDC,2,410,0.7,"|cff33ff33攻击时：25%概率在成","物理伤害|r",thistype.callbackATK_MDC);
            thistype.put(IATTR_ATK_STUN,2,411,0.2,"|cff33ff33攻击时：10%概率昏迷目标","秒|r",thistype.callbackATK_STUN);
            thistype.put(IATTR_ATK_CRIT,2,412,0.16,"|cff33ff33攻击时：","概率提升100%暴击|r",thistype.callbackATK_CRIT);
            thistype.put(IATTR_ATK_AMP,2,413,0.1,"|cff33ff33攻击时：目标受到","额外伤害|r",thistype.callbackATK_AMP);
            thistype.put(IATTR_ATK_MORTAL,2,416,0.1,"|cff33ff33攻击时：目标受到的治疗降低","|r",thistype.callbackATK_MORTAL);
            thistype.put(IATTR_ATK_MISS,2,417,0.1,"|cff33ff33攻击时：目标命中率降低","|r",thistype.callbackATK_MISS);
            thistype.put(IATTR_ATK_DDEF,2,418,0.1,"|cff33ff33攻击时：目标护甲降低","|r",thistype.callbackATK_DDEF);
            thistype.put(IATTR_ATK_DAS,2,419,0.1,"|cff33ff33攻击时：目标攻速降低","|r",thistype.callbackATK_DAS);
            thistype.put(IATTR_ATK_DMS,2,420,0.1,"|cff33ff33攻击时：目标移动速度降低","|r",thistype.callbackATK_DMS);
            thistype.put(IATTR_ATK_WEAK,2,421,0.1,"|cff33ff33攻击时：目标造成的伤害和治疗效果降低","|r",thistype.callbackATK_WEAK);
            thistype.put(IATTR_3ATK_MOONEXP,2,430,0.7,"|cff33ff33每第三次攻击：消耗5%法力，对附近所有目标造成","魔法伤害|r",thistype.callback3ATK_MOONEXP);
            thistype.put(IATTR_MD_MREGEN,2,450,0.5,"|cff33ff33造成魔法伤害或治疗效果：1%概率恢复","法力|r",thistype.callbackMD_MREGEN);
            thistype.put(IATTR_MD_POISON,2,451,0.7,"|cff33ff33造成魔法伤害：10%概率令目标中毒，造成","持续魔法伤害|r",thistype.callbackMD_POISON);
            thistype.put(IATTR_MD_CHAIN,2,452,0.7,"|cff33ff33造成伤害：10%概率对目标施展闪电链，造成","魔法伤害|r",thistype.callbackMD_CHAIN);
            thistype.put(IATTR_USE_INT,2,453,0.3,"|cff33ff33造成魔法伤害：15%概率提高","智力，持续15秒|r",thistype.callbackUSE_INT);
            thistype.put(IATTR_MD_ARCANE,2,454,0.7,"|cff33ff33造成魔法伤害：10%概率施展秘法飞弹，造成","魔法伤害|r",thistype.callbackMD_ARCANE);
            thistype.put(IATTR_MDC_ARCANE,2,460,0.5,"|cff33ff33魔法暴击：充能1层秘法，3次充能之后会朝目标释放，造成","魔法伤害|r",thistype.callbackMDC_ARCANE);
            thistype.put(IATTR_HEAL_HOLY,2,501,0.33,"|cff33ff33受到治疗：充能1层神圣能量，最多叠加","层|r",thistype.callbackHEAL_HOLY);
            thistype.put(IATTR_ATKED_WEAK,2,600,0.33,"|cff33ff33受到攻击：降低目标的攻击","|r",thistype.callbackATKED_WEAK);
            thistype.put(IATTR_AURA_CONVIC,2,800,0.1,"|cff33ff33赋予信念光环：600范围内的敌人受到","额外魔法伤害|r",thistype.callbackAURA_CONVIC);
            thistype.put(IATTR_AURA_MEDITA,2,801,0.2,"|cff33ff33赋予冥想光环：600范围内的友军每秒恢复","点法力|r",thistype.callbackAURA_MEDITA);
            thistype.put(IATTR_AURA_WARSONG,2,802,0.1,"|cff33ff33赋予战歌光环：600范围内的友军造成","更多的伤害和治疗，受到的治疗效果提升10%|r",thistype.callbackAURA_WARSONG);
            thistype.put(IATTR_AURA_UNHOLY,2,803,0.7,"|cff33ff33赋予邪恶光环：600范围内的友军每秒恢复","点生命|r",thistype.callbackAURA_UNHOLY);
            thistype.put(IATTR_USE_BATTLE,2,901,0.16,"|cff33ff33使用：战斗命令，提高900范围内友军","点最大生命，持续75秒|r",thistype.callbackUSE_BATTLE);
            thistype.put(IATTR_USE_MREGEN,2,902,0.4,"|cff33ff33使用：恢复","法力|r",thistype.callbackUSE_MREGEN);
            thistype.put(IATTR_USE_HREGEN,2,903,0.4,"|cff33ff33使用：恢复","点生命|r",thistype.callbackUSE_HREGEN);
            thistype.put(IATTR_USE_VOODOO,2,904,0.2,"|cff33ff33使用：对范围内的敌人造成","持续的魔法伤害|r",thistype.callbackUSE_VOODOO);
            thistype.put(IATTR_USE_SP,2,906,0.3,"|cff33ff33使用：提升法术强度","点，持续15秒|r",thistype.callbackUSE_SP);
            thistype.put(IATTR_USE_DODGE,2,907,0.1,"|cff33ff33使用：提升30%躲闪，持续","秒|r",thistype.callbackUSE_DODGE);
            thistype.put(IATTR_USE_MS,2,908,0.1,"|cff33ff33使用：提升300移动速度，持续","秒。有可能失败。|r",thistype.callbackUSE_MS);
            thistype.put(IATTR_USE_CTHUN,2,909,-0.33,"|cff33ff33使用：增加100%攻速，受到","额外伤害(唯一)|r",thistype.callbackUSE_CTHUN);
            thistype.put(IATTR_USE_HOLYHEAL,2,910,0.33,"|cff33ff33使用：释放所有神圣能量来治疗自己，每点能量治疗","点生命|r",thistype.callbackUSE_HOLYHEAL);
            thistype.put(IATTR_SET_ARTHAS,4,2000,0,"阿尔萨斯的堕落","|r",thistype.callbackSET_ARTHAS);
            thistype.put(IATTR_SET_ZANDALARI,4,2001,0,"赞达拉的崛起","|r",thistype.callbackSET_ZANDALARI);
            //:template.end
        }
    }

    function reforgeItem(rect whichAnvil, integer qlvl, integer forgeLevel, integer returnGold, integer returnLumber, string typeMismatch, player whichPlayer) {
        ItemExAttributes iea;
        countReforge = 0;
        reforgeTypeCheck = true;
        reforgingItem = null;
        reforgeClosureQlvl = qlvl;
        EnumItemsInRect(whichAnvil, null, function() {
            reforgingItem = GetEnumItem();
            countReforge += 1;
            if (GetItemLevel(reforgingItem) != reforgeClosureQlvl) {
                reforgeTypeCheck = false;
            }
        });
        if (countReforge != 1 || reforgeTypeCheck == false) {
            SimError(whichPlayer, "Place exact one " + typeMismatch + " item in circle please.");
            AdjustPlayerStateSimpleBJ(whichPlayer, PLAYER_STATE_RESOURCE_GOLD, returnGold);
            AdjustPlayerStateSimpleBJ(whichPlayer, PLAYER_STATE_RESOURCE_LUMBER, returnLumber);
        } else {
            iea = ItemExAttributes.inst(reforgingItem, "reforge");
            iea.reforge(forgeLevel);
            iea.updateUbertip();
            iea.updateName();
            AddTimedEffect.atCoord(ART_TOME_OF_STRENGTH, GetItemX(reforgingItem), GetItemY(reforgingItem), 0.5);
        }
    }

    function itemon() -> boolean {
        item it = GetManipulatedItem();
        integer itid = GetItemTypeId(it);
        integer i;
        item tmpi;
        unit u = GetTriggerUnit();
        NodeObject attrIt;
        AttributeEntry ae;
        if (GetItemLevel(it) < 2) {
            // reforge
            if (itid == ITID_REFORGE_UNCOMMON_L1) {
                RemoveItem(it);
                reforgeItem(ApprenticeAnvil, 2, 1, 0, 5, "uncommon (green)", GetOwningPlayer(u));
            } else if (itid == ITID_REFORGE_UNCOMMON_L2) {
                RemoveItem(it);
                reforgeItem(ExpertAnvil, 2, 2, 0, 10, "uncommon (green)", GetOwningPlayer(u));
            } else if (itid == ITID_REFORGE_UNCOMMON_L3) {
                RemoveItem(it);
                reforgeItem(MasterAnvil, 2, 3, 0, 15, "uncommon (green)", GetOwningPlayer(u));
            } else if (itid == ITID_REFORGE_RARE_L2) {
                RemoveItem(it);
                reforgeItem(ExpertAnvil, 3, 2, 0, 50, "rare (purple)", GetOwningPlayer(u));
            } else if (itid == ITID_REFORGE_RARE_L3) {
                RemoveItem(it);
                reforgeItem(MasterAnvil, 3, 3, 0, 75, "rare (purple)", GetOwningPlayer(u));
            } else if (itid == ITID_REFORGE_LEGENDARY_L3) {
                RemoveItem(it);
                reforgeItem(MasterAnvil, 4, 3, 1, 300, "legendary (orange)", GetOwningPlayer(u));
            } else {
                // stack charges
                i = 0;
                while (i < 6) {
                    tmpi = UnitItemInSlot(u, i);
                    if (GetItemTypeId(tmpi) == itid && GetHandleId(tmpi) != GetHandleId(it)) {
                        SetItemCharges(tmpi, GetItemCharges(tmpi) + GetItemCharges(it));
                        RemoveItem(it);
                        i += 6;
                    }
                    i += 1;
                    tmpi = null;
                }
            }
        } else {
            attrIt = ItemExAttributes.inst(it, "item on").attributes.head;
            while (attrIt != 0) {
                ae = AttributeEntry(attrIt.data);
                AttributeBehaviourMeta[ae.attrId].callback.evaluate(u, ae.value, 1);
                attrIt = attrIt.next;
            }
        }
        u = null;
        it = null;
        return false;
    }
    
    function itemoff() -> boolean {
        // integer itid = GetItemTypeId(GetManipulatedItem());
        NodeObject attrIt;
        AttributeEntry ae;
        integer tddata;
        if (GetItemLevel(GetManipulatedItem()) > 1) {
            attrIt = ItemExAttributes.inst(GetManipulatedItem(), "itemoff").attributes.head;
            ItemExAttributes.droppingItem = GetManipulatedItem();
            while (attrIt != 0) {
                ae = AttributeEntry(attrIt.data);
                AttributeBehaviourMeta[ae.attrId].callback.evaluate(GetTriggerUnit(), ae.value, -1);
                attrIt = attrIt.next;
            }
            ItemExAttributes.droppingItem = null;
            tddata = shouldDestroy.pop();
            while (tddata != 0) {
                ItemExAttributes(tddata).destroy();
                tddata = shouldDestroy.pop();
            }
        }
        return false;
    }

    function itemSold() -> boolean {
        ItemExAttributes iea;
        real exp, rp;
        integer ilvl = GetItemLevel(GetSoldItem());
        integer lumber, gold;
        if (ilvl > 1) {
            iea = ItemExAttributes.inst(GetSoldItem(), "item sold");
            exp = iea.exp - 1;
            rp = 1;
            if (GetRandomReal(0, 0.999) < 0.15) {rp = GetRandomReal(1.6, 2.2);}
            gold = 0;
            if (ilvl == 2) {lumber = 5;}
            else if (ilvl == 3) {lumber = 25;}
            else {lumber = 100; gold = 1;}
            shouldDestroy.push(iea);

            AdjustPlayerStateSimpleBJ(GetOwningPlayer(GetTriggerUnit()), PLAYER_STATE_RESOURCE_LUMBER, Rounding(lumber * exp * rp));
            AdjustPlayerStateSimpleBJ(GetOwningPlayer(GetTriggerUnit()), PLAYER_STATE_RESOURCE_GOLD, Rounding(gold * rp));
        }
        return false;
    }
    
    public function CreateItemEx(integer itid, real x, real y, real lootValue) -> item {
        item it = CreateItem(itid, x + GetRandomReal(-50, 50), y + GetRandomReal(-50, 50));
        real prefixFactor;
        real sufixFactor;
        real prob, prob1;
        boolean prefixDone;
        string itemName;
        real exp;
        ItemExAttributes iea;
        if (lootValue < ILVL_THRESHOLD[0]) {
            exp = 1.0;
        } else if (lootValue < ILVL_THRESHOLD[1]) {
            exp = 1.0 + lootValue / (ILVL_THRESHOLD[1] - ILVL_THRESHOLD[0]);
        } else {
            exp = 2.0 + lootValue / (ILVL_THRESHOLD[2] - ILVL_THRESHOLD[1]);
        }
        iea = ItemExAttributes.create(it, exp);
        prefixFactor = AFFIX_FACTOR_BASE + (GetItemLevel(it) - 1) * AFFIX_FACTOR_DELTA;
        sufixFactor = prefixFactor * SUFIX_MULTIPLIER;
        prob = lootValue / prefixFactor + PREFIX_STATIC_MOD;
        prefixDone = false;
        if (prob > 1.0) {
            prob1 = prob - 1.0;
            if (prob1 > PREFIX_MAX_PROB) {
                prob1 = PREFIX_MAX_PROB;
            }
            if (GetRandomReal(0, 1) < prob1) {
                prefixDone = true;
                iea.appendAffix(ItemAffix.create(ipPrefix2.get()));
            }
        }
        if (prefixDone == false) {
            if (GetRandomReal(0, 1) < prob) {
                prefixDone = true;
                iea.appendAffix(ItemAffix.create(ipPrefix1.get()));
            }
        }
        prob = (lootValue - prefixFactor) / sufixFactor + SUFIX_STATIC_MOD;
        if (prob > SUFIX_MAX_PROB) {
            prob = SUFIX_MAX_PROB;
        }
        if (GetRandomReal(0, 1) < prob) {
            iea.appendAffix(ItemAffix.create(ipSufix.get()));
        }
        iea.updateUbertip();
        iea.updateName();
        return it;
    }

    function onInit() {
        ApprenticeAnvil = Rect(6206, -11838, 6434, -11596);
        ExpertAnvil = Rect(6239, 8227, 6466, 8450);
        MasterAnvil = Rect(-2718, 3811, -2436, 4089);
        shouldDestroy = ListObject.create();
        
        TriggerAnyUnit(EVENT_PLAYER_UNIT_PICKUP_ITEM, function itemon);
        TriggerAnyUnit(EVENT_PLAYER_UNIT_DROP_ITEM, function itemoff);
        TriggerAnyUnit(EVENT_PLAYER_UNIT_PAWN_ITEM, function itemSold);

        ipPrefix1 = IntegerPool.create();
        ipPrefix2 = IntegerPool.create();
        ipSufix = IntegerPool.create();

        ipPrefix1.add(PREFIX_HEAVY, 10);
        ipPrefix1.add(PREFIX_SHARP, 10);
        ipPrefix1.add(PREFIX_SHIMERING, 10);
        ipPrefix1.add(PREFIX_ENDURABLE, 10);
        ipPrefix1.add(PREFIX_SKILLED, 10);
        ipPrefix1.add(PREFIX_ENCHANTED, 10);
        ipPrefix1.add(PREFIX_MYSTERIOUS, 10);
        ipPrefix1.add(PREFIX_STEADY, 10);
        ipPrefix1.add(PREFIX_HEALTHY, 10);

        ipPrefix2.add(PREFIX_STRONG, 10);
        ipPrefix2.add(PREFIX_AGILE, 10);
        ipPrefix2.add(PREFIX_INTELLIGENT, 10);
        ipPrefix2.add(PREFIX_VIBRANT, 10);
        ipPrefix2.add(PREFIX_CRUEL, 10);
        ipPrefix2.add(PREFIX_SORCEROUS, 10);
        ipPrefix2.add(PREFIX_ETERNAL, 10);
        ipPrefix2.add(PREFIX_TOUGH, 10);
        ipPrefix2.add(PREFIX_EVERLASTING, 10);

        ipSufix.add(SUFIX_LETHALITY, 10);
        ipSufix.add(SUFIX_SNAKE, 10);
        ipSufix.add(SUFIX_QUICKNESS, 10);
        ipSufix.add(SUFIX_WIND_SERPENT, 10);
        ipSufix.add(SUFIX_BRUTE, 10);
        ipSufix.add(SUFIX_DEXTERITY, 10);
        ipSufix.add(SUFIX_WISDOM, 10);
        ipSufix.add(SUFIX_VITALITY, 10);
        ipSufix.add(SUFIX_CHAMPION, 10);
        ipSufix.add(SUFIX_BUTCHER, 10);
        ipSufix.add(SUFIX_ASSASSIN, 10);
        ipSufix.add(SUFIX_RANGER, 10);
        ipSufix.add(SUFIX_WIZARD, 10);
        ipSufix.add(SUFIX_PRIEST, 10);
        ipSufix.add(SUFIX_GUARDIAN, 10);
        ipSufix.add(SUFIX_MASTERY, 10);
        ipSufix.add(SUFIX_BLUR, 10);
        ipSufix.add(SUFIX_STRONGHOLD, 10);
        ipSufix.add(SUFIX_DEEP_SEA, 10);
        ipSufix.add(SUFIX_VOID, 10);
        ipSufix.add(SUFIX_VAMPIRE, 10);
        ipSufix.add(SUFIX_SUCCUBUS, 10);
    }

}
//! endzinc
