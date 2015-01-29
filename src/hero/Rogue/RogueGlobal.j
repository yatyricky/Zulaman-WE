//! zinc
library RogueGlobal requires Table, ZAMCore {
    public struct ComboPoints {
        private static HandleTable ht;
        integer n;
        unit target;
        
        static method operator[] (unit u) -> thistype {
            thistype this;
            if (!thistype.ht.exists(u)) {
                this = thistype.allocate();
                this.n = 0;
                this.target = null;
                thistype.ht[u] = this;
            }
            return thistype.ht[u];
        }
        
        method isTarget(unit tar) -> boolean {
            return this.target == tar;
        }
        
        method add(unit tar, integer i) {
            texttag tt = CreateTextTag();
            if (!this.isTarget(tar)) {
                this.n = 0;                
            }
            this.target = tar;
            this.n += i;
            if (this.n > 5) {
                this.n = 5;
            }
            
            SetTextTagText(tt, "|cffffcc00" + I2S(this.n) + "连击|r", 0.024);
            SetTextTagPos(tt, GetUnitX(this.target)-5.5, GetUnitY(this.target), 16);
            SetTextTagVelocity(tt, -0.05, 0.05);
            SetTextTagVisibility(tt, true);
            SetTextTagFadepoint(tt, 1.0);
            SetTextTagLifespan(tt, 2.0);
            SetTextTagPermanent(tt, false);
            tt = null;
        }
        
        method get() -> integer {
            integer j = this.n;
            this.n = 0;
            return j;
        }
        
        private static method onInit() {
            thistype.ht = HandleTable.create();
        }
    }
    
    function responseenteredmap(unit u) {
        player p = null;
        if (GetUnitTypeId(u) == UTIDROGUE) {
            p = GetOwningPlayer(u);
            SetPlayerAbilityAvailable(p, SIDGARROTE, false);
            SetPlayerAbilityAvailable(p, SIDAMBUSH, false);
            p  = null;
        }
    }
    
    function onInit() {
        RegisterUnitEnterMap(responseenteredmap);
    }
}
//! endzinc
