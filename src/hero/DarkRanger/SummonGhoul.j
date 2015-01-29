//! zinc
library SummonGhoul requires SpellEvent, DarkRangerGlobal {
#define ART "Abilities\\Spells\\Undead\\RaiseSkeletonWarrior\\RaiseSkeleton.mdl"

    function delayAddLife(DelayTask dt) {
        UnitProp[dt.u0].ModLife((GetHeroLevel(darkranger[GetPidofu(dt.u0)]) - 1) * 350);
    }

    function onCast() {
        integer id = GetPlayerId(GetOwningPlayer(SpellEvent.CastingUnit));
        real ang = GetUnitFacing(SpellEvent.CastingUnit);
        real x = GetUnitX(SpellEvent.CastingUnit) + 200 * CosBJ(ang + 90.0);
        real y = GetUnitY(SpellEvent.CastingUnit) + 200 * SinBJ(ang + 90.0);
        if (ghoul[id] != null) {
            KillUnit(ghoul[id]);
        }
        ghoul[id] = CreateUnit(Player(id), UTIDGHOUL, x, y, ang);
        SetUnitPositionEx(ghoul[id], x, y);
        AddTimedEffect.atUnit(ART, ghoul[id], "origin", 0.4);
        DelayTask.create(delayAddLife, 0.15).u0 = ghoul[id];        
    }

    function onInit() {
        RegisterSpellEffectResponse(SIDSUMMONGHOUL, onCast);
    }
#undef ART
}
//! endzinc
