//! zinc
library UnitProperty requires ModelInfo, ZAMCore {
    
/* * * * * * * * Variable Attributes * */
    //! textmacro WriteUnitPropMod takes ABBR, VAR, START, END, NSTART, NEND
    private constant integer POS_$ABBR$_START = '$START$';
    private constant integer POS_$ABBR$_END = '$END$';
    private constant integer NEG_$ABBR$_START = '$NSTART$';
    private constant integer NEG_$ABBR$_END = '$NEND$';
    
    public function ModUnit$ABBR$(unit u, integer amount) {
        UnitProp up;
        integer tmp = 0;
        if (amount == 0) {return;}
        up = UnitProp[u];
        up.$VAR$ += amount;
        amount = up.$VAR$;
        //BJDebugMsg("$VAR$ of " + GetUnitName(u) +" is set to " + I2S(amount));
        
        if (amount == 0) {
            tmp = NEG_$ABBR$_START;
            while (tmp <= NEG_$ABBR$_END) {
                UnitRemoveAbility(u, tmp);
                tmp += 1;
            }
            tmp = POS_$ABBR$_START;
            while (tmp <= POS_$ABBR$_END) {
                UnitRemoveAbility(u, tmp);
                tmp += 1;
            }
        } else if (amount > 0) {
            tmp = NEG_$ABBR$_START;
            while (tmp <= NEG_$ABBR$_END) {
                UnitRemoveAbility(u, tmp);
                tmp += 1;
            }
            tmp = POS_$ABBR$_START;
            if (tmp <= POS_$ABBR$_END) {
                while (amount > 0) {
                    if (ModuloInteger(amount, 2) == 1) {
                        UnitAddAbility(u, tmp); 
                        UnitMakeAbilityPermanent(u, true, tmp);
                    } else {
                        UnitRemoveAbility(u, tmp);
                    } 
                    amount /= 2; 
                    tmp += 1;
                }
                while (tmp <= POS_$ABBR$_END) {
                    UnitRemoveAbility(u, tmp);
                    tmp += 1;
                }
            }
        } else {
            amount = 0 - amount;
            tmp = POS_$ABBR$_START;
            while (tmp <= POS_$ABBR$_END) {
                UnitRemoveAbility(u, tmp);
                tmp += 1;
            }
            tmp = NEG_$ABBR$_START;
            if (tmp <= NEG_$ABBR$_END) {
                while (amount > 0) {
                    if (ModuloInteger(amount, 2) == 1) {
                        UnitAddAbility(u, tmp); 
                        UnitMakeAbilityPermanent(u, true, tmp);
                    } else {
                        UnitRemoveAbility(u, tmp);
                    } 
                    amount /= 2; 
                    tmp += 1;
                }
                while (tmp <= NEG_$ABBR$_END) {
                    UnitRemoveAbility(u, tmp);
                    tmp += 1;
                }
            }
        }
    }
    //! endtextmacro
    
    //! runtextmacro WriteUnitPropMod("AP", "attackPower", "ADP0", "ADP<", "ADM0", "ADM9")
    //! runtextmacro WriteUnitPropMod("Life", "life", "AHP0", "AHPD", "1", "0")
    //! runtextmacro WriteUnitPropMod("MaxMana", "mana", "ALT0", "ALT@", "1", "0")
    //! runtextmacro WriteUnitPropMod("Armor", "armor", "ARM0", "ARM6", "AMP0", "AMP6")
    //! runtextmacro WriteUnitPropMod("AttackSpeed", "attackSpeed", "AHS0", "AHS7", "AHZ0", "AHZ7")
    //! runtextmacro WriteUnitPropMod("Str", "str", "ASR0", "ASR7", "1", "0")
    //! runtextmacro WriteUnitPropMod("Agi", "agi", "AAG0", "AAG7", "1", "0")
    //! runtextmacro WriteUnitPropMod("Int", "int", "AWZ0", "AWZ7", "1", "0")
    // runtextmacro WriteUnitPropMod("Speed", "speed", "AYS0", "AYS8", "AJS0", "AJS8")
/* * * * * * * * Variable Attributes * */
    
    public struct UnitProp {
        static HandleTable ht;   
        timer tm;
        unit u;
        real blockRate;         // 0 ~ 0.75; 1 str = 0.002 block
        real blockPoint;        // 1 str = 1 block
        real dodge;             // 0 ~ 0.75; 1 agi = 0.004 dodge
        integer spellReflect;   // ?
        real aggroRate;         // 0 ~ +oo
        integer armor;          // 0 ~ 75; 1 agi = 0.333 armor
        real spellTaken;        // 0 ~ +oo
        real damageTaken;       // 0 ~ +oo
        real healTaken;         // 0 ~ +oo
        //real absorb;            // deprecated 
        //real bleedTaken;        // deprecated
        //real critTaken;         // deprecated
        
        integer life;
        integer mana;
        real lifeRegen;         // 
        real manaRegen;         // 0 ~ +oo; 1 int = 0.03 regen
        integer str, agi, int;
        
        real attackCrit;        // 0 ~ 1.0; 1 agi = 0.0025 critic
        real spellPower;
        real spellCrit;         // 0 ~ 1.0; 1 int = 0.003 critic
        integer attackSpeed;    // -oo ~ +oo
        real spellHaste;        // 0 ~ +oo; 1 int = 0.002 haste
        integer attackPower;    // 0 ~ +oo; main attribute
        integer speed;
        real damageDealt;       // 0 ~ +oo
        real attackRate;        // 0.25 ~ 1.00
        
        boolean stunned;        
        integer disabled; // stunned or spellcountered
        boolean silent; // deprecated
        //boolean responsive;
        
        real damageGoesMana;
        real ll, ml;
        
        method BlockRate() -> real {
            real ret = this.blockRate + I2R(GetHeroStr(this.u, true)) * 0.002;
            if (ret > 0.75) {
                ret = 0.75;
            }
            if (!CanUnitBlock(this.u)) {
                ret = 0.0;
            }
            return ret;
        }
        
        method BlockPoint() -> real {
            return this.blockPoint + I2R(GetHeroStr(this.u, true));
        }
        
        method Dodge() -> real {
            real ret = this.dodge + I2R(GetHeroAgi(this.u, true)) * 0.002;
            if (ret > 0.75) {
                ret = 0.75;
            }
            return ret;
        }
        
        method SpellReflect() -> integer {
            return this.spellReflect;
        }
        
        method ModSpellReflect(integer mod) {
            this.spellReflect += mod;
            if (this.spellReflect < 0) {
                this.spellReflect = 0;
            }
        }
        
        method AggroRate() -> real {
            real ret = this.aggroRate;
            if (ret < 0.0) {
                ret = 0.0;
            }
            return ret;
        }
        
        method Armor() -> real {
            real ret = I2R(this.armor) + ModelInfo.get(GetUnitTypeId(this.u), "UnitProperty: 177").armor;
            if (ret > 75.0) {
                ret = 75.0;
            }
            return ret;
        }
        
        method ModArmor(integer m) {
            ModUnitArmor(this.u, m);
        }
        
        method ModInt(integer m) {
            ModUnitInt(this.u, m);
        }
        
        method ModAgi(integer m) {
            ModUnitAgi(this.u, m);
        }
        
        method ModStr(integer m) {
            ModUnitStr(this.u, m);
        }
        
        method SpellTaken() -> real {
            real ret = this.spellTaken;
            if (ret < 0.0) {
                ret = 0.0;
            }
            return ret;
        }
        
        method DamageTaken() -> real {
            real ret = this.damageTaken;
            if (ret < 0.0) {
                ret = 0.0;
            }
            return ret;
        }
        
        method HealTaken() -> real {
            real ret = this.healTaken;
            if (ret < 0.0) {
                ret = 0.0;
            }
            return ret;
        }       
        
        method Disabled() -> boolean {
            return this.disabled > 0;
        }
        
        method Stunned() -> boolean {
            return this.stunned;
        }
        
        // 1 int = 10 mp, 1 mp = 10 secs, thus 100 secs = 1 full mana slot
        // 0.1 = 100% / 10
        method ManaRegen() -> real {
            real ret = this.manaRegen + I2R(GetHeroInt(this.u, true)) * 0.03;
            if (ModelInfo.get(GetUnitTypeId(this.u), "UnitProperty: 236").mainAttribute == ATT_INT) {
                ret += 6.5;
            } else {
                ret *= 0.25;
            }
            return ret;
        }
        
        method AttackCrit() -> real {
            real ret = this.attackCrit + I2R(GetHeroAgi(this.u, true)) * 0.001;
            if (ret > 1.0) {
                ret = 1.0;
            }
            return ret;
        }
        
        method SpellCrit() -> real {
            real ret = this.spellCrit + I2R(GetHeroInt(this.u, true)) * 0.0015;
            if (ret > 1.0) {
                ret = 1.0;
            }
            return ret;
        }
        
        method AttackSpeed() -> integer {
            return this.attackSpeed;
        }
        
        method ModAttackSpeed(integer mod) {
            ModUnitAttackSpeed(this.u, mod);
        }
        
        method SpellHaste() -> real {
            return this.spellHaste + I2R(GetHeroInt(this.u, true)) * 0.001;
        }
    
        method AttackPower() -> real {
            ModelInfo mi;
            real ret;
            //print(GetUnitNameEx(this.u));
            mi = ModelInfo.get(GetUnitTypeId(this.u), "UnitProperty: 276");
            ret = I2R(this.attackPower + mi.ap + GetRandomInt(0, mi.apr));
            if (mi.mainAttribute == ATT_STR) {
                ret += GetHeroStr(this.u, true);
            } else if (mi.mainAttribute == ATT_AGI) {
                ret += GetHeroAgi(this.u, true);
            } else if (mi.mainAttribute == ATT_INT) {
                ret += GetHeroInt(this.u, true);
            }
            return ret;
        }
    
        method APMin() -> integer {
            ModelInfo mi = ModelInfo.get(GetUnitTypeId(this.u), "UnitProperty: 289");
            integer ret = this.attackPower + mi.ap;
            if (mi.mainAttribute == ATT_STR) {
                ret += GetHeroStr(this.u, true);
            } else if (mi.mainAttribute == ATT_AGI) {
                ret += GetHeroAgi(this.u, true);
            } else if (mi.mainAttribute == ATT_INT) {
                ret += GetHeroInt(this.u, true);
            }
            return ret;
        }
    
        method APMax() -> integer {
            return this.APMin() + ModelInfo.get(GetUnitTypeId(this.u), "UnitProperty: 302").apr;
        }
        
        method ModAP(integer num) {
            ModUnitAP(this.u, num);
        }
        
        method SpellPower() -> real {
            return I2R(GetHeroInt(this.u, true)) + this.spellPower;
        }
        
        method Speed() -> integer {
            return Rounding(GetUnitMoveSpeed(this.u));
        }
        
        method ModLife(integer m) {
            ModUnitLife(this.u, m);
        }
        
        method ModMana(integer m) {
            ModUnitMaxMana(this.u, m);
        }
        
        method ModSpeed(integer mod) {
            integer spd;
            this.speed += mod;
            spd = this.speed;
            if (spd > 522) {spd = 522;}
            if (spd < 0) {spd = 0;}
            SetUnitMoveSpeed(this.u, spd);
        }
        
        method DamageDealt() -> real {
            real ret = this.damageDealt;
            if (ret < 0.0) {
                ret = 0.0;
            }
            return ret;
        }
        
        method DamageGoesMana() -> real {
            real ret = this.damageGoesMana;
            if (ret < 0.0) {
                ret = 0.0;
            }
            return ret;
        }
        
        method AttackRate() -> real {
            real ret = this.attackRate;
            if (ret < 0.25) {
                ret = 0.25;
            }
            if (ret > 1.0) {
                ret = 1.0;
            }
            return ret;
        }
        
        method getDropValue() -> integer {
            return R2I(GetUnitState(this.u, UNIT_STATE_MAX_LIFE) + GetUnitState(this.u, UNIT_STATE_MAX_MANA));
        }
        
        //static method BleedTaken(unit u) -> real {return UnitProp[u].bleedTaken;}
        //static method CritTaken(unit u) -> real {return UnitProp[u].critTaken;}
        method LifeRegen() -> real {
            return this.lifeRegen;
        }
        
        static method operator[] (unit u) -> thistype {
            if (!thistype.ht.exists(u)) {
                BJDebugMsg(SCOPE_PREFIX+">Unregistered unit: " + GetUnitName(u));
                return 0;
            } else {
                return thistype.ht[u];
            }
        }
        
        static method doFlush() {
            thistype this = GetTimerData(GetExpiredTimer());
            ReleaseTimer(this.tm);
            //BJDebugMsg("Then flush");
            thistype.ht.flush(this.u);
            this.u = null;
            this.tm = null;
            this.deallocate();
        }
        
        method delayedFlush() {
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            TimerStart(this.tm, 30.0, false, function thistype.doFlush);
        }
        
        private static method recycle(unit u) {
            thistype this;
            if (!IsUnitType(u, UNIT_TYPE_HERO) && !IsUnitDummy(u)) {
                if (thistype.ht.exists(u)) {
                    this = thistype.ht[u];
                    this.delayedFlush();
                } else {
                    BJDebugMsg(SCOPE_PREFIX+">Unknown unit: " + GetUnitName(u));
                }
            }
        } 
        
        static method create() -> thistype {return thistype.allocate();}
        
        private static method onInit() {
            thistype.ht = HandleTable.create();
            RegisterUnitDeath(thistype.recycle);
        }
    } 
    
    function register(unit u) {
        UnitProp up;
        ModelInfo mi;
        if (UnitProp.ht.exists(u)) {
            //BJDebugMsg(SCOPE_PREFIX+">Double registering: " + GetUnitName(u));
        } else if (!IsUnitDummy(u)) {
            up = UnitProp.create();
            UnitProp.ht[u] = up;
            mi = ModelInfo.get(GetUnitTypeId(u), "UnitProperty: 424");
            
            up.u = u;
            
            up.blockRate = mi.blockRate;
            up.blockPoint = mi.blockPoint;
            up.dodge = mi.dodge;
            up.spellReflect = 0;
            up.aggroRate = 1.0;
            up.armor = 0;
            up.spellTaken = mi.mdef;
            up.damageTaken = 1.0;
            up.healTaken = 1.0;
            
            up.life = 0;     
            up.mana = 0;               
            up.manaRegen = 0.0;
            up.str = 0;
            up.agi = 0;
            up.int = 0;
            
            up.attackCrit = mi.attackCrit;
            up.spellPower = 0.0;
            up.spellCrit = 0.0;
            up.attackSpeed = 0;
            up.spellHaste = 0.0;
            up.attackPower = 0;
            up.speed = Rounding(GetUnitMoveSpeed(u));
            up.damageDealt = 1.0;
            up.attackRate = 1.0;
            
            up.stunned = false;
            up.disabled = 0;
            up.silent = false;
            //up.responsive = true;
            
            up.damageGoesMana = 0.0;
            up.ll = 0.0;
            up.ml = 0.0;
             
            up.lifeRegen = 0.0;
            //up.critTaken = 0.0;
            //up.absorb = 0.0;
            //up.bleedTaken = 1.0;
            
            ModUnitLife(u, mi.life);
        }
        u = null;
    }
	
	public function RegisterUnitProperty(unit u) {
		register(u);
	}
    
    private function onInit() {
        RegisterUnitEnterMap(register);
    }
}
//! endzinc
