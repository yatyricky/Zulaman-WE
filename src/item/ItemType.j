//! zinc
library ItemType requires Table {
    public constant integer QLVL_COMMON = 1;
    public constant integer QLVL_UNCOMMON = 2;
    public constant integer QLVL_RARE = 3;
    public constant integer QLVL_RELIC = 4;
    public constant integer QLVL_LEGENDARY = 5;
    
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

thistype.create('Ial0', 2, true, false, 1, 1);
thistype.create('shas', 2, true, false, 1, 1);
thistype.create('Ifz0', 2, true, false, 1, 1);
thistype.create('spro', 2, true, false, 1, 2);
thistype.create('sman', 2, true, false, 1, 1);
thistype.create('shea', 3, true, false, 1, 0);
thistype.create('I003', 4, true, false, 1, 0);
thistype.create('sror', 2, true, false, 1, 1);
thistype.create('srrc', 3, true, false, 1, 0);
thistype.create('I006', 3, true, false, 1, 0);
thistype.create('I00M', 2, true, false, 1, 1);
thistype.create('I017', 2, true, false, 1, 3);
thistype.create('I002', 2, true, false, 1, 1);
thistype.create('I004', 2, true, false, 1, 2);
thistype.create('I00C', 3, true, false, 1, 0);
thistype.create('I00D', 4, true, false, 1, 0);

thistype.create('phea', 1, true, false, 2, 2);
thistype.create('pman', 1, true, false, 2, 2);
thistype.create('I00A', 2, true, false, 1, 1);
thistype.create('I00Q', 2, true, false, 1, 1);
thistype.create('I00R', 2, true, false, 1, 1);
thistype.create('I00E', 4, true, false, 2, 1);
thistype.create('I00F', 2, true, false, 1, 1);
thistype.create('I00I', 2, true, false, 2, 1);
thistype.create('I00J', 3, true, false, 2, 1);
thistype.create('I00N', 3, true, false, 2, 1);
thistype.create('I00O', 2, true, false, 1, 0);
thistype.create('I01J', 2, true, false, 1, 1);

thistype.create('I00S', 3, true, false, 1, 1);
thistype.create('I00V', 3, true, false, 1, 1);
thistype.create('I00W', 2, true, false, 1, 1);
thistype.create('pnvl', 2, true, false, 1, 1);
thistype.create('pnvu', 3, true, false, 1, 0);
thistype.create('I008', 2, true, false, 1, 1);

thistype.create('I00B', 2, true, false, 1, 1);
thistype.create('I00X', 2, true, false, 1, 1);
thistype.create('I01Q', 2, true, false, 1, 1);

thistype.create('I007', 2, true, false, 1, 1);
thistype.create('I00Z', 2, true, false, 1, 1);
thistype.create('I010', 3, true, false, 1, 1);

thistype.create('I009', 2, true, false, 1, 1);
thistype.create('I011', 2, true, false, 1, 1);
thistype.create('I00Y', 2, true, false, 1, 1);

thistype.create('I01I', 2, true, false, 8, 0);
thistype.create('I01G', 2, true, false, 10, 5);
thistype.create('I01F', 2, true, false, 3, 4);
thistype.create('I01E', 2, true, false, 8, 4);
thistype.create('I005', 3, true, false, 3, 2);
thistype.create('I00G', 3, true, false, 3, 2);
thistype.create('I020', 2, true, false, 5, 4);
thistype.create('I021', 2, true, false, 4, 4);
thistype.create('I023', 3, true, false, 2, 2);
        }
    }

    public function IsItemUnique(item it) -> boolean {
        return GetWidgetLife(it) > 100.0;
    }
    
    public function IsItemTypeConsumable(integer id) -> boolean {
        return ItemData.typeIsConsumable(id);
    }
    
    public function CreateItemEx(integer id, real x, real y) -> item {
        item it = CreateItem(id, x, y);
        if (IsItemTypeConsumable(id)) {
            SetItemCharges(it, GetRandomInt(ItemData[id].spawnChargeMin, ItemData[id].spawnChargeMin + ItemData[id].spawnChargeRange));
        }
        return it;
    }
}
//! endzinc
