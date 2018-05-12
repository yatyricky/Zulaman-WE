//! zinc
library Burning requires DamageSystem {

    function onEffect(Buff buf) {
        integer i;
        for (0 <= i < PlayerUnits.n) {
            if (GetDistance.units2d(buf.bd.caster, PlayerUnits.units[i]) <= 256) {
                DamageTarget(buf.bd.caster, PlayerUnits.units[i], 200.0, SpellData.inst(SID_BURNING, SCOPE_PREFIX).name, false, false, false, WEAPON_TYPE_WHOKNOWS, false);
            }
        }
    }

    function onRemove(Buff buf) {}

    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BID_BURNING);
        buf.bd.interval = 1.0;
        buf.bd.tick = 10;
        if (buf.bd.e0 == 0) {
            buf.bd.e0 = BuffEffect.create(ART_GREEN_LARGE_FIRE, buf, "origin");
        }
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_BURNING, onCast);
        BuffType.register(BID_BURNING, BUFF_PHYX, BUFF_POS);
    }
}
//! endzinc
