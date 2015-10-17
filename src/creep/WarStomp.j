//! zinc
library WarStomp requires DamageSystem {
/*
deals 300 physical damage to all player units within range.
stun 3 seconds.
*/
#define ART_CASTER "Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl"
#define AOE 697.0
#define DAMAGE 300.0
#define DURATION 3.0

    function response(CastingBar cd) {
        integer i;
        for (0 <= i < PlayerUnits.n) {
        	print(GetUnitNameEx(cd.caster) + " to " + GetUnitNameEx(PlayerUnits.units[i]) + " = " + R2S(GetDistance.units(cd.caster, PlayerUnits.units[i])));
            if (GetDistance.units(cd.caster, PlayerUnits.units[i]) <= AOE) {
		        DamageTarget(cd.caster, PlayerUnits.units[i], DAMAGE, SpellData[SID_WAR_STOMP].name, true, false, false, WEAPON_TYPE_WHOKNOWS);
		        StunUnit(cd.caster, PlayerUnits.units[i], DURATION);
            }
        }

        AddTimedEffect.atCoord(ART_CASTER, GetUnitX(cd.caster), GetUnitY(cd.caster), 0.1);
    }

	function onChannel() {
		CastingBar.create(response).launch();
	}

	function onInit() {
		RegisterSpellChannelResponse(SID_WAR_STOMP, onChannel);
	}
#undef ART_CASTER
#undef AOE
#undef DAMAGE
#undef DURATION
}
//! endzinc
