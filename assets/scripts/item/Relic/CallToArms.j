//! zinc
library CallToArms requires ItemAttributes, DamageSystem {
    
    function onEffect(Buff buf) {}

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModLife(0 - buf.bd.i1);
    }
    
    function onCast() {
        integer i = 0;
        Buff buf;
        integer diff;
        real amp;
        integer ii = 0;
        item ti;
        amp = 0.0;
        while (ii < 6) {
            ti = UnitItemInSlot(SpellEvent.CastingUnit, ii);
            if (ti != null) {
                amp += ItemExAttributes.getAttributeValue(ti, IATTR_USE_BATTLE, SCOPE_PREFIX+"onCast") * (ItemExAttributes.getAttributeValue(ti, IATTR_LP, SCOPE_PREFIX + "onCast") * 0.33 + 1);
            }
            ii += 1;
        }
        ti = null;
        while (i < PlayerUnits.n) {
            if (GetDistance.units2d(PlayerUnits.units[i], SpellEvent.CastingUnit) <= 900.0 && !IsUnitDead(PlayerUnits.units[i])) {
                buf = Buff.cast(SpellEvent.CastingUnit, PlayerUnits.units[i], BID_CALL_TO_ARMS);
                buf.bd.tick = -1;
                buf.bd.interval = 75.0;
                if (buf.bd.i0 != 6) {
                    buf.bd.i1 = Rounding(GetUnitState(PlayerUnits.units[i], UNIT_STATE_MAX_LIFE) * amp);
                    UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModLife(buf.bd.i1);
                    buf.bd.i0 = 6;
                } else {
                    diff = Rounding(GetUnitState(PlayerUnits.units[i], UNIT_STATE_MAX_LIFE) * amp);
                    UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModLife(diff);
                    buf.bd.i1 += diff;
                }
                buf.bd.boe = onEffect;
                buf.bd.bor = onRemove;
                buf.run();  
            }
            i += 1;
        }
        AddTimedEffect.atUnit(ART_ROAR_CASTER, SpellEvent.CastingUnit, "origin", 1.0);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_CALL_TO_ARMS, onCast);
        BuffType.register(BID_CALL_TO_ARMS, BUFF_MAGE, BUFF_POS);
    }

}
//! endzinc
