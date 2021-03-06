//! zinc
library ForestStomp requires DamageSystem, ForcedMovement {
    
    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModSpeed(0 - buf.bd.i0);
    }
    
    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModSpeed(buf.bd.i0);
    }

    function onCast() {
        integer i;
        real dis, dx, dy;
        Buff buf;
        for (0 <= i < PlayerUnits.n) {
            dis = GetDistance.units(SpellEvent.CastingUnit, PlayerUnits.units[i]);
            if (dis <= 350.0) {
                // damage
                DamageTarget(SpellEvent.CastingUnit, PlayerUnits.units[i], 900.0, SpellData.inst(SID_FOREST_STOMP, SCOPE_PREFIX).name, true, false, false, WEAPON_TYPE_WHOKNOWS, false);

                // move
                dx = (GetUnitX(PlayerUnits.units[i]) - GetUnitX(SpellEvent.CastingUnit)) * 36.0 / dis;
                dy = (GetUnitY(PlayerUnits.units[i]) - GetUnitY(SpellEvent.CastingUnit)) * 36.0 / dis;
                ForceMoveUnitPolar(PlayerUnits.units[i], dx, dy, 20, -0.7);

                // slow
                buf = Buff.cast(SpellEvent.CastingUnit, PlayerUnits.units[i], BID_FOREST_STOMP);
                buf.bd.tick = -1;
                buf.bd.interval = 3.0;
                UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModSpeed(buf.bd.i0);
                buf.bd.i0 = Rounding(UnitProp.inst(buf.bd.target, SCOPE_PREFIX).Speed() * 0.75);
                if (buf.bd.e0 == 0) {
                    buf.bd.e0 = BuffEffect.create(ART_SLOW, buf, "origin");
                }
                buf.bd.boe = onEffect;
                buf.bd.bor = onRemove;
                buf.run();
            }
        }

        AddTimedEffect.atCoord(ART_STOMP, GetUnitX(SpellEvent.CastingUnit), GetUnitY(SpellEvent.CastingUnit), 0.1);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_FOREST_STOMP, onCast);
        BuffType.register(BID_FOREST_STOMP, BUFF_PHYX, BUFF_NEG);
    }
}
//! endzinc
