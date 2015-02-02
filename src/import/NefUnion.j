//! zinc
library NefUnion requires TimerUtils {
//==============================================================================
//  constant    integer:    DUMMY_ID
//==============================================================================
//              nothing:    DummyCast(unit caster, integer abilityID, 
//                              string orderString, unit target)
//              nothing:    TriggerAnyUnit(playerunitevent whichEvent, 
//                              code action)
//==============================================================================

    public struct AddTimedEffect {
        private timer t;
        private effect e;
        
        private static method execute() {
            thistype this = GetTimerData(GetExpiredTimer());
            DestroyEffect(this.e);
            ReleaseTimer(this.t);
            this.t = null;
            this.e = null;
            this.destroy();
        }

        static method atUnit(string se, unit a, string ap, real et) {
            thistype this = thistype.allocate();
            this.t = NewTimer();
            this.e = AddSpecialEffectTarget(se, a, ap);
            SetTimerData(this.t, this);
            TimerStart(this.t, et, false, function thistype.execute);
        }

        static method atCoord(string se, real x, real y, real et) {
            thistype this = thistype.allocate();
            this.t = NewTimer();
            this.e = AddSpecialEffect(se, x, y);
            SetTimerData(this.t, this);
            TimerStart(this.t, et, false, function thistype.execute);
        }
        
        static method byDummy(integer id, real x, real y) {
            KillUnit(CreateUnit(Player(0), id, x + 16.0, y + 24.0, 0.0));
        }
    }

    public struct DelayedAddTimedEffect {
        private timer t;
        private effect e;
        private real x, y, et;
        private string se;
        
        private static method execute() {
            thistype this = GetTimerData(GetExpiredTimer());
            DestroyEffect(this.e);
            ReleaseTimer(this.t);
            this.t = null;
            this.e = null;
            this.se = null;
            this.destroy();
        }
        
        private static method launch() {
            thistype this = GetTimerData(GetExpiredTimer());
            this.e = AddSpecialEffect(this.se, this.x, this.y);
            TimerStart(this.t, this.et, false, function thistype.execute);
        }
/*
        static method atUnit(string se, unit a, string ap, real et) {
            thistype this = thistype.allocate();
            this.t = NewTimer();
            this.e = AddSpecialEffectTarget(se, a, ap);
            SetTimerData(this.t, this);
            TimerStart(this.t, et, false, function thistype.execute);
        }*/

        static method atCoord(string se, real x, real y, real et, real dt) {
            thistype this = thistype.allocate();
            this.t = NewTimer();
            SetTimerData(this.t, this);
            this.x = x;
            this.y = y;
            this.se = se;
            this.et = et;
            TimerStart(this.t, dt, false, function thistype.launch);
        }
        /*
        static method byDummy(integer id, real x, real y) {
            KillUnit(CreateUnit(Player(0), id, x + 16.0, y + 24.0, 0.0));
        }*/
    }
    
	// "CLPB" 闪电链-主 
    // "CLSB" 闪电链-次
    // "DRAB" 汲取
    // "DRAL" 生命汲取
    // "DRAM" 魔法汲取
    // "AFOD" 死亡之指
    // "FORK" 叉状闪电
    // "HWPB" 医疗波-主
    // "HWSB" 医疗波-次
    // "CHIM" 闪电攻击
    // "LEAS" 魔法镣铐
    // "MBUR" 法力燃烧
    // "MFPB" 魔力之焰
    // "SPLK" 灵魂锁链
    public struct AddTimedLight {
        private lightning l;
        private unit a;
        private unit b;
        private integer c;
        private timer t;
		private location la;
		private location lb;
        private real za;
        private real zb;
        
        private method destroy() {
            ReleaseTimer(this.t);
            DestroyLightning(this.l);
			RemoveLocation(this.la);
			RemoveLocation(this.lb);
			this.la = null;
			this.lb = null;
            this.t = null;
            this.l = null;
            this.a = null;
            this.b = null;
			this.deallocate();
        }

        private static method executeNormal() {
            thistype this = GetTimerData(GetExpiredTimer());
            MoveLocation(this.la, GetUnitX(this.a), GetUnitY(this.a));
            MoveLocation(this.lb, GetUnitX(this.b), GetUnitY(this.b));
            MoveLightningEx(this.l, false,/*
            */GetLocationX(this.la), GetLocationY(this.la), GetLocationZ(this.la)+GetUnitFlyHeight(this.a),/*
            */GetLocationX(this.lb), GetLocationY(this.lb), GetLocationZ(this.lb)+GetUnitFlyHeight(this.b));
            this.c = this.c - 1;
            if (this.c < 0) {
                this.destroy();
            }
        }

        private static method executeNormalZ() {
            thistype this = GetTimerData(GetExpiredTimer());
            MoveLocation(this.la, GetUnitX(this.a), GetUnitY(this.a));
            MoveLocation(this.lb, GetUnitX(this.b), GetUnitY(this.b));
            MoveLightningEx(this.l, false,/*
            */GetLocationX(this.la), GetLocationY(this.la), GetLocationZ(this.la)+GetUnitFlyHeight(this.a)+this.za,/*
            */GetLocationX(this.lb), GetLocationY(this.lb), GetLocationZ(this.lb)+GetUnitFlyHeight(this.b)+this.zb);
            this.c = this.c - 1;
            if (this.c < 0) {
                this.destroy();
            }
        }
        
        private static method execute_unitCoord() {
            thistype this = GetTimerData(GetExpiredTimer());
            MoveLocation(this.la, GetUnitX(this.a), GetUnitY(this.a));
            MoveLightningEx(this.l, false,/*
            */GetLocationX(this.la), GetLocationY(this.la), GetLocationZ(this.la)+GetUnitFlyHeight(this.a),/*
            */GetLocationX(this.lb), GetLocationY(this.lb), GetLocationZ(this.lb));
            this.c = this.c - 1;
            if (this.c < 0) {
                this.destroy();
            }
        }

        private static method execute_coords() {
			thistype(GetTimerData(GetExpiredTimer())).destroy();
        }

        static method atUnits(string se, unit a, unit b, real et) -> thistype {
            thistype this = thistype.allocate();
            this.la = GetUnitLoc(a);
            this.lb = GetUnitLoc(b);
            this.l = AddLightningEx(se, false, GetLocationX(la), GetLocationY(la), GetLocationZ(la)+GetUnitFlyHeight(a), GetLocationX(lb), GetLocationY(lb), GetLocationZ(lb)+GetUnitFlyHeight(b));
            this.t = NewTimer();
            this.a = a;
            this.b = b;
            this.c = R2I(et*25.0);
            SetTimerData(this.t, this);
            TimerStart(this.t, 0.04, true, function thistype.executeNormal);
            return this;
        }

        static method atUnitsZ(string se, unit a, real za, unit b, real zb, real et) -> thistype {
            thistype this = thistype.allocate();
            this.la = GetUnitLoc(a);
            this.lb = GetUnitLoc(b);
            this.l = AddLightningEx(se, false, GetLocationX(la), GetLocationY(la), GetLocationZ(la)+GetUnitFlyHeight(a)+za, GetLocationX(lb), GetLocationY(lb), GetLocationZ(lb)+GetUnitFlyHeight(b)+zb);
            this.t = NewTimer();
            this.a = a;
            this.b = b;
            this.za = za;
            this.zb = zb;
            this.c = R2I(et*25.0);
            SetTimerData(this.t, this);
            TimerStart(this.t, 0.04, true, function thistype.executeNormalZ);
            return this;
        }

        static method atUnitCoord(string se, unit a, real x, real y, real et) -> thistype {
            thistype this = thistype.allocate();
            this.la = GetUnitLoc(a);
            this.lb = Location(x, y);
            this.l = AddLightningEx(se, false, GetLocationX(la), GetLocationY(la), GetLocationZ(la)+GetUnitFlyHeight(a), GetLocationX(lb), GetLocationY(lb), GetLocationZ(lb));
            this.t = NewTimer();
            this.a = a;
            this.c = R2I(et*25.0);
            SetTimerData(this.t, this);
            TimerStart(this.t, 0.04, true, function thistype.execute_unitCoord);
            return this;
        }
/*
        static method atCoord3dUnit(string se, real x, real y, real z, unit a, real et) -> thistype {
            thistype this = thistype.allocate();
            this.la = Location(x, y);
            this.lb = GetUnitLoc(a);
            this.l = AddLightningEx(se, false, GetLocationX(la), GetLocationY(la), GetLocationZ(la)+z, GetLocationX(lb), GetLocationY(lb), GetLocationZ(lb)+GetUnitFlyHeight(a));
            this.t = NewTimer();
            this.a = a;
            this.c = R2I(et*25.0);
            SetTimerData(this.t, this);
            TimerStart(this.t, 0.04, true, function thistype.execute_unitCoord);
            return this;
        }*/
		
		static method atCoords(string se, real xa, real ya, real xb, real yb, real et) -> thistype {
            thistype this = thistype.allocate();
            this.la = Location(xa, ya);
            this.lb = Location(xb, yb);
            this.l = AddLightningEx(se, false, GetLocationX(la), GetLocationY(la), GetLocationZ(la), GetLocationX(lb), GetLocationY(lb), GetLocationZ(lb));
            this.t = NewTimer();
            SetTimerData(this.t, this);
            TimerStart(this.t, et, false, function thistype.execute_coords);
            return this;
		}
		
		static method atCoords3D(string se, real xa, real ya, real za, real xb, real yb, real zb, real et) -> thistype {
            thistype this = thistype.allocate();
            this.l = AddLightningEx(se, false, xa, ya, za, xb, yb, zb);
            this.t = NewTimer();
            SetTimerData(this.t, this);
            TimerStart(this.t, et, false, function thistype.execute_coords);
            return this;
		}
        
        // 0-1.0
        method setColour(real r, real g, real b, real a) -> boolean {
            return SetLightningColor(this.l, r, g, b, a);
        }
    }
    
    public function B2I(boolean b) -> integer {
        if (b) {return 1;}
        else {return 0;}
    }
    
    public function B2S(boolean b) -> string {
        if (b) {
            return "TRUE";
        } else {
            return "FALSE";
        }
    }
    
    /**
	 * Supported parameters:
	 *     unit u0
	 * Usage:
	 *     function delayedCallBack(DelayTask dt) {
	 *         // do something
	 *     }
	 *
	 *     DelayedTaskExecute callback = delayedCallBack;
	 *     DelayTask dt = DelayTask.create(callback, 3.0);
	 *     dt.u0 = SpellEvent.CastingUnit;
	 */
	public type DelayedTaskExecute extends function(DelayTask);
    public struct DelayTask {
        private timer tm;
        private DelayedTaskExecute response;
        unit u0;
        integer i0;
        
        private method destroy() {
            ReleaseTimer(this.tm);
            this.tm = null;
            this.u0 = null;
            this.deallocate();
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            this.response.evaluate(this);
            this.destroy();
        }
    
        static method create(DelayedTaskExecute response, real timeout) -> thistype {
            thistype this = thistype.allocate();
            this.response = response;
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            TimerStart(this.tm, timeout, false, function thistype.run);
            return this;
        }
    }
	
    public constant integer DUMMY_ID = 'e01B';    
    public function DummyCast(unit a, integer aid, string oid, unit tar) {
        unit dc = CreateUnit(GetOwningPlayer(a), DUMMY_ID, GetUnitX(tar), GetUnitY(tar), 0.0);
        UnitAddAbility(dc, aid);
        IssueTargetOrderById(dc, OrderId(oid), tar);
        UnitApplyTimedLife(dc, 'BHwe', 2.0);
        dc = null;
    }
    public function DummyCastPoint(unit a, integer aid, string oid, real x, real y) {
        unit dc = CreateUnit(GetOwningPlayer(a), DUMMY_ID, x, y, 0.0);
        UnitAddAbility(dc, aid);
        IssuePointOrderById(dc, OrderId(oid), x, y);
        UnitApplyTimedLife(dc, 'BHwe', 2.0);
        dc = null;
    }
    
    public function GetAngleDeg(real xa, real ya, real xb, real yb) -> real {
        return bj_RADTODEG * Atan2(ya - yb, xa - xb) + 180.0;
    }
    
    public function GetAngle(real xa, real ya, real xb, real yb) -> real {
        return Atan2(ya - yb, xa - xb) + bj_PI;
    }
    
    public struct GetDistance {
        static method units(unit o, unit t) -> real {
            location lo = GetUnitLoc(o);
            location lt = GetUnitLoc(t);
            real dx = GetUnitX(t) - GetUnitX(o);
            real dy = GetUnitY(t) - GetUnitY(o);
            real dz = GetUnitFlyHeight(t) + GetLocationZ(lt) - GetUnitFlyHeight(o) - GetLocationZ(lo);
            real dis = SquareRoot(dx * dx + dy * dy + dz * dz);
            RemoveLocation(lo);
            RemoveLocation(lt);
            lo = null;
            lt = null;
            return dis;
        }

        static method coords(real xo, real yo, real zo, real xt, real yt, real zt) -> real {
            return SquareRoot((xt - xo) * (xt - xo) + (yt - yo) * (yt - yo) + (zt - zo) * (zt - zo));
        }
        
        static method unitCoord(unit o, real x, real y) -> real {
            location lo = GetUnitLoc(o);
            location lt = Location(x, y);
            real dx = GetLocationX(lt) - GetLocationX(lo);
            real dy = GetLocationY(lt) - GetLocationY(lo);
            real dz = GetLocationZ(lt) - GetLocationZ(lo) - GetUnitFlyHeight(o);
            real dis = SquareRoot(dx * dx + dy * dy + dz * dz);
            RemoveLocation(lo);
            RemoveLocation(lt);
            lo = null;
            lt = null;
            return dis;
        }
        
        static method units2d(unit o, unit t) -> real {
            if (IsUnit(o, t)) {return 0.0;}
            else {return thistype.coords(GetUnitX(o), GetUnitY(o), 0.0, GetUnitX(t), GetUnitY(t), 0.0);}
        }
        
        static method units2dAngular(unit o, unit t, unit c) -> real {
			real td;
            if (IsUnit(o, t)) {
				return 0.0;
			} else {
				td = RAbsBJ(GetAngleDeg(GetUnitX(o), GetUnitY(o), GetUnitX(c), GetUnitY(c)) - GetAngleDeg(GetUnitX(t), GetUnitY(t), GetUnitX(c), GetUnitY(c)));
				if (td > 180) {
					td = RAbsBJ(td - 360);
				}
				return td;
			}
        }

        static method coords2d(real xo, real yo, real xt, real yt) -> real {
            return thistype.coords(xo, yo, 0.0, xt, yt, 0.0);
        }
        
        static method unitCoord2d(unit o, real x, real y) -> real {
            return thistype.coords(GetUnitX(o), GetUnitY(o), 0.0, x, y, 0.0);
        }
    }
    
    public function GetPidofu(unit u) -> integer {
        return GetPlayerId(GetOwningPlayer(u));
    }
    
    public function GetUnitLifeLost(unit u) -> real {
        return (GetUnitState(u, UNIT_STATE_MAX_LIFE) - GetWidgetLife(u));
    }
    
    public function GetUnitMana(unit u) -> real {
        return GetUnitState(u, UNIT_STATE_MANA);
    }
    
    public function GetUnitManaLost(unit u) -> real {
        return (GetUnitState(u, UNIT_STATE_MAX_MANA) - GetUnitState(u, UNIT_STATE_MANA));
    }
    
    public function GetUnitNameEx(unit u) -> string {
        if (IsUnitType(u, UNIT_TYPE_HERO)) {
            return GetHeroProperName(u);
        } else {
            return GetUnitName(u);
        }
    }
    
    public function Rounding(real r) -> integer {
        integer i;
        integer tmp = R2I(r);
        i = R2I(r * 2) - tmp * 2;
        if (i == 0) {
            return tmp;
        } else {
            return tmp + 1;
        }
    }    
    
    public function SetUnitFlyable(unit a) {
        UnitAddAbility(a, 'Amrf');
        UnitRemoveAbility(a, 'Amrf');
    }

    public struct TimedUnitRemoveAbility {
        private timer tm;
        private unit a;
        private integer id;
    
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            UnitRemoveAbility(this.a, this.id);
            ReleaseTimer(this.tm);
            this.tm = null;
            this.a = null;
            this.deallocate();
        }
    
        static method start(unit a, integer id) {
            thistype this = thistype.allocate();
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.a = a;
            this.id = id;
            SetPlayerAbilityAvailable(GetOwningPlayer(a), id, false);
            TimerStart(this.tm, 0.1, false, function thistype.run);
        }
    }
    
    public function ModUnitMana(unit u, real amt) {
        SetUnitState(u, UNIT_STATE_MANA, GetUnitState(u, UNIT_STATE_MANA) + amt);
    }
    
    //public function Mod(integer a, integer b) -> integer {
    //    return a - (a / b) * b;
    //}
    
    public function TriggerAnyUnit(playerunitevent whichevent, code action) {
        integer i;
        trigger tg = CreateTrigger();
        i = 0;
        while (i < bj_MAX_PLAYER_SLOTS) {
            TriggerRegisterPlayerUnitEvent(tg, Player(i), whichevent, null);
            i += 1;
        }
        TriggerAddCondition(tg, Condition(action));
    }
}
//! endzinc
