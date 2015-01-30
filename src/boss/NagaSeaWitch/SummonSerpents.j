//! zinc
library SummonSerpents requires SpellEvent {
#define SPELL_ID 'A03N'

    function onCast() {
        real ang = GetUnitFacing(SpellEvent.CastingUnit);
        CreateUnit(Player(10), UTID_FLYING_SERPENT, GetUnitX(SpellEvent.CastingUnit) + 200 * CosBJ(ang - 90.0), GetUnitY(SpellEvent.CastingUnit) + 200 * SinBJ(ang - 90.0), ang);
        CreateUnit(Player(10), UTID_FLYING_SERPENT, GetUnitX(SpellEvent.CastingUnit) + 200 * CosBJ(ang + 90.0), GetUnitY(SpellEvent.CastingUnit) + 200 * SinBJ(ang + 90.0), ang);
    }

    function onInit() {
        RegisterSpellEffectResponse(SPELL_ID, onCast);
    }
#undef SPELL_ID 
}
//! endzinc
