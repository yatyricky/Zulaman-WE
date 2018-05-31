//! zinc
library ItemAttributes requires UnitProperty, List, BreathOfTheDying, WindForce, Infinity, ConvertAttackMagic, MagicPoison, VoodooVial, RomulosExpiredPoison, Drum {
    public constant real AFFIX_FACTOR_BASE = 15000;
    public constant real AFFIX_FACTOR_DELTA = 2500;
    public constant real SUFIX_MULTIPLIER = 4;
    public constant real PREFIX_STATIC_MOD = -0.5;
    public constant real SUFIX_STATIC_MOD = -0.2;
    public constant real PREFIX_MAX_PROB = 0.9;
    public constant real SUFIX_MAX_PROB = 0.75;

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
                thistype.create(ITID_CIRCLET_OF_NOBILITY,"|CFF11FF11Circlet of Nobility|R","").append(7,2,4);
                thistype.create(ITID_HEAVY_BOOTS,"|CFF11FF11Heavy Boots|R","|CFF999999It's just heavy, nothing special.|R").append(8,1,3);
                thistype.create(ITID_HELM_OF_VALOR,"|CFF11FF11Helm of Valor|R","").append(4,3,5).append(13,3,5);
                thistype.create(ITID_MEDALION_OF_COURAGE,"|CFF11FF11Medalion of Courage|R","").append(4,3,5).append(14,3,5);
                thistype.create(ITID_HOOD_OF_CUNNING,"|CFF11FF11Hood of Cunning|R","").append(13,3,5).append(14,3,5);
                thistype.create(ITID_CLAWS_OF_ATTACK,"|CFF11FF11Claws of Attack|R","").append(9,4,7);
                thistype.create(ITID_GLOVES_OF_HASTE,"|CFF11FF11Gloves of Haste|R","").append(12,4,7);
                thistype.create(ITID_SWORD_OF_ASSASSINATION,"|CFF11FF11Sword of Assassination|R","").append(11,0.02,0.04);
                thistype.create(ITID_VITALITY_PERIAPT,"|CFF11FF11Vitality Periapt|R","").append(21,80,120);
                thistype.create(ITID_RING_OF_PROTECTION,"|CFF11FF11Ring of Protection|R","").append(8,2,2);
                thistype.create(ITID_TALISMAN_OF_EVASION,"|CFF11FF11Talisman of Evasion|R","").append(27,0.02,0.03);
                thistype.create(ITID_MANA_PERIAPT,"|CFF11FF11Mana Periapt|R","").append(17,100,200);
                thistype.create(ITID_SOBI_MASK,"|CFF11FF11Sobi Mask|R","").append(72,3,5);
                thistype.create(ITID_STAFF_OF_THE_WITCH_DOCTOR,"|CFF11FF11Staff of the Witch Doctor|R","").append(18,6,16);
                thistype.create(ITID_HEALTH_STONE,"|CFF11FF11Health Stone|R","").append(73,3,5).append(31,400,800);
                thistype.create(ITID_MANA_STONE,"|CFF11FF11Mana Stone|R","").append(72,2,4).append(30,200,400);
                thistype.create(ITID_ROMULOS_EXPIRED_POISON,"|CFF11FF11Romulo's Expired Poison|R","|CFF999999Still usable.|R").append(53,80,115);
                thistype.create(ITID_MOROES_LUCKY_GEAR,"|CFF11FF11Moroes' Lucky Gear|R","|CFF999999Disassembled from Moroes' Lucky Pocket Watch|R").append(27,0.01,0.02).append(35,4,7);
                thistype.create(ITID_RUNED_BELT,"|CFF11FF11Runed Belt|R","|CFF999999Was a bracelet of an ogre.|R").append(21,60,90).append(2,0.03,0.07);
                thistype.create(ITID_UNGLAZED_ICON_OF_THE_CRESCENT,"|CFF11FF11Unglazed Icon of the Crescent|R","|CFF999999It can be seen vaguely that this icon was once beautiful silver.|R").append(14,8,10).append(33,12,18);

                thistype.create(ITID_COLOSSUS_BLADE,"|CFF11FF11Colossus Blade|R","|CFF999999A rough sword, the workmanship is not very good. But it's the most popular production weapons in Harrogath.|R").append(9,25,40).append(12,12,18);
                thistype.create(ITID_THE_X_RING,"|CFF8B66FFThe X Ring|R","|CFF999999All the former 20 are trash!|R").append(7,9,12);
                thistype.create(ITID_GOBLIN_ROCKET_BOOTS_LIMITED_EDITION,"|CFF8B66FFGoblin Rocket Boots Limited Edition|R","|CFF999999Limited edition, but it's a goblin product after all. So use it with caution.|R").append(21,100,140).append(17,75,100).append(27,0.01,0.02).append(24,15,20).append(36,8,12);
                thistype.create(ITID_WARSONG_BATTLE_DRUMS,"|CFF8B66FFWarsong Battle Drums|R","|CFF999999High morale.|R").append(12,1,3).append(56,0.01,0.02).append(84,0.01,0.02);
                thistype.create(ITID_TROLL_BANE,"|CFF8B66FFTroll Bane|R","|CFFFFDEAD\"You know this blade...\"|R").append(4,5,8).append(13,8,12).append(9,10,20);
                thistype.create(ITID_GOREHOWL,"|CFF8B66FFGorehowl|R","|CFFFFDEAD\"The axe of Grom Hellscream has sown terror across hundreds of battlefields.\"|R").append(4,10,13).append(9,10,15).append(11,0.03,0.05);
                thistype.create(ITID_CORE_HOUND_TOOTH,"|CFF8B66FFCore Hound Tooth|R","").append(21,50,75).append(9,15,22).append(12,5,7).append(11,0.02,0.04);
                thistype.create(ITID_VISKAG,"|CFF8B66FFVis'kag|R","|CFFFFDEAD\"The blood letter\"|R").append(13,8,12).append(9,12,18).append(12,7,12).append(44,0.04,0.05);
                thistype.create(ITID_LION_HORN,"|CFF8B66FFLion Horn|R","|CFF999999Much better than Dragonspine Trophy.|R").append(9,12,15).append(3,0.01,0.02).append(48,0.05,0.07);
                thistype.create(ITID_ARMOR_OF_THE_DAMNED,"|CFF8B66FFArmor of the Damned|R","|CFFFFDEAD\"Slow, Curse, Weakness, Misfortune\"|R").append(8,2,3).append(4,8,12).append(15,20,45).append(74,4,8).append(41,50,75);
                thistype.create(ITID_BULWARK_OF_THE_AMANI_EMPIRE,"|CFF8B66FFBulwark of the Amani Empire|R","|CFF999999It still seems to linger with the resentment of the first guardian warrior of the Brothers' Guild.|R").append(8,1,2).append(4,5,7).append(21,150,240).append(15,14,28);
                thistype.create(ITID_SIGNET_OF_THE_LAST_DEFENDER,"|CFF8B66FFSignet of the Last Defender|R","|CFF999999The signet originally belongs to a demon lord and was later stolen by an orc thief.|R").append(8,1,2).append(4,7,9).append(27,0.01,0.01).append(6,0.03,0.06);
                thistype.create(ITID_ARANS_SOOTHING_EMERALD,"|CFF8B66FFAran's Soothing Emerald|R","|CFF999999Aran had made all kinds of precious stones into soothing gems. It should be a sapphire that adventurers are most familiar with.|R").append(14,5,8).append(18,10,15).append(19,2,4).append(72,2,4);
                thistype.create(ITID_PURE_ARCANE,"|CFF8B66FFPure Arcane|R","|CFF999999Megatorque despises this, he thinks \"One simple capacitor can achieve this effect\".|R").append(77,170,220);
                thistype.create(ITID_HEX_SHRUNKEN_HEAD,"|CFF8B66FFHex Shrunken Head|R","|CFF999999The Hex Lord is now strong enough to no longer need such trinkets.|R").append(14,8,12).append(18,10,15).append(34,35,64);
                thistype.create(ITID_STAFF_OF_THE_SHADOW_FLAME,"|CFF8B66FFStaff of the Shadow Flame|R","|CFFFFDEADThe dark flame at the end of the staff is so pure and contains tremendous energy.|R").append(14,5,8).append(18,10,21).append(20,0.04,0.05);
                thistype.create(ITID_TIDAL_LOOP,"|CFF8B66FFTidal Loop|R","|CFF999999The ring was crafted to fight against the Lord of Fire's legion. But now its ability of fire resistance has lost.|R").append(4,7,10).append(14,8,12).append(72,3,5).append(87,60,90);
                thistype.create(ITID_ORB_OF_THE_SINDOREI,"|CFF8B66FFOrb of the Sin'dorei|R","|CFFFFDEADThe glory sign of remarkable bloodelf defenders.|R").append(4,5,7).append(21,60,80).append(18,14,20).append(16,0.04,0.06).append(86,0.03,0.07);
                thistype.create(ITID_REFORGED_BADGE_OF_TENACITY,"|CFF8B66FFReforged Badge of Tenacity|R","|CFFFFDEADOriginally forged by a demon overseer named Shartuul.|R").append(13,5,7).append(8,3,4).append(21,80,120).append(27,0.02,0.04).append(78,0.08,0.1).append(92,3,7);
                thistype.create(ITID_LIGHTS_JUSTICE,"|CFF8B66FFLight's Justice|R","|CFFFFDEADOpen your heart to the light.|R").append(14,5,6).append(18,10,20).append(20,0.03,0.04).append(79,0,0).append(91,0,0);
                thistype.create(ITID_BENEDICTION,"|CFF8B66FFBenediction|R","|CFFFFDEADBehind the light, it's shadow.|R").append(14,6,8).append(21,60,75).append(18,8,16).append(72,3,6).append(76,4,6).append(80,0,0);
                thistype.create(ITID_HORN_OF_CENARIUS,"|CFF8B66FFHorn of Cenarius|R","|CFFFFDEADThis Night Elf artifact is said to be able to summon the souls of all night elves.|R").append(7,4,5).append(21,50,80).append(17,80,130).append(18,10,14).append(69,3,4);
                thistype.create(ITID_BANNER_OF_THE_HORDE,"|CFF8B66FFBanner of the Horde|R","|CFFFFDEADWith the tribal glory, the head of the enemies were left behind.|R").append(4,6,8).append(13,6,8).append(9,10,12).append(11,0.03,0.04).append(39,0.4,0.6);
                thistype.create(ITID_KELENS_DAGGER_OF_ASSASSINATION,"|CFF8B66FFKelen's Dagger of Assassination|R","|CFFFFDEADKelen is not just a master escaper.|R").append(13,7,8).append(9,12,16).append(12,7,9).append(66,0,0).append(65,0.04,0.06).append(90,0.05,0.06);
                thistype.create(ITID_RHOKDELAR,"|CFF8B66FFRhok'delar|R","|CFFFFDEADLongbow of the Ancient Keepers|R").append(13,5,8).append(9,11,13).append(11,3,5).append(24,10,20).append(94,1,1);
                thistype.create(ITID_RAGE_WINTERCHILLS_PHYLACTERY,"|CFF8B66FFRage Winterchill's Phylactery|R","|CFFFFDEADFor some people, the value of his phylactery is greater than the Chronicle of Dark Secrets.|R").append(14,5,8).append(21,70,90).append(20,0.02,0.03).append(96,0.03,0.04).append(70,0.01,0.02);
                thistype.create(ITID_ANATHEMA,"|CFF8B66FFAnathema|R","|CFFFFDEADBefore the shadows, it's light.|R").append(21,90,150).append(18,10,15).append(19,0.02,0.03).append(20,0.02,0.03).append(81,2,3);
                thistype.create(ITID_RARE_SHIMMER_WEED,"|CFF8B66FFRare Shimmer Weed|R","|CFFFFDEADGathered from Thunder Mountain, this shimmer weed seems to have real thunder energy.|R").append(7,3,4).append(18,10,12).append(12,5,6).append(19,0.02,0.04).append(93,0.09,0.11);

                thistype.create(ITID_CALL_TO_ARMS,"|CFFFF8C00Call To Arms|R","|CFFFFCC00Lore|R|N|CFFFFDEADWhen Zakarum was exiled, he led a mercenary team. It is this very battle axe and his Holy Shield that lead his brothers through the bodies of countless enemies.|R").append(9,10,15).append(9,10,15).append(18,12,18).append(73,10,17).append(57,20,40).append(29,0.06,0.12).append(45,0.03,0.05);
                thistype.create(ITID_WOESTAVE,"|CFFFF8C00Woestave|R","|CFFFFDEAD\"Cause of the great plague.\"|R").append(9,7,21).append(63,0.01,0.03).append(62,0.02,0.04).append(61,1,2).append(60,0.03,0.04).append(64,0.01,0.01).append(59,0.11,0.17);
                thistype.create(ITID_ENIGMA,"|CFFFF8C00Enigma|R","|CFFFFCC00Lore|R|N|CFFFFDEADNot recorded.|R").append(1,0.01,0.02).append(3,0.01,0.02).append(24,12,20).append(IATTR_STR,8,13).append(40,0.01,0.02).append(28,0,0);
                thistype.create(ITID_BREATH_OF_THE_DYING,"|CFFFF8C00Breath of the Dying|R","|CFFFFCC00Lore|R|N|CFFFFDEADThe master piece by Griswold the Undead. On the unglazed handle six obscure runes glow: Vex-Hel-El-Eld-Zod-Eth.|R").append(7,4,6).append(9,18,22).append(12,6,9).append(45,0.03,0.04).append(50,18,23);
                thistype.create(ITID_WINDFORCE,"|CFFFF8C00Windforce|R","|CFFFFDEAD\"The wind carries life for those enveloped in its flow, and death for those arrayed against it.\"|R").append(13,8,12).append(9,11,16).append(12,6,8).append(11,0.02,0.03).append(47,0.05,0.1);
                thistype.create(ITID_DERANGEMENT_OF_CTHUN,"|CFFFF8C00Derangement of C'Thun|R","|CFFFFCC00Lore|R|N|CFFFFDEADAlthough the main body of the Old God C'Thun was eliminated, the faceless one formed by his degraded tentacles was everywhere in the abyss of the earth.|R").append(4,7,10).append(9,17,24).append(11,0.01,0.02).append(74,3,30).append(44,0.03,0.06).append(46,0.04,0.06).append(37,0.05,0.5);
                thistype.create(ITID_MIGHT_OF_THE_ANGEL_OF_JUSTICE,"|CFFFF8C00Might of the Angel of Justice|R","|CFFFFCC00Lore|R|N|CFFFFDEADThe armor used by Tyrael, the Archangel of Wisdom when he was once the incarnation of justice.|R").append(4,5,7).append(8,2,3).append(1,0.01,0.02).append(2,0.01,0.03).append(24,12,15).append(42,2,5).append(38,25,35);
                thistype.create(ITID_INFINITY,"|CFFFF8C00Infinity|R","|CFFFFCC00Lore|R|N|CFFFFDEADInfinity is the essence of the Will o'wisps. The energy of lightning contained in it excites the prophet Drexel. It is said that the soul of the bleak soul with a green cloud-like halo is a nightmare for all adventurers.|R").append(14,4,6).append(21,70,166).append(18,8,12).append(82,0.01,0.02).append(89,60,75);
                thistype.create(ITID_INSIGHT,"|CFFFF8C00Insight|R","|CFFFFCC00Lore|R|N|CFFFFDEADIn the fight against the forest trolls, the Blood Elf Rangers used this enchanted orb from Kirin Tor and eventually succeeded in establishing Quel'Thalas.|R").append(14,3,4).append(9,3,5).append(18,10,17).append(19,0.03,0.06).append(57,17,30).append(68,0,0).append(83,2,4);
                thistype.create(ITID_VOODOO_VIALS,"|CFFFF8C00Voodoo Vials|R","|CFFFFCC00Lore|R|N|CFFFFDEADZanzil \"makes\" friends by these small vials.|R").append(14,3,5).append(17,83,110).append(20,0.01,0.01).append(19,0.01,0.02).append(88,12,20).append(32,15,30);
                thistype.create(ITID_HOLY_MOONLIGHT_SWORD,"|CFFFF8C00Holy Moonlight Sword|R","|CFFFFDEAD\"Ludwig the Holy Blade\"|R").append(4,4,6).append(21,75,100).append(57,11,19).append(43,0.03,0.04).append(75,75,100).append(49,60,80);
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
            thistype.put(SUFIX_LETHALITY, 1, 2, IATTR_CRIT, 0.01, 0.03, " of Lethality");
            thistype.put(SUFIX_SNAKE, 1, 2, IATTR_SCRIT, 0.01, 0.03, " of Snake");
            thistype.put(SUFIX_QUICKNESS, 1, 2, IATTR_IAS, 5, 10, " of Quickness");
            thistype.put(SUFIX_WIND_SERPENT, 1, 2, IATTR_SHASTE, 0.04, 0.08, " of Wind Serpent");
            thistype.put(SUFIX_BRUTE, 1, 2, IATTR_STR, 6, 12, " of Brute");
            thistype.put(SUFIX_DEXTERITY, 1, 2, IATTR_AGI, 6, 12, " of Dexterity");
            thistype.put(SUFIX_WISDOM, 1, 2, IATTR_INT, 6, 12, " of Wisdom");
            thistype.put(SUFIX_VITALITY, 1, 2, IATTR_HP, 90, 180, " of Vitality");
            thistype.put(SUFIX_CHAMPION, 1, 2, IATTR_STR, 5, 7, " of Champion").addAttribute(IATTR_AP, 8, 11);
            thistype.put(SUFIX_BUTCHER, 1, 2, IATTR_STR, 5, 7, " of Butcher").addAttribute(IATTR_CRIT, 0.01, 0.02);
            thistype.put(SUFIX_ASSASSIN, 1, 2, IATTR_AGI, 5, 7, " of Assassin").addAttribute(IATTR_CRIT, 0.01, 0.02);
            thistype.put(SUFIX_RANGER, 1, 2, IATTR_AGI, 5, 7, " of Ranger").addAttribute(IATTR_AP, 8, 11);
            thistype.put(SUFIX_WIZARD, 1, 2, IATTR_INT, 5, 7, " of Wizard").addAttribute(IATTR_SHASTE, 0.02, 0.04);
            thistype.put(SUFIX_PRIEST, 1, 2, IATTR_INT, 5, 7, " of Priest").addAttribute(IATTR_MREG, 2, 3);
            thistype.put(SUFIX_GUARDIAN, 1, 2, IATTR_HP, 70, 100, " of Guardian").addAttribute(IATTR_DODGE, 0.01, 0.02);
            thistype.put(SUFIX_MASTERY, 1, 2, IATTR_LP, 1, 3, " of Mastery");
            thistype.put(SUFIX_BLUR, 1, 2, IATTR_DODGE, 0.01, 0.03, " of Blur");
            thistype.put(SUFIX_STRONGHOLD, 1, 2, IATTR_DEF, 5, 10, " of Stronghold");
            thistype.put(SUFIX_DEEP_SEA, 1, 2, IATTR_MREG, 3, 6, " of Deep Sea");
            thistype.put(SUFIX_VOID, 1, 2, IATTR_SP, 12, 24, " of Void");
            thistype.put(PREFIX_HEAVY, 1, 1, IATTR_STR, 4, 6, "Heavy ");
            thistype.put(PREFIX_STRONG, 2, 1, IATTR_STR, 7, 10, "Strong ");
            thistype.put(PREFIX_SHARP, 1, 1, IATTR_AGI, 4, 6, "Sharp ");
            thistype.put(PREFIX_AGILE, 2, 1, IATTR_AGI, 7, 10, "Agile ");
            thistype.put(PREFIX_SHIMERING, 1, 1, IATTR_INT, 4, 6, "Shimering ");
            thistype.put(PREFIX_INTELLIGENT, 2, 1, IATTR_INT, 7, 10, "Intelligent ");
            thistype.put(PREFIX_ENDURABLE, 1, 1, IATTR_HP, 60, 90, "Endurable ");
            thistype.put(PREFIX_VIBRANT, 2, 1, IATTR_HP, 91, 150, "Vibrant ");
            thistype.put(PREFIX_SKILLED, 1, 1, IATTR_AP, 7, 11, "Skilled ");
            thistype.put(PREFIX_CRUEL, 2, 1, IATTR_AP, 12, 18, "Cruel ");
            thistype.put(PREFIX_ENCHANTED, 1, 1, IATTR_SP, 8, 12, "Enchanted ");
            thistype.put(PREFIX_SORCEROUS, 2, 1, IATTR_SP, 13, 20, "Sorcerous ");
            thistype.put(PREFIX_MYSTERIOUS, 1, 1, IATTR_MREG, 2, 3, "Mysterious ");
            thistype.put(PREFIX_ETERNAL, 2, 1, IATTR_MREG, 4, 5, "Eternal ");
            thistype.put(PREFIX_STEADY, 1, 1, IATTR_DEF, 3, 5, "Steady ");
            thistype.put(PREFIX_TOUGH, 2, 1, IATTR_DEF, 6, 8, "Tough ");
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
        static method callbackCRKILLER(unit u, real val, integer polar) {}
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
        static method callbackATK_MOONWAVE(unit u, real val, integer polar) {}
        static method callbackATK_POISNOVA(unit u, real val, integer polar) {
            EquipedBOTD(u, polar);
        }
        static method callbackATK_COIL(unit u, real val, integer polar) {}
        static method callbackATK_BLEED(unit u, real val, integer polar) {}
        static method callbackATK_MDC(unit u, real val, integer polar) {
            EquipedChanceMagicDamage(u, polar);
        }
        static method callbackATK_STUN(unit u, real val, integer polar) {}
        static method callbackATK_CRIT(unit u, real val, integer polar) {}
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
        static method callback3ATK_MOONEXP(unit u, real val, integer polar) {}
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
            thistype.put(IATTR_ATK_CRIT,2,412,0.2,"|cff33ff33On Attack: 5% chance to increase "," attack critical chance, lasts for 5 seconds|r",thistype.callbackATK_CRIT);
            thistype.put(IATTR_ATK_AMP,2,413,0.1,"|cff33ff33On Attack: Target takes "," extra damage|r",thistype.callbackATK_AMP);
            thistype.put(IATTR_ATK_MORTAL,2,416,0.1,"|cff33ff33On Attack: Decrease target healing taken by ","|r",thistype.callbackATK_MORTAL);
            thistype.put(IATTR_ATK_MISS,2,417,0.1,"|cff33ff33On Attack: Decrease target attack hit chance by ","|r",thistype.callbackATK_MISS);
            thistype.put(IATTR_ATK_DDEF,2,418,0.1,"|cff33ff33On Attack: Decrease target armor by ","|r",thistype.callbackATK_DDEF);
            thistype.put(IATTR_ATK_DAS,2,419,0.1,"|cff33ff33On Attack: Decrease target attack speed by ","|r",thistype.callbackATK_DAS);
            thistype.put(IATTR_ATK_DMS,2,420,0.1,"|cff33ff33On Attack: Decrease target movement speed by ","|r",thistype.callbackATK_DMS);
            thistype.put(IATTR_ATK_WEAK,2,421,0.1,"|cff33ff33On Attack: Decrease target damage and healing dealt by ","|r",thistype.callbackATK_WEAK);
            thistype.put(IATTR_3ATK_MOONEXP,2,430,0.7,"|cff33ff33Every Third Attack: Consumes 5% of max MP, deals "," magic damage to all enemies nearby|r",thistype.callback3ATK_MOONEXP);
            thistype.put(IATTR_MD_MREGEN,2,450,0.5,"|cff33ff33Dealing Magic Damage: 1% chance to regen "," MP|r",thistype.callbackMD_MREGEN);
            thistype.put(IATTR_MD_POISON,2,451,0.7,"|cff33ff33Dealing Magic Damage: 10% chance to poison target, dealing "," magic damage over time|r",thistype.callbackMD_POISON);
            thistype.put(IATTR_MD_CHAIN,2,452,0.7,"|cff33ff33Dealing Magic Damage: 10% chance to cast Chain Lightning to target, dealing "," magic damage|r",thistype.callbackMD_CHAIN);
            thistype.put(IATTR_MDC_ARCANE,2,460,0.5,"|cff33ff33Magic Damage Critical: Charges with arcane power. All arcane power will be released automatically after 3 stacks, dealing "," magic damage to target|r",thistype.callbackMDC_ARCANE);
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
        // stack charges
        if (GetItemLevel(it) < 2) {
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
