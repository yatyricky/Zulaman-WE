//! zinc
library CreepsAction requires SpellData, UnitAbilityCD, CastingBar, PlayerUnitList, IntegerPool, UnitProperty, CombatFacts, RandomPoint, Parasite {

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
        if (!IsUnitChanneling(source) && !UnitProp[source].stunned) {
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
        if (!IsUnitChanneling(source) && !UnitProp[source].stunned) {
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
        if (!IsUnitChanneling(source) && !UnitProp[source].stunned) {
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
    function makeOrderNTPHealingWard(unit source, unit target, real combatTime) {}
    
    // protection ward
    function makeOrderNTPProtectionWard(unit source, unit target, real combatTime) {}
    
    // tank tester
    function makeOrderh002(unit source, unit target, real combatTime) {
        IssueTargetOrderById(source, OID_ATTACK, target);
    }
    
    function makeOrderLightningTotem(unit source, unit target, real combatTime) {}
    
    // nage siren
    function makeOrderNagaSiren(unit source, unit target, real combatTime) {
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
    function makeOrderDemonicWitch(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        unit tu;
        if (!IsUnitChanneling(source) && !UnitProp[source].stunned) {
            ip = IntegerPool.create();
            ip.add(0, 10);
            if (UnitCanUse(source, SID_BLAZING_HASTE) && combatTime > 5.0) {
                ip.add(SID_BLAZING_HASTE, 300);
            }
            if (UnitCanUse(source, SID_FIRE_BALL)) {
                ip.add(SID_FIRE_BALL, 200);
            }
            if (UnitCanUse(source, SID_FLAME_SHOCK)) {
                ip.add(SID_FLAME_SHOCK, 200);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else if (res == SID_FIRE_BALL) {
                IssueImmediateOrderById(source, SpellData[res].oid);
            } else if (res == SID_BLAZING_HASTE) {
                if (GetUnitAbilityLevel(source, BID_BLAZING_HASTE) == 0) {
                    tu = source;
                } else {
                    tu = MobList.getWithoutBuff(BID_BLAZING_HASTE);
                    if (tu == null) {
                        tu = source;
                    }
                }
                IssueTargetOrderById(source, SpellData[res].oid, tu);
            } else {
                tu = PlayerUnits.getRandomHero();
                if (tu != null) {
                    IssueTargetOrderById(source, SpellData[res].oid, tu);
                } else {
                    IssueTargetOrderById(source, OID_ATTACK, source);
                }
            }
            ip.destroy();
        }
        tu = null;
    }
    
    // serpent inferior
    function makeOrdern003(unit source, unit target, real combatTime) {
        IssueTargetOrderById(source, OID_ATTACK, target);
    }
    
    // nage myrmidon
    function makeOrderNagaMyrmidon(unit source, unit target, real combatTime) {
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
    function makeOrderNagaTidePriest(unit source, unit target, real combatTime) {
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
    function makeOrderNagaRoyalGuard(unit source, unit target, real combatTime) {
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
    function makeOrderSeaLizard(unit source, unit target, real combatTime) {
        IssueTargetOrderById(source, OID_ATTACK, target);
    }
    
    // murloc slave
    function makeOrderMurlocSlave(unit source, unit target, real combatTime) {
        IssueTargetOrderById(source, OID_ATTACK, target);
    }

    // Noxious Spider
    function makeOrderNoxiousSpider(unit source, unit target, real combatTime) {
        IssueTargetOrderById(source, OID_ATTACK, target);
    }

    function makeOrderJustAttack(unit source, unit target, real combatTime) {
        IssueTargetOrderById(source, OID_ATTACK, target);
    }

    // wind serpent        
    function makeOrderWindSerpent(unit source, unit target, real combatTime) {
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
                ip.add(SID_MANA_LEECH, 35);
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
        if (!IsUnitChanneling(source) && !UnitProp[source].stunned) {
            IssueTargetOrderById(source, SpellData[SID_SELF_DESTRUCT].oid, PlayerUnits.getRandomHero());
        }
    }
    
    function makeOrdernfac(unit source, unit target, real combatTime) {
        if (!IsUnitChanneling(source) && !UnitProp[source].stunned) {
            IssueImmediateOrderById(source, SpellData[SID_SUMMON_CLOCKWORK_GOBLIN].oid);
        }
    }
    
    function makeOrderTideBaron(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        /*        print("-- - - - - - - - - - - -  -");*/
        if (!IsUnitChanneling(source) && !UnitProp[source].stunned) {
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
        if (!IsUnitChanneling(source) && !UnitProp[source].stunned) {
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
        if (!IsUnitChanneling(source) && !UnitProp[source].stunned) {
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

    function makeOrderAbyssArchon(unit source, unit target, real combatTime) {
        if (!IsUnitChanneling(source) && !UnitProp[source].stunned) {
            IssueTargetOrderById(source, OID_ATTACK, target);   
        }
    }

    function makeOrderSpike(unit source, unit target, real combatTime) {}

    function makeOrderPoisonousCrawler(unit source, unit target, real combatTime) {
        IssueTargetOrderById(source, OID_ATTACK, target);   
    }

    function makeOrderAbomination(unit source, unit target, real combatTime) {
        IssueTargetOrderById(source, OID_ATTACK, target);   
    }

    function makeOrderWraith(unit source, unit target, real combatTime) {
        IssueTargetOrderById(source, OID_ATTACK, target);   
    }

    function makeOrderFelGrunt(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        unit tu;
        if (!IsUnitChanneling(source) && !UnitProp[source].stunned) {
            ip = IntegerPool.create();
            ip.add(0, 20);
            if (UnitCanUse(source, SID_UNHOLY_FRENZY) && combatTime > 10.0) {
                ip.add(SID_UNHOLY_FRENZY, 50);
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

    function makeOrderCursedHunter(unit source, unit target, real combatTime) {
        IssueTargetOrderById(source, OID_ATTACK, target);   
    }

    function makeOrderNetherHatchling(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        unit tu;
        if (!IsUnitChanneling(source) && !UnitProp[source].stunned) {
            ip = IntegerPool.create();
            ip.add(0, 20);
            if (UnitCanUse(source, SID_NETHER_SLOW) && combatTime > 10.0) {
                ip.add(SID_NETHER_SLOW, 50);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else {
                IssueTargetOrderById(source, SpellData[res].oid, PlayerUnits.getRandomHero());
            }
            ip.destroy();
        }
        tu = null;
    }

    function makeOrderFelRider(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        unit tu;
        if (!IsUnitChanneling(source) && !UnitProp[source].stunned) {
            ip = IntegerPool.create();
            ip.add(0, 20);
            if (UnitCanUse(source, SID_CHAOS_LEAP) && combatTime > 10.0) {
                ip.add(SID_CHAOS_LEAP, 90);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else {
                tu = PlayerUnits.getFarest(source);
                IssueTargetOrderById(source, SpellData[res].oid, tu);
            }
            ip.destroy();
        }
        tu = null;
    }

    function makeOrderFelWarBringer(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        unit tu;
        if (!IsUnitChanneling(source) && !UnitProp[source].stunned) {
            ip = IntegerPool.create();
            ip.add(0, 20);
            if (UnitCanUse(source, SID_BATTLE_COMMAND) && combatTime > 5.0) {
                ip.add(SID_BATTLE_COMMAND, 200);
            }
            if (UnitCanUse(source, SID_WAR_STOMP) && combatTime > 10.0) {
                ip.add(SID_WAR_STOMP, 90);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else if (res == SID_WAR_STOMP) {
                IssueImmediateOrderById(source, SpellData[res].oid);
            } else {
                tu = MobList.getWithoutBuff(BID_BATTLE_COMMAND);
                if (tu == null) {
                    tu = source;
                }
                IssueTargetOrderById(source, SpellData[res].oid, tu);
            }
            ip.destroy();
        }
        tu = null;
    }

    function makeOrderNetherDrake(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        if (!IsUnitChanneling(source) && !UnitProp[source].stunned) {
            ip = IntegerPool.create();
            ip.add(0, 10);
            if (UnitCanUse(source, SID_NETHER_IMPLOSION) && combatTime > 10.0) {
                ip.add(SID_NETHER_IMPLOSION, 70);
            }
            if (UnitCanUse(source, SID_NETHER_BREATH) && combatTime > 6.0) {
                ip.add(SID_NETHER_BREATH, 40);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else {
                IssueImmediateOrderById(source, SpellData[res].oid);
            }
            ip.destroy();
        }
    }

    function makeOrderDracoLich(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        if (!IsUnitChanneling(source) && !UnitProp[source].stunned) {
            ip = IntegerPool.create();
            ip.add(0, 10);
            if (UnitCanUse(source, SID_DEATH_AND_DECAY) && combatTime > 10.0) {
                ip.add(SID_DEATH_AND_DECAY, 140);
            }
            if (UnitCanUse(source, SID_FROST_GRAVE) && combatTime > 5.0) {
                ip.add(SID_FROST_GRAVE, 140);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else {
                IssueTargetOrderById(source, SpellData[res].oid, PlayerUnits.getRandomHero());
            }
            ip.destroy();
        }
    }

    function makeOrderObsidianConstruct(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        unit tu;
        if (!IsUnitChanneling(source) && !UnitProp[source].stunned) {
            ip = IntegerPool.create();
            ip.add(0, 10);
            if (UnitCanUse(source, SID_MANA_TAP) && combatTime > 8.0) {
                ip.add(SID_MANA_TAP, 50);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else {
                tu = PlayerUnits.getRandomHero();
                IssuePointOrderById(source, SpellData[res].oid, GetUnitX(tu), GetUnitY(tu));
                tu = null;
            }
            ip.destroy();
        }
    }

    function makeOrderParasiticalRoach(unit source, unit target, real combatTime) {
        if (!IsUnitChanneling(source) && !UnitProp[source].stunned) {
            if (combatTime > 10.0) {
                ParasiteOnTarget(source, PlayerUnits.getRandomHero());
            } else {
                IssueTargetOrderById(source, OID_ATTACK, target);
            }
        }   
    }

    function makeOrderGargantuan(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        if (!IsUnitChanneling(source) && !UnitProp[source].stunned) {
            ip = IntegerPool.create();
            ip.add(0, 10);
            if (UnitCanUse(source, SID_VOMIT) && combatTime > 15.0) {
                ip.add(SID_VOMIT, 30);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else {
                IssueImmediateOrderById(source, SpellData[res].oid);
            }
            ip.destroy();
        }
    }

    function makeOrderZombie(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        if (!IsUnitChanneling(source) && !UnitProp[source].stunned) {
            ip = IntegerPool.create();
            ip.add(0, 10);
            if (UnitCanUse(source, SID_GNAW) && combatTime > 5.0) {
                ip.add(SID_GNAW, 30);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else {
                IssueTargetOrderById(source, SpellData[res].oid, target);
            }
            ip.destroy();
        }
    }

    function makeOrderFacelessOne(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        if (!IsUnitChanneling(source) && !UnitProp[source].stunned) {
            ip = IntegerPool.create();
            ip.add(0, 10);
            if (UnitCanUse(source, SID_VICIOUS_STRIKE) && combatTime > 5.0) {
                ip.add(SID_VICIOUS_STRIKE, 30);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else {
                IssueTargetOrderById(source, SpellData[res].oid, PlayerUnits.getRandomHero());
            }
            ip.destroy();
        }
    }

    function makeOrderFelHound(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        if (!IsUnitChanneling(source) && !UnitProp[source].stunned) {
            ip = IntegerPool.create();
            ip.add(0, 10);
            if (UnitCanUse(source, SID_MANA_BURN) && combatTime > 5.0) {
                ip.add(SID_MANA_BURN, 30);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else {
                IssueTargetOrderById(source, SpellData[res].oid, PlayerUnits.getHighestMP());
            }
            ip.destroy();
        }
    }

    function makeOrderDerangedPriest(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        if (!IsUnitChanneling(source) && !UnitProp[source].stunned) {
            ip = IntegerPool.create();
            ip.add(0, 10);
            if (UnitCanUse(source, SID_CORPSE_RAIN) && combatTime > 10.0) {
                ip.add(SID_CORPSE_RAIN, 70);
            }
            if (UnitCanUse(source, SID_VOODOO_DOLL) && combatTime > 15.0) {
                ip.add(SID_VOODOO_DOLL, 200);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else {
                IssueTargetOrderById(source, SpellData[res].oid, PlayerUnits.getRandomHero());
            }
            ip.destroy();
        }
    }

    function makeOrderForestTroll(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        if (!IsUnitChanneling(source) && !UnitProp[source].stunned) {
            ip = IntegerPool.create();
            ip.add(0, 10);
            if (UnitCanUse(source, SID_CRUSHING_BLOW) && combatTime > 5.0) {
                ip.add(SID_CRUSHING_BLOW, 100);
            }
            if (UnitCanUse(source, SID_FOREST_STOMP) && combatTime > 10.0) {
                ip.add(SID_FOREST_STOMP, 40);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else if (res == SID_CRUSHING_BLOW) {
                IssueTargetOrderById(source, SpellData[res].oid, target);
            } else {
                IssueImmediateOrderById(source, SpellData[res].oid);
            }
            ip.destroy();
        }
    }

    function makeOrderInfernoConstruct(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        unit tu;
        if (!IsUnitChanneling(source) && !UnitProp[source].stunned) {
            ip = IntegerPool.create();
            ip.add(0, 10);
            if (UnitCanUse(source, SID_METEOR) && combatTime > 10.0) {
                ip.add(SID_METEOR, 30);
            }
            if (UnitCanUse(source, SID_BURNING) && combatTime > 5.0) {
                ip.add(SID_BURNING, 90);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else if (res == SID_METEOR) {
                tu = PlayerUnits.getRandomHero();
                // print("Random Target = " + GetUnitNameEx(tu));
                IssuePointOrderById(source, SpellData[res].oid, GetUnitX(tu), GetUnitY(tu));
                tu = null;
            } else {
                IssueImmediateOrderById(source, SpellData[res].oid);
            }
            ip.destroy();
        }
    }

    function makeOrderMaidOfAgony(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        if (!IsUnitChanneling(source) && !UnitProp[source].stunned) {
            ip = IntegerPool.create();
            ip.add(0, 10);
            if (UnitCanUse(source, SID_SHADOW_SPIKE) && combatTime > 5.0) {
                ip.add(SID_SHADOW_SPIKE, 30);
            }
            if (UnitCanUse(source, SID_MARK_OF_AGONY) && combatTime > 10.0) {
                ip.add(SID_MARK_OF_AGONY, 200);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else {
                IssueTargetOrderById(source, SpellData[res].oid, PlayerUnits.getRandomHero());
            }
            ip.destroy();
        }
    }

    function makeOrderVoidWalker(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        if (!IsUnitChanneling(source) && !UnitProp[source].stunned) {
            ip = IntegerPool.create();
            ip.add(0, 10);
            if (UnitCanUse(source, SID_NETHER_BOLT) && combatTime > 5.0 && GetUnitStatePercent(source, UNIT_STATE_LIFE, UNIT_STATE_MAX_LIFE) > 30) {
                ip.add(SID_NETHER_BOLT, 50);
            }
            if (UnitCanUse(source, SID_SHADOW_SHIFT) && combatTime > 7.0 && GetUnitStatePercent(source, UNIT_STATE_LIFE, UNIT_STATE_MAX_LIFE) < 90) {
                ip.add(SID_SHADOW_SHIFT, 50);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else if (res == SID_NETHER_BOLT) {
                IssueTargetOrderById(source, SpellData[res].oid, PlayerUnits.getHighestHP());
            } else {
                IssueTargetOrderById(source, SpellData[res].oid, target);
            }
            ip.destroy();
        }
    }

    function makeOrderGrimTotem(unit source, unit target, real combatTime) {}

    function makeOrderTwilightWitchDoctor(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        if (!IsUnitChanneling(source) && !UnitProp[source].stunned) {
            ip = IntegerPool.create();
            ip.add(0, 10);
            if (UnitCanUse(source, SID_GRIM_TOTEM) && combatTime > 5.0) {
                ip.add(SID_GRIM_TOTEM, 50);
            }
            if (UnitCanUse(source, SID_POISON_DART) && combatTime > 5.0) {
                ip.add(SID_POISON_DART, 50);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else if (res == SID_GRIM_TOTEM) {
                IssueImmediateOrderById(source, SpellData[res].oid);
            } else {
                IssueTargetOrderById(source, SpellData[res].oid, target);
            }
            ip.destroy();
        }
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

        unitCallBack[UTID_PIT_ARCHON] = makeOrderAbyssArchon;
        unitCallBack[UTID_SPIKE] = makeOrderSpike;
        unitCallBack[UTID_POISONOUS_CRAWLER] = makeOrderPoisonousCrawler;
        unitCallBack[UTID_ABOMINATION] = makeOrderAbomination;
        unitCallBack[UTID_WRAITH] = makeOrderWraith;

        unitCallBack[UTIDHEXLORD] = makeOrderHexLord;   // 妖术领主
        unitCallBack[UTIDLIGHTNINGTOTEM] = makeOrderLightningTotem;   // 闪电图腾
        
        // ============= Area 1, 2 ==================
        unitCallBack[UTID_NAGA_SIREN] = makeOrderNagaSiren;   // Naga Siren
        unitCallBack[UTID_NAGA_TIDE_PRIEST] = makeOrderNagaTidePriest;   // Naga Tide Priest
        unitCallBack[UTID_NTR_HEALING_WARD] = makeOrderNTPHealingWard;   // NTP Healing Ward
        unitCallBack[UTID_NTR_PROTECTION_WARD] = makeOrderNTPProtectionWard;   // NTP Protection Ward
        unitCallBack[UTID_NAGA_MYRMIDON] = makeOrderNagaMyrmidon;   // Naga Myrmidon
        unitCallBack[UTID_CHMP_NAGA_MYRMIDON] = makeOrderNagaMyrmidon;
        unitCallBack[UTID_NAGA_ROYAL_GUARD] = makeOrderNagaRoyalGuard;   // Naga Royal Guard
        unitCallBack[UTID_SEA_LIZARD] = makeOrderSeaLizard;   // Sea Lizard
        unitCallBack[UTID_MURLOC_SLAVE] = makeOrderMurlocSlave;   // Murloc Slave
        unitCallBack[UTID_WIND_SERPENT] = makeOrderWindSerpent;   // Wind Serpent

        // ============= Area 3 ==================
        unitCallBack[UTID_FEL_GRUNT] = makeOrderFelGrunt;   // Fel Grunt
        unitCallBack[UTID_FEL_RIDER] = makeOrderFelRider;   // Fel Rider
        unitCallBack[UTID_FEL_WAR_BRINGER] = makeOrderFelWarBringer; // Fel war bringer
        unitCallBack[UTID_DEMONIC_WITCH] = makeOrderDemonicWitch;   // 

        // ============= Area 4 ==================
        unitCallBack[UTID_NOXIOUS_SPIDER] = makeOrderNoxiousSpider;
        unitCallBack[UTID_PARASITICAL_ROACH] = makeOrderParasiticalRoach;    // ParasiticalRoach
        unitCallBack[UTID_ZOMBIE] = makeOrderZombie;    // zombie
        unitCallBack[UTID_DRACOLICH] = makeOrderDracoLich;    // dracolich

        unitCallBack[UTID_OBSIDIAN_CONSTRUCT] = makeOrderObsidianConstruct;   // 

        // ============= Area 5 ==================
        unitCallBack[UTID_VOID_WALKER] = makeOrderVoidWalker;
        unitCallBack[UTID_FEL_HOUND] = makeOrderFelHound;
        unitCallBack[UTID_MAID_OF_AGONY] = makeOrderMaidOfAgony;
        unitCallBack[UTID_NETHER_DRAKE] = makeOrderNetherDrake;
        unitCallBack[UTID_NETHER_HATCHLING] = makeOrderNetherHatchling;
        unitCallBack[UTID_INFERNO_CONSTRUCT] = makeOrderInfernoConstruct;   // inferno construct

        // ============= Area 6 ==================
        unitCallBack[UTID_FOREST_TROLL] = makeOrderForestTroll;
        unitCallBack[UTID_CURSED_HUNTER] = makeOrderCursedHunter;
        unitCallBack[UTID_DERANGED_PRIEST] = makeOrderDerangedPriest;
        unitCallBack[UTID_GARGANTUAN] = makeOrderGargantuan;
        unitCallBack[UTID_VOMIT_MAGGOT] = makeOrderJustAttack;
        unitCallBack[UTID_TWILIGHT_WITCH_DOCTOR] = makeOrderTwilightWitchDoctor;
        unitCallBack[UTID_GRIM_TOTEM] = makeOrderGrimTotem;
        unitCallBack[UTID_FACELESS_ONE] = makeOrderFacelessOne;

        unitCallBack['h000'] = makeOrderh000;   //
        unitCallBack['h002'] = makeOrderh002;   //
    }
    
    function onInit() {
        focus = HandleTable.create();
        pace = HandleTable.create();
        unitCallBack = Table.create();
        register();
    }
}
//! endzinc
