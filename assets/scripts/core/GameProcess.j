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

    function openNewArea(unit u) {
        integer utid = GetUnitTypeId(u);
        if (utid == UTID_ARCH_TINKER || utid == UTID_ARCH_TINKER_MORPH) {
            MobInitAllowArea(2);
        }
        if (utid == UTID_NAGA_SEA_WITCH) {
            MobInitAllowArea(3);
            ModifyGateBJ(bj_GATEOPERATION_OPEN, gg_dest_ZTsx_0031);
        }
        if (utid == UTID_TIDE_BARON || utid == UTID_TIDE_BARON_WATER) {
            MobInitAllowArea(4);
        }
        if (utid == UTID_WARLOCK) {
            MobInitAllowArea(5);
        }
    }

    function onInit() {
        TimerStart(CreateTimer(), 2.0, false, function() {
            MobInitAllowArea(1);
        });
        RegisterUnitDeath(openNewArea);
    }
}
//! endzinc
