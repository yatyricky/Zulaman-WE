//! zinc
library HolyShock requires SpellEvent, UnitProperty, BeaconOfLight, LightsJustice {
constant integer BUFF_ID = 'A02E';
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
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).spellHaste += buf.bd.r0;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAttackSpeed(buf.bd.i0);
        if (buf.bd.i1 == 1) {
            delayedDosth1.start(buf.bd.caster, buf.bd.target);
        }
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).spellHaste -= buf.bd.r0;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAttackSpeed(0 - buf.bd.i0);
        if (buf.bd.i1 == 1) {
            BeaconOfLight[buf.bd.caster].removeExtras(buf.bd.target);
        }
    }

    function onCast() {
        BuffSlot bs;
        Buff buf;
        integer lvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_HOLY_SHOCK);
        integer id = GetPlayerId(GetOwningPlayer(SpellEvent.CastingUnit));
        real excrit = 0;
        
        // equiped Justice of Light, won't consume Divine Favour
        if (HasLightsJustice(SpellEvent.CastingUnit)) {
            HealTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, (GetUnitState(SpellEvent.TargetUnit, UNIT_STATE_MAX_LIFE) - GetWidgetLife(SpellEvent.TargetUnit)) * 0.75, SpellData.inst(SID_HOLY_SHOCK, SCOPE_PREFIX).name, 2.0);
        } else {
            bs = BuffSlot[SpellEvent.CastingUnit];
            buf = bs.getBuffByBid(BID_DIVINE_FAVOR_CRIT);
            if (buf != 0) {
                excrit = 2.0;
                bs.dispelByBuff(buf);
                buf.destroy();
            }
            HealTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, (GetUnitState(SpellEvent.TargetUnit, UNIT_STATE_MAX_LIFE) - GetWidgetLife(SpellEvent.TargetUnit)) * 0.75, SpellData.inst(SID_HOLY_SHOCK, SCOPE_PREFIX).name, excrit);
        }
        
        AddTimedEffect.atPos(ART_FAERIE_DRAGON_MISSILE, GetUnitX(SpellEvent.TargetUnit), GetUnitY(SpellEvent.TargetUnit), GetUnitZ(SpellEvent.TargetUnit) + 24, 0, 3);
        buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BUFF_ID);
        buf.bd.tick = -1;
        buf.bd.interval = 6.0;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).spellHaste -= buf.bd.r0;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAttackSpeed(0 - buf.bd.i0);
        buf.bd.r0 = 0.1 * lvl;
        buf.bd.i0 = 10 * lvl;
        if (HealResult.isCritical && lvl > 2 && GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_BEACON_OF_LIGHT) > 0) {
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
        RegisterSpellEffectResponse(SID_HOLY_SHOCK, onCast);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
    }


}
//! endzinc
