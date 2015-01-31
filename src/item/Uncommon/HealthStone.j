//! zinc
library HealthStone requires ItemAttributes {
    //HandleTable ht;

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        up.lifeRegen += 5 * fac;
        //if (!ht.exists(u)) {ht[u] = 0;}
        //ht[u] = ht[u] + fac;
    }
    
    function onCast() {
        HealTarget(SpellEvent.CastingUnit, SpellEvent.CastingUnit, GetRandomReal(300.0, 600.0), SpellData[SID_HEALTH_STONE].name, 0.0);
        AddTimedEffect.atUnit(ART_HEAL, SpellEvent.CastingUnit, "origin", 1.0);
    }

    function onInit() {
        //ht = HandleTable.create();
        RegisterItemPropMod(ITID_HEALTH_STONE, action);
        RegisterSpellEffectResponse(SID_HEALTH_STONE, onCast);
    }
}
//! endzinc
