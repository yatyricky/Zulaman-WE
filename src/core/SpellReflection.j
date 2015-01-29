//! zinc
library SpellReflection requires UnitProperty {
    public type ResponseSpellReflection extends function(unit);
    ResponseSpellReflection responseSpellReflections[];
    integer responseSpellReflectionN = 0;
    
    public function TryReflect(unit u) -> boolean {
        UnitProp up = UnitProp[u];
        integer i;
        if (up.SpellReflect() > 0) {
            AddTimedEffect.atUnit("Abilities\\Spells\\Items\\SpellShieldAmulet\\SpellShieldCaster.mdl", u, "origin", 0.1);            
            up.ModSpellReflect(-1);
            
            i = 0;
            while (i < responseSpellReflectionN) {
                responseSpellReflections[i].evaluate(u);
                i += 1;
            }
            
            return true;
        }
        return false;
    }
    
    public function RegisterSpellReflectionEvent(ResponseSpellReflection rsrr) {
        responseSpellReflections[responseSpellReflectionN] = rsrr;
        responseSpellReflectionN += 1;
    }
}
//! endzinc
