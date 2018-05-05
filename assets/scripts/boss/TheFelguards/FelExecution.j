//! zinc
library FelExecution requires SpellEvent, TimerUtils, DamageSystem {

    struct FelExecution {
        private unit caster;
        private integer c;
        private timer tm;
        private unit lastTarget;

        private method destroy() {
            ReleaseTimer(this.tm);
            this.caster = null;
            this.lastTarget = null;
            this.tm = null;
            this.deallocate();
        }

        private strike() {
            // find target
            unit target = PlayerUnits.getNearestWithinExclude(this.caster, 450.0, this.lastTarget);

            if (target != null) {
                this.lastTarget = target;
            }

            if (this.lastTarget == null) {
                this.destroy();
            } else {
                // move
                SetUnitPosition(this.caster, GetUnitX(this.lastTarget), GetUnitY(this.lastTarget));
                AddTimedEffect.atUnit(ART_BLINK, this.caster, "origin", 1.0);
                SetUnitAnimation(this.caster, "Attack");
                DamageTarget(this.caster, this.lastTarget, 1000.0, SpellData.inst(SID_FEL_EXECUTION, SCOPE_PREFIX).name, true, true, true, WEAPON_TYPE_METAL_HEAVY_SLICE);
            }

        }

        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            this.c -= 1;
            if (this.c > -1) {
                this.strike();
            } else {
                this.destroy();
            }
        }

        static method start(unit caster) {
            thistype this = thistype.allocate();
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.c = 6;
            this.caster = caster;
            this.lastTarget = AggroList[this.caster].sort();

            this.strike();
            TimerStart(this.tm, 0.7, true, function thistype.run);
        }

    }

    function onCast() {       
        FelExecution.start(SpellEvent.CastingUnit);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_FEL_EXECUTION, onCast);
    }
}
//! endzinc
