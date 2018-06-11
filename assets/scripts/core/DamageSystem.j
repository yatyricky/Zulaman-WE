//! zinc
library DamageSystem requires ZAMCore, UnitProperty, BuffSystem, FloatingNumbers {
// - - - - - - - - - - - - - - - - - - - -
// public function DamageTarget(
//     unit source
//     unit target
//     real amount
//     string damageName
//     boolean isPhyx
//     boolean criticable
//     boolean dodgable
//     weapontype wtype
// )
//
// public function HealTarget(
//     unit a
//     unit b
//     real amount
//     string hName
//     real exCrit
// )
// - - - - - - - - - - - - - - - - - - - -
    constant string MISS = "Miss";
    constant string DODGE = "Dodge";
    constant string BLOCK = "Parry";
    constant string ABSORB = "Absorb";
    constant string IMMUNE = "Immune";
    unit damageDummy;
    
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
        static boolean wasDirect = false;
    }
    
    public struct HealResult {
        static unit source = null;
        static unit target = null;
        static string abilityName = null;
        static real amount = 0.0;
        static real effective = 0.0;
        static boolean isCritical = false;
        static boolean wasDirect = false;
    }
    
    public function HealTarget(unit a, unit b, real amount, string hName, real exCrit, boolean direct) {
        string display;
        integer i;
        HealResult.wasDirect = direct;
        HealResult.isCritical = GetRandomReal(0.0, 1.0) < UnitProp.inst(a, SCOPE_PREFIX + "HealTarget 1").SpellCrit() + exCrit;
        amount = amount * UnitProp.inst(a, SCOPE_PREFIX + "HealTarget 2").DamageDealt() * UnitProp.inst(b, SCOPE_PREFIX + "HealTarget 3").HealTaken();
        if (HealResult.isCritical) {
            amount *= 1.5;
        }
        if (amount + GetWidgetLife(b) > GetUnitState(b, UNIT_STATE_MAX_LIFE)) {
            HealResult.effective = GetUnitState(b, UNIT_STATE_MAX_LIFE) - GetWidgetLife(b);
        } else {
            HealResult.effective = amount;
        }
        SetWidgetLife(b, GetWidgetLife(b) + amount);
        if (amount >= 0.0) {
            if (GetLocalPlayer() == GetOwningPlayer(a) || GetLocalPlayer() == GetOwningPlayer(b)) {
                display = I2S(R2I(amount));
            } else {
                display = NULL_STR;
            }
            HealResult.source = a;
            HealResult.target = b;
            HealResult.abilityName = hName;
            HealResult.amount = amount;       
            i = 0;
            while (i < responseHealedN) {
                responseHealedCallList[i].evaluate();
                i += 1;
            }
            FloatingNumbers.create(display, COLOR_HEAL, GetUnitX(b), GetUnitY(b), 1.3, false);
        }
    }
    
public boolean lifelock = false;

    public function DamageTarget(unit a, unit b, real amount, string dmgName, boolean isPhyx, boolean criticable, boolean dodgable, weapontype wtype, boolean direct) {
        integer i;
        string display;
        string color;
        boolean isTop;
        real displaySize;
        real absorbAmt;
        real factor = GetRandomReal(0.0, 1.0);
        real desk = 0.0;
        UnitProp upa = UnitProp.inst(a, SCOPE_PREFIX + " DamageTarget upa");
        UnitProp upb = UnitProp.inst(b, SCOPE_PREFIX + " DamageTarget upb");
        DamageResult.abilityName = dmgName;
        DamageResult.source = a;
        DamageResult.target = b;
        DamageResult.isPhyx = isPhyx;
        DamageResult.wasDodgable = dodgable;
        DamageResult.wasDirect = direct;
        desk = 1.0 - upa.AttackRate();
        DamageResult.amount = amount;   
        DamageResult.extraCrit = 0.0;
        i = 0;
        while (i < responseOnDamageN) {
            responseOnDamageCallList[i].evaluate();
            i += 1;
        }
        if (factor < desk && DamageResult.wasDodgable) {
            display = MISS;
            DamageResult.amount = 0.0;
            DamageResult.isHit = false;
            DamageResult.isBlocked = false;
            DamageResult.isDodged = false;
            DamageResult.isCritical = false;
            DamageResult.isImmune = false;
        } else {
            desk += upb.Dodge();
            if (factor < desk && DamageResult.wasDodgable) {
                display = DODGE;
                DamageResult.amount = 0.0;
                DamageResult.isHit = false;
                DamageResult.isBlocked = false;
                DamageResult.isDodged = true;
                DamageResult.isCritical = false;
                DamageResult.isImmune = false;
            } else {
                DamageResult.amount *= upa.DamageDealt();
                DamageResult.isHit = true;
                DamageResult.isDodged = false;
                if (DamageResult.isPhyx) {
                    DamageResult.amount *= (100.0 - upb.Armor()) / 100.0;
                } else {
                    DamageResult.amount *= upb.SpellTaken();
                }
                DamageResult.amount *= upb.DamageTaken();
                if (DamageResult.amount < 2.0) {
                    DamageResult.amount = 0.0;
                    DamageResult.isBlocked = false;
                    DamageResult.isCritical = false;
                    if (upb.DamageTaken() <= 0.0) {
                        DamageResult.isImmune = true;
                        display = IMMUNE;
                    } else {
                        DamageResult.isImmune = false;
                        display = NULL_STR;
                    }
                } else {
                    DamageResult.isImmune = false;   
                    desk += upb.BlockRate();
                    if (factor < desk && DamageResult.wasDodgable) {
                        DamageResult.amount -= upb.BlockPoint();
                        DamageResult.isCritical = false;
                        DamageResult.isBlocked = true;
                        if (DamageResult.amount < 2.0) {
                            DamageResult.amount = 0.0;
                            display = BLOCK;
                        }
                    } else {
                        DamageResult.isBlocked = false;
                        desk += upa.AttackCrit();
                        if ((factor < desk + DamageResult.extraCrit && DamageResult.isPhyx) || (factor < upa.SpellCrit() + DamageResult.extraCrit && !DamageResult.isPhyx) && criticable) {
                            DamageResult.amount *= 2.0;
                            DamageResult.isCritical = true;
                        } else {
                            DamageResult.isCritical = false;
                        }
                    }
                    if (DamageResult.amount > 0.0) {
                        DamageResult.amount = BuffSlot[b].absorb(DamageResult.amount);
                        if (DamageResult.amount == 0.0) {
                            display = ABSORB;
                        } else {
                            display = I2S(R2I(DamageResult.amount));
                            UnitDamageTarget(a, b, DamageResult.amount, true, true, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_DIVINE, wtype);
                            if (GetWidgetLife(b) < GetUnitState(b, UNIT_STATE_MAX_LIFE) * 0.5 && lifelock) {SetWidgetLife(b, GetUnitState(b, UNIT_STATE_MAX_LIFE));}
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
        if (GetLocalPlayer() == GetOwningPlayer(a)) {
            if (DamageResult.isCritical == true) {
                color = COLOR_DAMAGE_CRITICAL;
                isTop = true;
                displaySize = 2.2;
            } else {
                color = COLOR_DAMAGE_MOB;
                isTop = true;
                displaySize = 1.3;
            }
        } else if (GetLocalPlayer() == GetOwningPlayer(b)) {
            color = COLOR_DAMAGE_PLAYER;
            isTop = false;
            displaySize = 1.3;
        } else {
            display = NULL_STR;
            color = COLOR_DAMAGE_MOB;
            isTop = true;
            displaySize = 1.0;
        }
        FloatingNumbers.create(display, color, GetUnitX(b), GetUnitY(b), displaySize, isTop);
    }

    public function DummyDamageTarget(unit target, real amount, string dmgName) {
        DamageTarget(damageDummy, target, amount, dmgName, false, false, false, WEAPON_TYPE_WHOKNOWS, false);
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
            DamageTarget(this.a, this.b, this.amount, this.dmgName, this.isPhyx, this.criticable, this.dodgable, this.wtype, false);
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
        if (dmg == 0.0) {
            a = null; b = null; return false;
        } else if (a == b) {
            a = null; b = null; return false;
        } else if (dmg > 1.0) {
            a = null; b = null; return false;
        } else {
            DamageTarget(a, b, UnitProp.inst(a, SCOPE_PREFIX + "damaged 1").AttackPower(), DAMAGE_NAME_MELEE, true, true, true, null, false);
        }
        a = null; b = null; return false;
    }
    
    private trigger dmgtrg;
    
    function register(unit u) { 
        if (!IsUnitDummy(u)) {
            TriggerRegisterUnitEvent(dmgtrg, u, EVENT_UNIT_DAMAGED);
        }
    }

    function dummyDeath(unit u) {
        if (GetUnitTypeId(u) == UTID_DAMAGE_DUMMY) {
            print("[Warning] Damage dummy is dead, please log");
            damageDummy = CreateUnit(Player(0), UTID_DAMAGE_DUMMY, -10516, -14027, 0);
        }
    }
    
    private function onInit() {
        dmgtrg = CreateTrigger();
        TriggerAddCondition(dmgtrg, Condition(function damaged));
        RegisterUnitEnterMap(register);
        TimerStart(CreateTimer(), 1.0, false, function() {
            DestroyTimer(GetExpiredTimer());
            damageDummy = CreateUnit(Player(0), UTID_DAMAGE_DUMMY, -10516, -14027, 0);
        });
        RegisterUnitDeath(dummyDeath);
    }
}
//! endzinc
