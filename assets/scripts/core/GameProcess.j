//! zinc
library GameProcess requires PlayerUnitList, MobInit, AggroSystem {
    
    struct BossFightCloseGate[] {
        static destructable blockers[];
        static Point blockerPs[];
        integer blockersN;
        destructable wall;
        Point wallPoint;
        real wallFace;
        boolean isClosed;

        method close() {
            integer i;
            Point p;
            if (this.isClosed == false) {
                this.isClosed = true;
                i = 0;
                while (i < this.blockersN) {
                    p = thistype.blockerPs[this * 16 + i];
                    thistype.blockers[this * 16 + i] = CreateDestructable(DOOD_BLOCKER, p.x, p.y, 0, 1.0, 0);
                    i += 1;
                }
                this.wall = CreateDestructable(DOOD_POWER_WALL, this.wallPoint.x, this.wallPoint.y, this.wallFace, 1.2, 0);
            }
        }

        method open() {
            integer i;
            if (this.isClosed == true) {
                this.isClosed = false;
                i = 0;
                while (i < this.blockersN) {
                    KillDestructable(thistype.blockers[this * 16 + i]);
                    i += 1;
                }
                KillDestructable(this.wall);
            }
        }
    }

    function InitBossGateData() {
        BossFightCloseGate bg = BossFightCloseGate[1];
        BossFightCloseGate.blockerPs[1 * 16 + 0] = Point.new(-6208, -12416);
        BossFightCloseGate.blockerPs[1 * 16 + 1] = Point.new(-6144, -12288);
        BossFightCloseGate.blockerPs[1 * 16 + 2] = Point.new(-6080, -12160);
        BossFightCloseGate.blockerPs[1 * 16 + 3] = Point.new(-6016, -12032);
        BossFightCloseGate.blockerPs[1 * 16 + 4] = Point.new(-5952, -11904);
        BossFightCloseGate.blockerPs[1 * 16 + 5] = Point.new(-5952, -11776);
        BossFightCloseGate.blockerPs[1 * 16 + 6] = Point.new(-5824, -11712);
        bg.wallPoint = Point.new(-6043, -12123);
        bg.wallFace = 331.76;
        bg.blockersN = 7;
        bg.isClosed = false;

        bg = BossFightCloseGate[2];
        BossFightCloseGate.blockerPs[2 * 16 + 0] = Point.new(-5312, -5312);
        BossFightCloseGate.blockerPs[2 * 16 + 1] = Point.new(-5312, -5440);
        BossFightCloseGate.blockerPs[2 * 16 + 2] = Point.new(-5312, -5568);
        BossFightCloseGate.blockerPs[2 * 16 + 3] = Point.new(-5312, -5696);
        bg.wallPoint = Point.new(-5312, -5504);
        bg.wallFace = 0;
        bg.blockersN = 4;
        bg.isClosed = false;

        bg = BossFightCloseGate[3];
        BossFightCloseGate.blockerPs[3 * 16 + 0] = Point.new(5440, -5824);
        BossFightCloseGate.blockerPs[3 * 16 + 1] = Point.new(5568, -5824);
        BossFightCloseGate.blockerPs[3 * 16 + 2] = Point.new(5696, -5824);
        BossFightCloseGate.blockerPs[3 * 16 + 3] = Point.new(5824, -5824);
        BossFightCloseGate.blockerPs[3 * 16 + 4] = Point.new(5952, -5824);
        BossFightCloseGate.blockerPs[3 * 16 + 5] = Point.new(6016, -5952);
        bg.wallPoint = Point.new(5760, -5824);
        bg.wallFace = 90;
        bg.blockersN = 6;
        bg.isClosed = false;

        bg = BossFightCloseGate[4];
        BossFightCloseGate.blockerPs[4 * 16 + 0] = Point.new(5760, 256);
        BossFightCloseGate.blockerPs[4 * 16 + 1] = Point.new(5824, 384);
        bg.wallPoint = Point.new(5751, 355);
        bg.wallFace = 341.13;
        bg.blockersN = 2;
        bg.isClosed = false;

        bg = BossFightCloseGate[5];
        BossFightCloseGate.blockerPs[5 * 16 + 0] = Point.new(8320, 9472);
        BossFightCloseGate.blockerPs[5 * 16 + 1] = Point.new(8192, 9536);
        bg.wallPoint = Point.new(8273, 9475);
        bg.wallFace = 0;
        bg.blockersN = 2;
        bg.isClosed = false;

        bg = BossFightCloseGate[6];
        BossFightCloseGate.blockerPs[6 * 16 + 0] = Point.new(-7488, 7488);
        BossFightCloseGate.blockerPs[6 * 16 + 1] = Point.new(-7360, 7488);
        BossFightCloseGate.blockerPs[6 * 16 + 2] = Point.new(-7232, 7488);
        BossFightCloseGate.blockerPs[6 * 16 + 3] = Point.new(-7104, 7488);
        BossFightCloseGate.blockerPs[6 * 16 + 4] = Point.new(-6976, 7488);
        BossFightCloseGate.blockerPs[6 * 16 + 5] = Point.new(-6848, 7488);
        bg.wallPoint = Point.new(-7168, 7424);
        bg.wallFace = 90;
        bg.blockersN = 6;
        bg.isClosed = false;
    }

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

    function enableOutOfCatacombAfterAnime(DelayTask dt) {
        isOutOfTheCatacombOpen = true;
    }

    function openRockGate(rect whichRect) {
        EnumDestructablesInRect(whichRect, null, function() {
            destructable iter = GetEnumDestructable();
            if (GetDestructableTypeId(iter) == DOOD_ROCK) {
                KillDestructable(iter);
            }
            iter = null;
        });
    }

    function openNewArea(unit u) {
        integer utid = GetUnitTypeId(u);
        if (utid == UTID_ARCH_TINKER || utid == UTID_ARCH_TINKER_MORPH) {
            MobInitAllowArea(2);
            openRockGate(gg_rct_AreaEntrance2);
        }
        if (utid == UTID_NAGA_SEA_WITCH) {
            MobInitAllowArea(3);
            openRockGate(gg_rct_AreaEntrance3);
            // open the gay!
            EnumDestructablesInRect(gg_rct_MainGate, null, function() {
                destructable iter = GetEnumDestructable();
                if (GetDestructableTypeId(iter) == 'ZTsx') {
                    KillDestructable(iter);
                    SetDestructableAnimation(iter, "Death Alternate");
                }
                iter = null;
            });
        }
        if (utid == UTID_TIDE_BARON || utid == UTID_TIDE_BARON_WATER) {
            MobInitAllowArea(4);
            openRockGate(gg_rct_AreaEntrance4);
        }
        if (utid == UTID_WARLOCK) {
            MobInitAllowArea(5);
            openRockGate(gg_rct_AreaEntrance5);
        }
        if (utid == UTID_PIT_ARCHON) {
            MobInitAllowArea(6);
            DelayTask.create(enableOutOfCatacombAfterAnime, 9.0);
            BlzSetSpecialEffectRoll(AddSpecialEffect(ART_ShimmeringPortal, 10897, 9536), bj_PI);
            AbyssArchonGlobal.wipeWraiths();
        }
        if (utid == UTID_FEL_GUARD) {
            MobInitAllowArea(7);
            openRockGate(gg_rct_AreaEntrance7);
        }
        if (utid == UTID_HEX_LORD) {
            MobInitAllowArea(8);
        }
    }

    function bossAggro(unit u) {
        integer utid;
        if (GetPidofu(u) == MOB_PID) {
            if (IsUnitType(u, UNIT_TYPE_HERO)) {
                utid = GetUnitTypeId(u);
                if (utid == UTID_ARCH_TINKER || utid == UTID_ARCH_TINKER_MORPH) {
                    BossFightCloseGate[1].close();
                }
                if (utid == UTID_NAGA_SEA_WITCH) {
                    BossFightCloseGate[2].close();
                }
                if (utid == UTID_TIDE_BARON || utid == UTID_TIDE_BARON_WATER) {
                    BossFightCloseGate[3].close();
                }
                if (utid == UTID_WARLOCK) {
                    BossFightCloseGate[4].close();
                    DanceMatConst.reset();
                }
                if (utid == UTID_PIT_ARCHON) {
                    BossFightCloseGate[5].close();
                }
                if (utid == UTID_FEL_GUARD) {
                    BossFightCloseGate[6].close();
                }
                if (utid == UTID_GOD_OF_DEATH) {
                    SetUnitState(u, UNIT_STATE_MANA, 0);
                }
            }
        } else {
            loge("Other units in moblist");
        }
    }

    function combatEnd(boolean state) {
        if (state == false) {
            BossFightCloseGate[1].open();
            BossFightCloseGate[2].open();
            BossFightCloseGate[3].open();
            BossFightCloseGate[4].open();
            BossFightCloseGate[5].open();
            BossFightCloseGate[6].open();
        }
    }

    trigger outOfTheCrypt;
    boolean isOutOfTheCatacombOpen;

    function outOfTheCryptAction() -> boolean {
        if (isOutOfTheCatacombOpen == true) {
            SetUnitPosition(GetTriggerUnit(), 3327, 12812);
            PanCameraToTimedForPlayer(GetOwningPlayer(GetTriggerUnit()), 3327, 12812, 1.00);
        }
        return false;
    }

    function onInit() {
        TimerStart(CreateTimer(), 2.0, false, function() {
            MobInitAllowArea(1);
        });
        RegisterUnitDeath(openNewArea);
        RegisterAggroEvent(bossAggro);
        RegisterCombatStateNotify(combatEnd);
        InitBossGateData();

        isOutOfTheCatacombOpen = false;
        outOfTheCrypt = CreateTrigger();
        TriggerRegisterEnterRectSimple(outOfTheCrypt, gg_rct_OutOfCatacomb);
        TriggerAddCondition(outOfTheCrypt, Condition(function outOfTheCryptAction));
    }
}
//! endzinc
