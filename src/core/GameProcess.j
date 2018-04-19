//! zinc
library GameProcess requires PlayerUnitList, MobInit {

    struct SeaWitchFlushControl {
        static timer tm;

        static method run() {
            integer i;
            for (0 <= i < PlayerUnits.n) {
                if (RectContainsUnit(gg_rct_FlushAway1, PlayerUnits.units[i])) {
                    SetUnitY(PlayerUnits.units[i], GetUnitY(PlayerUnits.units[i]) - 2.0);
                }
                if (RectContainsUnit(gg_rct_FlushAway2, PlayerUnits.units[i])) {
                    SetUnitX(PlayerUnits.units[i], GetUnitX(PlayerUnits.units[i]) + 3.0);
                }
            }
        }

        static method bossDeath(unit u) {
            if (GetUnitTypeId(u) == UTID_ARCH_TINKER || GetUnitTypeId(u) == UTID_ARCH_TINKER_MORPH) {
                thistype.tm = NewTimer();
                TimerStart(thistype.tm, 0.04, true, function thistype.run);
            }
            if (GetUnitTypeId(u) == UTID_NAGA_SEA_WITCH) {
                ReleaseTimer(thistype.tm);
                thistype.tm = null;
            }
        }

        static method onInit() {
            RegisterUnitDeath(thistype.bossDeath);
        }
    }

    function onInit() {
        TimerStart(CreateTimer(), 2.0, false, function() {
            MobInitAllowArea(1);
        });
    }
}
//! endzinc
