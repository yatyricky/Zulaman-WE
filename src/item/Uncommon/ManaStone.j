//! zinc
library ManaStone requires ItemAttributes {
    //HandleTable ht;

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        up.manaRegen += 4 * fac;
        //if (!ht.exists(u)) {ht[u] = 0;}
        //ht[u] = ht[u] + fac;
    }
    
    function onCast() {
        ModUnitMana(SpellEvent.CastingUnit, GetRandomReal(200.0, 400.0));
        AddTimedEffect.atUnit(ART_MANA, SpellEvent.CastingUnit, "origin", 1.0);
    }

    function onInit() {
        //ht = HandleTable.create();
        RegisterItemPropMod(ITID_MANA_STONE, action);
        RegisterSpellEffectResponse(SID_MANA_STONE, onCast);
    }
}
//! endzinc
