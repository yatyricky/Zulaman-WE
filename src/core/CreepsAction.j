//! zinc
library CreepsAction requires SpellData, UnitAbilityCD, CastingBar, PlayerUnitList, IntegerPool, UnitProperty, CombatFacts, RandomPoint {

    Table unitCallBack;
    HandleTable focus, pace;
    type UnitActionType extends function(unit, unit, real);
    /*
    struct MakeUnitNonResponsive {
        private timer tm;
        private unit u;
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            UnitProp[this.u].responsive = true;
            ReleaseTimer(this.tm);
            this.tm = null;
            this.u = null;
            this.deallocate();
        }
        static method start(unit u) {
            thistype this = thistype.allocate();
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.u = u;
            UnitProp[u].responsive = false;
            TimerStart(this.tm, 1.0, false, function thistype.run);
        }
    }*/

    //function NotAttacking(unit u) {
    //    focus[u] = 1;
    //}

    //function AttackTarget(unit s, unit t) {}    
    
    function makeOrderHexLord(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        real x, y, l, a;
        unit tar = null;
        if (!IsUnitChanneling(source) && GetUnitAbilityLevel(source, SIDAPIV) == 0) {
            ip = IntegerPool.create();
            if (UnitCanUse(source, SIDSPIRITBOLT) && combatTime > 30) {
                ip.add(SIDSPIRITBOLT, 30);
            } else {
                if (UnitCanUse(source, SIDSPIRITHARVEST) && GetUnitStatePercent(source, UNIT_STATE_LIFE, UNIT_STATE_MAX_LIFE) < 80) {
                    ip.add(SIDSPIRITHARVEST, 30);
                } else {                    
                    if (UnitCanUse(source, DBMHexLord.spell1)) {
                        ip.add(DBMHexLord.spell1, 30);
                    }         
                    if (UnitCanUse(source, DBMHexLord.spell2)) {
                        ip.add(DBMHexLord.spell2, 30);
                    }
                    ip.add(0, 5);
                }
            }
            res = ip.get();
// print("选取技能"+SpellData[res].name);
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else if (SpellData[res].otp == ORDER_TYPE_TARGET) {
                if (res == SIDDARKARROWHEX || res == SIDSTEALTHHEX || res == SIDPAINHEX) {
                    tar = PlayerUnits.getRandomHero();                    
                } else if (res == SIDPOLYMORPHHEX) {
                    tar = PlayerUnits.getRandomExclude(target);
                } else if (res == SIDLIFEBLOOMHEX || res == SIDHOLYBOLTHEX || res == SIDHEALHEX || res == SIDSHIELDHEX) {
                    tar = MobList.getLowestHPPercent();
                } else if (res == SIDHOLYSHOCKHEX) {
                    if (GetRandomInt(0, 1) == 1) {
                        tar = PlayerUnits.getRandomHero();
                    } else {
                        tar = MobList.getRandom();
                    }
                }
                if (tar != null) {target = tar;}
//print("Going to " + SpellData[res].name + " on " + GetUnitNameEx(target));
                IssueTargetOrderById(source, SpellData[res].oid, target);
            } else if (SpellData[res].otp == ORDER_TYPE_IMMEDIATE) {
                IssueImmediateOrderById(source, SpellData[res].oid);
//            } else if (SpellData[res].otp == ORDER_TYPE_POINT) {
//                x = GetUnitX(target); y = GetUnitY(target);
//                if (res == SIDSUNFIRESTORMHEX) {
//                    tar = PlayerUnits.getRandomInRange(source, 3600.0);
//print("Sunfire storm on " + GetUnitNameEx(tar));
//                    if (tar != null) {
//                        x = GetUnitX(tar); y = GetUnitY(tar);
//                    }
                //} else if (res == SIDFREEZINGTRAPHEX) {
//print("lightning totem casting point: " + R2S(GetUnitX(target)) + " - " + R2S(GetUnitY(target)));
                //    IssuePointOrderById(source, SpellData[res].oid, GetUnitX(target), GetUnitY(target));
//                } else if (res == SIDLIGHTNINGTOTEMHEX) {
//                    RandomPoint.aroundUnit(source, 100.0, 200.0);
//print("lightning totem casting point: " + R2S(RandomPoint.x) + " - " + R2S(RandomPoint.y));
//                    x = RandomPoint.x; y = RandomPoint.y;
//                }
//print("about to make order, source = " + GetUnitNameEx(source) + ", ids = " + OrderId2String(SpellData[res].oid) + ", x=" + R2S(x) + ", y=" + R2S(y));
//                IssuePointOrderById(source, SpellData[res].oid, x, y);
//print("order made");
            }
            ip.destroy();
        }
    }
    
    // nage sea witch
    function makeOrderHvsh(unit source, unit target, real combatTime) {        
        IntegerPool ip;
        integer res;
        unit tu;
        /*        print("-- - - - - - - - - - - -  -");*/
        if (!IsUnitChanneling(source)) {
            ip = IntegerPool.create();
            if (UnitCanUse(source, 'A03O') && combatTime > 49) {
                ip.add('A03O', 30);
            } else {
                if (UnitCanUse(source, 'A03Q') && combatTime > 300) {
                    ip.add('A03Q', 30);
                } else {
                    if (UnitCanUse(source, 'A03P') && GetUnitStatePercent(source, UNIT_STATE_LIFE, UNIT_STATE_MAX_LIFE) < 21) {
                        ip.add('A03P', 30);
                    } else {
                        if (UnitCanUse(source, 'A03L') && combatTime > 10) {
                            //print("1");
                            ip.add('A03L', 30);
                        }
                        if (UnitCanUse(source, 'A03M') && combatTime > 20) {
                            //print("2");
                            ip.add('A03M', 30);
                        }
                        if (UnitCanUse(source, 'A03N') && combatTime > 30) {
                            //print("3");
                            ip.add('A03N', 30);
                        }
                        ip.add(0, 50);
                    }
                }
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else if (SpellData[res].otp == ORDER_TYPE_TARGET) {
                //NotAttacking(source);
                if (res == 'A03L') {
                    IssueTargetOrderById(source, SpellData[res].oid, PlayerUnits.getFarest(source));
                } else {
                    tu = PlayerUnits.getRandomHero(); // to avoid that strong breeze clashes with thunder storm
                    if (!UnitProp[tu].stunned) {
                        IssueTargetOrderById(source, SpellData[res].oid, tu);
                    }
                }
            } else if (SpellData[res].otp == ORDER_TYPE_IMMEDIATE) {
                //NotAttacking(source);
                IssueImmediateOrderById(source, SpellData[res].oid);
            }
            ip.destroy();
        }    
        tu = null;
    }
    
    // Arch Tinker Morph
    function makeOrderNrob(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        // boss spec vars 
        real dis;
        unit tu;
        if (!IsUnitChanneling(source)) {
            ip = IntegerPool.create();
            if (combatTime > 300) {
                ip.add(SID_CLUSTER_ROCKETS, 50);
            } else {
                if (UnitCanUse(source, SID_LIGHTNING_SHIELD) && GetUnitAbilityLevel(source, BID_LIGHTNING_SHIELD) == 0) {
                    ip.add(SID_LIGHTNING_SHIELD, 20);
                } else {
                    if (UnitCanUse(source, SID_POCKET_FACTORY) && DBMArchTinker.numberOfFactory < 3) {
                        ip.add(SID_POCKET_FACTORY, 20);
                    } else {
                        tu = PlayerUnits.getFarest(source);
                        dis = GetDistance.units2d(tu, source);
                        if (dis > DBMArchTinker.gripRange && combatTime > 30.0) {
                            ip.add(SID_GRIP_OF_STATIC_ELECTRICITY, 20);
                        } else {
                            tu = PlayerUnits.getRandomHero();
                            if (UnitCanUse(source, SID_PULSE_BOMB) && combatTime > 15.0) {
                                ip.add(SID_PULSE_BOMB, 30);
                            }
                            if (UnitCanUse(source, SID_LASER_BEAM) && combatTime > 30.0) {
                                ip.add(SID_LASER_BEAM, 30);
                            }
                            ip.add(0, 20);
                        }
                    }
                }
            }
            
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, PlayerUnits.getRandomHero());
            } else if (SpellData[res].otp == ORDER_TYPE_TARGET) {
                IssueTargetOrderById(source, SpellData[res].oid, tu);
            } else if (SpellData[res].otp == ORDER_TYPE_IMMEDIATE) {
                IssueImmediateOrderById(source, SpellData[res].oid);
            }
            ip.destroy();
        }
    }
    
    // Arch Tinker
    function makeOrderNtin(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        // boss spec vars 
        real dis;
        unit tu;
        if (!IsUnitChanneling(source)) {
            ip = IntegerPool.create();
            if (combatTime > 300) {
                ip.add(SID_CLUSTER_ROCKETS, 50);
            } else {
                if (GetUnitLifePercent(source) < 41) {
                    ip.add(SID_TINKER_MORPH, 50);
                } else {
                    tu = PlayerUnits.getFarest(source);
                    dis = GetDistance.units2d(tu, source);
                    if (dis > DBMArchTinker.gripRange && combatTime > 30.0) {
                        ip.add(SID_GRIP_OF_STATIC_ELECTRICITY, 15);
                    } else {
                        tu = PlayerUnits.getRandomHero();
                        if (UnitCanUse(source, SID_PULSE_BOMB) && combatTime > 15.0) {
                            ip.add(SID_PULSE_BOMB, 30);
                        }
                        if (UnitCanUse(source, SID_LASER_BEAM) && combatTime > 30.0) {
                            ip.add(SID_LASER_BEAM, 30);
                        }
                        ip.add(0, 20);
                    }
                }
            }
            
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else if (SpellData[res].otp == ORDER_TYPE_TARGET) {
                IssueTargetOrderById(source, SpellData[res].oid, tu);
            } else if (SpellData[res].otp == ORDER_TYPE_IMMEDIATE) {
                IssueImmediateOrderById(source, SpellData[res].oid);
            }
            ip.destroy();
        }
    }
    
    // target
    function makeOrderh000(unit source, unit target, real combatTime) {}
    
    // healing ward
    function makeOrderh004(unit source, unit target, real combatTime) {}
    
    // protection ward
    function makeOrderh005(unit source, unit target, real combatTime) {}
    
    // tank tester
    function makeOrderh002(unit source, unit target, real combatTime) {
        IssueTargetOrderById(source, OID_ATTACK, target);
    }
    
    function makeOrderLightningTotem(unit source, unit target, real combatTime) {}
    
    // nage siren
    function makeOrdern000(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        unit tu;
        if (!IsUnitChanneling(source) && !UnitProp[source].stunned) {
            ip = IntegerPool.create();
            ip.add(0, 1);
            if (UnitCanUse(source, SID_LIGHTNING_BOLT)) {
                ip.add(SID_LIGHTNING_BOLT, 20);
            }
            if (UnitCanUse(source, SID_FROST_SHOCK)) {
                ip.add(SID_FROST_SHOCK, 80);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else if (res == SID_FROST_SHOCK) {
                tu = PlayerUnits.getRandomHero(); 
                IssueTargetOrderById(source, SpellData[res].oid, tu);
                tu = null;
            } else {
                IssueTargetOrderById(source, SpellData[res].oid, target);
            }
            ip.destroy();
        }
    }
    
    // demon witch
    function makeOrdern001(unit source, unit target, real combatTime) {
        real chance = GetRandomInt(0, 100);
        //print("1");
        if (!IsUnitChanneling(source)) {
            if (chance < 35) {
                if (UnitCanUse(source, 'A02Y')) {
                    //NotAttacking(source);
                    IssueTargetOrderById(source, SpellData['A02Y'].oid, source);
                } else {
                    IssueTargetOrderById(source, OID_ATTACK, target);
                }
            } else if (chance < 85) {
                if (UnitCanUse(source, 'A02W')) {
                    //NotAttacking(source);
                    IssueTargetOrderById(source, SpellData['A02W'].oid, target);
                } else {
                    IssueTargetOrderById(source, OID_ATTACK, target);
                }
            } else {
                //print("3");
                IssueTargetOrderById(source, OID_ATTACK, target);
            }
        } else {
                //print("4");
        }
    }
    
    // serpent inferior
    function makeOrdern003(unit source, unit target, real combatTime) {
        IssueTargetOrderById(source, OID_ATTACK, target);
    }
    
    // nage myrmidon
    function makeOrdern00A(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        unit tu;
        if (!IsUnitChanneling(source) && !UnitProp[source].stunned) {
            ip = IntegerPool.create();
            ip.add(0, 1);
            if (UnitCanUse(source, SID_ARMOR_CRUSHING) && combatTime > 15.0) {
                ip.add(SID_ARMOR_CRUSHING, 50);
            }
            if (UnitCanUse(source, SID_NAGA_FRENZY) && GetUnitAbilityLevel(target, 'A09W') > 0) {
                ip.add(SID_NAGA_FRENZY, 2500);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else if (SpellData[res].otp == ORDER_TYPE_IMMEDIATE) {
                IssueImmediateOrderById(source, SpellData[res].oid);
            } else {
                IssueTargetOrderById(source, SpellData[res].oid, target);
            }
            ip.destroy();
        }
        tu = null;
    }
    
    // nage tide priest
    function makeOrdern00B(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        unit tu;
        if (!IsUnitChanneling(source) && !UnitProp[source].stunned) {
            ip = IntegerPool.create();
            ip.add(0, 15);
            tu = MobList.getLowestHPPercent();
            if (GetUnitState(tu, UNIT_STATE_LIFE) / GetUnitState(tu, UNIT_STATE_MAX_LIFE) < 0.5) {
                if (UnitCanUse(source, SID_CHAIN_HEALING)) {
                    ip.add(SID_CHAIN_HEALING, 100);
                }
                if (UnitCanUse(source, SID_HEALING_WARD)) {
                    ip.add(SID_HEALING_WARD, 65);
                }
            }
            if (UnitCanUse(source, SID_PROTECTION_WARD) && combatTime > 15.0) {
                ip.add(SID_PROTECTION_WARD, 50);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else if (SpellData[res].otp == ORDER_TYPE_IMMEDIATE) {
                IssueImmediateOrderById(source, SpellData[res].oid);
            } else {
                IssueTargetOrderById(source, SpellData[res].oid, tu);
            }
            ip.destroy();
        }
        tu = null;
    }
    
    // nage royal guard
    function makeOrdern00E(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        unit tu;
        if (!IsUnitChanneling(source) && !UnitProp[source].stunned) {
            ip = IntegerPool.create();
            ip.add(0, 20);
            if (UnitCanUse(source, SID_THUNDER_CLAP) && combatTime > 20.0) {
                ip.add(SID_THUNDER_CLAP, 30);
            }
            if (UnitCanUse(source, SID_RAGE_ROAR) && combatTime > 20.0) {
                ip.add(SID_RAGE_ROAR, 30);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else {
                IssueImmediateOrderById(source, SpellData[res].oid);
            }
            ip.destroy();
        }
        tu = null;
    }
    
    // sea lizard
    function makeOrdern00F(unit source, unit target, real combatTime) {
        IssueTargetOrderById(source, OID_ATTACK, target);
    }
    
    // murloc slave
    function makeOrdern00G(unit source, unit target, real combatTime) {
        IssueTargetOrderById(source, OID_ATTACK, target);
    }
    
    // wind serpent        
    function makeOrdern00N(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        integer i;
        real max, tmp; 
        unit tu;
        if (!IsUnitChanneling(source) && !UnitProp[source].stunned) {
            ip = IntegerPool.create();
            ip.add(0, 10);
            if (UnitCanUse(source, SID_CHARGED_BREATH) && combatTime > 10.0 && GetUnitMana(source) > 500.0) {
                ip.add(SID_CHARGED_BREATH, 200);
            }
            if (UnitCanUse(source, SID_MANA_LEECH)) {
                ip.add(SID_MANA_LEECH, 100);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else {
                if (res == SID_MANA_LEECH) {
                    i = 0;
                    tu = null;
                    max = 0.0;
                    while (i < PlayerUnits.n) { 
                        if (GetDistance.units2d(source, PlayerUnits.units[i]) < 900.0 + 197.0 && !IsUnitDead(PlayerUnits.units[i])) {
                            tmp = RMinBJ(GetUnitMana(PlayerUnits.units[i]), GetUnitState(PlayerUnits.units[i], UNIT_STATE_MAX_MANA));
                            if (max < tmp) {
                                max = tmp;
                                tu = PlayerUnits.units[i];
                            }
                        }
                        i += 1;
                    }
                    if (tu != null) {
                        IssueTargetOrderById(source, SpellData[res].oid, tu);
                    } else {
                        IssueTargetOrderById(source, OID_ATTACK, target);
                    }
                } else {
                    IssueImmediateOrderById(source, SpellData[res].oid);
                }
            }
            ip.destroy();
        }
        tu = null;
    }
    
    function makeOrderncgb(unit source, unit target, real combatTime) {
        if (!IsUnitChanneling(source)) {
            IssueTargetOrderById(source, SpellData[SID_SELF_DESTRUCT].oid, PlayerUnits.getRandomHero());
        }
    }
    
    function makeOrdernfac(unit source, unit target, real combatTime) {
        if (!IsUnitChanneling(source)) {
            IssueImmediateOrderById(source, SpellData[SID_SUMMON_CLOCKWORK_GOBLIN].oid);
        }
    }
    
    function makeOrderTideBaron(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        /*        print("-- - - - - - - - - - - -  -");*/
        if (!IsUnitChanneling(source)) {
            ip = IntegerPool.create();
            if (UnitCanUse(source, SIDTIDEBARONMORPH) && combatTime > 34) {
                ip.add(SIDTIDEBARONMORPH, 50);
            } else {
                if (UnitCanUse(source, SIDTEARUP) && GetUnitAbilityLevel(target, 'A04Z') == 0) {
                    ip.add(SIDTEARUP, 15);
                }
                if (UnitCanUse(source, SIDLANCINATE) && GetUnitAbilityLevel(target, 'A050') == 0) {
                    //print("1");
                    ip.add(SIDLANCINATE, 30);
                }
                if (UnitCanUse(source, SIDRASPYROAR) && combatTime > 5) {
                    ip.add(SIDRASPYROAR, 30);
                }
                ip.add(0, 20);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else if (SpellData[res].otp == ORDER_TYPE_TARGET) {
                IssueTargetOrderById(source, SpellData[res].oid, AggroList[source].getFirst());
            } else if (SpellData[res].otp == ORDER_TYPE_IMMEDIATE) {
                IssueImmediateOrderById(source, SpellData[res].oid);
            }
            ip.destroy();
        }    
    }
    
    function makeOrderTideBaronWater(unit source, unit target, real combatTime) {    
        IntegerPool ip;
        integer res;
        /*        print("-- - - - - - - - - - - -  -");*/
        if (!IsUnitChanneling(source)) {
            ip = IntegerPool.create();
            if (UnitCanUse(source, SIDTIDEBARONMORPH) && combatTime > 34) {
                ip.add(SIDTIDEBARONMORPH, 50);
            } else {
                if (UnitCanUse(source, SIDALKALINEWATER)) {
                    ip.add(SIDALKALINEWATER, 30);
                }
                if (UnitCanUse(source, SIDTIDE) && combatTime > 20) {
                    //print("1");
                    ip.add(SIDTIDE, 15);
                }
                ip.add(0, 30);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else if (SpellData[res].otp == ORDER_TYPE_TARGET) {
                //NotAttacking(source);
                if (res == SIDALKALINEWATER) {
                    IssueTargetOrderById(source, SpellData[res].oid, AggroList[source].getFirst());
                } else {
                    IssueTargetOrderById(source, SpellData[res].oid, PlayerUnits.getRandomHero());
                }
            } else if (SpellData[res].otp == ORDER_TYPE_IMMEDIATE) {
                if (res == SIDTIDEBARONMORPH) {
//print("wanna be slardar");
                    IssueImmediateOrderById(source, OID_UNBEARFORM);
                }
            }
            ip.destroy();
        }    
    }
    
	/*
					#0	RAGE
		P1:	@10s 100%-25%
			@20s	#2	SIDFLAMEBOMB
			@35s	#3	SIDSUMMONLAVASPAWN
					#4	SIDFLAMETHROW
		P2:	25%-0%
					#1	SIDFRENZYWARLOCK
	*/
    function makeOrderWarlock(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        if (!IsUnitChanneling(source)) {
            ip = IntegerPool.create();
			if (UnitCanUse(source, SIDRAGECREEP) && combatTime > 300) {
			// print("makeOrderWarlock: Time > 300 add " + ID2S(SIDRAGECREEP));
				ip.add(SIDRAGECREEP, 30);
			} else if (UnitCanUse(source, SIDFRENZYWARLOCK) && GetUnitStatePercent(source, UNIT_STATE_LIFE, UNIT_STATE_MAX_LIFE) < 26) {
			// print("makeOrderWarlock: HP < 25 add " + ID2S(SIDFRENZYWARLOCK));
				ip.add(SIDFRENZYWARLOCK, 30);
			} else if (UnitCanUse(source, SIDFLAMEBOMB) && combatTime > 20) {
			// print("makeOrderWarlock: Time > 20 add " + ID2S(SIDFLAMEBOMB));
                ip.add(SIDFLAMEBOMB, 30);
            } else if (UnitCanUse(source, SIDSUMMONLAVASPAWN) && combatTime > 35 && GetUnitStatePercent(source, UNIT_STATE_LIFE, UNIT_STATE_MAX_LIFE) > 25) {
			// print("makeOrderWarlock: Time > 35 add " + ID2S(SIDSUMMONLAVASPAWN));
				ip.add(SIDSUMMONLAVASPAWN, 30);
			} else {
				if (UnitCanUse(source, SIDFLAMETHROW) && combatTime > 10) {
			// print("makeOrderWarlock: Time > 10 add " + ID2S(SIDFLAMETHROW));
					ip.add(SIDFLAMETHROW, 50);
				}
				ip.add(0, 20);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else if (SpellData[res].otp == ORDER_TYPE_TARGET) {
				IssueTargetOrderById(source, SpellData[res].oid, PlayerUnits.getRandomHero());
            } else if (SpellData[res].otp == ORDER_TYPE_IMMEDIATE) {
                IssueImmediateOrderById(source, SpellData[res].oid);
            }
            ip.destroy();
        }    
    }
	
	function makeOrderLavaSpawn(unit source, unit target, real combatTime) {
		IssueTargetOrderById(source, OID_ATTACK, target);
	}

    public function OrderCreeps(unit s, unit t, real c) {
        integer utid = GetUnitTypeId(s);
        //print(I2S(R2I(c)));
        if (!focus.exists(s)) {
            //print("注册一次");
            focus[s] = 1;
        }
        if (GetHandleId(t) != focus[s]) {
            //print("改变目标");
            focus[s] = GetHandleId(t);
            pace[s] = 0;
        }
        if (pace[s] == 0) {
            //print("命令");
            if (!unitCallBack.exists(utid)) {
                // print(SCOPE_PREFIX + ">Unregistered unit type order actions.");
            } else {
                UnitActionType(unitCallBack[utid]).evaluate(s, t, c);
            }
        }            
        pace[s] += 1;
        if (pace[s] > 6) {pace[s] = 0;}
        //print(GetUnitName(source) + " wants to attack " + GetUnitName(target));
    }
    
    function register() {
        unitCallBack['Ntin'] = makeOrderNtin;   // Arch Tinker
        unitCallBack['Nrob'] = makeOrderNrob;   // Arch Tinker Morph
        unitCallBack['nfac'] = makeOrdernfac;   // Pocket Factory
        unitCallBack['ncgb'] = makeOrderncgb;   // Clockwork Goblin
        
        unitCallBack['Hvsh'] = makeOrderHvsh;   // 娜迦女巫
        unitCallBack['n003'] = makeOrdern003;   // 飞蛇,劣质的
        
        unitCallBack[UTIDTIDEBARONWATER] = makeOrderTideBaronWater;   // 潮汐男爵 海元素形态
        unitCallBack[UTIDTIDEBARON] = makeOrderTideBaron;   // 潮汐男爵 海元素形态
        unitCallBack[UTIDWARLOCK] = makeOrderWarlock;   // 术士
        unitCallBack[UTID_LAVA_SPAWN] = makeOrderLavaSpawn;   // Lava Spawn
        unitCallBack[UTIDHEXLORD] = makeOrderHexLord;   // 妖术领主
        unitCallBack[UTIDLIGHTNINGTOTEM] = makeOrderLightningTotem;   // 闪电图腾
        
        unitCallBack['n000'] = makeOrdern000;   // 娜迦女妖
        unitCallBack['n00B'] = makeOrdern00B;   // 娜迦潮汐祭司
        unitCallBack['h004'] = makeOrderh004;   // 治疗守卫
        unitCallBack['h005'] = makeOrderh005;   // 防护守卫
        unitCallBack['n00A'] = makeOrdern00A;   // Naga Myrmidon
        unitCallBack['n00E'] = makeOrdern00E;   // Naga Royal Guard
        unitCallBack['n00F'] = makeOrdern00F;   // Sea Lizard
        unitCallBack['n00G'] = makeOrdern00G;   // Murloc Slave
        unitCallBack['n00N'] = makeOrdern00N;   // Wind Serpent
        
        unitCallBack['n001'] = makeOrdern001;   // 恶魔巫师
        unitCallBack['h000'] = makeOrderh000;   // 靶子
        unitCallBack['h002'] = makeOrderh002;   // 靶子
    }
    
    function onInit() {
        focus = HandleTable.create();
        pace = HandleTable.create();
        unitCallBack = Table.create();
        register();
    }
}
//! endzinc
