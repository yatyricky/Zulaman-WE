//! zinc
library PulseBomb requires DamageSystem, PlayerUnitList {
#define ART_TARGET "Abilities\\Spells\\Other\\SoulBurn\\SoulBurnbuff.mdl"
#define ART_DAMAGE "Abilities\\Weapons\\LordofFlameMissile\\LordofFlameMissile.mdl"

    function onEffect(Buff buf) {
        integer i = 0;
        DamageTarget(buf.bd.caster, buf.bd.target, 100.0, SpellData[SID_PULSE_BOMB].name, false, false, false, WEAPON_TYPE_WHOKNOWS);
        AddTimedEffect.atUnit(ART_DAMAGE, buf.bd.target, "origin", 0.0);
        while (i < PlayerUnits.n) {
            if (!IsUnitDead(PlayerUnits.units[i]) && !IsUnitDummy(PlayerUnits.units[i]) && !IsUnit(PlayerUnits.units[i], buf.bd.target) && GetDistance.units2d(buf.bd.target, PlayerUnits.units[i]) < DBMArchTinker.bombAOE) {
                DamageTarget(buf.bd.caster, PlayerUnits.units[i], 200.0, SpellData[SID_PULSE_BOMB].name, false, false, false, WEAPON_TYPE_WHOKNOWS);
                AddTimedEffect.atUnit(ART_DAMAGE, PlayerUnits.units[i], "origin", 0.0);
            }
            i += 1;
        }
    }

    function onRemove(Buff buf) {
        DBMArchTinker.bombTarget = null;
    }

    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BID_PULSE_BOMB);
        buf.bd.interval = 1.0;
        buf.bd.tick = 8;
        if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_TARGET, buf, "overhead");}
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        DBMArchTinker.bombTarget = SpellEvent.TargetUnit;
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_PULSE_BOMB, onCast);
        BuffType.register(BID_PULSE_BOMB, BUFF_PHYX, BUFF_NEG);
    }
#undef ART_DAMAGE
#undef ART_TARGET
}
//! endzinc
