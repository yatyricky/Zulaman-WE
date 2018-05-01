//! zinc
library AISpell requires SpellData, CastingBar, TimerUtils {
//==============================================================================
//  boolean:    IsSpellCD(unit whichUnit, integer abilityID)
//  integer:    GetSpellToCast(unit whichUnit)
//==============================================================================
//  AbilityList:
//      AbilityList:    [integer unitTypeID]
//      integer:        locate(integer abilityID)
//      nothing:        add(integer abilityID, integer weight)
//      nothing:        clear()
//      integer:        getRandom(unit whichUnit)
//==============================================================================
    constant integer ESTIMATED_MAX_ABILITIES = 32;
    
    public function IsSpellCD(unit u, integer aid) -> boolean {
        return !UnitSpells(UnitSpells.ht[u]).spellCDs.exists(aid);
    }

    public struct AbilityList {
        private static Table tab;
        private integer list[ESTIMATED_MAX_ABILITIES];
        private integer weight[ESTIMATED_MAX_ABILITIES];
        private integer size;
        private integer sum;
        
        static method operator[](integer utid) -> thistype {
            thistype this;
            if (thistype.tab.exists(utid)) {
                this = thistype.tab[utid];
            } else {
                this = thistype.allocate();
                thistype.tab[utid] = this;
                this.size = 0;
                this.sum = 0;
            }
            return this;
        }
        
        method locate(integer aid) -> integer {
            integer i = 0;
            while (i < this.size) {
                if (this.list[i] == aid) {
                    return i;
                }
                i += 1;
            }
            return -1;
        }
        
        method add(integer aid, integer weight) {
            integer index = this.locate(aid);
            if (index == -1) {
                this.list[this.size] = aid;
                this.weight[this.size] = weight;
                this.size += 1;
                this.sum += weight;
            } else {
                this.sum = this.sum - this.weight[index] + weight;
                this.weight[index] = weight;
            }
        }
        
        method clear() {
            this.size = 0;
            this.sum = 0;
        }
        
        method getRandom(unit u) -> integer {
            integer r;
            integer i;
            integer a;
            integer s;
            if (this.size == 0) {
                return 0;
            }
            i = 0;
            s = 0;
            while (i < this.size) {
                if (IsSpellCD(u, this.list[i])) {
                    s += this.weight[i];
                }
                i += 1;
            }
            //BJDebugMsg("sum of s=" + I2S(s));
            if (s == 0) {
                return 0;
            }
            r = GetRandomInt(0, s - 1);
            a = 0;
            i = 0;
            //BJDebugMsg("r=" + I2S(r));
            while (i < this.size) {
                if (IsSpellCD(u, this.list[i])) {
                    a += this.weight[i];
                    //BJDebugMsg("sum of a=" + I2S(a));
                    if (r < a) {
                        return this.list[i];
                    }
                }
                i += 1;
            }
            //debug BJDebugMsg("|cffff0000FATAL ERROR: AIAbilityCD|r - pool failed" + ", r=" + I2S(r) + ", a=" + I2S(a) + ", sum=" + I2S(this.sum));
            return 0;
        }
        
        private static method onInit() {
            thistype.tab = Table.create();
        }
    }

    struct SpellCDRun {
        private Table tab;
        private integer aid;
        private timer tm;
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            this.tab.flush(this.aid);
            ReleaseTimer(this.tm);
            this.tm = null;
            this.deallocate();
        }
    
        static method create(Table forWhich, integer aid) -> thistype {
            thistype this = thistype.allocate();
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.tab = forWhich;
            this.aid = aid;
            TimerStart(this.tm, SpellData[aid].cd, false, function thistype.run);
            return this;
        }
    }
    
    struct UnitSpells {
        static HandleTable ht;
        Table spellCDs;
    
        static method new(unit u, integer aid) {
            thistype this;
            if (thistype.ht.exists(u)) {
                this = thistype.ht[u];
            } else {
                this = thistype.allocate();
                this.spellCDs = Table.create();
                thistype.ht[u] = this;
            }
            if (!this.spellCDs.exists(aid)) {
                this.spellCDs[aid] = SpellCDRun.create(this.spellCDs, aid);
            }
        }
        
        private static method onInit() {
            thistype.ht = HandleTable.create();
        }
    }
    
    public function GetSpellToCast(unit u) -> integer {
        integer aid;
        if (!IsUnitChanneling(u)) {
            aid = AbilityList[GetUnitTypeId(u)].getRandom(u);
            if (aid > 0) {
                if (GetUnitState(u, UNIT_STATE_MANA) > SpellData[aid].cost) {
                    return aid;
                }
            }
        }
        return 0;
    }

    function spellEndCast() {
        if (IsLastSpellSuccess(SpellEvent.CastingUnit) && SpellData[SpellEvent.AbilityId].cd > 0.0) {
            UnitSpells.new(SpellEvent.CastingUnit, SpellEvent.AbilityId);
        }
    }

    function onInit() {
        RegisterSpellEndCastResponse(0, spellEndCast);        
    }
}
//! endzinc
