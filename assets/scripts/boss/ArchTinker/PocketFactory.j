//! zinc
library PocketFactory requires SpellEvent, ZAMCore, LightningShield {

    Point summonPoints[];
    integer summonPointsN;
    
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

    function onLanding(Projectile p) -> boolean {
        unit u = CreateUnit(Player(MOB_PID), UTID_POCKET_FACTORY, p.targetX, p.targetY, GetRandomReal(0, 360));
        AttachCaster.start(u, p.caster);
        DBMArchTinker.numberOfFactory += 1;
        return true;
    }

    function onCast() {
        Point point = summonPoints[GetRandomInt(0, summonPointsN - 1)];
        Projectile p = Projectile.create();
        p.caster = SpellEvent.CastingUnit;
        p.targetX = point.x;
        p.targetY = point.y;
        p.targetZ = GetLocZ(p.targetX, p.targetY);
        p.path = ART_HeroTinkerFactoryMissle;
        p.pr = onLanding;
        p.speed = 400.0;
        p.scale = 3.0;
        p.spill(700.0);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_POCKET_FACTORY, onCast);
        RegisterUnitDeath(factoryDeath);

        summonPoints[0] = Point.new(-7556, -10624);
        summonPoints[1] = Point.new(-7040, -11133);
        summonPoints[2] = Point.new(-8327, -12031);
        summonPointsN = 3;
    }
}
//! endzinc
