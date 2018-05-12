//! zinc
library FrostGrave requires DamageSystem {

    private struct FrostGrave {
        timer tm;
        integer count;
        unit caster, target;
        effect eff;

        private method destroy() {
            ReleaseTimer(this.tm);
            RemoveStun(this.target);
            DestroyEffect(this.eff);
            this.eff = null;
            this.caster = null;
            this.target = null;
            this.deallocate();
        }

        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            if (IsUnitDead(this.target)) {
                this.count = 0;
            } else {
                DamageTarget(this.caster, this.target, 200.0, SpellData.inst(SID_FROST_GRAVE, SCOPE_PREFIX).name, false, true, false, WEAPON_TYPE_WHOKNOWS, false);
            }
            this.count -= 1;

            if (this.count <= 0) {
                this.destroy();
            }
        }

        static method start(unit caster, unit target) {
            thistype this = thistype.allocate();
            this.tm = NewTimer();
            SetTimerData(this.tm, this);

            this.caster = caster;
            this.target = target;
            this.count = 3;

            // play effect
            AddTimedEffect.atUnit(ART_FROST_NOVA, target, "origin", 0.5);
            this.eff = AddSpecialEffectTarget(ART_FREEZING_BREATH, target, "origin");

            StunUnit(caster, target, 3.0);

            TimerStart(this.tm, 1, true, function thistype.run);
        }
    }

    function onCast() {
        FrostGrave.start(SpellEvent.CastingUnit, SpellEvent.TargetUnit);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_FROST_GRAVE, onCast);
    }
}
//! endzinc
