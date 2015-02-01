//! zinc
library InfoBoards requires Board, ModelInfo, NefUnion, ZAMCore, BuffSystem, AggroSystem, DamageSystem, SpellEvent, Clock {
    public unit playerSelection[NUMBER_OF_MAX_PLAYERS];

    //private Board dpsboards[10];
    private Board staboards[NUMBER_OF_MAX_PLAYERS];
    private Board buffboards[NUMBER_OF_MAX_PLAYERS];
    private Board aggroboards[NUMBER_OF_MAX_PLAYERS];
    private Board combatboards[NUMBER_OF_MAX_PLAYERS];
    private Board dpsall[NUMBER_OF_MAX_PLAYERS];
    private Board dps[NUMBER_OF_MAX_PLAYERS];
    private Board perspective[NUMBER_OF_MAX_PLAYERS];
    private trigger selectionTrigger, deselectionTrigger, escTrigger, nextPerspectiveTrigger;
    
#define MAX_DAMAGE_HEAL_TYPES 32

    struct UnitDps {
        private static HandleTable ht;
        static unit units[];
        static integer nunits = 0;
        unit u;
        string name[MAX_DAMAGE_HEAL_TYPES];
        StringTable dataStore;
        integer used;
        integer sum;
        
        string hname[MAX_DAMAGE_HEAL_TYPES];
        StringTable hdataStore;
        integer hused;
        integer hsum;
        
        static method operator[] (unit u) -> thistype {
            thistype this;
            if (!thistype.ht.exists(u)) {
                this = thistype.allocate();
                thistype.ht[u] = this;
                this.u = u;
                this.used = 0;
                this.dataStore = StringTable.create();
                this.sum = 0;
                this.hused = 0;
                this.hdataStore = StringTable.create();
                this.hsum = 0;
                
                thistype.units[thistype.nunits] = u;
                thistype.nunits += 1;
            } else {
                this = thistype.ht[u];
            }
            return this;
        }
        
        method damage(string name, integer amt) {
            if (!this.dataStore.exists(name)) {
                this.name[this.used] = name;
                this.used += 1;
                this.dataStore[name] = 0;
            }
            this.dataStore[name] += amt;
            this.sum += amt;
        }
        
        method heal(string name, integer amt) {
            if (!this.hdataStore.exists(name)) {
                this.hname[this.hused] = name;
                this.hused += 1;
                this.hdataStore[name] = 0;
            }
            this.hdataStore[name] += amt;
            this.hsum += amt;
        }
        
        method reset() {
            integer i = 0;
            while (i < this.used) {
                this.dataStore[this.name[i]] = 0;
                i += 1;
            }
            this.sum = 0;
            i = 0;
            while (i < this.hused) {
                this.hdataStore[this.hname[i]] = 0;
                i += 1;
            }
            this.hsum = 0;
        }
        
        static method resetAll() {
            integer i = 0;
            while (i < thistype.nunits) {
                thistype[thistype.units[i]].reset();
                i += 1;
            }
        }
    
        private static method onInit() {
            thistype.ht = HandleTable.create();
        }
    }
    
#undef MAX_DAMAGE_HEAL_TYPES
    
    private boolean combatState = false;
    private real timeStamp = 0.0;
    private real lastCombatDur = 1.0;
    
    function combatStateChanged() {
        combatState = !combatState;
        if (combatState) {
            timeStamp = GetGameTime();
            UnitDps.resetAll();
        } else {
            lastCombatDur = GetGameTime() - timeStamp;
        }
    }
    
    //private function PlayerDeselected() {
        //player p = GetTriggerPlayer();
        //integer id = GetPlayerId(p);
        //staboards[id].clear();
    //}

    private function PlayerSelected() {
        player p = GetTriggerPlayer();
        integer id = GetPlayerId(p);
        integer i;
        Buff buf;
        BoardItem bi;
        unit u = GetTriggerUnit();
        AggroList al;
        ModelInfo mi;
        real r0;
        UnitDps ud;
        real time;
        if (u != null && !IsUnitDummy(u)) {
            mi = ModelInfo.get(GetUnitTypeId(u), "ModelInfo: 136");
            //integer mainAtt;
            playerSelection[id] = u;
            //BJDebugMsg("Triggered!");
            //dpsboards[id].visible[p] = false;
            
            
            // sta boards
            bi = staboards[id][0][0];
            bi.setDisplay(true, true);
            bi.icon = mi.icon;
            bi.text = GetUnitName(u);
            
            bi = staboards[id][2][0];
            if (IsUnitType(u, UNIT_TYPE_HERO)) {
                bi.text = GetHeroProperName(u);
            }
            
            bi = staboards[id][0][1];
            bi.text = "Physics";
            bi = staboards[id][2][1];
            bi.text = "Spell";
            bi = staboards[id][4][1];
            bi.text = "Defence";
            bi = staboards[id][6][1];
            bi.text = "Misc";
            
            
            
            bi = staboards[id][0][2];
            bi.text = "AttackPower";
            bi = staboards[id][1][2];
            bi.text = I2S(UnitProp[u].APMin()) + " - " + I2S(UnitProp[u].APMax());            
            
            bi = staboards[id][0][3];
            bi.text = "AttackCrit";
            bi = staboards[id][1][3];
            bi.text = R2S(UnitProp[u].AttackCrit() * 100) + "%";
            
            bi = staboards[id][0][4];
            bi.text = "AttackSpeed";
            bi = staboards[id][1][4];
            bi.text = I2S(UnitProp[u].AttackSpeed() + 100) + "%";
            
            bi = staboards[id][0][5];
            bi.text = "AttackRate";
            bi = staboards[id][1][5];
            bi.text = R2S(UnitProp[u].AttackRate() * 100) + "%";
            
            
            
            bi = staboards[id][2][2];
            bi.text = "SpellCrit";
            bi = staboards[id][3][2];
            bi.text = R2S(UnitProp[u].SpellCrit() * 100) + "%";
            
            bi = staboards[id][2][3];
            bi.text = "SpellHaste";
            bi = staboards[id][3][3];
            bi.text = R2S(UnitProp[u].SpellHaste() * 100) + "%";
            
            bi = staboards[id][2][4];
            bi.text = "SpellPower";
            bi = staboards[id][3][4];
            bi.text = R2S(UnitProp[u].SpellPower());
            
            
            
            bi = staboards[id][4][2];
            bi.text = "Armor";
            bi = staboards[id][5][2];
            bi.text = R2S(UnitProp[u].Armor());
            
            bi = staboards[id][4][3];
            bi.text = "Dodge";
            bi = staboards[id][5][3];
            bi.text = R2S(UnitProp[u].Dodge() * 100) + "%";
            
            bi = staboards[id][4][4];
            bi.text = "BlockRate";
            bi = staboards[id][5][4];
            bi.text = R2S(UnitProp[u].BlockRate() * 100) + "%";
            
            bi = staboards[id][4][5];
            bi.text = "BlockPoint";
            bi = staboards[id][5][5];
            bi.text = R2S(UnitProp[u].BlockPoint());
            
            bi = staboards[id][4][6];
            bi.text = "SpellTaken";
            bi = staboards[id][5][6];
            bi.text = R2S(UnitProp[u].SpellTaken() * 100) + "%";
            
            bi = staboards[id][4][7];
            bi.text = "DamageTaken";
            bi = staboards[id][5][7];
            bi.text = R2S(UnitProp[u].DamageTaken() * 100) + "%";
            
            bi = staboards[id][4][8];
            bi.text = "HealTaken";
            bi = staboards[id][5][8];
            bi.text = R2S(UnitProp[u].HealTaken() * 100) + "%";
            
            
            
            bi = staboards[id][6][2];
            bi.text = "SpellReflect";
            bi = staboards[id][7][2];
            bi.text = I2S(UnitProp[u].SpellReflect());
            
            bi = staboards[id][6][3];
            bi.text = "AggroRate";
            bi = staboards[id][7][3];
            bi.text = R2S(UnitProp[u].AggroRate() * 100) + "%";
            
            bi = staboards[id][6][4];
            bi.text = "Disabled";
            bi = staboards[id][7][4];
            bi.text = B2S(UnitProp[u].Disabled());
            
            bi = staboards[id][6][5];
            bi.text = "LifeRegen";
            bi = staboards[id][7][5];
            bi.text = R2S(UnitProp[u].LifeRegen());
            
            bi = staboards[id][6][6];
            bi.text = "ManaRegen";
            bi = staboards[id][7][6];
            bi.text = R2S(UnitProp[u].ManaRegen());
            
            bi = staboards[id][6][7];
            bi.text = "Speed";
            bi = staboards[id][7][7];
            bi.text = I2S(UnitProp[u].Speed());
            
            bi = staboards[id][6][8];
            bi.text = "DamageDealt";
            bi = staboards[id][7][8];
            bi.text = R2S(UnitProp[u].DamageDealt() * 100) + "%";
            
            // BUFF BOARDS
            buffboards[id].all.text = "";
            
            bi = buffboards[id][0][0];
            bi.setDisplay(true, true);
            bi.icon = mi.icon;
            bi.text = GetUnitName(u);
            
            bi = buffboards[id][2][0];
            if (IsUnitType(u, UNIT_TYPE_HERO)) {
                bi.text = GetHeroProperName(u);
            }
            
            bi = buffboards[id][0][1];
            bi.text = "bid:";
            bi = buffboards[id][0][2];
            bi.text = "buffCate:";
            bi = buffboards[id][0][3];
            bi.text = "buffPoly:";
            bi = buffboards[id][0][4];
            bi.text = "caster:";
            bi = buffboards[id][0][5];
            bi.text = "target:";
            bi = buffboards[id][0][6];
            bi.text = "isShield:";
            bi = buffboards[id][0][7];
            bi.text = "interval:";
            bi = buffboards[id][0][8];
            bi.text = "tick:";
            bi = buffboards[id][0][9];
            bi.text = "bor:";
            bi = buffboards[id][0][10];
            bi.text = "boe:";
            bi = buffboards[id][0][11];
            bi.text = "ints:";
            bi = buffboards[id][0][12];
            bi.text = "reals:";
            bi = buffboards[id][0][13];
            bi.text = "effs:";
            bi = buffboards[id][0][14];
            bi.text = "# BuffData:";
            bi = buffboards[id][0][15];
            bi.text = "# Buff:";
            bi = buffboards[id][1][14];
            bi.text = I2S(BuffData.instances);
            bi = buffboards[id][1][15];
            bi.text = I2S(Buff.instances);
            
            i = 1;
            buf = BuffSlot[u].top;
            while (buf != 0) {
                bi = buffboards[id][i][1];
                bi.text = ID2S(buf.bd.bt.bid);
                bi = buffboards[id][i][2];
                if (buf.bd.bt.buffCate == BUFF_PHYX) {
                    bi.text = "BUFF_PHYX";
                } else if (buf.bd.bt.buffCate == BUFF_MAGE) {
                    bi.text = "BUFF_MAGE";
                } else {
                    bi.text = "BUFF_CATE?";
                }
                bi = buffboards[id][i][3];
                if (buf.bd.bt.buffPoly == BUFF_POS) {
                    bi.text = "BUFF_POS";
                } else if (buf.bd.bt.buffPoly == BUFF_NEG) {
                    bi.text = "BUFF_NEG";
                } else {
                    bi.text = "BUFF_POLY?";
                }
                bi = buffboards[id][i][4];
                if (IsUnitType(buf.bd.caster, UNIT_TYPE_HERO)) {
                    bi.text = GetHeroProperName(buf.bd.caster);
                } else {
                    bi.text = GetUnitName(buf.bd.caster);
                }
                bi = buffboards[id][i][5];
                if (IsUnitType(buf.bd.target, UNIT_TYPE_HERO)) {
                    bi.text = GetHeroProperName(buf.bd.target);
                } else {
                    bi.text = GetUnitName(buf.bd.target);
                }
                bi = buffboards[id][i][6];
                bi.text = B2S(buf.bd.isShield);
                bi = buffboards[id][i][7];
                bi.text = R2S(buf.bd.interval);
                bi = buffboards[id][i][8];
                bi.text = I2S(buf.bd.tick);
                bi = buffboards[id][i][9];
                bi.text = I2S(buf.bd.bor);
                bi = buffboards[id][i][10];
                bi.text = I2S(buf.bd.boe);
                bi = buffboards[id][i][11];
                bi.text = "[" + I2S(buf.bd.i0) + "," + I2S(buf.bd.i1) + "," + I2S(buf.bd.i2) + "]";
                bi = buffboards[id][i][12];
                bi.text = "[" + I2S(Rounding(buf.bd.r0)) + "," + I2S(Rounding(buf.bd.r1)) + "," + I2S(Rounding(buf.bd.r2)) + "]";
                bi = buffboards[id][i][13];
                bi.text = "[" + I2S(buf.bd.e0) + "," + I2S(buf.bd.e1) + "]";
                buf = buf.next;
                i += 1;
            }
            
            
            // Aggro List Boards
            aggroboards[id].all.text = "";
            aggroboards[id].col[0].setDisplay(true, true);
            
            bi = aggroboards[id][0][0];
            bi.icon = mi.icon;
            if (IsUnitType(u, UNIT_TYPE_HERO)) {
                bi.text = GetHeroProperName(u);
            } else {
                bi.text = GetUnitName(u);
            }
            
            al = AggroList[u];
            if (al != 0) {
			//print(SCOPE_PREFIX+":392> Player unit error");
                al.sort();
                i = 0;
                while (i < al.aggrosN) {
                    bi = aggroboards[id][0][i + 1];
                    //print("I have an aggro list???");
					//if (al.aggros[i] == null) {
					//	print(SCOPE_PREFIX + ":398> Found error!");
					//} else {
					mi = ModelInfo.get(GetUnitTypeId(al.aggros[i]), "ModelInfo: 401");
					//}
                    bi.icon = mi.icon;
                    if (IsUnitType(al.aggros[i], UNIT_TYPE_HERO)) {
                        bi.text = GetHeroProperName(al.aggros[i]);
                    } else {
                        bi.text = GetUnitName(al.aggros[i]);
                    }
                    
                    bi = aggroboards[id][1][i + 1];
                    bi.text = R2S(al.aps[i]);
                    
                    bi = aggroboards[id][2][i + 1];
					// print("InfoBoards: 414> al.aps[0]=" + R2S(al.aps[0]));
                    bi.text = R2S(al.aps[i] / al.aps[0] * 100) + "%";
                    
                    i += 1;
                }                
            }
            
            // Unit dps board
            dps[id].all.text = "";
            if (combatState) {
                time = GetGameTime() - timeStamp;
            } else {
                time = lastCombatDur;
            }
            dps[id].title = "Dps Log (Unit) " + R2S(time);
            
            bi = dps[id][0][0];
            bi.setDisplay(true, true);
            bi.icon = mi.icon;
            bi.text = GetUnitNameEx(u);
            
            bi = dps[id][0][1];
            bi.text = "Name";
            bi = dps[id][1][1];
            bi.text = "Damage";
            bi = dps[id][2][1];
            bi.text = "Percentage";
            bi = dps[id][3][1];
            bi.text = "DPS";
            bi = dps[id][4][1];
            bi.text = "Name";
            bi = dps[id][5][1];
            bi.text = "Healing";
            bi = dps[id][6][1];
            bi.text = "Percentage";
            bi = dps[id][7][1];
            bi.text = "HPS";
            
            ud = UnitDps[u];   
            i = 0;
            while (i < ud.used) {
                bi = dps[id][0][i + 2];
                bi.text = ud.name[i];
                
                r0 = I2R(ud.dataStore[ud.name[i]]);
                
                bi = dps[id][1][i + 2];
                bi.text = I2S(Rounding(r0));
                
                bi = dps[id][2][i + 2];
				// print("InfoBoards: 464> ud.sum="+R2S(ud.sum));
				if (ud.sum < 0.01) {
					bi.text = "0.00%";
				} else {
					bi.text = R2S(r0 * 100 / ud.sum) + "%";
				}
                
                bi = dps[id][3][i + 2];
				// print("InfoBoards: 468> time="+R2S(time));
                bi.text = R2S(r0 / time);
                
                i += 1;
            }
            bi = dps[id][0][i + 2];
            bi.text = "Sum:";
            bi = dps[id][1][i + 2];
            bi.text = I2S(ud.sum);
            bi = dps[id][3][i + 2];
			// print("InfoBoards: 479> time="+R2S(time));
            bi.text = I2S(Rounding(I2R(ud.sum) / time));
            
            i = 0;
            while (i < ud.hused) {
                bi = dps[id][4][i + 2];
                bi.text = ud.hname[i];
                
                r0 = I2R(ud.hdataStore[ud.hname[i]]);
                
                bi = dps[id][5][i + 2];
                bi.text = I2S(Rounding(r0));
                
                bi = dps[id][6][i + 2];
				// print("InfoBoards: 492> ud.hsum="+R2S(ud.hsum));
				if (ud.hsum < 0.01) {
					bi.text = "0.00%";
				} else {
					bi.text = R2S(r0 * 100 / ud.hsum) + "%";
				}
                
                bi = dps[id][7][i + 2];
				// print("InfoBoards: 496> time="+R2S(time));
                bi.text = R2S(r0 / time);
                
                i += 1;
            }
            bi = dps[id][4][i + 2];
            bi.text = "Sum:";
            bi = dps[id][5][i + 2];
            bi.text = I2S(ud.hsum);
            bi = dps[id][7][i + 2];
			// print("InfoBoards: 507> time="+R2S(time));
            bi.text = I2S(Rounding(I2R(ud.hsum) / time));
        }        
        //staboards[id].visible[p] = true;
    }
    
#define COMBAT_LOG_MAX 20
    struct CombatLogRecord[21] {
        unit source, target;
        string message;
    }
    
    private string combatLogAll[];
    private integer combatLogAllIndex = 0;
    
    public function GenerateCombatLog(string namespace) {
        string filename = "D:\\WExport\\" + namespace + I2HEX(GetRandomInt(0, 0x7FFFFFFF)) + ".welog";
        integer i = 0;
        PreloadGenStart();
        Preload("[");
        while (i < combatLogAllIndex) {
            if (i < combatLogAllIndex - 1) {
                Preload(combatLogAll[i] + ", ");
            } else {
                Preload(combatLogAll[i]);
            }
            i += 1;
        }
        Preload("]");
        PreloadGenEnd(filename);
        PreloadGenClear();
        combatLogAllIndex = 0;
        filename = null;
    }
    
    unit manaRecordUnit;
    string manaRecordTimeStamp;
    real manaRecordAmount;
    real manaRecordAmountMax;
    
    // eventType: 1 damage, 2 heal, 3 cast
    function pushCombatLog(integer eventType) {
        BoardItem bi;
        integer i;
        i = COMBAT_LOG_MAX - 1;
        while (i > 0) {     
            CombatLogRecord[i].source = CombatLogRecord[i - 1].source;
            CombatLogRecord[i].target = CombatLogRecord[i - 1].target;
            CombatLogRecord[i].message = CombatLogRecord[i - 1].message;  
            //BJDebugMsg("Copy from " + I2S(i) + " to " + I2S(i-1));
            if (CombatLogRecord[i].target != null) {
                bi = combatboards[0][0][i];
                bi.icon = ModelInfo.get(GetUnitTypeId(CombatLogRecord[i].source), "InfoBoards: 551").icon;
                bi.text = GetUnitNameEx(CombatLogRecord[i].source);
                bi = combatboards[0][1][i];
                bi.icon = ModelInfo.get(GetUnitTypeId(CombatLogRecord[i].target), "InfoBoards: 554").icon;
                bi.text = GetUnitNameEx(CombatLogRecord[i].target);
                bi = combatboards[0][2][i];
                bi.text = CombatLogRecord[i].message;      
            }
            i -= 1;
        }
        CombatLogRecord[0].source = CombatLogRecord[COMBAT_LOG_MAX].source;
        CombatLogRecord[0].target = CombatLogRecord[COMBAT_LOG_MAX].target;
        CombatLogRecord[0].message = CombatLogRecord[COMBAT_LOG_MAX].message;
        bi = combatboards[0][0][0];        
        if (CombatLogRecord[0].source != null) {
            bi.icon = ModelInfo.get(GetUnitTypeId(CombatLogRecord[0].source), "InfoBoards: 566").icon;
        } else {
            bi.icon = "";
        }
        bi.text = GetUnitNameEx(CombatLogRecord[0].source);
        bi = combatboards[0][1][0];
        if (CombatLogRecord[0].target != null) {
            bi.icon = ModelInfo.get(GetUnitTypeId(CombatLogRecord[0].target), "InfoBoards: 573").icon;
        } else {
            bi.icon = "";
        }
        bi.text = GetUnitNameEx(CombatLogRecord[0].target);
        bi = combatboards[0][2][0];
        bi.text = CombatLogRecord[0].message;  
        
        if (eventType == 1) {
            combatLogAll[combatLogAllIndex] = "[\"damage\",\"" /*
                                          */ + R2S(GetGameTime()) + "\",\"" /*
                                          */ + GetUnitNameEx(DamageResult.source) + "\",\"" /*
                                          */ + GetUnitNameEx(DamageResult.target) + "\",\"" /*
                                          */ + DamageResult.abilityName + "\",\"" /*
                                          */ + R2S(DamageResult.amount) + "\",\"" /*
                                          */ + B2S(DamageResult.isHit) + "\",\"" /*
                                          */ + B2S(DamageResult.isBlocked) + "\",\"" /*
                                          */ + B2S(DamageResult.isDodged) + "\",\"" /*
                                          */ + B2S(DamageResult.isCritical) + "\",\"" /*
                                          */ + B2S(DamageResult.isImmune) + "\",\"" /*
                                          */ + B2S(DamageResult.isPhyx) + "\",\"" /*
                                          */ + B2S(DamageResult.wasDodgable) + "\",\"" /*
                                          */ + ModelInfo.get(GetUnitTypeId(DamageResult.source), "InfoBoards: 595").Career() + "\",\"" /*
                                          */ + ModelInfo.get(GetUnitTypeId(DamageResult.target), "InfoBoards: 596").Career() + "\"]";
        } else if (eventType == 2) {
            combatLogAll[combatLogAllIndex] = "[\"heal\",\"" /*
                                          */ + R2S(GetGameTime()) + "\",\"" /*
                                          */ + GetUnitNameEx(HealResult.source) + "\",\"" /*
                                          */ + GetUnitNameEx(HealResult.target) + "\",\"" /*
                                          */ + HealResult.abilityName + "\",\"" /*
                                          */ + R2S(HealResult.effective) + "\",\"" /*
                                          */ + R2S(HealResult.amount - HealResult.effective) + "\",\"" /*
                                          */ + B2S(HealResult.isCritical) + "\",\"" /*
                                          */ + ModelInfo.get(GetUnitTypeId(HealResult.source), "InfoBoards: 606").Career() + "\",\"" /*
                                          */ + ModelInfo.get(GetUnitTypeId(HealResult.target), "InfoBoards: 607").Career() + "\"]";
        } else if (eventType == 3) {
            combatLogAll[combatLogAllIndex] = "[\"cast\",\"" /*
                                          */ + R2S(GetGameTime()) + "\",\"" /*
                                          */ + GetUnitNameEx(SpellEvent.CastingUnit) + "\",\"" /*
                                          */ + GetUnitNameEx(SpellEvent.TargetUnit) + "\",\"" /*
                                          */ + SpellData[SpellEvent.AbilityId].name + "\"]";
        } else if (eventType == 4) {
            combatLogAll[combatLogAllIndex] = "[\"combat\",\"" + R2S(GetGameTime())+ "\"]";
        } else {
            combatLogAll[combatLogAllIndex] = "[\"mana\",\"" /*
                                          */ + manaRecordTimeStamp + "\",\"" /*
                                          */ + GetUnitNameEx(manaRecordUnit) + "\",\"" /*
                                          */ + R2S(manaRecordAmount) + "\",\"" /*
                                          */ + R2S(manaRecordAmountMax) + "\"]";
        }
        combatLogAllIndex += 1;
        if (combatLogAllIndex == 8000) {GenerateCombatLog("Auto");}//combatLogAllIndex = 0;}
    }
    
    function damagerecord() {
        CombatLogRecord[COMBAT_LOG_MAX].source = DamageResult.source;
        CombatLogRecord[COMBAT_LOG_MAX].target = DamageResult.target;
        CombatLogRecord[COMBAT_LOG_MAX].message = "使用 " + DamageResult.abilityName;
        if (DamageResult.isDodged) {
            CombatLogRecord[COMBAT_LOG_MAX].message += " 被躲闪";
        }
        if (!DamageResult.isHit) {
            CombatLogRecord[COMBAT_LOG_MAX].message += " 未命中";
        }
        if (DamageResult.isBlocked) {
            CombatLogRecord[COMBAT_LOG_MAX].message += " 被招架";
        }
        if (DamageResult.isImmune) {
            CombatLogRecord[COMBAT_LOG_MAX].message += " 被免疫";
        }
        if (DamageResult.amount > 0.0) {
            CombatLogRecord[COMBAT_LOG_MAX].message += " 造成 " + I2S(Rounding(DamageResult.amount)) + " 伤害";
        }
        if (DamageResult.isCritical) {
            CombatLogRecord[COMBAT_LOG_MAX].message += "(暴击)";
        }
        pushCombatLog(1);
    }
    
    function healedrecord() {
        CombatLogRecord[COMBAT_LOG_MAX].source = HealResult.source;
        CombatLogRecord[COMBAT_LOG_MAX].target = HealResult.target;
        CombatLogRecord[COMBAT_LOG_MAX].message = "使用 " + HealResult.abilityName;
        CombatLogRecord[COMBAT_LOG_MAX].message += " 治疗 ";
        CombatLogRecord[COMBAT_LOG_MAX].message += I2S(Rounding(HealResult.effective)) + " 点";
        if (HealResult.isCritical) {
            CombatLogRecord[COMBAT_LOG_MAX].message += "(极效)";
        }
        if (HealResult.amount > HealResult.effective) {
            CombatLogRecord[COMBAT_LOG_MAX].message += "," + I2S(Rounding(HealResult.amount - HealResult.effective)) + " 溢出";
        }
        pushCombatLog(2);
    }
    
    function castlog() {
        if (IsLastSpellSuccess(SpellEvent.CastingUnit)) {
            pushCombatLog(3);
        }
    }
    
    function combatStatusLog() {
        pushCombatLog(4);
    }

    function absorbRecord() {
    	HealResult.source = AbsorbResult.source;
	    HealResult.target = AbsorbResult.target;
	    HealResult.abilityName = AbsorbResult.abilityName;
	    HealResult.amount = AbsorbResult.amount;
	    HealResult.effective = AbsorbResult.amount;
	    HealResult.isCritical = false;
    	pushCombatLog(2);
    }
    
    function manaLog() {
        integer i;
        if (combatState) {
            manaRecordTimeStamp = R2S(GetGameTime());
            i = 0;
            while (i < PlayerUnits.n) {
                if (!IsUnitDead(PlayerUnits.units[i]) && IsUnitType(PlayerUnits.units[i], UNIT_TYPE_HERO)) {
                    manaRecordUnit = PlayerUnits.units[i];
                    manaRecordAmount = GetUnitState(manaRecordUnit, UNIT_STATE_MANA);
                    manaRecordAmountMax = GetUnitState(manaRecordUnit, UNIT_STATE_MAX_MANA);
                    pushCombatLog(5);   
                }
                i += 1;
            }
        }
    }
    
    //function PlayerPressRight() {
    //}
    
    function dphlog() {
        UnitDps[HealResult.source].heal(HealResult.abilityName, Rounding(HealResult.amount));
    }
    
    function dpslog() {
        UnitDps[DamageResult.source].damage(DamageResult.abilityName, Rounding(DamageResult.amount));
    }
    
    private function PlayerEsced() {
        player p = GetTriggerPlayer();
        integer id = GetPlayerId(p);
        if (perspective[id] == staboards[id]) {
            perspective[id] = buffboards[id];
            combatboards[id].visible[p] = false;
            staboards[id].visible[p] = false;
            aggroboards[id].visible[p] = false;
            dpsall[id].visible[p] = false;
            dps[id].visible[p] = false;
            buffboards[id].visible[p] = true;
        } else if (perspective[id] == buffboards[id]) {
            perspective[id] = aggroboards[id];
            combatboards[id].visible[p] = false;
            staboards[id].visible[p] = false;
            buffboards[id].visible[p] = false;
            dpsall[id].visible[p] = false;
            dps[id].visible[p] = false;
            aggroboards[id].visible[p] = true;
        } else if (perspective[id] == aggroboards[id]) {
            perspective[id] = combatboards[id];
            staboards[id].visible[p] = false;
            buffboards[id].visible[p] = false;
            aggroboards[id].visible[p] = false;
            dpsall[id].visible[p] = false;
            dps[id].visible[p] = false;
            combatboards[id].visible[p] = true;
        } else if (perspective[id] == combatboards[id]) {
            perspective[id] = dpsall[id];
            buffboards[id].visible[p] = false;
            aggroboards[id].visible[p] = false;
            combatboards[id].visible[p] = false;
            dps[id].visible[p] = false;
            staboards[id].visible[p] = false;
            dpsall[id].visible[p] = true;
        } else if (perspective[id] == dpsall[id]) {
            perspective[id] = dps[id];
            buffboards[id].visible[p] = false;
            aggroboards[id].visible[p] = false;
            combatboards[id].visible[p] = false;
            dpsall[id].visible[p] = false;
            staboards[id].visible[p] = false;
            dps[id].visible[p] = true;
        } else if (perspective[id] == dps[id]) {
            perspective[id] = staboards[id];
            buffboards[id].visible[p] = false;
            aggroboards[id].visible[p] = false;
            combatboards[id].visible[p] = false;
            dpsall[id].visible[p] = false;
            dps[id].visible[p] = false;
            staboards[id].visible[p] = true;
        }
        p = null;
    }
    
    private function onInit() {
        selectionTrigger = CreateTrigger();
        //deselectionTrigger = CreateTrigger();
        //nextPerspectiveTrigger = CreateTrigger();
        escTrigger = CreateTrigger();
        TimerStart(CreateTimer(), 0.3, false, function() {
            integer i = 0;
            DestroyTimer(GetExpiredTimer());
            while (i < NUMBER_OF_MAX_PLAYERS) {
                if (IsPlayerUserOnline(Player(i))) {
                    TriggerRegisterPlayerUnitEvent(selectionTrigger, Player(i), EVENT_PLAYER_UNIT_SELECTED, null);
                    //TriggerRegisterPlayerUnitEvent(deselectionTrigger, Player(i), EVENT_PLAYER_UNIT_DESELECTED, null);
                    //TriggerRegisterPlayerKeyEventBJ(nextPerspectiveTrigger, Player(i), bj_KEYEVENTTYPE_DEPRESS, bj_KEYEVENTKEY_RIGHT);
                    TriggerRegisterPlayerEvent(escTrigger, Player(i), EVENT_PLAYER_END_CINEMATIC);
                    staboards[i] = Board.create();
                    staboards[i].visible = true;
                    staboards[i].title = "Unit Properties";
                    staboards[i].all.width = 0.05;
                    //
                    //dpsboards[i] = Board.create();
                    //dpsboards[i].visible = false;
                    
                    buffboards[i] = Board.create();
                    buffboards[i].visible = false;
                    buffboards[i].title = "Unit Buff";
                    buffboards[i].all.width = 0.08;
                    
                    aggroboards[i] = Board.create();
                    aggroboards[i].visible = false;
                    aggroboards[i].title = "Aggro List";
                    aggroboards[i].all.width = 0.08;
                    
                    combatboards[i] = Board.create();
                    combatboards[i].visible = false;
                    combatboards[i].title = "Combat Log";
                    combatboards[i].col.count = 3;
                    combatboards[i].row.count = COMBAT_LOG_MAX - 1;
                    combatboards[i].col[0].setDisplay(true, true);
                    combatboards[i].col[1].setDisplay(true, true);
                    combatboards[i].col[0].width = 0.06;
                    combatboards[i].col[1].width = 0.06;
                    combatboards[i].col[2].width = 0.17;
                    
                    dpsall[i] = Board.create();
                    dpsall[i].visible = false;
                    dpsall[i].title = "Dps Log (All)";
                    dpsall[i].all.width = 0.08;
                    
                    dps[i] = Board.create();
                    dps[i].visible = false;
                    dps[i].title = "Dps Log (Unit)";
                    dps[i].all.width = 0.08;
                    
                    perspective[i] = staboards[i];
                }
                i += 1;
            }
            i = 0;
            while (i < COMBAT_LOG_MAX) {
                CombatLogRecord[i].source = null;
                CombatLogRecord[i].target = null;
                CombatLogRecord[i].message = "";
                i += 1;
            }
            // Skada
            RegisterHealedEvent(healedrecord);
            RegisterDamagedEvent(damagerecord);            
            RegisterAbsorbedEvent(absorbRecord);
            RegisterCombatStateNotify(combatStatusLog);
            RegisterSpellEndCastResponse(0, castlog);
            TimerStart(CreateTimer(), 1.0, true, function manaLog);
            
            // Normal multiboard
            RegisterHealedEvent(dphlog);
            RegisterDamagedEvent(dpslog);
            RegisterCombatStateNotify(combatStateChanged);
            
        });
        TriggerAddAction(selectionTrigger, function PlayerSelected);
        //TriggerAddAction(deselectionTrigger, function PlayerDeselected);
        //TriggerAddAction(nextPerspectiveTrigger, function PlayerPressRight);
        TriggerAddAction(escTrigger, function PlayerEsced);
    }
}
#undef COMBAT_LOG_MAX
//! endzinc

/*    
    private function GetController(player p) -> string {
        if (GetPlayerController(p) == MAP_CONTROL_CREEP) {return "Creep";}
        else if (GetPlayerController(p) == MAP_CONTROL_NEUTRAL) {return "Neutral";}
        else if (GetPlayerController(p) == MAP_CONTROL_RESCUABLE) {return "Rescuable";}
        else if (GetPlayerController(p) == MAP_CONTROL_COMPUTER) {return "Computer";}
        else if (GetPlayerController(p) == MAP_CONTROL_USER) {return "User";}
        else if (GetPlayerController(p) == MAP_CONTROL_NONE) {return "None";}
        else {return "N/A";}
    }
    
    private function GetSlotState(player p) -> string {
        if (GetPlayerSlotState(p) == PLAYER_SLOT_STATE_EMPTY) {return "Empty";}
        else if (GetPlayerSlotState(p) == PLAYER_SLOT_STATE_PLAYING) {return "Playing";}
        else if (GetPlayerSlotState(p) == PLAYER_SLOT_STATE_LEFT) {return "Left";}
        else {return "N/A";}
    }

    private function onInit() {
        TimerStart(NewTimer(), 0.3, false, function() {
            BoardItem bi;
            integer i = 0;
            ReleaseTimer(GetExpiredTimer());
            boards[0] = Board.create();
            boards[0].visible = true;
            boards[0].all.width = 0.05;
            boards[0].minimized = false;
            while (i < 16) {
                bi = boards[0][0][i];
                bi.text = "Player " + I2S(i);
                i += 1;
            }
            i = 0;
            while (i < 16) {
                bi = boards[0][1][i];
                bi.text = GetController(Player(i));
                i += 1;
            }
            i = 0;
            while (i < 16) {
                bi = boards[0][2][i];
                bi.text = GetSlotState(Player(i));
                i += 1;
            }
        });
    }
*/
