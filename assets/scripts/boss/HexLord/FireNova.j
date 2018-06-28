//! zinc
library FireNova requires DamageSystem {

    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModArmor(0 - buf.bd.i0);
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModArmor(buf.bd.i0);
    }

    function response(CastingBar cd) {
        integer i;
        Buff buf;
        i = 0;
        while (i < PlayerUnits.n) {
            if (GetDistance.units2d(PlayerUnits.units[i], cd.caster) <= 350.0) {
                // damage
                DamageTarget(cd.caster, PlayerUnits.units[i], 800, SpellData.inst(SID_FIRE_NOVA, SCOPE_PREFIX).name, false, true, false, WEAPON_TYPE_WHOKNOWS, true);
                // decrease armor
                buf = Buff.cast(cd.caster, PlayerUnits.units[i], BID_FireNova);
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
        VisualEffects.nova(ART_BreathOfFireMissile, GetUnitX(cd.caster), GetUnitY(cd.caster), 350, 700.0, 15);
    }

    function onChannel() {
        CastingBar.create(response).setVisuals(ART_FireBallMissile).launch();
    }

    function onInit() {
        RegisterSpellChannelResponse(SID_FIRE_NOVA, onChannel);
        BuffType.register(BID_FireNova, BUFF_MAGE, BUFF_NEG);
    }

}
//! endzinc
