//! zinc
library SummonGhoul requires SpellEvent, DarkRangerGlobal, DamageSystem {

    function delayAddLife(DelayTask dt) {
        UnitProp.inst(dt.u0, SCOPE_PREFIX).ModLife((GetHeroLevel(darkranger[GetPidofu(dt.u0)]) - 1) * 350);
    }

    function onCast() {
        integer id = GetPlayerId(GetOwningPlayer(SpellEvent.CastingUnit));
        real ang = GetUnitFacing(SpellEvent.CastingUnit);
        real x = GetUnitX(SpellEvent.CastingUnit) + 200 * CosBJ(ang + 90.0);
        real y = GetUnitY(SpellEvent.CastingUnit) + 200 * SinBJ(ang + 90.0);
        if (ghoul[id] != null) {
            KillUnit(ghoul[id]);
        }
        ghoul[id] = CreateUnit(Player(id), UTID_GHOUL, x, y, ang);
        SetUnitPositionEx(ghoul[id], x, y);
        AddTimedEffect.atUnit(ART_RAISE_SKELETON, ghoul[id], "origin", 0.4);
        DelayTask.create(delayAddLife, 0.15).u0 = ghoul[id];
    }

    function masterDeath(unit u) {
        integer id = GetPidofu(u);
        if (GetUnitTypeId(u) != UTID_DARK_RANGER) return;
        if (ghoul[id] == null) return;
        if (IsUnitDead(ghoul[id]) == true) return;
        KillUnit(ghoul[id]);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_SUMMON_GHOUL, onCast);
        RegisterUnitDeath(masterDeath);
    }

}
//! endzinc
