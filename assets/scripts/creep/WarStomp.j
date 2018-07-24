//! zinc
library WarStomp requires DamageSystem {
/*
deals 300 physical damage to all player units within range.
stun 3 seconds.
*/
constant string  ART_CASTER  = "Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl";
constant real AOE = 697.0;
constant real DAMAGE = 300.0;
constant real DURATION = 3.0;

    function response(CastingBar cd) {
        integer i;
        for (0 <= i < PlayerUnits.n) {
            // print(GetUnitNameEx(cd.caster) + " to " + GetUnitNameEx(PlayerUnits.units[i]) + " = " + R2S(GetDistance.units(cd.caster, PlayerUnits.units[i])));
            if (GetDistance.units(cd.caster, PlayerUnits.units[i]) <= AOE) {
                DamageTarget(cd.caster, PlayerUnits.units[i], DAMAGE, SpellData.inst(SID_WAR_STOMP, SCOPE_PREFIX).name, true, false, false, WEAPON_TYPE_WHOKNOWS, false);
                StunUnit(cd.caster, PlayerUnits.units[i], DURATION);
            }
        }

        AddTimedEffect.atCoord(ART_CASTER, GetUnitX(cd.caster), GetUnitY(cd.caster), 0.1);
    }

    function onChannel() {
        CastingBar.create(response).setVisuals(ART_FireBallMissile).launch();
    }

    function onInit() {
        RegisterSpellChannelResponse(SID_WAR_STOMP, onChannel);
    }

}
//! endzinc
