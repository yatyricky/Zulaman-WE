//! zinc
library TidalLoop requires ItemAttributes {
    HandleTable ht;
    
    function damaged() {
        if (DamageResult.isHit) {
            if (ht.exists(DamageResult.source)) {
                if (ht[DamageResult.source] > 0 && !DamageResult.isPhyx) {
                    if (GetRandomInt(0, 99) < 1) {
                        ModUnitMana(DamageResult.source, 100.0);
                        AddTimedEffect.atUnit(ART_MANA, DamageResult.source, "origin", 1.0);
                    }
                }
            }
        }
    }
    
    function healed() {
        if (ht.exists(HealResult.source)) {
            if (ht[HealResult.source] > 0) {
                if (HealResult.abilityName != SpellData[SIDATTACKLL].name) {
                    if (GetRandomInt(0, 99) < 1) {
                        ModUnitMana(HealResult.source, 100.0);
                        AddTimedEffect.atUnit(ART_MANA, HealResult.source, "origin", 1.0);
                    }
                }
            }
        }
    }

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        up.ModStr(10 * fac);
        up.ModInt(15 * fac);
        up.manaRegen += 6 * fac;
        if (!ht.exists(u)) {ht[u] = 0;}
        ht[u] = ht[u] + fac;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterItemPropMod(ITID_TIDAL_LOOP, action);
        RegisterDamagedEvent(damaged);
        RegisterHealedEvent(healed);
    }
}
//! endzinc
