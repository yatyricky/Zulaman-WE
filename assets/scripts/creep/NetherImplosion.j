//! zinc
library NetherImplosion requires DamageSystem {

    function response(CastingBar cd) {
        unit tu;
        GroupUnitsInArea(ENUM_GROUP, GetUnitX(cd.caster), GetUnitY(cd.caster), 300.0);
        tu = FirstOfGroup(ENUM_GROUP);
        while (tu != null) {
            GroupRemoveUnit(ENUM_GROUP, tu);
            if (!IsUnitDummy(tu) && !IsUnitDead(tu) && !IsUnitUseless(tu) && GetPidofu(tu) < NUMBER_OF_MAX_PLAYERS) {
                DamageTarget(cd.caster, tu, 1500, SpellData[SID_NETHER_IMPLOSION].name, false, true, false, WEAPON_TYPE_WHOKNOWS);
            }
            tu = FirstOfGroup(ENUM_GROUP);
        }
        tu = null;

        AddTimedEffect.atCoord(ART_WISP_EXPLODE, GetUnitX(cd.caster), GetUnitY(cd.caster), 1.0);
    }

    function onChannel() {
        integer i;
        real angle;
        real ox, oy;
        CastingBar.create(response).launch();

        for (0 <= i < PlayerUnits.n) {
            angle = GetAngle(GetUnitX(SpellEvent.CastingUnit), GetUnitY(SpellEvent.CastingUnit), GetUnitX(PlayerUnits.units[i]), GetUnitY(PlayerUnits.units[i]));
            ox = Cos(angle) * 150.0;
            oy = Sin(angle) * 150.0;
            SetUnitPosition(PlayerUnits.units[i], GetUnitX(SpellEvent.CastingUnit) + ox, GetUnitY(SpellEvent.CastingUnit) + oy);
            AddTimedEffect.atUnit(ART_MASS_TELEPORT_TARGET, PlayerUnits.units[i], "origin", 1.0);
        }
    }

    function onInit() {
        RegisterSpellChannelResponse(SID_NETHER_IMPLOSION, onChannel);
    }
}
//! endzinc
 