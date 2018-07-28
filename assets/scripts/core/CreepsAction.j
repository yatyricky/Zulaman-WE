//! zinc
library CreepsAction requires SpellData, UnitAbilityCD, CastingBar, PlayerUnitList, IntegerPool, UnitProperty, CombatFacts, RandomPoint, Parasite, GodOfDeathGlobal {

    Table unitCallBack;
    HandleTable focus, pace;
    type UnitActionType extends function(unit, unit, real);

    function makeOrderDoNothing(unit source, unit target, real combatTime) {}

    function makeOrderJustAttack(unit source, unit target, real combatTime) {
        IssueTargetOrderById(source, OID_ATTACK, target);
    }

    function makeOrderHexLord(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        real x, y, l, a;
        unit tar = null;
        if (!IsUnitChanneling(source) && GetUnitAbilityLevel(source, SID_APIV) == 0) {
            ip = IntegerPool.create();
            if (UnitCanUse(source, SID_SPIRIT_BOLT) && combatTime > 30) {
                ip.add(SID_SPIRIT_BOLT, 30);
            } else {
                if (UnitCanUse(source, SID_SPIRIT_HARVEST) && GetUnitStatePercent(source, UNIT_STATE_LIFE, UNIT_STATE_MAX_LIFE) < 80) {
                    ip.add(SID_SPIRIT_HARVEST, 30);
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
            // print("选取技能"+SpellData.inst(res, SCOPE_PREFIX).name);
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else if (SpellData.inst(res, SCOPE_PREFIX).otp == ORDER_TYPE_TARGET) {
                if (res == SID_DARK_ARROW_HEX || res == SID_STEALTH_HEX || res == SID_PAIN_HEX) {
                    tar = PlayerUnits.getRandomHero();                    
                } else if (res == SID_POLYMORPH_HEX) {
                    tar = PlayerUnits.getRandomExclude(target);
                } else if (res == SID_LIFE_BLOOMHEX || res == SID_HOLY_BOLT_HEX || res == SID_HEAL_HEX || res == SID_SHIELD_HEX) {
                    tar = MobList.getLowestHPPercent();
                } else if (res == SID_HOLY_SHOCK_HEX) {
                    if (GetRandomInt(0, 1) == 1) {
                        tar = PlayerUnits.getRandomHero();
                    } else {
                        tar = MobList.getRandom();
                    }
                }
                if (tar != null) {target = tar;}
                //print("Going to " + SpellData.inst(res, SCOPE_PREFIX).name + " on " + GetUnitNameEx(target));
                IssueTargetOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, target);
            } else if (SpellData.inst(res, SCOPE_PREFIX).otp == ORDER_TYPE_IMMEDIATE) {
                IssueImmediateOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid);
            }
            ip.destroy();
        }
    }
    
    // nage sea witch
    function makeOrderHvsh(unit source, unit target, real combatTime) {        
        IntegerPool ip;
        integer res;
        unit tu;
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
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
            } else if (SpellData.inst(res, SCOPE_PREFIX).otp == ORDER_TYPE_TARGET) {
                //NotAttacking(source);
                if (res == 'A03L') {
                    IssueTargetOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, PlayerUnits.getFarest(source));
                } else {
                    tu = PlayerUnits.getRandomHero(); // to avoid that strong breeze clashes with thunder storm
                    if (!UnitProp.inst(tu, SCOPE_PREFIX).stunned) {
                        IssueTargetOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, tu);
                    }
                }
            } else if (SpellData.inst(res, SCOPE_PREFIX).otp == ORDER_TYPE_IMMEDIATE) {
                //NotAttacking(source);
                IssueImmediateOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid);
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
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
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
            } else if (SpellData.inst(res, SCOPE_PREFIX).otp == ORDER_TYPE_TARGET) {
                IssueTargetOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, tu);
            } else if (SpellData.inst(res, SCOPE_PREFIX).otp == ORDER_TYPE_IMMEDIATE) {
                IssueImmediateOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid);
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
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
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
            } else if (SpellData.inst(res, SCOPE_PREFIX).otp == ORDER_TYPE_TARGET) {
                IssueTargetOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, tu);
            } else if (SpellData.inst(res, SCOPE_PREFIX).otp == ORDER_TYPE_IMMEDIATE) {
                IssueImmediateOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid);
            }
            ip.destroy();
        }
    }

    function onEffectFelPortalInvulnerable(Buff buf) {
        StunBoss(buf.bd.target, buf.bd.target, 999);
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageTaken -= buf.bd.r0;
    }

    function onRemoveFelPortalInvulnerable(Buff buf) {
        RemoveStun(buf.bd.target);
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageTaken += buf.bd.r0;
    }

    function lockFelGuards(unit lock, unit unlock) {
        Buff buf;
        BuffSlot bs;
        if (GetUnitStatePercent(lock, UNIT_STATE_LIFE, UNIT_STATE_MAX_LIFE) > 20) {
            SetUnitPosition(lock, 100, 100);
            AddTimedEffect.atUnit(ART_MASS_TELEPORT_TARGET, lock, "origin", 1.0);
            buf = Buff.cast(lock, lock, BID_PORTAL_INVULNERABLE);
            buf.bd.tick = -1;
            buf.bd.interval = 120;
            UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageTaken += buf.bd.r0;
            buf.bd.r0 = 5.0;
            buf.bd.boe = onEffectFelPortalInvulnerable;
            buf.bd.bor = onRemoveFelPortalInvulnerable;
            buf.run();
        } else {
            bs = BuffSlot[lock];
            buf = bs.getBuffByBid(BID_PORTAL_INVULNERABLE);
            if (buf != 0) {
                bs.dispelByBuff(buf);
                buf.destroy();
            }
        }
        bs = BuffSlot[unlock];
        buf = bs.getBuffByBid(BID_PORTAL_INVULNERABLE);
        if (buf != 0) {
            bs.dispelByBuff(buf);
            buf.destroy();
        }
    }

    function makeOrderFelGuard(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        integer state = 0;
        if (combatTime >= FelGuardsGlobals.stage * 40) {
            FelGuardsGlobals.stage += 1;
            if (ModuloInteger(FelGuardsGlobals.stage, 2) == 1) {
                lockFelGuards(FelGuardsGlobals.bossGuard, FelGuardsGlobals.bossDefender);
            } else {
                lockFelGuards(FelGuardsGlobals.bossDefender, FelGuardsGlobals.bossGuard);
            }
        }
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
            ip = IntegerPool.create();
            if (GetUnitStatePercent(source, UNIT_STATE_LIFE, UNIT_STATE_MAX_LIFE) < 4) {
                if (GetUnitStatePercent(FelGuardsGlobals.bossDefender, UNIT_STATE_LIFE, UNIT_STATE_MAX_LIFE) >= 4) {
                    ip.add(SID_SOUL_LINK, 100);
                    state = 1;
                } else {
                    KillUnit(source);
                    KillUnit(FelGuardsGlobals.bossDefender);
                }
            }
            if (state == 0) {
                if (UnitCanUse(source, SID_FEL_EXECUTION) && combatTime > 15.0) {
                    ip.add(SID_FEL_EXECUTION, 30);
                }
                if (UnitCanUse(source, SID_POWER_SLASH) && combatTime > 10.0) {
                    ip.add(SID_POWER_SLASH, 30);
                }
                if (UnitCanUse(source, SID_FEL_FRENZY) && combatTime > 15.0) {
                    ip.add(SID_FEL_FRENZY, 30);
                }
                ip.add(0, 10);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else if (res == SID_FEL_EXECUTION) {
                IssueTargetOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, PlayerUnits.getRandomHero());
            } else if (res == SID_POWER_SLASH) {
                IssueTargetOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, target);
            } else if (res == SID_FEL_FRENZY) {
                IssueImmediateOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid);
            } else if (res == SID_SOUL_LINK) {
                IssueTargetOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, FelGuardsGlobals.bossDefender);
            }
            ip.destroy();
        }
    }

    function makeOrderFelDefender(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        unit tu;
        integer state = 0;
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
            ip = IntegerPool.create();
            if (GetUnitStatePercent(source, UNIT_STATE_LIFE, UNIT_STATE_MAX_LIFE) < 4) {
                if (GetUnitStatePercent(FelGuardsGlobals.bossGuard, UNIT_STATE_LIFE, UNIT_STATE_MAX_LIFE) >= 4) {
                    ip.add(SID_SOUL_LINK, 100);
                    state = 1;
                } else {
                    KillUnit(source);
                    KillUnit(FelGuardsGlobals.bossGuard);
                }
            }
            if (state == 0) {
                if (UnitCanUse(source, SID_POWER_SHADOW_SHIFT) && combatTime > 15.0) {
                    ip.add(SID_POWER_SHADOW_SHIFT, 20);
                }
                if (UnitCanUse(source, SID_SHADOW_DETONATION) && combatTime > 10.0) {
                    ip.add(SID_SHADOW_DETONATION, 50);
                }
                ip.add(0, 10);
            }
            
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else if (res == SID_POWER_SHADOW_SHIFT) {
                IssueTargetOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, PlayerUnits.getRandomHero());
            } else if (res == SID_SHADOW_DETONATION) {
                tu = PlayerUnits.getRandomHero();
                IssuePointOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, GetUnitX(tu), GetUnitY(tu));
                tu = null;
            } else if (res == SID_SOUL_LINK) {
                IssueTargetOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, FelGuardsGlobals.bossGuard);
            }
            ip.destroy();
        }
    }
    
    // nage siren
    function makeOrderNagaSiren(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        unit tu;
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
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
                IssueTargetOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, tu);
                tu = null;
            } else {
                IssueTargetOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, target);
            }
            ip.destroy();
        }
    }
    
    // demon witch
    function makeOrderDemonicWitch(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        unit tu;
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
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
                IssueImmediateOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid);
            } else if (res == SID_BLAZING_HASTE) {
                if (GetUnitAbilityLevel(source, BID_BLAZING_HASTE) == 0) {
                    tu = source;
                } else {
                    tu = MobList.getWithoutBuff(BID_BLAZING_HASTE);
                    if (tu == null) {
                        tu = source;
                    }
                }
                IssueTargetOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, tu);
            } else {
                tu = PlayerUnits.getRandomHero();
                if (tu != null) {
                    IssueTargetOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, tu);
                } else {
                    IssueTargetOrderById(source, OID_ATTACK, source);
                }
            }
            ip.destroy();
        }
        tu = null;
    }
    
    // nage myrmidon
    function makeOrderNagaMyrmidon(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        unit tu;
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
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
            } else if (SpellData.inst(res, SCOPE_PREFIX).otp == ORDER_TYPE_IMMEDIATE) {
                IssueImmediateOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid);
            } else {
                IssueTargetOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, target);
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
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
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
            } else if (SpellData.inst(res, SCOPE_PREFIX).otp == ORDER_TYPE_IMMEDIATE) {
                IssueImmediateOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid);
            } else {
                IssueTargetOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, tu);
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
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
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
                IssueImmediateOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid);
            }
            ip.destroy();
        }
        tu = null;
    }
    
    // wind serpent        
    function makeOrderWindSerpent(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        integer i;
        real max, tmp; 
        unit tu;
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
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
                        IssueTargetOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, tu);
                    } else {
                        IssueTargetOrderById(source, OID_ATTACK, target);
                    }
                } else {
                    IssueImmediateOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid);
                }
            }
            ip.destroy();
        }
        tu = null;
    }
    
    function makeOrderClockwerkGoblin(unit source, unit target, real combatTime) {
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
            IssueTargetOrderById(source, SpellData.inst(SID_SELF_DESTRUCT, SCOPE_PREFIX).oid, PlayerUnits.getRandomHero());
        }
    }
    
    function makeOrdernfac(unit source, unit target, real combatTime) {
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
            IssueImmediateOrderById(source, SpellData.inst(SID_SUMMON_CLOCKWORK_GOBLIN, SCOPE_PREFIX).oid);
        }
    }
    
    function makeOrderTideBaron(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
            ip = IntegerPool.create();
            if (UnitCanUse(source, SID_TIDE_BARON_MORPH) && combatTime > 34) {
                ip.add(SID_TIDE_BARON_MORPH, 50);
            } else {
                if (UnitCanUse(source, SID_TEAR_UP) && GetUnitAbilityLevel(target, 'A04Z') == 0) {
                    ip.add(SID_TEAR_UP, 15);
                }
                if (UnitCanUse(source, SID_LANCINATE) && GetUnitAbilityLevel(target, 'A050') == 0) {
                    //print("1");
                    ip.add(SID_LANCINATE, 30);
                }
                if (UnitCanUse(source, SID_RASPY_ROAR) && combatTime > 5) {
                    ip.add(SID_RASPY_ROAR, 30);
                }
                ip.add(0, 20);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else if (SpellData.inst(res, SCOPE_PREFIX).otp == ORDER_TYPE_TARGET) {
                IssueTargetOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, AggroList[source].getFirst());
            } else if (SpellData.inst(res, SCOPE_PREFIX).otp == ORDER_TYPE_IMMEDIATE) {
                IssueImmediateOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid);
            }
            ip.destroy();
        }    
    }
    
    function makeOrderTideBaronWater(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        unit tu;
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
            ip = IntegerPool.create();
            if (UnitCanUse(source, SID_TIDE_BARON_MORPH) && combatTime > 34) {
                ip.add(SID_TIDE_BARON_MORPH, 50);
            } else {
                if (UnitCanUse(source, SID_ALKALINE_WATER)) {
                    ip.add(SID_ALKALINE_WATER, 30);
                }
                if (UnitCanUse(source, SID_TIDE) && combatTime > 20) {
                    ip.add(SID_TIDE, 30);
                }
                ip.add(0, 20);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else if (res == SID_ALKALINE_WATER) {
                IssueTargetOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, AggroList[source].getFirst());
            } else if (res == SID_TIDE) {
                tu = PlayerUnits.getRandomHero();
                IssuePointOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, GetUnitX(tu), GetUnitY(tu));
                tu = null;
            } else {
                IssueImmediateOrderById(source, OID_UNBEARFORM);
            }
            ip.destroy();
        }    
    }
    
    /*
                    #0    RAGE
        P1:    @10s 100%-25%
            @20s    #2    SID_FLAME_BOMB
            @35s    #3    SID_SUMMON_LAVA_SPAWN
                    #4    SID_FLAME_THROW
        P2:    25%-0%
                    #1    SID_FRENZY_WARLOCK
    */
    function makeOrderWarlock(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
            ip = IntegerPool.create();
            if (UnitCanUse(source, SID_DANCE_MAT) && GetFireRune() == null) {
                ip.add(SID_DANCE_MAT, 30);
            } else if (UnitCanUse(source, SID_FRENZY_WARLOCK) && GetUnitStatePercent(source, UNIT_STATE_LIFE, UNIT_STATE_MAX_LIFE) < 26) {
            // print("makeOrderWarlock: HP < 25 add " + ID2S(SID_FRENZY_WARLOCK));
                ip.add(SID_FRENZY_WARLOCK, 30);
            } else if (UnitCanUse(source, SID_FLAME_BOMB) && combatTime > 20) {
            // print("makeOrderWarlock: Time > 20 add " + ID2S(SID_FLAME_BOMB));
                ip.add(SID_FLAME_BOMB, 30);
            } else if (UnitCanUse(source, SID_SUMMON_LAVA_SPAWN) && combatTime > 35 && GetUnitStatePercent(source, UNIT_STATE_LIFE, UNIT_STATE_MAX_LIFE) > 25) {
            // print("makeOrderWarlock: Time > 35 add " + ID2S(SID_SUMMON_LAVA_SPAWN));
                ip.add(SID_SUMMON_LAVA_SPAWN, 30);
            } else {
                if (UnitCanUse(source, SID_FLAME_THROW) && combatTime > 10) {
            // print("makeOrderWarlock: Time > 10 add " + ID2S(SID_FLAME_THROW));
                    ip.add(SID_FLAME_THROW, 50);
                }
                ip.add(0, 20);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else if (SpellData.inst(res, SCOPE_PREFIX).otp == ORDER_TYPE_TARGET) {
                IssueTargetOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, PlayerUnits.getRandomHero());
            } else if (SpellData.inst(res, SCOPE_PREFIX).otp == ORDER_TYPE_IMMEDIATE) {
                IssueImmediateOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid);
            }
            ip.destroy();
        }    
    }

    function makeOrderAbyssArchon(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
            ip = IntegerPool.create();
            ip.add(0, 1);
            if (UnitCanUse(source, SID_SUMMON_POISONOUS_CRAWLER) && combatTime > 20) {
                ip.add(SID_SUMMON_POISONOUS_CRAWLER, 50);
            } else {
                if (UnitCanUse(source, SID_LIFE_SIPHON) && combatTime > 40 && GetUnitStatePercent(source, UNIT_STATE_LIFE, UNIT_STATE_MAX_LIFE) < 81) {
                    ip.add(SID_LIFE_SIPHON, 100);
                } else {
                    if (UnitCanUse(source, SID_IMPALE) && combatTime > 15) {
                        ip.add(SID_IMPALE, 100);
                    }
                    if (UnitCanUse(source, SID_SUMMON_ABOMINATION) && GetUnitStatePercent(source, UNIT_STATE_LIFE, UNIT_STATE_MAX_LIFE) < 51) {
                        ip.add(SID_SUMMON_ABOMINATION, 50);
                    }
                    if (UnitCanUse(source, SID_SUMMON_WRAITH) && GetUnitStatePercent(source, UNIT_STATE_LIFE, UNIT_STATE_MAX_LIFE) < 21) {
                        ip.add(SID_SUMMON_WRAITH, 50);
                    }
                }
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else if (SpellData.inst(res, SCOPE_PREFIX).otp == ORDER_TYPE_TARGET) {
                IssueTargetOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, PlayerUnits.getRandomHero());
            } else if (SpellData.inst(res, SCOPE_PREFIX).otp == ORDER_TYPE_IMMEDIATE) {
                logi("issued order " + ID2S(res));
                IssueImmediateOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid);
            }
            ip.destroy();
        }
    }

    function makeOrderFelGrunt(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        unit tu;
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
            ip = IntegerPool.create();
            ip.add(0, 20);
            if (UnitCanUse(source, SID_UNHOLY_FRENZY) && combatTime > 10.0) {
                ip.add(SID_UNHOLY_FRENZY, 50);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else {
                IssueImmediateOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid);
            }
            ip.destroy();
        }
        tu = null;
    }

    function makeOrderNetherHatchling(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        unit tu;
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
            ip = IntegerPool.create();
            ip.add(0, 20);
            if (UnitCanUse(source, SID_NETHER_SLOW) && combatTime > 10.0) {
                ip.add(SID_NETHER_SLOW, 50);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else {
                IssueTargetOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, PlayerUnits.getRandomHero());
            }
            ip.destroy();
        }
        tu = null;
    }

    function makeOrderFelRider(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        unit tu;
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
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
                IssueTargetOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, tu);
            }
            ip.destroy();
        }
        tu = null;
    }

    function makeOrderFelWarBringer(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        unit tu;
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
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
                IssueImmediateOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid);
            } else {
                tu = MobList.getWithoutBuff(BID_BATTLE_COMMAND);
                if (tu == null) {
                    tu = source;
                }
                IssueTargetOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, tu);
            }
            ip.destroy();
        }
        tu = null;
    }

    function makeOrderNetherDrake(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
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
                IssueImmediateOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid);
            }
            ip.destroy();
        }
    }

    function makeOrderDracoLich(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
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
                IssueTargetOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, PlayerUnits.getRandomHero());
            }
            ip.destroy();
        }
    }

    function makeOrderObsidianConstruct(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        unit tu;
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
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
                IssuePointOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, GetUnitX(tu), GetUnitY(tu));
                tu = null;
            }
            ip.destroy();
        }
    }

    function makeOrderParasiticalRoach(unit source, unit target, real combatTime) {
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
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
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
            ip = IntegerPool.create();
            ip.add(0, 10);
            if (UnitCanUse(source, SID_VOMIT) && combatTime > 15.0) {
                ip.add(SID_VOMIT, 30);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else {
                IssueImmediateOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid);
            }
            ip.destroy();
        }
    }

    function makeOrderZombie(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
            ip = IntegerPool.create();
            ip.add(0, 10);
            if (UnitCanUse(source, SID_GNAW) && combatTime > 5.0) {
                ip.add(SID_GNAW, 30);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else {
                IssueTargetOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, target);
            }
            ip.destroy();
        }
    }

    function makeOrderFacelessOne(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
            ip = IntegerPool.create();
            ip.add(0, 10);
            if (UnitCanUse(source, SID_VICIOUS_STRIKE) && combatTime > 5.0) {
                ip.add(SID_VICIOUS_STRIKE, 30);
            }
            if (UnitCanUse(source, SID_FILTHY_LAND) && combatTime > 10.0) {
                ip.add(SID_FILTHY_LAND, 300);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else if (res == SID_VICIOUS_STRIKE) {
                IssueTargetOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, PlayerUnits.getRandomHero());
            } else {
                IssueImmediateOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid);
            }
            ip.destroy();
        }
    }

    function makeOrderNoxiousSpider(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
            ip = IntegerPool.create();
            ip.add(0, 10);
            if (UnitCanUse(source, SID_SUMMON_PARASITICAL_ROACH) && combatTime > 30.0) {
                ip.add(SID_SUMMON_PARASITICAL_ROACH, 50);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else {
                IssueImmediateOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid);
            }
            ip.destroy();
        }
    }

    function makeOrderFelHound(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
            ip = IntegerPool.create();
            ip.add(0, 10);
            if (UnitCanUse(source, SID_MANA_BURN) && combatTime > 5.0) {
                ip.add(SID_MANA_BURN, 30);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else {
                IssueTargetOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, PlayerUnits.getHighestMP());
            }
            ip.destroy();
        }
    }

    function makeOrderDerangedPriest(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
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
                IssueTargetOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, PlayerUnits.getRandomHero());
            }
            ip.destroy();
        }
    }

    function makeOrderForestTroll(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
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
                IssueTargetOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, target);
            } else {
                IssueImmediateOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid);
            }
            ip.destroy();
        }
    }

    function makeOrderSkeletalMage(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        unit tu;
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
            ip = IntegerPool.create();
            ip.add(0, 10);
            if (UnitCanUse(source, SID_CURSE_OF_THE_DEAD) && combatTime > 10.0) {
                ip.add(SID_CURSE_OF_THE_DEAD, 30);
            }
            if (UnitCanUse(source, SID_DEATH_ORB) && combatTime > 7.0) {
                ip.add(SID_DEATH_ORB, 30);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else if (res == SID_CURSE_OF_THE_DEAD) {
                tu = PlayerUnits.getRandomHero();
                IssueTargetOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, tu);
                tu = null;
            } else {
                IssueTargetOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, PlayerUnits.getRandomHero());
            }
            ip.destroy();
        }
    }

    function makeOrderInfernoConstruct(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        unit tu;
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
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
                IssuePointOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, GetUnitX(tu), GetUnitY(tu));
                tu = null;
            } else {
                IssueImmediateOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid);
            }
            ip.destroy();
        }
    }

    function makeOrderMaidOfAgony(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
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
                IssueTargetOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, PlayerUnits.getRandomHero());
            }
            ip.destroy();
        }
    }

    function makeOrderVoidWalker(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
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
                IssueTargetOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, PlayerUnits.getHighestHP());
            } else {
                IssueTargetOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, target);
            }
            ip.destroy();
        }
    }

    function makeOrderTwilightWitchDoctor(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
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
                IssueImmediateOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid);
            } else {
                IssueTargetOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, target);
            }
            ip.destroy();
        }
    }

    function makeOrderGazakroth(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
            ip = IntegerPool.create();
            ip.add(0, 10);
            if (UnitCanUse(source, SID_FIRE_BOLT)) {
                ip.add(SID_FIRE_BOLT, 100);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else {
                IssueImmediateOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid);
            }
            ip.destroy();
        }
    }

    function makeOrderLordRaadan(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
            ip = IntegerPool.create();
            ip.add(0, 10);
            if (UnitCanUse(source, SID_FIRE_NOVA)) {
                ip.add(SID_FIRE_NOVA, 50);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else {
                IssueImmediateOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid);
            }
            ip.destroy();
        }
    }

    function makeOrderDarkheart(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
            ip = IntegerPool.create();
            ip.add(0, 30);
            if (UnitCanUse(source, SID_PSYCHIC_WAIL)) {
                ip.add(SID_PSYCHIC_WAIL, 50);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, PlayerUnits.getRandomHero());
            } else {
                IssueImmediateOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid);
            }
            ip.destroy();
        }
    }

    function makeOrderAlysonAntille(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
            ip = IntegerPool.create();
            ip.add(0, 5);
            if (UnitCanUse(source, SID_FAST_HEAL)) {
                ip.add(SID_FAST_HEAL, 100);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else {
                IssueTargetOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, MobList.getLowestHPPercent());
            }
            ip.destroy();
        }
    }

    Point slitherTargets[];
    integer slitherTargetsN;
    integer slitherCurrent;

    function makeOrderSlither(unit source, unit target, real combatTime) {
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
            if (GetUnitAbilityLevel(source, BID_Slug) == 0) {
                IssueImmediateOrderById(source, SpellData.inst(SID_SLUG, SCOPE_PREFIX).oid);
            } else {
                if (GetDistance.unitCoord2d(source, slitherTargets[slitherCurrent].x, slitherTargets[slitherCurrent].y) > 150) {
                    IssuePointOrderById(source, OID_MOVE, slitherTargets[slitherCurrent].x, slitherTargets[slitherCurrent].y);
                } else {
                    slitherCurrent = GetRandomInt(0, slitherTargetsN - 1);
                }
            }
        }
    }

    function makeOrderKoragg(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
            ip = IntegerPool.create();
            ip.add(0, 30);
            if (UnitCanUse(source, SID_COLD_GAZE)) {
                ip.add(SID_COLD_GAZE, 60);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else {
                IssueTargetOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, PlayerUnits.getRandomHero());
            }
            ip.destroy();
        }
    }

    function makeOrderWindSerpentServant(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
            ip = IntegerPool.create();
            ip.add(0, 30);
            if (UnitCanUse(source, SID_DIVE)) {
                ip.add(SID_DIVE, 60);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else {
                IssueImmediateOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid);
            }
            ip.destroy();
        }
    }

    function makeOrderGodOfDeath(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        integer accu, i;
        unit tu;
        if (GodOfDeathPlatform.setup == false) {
            GodOfDeathPlatform.start(source);
        }
        if (!IsUnitChanneling(source)) {
            ip = IntegerPool.create();
            if (GetUnitMana(source) > 999) {
                // wipe
                ip.add(SID_ANNIHILATION, 100);
            } else {
                ip.add(0, 30);
                if (UnitCanUse(source, SID_SUMMON_UNHOLY_TENTACLES)) {
                    ip.add(SID_SUMMON_UNHOLY_TENTACLES, 60);
                }
                if (UnitCanUse(source, SID_MIND_BLAST) && combatTime > 5) {
                    ip.add(SID_MIND_BLAST, 60);
                }
                if (UnitCanUse(source, SID_TELEPORT_PLAYERS) && combatTime > 10) {
                    ip.add(SID_TELEPORT_PLAYERS, 60);
                }
                // 3 kinds of tentacles
                if (GodOfDeathPlatform.rootOfFilth == null) {
                    if (UnitCanUse(source, SID_PSYCHIC_LINK)) {
                        ip.add(SID_PSYCHIC_LINK, 60);
                    }
                } else {
                    if (UnitCanUse(source, SID_SUMMON_FILTHY_TENTACLE)) {
                        ip.add(SID_SUMMON_FILTHY_TENTACLE, 60);
                    }
                }
                if (GodOfDeathPlatform.rootOfViciousness == null) {
                    if (UnitCanUse(source, SID_EYE_BEAM)) {
                        ip.add(SID_EYE_BEAM, 60);
                    }
                } else {
                    if (UnitCanUse(source, SID_SUMMON_VICIOUS_TENTACLE)) {
                        ip.add(SID_SUMMON_VICIOUS_TENTACLE, 60);
                    }
                }
                if (GodOfDeathPlatform.rootOfFoulness == null) {
                    if (UnitCanUse(source, SID_LUNATIC_GAZE)) {
                        ip.add(SID_LUNATIC_GAZE, 60);
                    }
                } else {
                    if (UnitCanUse(source, SID_SUMMON_FOUL_TENTACLE)) {
                        ip.add(SID_SUMMON_FOUL_TENTACLE, 60);
                    }
                }
                // 30% hp
                if (GetUnitStatePercent(source, UNIT_STATE_LIFE, UNIT_STATE_MAX_LIFE) <= 30) {
                    if (UnitCanUse(source, SID_SUMMON_ETERNAL_GUARDIAN)) {
                        ip.add(SID_SUMMON_ETERNAL_GUARDIAN, 60);
                    }
                }
            }

            res = ip.get();
            if (res == 0) {
                // do nothing
            } else if (SpellData.inst(res, SCOPE_PREFIX).otp == ORDER_TYPE_IMMEDIATE) {
                IssueImmediateOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid);
            } else {
                // only possible ability is Mind Blast
                // find a player that not on the platform
                accu = 0;
                i = 0;
                tu = null;
                while (i < PlayerUnits.n) {
                    if (GodOfDeathPlatform.isUnitInPlatform(PlayerUnits.units[i]) == true) {
                        accu += 1;
                        if (GetRandomInt(1, accu) == 1) {
                            tu = PlayerUnits.units[i];
                        }
                    }
                    i += 1;
                }
                if (tu != null) {
                    IssuePointOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, GetUnitX(tu), GetUnitY(tu));
                }
            }
            ip.destroy();
        }
    }

    function makeOrderFelPeon(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
            ip = IntegerPool.create();
            ip.add(0, 30);
            if (UnitCanUse(source, SID_BLOOD_BOIL)) {
                ip.add(SID_BLOOD_BOIL, 50);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else {
                IssueImmediateOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid);
            }
            ip.destroy();
        }
    }

    function makeOrderLavaSpawn(unit source, unit target, real combatTime) {
        IntegerPool ip;
        integer res;
        unit tu;
        if (!IsUnitChanneling(source) && !UnitProp.inst(source, SCOPE_PREFIX).stunned) {
            ip = IntegerPool.create();
            ip.add(0, 30);
            if (UnitCanUse(source, SID_FIRE_SHIFT) && GetUnitStatePercent(source, UNIT_STATE_LIFE, UNIT_STATE_MAX_LIFE) >= FireShiftConsts.selfDamageRatio * 100) {
                ip.add(SID_FIRE_SHIFT, 30);
            }
            res = ip.get();
            if (res == 0) {
                IssueTargetOrderById(source, OID_ATTACK, target);
            } else {
                tu = PlayerUnits.getRandomHero();
                IssuePointOrderById(source, SpellData.inst(res, SCOPE_PREFIX).oid, GetUnitX(tu), GetUnitY(tu));
                tu = null;
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
    
    function registerUnitCallback() {
        unitCallBack['Ntin'] = makeOrderNtin;   // Arch Tinker
        unitCallBack['Nrob'] = makeOrderNrob;   // Arch Tinker Morph
        unitCallBack['nfac'] = makeOrdernfac;   // Pocket Factory
        unitCallBack[UTID_CLOCKWORK_GOBLIN] = makeOrderClockwerkGoblin;
        
        unitCallBack['Hvsh'] = makeOrderHvsh;   // Naga Sea Witch
        unitCallBack[UTID_FLYING_SERPENT] = makeOrderWindSerpentServant;
        
        unitCallBack[UTID_TIDE_BARON_WATER] = makeOrderTideBaronWater;   // Sir Tide Water form
        unitCallBack[UTID_TIDE_BARON] = makeOrderTideBaron;   // Sir Tide Naga form

        unitCallBack[UTID_WARLOCK] = makeOrderWarlock;   // Warlock
        unitCallBack[UTID_LAVA_SPAWN] = makeOrderLavaSpawn;

        unitCallBack[UTID_PIT_ARCHON] = makeOrderAbyssArchon;
        unitCallBack[UTID_SPIKE] = makeOrderDoNothing;
        unitCallBack[UTID_POISONOUS_CRAWLER] = makeOrderJustAttack;
        unitCallBack[UTID_ABOMINATION] = makeOrderJustAttack;
        unitCallBack[UTID_WRAITH] = makeOrderJustAttack;

        unitCallBack[UTID_FEL_GUARD] = makeOrderFelGuard;
        unitCallBack[UTID_FEL_DEFENDER] = makeOrderFelDefender;

        unitCallBack[UTID_HEX_LORD] = makeOrderHexLord;
        unitCallBack[UTID_LIGHTNING_TOTEM] = makeOrderDoNothing;
        unitCallBack[UTID_THURG] = makeOrderJustAttack;
        unitCallBack[UTID_GAZAKROTH] = makeOrderGazakroth;
        unitCallBack[UTID_LORD_RAADAN] = makeOrderLordRaadan;
        unitCallBack[UTID_DARKHEART] = makeOrderDarkheart;
        unitCallBack[UTID_ALYSON_ANTILLE] = makeOrderAlysonAntille;
        unitCallBack[UTID_SLITHER] = makeOrderSlither;
        unitCallBack[UTID_FENSTALKER] = makeOrderJustAttack;
        unitCallBack[UTID_KORAGG] = makeOrderKoragg;

        unitCallBack[UTID_GOD_OF_DEATH] = makeOrderGodOfDeath;
        
        // ============= Area 1, 2 ==================
        unitCallBack[UTID_NAGA_SIREN] = makeOrderNagaSiren;
        unitCallBack[UTID_NAGA_TIDE_PRIEST] = makeOrderNagaTidePriest;
        unitCallBack[UTID_NTR_HEALING_WARD] = makeOrderDoNothing;
        unitCallBack[UTID_NTR_PROTECTION_WARD] = makeOrderDoNothing;
        unitCallBack[UTID_NAGA_MYRMIDON] = makeOrderNagaMyrmidon;
        unitCallBack[UTID_CHMP_NAGA_MYRMIDON] = makeOrderNagaMyrmidon;
        unitCallBack[UTID_NAGA_ROYAL_GUARD] = makeOrderNagaRoyalGuard;
        unitCallBack[UTID_CHMP_NAGA_ROYAL_GUARD] = makeOrderNagaRoyalGuard;
        unitCallBack[UTID_SEA_LIZARD] = makeOrderJustAttack;
        unitCallBack[UTID_MURLOC_SLAVE] = makeOrderJustAttack;
        unitCallBack[UTID_WIND_SERPENT] = makeOrderWindSerpent;

        // ============= Area 3 ==================
        unitCallBack[UTID_FEL_PEON] = makeOrderFelPeon;
        unitCallBack[UTID_FEL_GRUNT] = makeOrderFelGrunt;
        unitCallBack[UTID_FEL_RIDER] = makeOrderFelRider;
        unitCallBack[UTID_FEL_WAR_BRINGER] = makeOrderFelWarBringer;
        unitCallBack[UTID_CHMP_FEL_WAR_BRINGER] = makeOrderFelWarBringer;
        unitCallBack[UTID_DEMONIC_WITCH] = makeOrderDemonicWitch;

        // ============= Area 4 ==================
        unitCallBack[UTID_NOXIOUS_SPIDER] = makeOrderNoxiousSpider;
        unitCallBack[UTID_PARASITICAL_ROACH] = makeOrderParasiticalRoach;
        unitCallBack[UTID_ZOMBIE] = makeOrderZombie;
        unitCallBack[UTID_SKELETAL_MAGE] = makeOrderSkeletalMage;
        unitCallBack[UTID_DRACOLICH] = makeOrderDracoLich;
        unitCallBack[UTID_CHMP_DRACOLICH] = makeOrderDracoLich;

        unitCallBack[UTID_OBSIDIAN_CONSTRUCT] = makeOrderObsidianConstruct;

        // ============= Area 5 ==================
        unitCallBack[UTID_VOID_WALKER] = makeOrderVoidWalker;
        unitCallBack[UTID_FEL_HOUND] = makeOrderFelHound;
        unitCallBack[UTID_MAID_OF_AGONY] = makeOrderMaidOfAgony;
        unitCallBack[UTID_NETHER_DRAKE] = makeOrderNetherDrake;
        unitCallBack[UTID_NETHER_HATCHLING] = makeOrderNetherHatchling;
        unitCallBack[UTID_INFERNO_CONSTRUCT] = makeOrderInfernoConstruct;
        unitCallBack[UTID_CHMP_INFERNO_CONSTRUCT] = makeOrderInfernoConstruct;

        // ============= Area 6 ==================
        unitCallBack[UTID_FOREST_TROLL] = makeOrderForestTroll;
        unitCallBack[UTID_CURSED_HUNTER] = makeOrderJustAttack;
        unitCallBack[UTID_DERANGED_PRIEST] = makeOrderDerangedPriest;
        unitCallBack[UTID_GARGANTUAN] = makeOrderGargantuan;
        unitCallBack[UTID_VOMIT_MAGGOT] = makeOrderJustAttack;
        unitCallBack[UTID_TWILIGHT_WITCH_DOCTOR] = makeOrderTwilightWitchDoctor;
        unitCallBack[UTID_GRIM_TOTEM] = makeOrderDoNothing;
        unitCallBack[UTID_FACELESS_ONE] = makeOrderFacelessOne;

        // dummies
        unitCallBack[UTID_STATIC_TARGET] = makeOrderDoNothing;
        unitCallBack[UTID_TANK_TESTER] = makeOrderJustAttack;
    }
    
    function onInit() {
        focus = HandleTable.create();
        pace = HandleTable.create();
        unitCallBack = Table.create();
        registerUnitCallback();

        BuffType.register(BID_PORTAL_INVULNERABLE, BUFF_PHYX, BUFF_POS);

        slitherTargets[0] = Point.new(252, 5378);
        slitherTargets[1] = Point.new(868, 5378);
        slitherTargets[2] = Point.new(-260, 4792);
        slitherTargets[3] = Point.new(-206, 4103);
        slitherTargets[4] = Point.new(1298, 4820);
        slitherTargets[5] = Point.new(1159, 4110);
        slitherTargets[6] = Point.new(242, 3618);
        slitherTargets[7] = Point.new(932, 3647);
        slitherTargetsN = 8;
        slitherCurrent = 0;
    }
}
//! endzinc
