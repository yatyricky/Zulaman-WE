//! zinc
library TerrorHex requires SpellEvent, StunUtils {
#define ART "Abilities\\Spells\\Other\\HowlOfTerror\\HowlCaster.mdl"

    function onCast() {
        integer i = 0;
		while (i < PlayerUnits.n) {
			if (!IsUnitDead(PlayerUnits.units[i])) {
				StunUnit(SpellEvent.CastingUnit, PlayerUnits.units[i], 3.0);
			}
			i += 1;
		}
        AddTimedEffect.atUnit(ART, SpellEvent.CastingUnit, "origin", 0.1);
    }

    function onInit() {
        RegisterSpellEffectResponse(SIDTERRORHEX, onCast);
    }
#undef ART
}
//! endzinc
