//! zinc
library AllianceAIAction requires AggroSystem, CombatFacts, CastingBar, PaladinGlobal, FrostNova, WarlockGlobal {
#define AIACTION_INTERVAL 0.33
    
    Table unitCallBack, unitLearSkill;
    type UnitActionType extends function(unit);

    timer globalTimer;
    boolean flip;
    unit aiu[];
    integer ain;
    //real positionX[];
    //real positionY[];
    //real positionR[];
    
    function ShouldIGiveWay(unit source, unit tar) -> boolean {
        ModelInfo ms = ModelInfo.get(GetUnitTypeId(source), "AllianceAIAction: 16");
        //ModelInfo mt = ModelInfo[GetUnitTypeId(tar)];
        if (ms.career == CAREER_TYPE_TANK) {
            return false;
        } else {
            return true;
        }/* else {
            if (mt.career == CAREER_TYPE_DPS) {
                return false;
            } else {
                return true;
            }
        }*/
    }

    function IssueNormalAttackOrder(unit source, unit target) {
        if (HexLordGlobalConst.normalAttackForbid) {
            IssueImmediateOrderById(source, OID_HOLD);
        } else {
            IssueTargetOrderById(source, OID_ATTACK, target);
        }
    }
    
    // true: i'm good / false: hang on, i've got business
    function PositioningArchTinker(unit source) -> boolean {
        unit tar;
        real alpha, dTheta, dis, x1, y1, x2, y2;
        integer i;
        LaserFireDamage fire;
        boolean flag;
        // Never go out of 1200
        if (GetDistance.units2d(source, whichBoss) >= DBMArchTinker.gripRange * 0.9) {
            if (IsUnitChanneling(source)) {
                IssueImmediateOrderById(source, OID_STOP);
            }
            IssuePointOrderById(source, OID_MOVE, GetUnitX(whichBoss), GetUnitY(whichBoss)); 
            return false;
        } else {
            // I'm the target of laser beam
            if (IsUnit(source, DBMArchTinker.laserTarget)) {
                if (GetDistance.unitCoord(source, DBMArchTinker.laserX, DBMArchTinker.laserY) > 400.0) {
                    // do not panic if it's still far away
                    return true;
                } else {
                    // run away little girl, run away!
                    dis = GetDistance.units2d(source, whichBoss);                    
                    if (dis < DBMArchTinker.gripRange * 0.8) {
                        // run straight line first
                        IssuePointOrderById(source, OID_MOVE, 2 * GetUnitX(source) - GetUnitX(whichBoss), 2 * GetUnitY(source) - GetUnitY(whichBoss));
                    } else {
                        // then on the circle CCW
                        dTheta = Asin(150 / dis) * 2;
                        alpha = GetAngle(GetUnitX(whichBoss), GetUnitY(whichBoss), GetUnitX(source), GetUnitY(source));
                        alpha += dTheta;
                        x1 = Cos(alpha) * dis + GetUnitX(whichBoss);
                        y1 = Sin(alpha) * dis + GetUnitY(whichBoss);
                        IssuePointOrderById(source, OID_MOVE, x1, y1);
                    }
                    return false;
                }
            } else {
                // keep distance from allies
                tar = PlayerUnits.getNearest(source);
                if (tar != null && GetDistance.units2d(tar, source) <= DBMArchTinker.bombAOE && ShouldIGiveWay(source, tar)) {
                    // too close, separate
                    IssuePointOrderById(source, OID_MOVE, 2 * GetUnitX(source) - GetUnitX(tar), 2 * GetUnitY(source) - GetUnitY(tar));
                    return false;
                } else {
                    // clockwork goblin is casting self destruct nearby
                    // [+]tar = GetSelfDestructingClockwerkGoblin(source);
                    tar = null;
                    i = 0;
                    while (i < MobList.n && tar == null) {
                        if (GetUnitTypeId(MobList.units[i]) == UTID_CLOCKWORK_GOBLIN) {
                            if (GetDistance.units2d(MobList.units[i], source) <= DBMArchTinker.selfDestructAOE) {
                                if (IsUnitChanneling(MobList.units[i])) {
                                    tar = MobList.units[i];
                                }
                            }
                        }
                        i += 1;
                    }
                    if (tar != null) {
                        IssuePointOrderById(source, OID_MOVE, 2 * GetUnitX(source) - GetUnitX(tar), 2 * GetUnitY(source) - GetUnitY(tar));
                        return false;
                    } else {
                        // do not stand in fire
                        i = 0;
                        flag = true;
                        while (i < LaserFireDamage.num && flag) {
                            fire = LaserFireDamage.instances[i];
                            if (GetDistance.unitCoord(source, fire.x, fire.y) <= DBMArchTinker.laserBeamAOE) {
                                flag = false;
                            } else {
                                i += 1;
                            }
                        }
                        // [+]IsUnitStandingOnLaserBeamFire(source)
                        if (flag) {
                            return true; 
                        } else {         
                            // [+]MoveOutOfLaserBeamFire(source)
                            if (LaserFireDamage.num > 1) {
                                if ((i > 0) && (i < LaserFireDamage.num - 1)) {
                                    fire = LaserFireDamage.instances[i - 1];
                                    x1 = fire.x; y1 = fire.y;
                                    fire = LaserFireDamage.instances[i + 1];
                                    x2 = fire.x; y2 = fire.y;
                                } else if (i == 0) {
                                    fire = LaserFireDamage.instances[i];
                                    x1 = fire.x; y1 = fire.y;
                                    fire = LaserFireDamage.instances[i + 1];
                                    x2 = fire.x; y2 = fire.y;
                                } else {
                                    fire = LaserFireDamage.instances[i - 1];
                                    x1 = fire.x; y1 = fire.y;
                                    fire = LaserFireDamage.instances[i];
                                    x2 = fire.x; y2 = fire.y;
                                }
                                alpha = (x1 - x2) / (y2 - y1);
                                dis = SquareRoot(90000.0 / (1 + alpha * alpha));
                                dTheta = alpha * dis;
                                IssuePointOrderById(source, OID_MOVE, (x2 - x1) / 2.0 + x1 + dis, (y2 - y1) / 2.0 + y1 + dTheta);
                            } else {
                                IssuePointOrderById(source, OID_MOVE, 2 * GetUnitX(source) - fire.x, 2 * GetUnitY(source) - fire.y);
                            }
                            return false;
                        }
                    }
                }
            }
        }
    }
    
    function PositioningNagaSeaWitch(unit source) -> boolean {
        unit tar;
        if (DBMNagaSeaWitch.isStorm) {
            // storm
            if (GetDistance.units2d(source, DBMNagaSeaWitch.stormTarget) > DBMNagaSeaWitch.safeRange) {
                if (IsUnitChanneling(source)) {
                    IssueImmediateOrderById(source, OID_STOP);
                }
                IssuePointOrderById(source, OID_MOVE, GetUnitX(DBMNagaSeaWitch.stormTarget), GetUnitY(DBMNagaSeaWitch.stormTarget));                    
            } else {
                // IssueImmediateOrderById(source, OID_HOLD);
                return true;
            }
            return false;
        } else {
            // keep distance                
            tar = PlayerUnits.getNearest(source);
            if (tar != null && GetDistance.units2d(tar, source) <= DBMNagaSeaWitch.forkedLightningAOE && ShouldIGiveWay(source, tar)) {
                // too close, separate
                IssuePointOrderById(source, OID_MOVE, 2 * GetUnitX(source) - GetUnitX(tar), 2 * GetUnitY(source) - GetUnitY(tar));
                return false;
            } else {
                // normal
                tar = PlayerUnits.getFarest(whichBoss);
                if (GetUnitAbilityLevel(tar, BID_FUCKED_LIGHTNING) > 0) {
                    if (IsUnit(tar, source)) {
                        IssuePointOrderById(source, OID_MOVE, GetUnitX(whichBoss), GetUnitY(whichBoss));
                        return false;
                    } else {
                        if (IsUnitType(source, UNIT_TYPE_RANGED_ATTACKER) && GetUnitAbilityLevel(source, BID_FUCKED_LIGHTNING) == 0) {
                            IssuePointOrderById(source, OID_MOVE, 2 * GetUnitX(source) - GetUnitX(whichBoss), 2 * GetUnitY(source) - GetUnitY(whichBoss));
                            return false;
                        } else {
                            return true;
                        }
                    }
                } else {
                    return true;
                }
            }
        }
    }
    
    function PositioningTideBaron(unit source) -> boolean {
        unit tar;
		ModelInfo ms;
		AggroList al;
		//vector vo, vm, vc;
		real t1, t2;
        if (GetUnitTypeId(whichBoss) == UTIDTIDEBARON) {
            // Naga form, nothing painful
            return true;
        } else {
            // Water form
			//	- keep away from allies
			tar = PlayerUnits.getNearest(source);
			if (tar != null && GetDistance.units2d(tar, source) <= DBMTideBaron.alkalineWaterAOE) {
				// too close, separate
				IssuePointOrderById(source, OID_MOVE, 2 * GetUnitX(source) - GetUnitX(tar), 2 * GetUnitY(source) - GetUnitY(tar));
				return false;
			} else {
				//	- tank should not aggro
				ms = ModelInfo.get(GetUnitTypeId(source), "AllianceAIAction: 194");
				if (ms.career == CAREER_TYPE_TANK) {
					al = AggroList[whichBoss];
					t1 = al.getAggro(source) + 500;
					t2 = al.getAggro(al.getFirst());
					if (t1 / t2 > DBMTideBaron.safeAggroPercent) {
						IssueImmediateOrderById(source, OID_HOLD);
						return false;
					} else {
						return true;
					}
				} else {
					// normal
					return true;
				}
			}
			/*else {
            // separate allies in angular way
				tar = PlayerUnits.getNearestAngular(source, whichBoss);
				if (tar != null && GetDistance.units2dAngular(tar, source, whichBoss) <= DBMTideBaron.safeAngle && ShouldIGiveWay(source, tar)) {
					// 	- don't line up
					vm = vector.create(0,0,0);
					vo = vector.create(0,0,0);
					vc = vector.create(0,0,0);
					vm.pointToUnit(source);
					vo.pointToUnit(tar);
					vc.pointToUnit(whichBoss);
					vm.subtract(vc);
					vo.subtract(vc);
					vo.setLength(vm.getLength());
					vm.subtract(vo);
					IssuePointOrderById(source, OID_MOVE, GetUnitX(source) + vm.x, GetUnitY(source) + vm.y);
					return false;
				} else {

				}
			}*/
        }
    }

    function PositioningWarlock(unit source) -> boolean {
        // vector v;
        // real tx, ty;
        boolean safe;
        real dis, dx, dy;
        unit danger;
        integer i;

        real k1, b1, k2, b2, sx, sy, ym, xm, yo, xo, yt, xt;
        if (DBMWarlock.isFireBomb) {
            // position on firebomb
            safe = true;
            for (0 <= i < FireBombGroup.size) {
                dis = GetDistance.units2d(source, FireBombGroup.bombs[i]);
                if (dis <= DBMWarlock.fireBombRadius) {
                    safe = false;
                    danger = FireBombGroup.bombs[i];
                    break;
                }
            }

            if (safe) {
                // IssueImmediateOrderById(source, OID_HOLD);
                return true;   
            } else {
                dx = 200 * (GetUnitX(source) - GetUnitX(danger)) / dis;
                dy = 200 * (GetUnitY(source) - GetUnitY(danger)) / dis;
                IssuePointOrderById(source, OID_MOVE, GetUnitX(source) + dx, GetUnitY(source) + dy);
                return false;
            }

        } else {
            // dodge flame throw
            if (FlameThrowAux.theBolt == null) {
                return true;
            } else {
                if (GetDistance.units2d(source, FlameThrowAux.theBolt) <= FlameThrowAux.radius * 1.7) {
                    ym = GetUnitY(FlameThrowAux.theBolt);
                    xm = GetUnitX(FlameThrowAux.theBolt);
                    yo = GetUnitY(whichBoss);
                    xo = GetUnitX(whichBoss);
                    yt = GetUnitY(source);
                    xt = GetUnitX(source);
                    k1 = (ym - yo) / (xm - xo);
                    b1 = (xm * yo - ym * xo) / (xm - xo);
                    k2 = -1.0 / k1;
                    b2 = yt - k2 * xt;
                    sx = (b2 - b1) / (k1 - k2);
                    sy = k1 * sx + b1;
                    dis = GetDistance.unitCoord(source, sx, sy);
                    dx = 200 * (xt - sx) / dis;
                    dy = 200 * (yt - sy) / dis;
                    IssuePointOrderById(source, OID_MOVE, xt + dx, yt + dy);
                    return false;
                }
                return true;
            }
        }
        return true;
    }

    function PositioningHexLord(unit source) -> boolean {
        integer i;
        real dis, tmp;
        boolean safe, goFreeze;
        vector v1, v2;
        unit tar;
        Point p1;
        if (DBMHexLord.absorb == UTIDBLOODELFDEFENDER) {
            safe = true;
            for (0 <= i < SunFireStormHexSpots.size()) {
                dis = GetDistance.unitCoord(source, SunFireStormHexSpots.get(i).x, SunFireStormHexSpots.get(i).y);
                if (dis <= HexLordGlobalConst.sunFireAOE) {
                    v1 = vector.create(SunFireStormHexSpots.get(i).x, SunFireStormHexSpots.get(i).y, 0);
                    safe = false;
                    break;
                }
            }
            if (!safe) {
                v2 = vector.create(GetUnitX(source), GetUnitY(source), 0);
                v2.subtract(v1);
                if (v2.getLength() == 0.0) {
                    v2.reset(GetRandomReal(-1, 1), GetRandomReal(-1, 1), 0);
                    if (v2.y == 0.0) {v2.y = 1.0;}
                }
                v2.setLength(HexLordGlobalConst.sunFireAOE * 1.5);
                v2.add(v1);
                IssuePointOrderById(source, OID_MOVE, v2.x, v2.y);
                v1.destroy();
                v2.destroy();
                return false;
            } else {
                return true;
            }
        } else if (DBMHexLord.absorb == UTIDCLAWDRUID) {
            if (GetUnitAbilityLevel(whichBoss, BID_NATURAL_REFLEX_HEX) > 0) {
                HexLordGlobalConst.normalAttackForbid = true;
            } else {
                HexLordGlobalConst.normalAttackForbid = false;
            }
            return true;
        } else if (DBMHexLord.absorb == UTIDDARKRANGER) {
            goFreeze = false;
            if (!IsUnitTank(source)) {
                tar = AggroList[whichBoss].getFirst();
                if (IsUnit(source, tar)) {
                    goFreeze = true;
                }
            }
            if (goFreeze) {
                // OT, go to clear aggro
                dis = 99999;
                for (0 <= i < FreezingTrapHexSpots.size()) {
                    tmp = GetDistance.unitCoord(source, FreezingTrapHexSpots.get(i).x, FreezingTrapHexSpots.get(i).y);
                    if (tmp < dis) {
                        dis = tmp;
                        p1 = FreezingTrapHexSpots.get(i);
                    }
                }
                if (dis < 9999) {
                    IssuePointOrderById(source, OID_MOVE, p1.x, p1.y);
                    return false;
                } else {
                    return true;
                }
            } else {
                // normal or im tank
                safe = true;
                for (0 <= i < FreezingTrapHexSpots.size()) {
                    dis = GetDistance.unitCoord(source, FreezingTrapHexSpots.get(i).x, FreezingTrapHexSpots.get(i).y);
                    if (dis <= HexLordGlobalConst.freezingTrapAOE * 1.5) { // stay safe is always good
                        v1 = vector.create(FreezingTrapHexSpots.get(i).x, FreezingTrapHexSpots.get(i).y, 0);
                        safe = false;
                        break;
                    }
                }
                if (!safe) {
                    v2 = vector.create(GetUnitX(source), GetUnitY(source), 0);
                    v2.subtract(v1);
                    if (v2.getLength() == 0.0) {
                        v2.reset(GetRandomReal(-1, 1), GetRandomReal(-1, 1), 0);
                        if (v2.y == 0.0) {v2.y = 1.0;}
                    }
                    v2.setLength(HexLordGlobalConst.freezingTrapAOE * 2.0);
                    v2.add(v1);
                    IssuePointOrderById(source, OID_MOVE, v2.x, v2.y);
                    v1.destroy();
                    v2.destroy();
                    return false;
                } else {
                    return true;
                }
            }
        } else {
            return true;
        }
    }
    
    function PositioningDone(unit source) -> boolean {
        unit tar;
        integer bossutid = GetUnitTypeId(whichBoss);
        if (bossutid == UTID_ARCH_TINKER || bossutid == UTID_ARCH_TINKER_MORPH) {           
            return PositioningArchTinker(source);
        } else if (GetUnitTypeId(whichBoss) == UTID_NAGA_SEA_WITCH) {
            return PositioningNagaSeaWitch(source);
        } else if (bossutid == UTIDTIDEBARON || bossutid == UTIDTIDEBARONWATER) {
            return PositioningTideBaron(source);
        } else if (bossutid == UTIDWARLOCK) {
            return PositioningWarlock(source);
		} else if (bossutid == UTIDHEXLORD) {
            return PositioningHexLord(source);
        } else {
            return true;
        }
    }
    
    // 1
    function learnSkillHmkg(unit source) {
        if (GetHeroLevel(source) == 1) {
            // 11100
            SelectHeroSkill(source, SIDSHIELDBLOCK);
            SelectHeroSkill(source, SIDSUNFIRESTORM);
            SelectHeroSkill(source, SIDARCANESHOCK);
        } else if (GetHeroLevel(source) == 2) {
            // 00111 -> 
            // 11211
            SelectHeroSkill(source, SIDARCANESHOCK);
            SelectHeroSkill(source, SIDDISCORD);
            SelectHeroSkill(source, SIDSHIELDOFSINDOREI);
        } else if (GetHeroLevel(source) == 3) {
            // 10101
            // 21312
            SelectHeroSkill(source, SIDSHIELDBLOCK);
            SelectHeroSkill(source, SIDARCANESHOCK);
            SelectHeroSkill(source, SIDSHIELDOFSINDOREI);
        } else if (GetHeroLevel(source) == 4) {
            // 02001
            // 23313
            SelectHeroSkill(source, SIDSUNFIRESTORM);
            SelectHeroSkill(source, SIDSUNFIRESTORM);
            SelectHeroSkill(source, SIDSHIELDOFSINDOREI);
        } else if (GetHeroLevel(source) == 5) {
            // 10020
            // 33333
            SelectHeroSkill(source, SIDSHIELDBLOCK);
            SelectHeroSkill(source, SIDDISCORD);
            SelectHeroSkill(source, SIDDISCORD);
        }
    }
    
    // 2
    function learnSkillHlgr(unit source) {
        if (GetHeroLevel(source) == 1) {
            // 11100
            SelectHeroSkill(source, SID_LACERATE);
            SelectHeroSkill(source, SID_SAVAGE_ROAR);
            SelectHeroSkill(source, SID_FOREST_CURE);
        } else if (GetHeroLevel(source) == 2) {
            // 10011
            // 21111
            SelectHeroSkill(source, SID_LACERATE);
            SelectHeroSkill(source, SID_NATURAL_REFLEX);
            SelectHeroSkill(source, SID_SURVIVAL_INSTINCTS);
        } else if (GetHeroLevel(source) == 3) {
            // 10101
            // 31212
            SelectHeroSkill(source, SID_FOREST_CURE);
            SelectHeroSkill(source, SID_NATURAL_REFLEX);
            SelectHeroSkill(source, SID_SURVIVAL_INSTINCTS);
        } else if (GetHeroLevel(source) == 4) {
            // 00111
            // 31323
            SelectHeroSkill(source, SID_LACERATE);
            SelectHeroSkill(source, SID_FOREST_CURE);
            SelectHeroSkill(source, SID_SURVIVAL_INSTINCTS);
        } else if (GetHeroLevel(source) == 5) {
            // 02010
            // 33333
            SelectHeroSkill(source, SID_SAVAGE_ROAR);
            SelectHeroSkill(source, SID_SAVAGE_ROAR);
            SelectHeroSkill(source, SID_NATURAL_REFLEX);
        }
    }
    
    // 3
    function learnSkillEmfr(unit source) {
        if (GetHeroLevel(source) == 1) {
            // 11100
            SelectHeroSkill(source, SIDLIFEBLOOM);
            SelectHeroSkill(source, SIDREJUVENATION);
            SelectHeroSkill(source, SIDREGROWTH);
        } else if (GetHeroLevel(source) == 2) {
            // 01011
            // 12111
            SelectHeroSkill(source, SIDREJUVENATION);
            SelectHeroSkill(source, SIDSWIFTMEND);
            SelectHeroSkill(source, SIDTRANQUILITY);
        } else if (GetHeroLevel(source) == 3) {
            // 01110
            // 13221
            SelectHeroSkill(source, SIDLIFEBLOOM);
            SelectHeroSkill(source, SIDREJUVENATION);
            SelectHeroSkill(source, SIDREGROWTH);
        } else if (GetHeroLevel(source) == 4) {
            // 20010
            // 33231
            SelectHeroSkill(source, SIDLIFEBLOOM);
            SelectHeroSkill(source, SIDREGROWTH);
            SelectHeroSkill(source, SIDSWIFTMEND);
        } else if (GetHeroLevel(source) == 5) {
            // 00102
            SelectHeroSkill(source, SIDSWIFTMEND);
            SelectHeroSkill(source, SIDTRANQUILITY);
            SelectHeroSkill(source, SIDTRANQUILITY);
        }
    }
    
    // 4
    function learnSkillHart(unit source) {
        integer fleshLight = GetFlashLightAID(source);
        if (GetHeroLevel(source) == 1) {
            SelectHeroSkill(source, fleshLight);
            SelectHeroSkill(source, SIDHOLYLIGHT);
            SelectHeroSkill(source, SIDHOLYSHOCK);
        } else if (GetHeroLevel(source) == 2) {
            SelectHeroSkill(source, SIDDIVINEFAVOR);
            SelectHeroSkill(source, SIDDIVINEFAVOR);
            SelectHeroSkill(source, SIDBEACONOFLIGHT);
        } else if (GetHeroLevel(source) == 3) {
            SelectHeroSkill(source, fleshLight);
            SelectHeroSkill(source, SIDHOLYLIGHT);
            SelectHeroSkill(source, SIDDIVINEFAVOR);
        } else if (GetHeroLevel(source) == 4) {
            SelectHeroSkill(source, fleshLight);
            SelectHeroSkill(source, SIDHOLYLIGHT);
            SelectHeroSkill(source, SIDHOLYSHOCK);
        } else if (GetHeroLevel(source) == 5) {
            SelectHeroSkill(source, SIDHOLYSHOCK);
            SelectHeroSkill(source, SIDBEACONOFLIGHT);
            SelectHeroSkill(source, SIDBEACONOFLIGHT);
        }
    }
    
    // 5
    function learnSkillOfar(unit source) {
        if (GetHeroLevel(source) == 1) {
            SelectHeroSkill(source, SIDHEAL);
            SelectHeroSkill(source, SIDPRAYEROFHEALING);
            SelectHeroSkill(source, SIDSHIELD);
        } else if (GetHeroLevel(source) == 2) {
            SelectHeroSkill(source, SIDSHIELD);
            SelectHeroSkill(source, SIDPRAYEROFMENDING);
            SelectHeroSkill(source, SIDDISPEL);
        } else if (GetHeroLevel(source) == 3) {
            SelectHeroSkill(source, SIDHEAL);
            SelectHeroSkill(source, SIDSHIELD);
            SelectHeroSkill(source, SIDPRAYEROFMENDING);
        } else if (GetHeroLevel(source) == 4) {
            SelectHeroSkill(source, SIDHEAL);
            SelectHeroSkill(source, SIDPRAYEROFHEALING);
            SelectHeroSkill(source, SIDPRAYEROFMENDING);
        } else if (GetHeroLevel(source) == 5) {
            SelectHeroSkill(source, SIDPRAYEROFHEALING);
            SelectHeroSkill(source, SIDDISPEL);
            SelectHeroSkill(source, SIDDISPEL);
        }
    }
    
    // 6
    function learnSkillNbrn(unit source) {
        if (GetHeroLevel(source) == 1) {
            SelectHeroSkill(source, SIDDARKARROW);
            SelectHeroSkill(source, SIDCONCERNTRATION);
            SelectHeroSkill(source, SIDFREEZINGTRAP);
        } else if (GetHeroLevel(source) == 2) {
            SelectHeroSkill(source, SIDDARKARROW);
            SelectHeroSkill(source, SIDPOWEROFABOMINATION);
            SelectHeroSkill(source, SIDDEATHPACT);
        } else if (GetHeroLevel(source) == 3) {
            SelectHeroSkill(source, SIDDARKARROW);
            SelectHeroSkill(source, SIDFREEZINGTRAP);
            SelectHeroSkill(source, SIDPOWEROFABOMINATION);
        } else if (GetHeroLevel(source) == 4) {
            SelectHeroSkill(source, SIDCONCERNTRATION);
            SelectHeroSkill(source, SIDFREEZINGTRAP);
            SelectHeroSkill(source, SIDDEATHPACT);
        } else if (GetHeroLevel(source) == 5) {
            SelectHeroSkill(source, SIDCONCERNTRATION);
            SelectHeroSkill(source, SIDPOWEROFABOMINATION);
            SelectHeroSkill(source, SIDDEATHPACT);
        }
    }
    
    // 7
    function learnSkillObla(unit source) {
        if (GetHeroLevel(source) == 1) {
            SelectHeroSkill(source, SID_HEROIC_STRIKE);
            SelectHeroSkill(source, SIDREND);
            SelectHeroSkill(source, SIDOVERPOWER);
        } else if (GetHeroLevel(source) == 2) {
            SelectHeroSkill(source, SIDOVERPOWER);	
            SelectHeroSkill(source, SIDMORTALSTRIKE);	
            SelectHeroSkill(source, SIDEXECUTELEARN);
        } else if (GetHeroLevel(source) == 3) {
            SelectHeroSkill(source, SIDOVERPOWER);	
            SelectHeroSkill(source, SIDMORTALSTRIKE);	
            SelectHeroSkill(source, SIDEXECUTELEARN);
        } else if (GetHeroLevel(source) == 4) {
            SelectHeroSkill(source, SID_HEROIC_STRIKE);	
            SelectHeroSkill(source, SID_HEROIC_STRIKE);			
            SelectHeroSkill(source, SIDMORTALSTRIKE);
        } else if (GetHeroLevel(source) == 5) {
            SelectHeroSkill(source, SIDREND);	
            SelectHeroSkill(source, SIDREND);			
            SelectHeroSkill(source, SIDEXECUTELEARN);
        }
    }
    
    // 8
    function learnSkillHjai(unit source) {
        if (GetHeroLevel(source) == 1) {
            SelectHeroSkill(source, SIDFROSTBOLT);
            SelectHeroSkill(source, SIDBLIZZARD);
            SelectHeroSkill(source, SIDFROSTNOVA);
        } else if (GetHeroLevel(source) == 2) {
            SelectHeroSkill(source, SIDFROSTBOLT);			
            SelectHeroSkill(source, SIDPOLYMORPH);	
            SelectHeroSkill(source, SID_SPELL_TRANSFER);
        } else if (GetHeroLevel(source) == 3) {
            SelectHeroSkill(source, SIDBLIZZARD);		
            SelectHeroSkill(source, SIDPOLYMORPH);	
            SelectHeroSkill(source, SID_SPELL_TRANSFER);
        } else if (GetHeroLevel(source) == 4) {
            SelectHeroSkill(source, SIDFROSTBOLT);	
            SelectHeroSkill(source, SIDBLIZZARD);			
            SelectHeroSkill(source, SID_SPELL_TRANSFER);
        } else if (GetHeroLevel(source) == 5) {
            SelectHeroSkill(source, SIDFROSTNOVA);	
            SelectHeroSkill(source, SIDFROSTNOVA);	
            SelectHeroSkill(source, SIDPOLYMORPH);
        }
    }
    
    // 9
    function learnSkillHapm(unit source) {
        if (GetHeroLevel(source) == 1) {
            SelectHeroSkill(source, SID_STORM_LASH);
            SelectHeroSkill(source, SIDEARTHSHOCK);
            SelectHeroSkill(source, SIDENCHANTEDTOTEM);
        } else if (GetHeroLevel(source) == 2) {
            SelectHeroSkill(source, SIDPURGE);	
            SelectHeroSkill(source, SIDENCHANTEDTOTEM);	
            SelectHeroSkill(source, SID_ASCENDANCE);
        } else if (GetHeroLevel(source) == 3) {
            SelectHeroSkill(source, SIDENCHANTEDTOTEM);	
            SelectHeroSkill(source, SID_ASCENDANCE);
            SelectHeroSkill(source, SID_ASCENDANCE);
        } else if (GetHeroLevel(source) == 4) {
            SelectHeroSkill(source, SID_STORM_LASH);	
            SelectHeroSkill(source, SIDEARTHSHOCK);
            SelectHeroSkill(source, SIDEARTHSHOCK);
        } else if (GetHeroLevel(source) == 5) {
            SelectHeroSkill(source, SID_STORM_LASH);		
            SelectHeroSkill(source, SIDPURGE);
            SelectHeroSkill(source, SIDPURGE);
        }
    }
    
    // 10
    function learnSkillEdem(unit source) {
        if (GetHeroLevel(source) == 1) {
            SelectHeroSkill(source, SIDSINISTERSTRIKE);
            SelectHeroSkill(source, SIDEVISCERATE);
            SelectHeroSkill(source, SIDASSAULT);
        } else if (GetHeroLevel(source) == 2) {
            SelectHeroSkill(source, SIDSINISTERSTRIKE);			
            SelectHeroSkill(source, SIDBLADEFLURRY);	
            SelectHeroSkill(source, SIDSTEALTH);
        } else if (GetHeroLevel(source) == 3) {
            SelectHeroSkill(source, SIDSINISTERSTRIKE);
            SelectHeroSkill(source, SIDEVISCERATE);
            SelectHeroSkill(source, SIDASSAULT);
        } else if (GetHeroLevel(source) == 4) {
            SelectHeroSkill(source, SIDEVISCERATE);	
            SelectHeroSkill(source, SIDASSAULT);	
            SelectHeroSkill(source, SIDBLADEFLURRY);
        } else if (GetHeroLevel(source) == 5) {
            SelectHeroSkill(source, SIDBLADEFLURRY);	
            SelectHeroSkill(source, SIDSTEALTH);
            SelectHeroSkill(source, SIDSTEALTH);
        }
    }
    
    // 11
    function learnSkillHblm(unit source) {
        if (GetHeroLevel(source) == 1) {
            SelectHeroSkill(source, SIDPAIN);
            SelectHeroSkill(source, SIDMARROWSQUEEZE);
            SelectHeroSkill(source, SIDMINDFLAY);
        } else if (GetHeroLevel(source) == 2) {
            SelectHeroSkill(source, SIDPAIN);			
            SelectHeroSkill(source, SIDDEATH);	
            SelectHeroSkill(source, SIDTERROR);
        } else if (GetHeroLevel(source) == 3) {
            SelectHeroSkill(source, SIDPAIN);		
            SelectHeroSkill(source, SIDMINDFLAY);	
            SelectHeroSkill(source, SIDDEATH);
        } else if (GetHeroLevel(source) == 4) {
            SelectHeroSkill(source, SIDMARROWSQUEEZE);	
            SelectHeroSkill(source, SIDMINDFLAY);		
            SelectHeroSkill(source, SIDTERROR);
        } else if (GetHeroLevel(source) == 5) {
            SelectHeroSkill(source, SIDMARROWSQUEEZE);		
            SelectHeroSkill(source, SIDDEATH);	
            SelectHeroSkill(source, SIDTERROR);
        }
    }
    
    function makeOrderHmkg(unit source) {
        // positioning > spell > consider properly
        unit ot;
        integer i;
        integer state = 0; // 0 - normal; 1 - OT;
        // low health
        if (GetWidgetLife(source) / GetUnitState(source, UNIT_STATE_MAX_LIFE) < 0.35) {
            if (UnitCanUse(source, SIDSHIELDOFSINDOREI)) {
                // shield
                IssueImmediateOrderById(source, SpellData[SIDSHIELDOFSINDOREI].oid);
            } else if (UnitCanUse(source, SIDDISCORD)) {
                // discord nearest
                IssueTargetOrderById(source, SpellData[SIDDISCORD].oid, MobList.getNearestFrom(source));
            } else if (UnitCanUse(source, SIDSHIELDBLOCK)) {
                // block
                IssueImmediateOrderById(source, SpellData[SIDSHIELDBLOCK].oid);
            }
        }
        // ot
        i = 0;
        while (i < MobList.n) {
            ot = AggroList[MobList.units[i]].getFirst();
            if (!IsUnit(ot, source)) {
                state = 1;
                if (UnitCanUse(source, SIDDISCORD)) {
                    // discord
                    IssueTargetOrderById(source, SpellData[SIDDISCORD].oid, MobList.units[i]);
                } else if (UnitCanUse(source, SIDARCANESHOCK)) {
                    // shock
                    IssueTargetOrderById(source, SpellData[SIDARCANESHOCK].oid, MobList.units[i]);
                } else {
                    // attack
                    IssueNormalAttackOrder(source, MobList.units[i]);
                }
                i += MobList.n;
            }
            i += 1;
        }
        
        // normal rotation
        if (state == 0) {
            if (UnitCanUse(source, SIDARCANESHOCK) && !IsUnitICD(source, SIDARCANESHOCK)) {
                // shock if not internal cd
                IssueTargetOrderById(source, SpellData[SIDARCANESHOCK].oid, MobList.getLowestHPPercent());
                SetUnitICD(source, SIDARCANESHOCK, 5.0);
            } else if (UnitCanUse(source, SIDSHIELDBLOCK) && GetUnitState(source, UNIT_STATE_MANA) > SpellData[SIDSHIELDBLOCK].cost + SpellData[SIDSUNFIRESTORM].cost) {
                // block if can cast shield + sunfire
                IssueImmediateOrderById(source, SpellData[SIDSHIELDBLOCK].oid);
            } else if (UnitCanUse(source, SIDSUNFIRESTORM) && GetUnitState(source, UNIT_STATE_MANA) > SpellData[SIDSHIELDBLOCK].cost + SpellData[SIDSUNFIRESTORM].cost) {
                // sunfire if can cast shield + sunfire
                IssueImmediateOrderById(source, SpellData[SIDSUNFIRESTORM].oid);
            } else {
                // attack lowest hp
                IssueNormalAttackOrder(source, MobList.getLowestHPPercent());
            }
        }
    }
    
    function makeOrderHlgr(unit source) {
        unit ot;
        integer i;
        integer state = 0; // 0 - normal; 1 - OT;
		integer findAny;
        if (GetUnitLifePercent(source) < 20) {
            // low health danger
            if (UnitCanUse(source, SID_SURVIVAL_INSTINCTS)) {
                // instinct
                IssueImmediateOrderById(source, SpellData[SID_SURVIVAL_INSTINCTS].oid);
            } else if (UnitCanUse(source, SID_NATURAL_REFLEX)) {
                // reflex
                IssueImmediateOrderById(source, SpellData[SID_NATURAL_REFLEX].oid);
            } else if (UnitCanUse(source, SID_FOREST_CURE) && GetUnitManaPercent(source) > 20) {
                // cure if mana > 20%
                IssueImmediateOrderById(source, SpellData[SID_FOREST_CURE].oid);
            } else if (UnitCanUse(source, SID_SAVAGE_ROAR)) {
                // roar for next cure
                IssueImmediateOrderById(source, SpellData[SID_SAVAGE_ROAR].oid);
            }
        } else if (GetUnitLifePercent(source) < 45) {
            // normal low health
            if (UnitCanUse(source, SID_NATURAL_REFLEX)) {
                // reflex
                IssueImmediateOrderById(source, SpellData[SID_NATURAL_REFLEX].oid);
            } else if (UnitCanUse(source, SID_FOREST_CURE) && GetUnitManaPercent(source) > 30) {
                // cure if mana > 30%
                IssueImmediateOrderById(source, SpellData[SID_FOREST_CURE].oid);
            } else if (UnitCanUse(source, SID_SAVAGE_ROAR)) {
                // roar for next cure
                IssueImmediateOrderById(source, SpellData[SID_SAVAGE_ROAR].oid);
            }
        }
        // ot
        i = 0;
        while (i < MobList.n) {
            ot = AggroList[MobList.units[i]].getFirst();
            if (!IsUnit(ot, source)) {
                state = 1;
                if (UnitCanUse(source, SID_LACERATE) && GetUnitTypeId(MobList.units[i]) != UTIDTIDEBARONWATER && !HexLordGlobalConst.normalAttackForbid) {
                    // lacerate
                    IssueTargetOrderById(source, SpellData[SID_LACERATE].oid, MobList.units[i]);
                } else {
                    // attack
                    IssueNormalAttackOrder(source, MobList.units[i]);
                }
                i += MobList.n;
            }
            i += 1;
        }
        
        // normal rotation
        if (state == 0) {
            if (GetUnitManaPercent(source) > 90 && UnitCanUse(source, SID_FOREST_CURE) && GetUnitLifePercent(source) < 90) {
                // cure if mana overflow
                IssueImmediateOrderById(source, SpellData[SID_FOREST_CURE].oid);
            } else if (UnitCanUse(source, SID_SAVAGE_ROAR) && GetUnitManaPercent(source) < 90) {
                // roar if mana not full
                IssueImmediateOrderById(source, SpellData[SID_SAVAGE_ROAR].oid);
            } else if (UnitCanUse(source, SID_LACERATE) && !HexLordGlobalConst.normalAttackForbid) {
                // lacerate 1 by 1
                i = 0;
				findAny = 0;
                while (i < MobList.n) {
                    if (GetUnitAbilityLevel(MobList.units[i], BID_LACERATE) == 0 && GetUnitTypeId(MobList.units[i]) != UTIDTIDEBARONWATER) {
						IssueTargetOrderById(source, SpellData[SID_LACERATE].oid, MobList.units[i]);
						findAny += 1;
                        i += MobList.n;
                    }
                    i += 1;
                }
				if (findAny == 0) {
					IssueNormalAttackOrder(source, MobList.getLowestHP());
				}
            } else {
                // attack lowest hp
                IssueNormalAttackOrder(source, MobList.getLowestHP());
            }
        }
    }
    
    function ruleEmfrLifeBloom(unit u1, unit u2) -> boolean {
        Buff b11 = BuffSlot[u1].getBuffByBid(BID_LIFE_BLOOM);
        Buff b12 = BuffSlot[u1].getBuffByBid(BID_REJUVENATION);
        Buff b21 = BuffSlot[u2].getBuffByBid(BID_LIFE_BLOOM);
        Buff b22 = BuffSlot[u2].getBuffByBid(BID_REJUVENATION);
        real r11 = 0.0;
        real r12 = 0.0;
        real r21 = 0.0;
        real r22 = 0.0;
        if (b11 != 0) {r11 = b11.bd.r0 * (b11.bd.tick - 1) + b11.bd.r1;}
        if (b12 != 0) {r12 = b12.bd.r0 * b12.bd.tick;}
        if (b21 != 0) {r21 = b21.bd.r0 * (b21.bd.tick - 1) + b21.bd.r1;}
        if (b22 != 0) {r22 = b22.bd.r0 * b22.bd.tick;}
        r11 = (r11 + r12) / 2;
        r22 = (r21 + r22) / 2;
        return ((GetUnitLifeLost(u1) - r11) < (GetUnitLifeLost(u2) - r22));
    }
    
    function makeOrderEmfr(unit source) {
        UnitListSortRule ulsr;
        unit ot;
        integer i;
        integer state = 0;
        if (!IsUnitChanneling(source)) {
            ot = PlayerUnits.getLowestHPAbove(0.0);
            if (GetUnitLifePercent(ot) < 35) {
                // emergent
                if (UnitCanUse(source, SIDSWIFTMEND) && (GetUnitAbilityLevel(ot, BID_REJUVENATION) > 0 || GetUnitAbilityLevel(ot, BID_REGROWTH) > 0)) {
                    // swift if target rejuv or regrowth
                    IssueTargetOrderById(source, SpellData[SIDSWIFTMEND].oid, ot);
                } else if (UnitCanUse(source, SIDREJUVENATION)) {
                    // rejuv for next swift
                    IssueTargetOrderById(source, SpellData[SIDREJUVENATION].oid, ot);
                } else if (UnitCanUse(source, SIDREGROWTH)) {
                    // regrowth
                    IssueTargetOrderById(source, SpellData[SIDREGROWTH].oid, ot);   
                } else if (UnitCanUse(source, SIDLIFEBLOOM)) {
                    // lifebloom
                    IssueTargetOrderById(source, SpellData[SIDLIFEBLOOM].oid, ot);   
                }
            } else {
                // normal rotation
                ulsr = ruleEmfrLifeBloom;
                PlayerUnits.sortByRule(ulsr);
                
                /*i = 0;
                while (i < PlayerUnits.n) {
                    print("PlayerUnits.sorted["+I2S(i)+"]="+GetUnitNameEx(PlayerUnits.sorted[i]));
                    i += 1;
                }*/
                
                i = 0;
                while (i < PlayerUnits.n && GetUnitLifePercent(PlayerUnits.sorted[i]) < 90) {
                    if (UnitCanUse(source, SIDLIFEBLOOM) && GetUnitAbilityLevel(PlayerUnits.sorted[i], BID_LIFE_BLOOM) == 0) {
                        // lifebloom if not applied yet
                        IssueTargetOrderById(source, SpellData[SIDLIFEBLOOM].oid, PlayerUnits.sorted[i]);
                        state = 1;
                    } else if (UnitCanUse(source, SIDREJUVENATION) && GetUnitAbilityLevel(PlayerUnits.sorted[i], BID_REJUVENATION) == 0) {
                        // rejuv if not applied yet
                        IssueTargetOrderById(source, SpellData[SIDREJUVENATION].oid, PlayerUnits.sorted[i]);
                        state = 1;
                    }
                    i += 1;
                }
                if (state == 0) {
                    IssueNormalAttackOrder(source, MobList.getLowestHP());
                }
            }
        }
    }
    
    function ruleHartNormal(unit u1, unit u2) -> boolean {
        return (GetUnitLifeLost(u1) < GetUnitLifeLost(u2));
    }
    
    // boolean: IsPaladinInstant(unit)
    function makeOrderHart(unit source) {
        UnitListSortRule ulsr;
        unit ot;
        integer i;
        integer state = 0;
        integer fleshLight = GetFlashLightAID(source);
        if (!IsUnitChanneling(source)) {
            ot = PlayerUnits.getLowestHPAbove(0.0);
            if (GetUnitLifePercent(ot) < 35) {
                // emergent
                if (UnitCanUse(source, SIDHOLYSHOCK)) {
                    // holy shock
                    IssueTargetOrderById(source, SpellData[SIDHOLYSHOCK].oid, ot);
                } else {
                    if (IsPaladinInstant(source)) {
                        // instant cast holy light
                        IssueTargetOrderById(source, SpellData[SIDHOLYLIGHT1].oid, ot);
                    } else {
                        if (UnitCanUse(source, SIDDIVINEFAVOR)) {
                            // make sure next healing spell must have crit effect
                            IssueImmediateOrderById(source, SpellData[SIDDIVINEFAVOR].oid);
                        } else if (UnitCanUse(source, fleshLight)) {
                            // flash light
                            IssueTargetOrderById(source, SpellData[SIDFLASHLIGHT].oid, ot); 
                        } else if (UnitCanUse(source, SIDHOLYLIGHT)) {
                            // normal holy light
                            IssueTargetOrderById(source, SpellData[SIDHOLYLIGHT].oid, ot);   
                        }
                    }
                }
            } else {
                // normal rotation
                ulsr = ruleHartNormal;
                PlayerUnits.sortByRule(ulsr);
                
                /*i = 0;
                while (i < PlayerUnits.n) {
                    print("PlayerUnits.sorted["+I2S(i)+"]="+GetUnitNameEx(PlayerUnits.sorted[i]));
                    i += 1;
                }*/
                
                if (PlayerUnits.n > 1 && GetUnitLifePercent(PlayerUnits.sorted[1]) < 75) {
                    if (UnitCanUse(source, SIDBEACONOFLIGHT)) {
                        IssueTargetOrderById(source, SpellData[SIDBEACONOFLIGHT].oid, PlayerUnits.sorted[1]);
                    }
                }
                i = 0;
                while (i < PlayerUnits.n && GetUnitLifePercent(PlayerUnits.sorted[i]) < 85) {
                    if (UnitCanUse(source, fleshLight)) {
                        IssueTargetOrderById(source, SpellData[SIDFLASHLIGHT].oid, PlayerUnits.sorted[i]);
                        state = 1;
                    } else if (GetUnitLifePercent(PlayerUnits.sorted[i]) < 75) {
                        if (IsPaladinInstant(source)) {
                            IssueTargetOrderById(source, SpellData[SIDHOLYLIGHT1].oid, PlayerUnits.sorted[i]);
                            state = 1;
                        } else if (UnitCanUse(source, SIDHOLYLIGHT)) {
                            IssueTargetOrderById(source, SpellData[SIDHOLYLIGHT].oid, PlayerUnits.sorted[i]);
                            state = 1;
                        }
                    }
                    i += 1;
                }
                if (state == 0) {
                    IssueNormalAttackOrder(source, MobList.getLowestHP());
                }
            }
        }
    }
    
    function ruleOfarHeal(unit u1, unit u2) -> boolean {
        Buff b1 = BuffSlot[u1].getBuffByBid(BID_HEAL);
        Buff b2 = BuffSlot[u2].getBuffByBid(BID_HEAL);
        real r1 = 0.0;
        real r2 = 0.0;
        if (b1 != 0) {r1 = b1.bd.r0 * b1.bd.tick;}
        if (b2 != 0) {r2 = b2.bd.r0 * b2.bd.tick;}
        r1 = r1 / 2;
        r2 = r2 / 2;
        return ((GetUnitLifeLost(u1) - r1) < (GetUnitLifeLost(u2) - r2));
    }
    
    function makeOrderOfar(unit source) {
        UnitListSortRule ulsr;
        unit ot;
        integer i;
        integer state = 0;
        if (!IsUnitChanneling(source)) {
            ot = PlayerUnits.getLowestHPAbove(0.0);
            if (GetUnitLifePercent(ot) < 40) {
                // danger
                if (UnitCanUse(source, SIDSHIELD) && (GetUnitAbilityLevel(ot, BID_SHIELD) == 0) && (GetUnitAbilityLevel(ot, BID_SHIELD_SOUL_WEAK) == 0)) {
                    // sheld if target no shield and no soul weak
                    IssueTargetOrderById(source, SpellData[SIDSHIELD].oid, ot);
                } else if (UnitCanUse(source, SIDPRAYEROFMENDING)) {
                    // mending
                    IssueTargetOrderById(source, SpellData[SIDPRAYEROFMENDING].oid, ot);
                } else if (UnitCanUse(source, SIDHEAL) && (GetUnitAbilityLevel(ot, BID_HEAL) == 0)) {
                    // heal
                    IssueTargetOrderById(source, SpellData[SIDHEAL].oid, ot);   
                } else if (UnitCanUse(source, SIDPRAYEROFHEALING)) {
                    // healing
                    IssuePointOrderById(source, SpellData[SIDPRAYEROFHEALING].oid, GetUnitX(ot), GetUnitY(ot));   
                }
            } else {
                ulsr = ruleOfarHeal;
                PlayerUnits.sortByRule(ulsr);
                
                /*i = 0;
                while (i < PlayerUnits.n) {
                    print("PlayerUnits.sorted["+I2S(i)+"]="+GetUnitNameEx(PlayerUnits.sorted[i]));
                    i += 1;
                }*/
                
                if (GetUnitLifePercent(PlayerUnits.sorted[1]) < 75 && (GetDistance.units2d(PlayerUnits.sorted[0], PlayerUnits.sorted[1]) < 500.0) && UnitCanUse(source, SIDPRAYEROFHEALING)) {
                    IssuePointOrderById(source, SpellData[SIDPRAYEROFHEALING].oid, (GetUnitX(PlayerUnits.sorted[0]) + GetUnitX(PlayerUnits.sorted[1])) / 2.0, (GetUnitY(PlayerUnits.sorted[0]) + GetUnitY(PlayerUnits.sorted[1])) / 2.0);   
                    state = 1;
                } else {
                    i = 0;
                    while (i < PlayerUnits.n && GetUnitLifePercent(PlayerUnits.sorted[i]) < 90) {
                        if (UnitCanUse(source, SIDHEAL) && GetUnitAbilityLevel(PlayerUnits.sorted[i], BID_HEAL) == 0) {
                            IssueTargetOrderById(source, SpellData[SIDHEAL].oid, PlayerUnits.sorted[i]);
                            state = 1;
                        }
                        i += 1;
                    }
                }
                if (state == 0) {
                    IssueNormalAttackOrder(source, MobList.getLowestHP());
                }
            }
        }
    }
    
    // dps 1
    function makeOrderNbrn(unit source) {
        unit ot, tar;
        integer i;
        integer state = 0, stateG = 0;
        boolean flag;
        real x, y;
        real dis, rng;
        if (!IsUnitChanneling(source)) {
            // Summon ghoul: no ghoul
            if (!DarkRangerHasGhoul(source)) {
                if (UnitCanUse(source, SIDSUMMONGHOUL)) {
                    IssueImmediateOrderById(source, SpellData[SIDSUMMONGHOUL].oid);
                    state = 1;
                }
            }
            // Death pact: when danger >> summon ghoul ready
            if (state == 0 && UnitCanUse(source, SIDDEATHPACT)) {
                if (GetUnitLifePercent(source) < 35 || UnitCanUse(source, SIDSUMMONGHOUL)) {
                    IssueImmediateOrderById(source, SpellData[SIDDEATHPACT].oid);
                    state = 1;
                }
            }
            // freezing trap: when ot
            if (state == 0) {
                i = 0;
                flag = true;
                while (i < MobList.n && flag) {
                    ot = AggroList[MobList.units[i]].getFirst();
                    if (!IsUnitTank(ot)) {
                        flag = false;
                        tar = MobList.units[i];
                    }
                    i += 1;
                }
                if (!flag) {
                    if ((UnitProp[tar].Speed() < UnitProp[source].Speed() * 0.75) || UnitProp[tar].Stunned()) {
                        if (IsUnit(source, ot)) {
                            if (GetDistance.units2d(source, tar) < 450.0) {
                                IssuePointOrderById(source, OID_MOVE, 2 * GetUnitX(source) - GetUnitX(tar), 2 * GetUnitY(source) - GetUnitY(tar));
                                state = 1;
                            }
                            if (DarkRangerHasGhoul(source)) {
                                IssueNormalAttackOrder(DarkRangerGetGhoul(source), tar);
                                stateG = 1;
                            }
                        }
                    } else {
                        if (UnitCanUse(source, SIDFREEZINGTRAP)) {
                            rng = GetDistance.units2d(source, tar);
                            dis = rng;
                            if (rng > 200) {rng = 200.0;}
                            x = (GetUnitX(tar) - GetUnitX(source)) * rng / dis + GetUnitX(source);
                            y = (GetUnitY(tar) - GetUnitY(source)) * rng / dis + GetUnitY(source);
                            IssuePointOrderById(source, SpellData[SIDFREEZINGTRAP].oid, x, y);
                            state = 1;
                        }
                    }
                }
            }
            // concerntration: when ready >> someone casting
            if (state == 0 && UnitCanUse(source, SIDCONCERNTRATION)) {
                IssueImmediateOrderById(source, SpellData[SIDCONCERNTRATION].oid);
                state = 1;
            }
            // black arrow: when ready
            if (state == 0 && UnitCanUse(source, SIDDARKARROW)) {
                IssueTargetOrderById(source, SpellData[SIDDARKARROW].oid, MobList.getLowestHP());
                state = 1;
            }
            // Abomi/banshee: mana
            if (UnitCanUse(source, SIDPOWEROFABOMINATION)) {
                if (GetUnitMana(source) < SpellData[SIDDARKARROW].Cost(GetUnitAbilityLevel(source, SIDDARKARROW)) + SpellData[SIDSUMMONGHOUL].Cost(GetUnitAbilityLevel(source, SIDSUMMONGHOUL))) {
                    if (DarkRangerIsAbominationOn(source)) {
                        IssueImmediateOrderById(source, OID_IMMOLATIONOFF);
                    }
                } else {
                    if (!DarkRangerIsAbominationOn(source)) {
                        IssueImmediateOrderById(source, OID_IMMOLATIONON);
                    }
                }
            }
            // attack
            if (state == 0) {
                IssueNormalAttackOrder(source, MobList.getLowestHP());
            }
            if (stateG == 0) {
                if (DarkRangerHasGhoul(source)) {
                    IssueNormalAttackOrder(DarkRangerGetGhoul(source), MobList.getLowestHP());
                }
            }
        }
    }
    
    // dps 2
    function makeOrderObla(unit source) {
        unit ot, tar;
        integer i;
        integer state = 0;
        boolean flag;
        if (!IsUnitChanneling(source)) {
            // I have only one target!
            tar = MobList.getLowestHP();
            // overpower: when ready
            if (UnitCanUse(source, SIDOVERPOWER) && !HexLordGlobalConst.normalAttackForbid) {
                if (BladeMasterCanOverpower(source) && GetUnitManaLost(source) >= BladeMasterGetOverpowerManaRep(source)) {
                    IssueTargetOrderById(source, SpellData[SIDOVERPOWER].oid, tar);
                    state = 1;
                }
            }
            // rend: if no rend
            if (state == 0 && UnitCanUse(source, SIDREND) && !HexLordGlobalConst.normalAttackForbid) {
                if (GetUnitAbilityLevel(tar, BID_REND) == 0) {
                    IssueTargetOrderById(source, SpellData[SIDREND].oid, tar);
                    state = 1;
                }
            }
            // mortal strike: rend about to expire
            if (state == 0 && UnitCanUse(source, SIDMORTALSTRIKE) && !HexLordGlobalConst.normalAttackForbid) {
                IssueTargetOrderById(source, SpellData[SIDMORTALSTRIKE].oid, tar);
                state = 1;
            }
            // execute: when > 16
            if (state == 0 && !HexLordGlobalConst.normalAttackForbid) {
                if (BladeMasterPeekValour(source) > 16) {
                    IssueTargetOrderById(source, SpellData[SIDEXECUTEEND].oid, tar);
                    state = 1;
                } else if (BladeMasterPeekValour(source) > 14) {
                    IssueTargetOrderById(source, SpellData[SIDEXECUTE4].oid, tar);
                    state = 1;
                }
            }
            // heroic strike: MANA% > BOSS HP% - 10 + Rend Cost
            if (UnitCanUse(source, SID_HEROIC_STRIKE) && GetUnitMana(source) > SpellData[SIDREND].Cost(GetUnitAbilityLevel(source, SIDREND))) {
                if (!BladeMasterIsHSOn(source)) {
                    IssueImmediateOrderById(source, SpellData[SID_HEROIC_STRIKE].oid);
                }
            } else {
                if (BladeMasterIsHSOn(source)) {
                    IssueImmediateOrderById(source, SpellData[SID_HEROIC_STRIKE].oid);
                }
            }
            // attack
            if (state == 0) {
                IssueNormalAttackOrder(source, tar);
            }
        }
    }
    
    // dps 3
    function makeOrderHjai(unit source) {
        unit ot, attacker;
        integer i;
        boolean flag;
        integer state = 0;
        if (!IsUnitChanneling(source)) {
            // frost nova
            if (UnitCanUse(source, SIDFROSTNOVA)) {
                i = 0;
                flag = true;
                while (i < MobList.n && flag) {
                    ot = AggroList[MobList.units[i]].getFirst();
                    if (!IsUnitTank(ot)) {
                        flag = false;
                        attacker = MobList.units[i];
                    }
                    i += 1;
                }
                if (!flag) {
                    if (GetDistance.units2d(source, attacker) < FrostMageGetFrostNovaAOE(GetUnitAbilityLevel(source, SIDFROSTNOVA))) {
                        IssueImmediateOrderById(source, SpellData[SIDFROSTNOVA].oid);
                        state = 1;
                    } else {
                        IssuePointOrderById(source, OID_MOVE, GetUnitX(attacker), GetUnitY(attacker)); 
                        state = 1;
                    }
                }
            }
            // spell transfer
            if (UnitCanUse(source, SID_SPELL_TRANSFER) && state == 0) {
                i = 0;
                flag = true;
                while (i < MobList.n && flag) {
                    if (BuffSlot[MobList.units[i]].contains(BUFF_MAGE, BUFF_POS)) {
                        ot = MobList.units[i];
                        flag = false;
                    }
                    i += 1;
                }
                if (flag) {
                    i = 0;
                    flag = true;
                    while (i < PlayerUnits.n && flag) {
                        if (BuffSlot[PlayerUnits.units[i]].contains(BUFF_MAGE, BUFF_NEG)) {
                            ot = PlayerUnits.units[i];
                            flag = false;
                        }
                        i += 1;
                    }
                }
                if (!flag) {
                    IssueTargetOrderById(source, SpellData[SID_SPELL_TRANSFER].oid, ot);
                    state = 1;
                }
            }
            // polymorph && counter spell
            if (state == 0 && UnitCanUse(source, SIDPOLYMORPH)) {
                ot = MobList.getChanneling();
                if (ot != null) {
                    IssueTargetOrderById(source, SpellData[SIDPOLYMORPH].oid, ot);
                    state = 1;
                }
            }
            // blizzard
            if (state == 0 && (UnitCanUse(source, SIDBLIZZARD) || UnitCanUse(source, SIDBLIZZARD1)) && MobList.GetNum() > 2) {
                i = 0;
                ot = null;
                flag = true;
                while (i < PlayerUnits.n && flag) {
                    if (IsUnitTank(PlayerUnits.units[i])) {
                        ot = PlayerUnits.units[i];
                        flag = false;
                    }
                    i += 1;
                }
                if (!flag) {
                    if (UnitCanUse(source, SIDBLIZZARD)) {
                        IssuePointOrderById(source, SpellData[SIDBLIZZARD].oid, GetUnitX(ot), GetUnitY(ot));
                    } else if (UnitCanUse(source, SIDBLIZZARD1)) {
                        IssuePointOrderById(source, SpellData[SIDBLIZZARD1].oid, GetUnitX(ot), GetUnitY(ot));
                    }
                    state = 1;
                }
            }
            // frost bolt
            if (state == 0 && UnitCanUse(source, SIDFROSTBOLT)) {
                IssueTargetOrderById(source, SpellData[SIDFROSTBOLT].oid, MobList.getLowestHP());
                state = 1;
            }            
            // attack
            if (state == 0) {
                IssueNormalAttackOrder(source, MobList.getLowestHP());
            }
        }
    }
    
    // dps 4
    function makeOrderHapm(unit source) {
        unit ot, tar;
        integer i;
        integer state = 0;
        boolean flag;
            
        // earth shock: free cast
        if (EarthBinderFreeES(source)) {
            IssueImmediateOrderById(source, OID_STOP);            
            ot = MobList.getChanneling();
            if (ot == null) {
                ot = MobList.getLowestHP();
            }
            IssueTargetOrderById(source, SpellData[SIDEARTHSHOCK1].oid, ot);
            state = 1;            
        }
        if (state == 0 && !IsUnitChanneling(source)) {
            // earth shock: counter spell
            if (UnitCanUse(source, SIDEARTHSHOCK)) {
                ot = MobList.getChanneling();
                if (ot != null) {
                    IssueTargetOrderById(source, SpellData[SIDEARTHSHOCK].oid, ot);
                    state = 1;
                }
            }
            // purge: offensive dispel, then defensive dispel
            if (state == 0 && UnitCanUse(source, SIDPURGE)) {
                i = 0;
                flag = true;
                while (i < MobList.n && flag) {
                    if (BuffSlot[MobList.units[i]].contains(BUFF_MAGE, BUFF_POS)) {
                        ot = MobList.units[i];
                        flag = false;
                    }
                    i += 1;
                }
                if (flag) {
                    i = 0;
                    flag = true;
                    while (i < PlayerUnits.n && flag) {
                        if (BuffSlot[PlayerUnits.units[i]].contains(BUFF_MAGE, BUFF_NEG)) {
                            ot = PlayerUnits.units[i];
                            flag = false;
                        }
                        i += 1;
                    }
                }
                if (!flag) {
                    IssueTargetOrderById(source, SpellData[SIDPURGE].oid, ot);
                    state = 1;
                }
            }
            // ascendance: use when ready
            if (state == 0 && UnitCanUse(source, SID_ASCENDANCE)) {
                IssueImmediateOrderById(source, SpellData[SID_ASCENDANCE].oid);
                state = 1;
            }
            // totem
            if (state == 0) {
                // torrent totem
                if (whichBoss != null) {
                    if (GetUnitManaPercent(source) < GetUnitLifePercent(whichBoss) - 10) {
                        if (EarthBinderGetCurrentTotem(source) != SIDTORRENTTOTEM) {
                            if (UnitCanUse(source, SIDPURGE)) {
                                IssueTargetOrderById(source, SpellData[SIDPURGE].oid, source);
                            }
                        } else if (UnitCanUse(source, SIDTORRENTTOTEM)) {
                            IssuePointOrderById(source, SpellData[SIDTORRENTTOTEM].oid, GetUnitX(source) - 128.0, GetUnitY(source) - 128.0);
                        }
                        state = 1;
                    }
                }
                // earth bind totem
                if (state == 0) {
                    i = 0;
                    flag = true;
                    while (i < MobList.n && flag) {
                        ot = AggroList[MobList.units[i]].getFirst();
                        if (!IsUnitTank(ot)) {
                            flag = false;
                            tar = MobList.units[i];
                        }
                        i += 1;
                    }
                    if (!flag) {
                        if (GetUnitAbilityLevel(tar, BID_EARTH_BIND_TOTEM) > 0) {
                            if (IsUnit(source, ot)) {
                                if (GetDistance.units2d(source, tar) < 400.0) {
                                    IssuePointOrderById(source, OID_MOVE, 2 * GetUnitX(source) - GetUnitX(tar), 2 * GetUnitY(source) - GetUnitY(tar));
                                    state = 1;
                                } else {
                                    state = 2;
                                }
                            }
                        } else {
                            if (EarthBinderGetCurrentTotem(source) != SIDEARTHBINDTOTEM) {
                                if (EarthBinderFreeES(source)) {
                                    IssueTargetOrderById(source, SpellData[SIDEARTHSHOCK1].oid, MobList.getLowestHP());
                                } else if (UnitCanUse(source, SIDEARTHSHOCK)) {
                                    IssueTargetOrderById(source, SpellData[SIDEARTHSHOCK].oid, MobList.getLowestHP());
                                }
                            } else {
                                if (UnitCanUse(source, SIDEARTHBINDTOTEM)) {
                                    IssuePointOrderById(source, SpellData[SIDEARTHBINDTOTEM].oid, GetUnitX(tar) - 128.0, GetUnitY(tar) - 128.0);
                                }
                            }
                            state = 1;
                        }
                    }                    
                }
                if (state == 0) {
                    if (!EarthBinderHasLightningTotem(source)) {
                        if (EarthBinderGetCurrentTotem(source) != SIDLIGHTNINGTOTEM) {
                            if (UnitCanUse(source, SID_STORM_LASH)) {
                                IssueTargetOrderById(source, SpellData[SID_STORM_LASH].oid, MobList.getLowestHP());
                            }
                        } else {
                            if (UnitCanUse(source, SIDLIGHTNINGTOTEM)) {
                                tar = MobList.getLowestHP();
                                IssuePointOrderById(source, SpellData[SIDLIGHTNINGTOTEM].oid, GetUnitX(tar) - 128.0, GetUnitY(tar) - 128.0);
                            }
                        }
                        state = 1;
                    }
                }
            }
            // storm lash: MANA >= BOSS HP - 10
            if ((state == 0 || state == 2) && UnitCanUse(source, SID_STORM_LASH)) {
                IssueTargetOrderById(source, SpellData[SID_STORM_LASH].oid, MobList.getLowestHP());
                state = 1;
            }
            // attack
            if (state == 0 || state == 2) {
                IssueNormalAttackOrder(source, MobList.getLowestHP());
            }
        }
    }
    
    // dps 5
    function makeOrderEdem(unit source) {
        unit ot, tar;
        integer i;
        integer state = 0;
        boolean flag;
        if (!IsUnitChanneling(source)) {
            // stealth
            if (UnitCanUse(source, SIDSTEALTH)) {
                i = 0;
                flag = true;
                while (i < MobList.n && flag) {
                    if (!IsUnitUseless(MobList.units[i])) {
                        ot = AggroList[MobList.units[i]].getFirst();
                        if (IsUnit(source, ot)) {
                            flag = false;
                            IssueImmediateOrderById(source, SpellData[SIDSTEALTH].oid);
                            state = 1;
                        }
                    }
                    i += 1;
                }
            }
            // blade flurry: use when ready
            if (state == 0 && UnitCanUse(source, SIDBLADEFLURRY) && !IsUnitStealth(source) && !HexLordGlobalConst.normalAttackForbid) {
                IssueImmediateOrderById(source, SpellData[SIDBLADEFLURRY].oid);
                state = 1;
            }
            // stealth abilities
            if (state == 0 && IsUnitStealth(source) && !HexLordGlobalConst.normalAttackForbid) {
                tar = MobList.getLowestHP();
                if (GetUnitMana(tar) == 0) {
                    IssueTargetOrderById(source, SpellData[SIDAMBUSH].oid, tar);
                } else {
                    IssueTargetOrderById(source, SpellData[SIDGARROTE].oid, tar);
                }
                state = 1;
            }
            // assault: counter spell
            if (state == 0 && UnitCanUse(source, SIDASSAULT) && !HexLordGlobalConst.normalAttackForbid) {
                ot = MobList.getChanneling();
                if (ot != null) {
                    IssueTargetOrderById(source, SpellData[SIDASSAULT].oid, ot);
                    state = 1;
                }
            }
            // eviscerate: when 5*
            if (state == 0 && UnitCanUse(source, SIDEVISCERATE) && !HexLordGlobalConst.normalAttackForbid) {
                if (ComboPoints[source].n == 5 && GetUnitManaPercent(source) >= 25) {
                    IssueTargetOrderById(source, SpellData[SIDEVISCERATE].oid, MobList.getLowestHP());
                    state = 1;
                }
            }
            // sinister strike
            if (state == 0 && UnitCanUse(source, SIDSINISTERSTRIKE) && GetUnitManaPercent(source) >= 40 && !HexLordGlobalConst.normalAttackForbid) {
                IssueTargetOrderById(source, SpellData[SIDSINISTERSTRIKE].oid, MobList.getLowestHP());
                state = 1;
            }
            // attack
            if (state == 0) {
                IssueNormalAttackOrder(source, MobList.getLowestHP());
            }
        }
    }
    
    // dps 6
    function makeOrderHblm(unit source) {
        unit ot, tar;
        integer i;
        integer state = 0;
        boolean flag;
        real r0;
        if (!IsUnitChanneling(source)) {
            // counter spell or crowd control
            if (UnitCanUse(source, SIDTERROR)) {
                // try counter spell
                ot = MobList.getChanneling();
                if (ot != null) {
                    if (GetDistance.units2d(source, ot) < HereticGetTerrorAOE(GetUnitAbilityLevel(source, SIDTERROR))) {
                        IssueImmediateOrderById(source, SpellData[SIDTERROR].oid);
                    } else {
                        IssuePointOrderById(source, OID_MOVE, GetUnitX(ot), GetUnitY(ot)); 
                    }
                    state = 1;
                } else {
                    // crowd control
                    i = 0;
                    flag = true;
                    while (i < MobList.n && flag) {
                        ot = AggroList[MobList.units[i]].getFirst();
                        if (!IsUnitTank(ot)) {
                            flag = false;
                            tar = MobList.units[i];
                        }
                        i += 1;
                    }
                    if (!flag) {
                        if (GetDistance.units2d(source, tar) < HereticGetTerrorAOE(GetUnitAbilityLevel(source, SIDTERROR))) {
                            IssueImmediateOrderById(source, SpellData[SIDTERROR].oid);
                        } else {
                            IssuePointOrderById(source, OID_MOVE, GetUnitX(tar), GetUnitY(tar)); 
                        }
                        state = 1;
                    }
                }
            }
            // death!
            if (state == 0 && UnitCanUse(source, SIDDEATH)) {
                IssueTargetOrderById(source, SpellData[SIDDEATH].oid, MobList.getLowestHP());
                state = 1;
            }
            // pain on each target
            if (state == 0 && UnitCanUse(source, SIDPAIN)) {
                i = 0;
                flag = true;
                while (i < MobList.n && flag) {
                    if (!IsUnitUseless(MobList.units[i])) {
                        if (GetUnitAbilityLevel(MobList.units[i], BID_PAIN) == 0) {
                            IssueTargetOrderById(source, SpellData[SIDPAIN].oid, MobList.units[i]);
                            state = 1;
                            flag = false;
                        }
                    }
                    i += 1;
                }
            }
            // Marrow squeeze & Mind flay; MANA% = BOSS HP% - 10%
            if (state == 0) {
                // flag true: use mana; false: regen mana
                if (whichBoss != null) {
                    flag = (GetUnitManaPercent(source) > (GetUnitLifePercent(whichBoss) - 10));
                } else {
                    flag = (GetUnitManaPercent(source) > 10);
                }
                if (flag) {
                    r0 = SpellData[SIDPAIN].Cost(GetUnitAbilityLevel(source, SIDPAIN));
                    r0 += SpellData[SIDMARROWSQUEEZE].Cost(GetUnitAbilityLevel(source, SIDMARROWSQUEEZE));
                    r0 += SpellData[SIDMINDFLAY].Cost(GetUnitAbilityLevel(source, SIDMINDFLAY));
                    if (GetUnitMana(source) >= r0 && UnitCanUse(source, SIDMARROWSQUEEZE)) {
                        IssueTargetOrderById(source, SpellData[SIDMARROWSQUEEZE].oid, MobList.getLowestHP());
                        state = 1;
                    }
                }
                if (state == 0) {
                    if (UnitCanUse(source, SIDMINDFLAY)) {
                        IssueTargetOrderById(source, SpellData[SIDMINDFLAY].oid, MobList.getLowestHP());
                        state = 1;
                    }
                }
            }
            // attack
            if (state == 0) {
                IssueNormalAttackOrder(source, MobList.getLowestHP());
            }
        }
    }
    
    function AIActions() {
        integer i = 0;
        while (i < ain) {
            if (!UnitProp[aiu[i]].Stunned() && !UnitProp[aiu[i]].Disabled()) {
                if (PositioningDone(aiu[i])) {
                    UnitActionType(unitCallBack[GetUnitTypeId(aiu[i])]).evaluate(aiu[i]);
                }
            }
            i += 1;
        }
    }
    
    function register() {
        unitCallBack['Hmkg'] = makeOrderHmkg;   // 血精灵防御者
        unitCallBack['Hlgr'] = makeOrderHlgr;   // 利爪德鲁依 
        unitCallBack['Emfr'] = makeOrderEmfr;   // 丛林守护者
        unitCallBack['Hart'] = makeOrderHart;   // 圣骑士
        unitCallBack['Ofar'] = makeOrderOfar;   // 牧师
        unitCallBack['Obla'] = makeOrderObla;   // 剑圣
        unitCallBack['Nbrn'] = makeOrderNbrn;   // 黑暗猎手
        unitCallBack['Hjai'] = makeOrderHjai;   // 寒冰法师
        unitCallBack['Hapm'] = makeOrderHapm;   // 地缚者
        unitCallBack['H006'] = makeOrderHapm;   // 地缚者
        unitCallBack['Edem'] = makeOrderEdem;   // 流浪剑客
        unitCallBack['Hblm'] = makeOrderHblm;   // 异教徒
        unitLearSkill['Hmkg'] = learnSkillHmkg;   // 
        unitLearSkill['Hlgr'] = learnSkillHlgr;   // 利爪德鲁依 
        unitLearSkill['Emfr'] = learnSkillEmfr;   // 丛林守护者
        unitLearSkill['Hart'] = learnSkillHart;   // 圣骑士
        unitLearSkill['Ofar'] = learnSkillOfar;   // 牧师
        unitLearSkill['Obla'] = learnSkillObla;   // 剑圣
        unitLearSkill['Nbrn'] = learnSkillNbrn;   // 黑暗猎手
        unitLearSkill['Hjai'] = learnSkillHjai;   // 寒冰法师
        unitLearSkill['Hapm'] = learnSkillHapm;   // 地缚者
        unitLearSkill['Edem'] = learnSkillEdem;   // 流浪剑客
        unitLearSkill['Hblm'] = learnSkillHblm;   // 异教徒
    }
    
    // learn skills once
    struct delayedDosth1 {
        private timer tm;
        private unit sor;
    
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            integer i = 0;
            UnitActionType(unitLearSkill[GetUnitTypeId(this.sor)]).evaluate(this.sor);
            
            ReleaseTimer(this.tm);
            this.tm = null;
            this.sor = null;
            this.deallocate();
        }
    
        static method start(unit sor) {
            thistype this = thistype.allocate();
            this.sor = sor;
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            TimerStart(this.tm, 0.01, false, function thistype.run);
        }
    }
    
    function heroLearnSkillsAlways() {
        integer i = 0;
        while (i < PlayerUnits.n) {
            if (IsUnitType(PlayerUnits.units[i], UNIT_TYPE_HERO)) {
                if (!IsPlayerUserOnline(GetOwningPlayer(PlayerUnits.units[i]))) {
                    if (GetHeroSkillPoints(PlayerUnits.units[i]) > 0) {
                        UnitActionType(unitLearSkill[GetUnitTypeId(PlayerUnits.units[i])]).evaluate(PlayerUnits.units[i]);
                    }
                }
            }
            i += 1;
        }
    }

    public function RegisterAIAlliance(unit u) {
        aiu[ain] = u;
        ain += 1;
        delayedDosth1.start(u);        
    }
    
    // if not in combat, AI will do nothing
    function changeState() {
        if (flip) {
            PauseTimer(globalTimer);
        } else {
            TimerStart(globalTimer, AIACTION_INTERVAL, true, function AIActions);
        }
        flip = !flip;
    }
    
    function onInit() {
        ain = 0;
        RegisterCombatStateNotify(changeState);
        globalTimer = CreateTimer();
        unitCallBack = Table.create();
        unitLearSkill = Table.create();
        flip = false;
        register();
        
        TimerStart(CreateTimer(), 5.0, true, function heroLearnSkillsAlways);
    }
}
//! endzinc
