//! zinc
library MultipleAbility requires Table, Integer, SpellEvent {
    public boolean SystemOrderIndicator = false;
    
    public struct MultipleAbility {
        static Table ht;
        integer primary;
        integer secondary;
        integer tertiary;
        
        method setTertiary(integer tertiary) {
            this.tertiary = tertiary;
        }
        
        method showPrimary(player p) {
            SetPlayerAbilityAvailable(p, this.secondary, false);
            SetPlayerAbilityAvailable(p, this.primary, true);
            ForceUICancelBJ(p);
        }
        
        method showSecondary(player p) {
            SetPlayerAbilityAvailable(p, this.primary, false);
            SetPlayerAbilityAvailable(p, this.secondary, true);
            ForceUICancelBJ(p);
        }
        
        static method register(integer primary, integer secondary) {
            thistype this;
            if (!thistype.ht.exists(primary)) {
                this = thistype.allocate();
                thistype.ht[primary] = this;
                this.primary = primary;
                this.secondary = secondary;
            }
        }
        
        static method operator[] (integer primary) -> thistype {
            if (!thistype.ht.exists(primary)) {
                BJDebugMsg(SCOPE_PREFIX+">Unregistered primary ability: " + ID2S(primary));
                return 0;
            } else {
                return thistype.ht[primary];
            }
        }
        
        static method syncro() -> boolean {
            integer aid = GetLearnedSkill();
            if (thistype.ht.exists(aid)) {
                SetUnitAbilityLevel(GetTriggerUnit(), thistype(thistype.ht[aid]).secondary, GetUnitAbilityLevel(GetTriggerUnit(), aid));
            }
            return false;
        }
        
        private static method recoverIndicator() -> boolean {
            //integer ioid = GetIssuedOrderId();
            //if (!SystemOrderIndicator) {
            //    if (ioid == OID_FROSTARMORON) {
            //        IssueImmediateOrderById(GetTriggerUnit(), OID_FROSTARMOROFF);
            //    } else if (ioid == OID_FROSTARMOROFF) {
            //        IssueImmediateOrderById(GetTriggerUnit(), OID_FROSTARMORON);
            //    }
            //}
            return false;
        }
        
        static method onInit() {
            trigger trig = CreateTrigger();
            thistype.ht = Table.create();
            TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_HERO_SKILL);
            TriggerAddCondition(trig, Condition(function thistype.syncro));
            TriggerAnyUnit(EVENT_PLAYER_UNIT_ISSUED_ORDER, function thistype.recoverIndicator);
        }
    }
}
//! endzinc
