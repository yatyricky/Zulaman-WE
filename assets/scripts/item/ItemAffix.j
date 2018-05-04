//! zinc
library ItemAffix requires Table {
    constant integer MAX_ATTRIBUTES = 4;
    constant integer MAX_LANGUAGES = 2;

    struct AffixRawData {
        static Table ht;
        integer attribute[MAX_ATTRIBUTES];
        real valueLow[MAX_ATTRIBUTES];
        real valueHigh[MAX_ATTRIBUTES];
        integer attributeN;
        string text[MAX_LANGUAGES];
        integer qlvl;
        integer slot;

        static method inst(integer id, string trace) -> thistype {
            if (thistype.ht.exists(id)) {
                return thistype.ht[id];
            } else {
                print("Unregistered AffixRawData: " + I2S(id) + ", trace: " + trace);
                return 0;
            }
        }

        static method create(integer id, integer qlvl, integer slot, integer attrType, real lo, real hi, string textCN, string textEN) -> thistype {
            thistype this = thistype.allocate();
            this.qlvl = qlvl;
            this.slot = slot;
            this.attributeN = 0;
            this.addAttribute(attrType, lo, hi);
            this.text[0] = textCN;
            this.text[1] = textEN;
            thistype.ht[id] = this;
            return this;
        }

        method addAttribute(integer attrType, real lo, real hi) {
            this.attribute[this.attributeN] = attrType;
            this.valueLow[this.attributeN] = lo;
            this.valueHigh[this.attributeN] = hi;
            this.attributeN += 1;
        }

        static method onInit() {
            thistype.ht = Table.create();
            thistype.create(SUFIX_LETHALITY, 1, 2, AFFIX_TYPE_CRIT, 1, 3, "致命之", " of Lethality");
            thistype.create(SUFIX_SNAKE, 1, 2, AFFIX_TYPE_SCRIT, 1, 3, "灵蛇之", " of Snake");
            thistype.create(SUFIX_QUICKNESS, 1, 2, AFFIX_TYPE_AP, 5, 10, "快速之", " of Quickness");
            thistype.create(SUFIX_WIND_SERPENT, 1, 2, AFFIX_TYPE_SHASTE, 4, 8, "风蛇之", " of Wind Serpent");
            thistype.create(SUFIX_BRUTE, 1, 2, AFFIX_TYPE_STR, 6, 12, "蛮力之", " of Brute");
            thistype.create(SUFIX_DEXTERITY, 1, 2, AFFIX_TYPE_AGI, 6, 12, "灵巧之", " of Dexterity");
            thistype.create(SUFIX_WISDOM, 1, 2, AFFIX_TYPE_INT, 6, 12, "学识之", " of Wisdom");
            thistype.create(SUFIX_VITALITY, 1, 2, AFFIX_TYPE_HP, 90, 180, "活力之", " of Vitality");
            thistype.create(SUFIX_CHAMPION, 1, 2, AFFIX_TYPE_STR, 5, 7, "勇士之", " of Champion").addAttribute(AFFIX_TYPE_AP, 8, 11);
            thistype.create(SUFIX_BUTCHER, 1, 2, AFFIX_TYPE_STR, 5, 7, "屠夫之", " of Butcher").addAttribute(AFFIX_TYPE_CRIT, 1, 2);
            thistype.create(SUFIX_ASSASSIN, 1, 2, AFFIX_TYPE_AGI, 5, 7, "刺客之", " of Assassin").addAttribute(AFFIX_TYPE_CRIT, 1, 2);
            thistype.create(SUFIX_RANGER, 1, 2, AFFIX_TYPE_AGI, 5, 7, "游侠之", " of Ranger").addAttribute(AFFIX_TYPE_AP, 8, 11);
            thistype.create(SUFIX_WIZARD, 1, 2, AFFIX_TYPE_INT, 5, 7, "巫师之", " of Wizard").addAttribute(AFFIX_TYPE_SHASTE, 2, 4);
            thistype.create(SUFIX_PRIEST, 1, 2, AFFIX_TYPE_INT, 5, 7, "祭司之", " of Priest").addAttribute(AFFIX_TYPE_MREGEN, 2, 3);
            thistype.create(SUFIX_GUARDIAN, 1, 2, AFFIX_TYPE_HP, 70, 100, "护卫之", " of Guardian").addAttribute(AFFIX_TYPE_DODGE, 1, 2);
            thistype.create(SUFIX_MASTERY, 1, 2, AFFIX_TYPE_SLVL, 1, 3, "精通之", " of Mastery");
            thistype.create(SUFIX_BLUR, 1, 2, AFFIX_TYPE_DODGE, 1, 3, "模糊之", " of Blur");
            thistype.create(SUFIX_STRONGHOLD, 1, 2, AFFIX_TYPE_DEF, 5, 10, "堡垒之", " of Stronghold");
            thistype.create(SUFIX_DEEP_SEA, 1, 2, AFFIX_TYPE_MREGEN, 3, 6, "深海之", " of Deep Sea");
            thistype.create(SUFIX_VOID, 1, 2, AFFIX_TYPE_SP, 12, 24, "虚空之", " of Void");
            thistype.create(PREFIX_HEAVY, 1, 1, AFFIX_TYPE_STR, 4, 6, "厚重的", "Heavy ");
            thistype.create(PREFIX_STRONG, 2, 1, AFFIX_TYPE_STR, 7, 10, "强壮的", "Strong ");
            thistype.create(PREFIX_SHARP, 1, 1, AFFIX_TYPE_AGI, 4, 6, "锋利的", "Sharp ");
            thistype.create(PREFIX_AGILE, 2, 1, AFFIX_TYPE_AGI, 7, 10, "敏捷的", "Agile ");
            thistype.create(PREFIX_SHIMERING, 1, 1, AFFIX_TYPE_INT, 4, 6, "闪耀的", "Shimering ");
            thistype.create(PREFIX_INTELLIGENT, 2, 1, AFFIX_TYPE_INT, 7, 10, "智慧的", "Intelligent ");
            thistype.create(PREFIX_ENDURABLE, 1, 1, AFFIX_TYPE_HP, 60, 90, "耐久的", "Endurable ");
            thistype.create(PREFIX_VIBRANT, 2, 1, AFFIX_TYPE_HP, 91, 150, "生命的", "Vibrant ");
            thistype.create(PREFIX_SKILLED, 1, 1, AFFIX_TYPE_AP, 7, 11, "熟练的", "Skilled ");
            thistype.create(PREFIX_CRUEL, 2, 1, AFFIX_TYPE_AP, 12, 18, "残忍的", "Cruel ");
            thistype.create(PREFIX_ENCHANTED, 1, 1, AFFIX_TYPE_SP, 8, 12, "附魔的", "Enchanted ");
            thistype.create(PREFIX_SORCEROUS, 2, 1, AFFIX_TYPE_SP, 13, 20, "法术的", "Sorcerous ");
            thistype.create(PREFIX_MYSTERIOUS, 1, 1, AFFIX_TYPE_MREGEN, 2, 3, "神秘的", "Mysterious ");
            thistype.create(PREFIX_ETERNAL, 2, 1, AFFIX_TYPE_MREGEN, 4, 5, "永恒的", "Eternal ");
            thistype.create(PREFIX_STEADY, 1, 1, AFFIX_TYPE_DEF, 3, 5, "稳固的", "Steady ");
            thistype.create(PREFIX_TOUGH, 2, 1, AFFIX_TYPE_DEF, 6, 8, "坚硬的", "Tough ");
        }
    }

    public struct ItemAffix {
        static HandleTable ht;
        integer id;
        integer attribute[MAX_ATTRIBUTES];
        real value[MAX_ATTRIBUTES];
        integer attributeN;
        thistype next;

        static method inst(item it, string trace) -> thistype {
            if (thistype.ht.exists(it)) {
                return thistype.ht[it];
            } else {
                return 0;
            }
        }

        static method addToItem(item it, integer id) {
            thistype this;
            thistype index;
            integer i;
            AffixRawData data = AffixRawData.inst(id, "ItemAffix.addToItem");
            if (data != 0) {
                // init Item Affix
                this = thistype.allocate();
                this.id = id;
                this.attributeN = 0;
                i = 0;
                while (i < data.attributeN) {
                    this.addAttribute(data.attribute[i], GetRandomReal(data.valueLow[i], data.valueHigh[i]));
                    i += 1;
                }
                this.next = 0;

                // attach to item
                if (thistype.ht.exists(it)) {
                    index = thistype.ht[it];
                    while (index.next != 0) {
                        index = index.next;
                    }
                    index.next = this;
                } else {
                    thistype.ht[it] = this;
                }
            }
        }

        method addAttribute(integer attrType, real val) {
            this.attribute[this.attributeN] = attrType;
            this.value[this.attributeN] = val;
            this.attributeN += 1;
        }

        static method onInit() {
            thistype.ht = HandleTable.create();
        }
    }

    public function GetAllItemAffixesText(item it, integer lang) -> string {
        ItemAffix data = ItemAffix.inst(it, "GetAllItemAffixesText");
        AffixRawData raw;
        string sb = BlzGetItemTooltip(it);
        string sufix = "";
        string prefix = "";
        while (data != 0) {
            raw = AffixRawData.inst(data.id, "GetAllItemAffixesText");
            if (raw.slot == 1) {
                prefix = prefix + raw.text[lang];
            } else if (raw.slot == 2) {
                sufix = sufix + raw.text[lang];
            } else {
                print("WTF??? GetAllItemAffixesText 155");
            }
            data = data.next;
        }
        if (lang == 0) {
            // Chinese
            sb = sufix + prefix + sb;
        } else if (lang == 1) {
            // English
            sb = prefix + sb + sufix;
        } else {
            print("WTF??? GetAllItemAffixesText 166");
        }
        return sb;
    }

}
//! endzinc
