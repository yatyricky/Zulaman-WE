//! zinc
library ItemAttributes requires UnitProperty, List, BreathOfTheDying, WindForce, Infinity, ConvertAttackMagic, MagicPoison, VoodooVial, RomulosExpiredPoison, Drum, MoonlightExplosion, NonHeroExtraDamage, AttackChanceICC {
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
                if (ti != null && ti != thistype.droppingItem) {
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

        method updateUbertip() {
            NodeObject it;
            string str;
            string valstr;
            real finalValue;
            real lp;
            boolean hasLP;
            AttributeBehaviourMeta abm;
            AttributeEntry ae;
            this.attributes.sort(thistype.sortAttributes);
            it = this.attributes.head;
            str = "";
            lp = 0.0;
            hasLP = false;
            while (it != 0) {
                ae = AttributeEntry(it.data);
                abm = AttributeBehaviourMeta[ae.attrId];
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
                if (it.next != 0) {
                    str = str + "|N";
                }
                it = it.next;
            }
            print(str);
            // BlzSetItemExtendedTooltip(it, str);
        }

        method updateName() {
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
            BlzSetItemName(this.theItem, prefix + rawName + sufix);
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
                thistype.create(ITID_BELT_OF_GIANT,"|cff11ff11Belt of Giant|r","").append(4,5,10);
                thistype.create(ITID_BOOTS_OF_QUELTHALAS,"|cff11ff11Boots of Quel'Thalas|r","").append(13,5,10);
                thistype.create(ITID_ROBE_OF_MAGI,"|cff11ff11Robe of Magi|r","").append(14,5,10);
                thistype.create(ITID_CIRCLET_OF_NOBILITY,"|cff11ff11Circlet of Nobility|r","").append(7,4,7);
                thistype.create(ITID_BOOTS_OF_SPEED,"|cff11ff11Boots of Speed|r","").append(24,11,17);
                thistype.create(ITID_HELM_OF_VALOR,"|cff11ff11Helm of Valor|r","").append(4,4,7).append(13,4,7);
                thistype.create(ITID_MEDALION_OF_COURAGE,"|cff11ff11Medalion of Courage|r","").append(4,4,7).append(14,4,7);
                thistype.create(ITID_HOOD_OF_CUNNING,"|cff11ff11Hood of Cunning|r","").append(13,4,7).append(14,4,7);
                thistype.create(ITID_CLAWS_OF_ATTACK,"|cff11ff11Claws of Attack|r","").append(9,5,10);
                thistype.create(ITID_GLOVES_OF_HASTE,"|cff11ff11Gloves of Haste|r","").append(12,3,5);
                thistype.create(ITID_SWORD_OF_ASSASSINATION,"|cff11ff11Sword of Assassination|r","").append(11,0.03,0.05);
                thistype.create(ITID_VITALITY_PERIAPT,"|cff11ff11Vitality Periapt|r","").append(21,75,150);
                thistype.create(ITID_RING_OF_PROTECTION,"|cff11ff11Ring of Protection|r","").append(8,2,3);
                thistype.create(ITID_TALISMAN_OF_EVASION,"|cff11ff11Talisman of Evasion|r","").append(27,0.02,0.03);
                thistype.create(ITID_MANA_PERIAPT,"|cff11ff11Mana Periapt|r","").append(17,75,150);
                thistype.create(ITID_SOBI_MASK,"|cff11ff11Sobi Mask|r","").append(72,1,2);
                thistype.create(ITID_MAGIC_BOOK,"|cff11ff11Magic Book|r","").append(18,5,10);
                thistype.create(ITID_CRYSTAL_BALL,"|cff11ff11Crystal Ball|r","").append(20,0.03,0.05);
                thistype.create(ITID_LONG_STAFF,"|cff11ff11Long Staff|r","").append(19,0.03,0.05);
                thistype.create(ITID_HEALTH_STONE,"|cff11ff11Health Stone|r","").append(73,2,4).append(31,400,800);
                thistype.create(ITID_MANA_STONE,"|cff11ff11Mana Stone|r","").append(72,1,1).append(30,200,400);
                thistype.create(ITID_ROMULOS_EXPIRED_POISON,"|cff11ff11Romulo's Expired Poison|r","|cff999999Still usable.|r").append(53,25,100);
                thistype.create(ITID_MOROES_LUCKY_GEAR,"|cff11ff11Moroes' Lucky Gear|r","|cff999999Disassembled from Moroes' Lucky Pocket Watch.|r").append(27,0.01,0.02).append(35,8,12);
                thistype.create(ITID_RUNED_BELT,"|cff11ff11Runed Belt|r","|cff999999A bracelet belongs to an ogre.|r").append(21,57,113).append(2,0.03,0.05);
                thistype.create(ITID_UNGLAZED_ICON_OF_THE_CRESCENT,"|cff11ff11Unglazed Icon of the Crescent|r","|cff999999It can be seen vaguely that this icon was once beautiful silver.|r").append(14,4,7).append(33,13,25);
                thistype.create(ITID_COLOSSUS_BLADE,"|cff11ff11Colossus Blade|r","|cff999999A rough sword, the workmanship is not very good. But it's the most popular production weapons in Harrogath.|r").append(9,8,15).append(12,4,8);
                thistype.create(ITID_THE_X_RING,"|cff8b66ffThe X Ring|r","|cffffdeadAll the former 20 are trash!|r").append(7,12,21);
                thistype.create(ITID_GOBLIN_ROCKET_BOOTS_LIMITED_EDITION,"|cff8b66ffGoblin Rocket Boots Limited Edition|r","|cffffdeadLimited edition, but it's a goblin product after all. So use it with caution.|r").append(21,100,200).append(17,100,200).append(24,13,25).append(36,8,12);
                thistype.create(ITID_WARSONG_BATTLE_DRUMS,"|cff8b66ffWarsong Battle Drums|r","|cffffdeadHigh morale.|r").append(11,0.02,0.04).append(56,0.01,0.02).append(84,0.01,0.02);
                thistype.create(ITID_TROLL_BANE,"|cff8b66ffTroll Bane|r","|cffffdeadYou know this blade...|r").append(4,5,10).append(12,3,5).append(9,5,10);
                thistype.create(ITID_GOREHOWL,"|cff8b66ffGorehowl|r","|cffffdeadThe axe of Grom Hellscream has sown terror across hundreds of battlefields.|r").append(4,6,12).append(21,75,150).append(11,0.03,0.05);
                thistype.create(ITID_CORE_HOUND_TOOTH,"|cff8b66ffCore Hound Tooth|r","").append(21,75,150).append(12,3,5).append(11,0.03,0.05);
                thistype.create(ITID_VISKAG,"|cff8b66ffVis'kag|r","|cffffdeadThe blood letter.|r").append(13,5,10).append(9,5,10).append(12,3,5).append(44,0.03,0.06);
                thistype.create(ITID_LION_HORN,"|cff8b66ffLion Horn|r","|cffffdeadMuch better than Dragonspine Trophy.|r").append(9,5,10).append(3,0.01,0.01).append(48,0.05,0.07);
                thistype.create(ITID_ARMOR_OF_THE_DAMNED,"|cff8b66ffArmor of the Damned|r","|cffffdeadSlow, Curse, Weakness, Misfortune|r").append(8,2,3).append(21,120,240).append(74,4,8).append(41,50,100);
                thistype.create(ITID_BULWARK_OF_THE_AMANI_EMPIRE,"|cff8b66ffBulwark of the Amani Empire|r","|cff999999It still seems to linger with the resentment of the first guardian warrior of the Brothers Guild.|r").append(8,2,3).append(4,5,10).append(15,14,28);
                thistype.create(ITID_SIGNET_OF_THE_LAST_DEFENDER,"|cff8b66ffSignet of the Last Defender|r","|cffffdeadThe signet originally belongs to a demon lord and was later stolen by an orc thief.|r").append(21,100,200).append(27,0.02,0.03).append(6,0.03,0.06);
                thistype.create(ITID_ARANS_SOOTHING_EMERALD,"|cff8b66ffAran's Soothing Emerald|r","|cffffdeadAran had made all kinds of precious stones into soothing gems. It should be a sapphire that adventurers are most familiar with.|r").append(14,5,10).append(18,5,10).append(72,1,2);
                thistype.create(ITID_PURE_ARCANE,"|cff8b66ffPure Arcane|r","|cffffdeadMegatorque despises this, he thinks that one simple capacitor can achieve this effect.|r").append(77,170,340);
                thistype.create(ITID_HEX_SHRUNKEN_HEAD,"|cff8b66ffHex Shrunken Head|r","|cffffdeadThe Hex Lord is now strong enough to no longer need such trinkets.|r").append(14,5,10).append(18,5,10).append(34,40,80);
                thistype.create(ITID_STAFF_OF_THE_SHADOW_FLAME,"|cff8b66ffStaff of the Shadow Flame|r","|cffffdeadThe dark flame at the end of the staff is so pure and contains tremendous energy.|r").append(14,5,10).append(18,5,10).append(20,0.03,0.05);
                thistype.create(ITID_TIDAL_LOOP,"|cff8b66ffTidal Loop|r","|cffffdeadThe ring was crafted to fight against the Lord of Fire's legion. But now its ability of fire resistance has lost.|r").append(4,5,10).append(72,2,4).append(87,60,90);
                thistype.create(ITID_ORB_OF_THE_SINDOREI,"|cff8b66ffOrb of the Sin'dorei|r","|cffffdeadThe glory sign of remarkable bloodelf defenders.|r").append(4,4,7).append(18,8,15).append(16,0.04,0.06).append(86,0.03,0.07);
                thistype.create(ITID_REFORGED_BADGE_OF_TENACITY,"|cff8b66ffReforged Badge of Tenacity|r","|cffffdeadOriginally forged by a demon overseer named Shartuul.|r").append(13,4,7).append(21,120,240).append(27,0.02,0.03).append(78,0.08,0.1).append(92,3,7);
                thistype.create(ITID_LIGHTS_JUSTICE,"|cff8b66ffLight's Justice|r","|cffffdeadOpen your heart to the light.|r").append(14,4,7).append(18,5,10).append(20,0.03,0.05).append(79,0,0).append(91,0,0);
                thistype.create(ITID_BENEDICTION,"|cff8b66ffBenediction|r","|cffffdeadBehind the light, it's shadow.|r").append(14,4,7).append(18,5,10).append(72,2,4).append(76,4,6).append(80,0,0);
                thistype.create(ITID_HORN_OF_CENARIUS,"|cff8b66ffHorn of Cenarius|r","|cffffdeadThis Night Elf artifact is said to be able to summon the souls of all night elves.|r").append(7,4,7).append(21,100,200).append(17,100,200).append(69,3,4.7);
                thistype.create(ITID_BANNER_OF_THE_HORDE,"|cff8b66ffBanner of the Horde|r","|cffffdeadWith the tribal glory, the head of the enemies were left behind.|r").append(4,5,10).append(9,5,10).append(11,0.03,0.05).append(39,0.4,0.6);
                thistype.create(ITID_KELENS_DAGGER_OF_ASSASSINATION,"|cff8b66ffKelen's Dagger of Assassination|r","|cffffdeadKelen is not just a master escaper.|r").append(13,5,10).append(9,5,10).append(12,3,5).append(66,0,0).append(65,0.04,0.06).append(90,0.03,0.06);
                thistype.create(ITID_RHOKDELAR,"|cff8b66ffRhokdelar|r","|cffffdeadLongbow of the Ancient Keepers|r").append(13,5,8).append(12,3,5).append(11,0.03,0.05).append(24,10,20).append(94,0.7,1);
                thistype.create(ITID_RAGE_WINTERCHILLS_PHYLACTERY,"|cff8b66ffRage Winterchill's Phylactery|r","|cffffdeadFor some people, the value of his phylactery is greater than the Chronicle of Dark Secrets.|r").append(14,5,10).append(19,0.03,0.05).append(96,0.02,0.04).append(70,0.01,0.02);
                thistype.create(ITID_ANATHEMA,"|cff8b66ffAnathema|r","|cffffdeadBefore the shadows, it's light.|r").append(21,125,250).append(18,5,10).append(20,0.03,0.05).append(81,1.5,2);
                thistype.create(ITID_RARE_SHIMMER_WEED,"|cff8b66ffRare Shimmer Weed|r","|cffffdeadGathered from Thunder Mountain, this shimmer weed seems to have real thunder energy.|r").append(7,4,7).append(12,3,5).append(19,0.03,0.05).append(93,0.01,0.03);
                thistype.create(ITID_CALL_TO_ARMS,"|cffff8c00Call To Arms|r","|cffffdeadWhen Zakarum was exiled, he led a mercenary team. It is this very battle axe and his Holy Shield that lead his brothers through the bodies of countless enemies.|r").append(9,5,10).append(18,5,10).append(73,10,17).append(57,10,20).append(29,0.06,0.12);
                thistype.create(ITID_WOESTAVE,"|cffff8c00Woestave|r","|cffffdeadCause of the great plague.|r").append(9,5,15).append(63,0.01,0.03).append(62,0.02,0.04).append(61,1,2).append(60,0.03,0.04).append(64,0.01,0.01).append(59,0.11,0.17);
                thistype.create(ITID_ENIGMA,"|cffff8c00Enigma|r","|cffffdeadNot recorded.|r").append(1,0.01,0.02).append(3,0.01,0.02).append(24,12,20).append(4,5,10).append(40,0.01,0.02).append(28,0,0);
                thistype.create(ITID_BREATH_OF_THE_DYING,"|cffff8c00Breath of the Dying|r","|cffffdeadThe master piece by Griswold the Undead. On the unglazed handle six obscure runes glow: Vex-Hel-El-Eld-Zod-Eth.|r").append(7,4,7).append(9,5,10).append(12,5,10).append(45,0.02,0.04).append(50,18,23);
                thistype.create(ITID_WINDFORCE,"|cffff8c00Windforce|r","|cffffdeadThe wind carries life for those enveloped in its flow, and death for those arrayed against it.|r").append(13,5,10).append(9,5,10).append(12,3,5).append(11,0.03,0.05).append(47,0.05,0.1);
                thistype.create(ITID_DERANGEMENT_OF_CTHUN,"|cffff8c00Derangement of C'Thun|r","|cffffdeadAlthough the main body of the Old God C'Thun was eliminated, the faceless one formed by his degraded tentacles was everywhere in the abyss of the earth.|r").append(4,6,12).append(9,6,12).append(11,0.03,0.05).append(74,3,30).append(44,0.03,0.06).append(46,0.04,0.06).append(37,0.05,0.5);
                thistype.create(ITID_MIGHT_OF_THE_ANGEL_OF_JUSTICE,"|cffff8c00Might of the Angel of Justice|r","|cffffdeadThe armor used by Tyrael, the Archangel of Wisdom when he was once the incarnation of justice.|r").append(8,2,3).append(1,0.01,0.02).append(2,0.02,0.04).append(24,12,24).append(42,2,5).append(38,25,35);
                thistype.create(ITID_INFINITY,"|cffff8c00Infinity|r","|cffffdeadInfinity is the essence of the Will o'wisps. The energy of lightning contained in it excites the prophet Drexel. It is said that the soul of the bleak soul with a green cloud-like halo is a nightmare for all adventurers.|r").append(14,5,10).append(21,100,200).append(18,5,10).append(82,0.01,0.02).append(89,60,100);
                thistype.create(ITID_INSIGHT,"|cffff8c00Insight|r","|cffffdeadIn the fight against the forest trolls, the Blood Elf Rangers used this enchanted orb from Kirin Tor and eventually succeeded in establishing Quel'Thalas.|r").append(14,5,10).append(18,5,10).append(19,0.03,0.05).append(68,0,0).append(83,2,4);
                thistype.create(ITID_VOODOO_VIALS,"|cffff8c00Voodoo Vials|r","|cffffdeadZanzil *makes* friends by these small vials.|r").append(14,5,10).append(20,0.03,0.05).append(19,0.03,0.05).append(88,12,20).append(32,15,30);
                thistype.create(ITID_MOONLIGHT_GREATSWORD,"|cffff8c00Moonlight Greatsword|r","|cffffdeadLudwig the Holy Blade.|r").append(4,5,10).append(21,75,150).append(57,10,20).append(43,0.02,0.04).append(75,30,60).append(49,100,250);
                thistype.create(ITID_DETERMINATION_OF_VENGEANCE,"|cffffcc00Determination of Vengeance|r","|cffffdeadThe determination to revenge Mal'Ganis is unshakeable.|r").append(13,5,8).append(21,50,75).append(1,0.01,0.02).append(16,0.02,0.04);
                thistype.create(ITID_STRATHOLME_TRAGEDY,"|cffffcc00Stratholme Tragedy|r","|cffffdeadIn disregard of Jaina's advice, Stratholme became a hell on earth in merely one night.|r").append(9,9,12).append(12,4,6).append(67,0.05,0.09).append(24,12,18);
                thistype.create(ITID_PATRICIDE,"|cffffcc00Patricide|r","|cffffdeadOne last step!|r").append(9,12,16).append(52,26,48).append(55,0.05,0.1).append(12,3,4).append(54,1,1);
                thistype.create(ITID_FROSTMOURNE,"|cffffcc00FrostMourne|r","|cffffdeadA gift from the Lich King.|r").append(4,4,6).append(44,0.02,0.04).append(71,7,12).append(43,0.02,0.03).append(58,24,55);
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
            thistype.put(SUFIX_LETHALITY, 1, 2, IATTR_CRIT, 0.03, 0.07, " of Lethality");
            thistype.put(SUFIX_SNAKE, 1, 2, IATTR_SCRIT, 0.03, 0.07, " of Snake");
            thistype.put(SUFIX_QUICKNESS, 1, 2, IATTR_IAS, 3, 7, " of Quickness");
            thistype.put(SUFIX_WIND_SERPENT, 1, 2, IATTR_SHASTE, 0.03, 0.07, " of Wind Serpent");
            thistype.put(SUFIX_BRUTE, 1, 2, IATTR_STR, 8, 15, " of Brute");
            thistype.put(SUFIX_DEXTERITY, 1, 2, IATTR_AGI, 8, 15, " of Dexterity");
            thistype.put(SUFIX_WISDOM, 1, 2, IATTR_INT, 8, 15, " of Wisdom");
            thistype.put(SUFIX_VITALITY, 1, 2, IATTR_HP, 113, 225, " of Vitality");
            thistype.put(SUFIX_CHAMPION, 1, 2, IATTR_STR, 5, 9, " of Champion").addAttribute(IATTR_AP, 6, 11);
            thistype.put(SUFIX_BUTCHER, 1, 2, IATTR_STR, 5, 9, " of Butcher").addAttribute(IATTR_CRIT, 0.02, 0.05);
            thistype.put(SUFIX_ASSASSIN, 1, 2, IATTR_AGI, 5, 9, " of Assassin").addAttribute(IATTR_CRIT, 0.02, 0.05);
            thistype.put(SUFIX_RANGER, 1, 2, IATTR_AGI, 5, 9, " of Ranger").addAttribute(IATTR_AP, 6, 11);
            thistype.put(SUFIX_WIZARD, 1, 2, IATTR_INT, 5, 9, " of Wizard").addAttribute(IATTR_SHASTE, 0.02, 0.05);
            thistype.put(SUFIX_PRIEST, 1, 2, IATTR_INT, 5, 9, " of Priest").addAttribute(IATTR_MREG, 1, 2);
            thistype.put(SUFIX_GUARDIAN, 1, 2, IATTR_HP, 68, 135, " of Guardian").addAttribute(IATTR_DODGE, 0.02, 0.03);
            thistype.put(SUFIX_MASTERY, 1, 2, IATTR_LP, 1, 3, " of Mastery");
            thistype.put(SUFIX_BLUR, 1, 2, IATTR_DODGE, 0.02, 0.05, " of Blur");
            thistype.put(SUFIX_STRONGHOLD, 1, 2, IATTR_DEF, 2, 5, " of Stronghold");
            thistype.put(SUFIX_DEEP_SEA, 1, 2, IATTR_MREG, 2, 3, " of Deep Sea");
            thistype.put(SUFIX_VOID, 1, 2, IATTR_SP, 10, 20, " of Void");
            thistype.put(PREFIX_HEAVY, 1, 1, IATTR_STR, 4, 7, "Heavy ");
            thistype.put(PREFIX_STRONG, 2, 1, IATTR_STR, 8, 15, "Strong ");
            thistype.put(PREFIX_SHARP, 1, 1, IATTR_AGI, 4, 7, "Sharp ");
            thistype.put(PREFIX_AGILE, 2, 1, IATTR_AGI, 8, 15, "Agile ");
            thistype.put(PREFIX_SHIMERING, 1, 1, IATTR_INT, 4, 7, "Shimering ");
            thistype.put(PREFIX_INTELLIGENT, 2, 1, IATTR_INT, 8, 15, "Intelligent ");
            thistype.put(PREFIX_ENDURABLE, 1, 1, IATTR_HP, 57, 112, "Endurable ");
            thistype.put(PREFIX_VIBRANT, 2, 1, IATTR_HP, 113, 225, "Vibrant ");
            thistype.put(PREFIX_SKILLED, 1, 1, IATTR_AP, 5, 10, "Skilled ");
            thistype.put(PREFIX_CRUEL, 2, 1, IATTR_AP, 10, 20, "Cruel ");
            thistype.put(PREFIX_ENCHANTED, 1, 1, IATTR_SP, 8, 12, "Enchanted ");
            thistype.put(PREFIX_SORCEROUS, 2, 1, IATTR_SP, 13, 20, "Sorcerous ");
            thistype.put(PREFIX_MYSTERIOUS, 1, 1, IATTR_MREG, 1, 1, "Mysterious ");
            thistype.put(PREFIX_ETERNAL, 2, 1, IATTR_MREG, 2, 3, "Eternal ");
            thistype.put(PREFIX_STEADY, 1, 1, IATTR_DEF, 1, 2, "Steady ");
            thistype.put(PREFIX_TOUGH, 2, 1, IATTR_DEF, 3, 5, "Tough ");
        }
    }

    public type AttributeBehaviourMetaCallback extends function(unit, real, integer);
    struct AttributeBehaviourMeta[] {
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
        static method callbackLEECHAURA(unit u, real val, integer polar) {}
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
        static method callbackATK_BLEED(unit u, real val, integer polar) {}
        static method callbackATK_MDC(unit u, real val, integer polar) {
            EquipedChanceMagicDamage(u, polar);
        }
        static method callbackATK_STUN(unit u, real val, integer polar) {}
        static method callbackATK_CRIT(unit u, real val, integer polar) {
            EquipedAttackChanceICC(u, polar);
        }
        static method callbackATK_AMP(unit u, real val, integer polar) {
            EquipedAttackAmplifiedDamage(u, polar);
        }
        static method callbackATK_MD(unit u, real val, integer polar) {
            EquipedExtraMagicDamage(u, polar);
        }
        static method callbackATK_MDK(unit u, real val, integer polar) {}
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
        static method callbackUSE_INT(unit u, real val, integer polar) {}
        static method callbackUSE_SP(unit u, real val, integer polar) {}
        static method callbackUSE_DODGE(unit u, real val, integer polar) {}
        static method callbackUSE_MS(unit u, real val, integer polar) {}
        static method callbackUSE_CTHUN(unit u, real val, integer polar) {}
        static method callbackUSE_HOLYHEAL(unit u, real val, integer polar) {}

        static method onInit() {
            //:template.id = attributeMeta
            //:template.indentation = 3
            thistype.put(IATTR_STR,1,100,0,"+"," Strength",thistype.callbackSTR);
            thistype.put(IATTR_STRPL,1,101,0,"+"," Strength/level",thistype.callbackSTRPL);
            thistype.put(IATTR_AGI,1,102,0,"+"," Agility",thistype.callbackAGI);
            thistype.put(IATTR_INT,1,104,0,"+"," Intelligence",thistype.callbackINT);
            thistype.put(IATTR_ALLSTAT,1,106,0,"+"," All stats",thistype.callbackALLSTAT);
            thistype.put(IATTR_HP,1,110,0,"+"," Max HP",thistype.callbackHP);
            thistype.put(IATTR_HPPCT,1,111,0,"+"," Max HP",thistype.callbackHPPCT);
            thistype.put(IATTR_HPPL,1,112,0,"+"," Max HP/level",thistype.callbackHPPL);
            thistype.put(IATTR_MP,1,114,0,"+"," Max MP",thistype.callbackMP);
            thistype.put(IATTR_AP,1,120,0,"+"," Attack power",thistype.callbackAP);
            thistype.put(IATTR_APPL,1,121,0,"+"," Attack power/level",thistype.callbackAPPL);
            thistype.put(IATTR_CRIT,1,122,0,"+"," Attack critical",thistype.callbackCRIT);
            thistype.put(IATTR_IAS,1,124,0,"+","% Attack speed",thistype.callbackIAS);
            thistype.put(IATTR_SP,1,130,0,"+"," Spell power",thistype.callbackSP);
            thistype.put(IATTR_SCRIT,1,132,0,"+"," Spell critical",thistype.callbackSCRIT);
            thistype.put(IATTR_SHASTE,1,134,0,"+"," Spell haste",thistype.callbackSHASTE);
            thistype.put(IATTR_DEF,1,140,0,"+"," Armor",thistype.callbackDEF);
            thistype.put(IATTR_DEFPL,1,141,0,"+"," Armor/level",thistype.callbackDEFPL);
            thistype.put(IATTR_BR,1,142,0,"+"," Block chance",thistype.callbackBR);
            thistype.put(IATTR_BP,1,144,0,"+"," Block points",thistype.callbackBP);
            thistype.put(IATTR_DODGE,1,146,0,"+"," Dodge chance",thistype.callbackDODGE);
            thistype.put(IATTR_DR,1,150,0,"-"," All damage taken",thistype.callbackDR);
            thistype.put(IATTR_MDR,1,152,0,"-"," magic damage taken",thistype.callbackMDR);
            thistype.put(IATTR_AMP,1,154,0,"+"," Damage and healing dealt",thistype.callbackAMP);
            thistype.put(IATTR_HAMP,1,156,0,"+"," Healing taken",thistype.callbackHAMP);
            thistype.put(IATTR_MREG,1,160,0,"Regens "," MP per second",thistype.callbackMREG);
            thistype.put(IATTR_HREG,1,162,0,"Regens "," HP per second",thistype.callbackHREG);
            thistype.put(IATTR_HLOST,1,164,0,"Lost "," HP per second during combat",thistype.callbackHLOST);
            thistype.put(IATTR_MS,1,170,0,"+"," Movement speed",thistype.callbackMS);
            thistype.put(IATTR_MSPL,1,171,0,"+"," Movement speed/level",thistype.callbackMSPL);
            thistype.put(IATTR_LP,1,195,0,"Improve item |cff33ff33special power|r + ","",thistype.callbackLP);
            thistype.put(IATTR_ATK_ML,3,200,0,"|cff87ceeb+"," Mana stolen per hit|r",thistype.callbackATK_ML);
            thistype.put(IATTR_ATK_LL,3,202,0,"|cff87ceeb+"," Life stolen per hit|r",thistype.callbackATK_LL);
            thistype.put(IATTR_ATK_LLML,3,204,0,"|cff87ceeb+"," Life and mana stolen per hit|r",thistype.callbackATK_LLML);
            thistype.put(IATTR_ATK_MD,3,210,0,"|cff87ceebDeals "," extra magic damage per hit|r",thistype.callbackATK_MD);
            thistype.put(IATTR_ATK_MDK,3,211,0,"|cff87ceebDeals "," extra magic damage per hit, scaled up by target HP lost|r",thistype.callbackATK_MDK);
            thistype.put(IATTR_RG_ONESHOT,3,250,0,"|cff87ceebOne-shot target when it's HP is less than yours","|r",thistype.callbackRG_ONESHOT);
            thistype.put(IATTR_MCVT,3,253,0,"|cff87ceebConverts your normal attacks into magic damage","|r",thistype.callbackMCVT);
            thistype.put(IATTR_PL_SHOCK,3,256,0,"|cff87ceebHoly Shock always deals critical healing","|r",thistype.callbackPL_SHOCK);
            thistype.put(IATTR_PR_SHIELD,3,259,0,"|cff87ceebRemoves weakness effect of Shield","|r",thistype.callbackPR_SHIELD);
            thistype.put(IATTR_PL_LIGHT,3,262,0,"|cff87ceebFlash Light dispels one debuff from target","|r",thistype.callbackPL_LIGHT);
            thistype.put(IATTR_DT_MREGEN,3,266,0,"|cff87ceebRegens MP from "," of the damage taken|r",thistype.callbackDT_MREGEN);
            thistype.put(IATTR_USE_TP,3,268,0,"|cff87ceebUse: Teleports to an ally","|r",thistype.callbackUSE_TP);
            thistype.put(IATTR_BM_VALOR,2,300,0.33,"|cff33ff33Regenerates "," more valor points|r",thistype.callbackBM_VALOR);
            thistype.put(IATTR_RG_RUSH,2,302,0.16,"|cff33ff33Sinister Strike and Eviscerate deal "," extra damage to target below 30% max HP|r",thistype.callbackRG_RUSH);
            thistype.put(IATTR_CRKILLER,2,303,0.5,"|cff33ff33Deals "," extra damage to non-hero targets|r",thistype.callbackCRKILLER);
            thistype.put(IATTR_KG_REGRCD,2,305,0.33,"|cff33ff33Reduce cooldown of Instant Regrowth by "," seconds (unique)|r",thistype.callbackKG_REGRCD);
            thistype.put(IATTR_LEECHAURA,2,307,0.33,"|cff33ff33Absorb "," HP from all enemies nearby every second|r",thistype.callbackLEECHAURA);
            thistype.put(IATTR_PR_POHDEF,2,308,0.2,"|cff33ff33Prayer of healing increases armor of target by ","|r",thistype.callbackPR_POHDEF);
            thistype.put(IATTR_DR_MAXHP,2,310,0.16,"|cff33ff33Survival Instincts provides "," extra healing and max HP|r",thistype.callbackDR_MAXHP);
            thistype.put(IATTR_CT_PAIN,2,313,0.4,"|cff33ff33Marrow Squeeze extends the Pain on target by "," seconds|r",thistype.callbackCT_PAIN);
            thistype.put(IATTR_BD_SHIELD,2,314,0.33,"|cff33ff33Shield of Sin'dorei provides "," extra damage reduction, and forces all nearby enemies to attack you|r",thistype.callbackBD_SHIELD);
            thistype.put(IATTR_RG_PARALZ,2,315,0.33,"|cff33ff33Sinister Strike has a "," chance to paralyze target, reduce target spell haste by 20% and gain an extra combo point|r",thistype.callbackRG_PARALZ);
            thistype.put(IATTR_DR_CDR,2,317,0.16,"|cff33ff33Reduce cooldown of Survival Instincts by "," seconds (unique)|r",thistype.callbackDR_CDR);
            thistype.put(IATTR_SM_LASH,2,318,0.1,"|cff33ff33Storm Lash has "," extra chance to cooldown Earth Shock (unique)|r",thistype.callbackSM_LASH);
            thistype.put(IATTR_DK_ARROW,2,319,0.12,"|cff33ff33Number of Dark Arrows increased by "," (unique)|r",thistype.callbackDK_ARROW);
            thistype.put(IATTR_MG_FDMG,2,320,0.2,"|cff33ff33Increase ice spell damage by ","|r",thistype.callbackMG_FDMG);
            thistype.put(IATTR_MG_BLZ,2,322,0.16,"|cff33ff33"," chance to cast an instant Frost Bolt to targets damaged by Blizzard|r",thistype.callbackMG_BLZ);
            thistype.put(IATTR_ATK_CTHUN,2,403,0.15,"|cff33ff33On Attack: Increase attack speed by 1% per attack, stacks up to ",", lasts for 3 seconds|r",thistype.callbackATK_CTHUN);
            thistype.put(IATTR_ATK_WF,2,404,0.2,"|cff33ff33On Attack: "," chance to knock back target|r",thistype.callbackATK_WF);
            thistype.put(IATTR_ATK_LION,2,405,0.16,"|cff33ff33On Attack: "," chance to increase 30% attack speed, lasts for 5 seconds|r",thistype.callbackATK_LION);
            thistype.put(IATTR_ATK_MOONWAVE,2,406,0.7,"|cff33ff33On Attack: 10% chance to consume 5% of max MP, deals "," magic damage to all enemies in a row|r",thistype.callbackATK_MOONWAVE);
            thistype.put(IATTR_ATK_POISNOVA,2,407,0.7,"|cff33ff33On Attack: 15% chance to cast poison nova, dealing "," magic damage over time to all enemies within 600 yards|r",thistype.callbackATK_POISNOVA);
            thistype.put(IATTR_ATK_COIL,2,408,0.7,"|cff33ff33On Attack: 15% chance to cast Death Coil, deals "," magic damage to target. Target takes 3% extra damge|r",thistype.callbackATK_COIL);
            thistype.put(IATTR_ATK_BLEED,2,409,0.7,"|cff33ff33On Attack: 20% chance to deal bleed effect to target. Target takes "," physical damage over time, lasts for 10 seconds|r",thistype.callbackATK_BLEED);
            thistype.put(IATTR_ATK_MDC,2,410,0.7,"|cff33ff33On Attack: 25% chance to deal "," magic damage to target|r",thistype.callbackATK_MDC);
            thistype.put(IATTR_ATK_STUN,2,411,0.2,"|cff33ff33On Attack: 5% chance to stun target for "," seconds|r",thistype.callbackATK_STUN);
            thistype.put(IATTR_ATK_CRIT,2,412,0.16,"|cff33ff33On Attack: "," chance to increase 100% attack critical chance, lasts for 5 seconds|r",thistype.callbackATK_CRIT);
            thistype.put(IATTR_ATK_AMP,2,413,0.1,"|cff33ff33On Attack: Target takes "," extra damage|r",thistype.callbackATK_AMP);
            thistype.put(IATTR_ATK_MORTAL,2,416,0.1,"|cff33ff33On Attack: Decrease target healing taken by ","|r",thistype.callbackATK_MORTAL);
            thistype.put(IATTR_ATK_MISS,2,417,0.1,"|cff33ff33On Attack: Decrease target attack accuracy by ","|r",thistype.callbackATK_MISS);
            thistype.put(IATTR_ATK_DDEF,2,418,0.1,"|cff33ff33On Attack: Decrease target armor by ","|r",thistype.callbackATK_DDEF);
            thistype.put(IATTR_ATK_DAS,2,419,0.1,"|cff33ff33On Attack: Decrease target attack speed by ","|r",thistype.callbackATK_DAS);
            thistype.put(IATTR_ATK_DMS,2,420,0.1,"|cff33ff33On Attack: Decrease target movement speed by ","|r",thistype.callbackATK_DMS);
            thistype.put(IATTR_ATK_WEAK,2,421,0.1,"|cff33ff33On Attack: Decrease target damage and healing dealt by ","|r",thistype.callbackATK_WEAK);
            thistype.put(IATTR_3ATK_MOONEXP,2,430,0.7,"|cff33ff33Every Third Attack: Consumes 5% of max MP, deals "," magic damage to all enemies nearby|r",thistype.callback3ATK_MOONEXP);
            thistype.put(IATTR_MD_MREGEN,2,450,0.5,"|cff33ff33Dealing Magical Damage or Healing: 1% chance to regen "," MP|r",thistype.callbackMD_MREGEN);
            thistype.put(IATTR_MD_POISON,2,451,0.7,"|cff33ff33Dealing Magical Damage: 10% chance to poison target, dealing "," magic damage over time|r",thistype.callbackMD_POISON);
            thistype.put(IATTR_MD_CHAIN,2,452,0.7,"|cff33ff33Dealing Magical Damage: 10% chance to cast Chain Lightning to target, dealing "," magic damage|r",thistype.callbackMD_CHAIN);
            thistype.put(IATTR_MDC_ARCANE,2,460,0.5,"|cff33ff33Magical Damage Critical: Charges with arcane power. All arcane power will be released automatically after 3 stacks, dealing "," magic damage to target|r",thistype.callbackMDC_ARCANE);
            thistype.put(IATTR_HEAL_HOLY,2,501,0.33,"|cff33ff33On Healed: Charges 1 holy power, stacks up to "," points|r",thistype.callbackHEAL_HOLY);
            thistype.put(IATTR_ATKED_WEAK,2,600,0.33,"|cff33ff33On Attacked: Decreases attacker's attack power by ","|r",thistype.callbackATKED_WEAK);
            thistype.put(IATTR_AURA_CONVIC,2,800,0.1,"|cff33ff33Grant Aura of Conviction: All enemies within 600 yards take "," more magic damage|r",thistype.callbackAURA_CONVIC);
            thistype.put(IATTR_AURA_MEDITA,2,801,0.2,"|cff33ff33Grant Aura of Meditation: All allies within 600 yards regen "," MP per second|r",thistype.callbackAURA_MEDITA);
            thistype.put(IATTR_AURA_WARSONG,2,802,0.1,"|cff33ff33Grant Aura of Warsong: All allies deal "," more damage and healing, take 10% more healing within 600 yards|r",thistype.callbackAURA_WARSONG);
            thistype.put(IATTR_AURA_UNHOLY,2,803,0.7,"|cff33ff33Grant Aura of Unholy: All allies within 600 yards regen "," HP per second|r",thistype.callbackAURA_UNHOLY);
            thistype.put(IATTR_USE_BATTLE,2,901,0.16,"|cff33ff33Use: Battle Orders, increases "," max HP to all allies within 900 yards, lasts for 75 seconds|r",thistype.callbackUSE_BATTLE);
            thistype.put(IATTR_USE_MREGEN,2,902,0.4,"|cff33ff33Use: Regens "," MP|r",thistype.callbackUSE_MREGEN);
            thistype.put(IATTR_USE_HREGEN,2,903,0.4,"|cff33ff33Use: Regens "," HP|r",thistype.callbackUSE_HREGEN);
            thistype.put(IATTR_USE_VOODOO,2,904,0.2,"|cff33ff33Use: Deals "," magic damage to all enemies within range over time|r",thistype.callbackUSE_VOODOO);
            thistype.put(IATTR_USE_INT,2,905,0.3,"|cff33ff33Use: Increase intelligence by ",", lasts for 20 seconds|r",thistype.callbackUSE_INT);
            thistype.put(IATTR_USE_SP,2,906,0.3,"|cff33ff33Use: Increase spell power by ",", lasts for 15 seconds|r",thistype.callbackUSE_SP);
            thistype.put(IATTR_USE_DODGE,2,907,0.1,"|cff33ff33Use: Increase dodge chance by 30%, lasts for "," seconds|r",thistype.callbackUSE_DODGE);
            thistype.put(IATTR_USE_MS,2,908,0.1,"|cff33ff33Use: Increase movement speed by 300, lasts for "," seconds. Possible failures.|r",thistype.callbackUSE_MS);
            thistype.put(IATTR_USE_CTHUN,2,909,-0.33,"|cff33ff33Use: Increase attack speed by 100%, take "," extra damage (unique)|r",thistype.callbackUSE_CTHUN);
            thistype.put(IATTR_USE_HOLYHEAL,2,910,0.33,"|cff33ff33Use: Release all holy power to heal yourself, each point heals "," HP|r",thistype.callbackUSE_HOLYHEAL);
            //:template.end
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
                countReforge = 0;
                EnumItemsInRect(ApprenticeAnvil, null, function() {countReforge += 1;});
                if (countReforge == 1) {
                    EnumItemsInRect(ApprenticeAnvil, null, function() {
                        ItemExAttributes iea = ItemExAttributes.inst(GetEnumItem(), "reforge");
                        iea.reforge(1);
                        iea.updateUbertip();
                        iea.updateName();
                    });
                } else {
                    SimError(GetOwningPlayer(u), "Place exact one item in circle, current: " + I2S(countReforge));
                    AdjustPlayerStateSimpleBJ(GetOwningPlayer(u), PLAYER_STATE_RESOURCE_LUMBER, 5);
                }
            } else if (itid == ITID_REFORGE_UNCOMMON_L2) {
            } else if (itid == ITID_REFORGE_UNCOMMON_L3) {
            } else if (itid == ITID_REFORGE_RARE_L2) {
            } else if (itid == ITID_REFORGE_RARE_L3) {
            } else if (itid == ITID_REFORGE_LEGENDARY_L3) {
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
        MasterAnvil = Rect(6267, -11776, 6394, -11638);
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

        ipPrefix2.add(PREFIX_STRONG, 10);
        ipPrefix2.add(PREFIX_AGILE, 10);
        ipPrefix2.add(PREFIX_INTELLIGENT, 10);
        ipPrefix2.add(PREFIX_VIBRANT, 10);
        ipPrefix2.add(PREFIX_CRUEL, 10);
        ipPrefix2.add(PREFIX_SORCEROUS, 10);
        ipPrefix2.add(PREFIX_ETERNAL, 10);
        ipPrefix2.add(PREFIX_TOUGH, 10);

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
        ipSufix.add(SUFIX_MASTERY, 100);
        ipSufix.add(SUFIX_BLUR, 10);
        ipSufix.add(SUFIX_STRONGHOLD, 10);
        ipSufix.add(SUFIX_DEEP_SEA, 10);
        ipSufix.add(SUFIX_VOID, 10);
    }

}
//! endzinc
