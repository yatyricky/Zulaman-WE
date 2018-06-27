//! zinc
library PsychicWail requires BuffSystem, StunUtils {

    function onEffect(Buff buf) {
        StunUnit(buf.bd.caster, buf.bd.target, 15.0);
    }

    function onRemove(Buff buf) {
        RemoveStun(buf.bd.target);
    }

    function onCast() {
        integer i;
        Buff buf;
        i = 0;
        while (i < PlayerUnits.n) {
            if (GetDistance.units2d(PlayerUnits.units[i], SpellEvent.CastingUnit) <= 350.0) {
                // apply stun debuff
                buf = Buff.cast(SpellEvent.CastingUnit, PlayerUnits.units[i], BID_PsychicWail);
                buf.bd.tick = -1;
                buf.bd.interval = 15.0;
                onRemove(buf);
                if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_SleepTarget, buf, "overhead");}
                buf.bd.boe = onEffect;
                buf.bd.bor = onRemove;
                buf.run();
            }
            i += 1;
        }
        AddTimedEffect.atUnit(ART_SilenceAreaBirth, SpellEvent.CastingUnit, "origin", 1.0);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_PSYCHIC_WAIL, onCast);
        BuffType.register(BID_PsychicWail, BUFF_MAGE, BUFF_NEG);
    }

}
//! endzinc
