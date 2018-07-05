//! zinc
library GodOfDeathGlobal requires DamageSystem {

    public struct GodOfDeathGlobalConst {
        static real mindBlastAOE = 300.0;
        static real psychicLinkRange = 300.0;
    }

    public struct GodOfDeathPlatform {
        static boolean setup = false;
        static unit rootOfFilth = null;
        static unit rootOfViciousness = null;
        static unit rootOfFoulness = null;
        static unit boss = null;
        static ListObject/*<Point>*/ eternalGuardianSpawnPts;
        static timer tm;

        static method platformDamage() {
            integer i;
            if (IsUnitDead(thistype.boss) == true) return;

            i = 0;
            while (i < PlayerUnits.n) {
                if (RectContainsUnit(gg_rct_PlatformFilth, PlayerUnits.units[i]) || RectContainsUnit(gg_rct_PlatformViciousness, PlayerUnits.units[i]) || RectContainsUnit(gg_rct_PlatformFoulness, PlayerUnits.units[i])) {
                    DamageTarget(thistype.boss, PlayerUnits.units[i], GetUnitState(PlayerUnits.units[i], UNIT_STATE_MAX_LIFE) * 0.05, SpellData.inst(SID_TELEPORT_PLAYERS, SCOPE_PREFIX).name, false, false, false, WEAPON_TYPE_WHOKNOWS, false);
                }
                i += 1;
            }
        }

        static method start(unit boss) {
            thistype.setup = true;

            thistype.boss = boss;
            // spawn 3 roots
            thistype.rootOfFilth = CreateUnit(Player(MOB_PID), UTID_ROOT_OF_FILTH, -1536, 10432, 0);
            thistype.rootOfViciousness = CreateUnit(Player(MOB_PID), UTID_ROOT_OF_VICIOUSNESS, -1536, 6208, 0);
            thistype.rootOfFoulness = CreateUnit(Player(MOB_PID), UTID_ROOT_OF_FOULNESS, 2688, 6208, 0);
            // boss damage taken reduced by 90%
            UnitProp.inst(boss, SCOPE_PREFIX).damageTaken -= 0.9;
            // start damage
            TimerStart(thistype.tm, 1.0, true, function thistype.platformDamage);
        }

        static method stop() {
            thistype.setup = false;
            thistype.rootOfFilth = null;
            thistype.rootOfViciousness = null;
            thistype.rootOfFoulness = null;
            PauseTimer(thistype.tm);
        }

        static method getRandomPlatform() -> Point {
            integer i = 0;
            Point ret;
            if (thistype.rootOfFilth == null && thistype.rootOfViciousness == null && thistype.rootOfFoulness == null) {
                return 0;
            } else {
                ret = Point.new(0, 0);
                if (thistype.rootOfFilth != null) {
                    i += 1;
                    if (GetRandomInt(1, i) == 1) {
                        ret.x = -897;
                        ret.y = 9858;
                    }
                }
                if (thistype.rootOfViciousness != null) {
                    i += 1;
                    if (GetRandomInt(1, i) == 1) {
                        ret.x = -826;
                        ret.y = 6920;
                    }
                }
                if (thistype.rootOfFoulness != null) {
                    i += 1;
                    if (GetRandomInt(1, i) == 1) {
                        ret.x = 1999;
                        ret.y = 6914;
                    }
                }
                return ret;
            }
        }

        static method onInit() {
            thistype.eternalGuardianSpawnPts = ListObject.create();
            thistype.eternalGuardianSpawnPts.push(Point.new(287, 10510));
            thistype.eternalGuardianSpawnPts.push(Point.new(1981, 10440));
            thistype.eternalGuardianSpawnPts.push(Point.new(82, 7608));
            thistype.eternalGuardianSpawnPts.push(Point.new(2293, 8198));
            thistype.tm = CreateTimer();
        }
    }

    function platformTentacleDeath(unit u) {
        integer utid = GetUnitTypeId(u);
        if (utid == UTID_ROOT_OF_FILTH) {
            GodOfDeathPlatform.rootOfFilth = null;
            UnitProp.inst(GodOfDeathPlatform.boss, SCOPE_PREFIX).damageTaken += 0.3;
        }
        if (utid == UTID_ROOT_OF_VICIOUSNESS) {
            GodOfDeathPlatform.rootOfViciousness = null;
            UnitProp.inst(GodOfDeathPlatform.boss, SCOPE_PREFIX).damageTaken += 0.3;
        }
        if (utid == UTID_ROOT_OF_FOULNESS) {
            GodOfDeathPlatform.rootOfFoulness = null;
            UnitProp.inst(GodOfDeathPlatform.boss, SCOPE_PREFIX).damageTaken += 0.3;
        }
    }

    trigger leavePlatform;

    function leavePlatformAction() -> boolean {
        SetUnitPosition(GetTriggerUnit(), 866, 7822);
        AddTimedEffect.atUnit(ART_MASS_TELEPORT_TARGET, GetTriggerUnit(), "origin", 0.5);
        return false;
    }

    function onInit() {
        RegisterUnitDeath(platformTentacleDeath);

        leavePlatform = CreateTrigger();
        TriggerRegisterEnterRectSimple(leavePlatform, gg_rct_LeaveFilth);
        TriggerRegisterEnterRectSimple(leavePlatform, gg_rct_LeaveViciousness);
        TriggerRegisterEnterRectSimple(leavePlatform, gg_rct_LeaveFoulness);
        TriggerAddCondition(leavePlatform, Condition(function leavePlatformAction));
    }
}
//! endzinc
