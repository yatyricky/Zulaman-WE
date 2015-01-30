//! zinc
library StrongBreeze requires SpellEvent, DamageSystem {
#define SPELL_ID 'A03M'
#define ART "Abilities\\Spells\\NightElf\\Cyclone\\CycloneTarget.mdl"

    struct ThrowDamage {
        private timer tm;
        private unit a, b;
        private integer c;
        
        private method destroy() {
            ReleaseTimer(this.tm);
            this.tm = null;
            this.a = null;
            this.b = null;
            this.deallocate();
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            this.c += 1;
            SetUnitFlyHeight(this.b, Sin(3.1416 / 50 * this.c) * 700.0, 0.0);
            if (this.c > 49) {
                SetUnitFlyHeight(this.b, 0.0, 0.0);
                DamageTarget(this.a, this.b, GetUnitState(this.b, UNIT_STATE_MAX_LIFE) * 0.33, SpellData[SPELL_ID].name, true, false, false, WEAPON_TYPE_WHOKNOWS);
                DestroyEffect(AddSpecialEffect(ART_DUST, GetUnitX(this.b), GetUnitY(this.b)));
                this.destroy();
            }
        }
    
        static method start(unit a, unit b) {
            thistype this = thistype.allocate();
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.a = a;
            this.b = b;
            this.c = 0;
            SetUnitFlyable(b);
            StunUnit(a, b, 2.0);
            TimerStart(this.tm, 0.04, true, function thistype.run);
        }
    }

    function onCast() {
        ThrowDamage.start(SpellEvent.CastingUnit, SpellEvent.TargetUnit);
        DestroyEffect(AddSpecialEffect(ART, GetUnitX(SpellEvent.TargetUnit), GetUnitY(SpellEvent.TargetUnit)));
    }

    function onInit() {
        RegisterSpellEffectResponse(SPELL_ID, onCast);
    }
#undef ART
#undef SPELL_ID 
}
//! endzinc
