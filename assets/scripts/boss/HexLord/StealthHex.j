//! zinc
library StealthHex requires AggroSystem, SpellEvent, UnitProperty, DamageSystem {
constant string  ART  = "Abilities\\Spells\\Human\\CloudOfFog\\CloudOfFog.mdl";

    struct DanceInShadow {
        private timer tm;
        private unit a, b;
        
        private method destroy() {
            ReleaseTimer(this.tm);
            this.tm = null;
            this.a = null;
            this.b = null;
            this.deallocate();
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            if (GetUnitAbilityLevel(this.a, SID_APIV) > 0 && !IsUnitDead(this.a) && !IsUnitDead(this.b)) {
                IssueTargetOrderById(this.a, SpellData[SID_STEALTH_AMBUSH_HEX].oid, this.b);
            } else {
                UnitRemoveAbility(this.a, SID_APIV);
                UnitRemoveAbility(this.a, SID_STEALTH_AMBUSH_HEX);
                IssueTargetOrderById(this.a, OID_ATTACK, AggroList[this.a].getFirst());
                this.destroy();
            }
        }
        
        private static method ready() {
            thistype this = GetTimerData(GetExpiredTimer());
            if (!IsUnitDead(this.a)) {
                IssueTargetOrderById(this.a, SpellData[SID_STEALTH_AMBUSH_HEX].oid, this.b);
                TimerStart(this.tm, 0.75, true, function thistype.run);
            } else {
                this.destroy();
            }
        }
        
        static method start(unit a, unit b) {
            thistype this = thistype.allocate();
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.a = a;
            this.b = b;
            IssueImmediateOrderById(a, OID_HOLD);
            TimerStart(this.tm, 2.0, false, function thistype.ready);
        }
    }

    function onCast() {
        AddTimedEffect.atCoord(ART, GetUnitX(SpellEvent.CastingUnit), GetUnitY(SpellEvent.CastingUnit), 1.0);
        UnitAddAbility(SpellEvent.CastingUnit, SID_APIV);
        UnitAddAbility(SpellEvent.CastingUnit, SID_STEALTH_AMBUSH_HEX);
        //IssueTargetOrderById(SpellEvent.CastingUnit, SpellData[SID_STEALTH_AMBUSH_HEX].oid, SpellEvent.TargetUnit);
        
        DanceInShadow.start(SpellEvent.CastingUnit, SpellEvent.TargetUnit);
    }
    
    function gotodamage() {
        DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, 800.0, SpellData[SID_STEALTH_AMBUSH_HEX].name, true, false, false, WEAPON_TYPE_METAL_LIGHT_SLICE);
        AddTimedEffect.atUnit(ART_BLEED, SpellEvent.TargetUnit, "origin", 1.0);
        
        UnitRemoveAbility(SpellEvent.CastingUnit, SID_APIV);
        UnitRemoveAbility(SpellEvent.CastingUnit, SID_STEALTH_AMBUSH_HEX);
        IssueTargetOrderById(SpellEvent.CastingUnit, OID_ATTACK, AggroList[SpellEvent.CastingUnit].getFirst());
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_STEALTH_HEX, onCast);
        RegisterSpellEffectResponse(SID_STEALTH_AMBUSH_HEX, gotodamage);
    }

}
//! endzinc
