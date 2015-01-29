//! zinc
library HolyShock requires PaladinGlobal, SpellEvent, UnitProperty, BeaconOfLight, LightsJustice {
#define ART_ID 'e00J'
#define BUFF_ID 'A02E'
    struct delayedDosth1 {
        private timer tm;
        private unit sor, tar;
    
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            BeaconOfLight[this.sor].addExtras(this.tar);
            
            ReleaseTimer(this.tm);
            this.tm = null;
            this.sor = null;
            this.tar = null;
            this.deallocate();
        }
    
        static method start(unit sor, unit tar) {
            thistype this = thistype.allocate();
            this.sor = sor;
            this.tar = tar;
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            TimerStart(this.tm, 0.01, false, function thistype.run);
        }
    }

    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].spellHaste += buf.bd.r0;
        UnitProp[buf.bd.target].ModAttackSpeed(buf.bd.i0);
        if (buf.bd.i1 == 1) {
            delayedDosth1.start(buf.bd.caster, buf.bd.target);
        }
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].spellHaste -= buf.bd.r0;
        UnitProp[buf.bd.target].ModAttackSpeed(0 - buf.bd.i0);
        if (buf.bd.i1 == 1) {
            BeaconOfLight[buf.bd.caster].removeExtras(buf.bd.target);
        }
    }

    function onCast() {
        Buff buf;
        integer lvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDHOLYSHOCK);
        integer id = GetPlayerId(GetOwningPlayer(SpellEvent.CastingUnit));       
        
        // equiped Justice of Light, won't consume Divine Favour
        if (HasLightsJustice(SpellEvent.CastingUnit)) {
            HealTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, (GetUnitState(SpellEvent.TargetUnit, UNIT_STATE_MAX_LIFE) - GetWidgetLife(SpellEvent.TargetUnit)) * 0.75, SpellData[SIDHOLYSHOCK].name, 2.0);
        } else {        
            HealTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, (GetUnitState(SpellEvent.TargetUnit, UNIT_STATE_MAX_LIFE) - GetWidgetLife(SpellEvent.TargetUnit)) * 0.75, SpellData[SIDHOLYSHOCK].name, healCrit[id]);
            if (healCrit[id] > 0) {
                healCrit[id] = 0.0;
            }
        }
        
        AddTimedEffect.byDummy(ART_ID, GetUnitX(SpellEvent.TargetUnit), GetUnitY(SpellEvent.TargetUnit));
        buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BUFF_ID);
        buf.bd.tick = -1;
        buf.bd.interval = 6.0;
        UnitProp[buf.bd.target].spellHaste -= buf.bd.r0;
        UnitProp[buf.bd.target].ModAttackSpeed(0 - buf.bd.i0);
        buf.bd.r0 = 0.1 * lvl;
        buf.bd.i0 = 10 * lvl;
        if (HealResult.isCritical && lvl > 2 && GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDBEACONOFLIGHT) > 0) {
            buf.bd.i1 = 1;
        } //else {
          //  buf.bd.i1 = 0;
        //}
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        BeaconOfLight[SpellEvent.CastingUnit].healBeacons(SpellEvent.TargetUnit, HealResult.amount, "");
    }

    function onInit() {
        RegisterSpellEffectResponse(SIDHOLYSHOCK, onCast);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
    }
#undef BUFF_ID
#undef ART_ID
}
//! endzinc
