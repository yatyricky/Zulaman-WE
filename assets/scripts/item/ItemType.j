//! zinc
library ItemType requires ItemAffix {
    public constant integer QLVL_COMMON = 1;
    public constant integer QLVL_UNCOMMON = 2;
    public constant integer QLVL_RARE = 3;
    public constant integer QLVL_RELIC = 4;
    public constant integer QLVL_LEGENDARY = 5;
    public constant real AFFIX_FACTOR_BASE = 15000;
    public constant real AFFIX_FACTOR_DELTA = 2500;
    public constant real SUFIX_MULTIPLIER = 4;
    public constant real PREFIX_STATIC_MOD = -0.5;
    public constant real SUFIX_STATIC_MOD = -0.2;
    public constant real PREFIX_MAX_PROB = 0.9;
    public constant real SUFIX_MAX_PROB = 0.75;

    IntegerPool ipPrefix1;
    IntegerPool ipPrefix2;
    IntegerPool ipSufix;
    
    public struct ItemData {
        private static Table db;
        integer qlvl;
        boolean isConsumable;
        boolean isUnique;
        integer spawnChargeMin, spawnChargeRange;
    
        static method operator[](integer id) -> thistype {
            if (thistype.db.exists(id)) {
                return thistype(thistype.db[id]);
            } else {
                BJDebugMsg(SCOPE_PREFIX+">Unknown item type ID: " + ID2S(id));
                return 0;
            }
        }
        
        //static integer ct = 0;
        
        private static method create(integer id, integer qlvl, boolean ic, boolean iu, integer scm, integer scr) -> thistype {
            thistype this = thistype.allocate();
            thistype.db[id] = this;
            this.qlvl = qlvl;
            this.isConsumable = ic;
            this.isUnique = iu;
            this.spawnChargeMin = scm;
            this.spawnChargeRange = scr;
            //CreateItem(id, ct * 100, 0);
            //ct += 1;
            return this;
        }
        
        static method typeIsConsumable(integer id) -> boolean {
            thistype this;
            if (thistype.db.exists(id)) {
                this = thistype(thistype.db[id]);
                return this.isConsumable;
            } else {
                return false;
            }
        }
    
        private static method onInit() {
            thistype.db = Table.create();

            thistype.create(ITID_ARANS_COUNTER_SPELL_SCROLL, 2, true, false, 1, 1);
            thistype.create(ITID_SPEED_SCROLL, 2, true, false, 1, 1);
            thistype.create(ITID_FRENZY_SCROLL, 2, true, false, 1, 1);
            thistype.create(ITID_DEFEND_SCROLL, 2, true, false, 1, 2);
            thistype.create(ITID_MANA_SCROLL, 2, true, false, 1, 1);
            thistype.create(ITID_HEAL_SCROLL, 3, true, false, 1, 0);
            thistype.create(ITID_ARMAGEDDON_SCROLL, 4, true, false, 1, 0);
            thistype.create(ITID_ROAR_SCROLL, 2, true, false, 1, 1);
            thistype.create(ITID_SLAYER_SCROLL, 3, true, false, 1, 0);
            thistype.create(ITID_SANCTUARY_SCROLL, 3, true, false, 1, 0);
            thistype.create(ITID_SPELL_REFLECTION_SCROLL, 2, true, false, 1, 1);
            thistype.create(ITID_MASS_DISPEL_SCROLL, 2, true, false, 1, 3);
            thistype.create(ITID_MASS_TELEPORT_SCROLL, 2, true, false, 1, 1);
            thistype.create(ITID_CORRUPTION_SCROLL, 2, true, false, 1, 2);
            thistype.create(ITID_BANSHEE_SCROLL, 3, true, false, 1, 0);
            thistype.create(ITID_WEAKEN_CURSE_SCROLL, 4, true, false, 1, 0);

            thistype.create(ITID_LIFE_POTION, 1, true, false, 2, 2);
            thistype.create(ITID_MANA_POTION, 1, true, false, 2, 2);
            thistype.create(ITID_LEECH_POTION, 2, true, false, 1, 1);
            thistype.create(ITID_LIFE_REGEN_POTION, 2, true, false, 1, 1);
            thistype.create(ITID_MANA_REGEN_POTION, 2, true, false, 1, 1);
            thistype.create(ITID_MANA_SOURCE_POTION, 4, true, false, 2, 1);
            thistype.create(ITID_TRANQUILITY_POTION, 2, true, false, 1, 1);
            thistype.create(ITID_BIG_LIFE_POTION, 2, true, false, 2, 1);
            thistype.create(ITID_ARCH_MAGE_POTION, 3, true, false, 2, 1);
            thistype.create(ITID_COMBAT_MASTER_POTION, 3, true, false, 2, 1);
            thistype.create(ITID_EMPERORS_NEW_POTION, 2, true, false, 1, 0);
            thistype.create(ITID_TRANSFER_POTION, 2, true, false, 1, 1);

            thistype.create(ITID_SHIELD_POTION, 3, true, false, 1, 1);
            thistype.create(ITID_FORTRESS_POTION, 3, true, false, 1, 1);
            thistype.create(ITID_DODGE_POTION, 2, true, false, 1, 1);
            thistype.create(ITID_SMALL_INVUL_POTION, 2, true, false, 1, 1);
            thistype.create(ITID_INVUL_POTION, 3, true, false, 1, 0);
            thistype.create(ITID_STONE_SKIN_POTION, 2, true, false, 1, 1);

            thistype.create(ITID_SPELL_POWER_POTION, 2, true, false, 1, 1);
            thistype.create(ITID_SPELL_MASTER_POTION, 2, true, false, 1, 1);
            thistype.create(ITID_ARCANE_POTION, 2, true, false, 1, 1);

            thistype.create(ITID_ANGRY_CAST_POTION, 2, true, false, 1, 1);
            thistype.create(ITID_SPELL_PIERCE_POTION, 2, true, false, 1, 1);
            thistype.create(ITID_UNSTABLE_POTION, 3, true, false, 1, 1);

            thistype.create(ITID_AGILITY_POTION, 2, true, false, 1, 1);
            thistype.create(ITID_ACUTE_POTION, 2, true, false, 1, 1);
            thistype.create(ITID_DEXTERITY_POTION, 2, true, false, 1, 1);

            thistype.create(ITID_CHARM_OF_SIMPLE_HEAL, 2, true, false, 8, 0);
            thistype.create(ITID_CHARM_OF_DISPEL, 2, true, false, 10, 5);
            thistype.create(ITID_CHARM_OF_HEALING_WARD, 2, true, false, 3, 4);
            thistype.create(ITID_CHARM_OF_INNER_FIRE, 2, true, false, 8, 4);
            thistype.create(ITID_CHARM_OF_CHAIN_LIGHTNING, 3, true, false, 3, 2);
            thistype.create(ITID_CHARM_OF_DEATH_FINGER, 3, true, false, 3, 2);
            thistype.create(ITID_CHARM_OF_SIPHON_LIFE, 2, true, false, 5, 4);
            thistype.create('I021', 2, true, false, 4, 4);
            thistype.create(ITID_STRANGE_WAND, 3, true, false, 2, 2);
        }
    }
    
    public function IsItemTypeConsumable(integer id) -> boolean {
        return ItemData.typeIsConsumable(id);
    }
    
    public function CreateItemEx(integer id, real x, real y, real affixValue) -> item {
        item it = CreateItem(id, x + GetRandomReal(-50, 50), y + GetRandomReal(-50, 50));
        real prefixFactor;
        real sufixFactor;
        real prob, prob1;
        boolean prefixDone;
        string itemName;
        if (IsItemTypeConsumable(id)) {
            SetItemCharges(it, GetRandomInt(ItemData[id].spawnChargeMin, ItemData[id].spawnChargeMin + ItemData[id].spawnChargeRange));
        } else {
            prefixFactor = AFFIX_FACTOR_BASE + (GetItemLevel(it) - 1) * AFFIX_FACTOR_DELTA;
            sufixFactor = prefixFactor * SUFIX_MULTIPLIER;
            prob = affixValue / prefixFactor + PREFIX_STATIC_MOD;
            prefixDone = false;
            if (prob > 1.0) {
                prob1 = prob - 1.0;
                if (prob1 > PREFIX_MAX_PROB) {
                    prob1 = PREFIX_MAX_PROB;
                }
                if (GetRandomReal(0, 1) < prob1) {
                    prefixDone = true;
                    ItemAffix.addToItem(it, ipPrefix2.get());
                }
            }
            if (prefixDone == false) {
                if (GetRandomReal(0, 1) < prob) {
                    prefixDone = true;
                    ItemAffix.addToItem(it, ipPrefix1.get());
                }
            }
            prob = (affixValue - prefixFactor) / sufixFactor + SUFIX_STATIC_MOD;
            if (prob > SUFIX_MAX_PROB) {
                prob = SUFIX_MAX_PROB;
            }
            if (GetRandomReal(0, 1) < prob) {
                ItemAffix.addToItem(it, ipSufix.get());
            }
            // itemName = GetAllItemAffixesText(it, 1);
            // BlzSetItemTooltip(it, itemName);
            // BlzSetItemName(it, itemName);
            // print("Set item " + I2HEX(GetHandleId(it)) + " name to: " + itemName);
        }
        return it;
    }

    function onInit() {
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
        ipSufix.add(SUFIX_MASTERY, 10);
        ipSufix.add(SUFIX_BLUR, 10);
        ipSufix.add(SUFIX_STRONGHOLD, 10);
        ipSufix.add(SUFIX_DEEP_SEA, 10);
        ipSufix.add(SUFIX_VOID, 10);
    }
}
//! endzinc
