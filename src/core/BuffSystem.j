//! zinc
library BuffSystem requires TimerUtils, Table, Integer, ZAMCore {

    public type BuffOnRemove extends function(Buff);
    public type BuffOnEffect extends function(Buff);
    
    public type ResponseAbsorbed extends function();       
    private ResponseAbsorbed responseAbsorbedCallList[];
    private integer responseAbsorbedN = 0;        
    public function RegisterAbsorbedEvent (ResponseAbsorbed responseAbsorbed) {
        responseAbsorbedCallList[responseAbsorbedN] = responseAbsorbed;
        responseAbsorbedN += 1;
    }
    
    public struct BuffResult {
        static boolean isNew;
    }
    
    Buff lastStolen[NUMBER_OF_MAX_PLAYERS];
    public function GetLastStolen(unit u) -> Buff {
        return lastStolen[GetPlayerId(GetOwningPlayer(u))];
    }
    public function SetLastStolen(unit u, Buff buf) {
        lastStolen[GetPlayerId(GetOwningPlayer(u))] = buf;
    }
    
    public struct BuffEffect {
        Buff parent;
        effect eff;
        string path;
        string point;
        
        method destroy() {
            if (this.eff != null) {
                DestroyEffect(this.eff);
            }
            this.eff = null;
            this.parent = 0;
            this.deallocate();
        }
        
        method remove() {
            if (this.eff != null) {
                //BJDebugMsg(I2HEX(GetHandleId(this.eff)));
                DestroyEffect(this.eff);
            }
            this.eff = null;
        }
        
        method refresh() {
            if (this.eff == null) {
                this.eff = AddSpecialEffectTarget(this.path, this.parent.bd.target, this.point);
                //BJDebugMsg(I2HEX(GetHandleId(this.eff)));
            }
        }
        
        static method create(string path, Buff parent, string point) -> thistype {
            thistype this = thistype.allocate();
            this.path = path;
            this.parent = parent;
            this.point = point;
            this.eff = null;
            this.refresh();
            return this;
        }
    }
    
    public struct BuffData {
        static integer instances = 0;
        BuffType bt;
        unit caster;
        unit target;
        boolean isShield;
        real interval;
        integer tick;
        BuffOnRemove bor;
        BuffOnEffect boe;
        integer i0, i1, i2;
        real r0, r1, r2;
        BuffEffect e0, e1;
        unit u0;
        
        method toString() -> string {
            string ret = "BuffType: " + ID2S(this.bt.bid);
            ret += ", caster: " + GetUnitNameEx(this.caster);
            ret += ", target: " + GetUnitNameEx(this.target);
            ret += ", isShield: " + B2S(this.isShield);
            ret += ", interval: " + R2S(this.interval);
            ret += ", tick: " + I2S(this.tick);
            return ret;
            
        }
        
        method destroy() {
            integer i = 0;
            while (i < NUMBER_OF_MAX_PLAYERS) {
                if (lastStolen[i] == this) {
                    lastStolen[i] = 0;
                }
                i += 1;
            }
            if (this.e0 != 0) {
                this.e0.destroy();
            }
            if (this.e1 != 0) {
                this.e1.destroy();
            }
            this.caster = null;
            this.target = null;
            this.e0 = 0;
            this.e1 = 0;
            this.i0 = 0; this.i1 = 0; this.i2 = 0;
            this.r0 = 0; this.r1 = 0; this.r2 = 0;
            this.deallocate();
            thistype.instances -= 1;
        }
        
        static method create() -> thistype {
            thistype this = thistype.allocate();
            this.isShield = false;
            this.i0 = 0;
            this.i1 = 0;
            this.i2 = 0;
            this.r0 = .0;
            this.r1 = .0;
            this.r2 = .0;
            this.e0 = 0;
            this.e1 = 0;
            thistype.instances += 1;
            return this;
        }
    }
    
    public struct AbsorbResult {
        static unit source = null;
        static unit target = null;
        static string abilityName = null;
        static real amount = 0.0;
    }

    public struct Buff {
        static integer instances = 0;
        Buff next;
        BuffData bd;
        timer tm;
        
        method destroy() {
            ReleaseTimer(this.tm);
            this.bd.destroy();
            this.tm = null;
            this.deallocate();
            thistype.instances -= 1;
        }
        
        method onRemove() {
            this.bd.bor.evaluate(this.bd);
            BuffSlot[this.bd.target].cancel(this);
            if (GetUnitAbilityLevel(this.bd.target, this.bd.bt.bid) > 0) {
                UnitRemoveAbility(this.bd.target, this.bd.bt.bid);
            }
            if (this.bd.e0 != 0) {
                //BJDebugMsg("to be remove inst: " + I2S(this.bd.e0));
                this.bd.e0.remove();
            }
            if (this.bd.e1 != 0) {
                this.bd.e1.remove();
            }
        }
        
        static method execution() {
            thistype this = GetTimerData(GetExpiredTimer());
            if (this.bd.tick > 0) {
                this.bd.boe.evaluate(this.bd);
            }
            this.bd.tick -= 1;
            if (this.bd.tick <= 0) {
                this.onRemove();
                this.destroy();
            }
        }
        
        method refresh() {
            if (this.bd.e0 != 0) {this.bd.e0.refresh();}
            if (this.bd.e1 != 0) {this.bd.e1.refresh();}
            if (GetUnitAbilityLevel(this.bd.target, this.bd.bt.bid) == 0) {
                UnitAddAbility(this.bd.target, this.bd.bt.bid);
                UnitMakeAbilityPermanent(this.bd.target, true, this.bd.bt.bid);
            }
            if (this.bd.tick < 0) {
                this.bd.boe.evaluate(this);
            }
        }
        
        method run() {
            if (this.bd.tick < 0) {
                this.bd.boe.evaluate(this.bd);
            }
            TimerStart(this.tm, this.bd.interval, this.bd.tick > 0, function thistype.execution);
        }
        
        // for strange wand
        method reRunForLasting(real last) {
            if (this.bd.tick < 0) {
                TimerStart(this.tm, last, false, function thistype.execution);
            }
        }
        
        static method cast(unit caster, unit target, integer bid) -> Buff {
            BuffSlot bs = BuffSlot[target];
            Buff this = bs.getBuffByBid(bid);
            if (this == 0) {
                this = Buff.allocate();
                thistype.instances += 1;
                this.next = 0;
                this.bd = BuffData.create();
                bs.push(this);
                this.bd.target = target;
                this.bd.bt = BuffType[bid];
                this.tm = NewTimer();
                SetTimerData(this.tm, this);
                if (GetUnitAbilityLevel(target, bid) == 0) {
                    UnitAddAbility(target, bid);
                    UnitMakeAbilityPermanent(target, true, bid);
                } 
                BuffResult.isNew = true;
            } else {
                BuffResult.isNew = false;
            }
            this.bd.caster = caster;
            return this;
        }
    }

    public struct BuffSlot {
        static HandleTable ht;
        unit u;
        Buff top;
        timer tm;
        
        method push(Buff b) {
            b.next = this.top;
            this.top = b;
        }
        
        method contains(integer buffCate, integer buffPoly) -> boolean {
            Buff current = this.top;
            while (current != 0) {
                if (current.bd.bt.buffCate == buffCate && current.bd.bt.buffPoly == buffPoly) {
                    return true;
                }
                current = current.next;
            }
            return false;
        }
        
        method dispel(integer buffCate, integer buffPoly) -> Buff {
            Buff current = this.top;
            Buff prev;
            while (current != 0) {
                if ((current.bd.bt.buffCate == buffCate || buffCate == BUFF_CATE_ALL) && current.bd.bt.buffPoly == buffPoly) {
                    if (current == this.top) {
                        this.top = current.next;
                        //BJDebugMsg("Removed top");
                    } else  {
                        prev.next = current.next;
                    }
                    //BJDebugMsg("Gonna onRemove");
                    current.onRemove();
                    return current;
                } else {
                    prev = current;
                    current = current.next;
                }
            }
            return 0;
        }
        
        method dispelByBuff(Buff buf) {
            Buff current = this.top;
            Buff prev;
            while (current != 0) {
                if (current == buf) {
                    if (current == this.top) {
                        this.top = current.next;
                    } else  {
                        prev.next = current.next;
                    }
                    current.onRemove();
                    return;
                } else {
                    prev = current;
                    current = current.next;
                }
            }
        }
        
        method removeAllBuff() {
            Buff current;
            //BJDebugMsg("to remove buff");
            while (this.top != 0) {
                //BJDebugMsg("One buff removed");
                current = this.top;
                current.onRemove();
                current.destroy();
            }
        }
        
        method cancel(Buff buf) {
            Buff current = this.top;
            Buff prev;
            while (current != 0) {
                if (current == buf) {
                    if (current == this.top) {
                        this.top = current.next;
                        //BJDebugMsg("Removed top");
                    } else  {
                        prev.next = current.next;
                    }
                    return;
                } else {
                    prev = current;
                    current = current.next;
                }
            }
        }
        
        method getBuffByBid(integer bid) -> Buff {
            Buff current = this.top;
            while (current != 0) {
                if (current.bd.bt.bid == bid) {
                    return current;
                } else {
                    current = current.next;
                }
            }
            return 0;
        }
        
        method absorb(real amount) -> real {
            Buff current = this.top;
            Buff preserve;
            integer i;
            while (current != 0 && amount > 0.0) {
                if (current.bd.isShield) {
                    // response Absorbed Events
                    AbsorbResult.source = current.bd.caster;
                    AbsorbResult.target = current.bd.target;
                    //logcat(current.bd.toString());
                    AbsorbResult.abilityName = SpellData[current.bd.bt.bid].name;
                    if (current.bd.r0 > amount) {
                        AbsorbResult.amount = amount;
                        
                        current.bd.r0 -= amount;
                        amount = 0.0;
                    } else {
                        AbsorbResult.amount = current.bd.r0;
                        
                        preserve = current.next;
                        amount -= current.bd.r0;
                        this.cancel(current);
                        current.onRemove();
                        current.destroy();
                        current = preserve;
                    }
                    i = 0;
                    while (i < responseAbsorbedN) {
                        responseAbsorbedCallList[i].evaluate();
                        i += 1;
                    }  
                } else {
                    current = current.next;
                }
            }
            if (amount < 2.0) {amount = 0.0;}
            return amount;
        }
        
        method print() {
            Buff current = this.top;
            //BJDebugMsg(GetUnitName(u) + "'s Buff Slot:");
            while (current != 0) {
                //BJDebugMsg(ID2S(current.bd.bt.bid));
                current = current.next;
            }
        }
        
        static method operator[] (unit u) -> thistype {
            thistype this;
            if (!thistype.ht.exists(u)) {
                this = thistype.allocate();
                this.u = u;
                thistype.ht[u] = this;
                this.top = 0;
            } else {
                this = thistype.ht[u];
            }
            return this;
        }
        
        private static method doFlush() {
            thistype this = GetTimerData(GetExpiredTimer());
            this.removeAllBuff();
            ReleaseTimer(this.tm);
            if (!IsUnitType(this.u, UNIT_TYPE_HERO) && !IsUnitDummy(this.u)) {
                thistype.ht.flush(this.u);
            }
            this.u = null;
            this.tm = null;
            this.deallocate();
        }
        
        private method delayedFlush() {
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            TimerStart(this.tm, 0.3, false, function thistype.doFlush);
        }
        
        private static method recycle(unit u) {
            thistype this;
            if (thistype.ht.exists(u)) {
                this = thistype.ht[u];
                this.delayedFlush();
            }
        }     
        
        private static method onInit() {
            thistype.ht = HandleTable.create();
            RegisterUnitDeath(thistype.recycle);
        }
    }
    
    public struct BuffType {
        static Table ht;
        integer bid;
        integer buffCate;
        integer buffPoly;
        
        static method operator[] (integer bid) -> thistype {
            if (!thistype.ht.exists(bid)) {
                BJDebugMsg(SCOPE_PREFIX+">Unknown: " + ID2S(bid));
                return 0;
            } else {
                return thistype.ht[bid];
            }
        }
        
        static method register(integer bid, integer buffCate, integer buffPoly) {
            thistype this;
            if (thistype.ht.exists(bid)) {
                BJDebugMsg(SCOPE_PREFIX+">Double registering: " + ID2S(bid));
            } else {
                this = thistype.allocate();
                thistype.ht[bid] = this;
                this.bid = bid;
                this.buffCate = buffCate;
                this.buffPoly = buffPoly;
            }
        }
        
        private static method onInit() {
            thistype.ht = Table.create();
        }
    }

    
    function onInit() {
        integer i = 0;
        while (i < NUMBER_OF_MAX_PLAYERS) {
            lastStolen[i] = 0;
            i += 1;
        }
    }
}
//! endzinc
