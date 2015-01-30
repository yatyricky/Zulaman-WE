//! zinc
library PocketFactory requires SpellEvent, ZAMCore, LightningShield {
    
    struct AttachCaster {
        private static HandleTable ht;
        private unit caster;
        
        private method destroy() {
            this.caster = null;
            this.deallocate();
        }
    
        static method start(unit fac, unit caster) {
            thistype this = thistype.allocate();
            thistype.ht[fac] = this;
            this.caster = caster;
        }
        
        static method recycle(unit fac) {
            thistype this;
            if (thistype.ht.exists(fac)) {
                this = thistype(thistype.ht[fac]);
                LightningShield.shatter(this.caster);
                thistype.ht.flush(fac);
                this.destroy();
            }
        }
        
        private static method onInit() {
            thistype.ht = HandleTable.create();
        }
    }
    
    function factoryDeath(unit u) {
        if (GetUnitTypeId(u) == UTID_POCKET_FACTORY) {
            DBMArchTinker.numberOfFactory -= 1;
            //print("Number of Factories = " + I2S(DBMArchTinker.numberOfFactory));
            AttachCaster.recycle(u);
        }
    }

    function onCast() {
        real ang = GetRandomReal(0, 6.283);
        real x = GetUnitX(SpellEvent.CastingUnit) + Cos(ang) * 250.0;
        real y = GetUnitY(SpellEvent.CastingUnit) + Sin(ang) * 250.0;
        unit u = CreateUnit(Player(MOB_PID), UTID_POCKET_FACTORY, x, y, GetRandomReal(0, 360));
        AttachCaster.start(u, SpellEvent.CastingUnit);
        DBMArchTinker.numberOfFactory += 1;
        //print("Number of Factories = " + I2S(DBMArchTinker.numberOfFactory));
        u = null;
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_POCKET_FACTORY, onCast);
        RegisterUnitDeath(factoryDeath);
    }
}
//! endzinc
