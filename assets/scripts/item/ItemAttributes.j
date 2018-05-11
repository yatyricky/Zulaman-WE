//! zinc
library ItemAttributes requires UnitProperty, BreathOfTheDying {
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

        static method getValue(item it, integer id, string trace) -> real {
            thistype head = thistype.inst(it, trace);
            real ret = 0;
            boolean found = false;
            while (found == false && head != 0) {
                if (head.id == id) {
                    found = true;
                    ret = head.value;
                }
                head = head.next;
            }
            if (found == true) {
                return ret;
            } else {
                if (id != IATTR_LP) {
                    print("ItemExAttributes.getValue: unable to find " + I2S(id) + " in item: " + ID2S(GetItemTypeId(it)));
                }
                return 0.0;
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

        static method callbackSTR(unit u, real val, integer polar) {}
        static method callbackSTRPL(unit u, real val, integer polar) {}
        static method callbackAGI(unit u, real val, integer polar) {}
        static method callbackINT(unit u, real val, integer polar) {}
        static method callbackALLSTAT(unit u, real val, integer polar) {
            UnitProp up = UnitProp.inst(u, "ItemAttributeMeta.callback7");
            up.ModStr(Rounding(val) * polar);
            up.ModAgi(Rounding(val) * polar);
            up.ModInt(Rounding(val) * polar);
        }
        static method callbackHP(unit u, real val, integer polar) {}
        static method callbackHPPCT(unit u, real val, integer polar) {}
        static method callbackHPPL(unit u, real val, integer polar) {}
        static method callbackMP(unit u, real val, integer polar) {}
        static method callbackAP(unit u, real val, integer polar) {
            UnitProp up = UnitProp.inst(u, "ItemAttributeMeta.callback9");
            up.ModAP(Rounding(val) * polar);
        }
        static method callbackAPPL(unit u, real val, integer polar) {}
        static method callbackCRIT(unit u, real val, integer polar) {}
        static method callbackIAS(unit u, real val, integer polar) {
            UnitProp up = UnitProp.inst(u, "ItemAttributeMeta.callback12");
            up.ModAttackSpeed(Rounding(val) * polar);
        }
        static method callbackSP(unit u, real val, integer polar) {}
        static method callbackSCRIT(unit u, real val, integer polar) {}
        static method callbackSHASTE(unit u, real val, integer polar) {}
        static method callbackDEF(unit u, real val, integer polar) {}
        static method callbackDEFPL(unit u, real val, integer polar) {}
        static method callbackBR(unit u, real val, integer polar) {}
        static method callbackBP(unit u, real val, integer polar) {}
        static method callbackDODGE(unit u, real val, integer polar) {}
        static method callbackDR(unit u, real val, integer polar) {}
        static method callbackMDR(unit u, real val, integer polar) {}
        static method callbackAMP(unit u, real val, integer polar) {}
        static method callbackHAMP(unit u, real val, integer polar) {}
        static method callbackMREG(unit u, real val, integer polar) {}
        static method callbackHREG(unit u, real val, integer polar) {}
        static method callbackHLOST(unit u, real val, integer polar) {}
        static method callbackMS(unit u, real val, integer polar) {}
        static method callbackMSPL(unit u, real val, integer polar) {}
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
        static method callbackATK_ML(unit u, real val, integer polar) {}
        static method callbackATK_LL(unit u, real val, integer polar) {}
        static method callbackATK_LLML(unit u, real val, integer polar) {
            UnitProp up = UnitProp.inst(u, "ItemAttributeMeta.callback45");
            up.ll += val * polar;
            up.ml += val * polar;
        }
        static method callbackATK_CTHUN(unit u, real val, integer polar) {}
        static method callbackATK_WF(unit u, real val, integer polar) {}
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
        static method callbackATK_MD(unit u, real val, integer polar) {}
        static method callbackATK_MDK(unit u, real val, integer polar) {}
        static method callbackATK_MORTAL(unit u, real val, integer polar) {}
        static method callbackATK_MISS(unit u, real val, integer polar) {}
        static method callbackATK_DDEF(unit u, real val, integer polar) {}
        static method callbackATK_DAS(unit u, real val, integer polar) {}
        static method callbackATK_DMS(unit u, real val, integer polar) {}
        static method callbackATK_WEAK(unit u, real val, integer polar) {}
        static method callback3ATK_MOONEXP(unit u, real val, integer polar) {}
        static method callbackMD_MREGEN(unit u, real val, integer polar) {}
        static method callbackMD_POISON(unit u, real val, integer polar) {}
        static method callbackMD_CHAIN(unit u, real val, integer polar) {}
        static method callbackMDC_ARCANE(unit u, real val, integer polar) {}
        static method callbackDT_MREGEN(unit u, real val, integer polar) {}
        static method callbackATKED_WEAK(unit u, real val, integer polar) {}
        static method callbackHEAL_HOLY(unit u, real val, integer polar) {}
        static method callbackAURA_CONVIC(unit u, real val, integer polar) {}
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
            thistype.create(IATTR_MDR,152,"-"," Magical damage taken",thistype.callbackMDR);
            thistype.create(IATTR_AMP,154,"+"," Damage and healing dealt",thistype.callbackAMP);
            thistype.create(IATTR_HAMP,156,"+"," Healing taken",thistype.callbackHAMP);
            thistype.create(IATTR_MREG,160,"Regens "," MP per second",thistype.callbackMREG);
            thistype.create(IATTR_HREG,162,"Regens "," HP per second",thistype.callbackHREG);
            thistype.create(IATTR_HLOST,164,"Lost "," HP per second during combat",thistype.callbackHLOST);
            thistype.create(IATTR_MS,170,"+"," Movement speed",thistype.callbackMS);
            thistype.create(IATTR_MSPL,171,"+"," Movement speed/level",thistype.callbackMSPL);
            thistype.create(IATTR_LP,180,"+"," Item special power level",thistype.callbackLP);
            thistype.create(IATTR_BM_VALOR,200,"Regenerates "," more valor points",thistype.callbackBM_VALOR);
            thistype.create(IATTR_RG_ONESHOT,201,"One-shot target when it's HP is less than yours","",thistype.callbackRG_ONESHOT);
            thistype.create(IATTR_RG_RUSH,202,"Deals "," extra damage to target below 30% max HP",thistype.callbackRG_RUSH);
            thistype.create(IATTR_CRKILLER,203,"Deals "," extra damage to non-hero targets",thistype.callbackCRKILLER);
            thistype.create(IATTR_MCVT,204,"Converts your normal attacks into magical damage","",thistype.callbackMCVT);
            thistype.create(IATTR_KG_REGRCD,205,"Reduce cooldown of Instant Regrowth by "," seconds",thistype.callbackKG_REGRCD);
            thistype.create(IATTR_LEECHAURA,207,"Absorb "," HP from all enemies nearby every second",thistype.callbackLEECHAURA);
            thistype.create(IATTR_PR_POHDEF,208,"Prayer of healing increases armor of target by ","",thistype.callbackPR_POHDEF);
            thistype.create(IATTR_DR_MAXHP,210,"Survival Instincts provides "," extra healing and max HP",thistype.callbackDR_MAXHP);
            thistype.create(IATTR_PL_SHOCK,211,"Holy Shock always deals critical healing","",thistype.callbackPL_SHOCK);
            thistype.create(IATTR_PR_SHIELD,212,"Removes weakness effect of Shield","",thistype.callbackPR_SHIELD);
            thistype.create(IATTR_CT_PAIN,213,"Marrow Squeeze extends the Pain on target by "," seconds",thistype.callbackCT_PAIN);
            thistype.create(IATTR_BD_SHIELD,214,"Shield of Sin'dorei provides "," extra damage reduction, and forces all nearby enemies to attack you",thistype.callbackBD_SHIELD);
            thistype.create(IATTR_RG_PARALZ,215,"Sinister Strike has a "," chance to paralyze target, reduce target spell haste by 20% and gain an extra combo point",thistype.callbackRG_PARALZ);
            thistype.create(IATTR_PL_LIGHT,216,"Flash Light dispels one debuff from target","",thistype.callbackPL_LIGHT);
            thistype.create(IATTR_DR_CDR,217,"Reduce cooldown of Survival Instincts by "," seconds",thistype.callbackDR_CDR);
            thistype.create(IATTR_SM_LASH,218,"Storm Lash has "," extra chance to cooldown Earth Shock",thistype.callbackSM_LASH);
            thistype.create(IATTR_DK_ARROW,219,"Number of Dark Arrows increased by ","",thistype.callbackDK_ARROW);
            thistype.create(IATTR_MG_FDMG,220,"Increase ice spell damage by ","",thistype.callbackMG_FDMG);
            thistype.create(IATTR_MG_BLZ,222,""," chance to cast an instant Frost Bolt to targets damaged by Blizzard",thistype.callbackMG_BLZ);
            thistype.create(IATTR_ATK_ML,400,"On Attack: "," mana steal",thistype.callbackATK_ML);
            thistype.create(IATTR_ATK_LL,401,"On Attack: "," life steal",thistype.callbackATK_LL);
            thistype.create(IATTR_ATK_LLML,402,"On Attack: "," life and mana steal",thistype.callbackATK_LLML);
            thistype.create(IATTR_ATK_CTHUN,403,"On Attack: Increase attack speed by 1% per attack, stacks up to ",", lasts for 3 seconds",thistype.callbackATK_CTHUN);
            thistype.create(IATTR_ATK_WF,404,"On Attack: "," chance to knock back target",thistype.callbackATK_WF);
            thistype.create(IATTR_ATK_LION,405,"On Attack: "," chance to increase 30% attack speed, lasts for 5 seconds",thistype.callbackATK_LION);
            thistype.create(IATTR_ATK_MOONWAVE,406,"On Attack: 10% chance to consume 5% of max MP, deals "," magical damage to all enemies in a row",thistype.callbackATK_MOONWAVE);
            thistype.create(IATTR_ATK_POISNOVA,407,"On Attack: 15% chance to cast poison nova, dealing "," magic damage over time to all enemies within 600 yards",thistype.callbackATK_POISNOVA);
            thistype.create(IATTR_ATK_COIL,408,"On Attack: 15% chance to cast Death Coil, deals "," magical damage to target. Target takes 3% extra damge",thistype.callbackATK_COIL);
            thistype.create(IATTR_ATK_BLEED,409,"On Attack: 20% chance to deal bleed effect to target. Target takes "," physical damage over time, lasts for 10 seconds",thistype.callbackATK_BLEED);
            thistype.create(IATTR_ATK_MDC,410,"On Attack: 25% chance to deal "," magical damage to target",thistype.callbackATK_MDC);
            thistype.create(IATTR_ATK_STUN,411,"On Attack: 5% chance to stun target for "," seconds",thistype.callbackATK_STUN);
            thistype.create(IATTR_ATK_CRIT,412,"On Attack: 5% chance to increase "," attack critical chance, lasts for 5 seconds",thistype.callbackATK_CRIT);
            thistype.create(IATTR_ATK_AMP,413,"On Attack: Target takes "," extra damage, lasts for 3 seconds",thistype.callbackATK_AMP);
            thistype.create(IATTR_ATK_MD,414,"On Attack: Deals "," magical damage, scaled up by your attack power and spell power",thistype.callbackATK_MD);
            thistype.create(IATTR_ATK_MDK,415,"On Attack: Deals "," magical damage, scaled up by target HP lost",thistype.callbackATK_MDK);
            thistype.create(IATTR_ATK_MORTAL,416,"On Attack: Decrease target healing taken by ","",thistype.callbackATK_MORTAL);
            thistype.create(IATTR_ATK_MISS,417,"On Attack: Decrease target attack hit chance by ","",thistype.callbackATK_MISS);
            thistype.create(IATTR_ATK_DDEF,418,"On Attack: Decrease target armor by ","",thistype.callbackATK_DDEF);
            thistype.create(IATTR_ATK_DAS,419,"On Attack: Decrease target attack speed by ","",thistype.callbackATK_DAS);
            thistype.create(IATTR_ATK_DMS,420,"On Attack: Decrease target movement speed by ","",thistype.callbackATK_DMS);
            thistype.create(IATTR_ATK_WEAK,421,"On Attack: Decrease target damage and healing dealt by ","",thistype.callbackATK_WEAK);
            thistype.create(IATTR_3ATK_MOONEXP,430,"Every Third Attack: Consumes 5% of max MP, deals "," magical damage to all enemies nearby",thistype.callback3ATK_MOONEXP);
            thistype.create(IATTR_MD_MREGEN,450,"Spell Damage: 1% chance to regen "," MP",thistype.callbackMD_MREGEN);
            thistype.create(IATTR_MD_POISON,451,"Spell Damage: 10% chance to poison target, dealing "," magical damage over time",thistype.callbackMD_POISON);
            thistype.create(IATTR_MD_CHAIN,452,"Spell Damage: 10% chance to cast Chain Lightning to target, dealing "," magical damage",thistype.callbackMD_CHAIN);
            thistype.create(IATTR_MDC_ARCANE,460,"Spell Critical: Charges with arcane power. All arcane power will be released automatically after 3 stacks, dealing "," magical damage to target",thistype.callbackMDC_ARCANE);
            thistype.create(IATTR_DT_MREGEN,500,"On Damaged: Regens MP from "," of the damage taken",thistype.callbackDT_MREGEN);
            thistype.create(IATTR_ATKED_WEAK,600,"On Attacked: Decreases attacker's attack power by ","",thistype.callbackATKED_WEAK);
            thistype.create(IATTR_HEAL_HOLY,700,"On Healed: Charges 1 holy power","",thistype.callbackHEAL_HOLY);
            thistype.create(IATTR_AURA_CONVIC,800,"Grant Aura of Conviction: All enemies within 600 yards take "," more magical damage",thistype.callbackAURA_CONVIC);
            thistype.create(IATTR_AURA_MEDITA,801,"Grant Aura of Meditation: All allies within 600 yards regen "," MP per second",thistype.callbackAURA_MEDITA);
            thistype.create(IATTR_AURA_WARSONG,802,"Grant Aura of Warsong: All allies deal "," more damage and healing, take 10% more healing within 600 yards",thistype.callbackAURA_WARSONG);
            thistype.create(IATTR_AURA_UNHOLY,803,"Grant Aura of Unholy: All allies within 600 yards regen "," HP per second",thistype.callbackAURA_UNHOLY);
            thistype.create(IATTR_USE_TP,900,"Use: Teleports to an ally","",thistype.callbackUSE_TP);
            thistype.create(IATTR_USE_BATTLE,901,"Use: Battle Orders, increases "," max HP to all allies within 900 yards, lasts for 75 seconds",thistype.callbackUSE_BATTLE);
            thistype.create(IATTR_USE_MREGEN,902,"Use: Regens "," MP",thistype.callbackUSE_MREGEN);
            thistype.create(IATTR_USE_HREGEN,903,"Use: Regens "," HP",thistype.callbackUSE_HREGEN);
            thistype.create(IATTR_USE_VOODOO,904,"Use: Deals "," magical damage to all enemies within range over time",thistype.callbackUSE_VOODOO);
            thistype.create(IATTR_USE_INT,905,"Use: Increase intelligence by ",", lasts for 20 seconds",thistype.callbackUSE_INT);
            thistype.create(IATTR_USE_SP,906,"Use: Increase spell power by ",", lasts for 15 seconds",thistype.callbackUSE_SP);
            thistype.create(IATTR_USE_DODGE,907,"Use: Increase dodge chance by 30%, lasts for "," seconds",thistype.callbackUSE_DODGE);
            thistype.create(IATTR_USE_MS,908,"Use: Increase movement speed by 300, lasts for "," seconds. Possible failures.",thistype.callbackUSE_MS);
            thistype.create(IATTR_USE_CTHUN,909,"Use: Increase attack speed by 40%, take "," extra damage",thistype.callbackUSE_CTHUN);
            thistype.create(IATTR_USE_HOLYHEAL,910,"Use: Release all holy power to heal yourself, each point heals "," HP",thistype.callbackUSE_HOLYHEAL);
        }
    }

    function onInit() {
        ItemAttributes = Table.create();
        
        TriggerAnyUnit(EVENT_PLAYER_UNIT_PICKUP_ITEM, function itemon);
        TriggerAnyUnit(EVENT_PLAYER_UNIT_DROP_ITEM, function itemoff);
    }
}
//! endzinc
