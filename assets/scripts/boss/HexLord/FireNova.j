//! zinc
library FireNova requires DamageSystem {

    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModArmor(0 - buf.bd.i0);
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModArmor(buf.bd.i0);
    }

    function onCast() {
        integer i;
        Buff buf;
        i = 0;
        while (i < PlayerUnits.n) {
            if (GetDistance.units2d(PlayerUnits.units[i], SpellEvent.CastingUnit) <= 350.0) {
                // damage
                DamageTarget(SpellEvent.CastingUnit, PlayerUnits.units[i], 800, SpellData.inst(SID_FIRE_NOVA, SCOPE_PREFIX).name, false, true, false, WEAPON_TYPE_WHOKNOWS, true);
                // decrease armor
                buf = Buff.cast(SpellEvent.CastingUnit, PlayerUnits.units[i], BID_FireNova);
                buf.bd.tick = -1;
                buf.bd.interval = 10.0;
                onRemove(buf);
                buf.bd.i0 = 65;
                buf.bd.boe = onEffect;
                buf.bd.bor = onRemove;
                buf.run();
            }
            i += 1;
        }
        VisualEffects.nova(ART_BreathOfFireMissile, GetUnitX(SpellEvent.CastingUnit), GetUnitY(SpellEvent.CastingUnit), 350, 700.0, 15);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_FIRE_NOVA, onCast);
        BuffType.register(BID_FireNova, BUFF_MAGE, BUFF_NEG);
    }

}
//! endzinc
