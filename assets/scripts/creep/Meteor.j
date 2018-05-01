//! zinc
library Meteor requires DamageSystem {

    struct Meteor {
        private timer tm;
        private unit caster;
        private real x, y;
        
        private method destroy() {
            ReleaseTimer(this.tm);
            this.tm = null;
            this.caster = null;
            this.deallocate();
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            integer i;
            integer count = 0;
            real damage = 6000.0;
            for (0 <= i < PlayerUnits.n) {
                if (GetDistance.unitCoord(PlayerUnits.units[i], this.x, this.y) < 450.0) {
                    count += 1;
                }
            }
            damage /= count;
            for (0 <= i < PlayerUnits.n) {
                if (GetDistance.unitCoord(PlayerUnits.units[i], this.x, this.y) < 450.0) {
                    DamageTarget(this.caster, PlayerUnits.units[i], damage, SpellData[SID_METEOR].name, true, false, false, WEAPON_TYPE_WHOKNOWS);
                }
            }
            AddTimedEffect.atCoord(ART_CRATER, this.x, this.y, 0.7);
            this.destroy();
        }
        
        static method start(unit caster, real x, real y) {
            thistype this = thistype.allocate();
            this.x = x;
            this.y = y;
            this.caster = caster;
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            TimerStart(this.tm, 1.0, false, function thistype.run);
            AddTimedEffect.atCoord(ART_INFERNAL_BIRTH, x, y, 1.0);
        }
    }

    function onCast() {
        Meteor.start(SpellEvent.CastingUnit, SpellEvent.TargetX, SpellEvent.TargetY);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_METEOR, onCast);
    }
}
//! endzinc
