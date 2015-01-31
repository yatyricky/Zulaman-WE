//! zinc
library StratholmeTragedy requires ItemAttributes, ArthassCorruption {
    HandleTable ht;

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        up.ModAttackSpeed(15 * fac);
        up.ModSpeed(20 * fac);
        // +25 damage to minions
        //if (!ht.exists(u)) {ht[u] = 0;}
        //ht[u] = ht[u] + fac;
        RefreshArthassCorruption(u);
    }

    struct StratholmeTragedy1Data {
        private static HandleTable infinititab;
        integer speed;
        
        static method operator[] (item it) -> thistype {
            thistype this;
            if (!thistype.infinititab.exists(it)) {
                this = thistype.allocate();
                thistype.infinititab[it] = this;
                this.speed = 0;
            } else {
                this = thistype.infinititab[it];
            }
            return this;
        }
        
        private static method onInit() {
            thistype.infinititab = HandleTable.create();
        }
    }

    function action1(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        StratholmeTragedy1Data std = StratholmeTragedy1Data[it];
        up.ModAttackSpeed(15 * fac);
        up.ModSpeed(20 * fac);
        // +25 damage to minions
        
        if (fac == 1) {
            std.speed = 10 * GetHeroLevel(u);
        }
        up.ModSpeed(std.speed * fac);
        
        if (!ht.exists(u)) {ht[u] = 0;}
        ht[u] = ht[u] + fac;
        
        RefreshArthassCorruption(u);
    }
    
    function lvledup() -> boolean {
        unit u = GetTriggerUnit();
        integer i;
        item tmpi;
        ItemPropModType ipmt;
        if (ht.exists(u)) {
            if (ht[u] > 0) {
                ipmt = action1;
                i = 0;
                while (i < 6) {
                    tmpi = UnitItemInSlot(u, i);
                    if (GetItemTypeId(tmpi) == ITID_STRATHOLME_TRAGEDY1) {
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
        RegisterItemPropMod(ITID_STRATHOLME_TRAGEDY, action);
        RegisterItemPropMod(ITID_STRATHOLME_TRAGEDY1, action1);
        TriggerAnyUnit(EVENT_PLAYER_HERO_LEVEL, function lvledup);
    }
}
//! endzinc
