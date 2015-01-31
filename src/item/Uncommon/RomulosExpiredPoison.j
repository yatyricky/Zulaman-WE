//! zinc
library RomulosExpiredPoison requires ItemAttributes {
    HandleTable ht;
    
    function damaged() {
        if (DamageResult.isHit) {
            if (ht.exists(DamageResult.source)) {
                if (ht[DamageResult.source] > 0 && DamageResult.abilityName == DAMAGE_NAME_MELEE) {
                    if (GetRandomInt(0, 99) < 25) {
                        DelayedDamageTarget(DamageResult.source, DamageResult.target, GetRandomReal(80.0, 115.0), "ÂÞÃÜÅ·µÄ¹ýÆÚ¶¾Ò©", false, true, false, WEAPON_TYPE_WHOKNOWS);
                        AddTimedEffect.atUnit(ART_POISON, DamageResult.target, "origin", 0.5);
                    }
                }
            }
        }
    }

    function action(unit u, item it, integer fac) {
        if (!ht.exists(u)) {ht[u] = 0;}
        ht[u] = ht[u] + fac;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterItemPropMod(ITID_ROMULOS_EXPIRED_POISON, action);
        RegisterDamagedEvent(damaged);
    }
}
//! endzinc
