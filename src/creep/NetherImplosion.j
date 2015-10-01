//! zinc
library NetherImplosion {
/*
pull all targets towards void lord and explode for 1500 damage
*/
#define MAX_HEIGHT 400.0
#define STEP_COUNT 25

    private struct GripOfDeath {
        private unit caster;
        private unit target;
        private real damage;
        private integer count;
        private timer tm;
        
        private method destroy() {
            SetUnitFlyHeight(this.target, 0, 0);
            ReleaseTimer(this.tm);
            this.tm = null;
            this.caster = null;
            this.target = null;
            this.deallocate();
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            real tx, ty, cx, cy;
            real angle;
            real height;
            if (!IsUnitDead(this.caster) && !IsUnitDead(this.target)) {
                tx = GetUnitX(this.target);
                ty = GetUnitY(this.target);
                angle = GetAngle(GetUnitX(this.caster), GetUnitY(this.caster), GetUnitX(this.target), GetUnitY(this.target));
                cx = GetUnitX(this.caster) + Cos(angle) * 128.0;
                cy = GetUnitY(this.caster) + Sin(angle) * 128.0;
                tx = tx + (cx - tx) / this.count;
                ty = ty + (cy - ty) / this.count;
                SetUnitPosition(this.target, tx, ty);

                height = Sin(this.count / STEP_COUNT * bj_PI) * MAX_HEIGHT;
                SetUnitFlyHeight(this.target, height, 0);

                AddTimedLight.atUnits("CLPB", this.caster, this.target, 0.04);
                this.count -= 1;
            } else {
                this.count = 0;
            }
            if (this.count < 1) {
                this.destroy();
            }
        }
    
        static method start(unit caster, unit target) {
            thistype this = thistype.allocate();
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.caster = caster;
            this.target = target;
            SetUnitFlyable(this.target);
            this.count = STEP_COUNT;
            StunUnit(caster, target, 1.0);
            TimerStart(this.tm, 0.04, true, function thistype.run);
        }
    }

    function response(CastingBar cd) {
        integer i;
        for (0 <= i < PlayerUnits.n) {
	        DamageTarget(cd.caster, PlayerUnits.units[i], 1500, SpellData[SID].name, false, true, false, WEAPON_TYPE_WHOKNOWS);
        }

        AddTimedEffect.atCoord(ART_EXPLOSION, GetUnitX(cd.caster), GetUnitY(cd.caster), 1.0);
    }

    function onChannel() {
    	integer i;
        CastingBar.create(response).launch();

        for (0 <= i < PlayerUnits.n) {
	        GripOfDeath.start(SpellEvent.CastingUnit, PlayerUnits.units[i]);
	    }
    }

    functon onInit() {
        RegisterSpellChannelResponse(SID, onChannel);
    }
#undef STEP_COUNT
#undef MAX_HEIGHT
}
//! endzinc
 