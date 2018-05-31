//! zinc
library UnitProperty requires ModelInfo, ZAMCore {
    
    //! textmacro WriteUnitPropMod takes ABBR, VAR
    integer POS_$ABBR$_ARR[];
    integer NEG_$ABBR$;
    integer NUM_$ABBR$;
    integer CAP_$ABBR$;
    
    public function ModUnit$ABBR$(unit u, integer amount) {
        UnitProp up;
        integer i = 0;
        if (amount == 0) {return;}
        up = UnitProp.inst(u, SCOPE_PREFIX);
        up.$VAR$ += amount;
        amount = up.$VAR$;
        // logi("$VAR$ of " + GetUnitNameEx(u) +" is set to " + I2S(amount));

        // validation
        if (amount < 0) {
            if (NEG_$ABBR$ == 0) {
                amount = 0;
            }
            if (amount < 0 - CAP_$ABBR$) {
                amount = 0 - CAP_$ABBR$;
            }
        }
        if (amount >= CAP_$ABBR$) {
            amount = CAP_$ABBR$ - 1;
        }
        
        if (amount == 0) {
            if (NEG_$ABBR$ != 0 && GetUnitAbilityLevel(u, NEG_$ABBR$) > 0) {
                UnitRemoveAbility(u, NEG_$ABBR$);
            }
            i = 0;
            while (i <= NUM_$ABBR$) {
                if (GetUnitAbilityLevel(u, POS_$ABBR$_ARR[i]) > 0) {
                    UnitRemoveAbility(u, POS_$ABBR$_ARR[i]);
                }
                i += 1;
            }
        } else {
            if (amount < 0) {
                amount += CAP_$ABBR$;
                if (NEG_$ABBR$ != 0 && GetUnitAbilityLevel(u, NEG_$ABBR$) == 0) {
                    UnitAddAbility(u, NEG_$ABBR$);
                    UnitMakeAbilityPermanent(u, true, NEG_$ABBR$);
                }
            } else {
                if (NEG_$ABBR$ != 0 && GetUnitAbilityLevel(u, NEG_$ABBR$) > 0) {
                    UnitRemoveAbility(u, NEG_$ABBR$);
                }
            }
            i = 0;
            while (amount > 0) {
                if (ModuloInteger(amount, 2) == 1) {
                    if (GetUnitAbilityLevel(u, POS_$ABBR$_ARR[i]) == 0) {
                        UnitAddAbility(u, POS_$ABBR$_ARR[i]);
                        UnitMakeAbilityPermanent(u, true, POS_$ABBR$_ARR[i]);
                    }
                } else {
                    if (GetUnitAbilityLevel(u, POS_$ABBR$_ARR[i]) > 0) {
                        UnitRemoveAbility(u, POS_$ABBR$_ARR[i]);
                    }
                } 
                amount /= 2; 
                i += 1;
            }
            while (i < NUM_$ABBR$) {
                if (GetUnitAbilityLevel(u, POS_$ABBR$_ARR[i]) > 0) {
                    UnitRemoveAbility(u, POS_$ABBR$_ARR[i]);
                }
                i += 1;
            }
        }
    }
    //! endtextmacro
    
    //! runtextmacro WriteUnitPropMod("AP", "attackPower")
    //! runtextmacro WriteUnitPropMod("Life", "life")
    //! runtextmacro WriteUnitPropMod("MaxMana", "mana")
    //! runtextmacro WriteUnitPropMod("Armor", "armor")
    //! runtextmacro WriteUnitPropMod("AttackSpeed", "attackSpeed")
    //! runtextmacro WriteUnitPropMod("Str", "str")
    //! runtextmacro WriteUnitPropMod("Agi", "agi")
    //! runtextmacro WriteUnitPropMod("Int", "int")
    // runtextmacro WriteUnitPropMod("Speed", "speed")
    
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

        method disable() {
            this.disabled += 1;
        }

        method enable() {
            this.disabled -= 1;   
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
        
        //static method BleedTaken(unit u) -> real {return UnitProp.inst(u, SCOPE_PREFIX).bleedTaken;}
        //static method CritTaken(unit u) -> real {return UnitProp.inst(u, SCOPE_PREFIX).critTaken;}
        method LifeRegen() -> real {
            return this.lifeRegen;
        }
        
        static method inst(unit u, string trace) -> thistype {
            if (!thistype.ht.exists(u)) {
                print(SCOPE_PREFIX+" Unregistered unit: " + GetUnitName(u) + " trace " + trace);
                return 0/0;
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
                    print(SCOPE_PREFIX+">Unknown unit: " + GetUnitName(u));
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
        } else if (!IsUnitDummy(u) || GetUnitTypeId(u) == UTID_DAMAGE_DUMMY) {
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

        POS_AP_ARR[0] = 'ADP0';
        POS_AP_ARR[1] = 'ADP1';
        POS_AP_ARR[2] = 'ADP2';
        POS_AP_ARR[3] = 'ADP3';
        POS_AP_ARR[4] = 'ADP4';
        POS_AP_ARR[5] = 'ADP5';
        POS_AP_ARR[6] = 'ADP6';
        POS_AP_ARR[7] = 'ADP7';
        POS_AP_ARR[8] = 'ADP8';
        POS_AP_ARR[9] = 'ADP9';
        POS_AP_ARR[10] = 'ADP:';
        POS_AP_ARR[11] = 'ADP;';
        POS_AP_ARR[12] = 'ADP<';
        NEG_AP = 'ADM0';
        NUM_AP = 13;
        CAP_AP = 8192;

        POS_Life_ARR[0] = 'AHP0';
        POS_Life_ARR[1] = 'AHP1';
        POS_Life_ARR[2] = 'AHP2';
        POS_Life_ARR[3] = 'AHP3';
        POS_Life_ARR[4] = 'AHP4';
        POS_Life_ARR[5] = 'AHP5';
        POS_Life_ARR[6] = 'AHP6';
        POS_Life_ARR[7] = 'AHP7';
        POS_Life_ARR[8] = 'AHP8';
        POS_Life_ARR[9] = 'AHP9';
        POS_Life_ARR[10] = 'AHP:';
        POS_Life_ARR[11] = 'AHP;';
        POS_Life_ARR[12] = 'AHP<';
        POS_Life_ARR[13] = 'AHP=';
        POS_Life_ARR[14] = 'AHP>';
        POS_Life_ARR[15] = 'AHP?';
        POS_Life_ARR[16] = 'AHP@';
        POS_Life_ARR[17] = 'AHPA';
        POS_Life_ARR[18] = 'AHPB';
        POS_Life_ARR[19] = 'AHPC';
        POS_Life_ARR[20] = 'AHPD';
        NEG_Life = 0;
        NUM_Life = 21;
        CAP_Life = 2097152;

        POS_MaxMana_ARR[0] = 'ALT0';
        POS_MaxMana_ARR[1] = 'ALT1';
        POS_MaxMana_ARR[2] = 'ALT2';
        POS_MaxMana_ARR[3] = 'ALT3';
        POS_MaxMana_ARR[4] = 'ALT4';
        POS_MaxMana_ARR[5] = 'ALT5';
        POS_MaxMana_ARR[6] = 'ALT6';
        POS_MaxMana_ARR[7] = 'ALT7';
        POS_MaxMana_ARR[8] = 'ALT8';
        POS_MaxMana_ARR[9] = 'ALT9';
        POS_MaxMana_ARR[10] = 'ALT:';
        POS_MaxMana_ARR[11] = 'ALT;';
        POS_MaxMana_ARR[12] = 'ALT<';
        POS_MaxMana_ARR[13] = 'ALT=';
        POS_MaxMana_ARR[14] = 'ALT>';
        POS_MaxMana_ARR[15] = 'ALT?';
        POS_MaxMana_ARR[16] = 'ALT@';
        NEG_MaxMana = 0;
        NUM_MaxMana = 17;
        CAP_MaxMana = 131072;

        POS_Armor_ARR[0] = 'ARM0';
        POS_Armor_ARR[1] = 'ARM1';
        POS_Armor_ARR[2] = 'ARM2';
        POS_Armor_ARR[3] = 'ARM3';
        POS_Armor_ARR[4] = 'ARM4';
        POS_Armor_ARR[5] = 'ARM5';
        POS_Armor_ARR[6] = 'ARM6';
        NEG_Armor = 'AMP0';
        NUM_Armor = 7;
        CAP_Armor = 128;

        POS_AttackSpeed_ARR[0] = 'AHS0';
        POS_AttackSpeed_ARR[1] = 'AHS1';
        POS_AttackSpeed_ARR[2] = 'AHS2';
        POS_AttackSpeed_ARR[3] = 'AHS3';
        POS_AttackSpeed_ARR[4] = 'AHS4';
        POS_AttackSpeed_ARR[5] = 'AHS5';
        POS_AttackSpeed_ARR[6] = 'AHS6';
        POS_AttackSpeed_ARR[7] = 'AHS7';
        NEG_AttackSpeed = 'AHZ0';
        NUM_AttackSpeed = 8;
        CAP_AttackSpeed = 256;

        POS_Str_ARR[0] = 'ASR0';
        POS_Str_ARR[1] = 'ASR1';
        POS_Str_ARR[2] = 'ASR2';
        POS_Str_ARR[3] = 'ASR3';
        POS_Str_ARR[4] = 'ASR4';
        POS_Str_ARR[5] = 'ASR5';
        POS_Str_ARR[6] = 'ASR6';
        POS_Str_ARR[7] = 'ASR7';
        POS_Str_ARR[8] = 'A0D5';
        NEG_Str = 0;
        NUM_Str = 9;
        CAP_Str = 512;

        POS_Agi_ARR[0] = 'AAG0';
        POS_Agi_ARR[1] = 'AAG1';
        POS_Agi_ARR[2] = 'AAG2';
        POS_Agi_ARR[3] = 'AAG3';
        POS_Agi_ARR[4] = 'AAG4';
        POS_Agi_ARR[5] = 'AAG5';
        POS_Agi_ARR[6] = 'AAG6';
        POS_Agi_ARR[7] = 'AAG7';
        POS_Agi_ARR[8] = 'A0D6';
        NEG_Agi = 0;
        NUM_Agi = 9;
        CAP_Agi = 512;

        POS_Int_ARR[0] = 'AWZ0';
        POS_Int_ARR[1] = 'AWZ1';
        POS_Int_ARR[2] = 'AWZ2';
        POS_Int_ARR[3] = 'AWZ3';
        POS_Int_ARR[4] = 'AWZ4';
        POS_Int_ARR[5] = 'AWZ5';
        POS_Int_ARR[6] = 'AWZ6';
        POS_Int_ARR[7] = 'AWZ7';
        POS_Int_ARR[8] = 'A0D7';
        NEG_Int = 0;
        NUM_Int = 9;
        CAP_Int = 512;
    }
}
//! endzinc
