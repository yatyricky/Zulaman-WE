//! zinc
library DamageSystem requires ZAMCore, UnitProperty, BuffSystem {
#define MISS "|cffffcc00未命中|r"
#define DODGE "|cffffcc00躲闪|r"
#define BLOCK "|cffffcc00招架|r"
#define ABSORB "|cffffcc00吸收|r"
#define IMMUNE "|cffffcc00免疫|r"
#define NULL_STR ""
    
    public type ResponseDamaged extends function();       
    private ResponseDamaged responseDamagedCallList[];
    private integer responseDamagedN = 0;        
    public function RegisterDamagedEvent (ResponseDamaged responseDamaged) {
        responseDamagedCallList[responseDamagedN] = responseDamaged;
        responseDamagedN += 1;
    }
    
    public type ResponseOnDamage extends function();       
    private ResponseOnDamage responseOnDamageCallList[];
    private integer responseOnDamageN = 0;        
    public function RegisterOnDamageEvent (ResponseOnDamage responseOnDamage) {
        responseOnDamageCallList[responseOnDamageN] = responseOnDamage;
        responseOnDamageN += 1;
    }
    
    public type ResponseHealed extends function();       
    private ResponseHealed responseHealedCallList[];
    private integer responseHealedN = 0;        
    public function RegisterHealedEvent (ResponseHealed responseHealed) {
        responseHealedCallList[responseHealedN] = responseHealed;
        responseHealedN += 1;
    }
    
    public struct DamageResult {
        static unit source = null;
        static unit target = null;
        static string abilityName = null;
        static real amount = 0.0;
        static boolean isHit = false;
        static boolean isBlocked = false;
        static boolean isDodged = false;
        static boolean isCritical = false;
        static boolean isImmune = false;
        static real extraCrit = 0.0;
        static boolean isPhyx = false;
        static boolean wasDodgable = false;
        
        /*unit Dsource, Dtarget;
        string DabilityName;
        real Damount;
        boolean DisHit;
        boolean DisBlocked;
        boolean DisDodged;
        boolean DisCritical;
        boolean DisImmune;
        real DextraCrit;
        boolean DisPhyx;
        boolean DwasDodgable;*/
        /*
        method destroy() {
            this.source = null;
            this.target = null;
            this.deallocate();
        }*/
        
        /*static method save() -> thistype {
            thistype this = thistype.allocate();
            this.Dsource = thistype.source;
            this.Dtarget = thistype.target;
            this.DabilityName = thistype.abilityName;
            this.Damount = thistype.amount;
            this.DisHit = thistype.isHit;
            this.DisBlocked = thistype.isBlocked;
            this.DisDodged = thistype.isDodged;
            this.DisCritical = thistype.isCritical;
            this.DisImmune = thistype.isImmune;
            this.DextraCrit = thistype.extraCrit;
            this.DisPhyx = thistype.isPhyx;
            this.DwasDodgable = thistype.wasDodgable;
            return this;
        }*/
        /*
        static method display() {
            BJDebugMsg("= = = = = Damage Result = = = = =");
            BJDebugMsg("Amount: " + R2S(thistype.amount));
            BJDebugMsg("= = = = = Damage Result = = = = =");
        }*/
    }
    
    public struct HealResult {
        static unit source = null;
        static unit target = null;
        static string abilityName = null;
        static real amount = 0.0;
        static real effective = 0.0;
        static boolean isCritical = false;
        /*
        unit Dsource, Dtarget;
        string DabilityName;
        real Damount;
        real Deffective;
        boolean DisCritical;
        
        method destroy() {
            this.source = null;
            this.target = null;
            this.deallocate();
        }
        
        static method save() -> thistype {
            thistype this = thistype.allocate();
            this.Dsource = thistype.source;
            this.Dtarget = thistype.target;
            this.DabilityName = thistype.abilityName;
            this.Damount = thistype.amount;
            this.Deffective = thistype.effective;
            this.DisCritical = thistype.isCritical;
            return this;
        }  */      
        
    }
    
    public function HealTarget(unit a, unit b, real amount, string hName, real exCrit) {
        string display;
        integer i;        
        HealResult.isCritical = GetRandomReal(0.0, 1.0) < UnitProp[a].SpellCrit() + exCrit;
        amount = amount * UnitProp[a].DamageDealt() * UnitProp[b].HealTaken();
        if (HealResult.isCritical) {
            amount *= 1.5;
        }
        //Recount[a].cheal += amount;
        //BJDebugMsg("Recieved Heal = " + R2S(amount));
        if (amount + GetWidgetLife(b) > GetUnitState(b, UNIT_STATE_MAX_LIFE)) {
            HealResult.effective = GetUnitState(b, UNIT_STATE_MAX_LIFE) - GetWidgetLife(b);
            //Recount[a].ceffheal += GetUnitState(b, UNIT_STATE_MAX_LIFE) - GetWidgetLife(b);
        } else {
            HealResult.effective = amount;
            //Recount[a].ceffheal += amount;
        }
        SetWidgetLife(b, GetWidgetLife(b) + amount);
        if (amount >= 0.0) {
            if (GetLocalPlayer() == GetOwningPlayer(a) || GetLocalPlayer() == GetOwningPlayer(b))
            {display = I2S(R2I(amount));} else {display = "";}
            //BJDebugMsg(GetHeroProperName(a) + " heals " + GetHeroProperName(b));
            HealResult.source = a;
            HealResult.target = b;
            HealResult.abilityName = hName;
            HealResult.amount = amount;       
            i = 0;
            while (i < responseHealedN) {
                responseHealedCallList[i].evaluate();
                i += 1;
            }            
            TextTag_Heal(b, display, HealResult.isCritical);
        }
    }
    
public boolean lifelock = false;
    // source
	// target
	// amount
	// from ability by name
    // is physics
    // is criticable
    // is dodgable
    // damage sound
    public function DamageTarget(unit a, unit b, real amount, string dmgName, boolean isPhyx, boolean criticable, boolean dodgable, weapontype wtype) {
        integer i;
        string display;
        real absorbAmt;
        real factor = GetRandomReal(0.0, 1.0);
        real desk = 0.0;
        DamageResult.abilityName = dmgName;
        DamageResult.source = a;
        DamageResult.target = b;
        DamageResult.isPhyx = isPhyx;
        DamageResult.wasDodgable = dodgable;
//BJDebugMsg("factor = " + R2S(factor));
        desk = 1.0 - UnitProp[a].AttackRate();
//BJDebugMsg("desk 1 = " + R2S(desk));
        DamageResult.amount = amount;   
        DamageResult.extraCrit = 0.0;
        i = 0;
        while (i < responseOnDamageN) {
            responseOnDamageCallList[i].evaluate();
            i += 1;
        }
        //BJDebugMsg("Extra critical: " + R2S(DamageResult.extraCrit));
        if (factor < desk && DamageResult.wasDodgable) {
            display = MISS;
            DamageResult.amount = 0.0;
            DamageResult.isHit = false;
            DamageResult.isBlocked = false;
            DamageResult.isDodged = false;
            DamageResult.isCritical = false;
            DamageResult.isImmune = false;
            //BJDebugMsg("miss");
        } else {
            desk += UnitProp[b].Dodge();
//BJDebugMsg("desk 2 = " + R2S(desk));
            if (factor < desk && DamageResult.wasDodgable) {
                display = DODGE;
                DamageResult.amount = 0.0;
                DamageResult.isHit = false;
                DamageResult.isBlocked = false;
                DamageResult.isDodged = true;
                DamageResult.isCritical = false;
                DamageResult.isImmune = false;
            } else {
                DamageResult.amount *= UnitProp[a].DamageDealt();
                DamageResult.isHit = true;
                DamageResult.isDodged = false;
                if (DamageResult.isPhyx) {
                    DamageResult.amount *= (100.0 - UnitProp[b].Armor()) / 100.0;
                    //BJDebugMsg("phyx dmg");
                } else {
                    DamageResult.amount *= UnitProp[b].SpellTaken();
                    //BJDebugMsg("magic dmg");
                }
                DamageResult.amount *= UnitProp[b].DamageTaken();
                if (DamageResult.amount < 2.0) {
                    DamageResult.amount = 0.0;
                    DamageResult.isBlocked = false;
                    DamageResult.isCritical = false;
                    if (UnitProp[b].DamageTaken() <= 0.0) {
                        DamageResult.isImmune = true;
                        display = IMMUNE;
                    } else {
                        DamageResult.isImmune = false;
                        display = NULL_STR;
                    }
                    //BJDebugMsg("immune");
                } else {
                    DamageResult.isImmune = false;   
                    desk += UnitProp[b].BlockRate();
//BJDebugMsg("desk 3 = " + R2S(desk));
                    if (factor < desk && DamageResult.wasDodgable) {
                        DamageResult.amount -= UnitProp[b].BlockPoint();
                        DamageResult.isCritical = false;
                        DamageResult.isBlocked = true;
                        if (DamageResult.amount < 2.0) {
                            DamageResult.amount = 0.0;
                            display = BLOCK;
                        }
                        //BJDebugMsg("blocked");
                    } else {
                        DamageResult.isBlocked = false;
                        desk += UnitProp[a].AttackCrit();
//BJDebugMsg("desk 4 = " + R2S(desk));
                        if ((factor < desk + DamageResult.extraCrit && DamageResult.isPhyx) || (factor < UnitProp[a].SpellCrit() + DamageResult.extraCrit && !DamageResult.isPhyx) && criticable) {
                            DamageResult.amount *= 2.0;
                            DamageResult.isCritical = true;
                            //BJDebugMsg("crittical");
                        } else {
                            DamageResult.isCritical = false;
                            //BJDebugMsg("not crit");
                        }
                    }
                    if (DamageResult.amount > 0.0) {
                        DamageResult.amount = BuffSlot[b].absorb(DamageResult.amount);
                        if (DamageResult.amount == 0.0) {
                            display = ABSORB;
                            //BJDebugMsg("absorb");
                        } else {
                            display = I2S(R2I(DamageResult.amount));
                            //BJDebugMsg("set dmg amt -> " + display);
                            UnitDamageTarget(a, b, DamageResult.amount, true, true, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_DIVINE, wtype);
    if (GetWidgetLife(b) < GetUnitState(b, UNIT_STATE_MAX_LIFE) * 0.5 && lifelock) {SetWidgetLife(b, GetUnitState(b, UNIT_STATE_MAX_LIFE));}
                            //BJDebugMsg("dmged");
                        }
                    }
                }
            }
        }
        i = 0;
        while (i < responseDamagedN) {
            responseDamagedCallList[i].evaluate();
            i += 1;
        }
        if (DamageResult.isCritical) {
            display += "!";
        }
        if (GetLocalPlayer() != GetOwningPlayer(a) && GetLocalPlayer() != GetOwningPlayer(b)) {
            display = NULL_STR;
        }
        TextTag_Damage(b, display, DamageResult.isCritical);
    }
    
    public struct TimedDamageTarget {
        private unit a, b;
        private real amount;
        private string dmgName;
        private boolean isPhyx, criticable, dodgable;
        private weapontype wtype;
        private timer tm;
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            DamageTarget(this.a, this.b, this.amount, this.dmgName, this.isPhyx, this.criticable, this.dodgable, this.wtype);
            ReleaseTimer(this.tm);
            this.tm = null;
            this.a = null;
            this.b = null;
            this.wtype = null;
            this.deallocate();
        }
        
        static method start(unit a, unit b, real amount, string dmgName, boolean isPhyx, boolean criticable, boolean dodgable, weapontype wtype, real timeOut) {
            thistype this = thistype.allocate();
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.a = a;
            this.b = b;
            this.amount = amount;
            this.dmgName = dmgName;
            this.isPhyx = isPhyx;
            this.criticable = criticable;
            this.dodgable = dodgable;
            this.wtype = wtype;
            TimerStart(this.tm, timeOut, false, function thistype.run);
        }
    }
    
    public function DelayedDamageTarget(unit a, unit b, real amount, string dmgName, boolean isPhyx, boolean criticable, boolean dodgable, weapontype wtype) {
        TimedDamageTarget.start(a, b, amount, dmgName, isPhyx, criticable, dodgable, wtype, 0.01);
    }
    
    private function damaged() -> boolean {
        real dmg = GetEventDamage();
        unit a = GetEventDamageSource(), b = GetTriggerUnit();
        //print("我书读的少, 你别骗我.");
        if (dmg == 0.0) {
            //BJDebugMsg(SCOPE_PREFIX+">0 damage detected");
            a = null; b = null; return false;
        } else if (a == b) {
            //BJDebugMsg(SCOPE_PREFIX+">|cffff0000self damaging!|r");
            a = null; b = null; return false;
        } else if (dmg > 1.0) {
            //BJDebugMsg(SCOPE_PREFIX+">filtered");
            a = null; b = null; return false;
        } else {
            //BJDebugMsg(SCOPE_PREFIX+">Normal attacking");
            DamageTarget(a, b, UnitProp[a].AttackPower(), DAMAGE_NAME_MELEE, true, true, true, null);
        }
        a = null; b = null; return false;
    }
    
    private trigger dmgtrg;
    
    function register(unit u) { 
        if (!IsUnitDummy(u)) {
            TriggerRegisterUnitEvent(dmgtrg, u, EVENT_UNIT_DAMAGED);
        }
    }
    
    private function onInit() {
        dmgtrg = CreateTrigger();
        TriggerAddCondition(dmgtrg, Condition(function damaged));
        RegisterUnitEnterMap(register);
    }
}
//! endzinc
