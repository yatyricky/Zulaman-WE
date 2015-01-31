//! zinc
library SignetOfTheLastDefender requires ItemAttributes {
    HandleTable ht;

    struct SOTLDData {
        private static HandleTable infinititab;
        integer armor;
        
        static method operator[] (item it) -> thistype {
            thistype this;
            if (!thistype.infinititab.exists(it)) {
                this = thistype.allocate();
                thistype.infinititab[it] = this;
                this.armor = 0;
            } else {
                this = thistype.infinititab[it];
            }
            return this;
        }
        
        private static method onInit() {
            thistype.infinititab = HandleTable.create();
        }
    }

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        SOTLDData sd = SOTLDData[it];
        up.ModStr(15 * fac);
        up.dodge += 0.04 * fac;
        up.healTaken += 0.1 * fac;
        
        if (fac == 1) {
            sd.armor = GetHeroLevel(u);
        }
        up.ModArmor(sd.armor * fac);
        
        if (!ht.exists(u)) {ht[u] = 0;}
        ht[u] = ht[u] + fac;
    }
    
    function lvledup() -> boolean {
        unit u = GetTriggerUnit();
        integer i;
        item tmpi;
        ItemPropModType ipmt;
        if (ht.exists(u)) {
            if (ht[u] > 0) {
                ipmt = action;
                i = 0;
                while (i < 6) {
                    tmpi = UnitItemInSlot(u, i);
                    if (GetItemTypeId(tmpi) == ITID_SIGNET_OF_THE_LAST_DEFENDER) {
                        ipmt.evaluate(u, tmpi, -1);
                        ipmt.evaluate(u, tmpi, 1);
                    }
                    i += 1;
                }
            }
        }
        return false;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterItemPropMod(ITID_SIGNET_OF_THE_LAST_DEFENDER, action);
        TriggerAnyUnit(EVENT_PLAYER_HERO_LEVEL, function lvledup);
    }
}
//! endzinc
