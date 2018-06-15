//! zinc
library HolyShock requires SpellEvent, UnitProperty, BeaconOfLight {

    function applyExtraBeacon(DelayTask dt) {
        BeaconOfLight[dt.u0].addExtras(dt.u1);
    }

    function onEffect(Buff buf) {
        DelayTask dt = DelayTask.create(applyExtraBeacon, 0.01);
        dt.u0 = buf.bd.caster;
        dt.u1 = buf.bd.target;
    }

    function onRemove(Buff buf) {
        BeaconOfLight[buf.bd.caster].removeExtras(buf.bd.target);
    }

    function onCast() {
        BuffSlot bs;
        Buff buf;
        integer lvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_HOLY_SHOCK);
        real excrit = 0;
        real amt = GetUnitState(SpellEvent.TargetUnit, UNIT_STATE_MAX_LIFE) * 0.1 * lvl;
        real hdec = UnitProp.inst(SpellEvent.TargetUnit, SCOPE_PREFIX).HealTaken();
        // equiped Justice of Light, won't consume Divine Favour
        if (UnitHasItemOfTypeBJ(SpellEvent.CastingUnit, ITID_LIGHTS_JUSTICE) == true) {
            excrit = 2.0;
        } else {
            bs = BuffSlot[SpellEvent.CastingUnit];
            buf = bs.getBuffByBid(BID_DIVINE_FAVOR_CRIT);
            if (buf != 0) {
                excrit = 2.0;
                bs.dispelByBuff(buf);
                buf.destroy();
            }
        }
        if (hdec == 0) {
            if (GetRandomReal(0, 0.999) < UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).SpellCrit() + excrit) {amt *= 1.5;}
            SetWidgetLife(SpellEvent.TargetUnit, GetWidgetLife(SpellEvent.TargetUnit) + amt);
        } else {
            if (hdec < 1) {amt /= hdec;}
            HealTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, amt, SpellData.inst(SID_HOLY_SHOCK, SCOPE_PREFIX).name, excrit, true);
        }
        AddTimedEffect.atPos(ART_FAERIE_DRAGON_MISSILE, GetUnitX(SpellEvent.TargetUnit), GetUnitY(SpellEvent.TargetUnit), GetUnitZ(SpellEvent.TargetUnit) + 24, 0, 3);
        // extra beacon
        if (HealResult.isCritical && lvl > 2 && GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_BEACON_OF_LIGHT) > 0) {
            buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BID_HOLY_SHOCK);
            buf.bd.tick = -1;
            buf.bd.interval = 6.0;
            buf.bd.boe = onEffect;
            buf.bd.bor = onRemove;
            buf.run();
        }
        BeaconOfLight[SpellEvent.CastingUnit].healBeacons(SpellEvent.TargetUnit, HealResult.amount, "");
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_HOLY_SHOCK, onCast);
        BuffType.register(BID_HOLY_SHOCK, BUFF_MAGE, BUFF_POS);
    }

}
//! endzinc
