//! zinc
library ItemAttributes requires UnitProperty, Table {
    public type ItemPropModType extends function(unit, item, integer);
    public type ItemAttributeCallback extends function(unit, real, integer);
    //public HandleTable itemInst;
    Table ItemAttributes;

    struct DefaultItemAttributesData {
        static Table ht;
        thistype next;
        integer id;
        real lo, hi;
        string name;
        string loreText;

        static method create(integer id, real lo, real hi) -> thistype {
            thistype this = thistype.allocate();
            this.id = id;
            this.lo = lo;
            this.hi = hi;
            this.name = "";
            this.loreText = "";
            this.next = 0;
            return this;
        }

        static method inst(integer itid, string trace) -> thistype {
            if (thistype.ht.exists(itid)) {
                return thistype.ht[itid];
            } else {
                print("Unknown ITID: " + ID2S(itid) + ", trace: " + trace);
                return 0;
            }
        }

        static method setLoreText(integer itid, string name, string lore) {
            thistype this = thistype.inst(itid, "setLoretext");
            this.name = name;
            this.loreText = lore;
        }

        static method append(integer itid, integer id, real lo, real hi) {
            thistype data = thistype.create(id, lo, hi);
            thistype index;
            if (thistype.ht.exists(itid)) {
                index = thistype.ht[itid];
                while (index.next != 0) {
                    index = index.next;
                }
                index.next = data;
            } else {
                thistype.ht[itid] = data;
            }
        }

        static method onInit() {
            thistype.ht = Table.create();
            thistype.append(ITID_CALL_TO_ARMS,9,10,15);
            thistype.append(ITID_CALL_TO_ARMS,9,10,15);
            thistype.append(ITID_CALL_TO_ARMS,18,12,18);
            thistype.append(ITID_CALL_TO_ARMS,73,10,17);
            thistype.append(ITID_CALL_TO_ARMS,57,20,40);
            thistype.append(ITID_CALL_TO_ARMS,45,0.03,0.05);
            thistype.append(ITID_CALL_TO_ARMS,29,0.06,0.12);


            thistype.setLoreText(ITID_CALL_TO_ARMS,"|CFFFF8C00Call To Arms|R","|CFFFFCC00Lore|R|N|CFFFFDEADWhen Zakarum was exiled, he led a mercenary team. It is this very battle axe and his Holy Shield that lead his brothers through the bodies of countless enemies.|R");

            thistype.append(ITID_WOESTAVE,9,15,45);
            thistype.append(ITID_WOESTAVE,63,40,50);
            thistype.append(ITID_WOESTAVE,62,12,15);
            thistype.append(ITID_WOESTAVE,61,1,2);
            thistype.append(ITID_WOESTAVE,60,0.03,0.04);
            thistype.append(ITID_WOESTAVE,64,0.01,0.01);
            thistype.append(ITID_WOESTAVE,59,0.11,0.17);

            thistype.setLoreText(ITID_WOESTAVE,"|CFFFF8C00Woestave|R","|CFFFFDEAD\"Cause of the great plague.\"|R");

            thistype.append(ITID_ENIGMA,1,0.01,0.02);
            thistype.append(ITID_ENIGMA,3,0.01,0.02);
            thistype.append(ITID_ENIGMA,24,12,20);
            thistype.append(ITID_ENIGMA,5,2,3);
            thistype.append(ITID_ENIGMA,22,0.01,0.02);
            thistype.append(ITID_ENIGMA,40,0.01,0.02);
            thistype.append(ITID_ENIGMA,28,0,0);


            thistype.setLoreText(ITID_ENIGMA,"|CFFFF8C00Enigma|R","|CFFFFCC00Lore|R|N|CFFFFDEADNot recorded.|R");

            thistype.append(ITID_BREATH_OF_THE_DYING,7,4,6);
            thistype.append(ITID_BREATH_OF_THE_DYING,9,18,22);
            thistype.append(ITID_BREATH_OF_THE_DYING,12,6,9);
            thistype.append(ITID_BREATH_OF_THE_DYING,45,0.03,0.04);
            thistype.append(ITID_BREATH_OF_THE_DYING,50,18,23);


            thistype.setLoreText(ITID_BREATH_OF_THE_DYING,"|CFFFF8C00Breath of the Dying|R","|CFFFFCC00Lore|R|N|CFFFFDEADThe master piece by Griswold the Undead. On the unglazed handle six obscure runes glow: Vex-Hel-El-Eld-Zod-Eth.|R");

            thistype.append(ITID_WINDFORCE,13,8,12);
            thistype.append(ITID_WINDFORCE,9,11,16);
            thistype.append(ITID_WINDFORCE,12,6,8);
            thistype.append(ITID_WINDFORCE,11,0.02,0.03);
            thistype.append(ITID_WINDFORCE,47,0.05,0.1);

            thistype.setLoreText(ITID_WINDFORCE,"|CFFFF8C00Windforce|R","|CFFFFDEAD\"The wind carries life for those enveloped in its flow, and death for those arrayed against it.\"|R");

            thistype.append(ITID_DERANGEMENT_OF_CTHUN,4,7,10);
            thistype.append(ITID_DERANGEMENT_OF_CTHUN,10,2,4);
            thistype.append(ITID_DERANGEMENT_OF_CTHUN,11,0.01,0.02);
            thistype.append(ITID_DERANGEMENT_OF_CTHUN,74,3,30);
            thistype.append(ITID_DERANGEMENT_OF_CTHUN,44,0.03,0.06);
            thistype.append(ITID_DERANGEMENT_OF_CTHUN,46,0.04,0.06);
            thistype.append(ITID_DERANGEMENT_OF_CTHUN,37,0.05,0.5);


            thistype.setLoreText(ITID_DERANGEMENT_OF_CTHUN,"|CFFFF8C00Derangement of C'Thun|R","|CFFFFCC00Lore|R|N|CFFFFDEADAlthough the main body of the Old God C'Thun was eliminated, the faceless one formed by his degraded tentacles was everywhere in the abyss of the earth.|R");

            thistype.append(ITID_MIGHT_OF_THE_ANGEL_OF_JUSTICE,4,5,7);
            thistype.append(ITID_MIGHT_OF_THE_ANGEL_OF_JUSTICE,8,2,3);
            thistype.append(ITID_MIGHT_OF_THE_ANGEL_OF_JUSTICE,1,0.01,0.02);
            thistype.append(ITID_MIGHT_OF_THE_ANGEL_OF_JUSTICE,2,0.01,0.03);
            thistype.append(ITID_MIGHT_OF_THE_ANGEL_OF_JUSTICE,24,12,15);
            thistype.append(ITID_MIGHT_OF_THE_ANGEL_OF_JUSTICE,42,0,0);
            thistype.append(ITID_MIGHT_OF_THE_ANGEL_OF_JUSTICE,38,25,35);


            thistype.setLoreText(ITID_MIGHT_OF_THE_ANGEL_OF_JUSTICE,"|CFFFF8C00Might of the Angel of Justice|R","|CFFFFCC00Lore|R|N|CFFFFDEADThe armor used by Tyrael, the Archangel of Wisdom when he was once the incarnation of justice.|R");

            thistype.append(ITID_INFINITY,14,4,6);
            thistype.append(ITID_INFINITY,23,30,43);
            thistype.append(ITID_INFINITY,18,8,12);
            thistype.append(ITID_INFINITY,82,0.01,0.02);
            thistype.append(ITID_INFINITY,89,60,75);


            thistype.setLoreText(ITID_INFINITY,"|CFFFF8C00Infinity|R","|CFFFFCC00Lore|R|N|CFFFFDEADInfinity is the essence of the Will o'wisps. The energy of lightning contained in it excites the prophet Drexel. It is said that the soul of the bleak soul with a green cloud-like halo is a nightmare for all adventurers.|R");

            thistype.append(ITID_INSIGHT,14,3,4);
            thistype.append(ITID_INSIGHT,9,3,5);
            thistype.append(ITID_INSIGHT,18,10,17);
            thistype.append(ITID_INSIGHT,19,0.03,0.06);
            thistype.append(ITID_INSIGHT,57,17,30);
            thistype.append(ITID_INSIGHT,68,0,0);
            thistype.append(ITID_INSIGHT,83,2,4);


            thistype.setLoreText(ITID_INSIGHT,"|CFFFF8C00Insight|R","|CFFFFCC00Lore|R|N|CFFFFDEADIn the fight against the forest trolls, the Blood Elf Rangers used this enchanted orb from Kirin Tor and eventually succeeded in establishing Quel'Thalas.|R");

            thistype.append(ITID_VOODOO_VIALS,14,3,5);
            thistype.append(ITID_VOODOO_VIALS,17,83,110);
            thistype.append(ITID_VOODOO_VIALS,20,0.01,0.01);
            thistype.append(ITID_VOODOO_VIALS,19,0.01,0.02);
            thistype.append(ITID_VOODOO_VIALS,88,12,20);
            thistype.append(ITID_VOODOO_VIALS,32,15,30);


            thistype.setLoreText(ITID_VOODOO_VIALS,"|CFFFF8C00Voodoo Vials|R","|CFFFFCC00Lore|R|N|CFFFFDEADZanzil \"makes\" friends by these small vials.|R");

            thistype.append(ITID_HOLY_MOONLIGHT_SWORD,4,4,6);
            thistype.append(ITID_HOLY_MOONLIGHT_SWORD,21,75,100);
            thistype.append(ITID_HOLY_MOONLIGHT_SWORD,57,11,19);
            thistype.append(ITID_HOLY_MOONLIGHT_SWORD,43,0.03,0.04);
            thistype.append(ITID_HOLY_MOONLIGHT_SWORD,75,75,100);
            thistype.append(ITID_HOLY_MOONLIGHT_SWORD,49,60,80);

            thistype.setLoreText(ITID_HOLY_MOONLIGHT_SWORD,"|CFFFF8C00Holy Moonlight Sword|R","|CFFFFDEAD\"Ludwig the Holy Blade\"|R");

        }
    }

    public struct ItemExAttributes {
        static HandleTable ht;
        integer id;
        real value;
        thistype next;

        static method inst(item it, string trace) -> thistype {
            if (thistype.ht.exists(it)) {
                return thistype.ht[it];
            } else {
                print("Unknown item: " + ID2S(GetItemTypeId(it)) + ", trace: " + trace);
                return 0;
            }
        }

        static method create(DefaultItemAttributesData raw) -> thistype {
            thistype this = thistype.allocate();
            this.id = raw.id;
            this.value = GetRandomReal(raw.lo, raw.hi);
            this.next = 0;
            return this;
        }

        static method updateUbertip(item it) {
            thistype head;
            string str = "";
            string valstr;
            ItemAttributeMeta meta;
            DefaultItemAttributesData raw;
            if (thistype.ht.exists(it)) {
                head = thistype.ht[it];
                while (head != 0) {
                    meta = ItemAttributeMeta.inst(head.id, "ItemExAttributes.updateUbertip.meta");
                    if (head.value < 1) {
                        valstr = I2S(Rounding(head.value * 100)) + "%";
                    } else {
                        valstr = I2S(Rounding(head.value));
                    }
                    str = str + meta.str1 + valstr + meta.str2;
                    if (head.next != 0) {
                        str = str + "|N";
                    }
                    head = head.next;
                }
                raw = DefaultItemAttributesData.inst(GetItemTypeId(it), "updateUberTip");
                print(str);
                BlzSetItemExtendedTooltip(it, str);
                BlzSetItemName(it, raw.name);
            } else {
                print("ItemExAttributes.updateUbertip no such item " + ID2S(GetItemTypeId(it)));
            }
        }

        static method instantiate(item it) {
            DefaultItemAttributesData raw = DefaultItemAttributesData.inst(GetItemTypeId(it), "ItemExAttributes.intantiate");
            thistype data;
            thistype head, index;
            boolean found;
            ItemAttributeMeta metaIndex, metaData;
            if (raw == 0) {
                print("Raw data does not exist ItemExAttributes 73");
            } else {
                head = thistype.create(raw);
                thistype.ht[it] = head;
                raw = raw.next;
                while (raw != 0) {
                    data = thistype.create(raw);
                    // insert
                    index = head;
                    found = false;
                    while (index.next != 0 && found == false) {
                        metaIndex = ItemAttributeMeta.inst(index.id, "ItemExAttributes.intantiate.metaIndex");
                        metaData = ItemAttributeMeta.inst(data.id, "ItemExAttributes.intantiate.metaData");
                        if (metaIndex.sort < metaData.sort) {
                            index = index.next;
                        } else {
                            found = true;
                        }
                    }
                    if (index.next != 0) {
                        data.next = index.next;
                    }
                    index.next = data;
                    raw = raw.next;
                }
                thistype.updateUbertip(it);
            }
        }

        static method onInit() {
            thistype.ht = HandleTable.create();
        }
    }
    
    public function RegisterItemPropMod(integer itid, ItemPropModType act) {
        if (ItemAttributes.exists(itid)) {
            BJDebugMsg(SCOPE_PREFIX+":>|cffff0000Double registering item property action.|r");
        } else {
            ItemAttributes[itid] = act;
        }
    }

    function ItemAffixEffect(unit u, item it, integer polar) {
        ItemAffix data = ItemAffix.inst(it, "ItemAttributes.ItemAffixEffect");
        UnitProp up = UnitProp.inst(u, SCOPE_PREFIX);
        integer i;
        while (data != 0) {
            i = 0;
            while (i < data.attributeN) {
                if (data.attribute[i] == AFFIX_TYPE_STR) {
                    up.ModStr(Rounding(data.value[i]) * polar);
                } else if (data.attribute[i] == AFFIX_TYPE_AGI) {
                    up.ModAgi(Rounding(data.value[i]) * polar);
                } else if (data.attribute[i] == AFFIX_TYPE_INT) {
                    up.ModInt(Rounding(data.value[i]) * polar);
                } else if (data.attribute[i] == AFFIX_TYPE_HP) {
                    up.ModLife(Rounding(data.value[i]) * polar);
                } else if (data.attribute[i] == AFFIX_TYPE_AP) {
                    up.ModAP(Rounding(data.value[i]) * polar);
                } else if (data.attribute[i] == AFFIX_TYPE_CRIT) {
                    up.attackCrit += data.value[i] * polar;
                } else if (data.attribute[i] == AFFIX_TYPE_IAS) {
                    up.ModAttackSpeed(Rounding(data.value[i]) * polar);
                } else if (data.attribute[i] == AFFIX_TYPE_SP) {
                    up.spellPower += (data.value[i] * polar);
                } else if (data.attribute[i] == AFFIX_TYPE_SCRIT) {
                    up.spellCrit += (data.value[i] * polar);
                } else if (data.attribute[i] == AFFIX_TYPE_SHASTE) {
                    up.spellHaste += (data.value[i] * polar);
                } else if (data.attribute[i] == AFFIX_TYPE_MREGEN) {
                    up.manaRegen += (data.value[i] * polar);
                } else if (data.attribute[i] == AFFIX_TYPE_DEF) {
                    up.ModArmor(Rounding(data.value[i]) * polar);
                } else if (data.attribute[i] == AFFIX_TYPE_DODGE) {
                    up.dodge += (data.value[i] * polar);
                }
                i += 1;
            }
            data = data.next;
        }
    }

    function itemon() -> boolean {
        item it = GetManipulatedItem();
        integer itid = GetItemTypeId(it);
        integer i;
        item tmpi;
        unit u = GetTriggerUnit();
        ItemExAttributes attr;
        ItemAttributeMeta meta;
        attr = ItemExAttributes.inst(it, "item on");
        while (attr != 0) {
            meta = ItemAttributeMeta.inst(attr.id, "item on");
            if (meta != 0) {
                meta.callback.evaluate(u, attr.value, 1);
            }
            attr = attr.next;
        }
        if (ItemAttributes.exists(itid)) {
            // ItemPropModType(ItemAttributes[itid]).evaluate(u, it, 1);
            // ItemAffixEffect(u, it, 1);
            //if (!itemInst.exists())
        }
        // stack charges
        if (IsItemTypeConsumable(itid)) {
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
        u = null;
        it = null;
        return false;
    }
    
    function itemoff() -> boolean {
        // integer itid = GetItemTypeId(GetManipulatedItem());
        ItemExAttributes attr;
        ItemAttributeMeta meta;
        attr = ItemExAttributes.inst(GetManipulatedItem(), "itemoff");
        while (attr != 0) {
            meta = ItemAttributeMeta.inst(attr.id, "item off");
            if (meta != 0) {
                meta.callback.evaluate(GetTriggerUnit(), attr.value, -1);
            }
            attr = attr.next;
        }
        // if (ItemAttributes.exists(itid)) {
        //     ItemPropModType(ItemAttributes[itid]).evaluate(GetTriggerUnit(), GetManipulatedItem(), -1);
        //     ItemAffixEffect(GetTriggerUnit(), GetManipulatedItem(), -1);
        // }
        return false;
    }

    struct ItemAttributeMeta {
        static Table ht;
        integer sort;
        string str1, str2;
        ItemAttributeCallback callback;

        static method inst(integer id, string trace) -> thistype {
            if (thistype.ht.exists(id)) {
                return thistype.ht[id];
            } else {
                print("ItemAttributeMeta.inst not found: " + ID2S(id) + ", trace: " + trace);
                return 0;
            }
        }

        static method create(integer id, integer sort, string str1, string str2, ItemAttributeCallback callback) -> thistype {
            thistype this = thistype.allocate();
            thistype.ht[id] = this;
            this.sort = sort;
            this.str1 = str1;
            this.str2 = str2;
            this.callback = callback;
            return this;
        }

        static method callback1(unit u, real val, integer polar) {}
        static method callback2(unit u, real val, integer polar) {}
        static method callback3(unit u, real val, integer polar) {}
        static method callback4(unit u, real val, integer polar) {}
        static method callback5(unit u, real val, integer polar) {}
        static method callback6(unit u, real val, integer polar) {}
        static method callback7(unit u, real val, integer polar) {
            UnitProp up = UnitProp.inst(u, "ItemAttributeMeta.callback7");
            up.ModStr(Rounding(val) * polar);
            up.ModAgi(Rounding(val) * polar);
            up.ModInt(Rounding(val) * polar);
        }
        static method callback8(unit u, real val, integer polar) {}
        static method callback9(unit u, real val, integer polar) {
            UnitProp up = UnitProp.inst(u, "ItemAttributeMeta.callback9");
            up.ModAP(Rounding(val) * polar);
        }
        static method callback10(unit u, real val, integer polar) {}
        static method callback11(unit u, real val, integer polar) {}
        static method callback12(unit u, real val, integer polar) {
            UnitProp up = UnitProp.inst(u, "ItemAttributeMeta.callback12");
            up.ModAttackSpeed(Rounding(val) * polar);
        }
        static method callback13(unit u, real val, integer polar) {}
        static method callback14(unit u, real val, integer polar) {}
        static method callback15(unit u, real val, integer polar) {}
        static method callback16(unit u, real val, integer polar) {}
        static method callback17(unit u, real val, integer polar) {}
        static method callback18(unit u, real val, integer polar) {}
        static method callback19(unit u, real val, integer polar) {}
        static method callback20(unit u, real val, integer polar) {}
        static method callback21(unit u, real val, integer polar) {}
        static method callback22(unit u, real val, integer polar) {}
        static method callback23(unit u, real val, integer polar) {}
        static method callback24(unit u, real val, integer polar) {}
        static method callback25(unit u, real val, integer polar) {}
        static method callback26(unit u, real val, integer polar) {}
        static method callback27(unit u, real val, integer polar) {}
        static method callback28(unit u, real val, integer polar) {}
        static method callback29(unit u, real val, integer polar) {}
        static method callback30(unit u, real val, integer polar) {}
        static method callback31(unit u, real val, integer polar) {}
        static method callback32(unit u, real val, integer polar) {}
        static method callback33(unit u, real val, integer polar) {}
        static method callback34(unit u, real val, integer polar) {}
        static method callback35(unit u, real val, integer polar) {}
        static method callback36(unit u, real val, integer polar) {}
        static method callback37(unit u, real val, integer polar) {}
        static method callback38(unit u, real val, integer polar) {}
        static method callback39(unit u, real val, integer polar) {}
        static method callback40(unit u, real val, integer polar) {}
        static method callback41(unit u, real val, integer polar) {}
        static method callback42(unit u, real val, integer polar) {}
        static method callback43(unit u, real val, integer polar) {}
        static method callback44(unit u, real val, integer polar) {}
        static method callback45(unit u, real val, integer polar) {
            UnitProp up = UnitProp.inst(u, "ItemAttributeMeta.callback45");
            up.ll += val * polar;
        }
        static method callback46(unit u, real val, integer polar) {}
        static method callback47(unit u, real val, integer polar) {}
        static method callback48(unit u, real val, integer polar) {}
        static method callback49(unit u, real val, integer polar) {}
        static method callback50(unit u, real val, integer polar) {}
        static method callback51(unit u, real val, integer polar) {}
        static method callback52(unit u, real val, integer polar) {}
        static method callback53(unit u, real val, integer polar) {}
        static method callback54(unit u, real val, integer polar) {}
        static method callback55(unit u, real val, integer polar) {}
        static method callback56(unit u, real val, integer polar) {}
        static method callback57(unit u, real val, integer polar) {}
        static method callback58(unit u, real val, integer polar) {}
        static method callback59(unit u, real val, integer polar) {}
        static method callback60(unit u, real val, integer polar) {}
        static method callback61(unit u, real val, integer polar) {}
        static method callback62(unit u, real val, integer polar) {}
        static method callback63(unit u, real val, integer polar) {}
        static method callback64(unit u, real val, integer polar) {}
        static method callback65(unit u, real val, integer polar) {}
        static method callback66(unit u, real val, integer polar) {}
        static method callback67(unit u, real val, integer polar) {}
        static method callback68(unit u, real val, integer polar) {}
        static method callback69(unit u, real val, integer polar) {}
        static method callback70(unit u, real val, integer polar) {}
        static method callback71(unit u, real val, integer polar) {}
        static method callback72(unit u, real val, integer polar) {}
        static method callback73(unit u, real val, integer polar) {}
        static method callback74(unit u, real val, integer polar) {}
        static method callback75(unit u, real val, integer polar) {}
        static method callback76(unit u, real val, integer polar) {}
        static method callback77(unit u, real val, integer polar) {}
        static method callback78(unit u, real val, integer polar) {}
        static method callback79(unit u, real val, integer polar) {}
        static method callback80(unit u, real val, integer polar) {}
        static method callback81(unit u, real val, integer polar) {}
        static method callback82(unit u, real val, integer polar) {}
        static method callback83(unit u, real val, integer polar) {}
        static method callback84(unit u, real val, integer polar) {}
        static method callback85(unit u, real val, integer polar) {}
        static method callback86(unit u, real val, integer polar) {}
        static method callback87(unit u, real val, integer polar) {}
        static method callback88(unit u, real val, integer polar) {}
        static method callback89(unit u, real val, integer polar) {}
        static method callback90(unit u, real val, integer polar) {}
        static method callback91(unit u, real val, integer polar) {}
        static method callback92(unit u, real val, integer polar) {}
        static method callback93(unit u, real val, integer polar) {}
        static method callback94(unit u, real val, integer polar) {}
        static method callback95(unit u, real val, integer polar) {}
        static method callback96(unit u, real val, integer polar) {}

        static method onInit() {
            thistype.ht = Table.create();
            thistype.create(4,100,"+"," Strength", thistype.callback4);
            thistype.create(5,101,"+"," Strength/level", thistype.callback5);
            thistype.create(13,102,"+"," Agility", thistype.callback13);
            thistype.create(14,104,"+"," Intelligence", thistype.callback14);
            thistype.create(7,106,"+"," All stats", thistype.callback7);
            thistype.create(21,110,"+"," Max HP", thistype.callback21);
            thistype.create(22,111,"+"," Max HP", thistype.callback22);
            thistype.create(23,112,"+"," Max HP/level", thistype.callback23);
            thistype.create(17,114,"+"," Max MP", thistype.callback17);
            thistype.create(9,120,"+"," Attack power", thistype.callback9);
            thistype.create(10,121,"+"," Attack power/level", thistype.callback10);
            thistype.create(11,122,"+"," Attack critical", thistype.callback11);
            thistype.create(12,124,"+","% Attack speed", thistype.callback12);
            thistype.create(18,130,"+"," Spell power", thistype.callback18);
            thistype.create(20,132,"+"," Spell critical", thistype.callback20);
            thistype.create(19,134,"+"," Spell haste", thistype.callback19);
            thistype.create(8,140,"+"," Armor", thistype.callback8);
            thistype.create(95,141,"+"," Armor/level", thistype.callback95);
            thistype.create(16,142,"+"," Block chance", thistype.callback16);
            thistype.create(15,144,"+"," Block points", thistype.callback15);
            thistype.create(27,146,"+"," Dodge chance", thistype.callback27);
            thistype.create(1,150,"-"," All damage taken", thistype.callback1);
            thistype.create(2,152,"-"," Spell damage taken", thistype.callback2);
            thistype.create(3,154,"+"," Damage and healing dealt", thistype.callback3);
            thistype.create(6,156,"+"," Healing taken", thistype.callback6);
            thistype.create(72,160,"Regens "," MP per second", thistype.callback72);
            thistype.create(73,162,"Regens "," HP per second", thistype.callback73);
            thistype.create(74,164,"Lost "," HP per second during combat", thistype.callback74);
            thistype.create(24,170,"+"," Movement speed", thistype.callback24);
            thistype.create(25,171,"+"," Movement speed/level", thistype.callback25);
            thistype.create(26,180,"+"," Item special power level", thistype.callback26);
            thistype.create(39,200,"|CFF33FF33Regenerates "," more valor points|R", thistype.callback39);
            thistype.create(66,201,"|cff33ff33One-shot target when it's HP is less than yours|R","", thistype.callback66);
            thistype.create(65,202,"|CFF33FF33Deals "," extra damage to target below 30% max HP|R", thistype.callback65);
            thistype.create(67,203,"|CFF33FF33Deals "," extra damage to non-hero targets|R", thistype.callback67);
            thistype.create(68,204,"|cff33ff33Converts your normal attacks into magical damage|R","", thistype.callback68);
            thistype.create(69,205,"|CFF33FF33Reduce cooldown of Instant Regrowth by "," seconds|R", thistype.callback69);
            thistype.create(71,207,"|CFF33FF33Absorb "," HP from all enemies nearby every second|R", thistype.callback71);
            thistype.create(76,208,"|CFF33FF33Prayer of healing increases armor of target by ","|R", thistype.callback76);
            thistype.create(78,210,"|CFF33FF33Survival Instincts provides "," extra healing and max HP|R", thistype.callback78);
            thistype.create(79,211,"|cff33ff33Holy Shock always deals critical healing|R","", thistype.callback79);
            thistype.create(80,212,"|cff33ff33Removes weakness effect of Shield|R","", thistype.callback80);
            thistype.create(81,213,"|CFF33FF33Marrow Squeeze extends the Pain on target by "," seconds|R", thistype.callback81);
            thistype.create(86,214,"|CFF33FF33Shield of Sin'dorei provides "," extra damage reduction, and forces all nearby enemies to attack you|R", thistype.callback86);
            thistype.create(90,215,"|CFF33FF33Sinister Strike has a "," chance to paralyze target, reduce target spell haste by 20% and gain an extra combo point|R", thistype.callback90);
            thistype.create(91,216,"|cff33ff33Flash Light dispels one debuff from target|R","", thistype.callback91);
            thistype.create(92,217,"|CFF33FF33Reduce cooldown of Survival Instincts by "," seconds|R", thistype.callback92);
            thistype.create(93,218,"|CFF33FF33Storm Lash has "," extra chance to cooldown Earth Shock|R", thistype.callback93);
            thistype.create(94,219,"|CFF33FF33Number of Dark Arrows increased by ","|R", thistype.callback94);
            thistype.create(96,220,"|CFF33FF33Increase ice spell damage by ","|R", thistype.callback96);
            thistype.create(70,222,"|CFF33FF33"," chance to cast an instant Frost Bolt to targets damaged by Blizzard|R", thistype.callback70);
            thistype.create(43,400,"|CFF33FF33On Attack: "," mana steal|R", thistype.callback43);
            thistype.create(44,401,"|CFF33FF33On Attack: "," life steal|R", thistype.callback44);
            thistype.create(45,402,"|CFF33FF33On Attack: "," life and mana steal|R", thistype.callback45);
            thistype.create(46,403,"|CFF33FF33On Attack: Increase attack speed by 1% per attack, stacks up to ",", lasts for 3 seconds|R", thistype.callback46);
            thistype.create(47,404,"|CFF33FF33On Attack: "," chance to knock back target|R", thistype.callback47);
            thistype.create(48,405,"|CFF33FF33On Attack: "," chance to increase 30% attack speed, lasts for 5 seconds|R", thistype.callback48);
            thistype.create(49,406,"|CFF33FF33On Attack: 10% chance to consume 5% of max MP, deals "," magical damage to all enemies in a row|R", thistype.callback49);
            thistype.create(50,407,"|CFF33FF33On Attack: 15% chance to cast poison nova, dealing "," magic damage over time to all enemies within 600 yards|R", thistype.callback50);
            thistype.create(51,408,"|CFF33FF33On Attack: 15% chance to cast Death Coil, deals "," magical damage to target. Target takes 3% extra damge|R", thistype.callback51);
            thistype.create(52,409,"|CFF33FF33On Attack: 20% chance to deal bleed effect to target. Target takes "," physical damage over time, lasts for 10 seconds|R", thistype.callback52);
            thistype.create(53,410,"|CFF33FF33On Attack: 25% chance to deal "," magical damage to target|R", thistype.callback53);
            thistype.create(54,411,"|CFF33FF33On Attack: 5% chance to stun target for "," seconds|R", thistype.callback54);
            thistype.create(55,412,"|CFF33FF33On Attack: 5% chance to increase "," attack critical chance, lasts for 5 seconds|R", thistype.callback55);
            thistype.create(56,413,"|CFF33FF33On Attack: Target takes "," extra damage, lasts for 3 seconds|R", thistype.callback56);
            thistype.create(57,414,"|CFF33FF33On Attack: Deals "," magical damage, scaled up by your attack power and spell power|R", thistype.callback57);
            thistype.create(58,415,"|CFF33FF33On Attack: Deals "," magical damage, scaled up by target HP lost|R", thistype.callback58);
            thistype.create(59,416,"|CFF33FF33On Attack: Decrease target healing taken by ","|R", thistype.callback59);
            thistype.create(60,417,"|CFF33FF33On Attack: Decrease target attack hit chance by ","|R", thistype.callback60);
            thistype.create(61,418,"|CFF33FF33On Attack: Decrease target armor by ","|R", thistype.callback61);
            thistype.create(62,419,"|CFF33FF33On Attack: Decrease target attack speed by ","|R", thistype.callback62);
            thistype.create(63,420,"|CFF33FF33On Attack: Decrease target movement speed by ","|R", thistype.callback63);
            thistype.create(64,421,"|CFF33FF33On Attack: Decrease target damage and healing dealt by ","|R", thistype.callback64);
            thistype.create(75,430,"|CFF33FF33Every Third Attack: Consumes 5% of max MP, deals "," magical damage to all enemies nearby|R", thistype.callback75);
            thistype.create(87,450,"|CFF33FF33Spell Damage: 1% chance to regen "," MP|R", thistype.callback87);
            thistype.create(88,451,"|CFF33FF33Spell Damage: 10% chance to poison target, dealing "," magical damage over time|R", thistype.callback88);
            thistype.create(89,452,"|CFF33FF33Spell Damage: 10% chance to cast Chain Lightning to target, dealing "," magical damage|R", thistype.callback89);
            thistype.create(77,460,"|CFF33FF33Spell Critical: Charges with arcane power. All arcane power will be released automatically after 3 stacks, dealing "," magical damage to target|R", thistype.callback77);
            thistype.create(40,500,"|CFF33FF33On Damaged: Regens MP from "," of the damage taken|R", thistype.callback40);
            thistype.create(41,600,"|CFF33FF33On Attacked: Decreases attacker's attack power by ","|R", thistype.callback41);
            thistype.create(42,700,"|cff33ff33On Healed: Charges 1 holy power|R","", thistype.callback42);
            thistype.create(82,800,"|CFF33FF33Grant Aura of Conviction: All enemies within 600 yards take "," more magical damage|R", thistype.callback82);
            thistype.create(83,801,"|CFF33FF33Grant Aura of Meditation: All allies within 600 yards regen "," MP per second|R", thistype.callback83);
            thistype.create(84,802,"|CFF33FF33Grant Aura of Warsong: All allies deal "," more damage and healing, take 10% more healing within 600 yards|R", thistype.callback84);
            thistype.create(85,803,"|CFF33FF33Grant Aura of Unholy: All allies within 600 yards regen "," HP per second|R", thistype.callback85);
            thistype.create(28,900,"|cff33ff33Use: Teleports to an ally|R","", thistype.callback28);
            thistype.create(29,901,"|CFF33FF33Use: Battle Orders, increases "," max HP to all allies within 900 yards, lasts for 75 seconds|R", thistype.callback29);
            thistype.create(30,902,"|CFF33FF33Use: Regens "," MP|R", thistype.callback30);
            thistype.create(31,903,"|CFF33FF33Use: Regens "," HP|R", thistype.callback31);
            thistype.create(32,904,"|CFF33FF33Use: Deals "," magical damage to all enemies within range over time|R", thistype.callback32);
            thistype.create(33,905,"|CFF33FF33Use: Increase intelligence by ",", lasts for 20 seconds|R", thistype.callback33);
            thistype.create(34,906,"|CFF33FF33Use: Increase spell power by ",", lasts for 15 seconds|R", thistype.callback34);
            thistype.create(35,907,"|CFF33FF33Use: Increase dodge chance by 30%, lasts for "," seconds|R", thistype.callback35);
            thistype.create(36,908,"|CFF33FF33Use: Increase movement speed by 300, lasts for "," seconds. Possible failures.|R", thistype.callback36);
            thistype.create(37,909,"|CFF33FF33Use: Increase attack speed by 40%, take "," extra damage|R", thistype.callback37);
            thistype.create(38,910,"|CFF33FF33Use: Release all holy power to heal yourself, each point heals "," HP|R", thistype.callback38);
        }
    }

    function onInit() {
        ItemAttributes = Table.create();
        
        TriggerAnyUnit(EVENT_PLAYER_UNIT_PICKUP_ITEM, function itemon);
        TriggerAnyUnit(EVENT_PLAYER_UNIT_DROP_ITEM, function itemoff);
    }
}
//! endzinc
