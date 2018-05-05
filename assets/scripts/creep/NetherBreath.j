//! zinc
library NetherBreath requires DamageSystem {

    function onEffect(Buff buf) { 
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).spellTaken += buf.bd.r0;
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).spellTaken -= buf.bd.r0;
    }
    
    function onCast() {
        integer i;
        real fcaster = GetUnitFacing(SpellEvent.CastingUnit);
        Buff buf;
        Projectile p;
        for (0 <= i < PlayerUnits.n) {
            if (GetAngleDiffDeg(fcaster, GetAngleDeg(GetUnitX(SpellEvent.CastingUnit), GetUnitY(SpellEvent.CastingUnit), GetUnitX(PlayerUnits.units[i]), GetUnitY(PlayerUnits.units[i]))) <= 38.0 && GetDistance.units(SpellEvent.CastingUnit, PlayerUnits.units[i]) <= 800.0) {
                DamageTarget(SpellEvent.CastingUnit, PlayerUnits.units[i], 800.0, SpellData.inst(SID_NETHER_BREATH, SCOPE_PREFIX).name, false, true, false, WEAPON_TYPE_WHOKNOWS);

                buf = Buff.cast(SpellEvent.CastingUnit, PlayerUnits.units[i], BID_NETHER_BREATH);
                buf.bd.tick = -1;
                buf.bd.interval = 12;
                UnitProp.inst(buf.bd.target, SCOPE_PREFIX).spellTaken -= buf.bd.r0;
                buf.bd.r0 = 1.0;
                buf.bd.boe = onEffect;
                buf.bd.bor = onRemove;
                buf.run();
            }
        }

        // just visual effect
        p = Projectile.create();
        p.caster = SpellEvent.CastingUnit;
        p.path = ART_BREATH_OF_FROST_MISSILE;
        p.angle = bj_DEGTORAD * fcaster;
        p.speed = 1050;
        p.distance = 800;
        p.pierce();
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_NETHER_BREATH, onCast);
        BuffType.register(BID_NETHER_BREATH, BUFF_MAGE, BUFF_NEG);
    }
}
//! endzinc
 