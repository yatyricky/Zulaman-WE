//! zinc
library GripOfStaticElectricity requires DamageSystem {
    private struct GripOfDeath {
        private unit caster;
        private unit target;
        private real damage;
        private integer count;
        private timer tm;
        
        private method destroy() {
            ReleaseTimer(this.tm);
            this.tm = null;
            this.caster = null;
            this.target = null;
            this.deallocate();
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            real tx, ty, cx, cy;
            real face;
            if (!IsUnitDead(this.caster) && !IsUnitDead(this.target)) {
                tx = GetUnitX(this.target);
                ty = GetUnitY(this.target);
                face = GetUnitFacing(this.caster) * bj_DEGTORAD;
                cx = GetUnitX(this.caster) + Cos(face) * 128.0;
                cy = GetUnitY(this.caster) + Sin(face) * 128.0;
                tx = tx + (cx - tx) / this.count;
                ty = ty + (cy - ty) / this.count;
                SetUnitPosition(this.target, tx, ty);
                AddTimedLight.atUnits("CLPB", this.caster, this.target, 0.04);
                this.count -= 1;
                if (this.count < 1) {
                    DamageTarget(this.caster, this.target, this.damage, SpellData[SID_GRIP_OF_STATIC_ELECTRICITY].name, false, false, false, WEAPON_TYPE_WHOKNOWS);  
                    AddTimedEffect.atUnit(ART_IMPACT, this.target, "origin", 0.3);
                }
            } else {
                this.count = 0;
            }
            if (this.count < 1) {
                this.destroy();
            }
        }
    
        static method new(unit caster, unit target) {
            thistype this = thistype.allocate();
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.caster = caster;
            this.target = target;
            this.damage = GetDistance.units2d(caster, target) * 0.5;
            this.count = 25;
            StunUnit(caster, target, 1.0);
            TimerStart(this.tm, 0.04, true, function thistype.run);
        }
    }

    function onCast() {
        GripOfDeath.new(SpellEvent.CastingUnit, SpellEvent.TargetUnit);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_GRIP_OF_STATIC_ELECTRICITY, onCast);
    }
}
//! endzinc
