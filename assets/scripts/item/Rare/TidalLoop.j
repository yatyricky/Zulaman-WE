//! zinc
library TidalLoop requires BuffSystem, DamageSystem {

    HandleTable ht;
    
    function damaged() {
        if (DamageResult.isHit == false) return;
        if (DamageResult.isPhyx == true) return;
        if (DamageResult.wasDirect == false) return;
        if (ht.exists(DamageResult.source) == false) return;
        if (ht[DamageResult.source] <= 0) return;
        if (IsUnitICD(DamageResult.source, ITID_TIDAL_LOOP) == true) return;
        if (GetRandomReal(0, 0.999) > 0.01) return;

        ModUnitMana(DamageResult.source, ItemExAttributes.getUnitAttrVal(DamageResult.source, IATTR_MD_MREGEN, SCOPE_PREFIX));
        AddTimedEffect.atUnit(ART_MANA, DamageResult.source, "origin", 1.0);

        SetUnitICD(DamageResult.source, ITID_TIDAL_LOOP, 10);
    }
    
    function healed() {
        if (HealResult.wasDirect == false) return;
        if (ht.exists(HealResult.source) == false) return;
        if (ht[HealResult.source] <= 0) return;
        if (IsUnitICD(HealResult.source, ITID_TIDAL_LOOP) == true) return;
        if (GetRandomReal(0, 0.999) > 0.01) return;

        ModUnitMana(HealResult.source, ItemExAttributes.getUnitAttrVal(HealResult.source, IATTR_MD_MREGEN, SCOPE_PREFIX));
        AddTimedEffect.atUnit(ART_MANA, HealResult.source, "origin", 1.0);

        SetUnitICD(HealResult.source, ITID_TIDAL_LOOP, 10);
    }

    public function EquipedTidalLoop(unit u, integer polar) {
        if (ht.exists(u) == false) {
            ht[u] = 0;
        }
        ht[u] = ht[u] + polar;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterDamagedEvent(damaged);
        RegisterHealedEvent(healed);
    }
}
//! endzinc
