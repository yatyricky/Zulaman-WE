//! zinc
library MindTeleport requires ZAMCore, SpellEvent, GodOfDeathGlobal {

    function dpsGoFirst(unit u1, unit u2) -> boolean {
        return IsUnitDPS(u2);
    }
    
    function onCast() {
        integer i;
        integer n;
        Point p;
        UnitListSortRule ulsr;
        p = GodOfDeathPlatform.getRandomPlatform();
        if (p != 0) {
            ulsr = dpsGoFirst;
            PlayerUnits.sortByRule(ulsr);
            n = 3;
            if (n > PlayerUnits.n) {n = PlayerUnits.n;}
            for (0 <= i < n) {
                SetUnitPosition(PlayerUnits.units[i], p.x, p.y);
                AddTimedEffect.atUnit(ART_MASS_TELEPORT_TARGET, PlayerUnits.units[i], "origin", 1.0);
            }
            p.destroy();
        }
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_TELEPORT_PLAYERS, onCast);
    }

}
//! endzinc
