//! zinc
library ItemType {
    public constant integer QLVL_COMMON = 1;
    public constant integer QLVL_UNCOMMON = 2;
    public constant integer QLVL_RARE = 3;
    public constant integer QLVL_RELIC = 4;
    public constant integer QLVL_LEGENDARY = 5;
    
    struct ItemData {
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
}
//! endzinc
