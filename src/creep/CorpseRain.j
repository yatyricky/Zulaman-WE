//! zinc
library CorpseRain {
    struct CorpseFall {
        unit mis;

        static method start(integer dummyId, real x, real y) {

        }
    }

    struct CorpseRain {
        timer tm;
        real x, y;
        integer count;
        unit caster;
        
        method destroy() {
            ReleaseTimer(this.tm);
            this.caster = null;
            this.tm = null;
            this.deallocate();
        }
    
        static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            
            if (ModuloInteger(this.count, 25) == 0) {
                // Damage, Heal
            }
            
            if (GetRandomReal(0, 1.0) < 0.7) {
                
            }
            
            this.count -= 1;
            if (this.count <= 0) {
                this.destroy();
            }
        }
    
        static method start(unit caster, real x, real y) {
            thistype this = thistype.allocate();
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            
            this.caster = caster;
            this.x = x;
            this.y = y;
            this.count = 150;
            
            TimerStart(this.tm, 0.04, true, function thistype.run);
        }
    }

    function onCast() {
        CorpseRain.start(SpellEvent.CastingUnit, GetUnitX(SpellEvent.TargetUnit), GetUnitY(SpellEvent.TargetUnit));
    }

    function onInit() {
        RegisterSpellEventResponse(SID_CORPSE_RAIN, onCast);
    }
}
//! endzinc
