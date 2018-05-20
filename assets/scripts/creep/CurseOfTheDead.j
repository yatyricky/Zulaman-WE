//! zinc
library CurseOfTheDead requires BuffSystem, DamageSystem {

    function onEffect(Buff buf) {}

    function onRemove(Buff buf) {
        integer i = 0;
        real amt = GetUnitState(buf.bd.target, UNIT_STATE_MAX_LIFE) * 0.75;
        while (i < PlayerUnits.n) {
            if (IsUnitDead(PlayerUnits.units[i]) == false && GetDistance.units2d(buf.bd.target, PlayerUnits.units[i]) < 300) {
                DamageTarget(buf.bd.caster, PlayerUnits.units[i], amt, SpellData.inst(SID_CURSE_OF_THE_DEAD, SCOPE_PREFIX).name, false, false, false, WEAPON_TYPE_WHOKNOWS, true);
            }
            i += 1;
        }
        AddTimedEffect.atPos(ART_SKELETAL_MAGE_MISSILE, GetUnitX(buf.bd.target), GetUnitY(buf.bd.target), GetUnitZ(buf.bd.target), 0, 4);
    }

    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BID_CURSE_OF_THE_DEAD);
        buf.bd.tick = -1;
        buf.bd.interval = 5.0;
        if (buf.bd.e0 == 0) {
            buf.bd.e0 = BuffEffect.create(ART_ANTI_MAGIC_SHELL, buf, "overhead");
        }
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_CURSE_OF_THE_DEAD, onCast);
        BuffType.register(BID_CURSE_OF_THE_DEAD, BUFF_MAGE, BUFF_NEG);
    }

}
//! endzinc
