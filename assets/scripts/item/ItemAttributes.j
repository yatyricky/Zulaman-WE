//! zinc
library ItemAttributes requires UnitProperty, ItemAffix, BreathOfTheDying, WindForce, Infinity {
    public constant real AFFIX_FACTOR_BASE = 15000;
    public constant real AFFIX_FACTOR_DELTA = 2500;
    public constant real SUFIX_MULTIPLIER = 4;
    public constant real PREFIX_STATIC_MOD = -0.5;
    public constant real SUFIX_STATIC_MOD = -0.2;
    public constant real PREFIX_MAX_PROB = 0.9;
    public constant real SUFIX_MAX_PROB = 0.75;

    public type ItemPropModType extends function(unit, item, integer);
    public type ItemAttributeCallback extends function(unit, real, integer);
    //public HandleTable itemInst;
    Table ItemAttributes;

    IntegerPool ipPrefix1;
    IntegerPool ipPrefix2;
    IntegerPool ipSufix;

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

            thistype.append(ITID_WOESTAVE,9,7,21);
            thistype.append(ITID_WOESTAVE,63,0.01,0.03);
            thistype.append(ITID_WOESTAVE,62,0.02,0.04);
            thistype.append(ITID_WOESTAVE,61,1,2);
            thistype.append(ITID_WOESTAVE,60,0.03,0.04);
            thistype.append(ITID_WOESTAVE,64,0.01,0.01);
            thistype.append(ITID_WOESTAVE,59,0.11,0.17);

            thistype.setLoreText(ITID_WOESTAVE,"|CFFFF8C00Woestave|R","|CFFFFDEAD\"Cause of the great plague.\"|R");

            thistype.append(ITID_ENIGMA,1,0.01,0.02);
            thistype.append(ITID_ENIGMA,3,0.01,0.02);
            thistype.append(ITID_ENIGMA,24,12,20);
            thistype.append(ITID_ENIGMA,IATTR_STR,8,13);
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
            thistype.append(ITID_DERANGEMENT_OF_CTHUN,9,17,24);
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
            thistype.append(ITID_MIGHT_OF_THE_ANGEL_OF_JUSTICE,42,2,5);
            thistype.append(ITID_MIGHT_OF_THE_ANGEL_OF_JUSTICE,38,25,35);


            thistype.setLoreText(ITID_MIGHT_OF_THE_ANGEL_OF_JUSTICE,"|CFFFF8C00Might of the Angel of Justice|R","|CFFFFCC00Lore|R|N|CFFFFDEADThe armor used by Tyrael, the Archangel of Wisdom when he was once the incarnation of justice.|R");

            thistype.append(ITID_INFINITY,14,4,6);
            thistype.append(ITID_INFINITY,21,70,166);
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
        ItemAffix affix;

        static method inst(item it, string trace) -> thistype {
            if (thistype.ht.exists(it)) {
                return thistype.ht[it];
            } else {
                print("Unknown item: " + ID2S(GetItemTypeId(it)) + ", trace: " + trace);
                return 0;
            }
        }

        static method findAttribute(item it, integer id) -> thistype {
            thistype head = thistype.inst(it, "ItemExAttributes.findAttribute");
            boolean found = false;
            while (found == false && head != 0) {
                if (head.id == id) {
                    found = true;
                } else {
                    head = head.next;
                }
            }
            if (found == true) {
                return head;
            } else {
                return 0;
            }
        }

        static method getAttributeValue(item it, integer id, string trace) -> real {
            thistype attr = thistype.findAttribute(it, id);
            if (attr == 0) {
                return 0.0;
            } else {
                return attr.value;
            }
        }

        static method create(integer id, real val) -> thistype {
            thistype this = thistype.allocate();
            this.id = id;
            this.value = val;
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
                    if (head.value < 1 || head.id == IATTR_USE_CTHUN) {
                        valstr = I2S(Rounding(head.value * 100)) + "%";
                    } else {
                        valstr = I2S(Rounding(head.value));
                    }
                    if (head.value == 0) {
                        str = str + meta.str1 + meta.str2;
                    } else {
                        str = str + meta.str1 + valstr + meta.str2;
                    }
                    if (head.next != 0) {
                        str = str + "|N";
                    }
                    head = head.next;
                }
                raw = DefaultItemAttributesData.inst(GetItemTypeId(it), "updateUberTip");
                BlzSetItemExtendedTooltip(it, str);
            } else {
                print("ItemExAttributes.updateUbertip no such item " + ID2S(GetItemTypeId(it)));
            }
        }

        static method updateName(item it) {
            thistype this = thistype.inst(it, "ItemExAttributes.updateName");
            string rawName = DefaultItemAttributesData.inst(GetItemTypeId(it), "updateName").name;
            ItemAffix head = this.affix;
            AffixRawData meta;
            string sufix = "";
            string prefix = "";
            while (head != 0) {
                meta = AffixRawData.inst(head.id, "ItemExAttributes.updateName");
                if (meta.slot == 1) {
                    prefix = prefix + meta.text[1];
                } else if (meta.slot == 2) {
                    sufix = sufix + meta.text[1];
                } else {
                    print("WTF??? ItemExAttributes.updateName 155");
                }
                head = head.next;
            }
            BlzSetItemName(it, prefix + rawName + sufix);
        }

        static method apply(item it, real exp) {
            DefaultItemAttributesData raw = DefaultItemAttributesData.inst(GetItemTypeId(it), "ItemExAttributes.intantiate");
            thistype data;
            thistype head, index;
            boolean found;
            ItemAttributeMeta metaIndex, metaData;
            if (raw == 0) {
                print("Raw data does not exist ItemExAttributes 73");
            } else {
                head = thistype.create(raw.id, GetRandomReal(raw.lo, raw.hi) * exp);
                head.affix = 0;
                thistype.ht[it] = head;
                raw = raw.next;
                while (raw != 0) {
                    data = thistype.create(raw.id, GetRandomReal(raw.lo, raw.hi) * exp);
                    // insert
                    index = head;
                    found = false;
                    while (index.next != 0 && found == false) {
                        metaIndex = ItemAttributeMeta.inst(index.next.id, "ItemExAttributes.intantiate.metaIndex");
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
            }
        }

        static method append(item it, integer id, real val) {
            thistype attr = thistype.findAttribute(it, id);
            thistype head;
            thistype data;
            boolean found;
            ItemAttributeMeta metaHead, metaData;
            if (attr != 0) {
                attr.value += val;
            } else {
                data = thistype.create(id, val);
                head = thistype.inst(it, "ItemExAttributes.append");
                found = false;
                while (found == false && head.next != 0) {
                    metaHead = ItemAttributeMeta.inst(head.next.id, "ItemExAttributes.intantiate.metaHead");
                    metaData = ItemAttributeMeta.inst(data.id, "ItemExAttributes.intantiate.metaData");
                    if (metaHead.sort < metaData.sort) {
                        head = head.next;
                    } else {
                        found = true;
                    }
                }
                if (head.next != 0) {
                    data.next = head.next;
                }
                head.next = data;
            }
        }

        static method appendAffix(item it, ItemAffix affix) {
            thistype this = thistype.inst(it, "ItemExAttributes.appendAffix");
            integer i;
            ItemAffix index = this.affix;
            while (index != 0 && index.next != 0) {
                index = index.next;
            }
            if (index == 0) {
                this.affix = affix;
            } else {
                index.next = affix;
            }
            i = 0;
            while (i < affix.attributeN) {
                if (affix.attribute[i] == AFFIX_TYPE_STR) {
                    thistype.append(it, IATTR_STR, affix.value[i]);
                } else if (affix.attribute[i] == AFFIX_TYPE_AGI) {
                    thistype.append(it, IATTR_AGI, affix.value[i]);
                } else if (affix.attribute[i] == AFFIX_TYPE_INT) {
                    thistype.append(it, IATTR_INT, affix.value[i]);
                } else if (affix.attribute[i] == AFFIX_TYPE_HP) {
                    thistype.append(it, IATTR_HP, affix.value[i]);
                } else if (affix.attribute[i] == AFFIX_TYPE_AP) {
                    thistype.append(it, IATTR_AP, affix.value[i]);
                } else if (affix.attribute[i] == AFFIX_TYPE_CRIT) {
                    thistype.append(it, IATTR_CRIT, affix.value[i]);
                } else if (affix.attribute[i] == AFFIX_TYPE_IAS) {
                    thistype.append(it, IATTR_IAS, affix.value[i]);
                } else if (affix.attribute[i] == AFFIX_TYPE_SP) {
                    thistype.append(it, IATTR_SP, affix.value[i]);
                } else if (affix.attribute[i] == AFFIX_TYPE_SCRIT) {
                    thistype.append(it, IATTR_SCRIT, affix.value[i]);
                } else if (affix.attribute[i] == AFFIX_TYPE_SHASTE) {
                    thistype.append(it, IATTR_SHASTE, affix.value[i]);
                } else if (affix.attribute[i] == AFFIX_TYPE_MREGEN) {
                    thistype.append(it, IATTR_MREG, affix.value[i]);
                } else if (affix.attribute[i] == AFFIX_TYPE_DEF) {
                    thistype.append(it, IATTR_DEF, affix.value[i]);
                } else if (affix.attribute[i] == AFFIX_TYPE_DODGE) {
                    thistype.append(it, IATTR_DODGE, affix.value[i]);
                } else if (affix.attribute[i] == AFFIX_TYPE_SLVL) {
                    thistype.append(it, IATTR_LP, affix.value[i]);
                }
                i += 1;
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
    
    public function CreateItemEx(integer itid, real x, real y, real lootValue) -> item {
        item it = CreateItem(itid, x + GetRandomReal(-50, 50), y + GetRandomReal(-50, 50));
        real prefixFactor;
        real sufixFactor;
        real prob, prob1;
        boolean prefixDone;
        string itemName;
        real exp;
        if (lootValue < ILVL_THRESHOLD[0]) {
            exp = 1.0;
        } else if (lootValue < ILVL_THRESHOLD[1]) {
            exp = 1.0 + lootValue / (ILVL_THRESHOLD[1] - ILVL_THRESHOLD[0]);
        } else {
            exp = 2.0 + lootValue / (ILVL_THRESHOLD[2] - ILVL_THRESHOLD[1]);
        }
        ItemExAttributes.apply(it, exp);
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
                ItemExAttributes.appendAffix(it, ItemAffix.instantiate(ipPrefix2.get()));
            }
        }
        if (prefixDone == false) {
            if (GetRandomReal(0, 1) < prob) {
                prefixDone = true;
                ItemExAttributes.appendAffix(it, ItemAffix.instantiate(ipPrefix1.get()));
            }
        }
        prob = (lootValue - prefixFactor) / sufixFactor + SUFIX_STATIC_MOD;
        if (prob > SUFIX_MAX_PROB) {
            prob = SUFIX_MAX_PROB;
        }
        if (GetRandomReal(0, 1) < prob) {
            ItemExAttributes.appendAffix(it, ItemAffix.instantiate(ipSufix.get()));
        }
        ItemExAttributes.updateUbertip(it);
        ItemExAttributes.updateName(it);
        // itemName = GetAllItemAffixesText(it, 1);
        // BlzSetItemTooltip(it, itemName);
        // BlzSetItemName(it, itemName);
        // print("Set item " + I2HEX(GetHandleId(it)) + " name to: " + itemName);
        return it;
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
            UnitProp up = UnitProp.inst(u, "ItemAttributeMeta.callback7");
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
        static method callbackRG_ONESHOT(unit u, real val, integer polar) {}
        static method callbackRG_RUSH(unit u, real val, integer polar) {}
        static method callbackCRKILLER(unit u, real val, integer polar) {}
        static method callbackMCVT(unit u, real val, integer polar) {}
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
        static method callbackDR_CDR(unit u, real val, integer polar) {}
        static method callbackSM_LASH(unit u, real val, integer polar) {}
        static method callbackDK_ARROW(unit u, real val, integer polar) {}
        static method callbackMG_FDMG(unit u, real val, integer polar) {}
        static method callbackMG_BLZ(unit u, real val, integer polar) {}
        static method callbackATK_ML(unit u, real val, integer polar) {
            UnitProp.inst(u, "ItemAttributeMeta.callback45").ml += val * polar;
        }
        static method callbackATK_LL(unit u, real val, integer polar) {
            UnitProp.inst(u, "ItemAttributeMeta.callback45").ll += val * polar;
        }
        static method callbackATK_LLML(unit u, real val, integer polar) {
            UnitProp up = UnitProp.inst(u, "ItemAttributeMeta.callback45");
            up.ll += val * polar;
            up.ml += val * polar;
        }
        static method callbackATK_CTHUN(unit u, real val, integer polar) {
            EquipedAttackStackableIAS(u, polar);
        }
        static method callbackATK_WF(unit u, real val, integer polar) {
            EquipedWindforce(u, polar);
        }
        static method callbackATK_LION(unit u, real val, integer polar) {}
        static method callbackATK_MOONWAVE(unit u, real val, integer polar) {}
        static method callbackATK_POISNOVA(unit u, real val, integer polar) {
            EquipedBOTD(u, polar);
        }
        static method callbackATK_COIL(unit u, real val, integer polar) {}
        static method callbackATK_BLEED(unit u, real val, integer polar) {}
        static method callbackATK_MDC(unit u, real val, integer polar) {}
        static method callbackATK_STUN(unit u, real val, integer polar) {}
        static method callbackATK_CRIT(unit u, real val, integer polar) {}
        static method callbackATK_AMP(unit u, real val, integer polar) {}
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
        static method callbackMD_MREGEN(unit u, real val, integer polar) {}
        static method callbackMD_POISON(unit u, real val, integer polar) {}
        static method callbackMD_CHAIN(unit u, real val, integer polar) {
            EquipedMagicChainLightning(u, polar);
        }
        static method callbackMDC_ARCANE(unit u, real val, integer polar) {}
        static method callbackDT_MREGEN(unit u, real val, integer polar) {
            UnitProp.inst(u, "ItemAttributeMeta.callback45").damageGoesMana += val * polar;
        }
        static method callbackATKED_WEAK(unit u, real val, integer polar) {}
        static method callbackHEAL_HOLY(unit u, real val, integer polar) {
            EquipedHealedStackHoly(u, polar);
        }
        static method callbackAURA_CONVIC(unit u, real val, integer polar) {
            EquipedConvictionAura(u, polar);
        }
        static method callbackAURA_MEDITA(unit u, real val, integer polar) {}
        static method callbackAURA_WARSONG(unit u, real val, integer polar) {}
        static method callbackAURA_UNHOLY(unit u, real val, integer polar) {}
        static method callbackUSE_TP(unit u, real val, integer polar) {}
        static method callbackUSE_BATTLE(unit u, real val, integer polar) {}
        static method callbackUSE_MREGEN(unit u, real val, integer polar) {}
        static method callbackUSE_HREGEN(unit u, real val, integer polar) {}
        static method callbackUSE_VOODOO(unit u, real val, integer polar) {}
        static method callbackUSE_INT(unit u, real val, integer polar) {}
        static method callbackUSE_SP(unit u, real val, integer polar) {}
        static method callbackUSE_DODGE(unit u, real val, integer polar) {}
        static method callbackUSE_MS(unit u, real val, integer polar) {}
        static method callbackUSE_CTHUN(unit u, real val, integer polar) {}
        static method callbackUSE_HOLYHEAL(unit u, real val, integer polar) {}

        static method onInit() {
            thistype.ht = Table.create();
thistype.create(IATTR_STR,100,"+"," Strength",thistype.callbackSTR);
thistype.create(IATTR_STRPL,101,"+"," Strength/level",thistype.callbackSTRPL);
thistype.create(IATTR_AGI,102,"+"," Agility",thistype.callbackAGI);
thistype.create(IATTR_INT,104,"+"," Intelligence",thistype.callbackINT);
thistype.create(IATTR_ALLSTAT,106,"+"," All stats",thistype.callbackALLSTAT);
thistype.create(IATTR_HP,110,"+"," Max HP",thistype.callbackHP);
thistype.create(IATTR_HPPCT,111,"+"," Max HP",thistype.callbackHPPCT);
thistype.create(IATTR_HPPL,112,"+"," Max HP/level",thistype.callbackHPPL);
thistype.create(IATTR_MP,114,"+"," Max MP",thistype.callbackMP);
thistype.create(IATTR_AP,120,"+"," Attack power",thistype.callbackAP);
thistype.create(IATTR_APPL,121,"+"," Attack power/level",thistype.callbackAPPL);
thistype.create(IATTR_CRIT,122,"+"," Attack critical",thistype.callbackCRIT);
thistype.create(IATTR_IAS,124,"+","% Attack speed",thistype.callbackIAS);
thistype.create(IATTR_SP,130,"+"," Spell power",thistype.callbackSP);
thistype.create(IATTR_SCRIT,132,"+"," Spell critical",thistype.callbackSCRIT);
thistype.create(IATTR_SHASTE,134,"+"," Spell haste",thistype.callbackSHASTE);
thistype.create(IATTR_DEF,140,"+"," Armor",thistype.callbackDEF);
thistype.create(IATTR_DEFPL,141,"+"," Armor/level",thistype.callbackDEFPL);
thistype.create(IATTR_BR,142,"+"," Block chance",thistype.callbackBR);
thistype.create(IATTR_BP,144,"+"," Block points",thistype.callbackBP);
thistype.create(IATTR_DODGE,146,"+"," Dodge chance",thistype.callbackDODGE);
thistype.create(IATTR_DR,150,"-"," All damage taken",thistype.callbackDR);
thistype.create(IATTR_MDR,152,"-"," magic damage taken",thistype.callbackMDR);
thistype.create(IATTR_AMP,154,"+"," Damage and healing dealt",thistype.callbackAMP);
thistype.create(IATTR_HAMP,156,"+"," Healing taken",thistype.callbackHAMP);
thistype.create(IATTR_MREG,160,"Regens "," MP per second",thistype.callbackMREG);
thistype.create(IATTR_HREG,162,"Regens "," HP per second",thistype.callbackHREG);
thistype.create(IATTR_HLOST,164,"Lost "," HP per second during combat",thistype.callbackHLOST);
thistype.create(IATTR_MS,170,"+"," Movement speed",thistype.callbackMS);
thistype.create(IATTR_MSPL,171,"+"," Movement speed/level",thistype.callbackMSPL);
thistype.create(IATTR_LP,195,"Improve item |cff33ff33special power|r + ","",thistype.callbackLP);
thistype.create(IATTR_ATK_ML,200,"|cff87ceeb+"," Mana stolen per hit|r",thistype.callbackATK_ML);
thistype.create(IATTR_ATK_LL,202,"|cff87ceeb+"," Life stolen per hit|r",thistype.callbackATK_LL);
thistype.create(IATTR_ATK_LLML,204,"|cff87ceeb+"," Life and mana stolen per hit|r",thistype.callbackATK_LLML);
thistype.create(IATTR_ATK_MD,210,"|cff87ceebDeals "," extra magic damage per hit|r",thistype.callbackATK_MD);
thistype.create(IATTR_ATK_MDK,211,"|cff87ceebDeals "," extra magic damage per hit, scaled up by target HP lost|r",thistype.callbackATK_MDK);
thistype.create(IATTR_RG_ONESHOT,250,"|cff87ceebOne-shot target when it's HP is less than yours","|r",thistype.callbackRG_ONESHOT);
thistype.create(IATTR_MCVT,253,"|cff87ceebConverts your normal attacks into magic damage","|r",thistype.callbackMCVT);
thistype.create(IATTR_PL_SHOCK,256,"|cff87ceebHoly Shock always deals critical healing","|r",thistype.callbackPL_SHOCK);
thistype.create(IATTR_PR_SHIELD,259,"|cff87ceebRemoves weakness effect of Shield","|r",thistype.callbackPR_SHIELD);
thistype.create(IATTR_PL_LIGHT,262,"|cff87ceebFlash Light dispels one debuff from target","|r",thistype.callbackPL_LIGHT);
thistype.create(IATTR_DT_MREGEN,266,"|cff87ceebRegens MP from "," of the damage taken|r",thistype.callbackDT_MREGEN);
thistype.create(IATTR_USE_TP,268,"|cff87ceebUse: Teleports to an ally","|r",thistype.callbackUSE_TP);
thistype.create(IATTR_BM_VALOR,300,"|cff33ff33Regenerates "," more valor points|r",thistype.callbackBM_VALOR);
thistype.create(IATTR_RG_RUSH,302,"|cff33ff33Deals "," extra damage to target below 30% max HP|r",thistype.callbackRG_RUSH);
thistype.create(IATTR_CRKILLER,303,"|cff33ff33Deals "," extra damage to non-hero targets|r",thistype.callbackCRKILLER);
thistype.create(IATTR_KG_REGRCD,305,"|cff33ff33Reduce cooldown of Instant Regrowth by "," seconds|r",thistype.callbackKG_REGRCD);
thistype.create(IATTR_LEECHAURA,307,"|cff33ff33Absorb "," HP from all enemies nearby every second|r",thistype.callbackLEECHAURA);
thistype.create(IATTR_PR_POHDEF,308,"|cff33ff33Prayer of healing increases armor of target by ","|r",thistype.callbackPR_POHDEF);
thistype.create(IATTR_DR_MAXHP,310,"|cff33ff33Survival Instincts provides "," extra healing and max HP|r",thistype.callbackDR_MAXHP);
thistype.create(IATTR_CT_PAIN,313,"|cff33ff33Marrow Squeeze extends the Pain on target by "," seconds|r",thistype.callbackCT_PAIN);
thistype.create(IATTR_BD_SHIELD,314,"|cff33ff33Shield of Sin'dorei provides "," extra damage reduction, and forces all nearby enemies to attack you|r",thistype.callbackBD_SHIELD);
thistype.create(IATTR_RG_PARALZ,315,"|cff33ff33Sinister Strike has a "," chance to paralyze target, reduce target spell haste by 20% and gain an extra combo point|r",thistype.callbackRG_PARALZ);
thistype.create(IATTR_DR_CDR,317,"|cff33ff33Reduce cooldown of Survival Instincts by "," seconds|r",thistype.callbackDR_CDR);
thistype.create(IATTR_SM_LASH,318,"|cff33ff33Storm Lash has "," extra chance to cooldown Earth Shock|r",thistype.callbackSM_LASH);
thistype.create(IATTR_DK_ARROW,319,"|cff33ff33Number of Dark Arrows increased by ","|r",thistype.callbackDK_ARROW);
thistype.create(IATTR_MG_FDMG,320,"|cff33ff33Increase ice spell damage by ","|r",thistype.callbackMG_FDMG);
thistype.create(IATTR_MG_BLZ,322,"|cff33ff33"," chance to cast an instant Frost Bolt to targets damaged by Blizzard|r",thistype.callbackMG_BLZ);
thistype.create(IATTR_ATK_CTHUN,403,"|cff33ff33On Attack: Increase attack speed by 1% per attack, stacks up to ",", lasts for 3 seconds|r",thistype.callbackATK_CTHUN);
thistype.create(IATTR_ATK_WF,404,"|cff33ff33On Attack: "," chance to knock back target|r",thistype.callbackATK_WF);
thistype.create(IATTR_ATK_LION,405,"|cff33ff33On Attack: "," chance to increase 30% attack speed, lasts for 5 seconds|r",thistype.callbackATK_LION);
thistype.create(IATTR_ATK_MOONWAVE,406,"|cff33ff33On Attack: 10% chance to consume 5% of max MP, deals "," magic damage to all enemies in a row|r",thistype.callbackATK_MOONWAVE);
thistype.create(IATTR_ATK_POISNOVA,407,"|cff33ff33On Attack: 15% chance to cast poison nova, dealing "," magic damage over time to all enemies within 600 yards|r",thistype.callbackATK_POISNOVA);
thistype.create(IATTR_ATK_COIL,408,"|cff33ff33On Attack: 15% chance to cast Death Coil, deals "," magic damage to target. Target takes 3% extra damge|r",thistype.callbackATK_COIL);
thistype.create(IATTR_ATK_BLEED,409,"|cff33ff33On Attack: 20% chance to deal bleed effect to target. Target takes "," physical damage over time, lasts for 10 seconds|r",thistype.callbackATK_BLEED);
thistype.create(IATTR_ATK_MDC,410,"|cff33ff33On Attack: 25% chance to deal "," magic damage to target|r",thistype.callbackATK_MDC);
thistype.create(IATTR_ATK_STUN,411,"|cff33ff33On Attack: 5% chance to stun target for "," seconds|r",thistype.callbackATK_STUN);
thistype.create(IATTR_ATK_CRIT,412,"|cff33ff33On Attack: 5% chance to increase "," attack critical chance, lasts for 5 seconds|r",thistype.callbackATK_CRIT);
thistype.create(IATTR_ATK_AMP,413,"|cff33ff33On Attack: Target takes "," extra damage|r",thistype.callbackATK_AMP);
thistype.create(IATTR_ATK_MORTAL,416,"|cff33ff33On Attack: Decrease target healing taken by ","|r",thistype.callbackATK_MORTAL);
thistype.create(IATTR_ATK_MISS,417,"|cff33ff33On Attack: Decrease target attack hit chance by ","|r",thistype.callbackATK_MISS);
thistype.create(IATTR_ATK_DDEF,418,"|cff33ff33On Attack: Decrease target armor by ","|r",thistype.callbackATK_DDEF);
thistype.create(IATTR_ATK_DAS,419,"|cff33ff33On Attack: Decrease target attack speed by ","|r",thistype.callbackATK_DAS);
thistype.create(IATTR_ATK_DMS,420,"|cff33ff33On Attack: Decrease target movement speed by ","|r",thistype.callbackATK_DMS);
thistype.create(IATTR_ATK_WEAK,421,"|cff33ff33On Attack: Decrease target damage and healing dealt by ","|r",thistype.callbackATK_WEAK);
thistype.create(IATTR_3ATK_MOONEXP,430,"|cff33ff33Every Third Attack: Consumes 5% of max MP, deals "," magic damage to all enemies nearby|r",thistype.callback3ATK_MOONEXP);
thistype.create(IATTR_MD_MREGEN,450,"|cff33ff33Dealing Magic Damage: 1% chance to regen "," MP|r",thistype.callbackMD_MREGEN);
thistype.create(IATTR_MD_POISON,451,"|cff33ff33Dealing Magic Damage: 10% chance to poison target, dealing "," magic damage over time|r",thistype.callbackMD_POISON);
thistype.create(IATTR_MD_CHAIN,452,"|cff33ff33Dealing Magic Damage: 10% chance to cast Chain Lightning to target, dealing "," magic damage|r",thistype.callbackMD_CHAIN);
thistype.create(IATTR_MDC_ARCANE,460,"|cff33ff33Magic Damage Critical: Charges with arcane power. All arcane power will be released automatically after 3 stacks, dealing "," magic damage to target|r",thistype.callbackMDC_ARCANE);
thistype.create(IATTR_HEAL_HOLY,501,"|cff33ff33On Healed: Charges 1 holy power, stacks up to "," points|r",thistype.callbackHEAL_HOLY);
thistype.create(IATTR_ATKED_WEAK,600,"|cff33ff33On Attacked: Decreases attacker's attack power by ","|r",thistype.callbackATKED_WEAK);
thistype.create(IATTR_AURA_CONVIC,800,"|cff33ff33Grant Aura of Conviction: All enemies within 600 yards take "," more magic damage|r",thistype.callbackAURA_CONVIC);
thistype.create(IATTR_AURA_MEDITA,801,"|cff33ff33Grant Aura of Meditation: All allies within 600 yards regen "," MP per second|r",thistype.callbackAURA_MEDITA);
thistype.create(IATTR_AURA_WARSONG,802,"|cff33ff33Grant Aura of Warsong: All allies deal "," more damage and healing, take 10% more healing within 600 yards|r",thistype.callbackAURA_WARSONG);
thistype.create(IATTR_AURA_UNHOLY,803,"|cff33ff33Grant Aura of Unholy: All allies within 600 yards regen "," HP per second|r",thistype.callbackAURA_UNHOLY);
thistype.create(IATTR_USE_BATTLE,901,"|cff33ff33Use: Battle Orders, increases "," max HP to all allies within 900 yards, lasts for 75 seconds|r",thistype.callbackUSE_BATTLE);
thistype.create(IATTR_USE_MREGEN,902,"|cff33ff33Use: Regens "," MP|r",thistype.callbackUSE_MREGEN);
thistype.create(IATTR_USE_HREGEN,903,"|cff33ff33Use: Regens "," HP|r",thistype.callbackUSE_HREGEN);
thistype.create(IATTR_USE_VOODOO,904,"|cff33ff33Use: Deals "," magic damage to all enemies within range over time|r",thistype.callbackUSE_VOODOO);
thistype.create(IATTR_USE_INT,905,"|cff33ff33Use: Increase intelligence by ",", lasts for 20 seconds|r",thistype.callbackUSE_INT);
thistype.create(IATTR_USE_SP,906,"|cff33ff33Use: Increase spell power by ",", lasts for 15 seconds|r",thistype.callbackUSE_SP);
thistype.create(IATTR_USE_DODGE,907,"|cff33ff33Use: Increase dodge chance by 30%, lasts for "," seconds|r",thistype.callbackUSE_DODGE);
thistype.create(IATTR_USE_MS,908,"|cff33ff33Use: Increase movement speed by 300, lasts for "," seconds. Possible failures.|r",thistype.callbackUSE_MS);
thistype.create(IATTR_USE_CTHUN,909,"|cff33ff33Use: Increase attack speed by 100%, take "," extra damage|r",thistype.callbackUSE_CTHUN);
thistype.create(IATTR_USE_HOLYHEAL,910,"|cff33ff33Use: Release all holy power to heal yourself, each point heals "," HP|r",thistype.callbackUSE_HOLYHEAL);
        }
    }

    function onInit() {
        ItemAttributes = Table.create();
        
        TriggerAnyUnit(EVENT_PLAYER_UNIT_PICKUP_ITEM, function itemon);
        TriggerAnyUnit(EVENT_PLAYER_UNIT_DROP_ITEM, function itemoff);

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
