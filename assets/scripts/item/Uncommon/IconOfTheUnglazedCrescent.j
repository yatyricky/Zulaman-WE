//! zinc
library IconOfTheUnglazedCrescent requires BuffSystem, DamageSystem {

    HandleTable ht;

    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModInt(buf.bd.i0);
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModInt(0 - buf.bd.i0);
    }
    
    function damaged() {
        Buff buf;
        if (DamageResult.isHit == false) return;
        if (DamageResult.isPhyx == true) return;
        if (ht.exists(DamageResult.source) == false) return;
        if (ht[DamageResult.source] <= 0) return;
        if (IsUnitICD(DamageResult.source, BID_ICON_OF_THE_UNGLAZED_CRESCENT) == true) return;
        if (GetRandomReal(0, 0.99999) >= 0.15) return;

        buf = Buff.cast(DamageResult.source, DamageResult.source, BID_ICON_OF_THE_UNGLAZED_CRESCENT);
        buf.bd.tick = -1;
        buf.bd.interval = 15.0;
        onRemove(buf);
        buf.bd.i0 = Rounding(ItemExAttributes.getUnitAttrVal(DamageResult.source, IATTR_USE_INT, SCOPE_PREFIX));
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();

        SetUnitICD(DamageResult.source, BID_ICON_OF_THE_UNGLAZED_CRESCENT, 45);
        AddTimedEffect.atUnit(ART_INTELLIGENCE, DamageResult.source, "origin", 0.5);
    }

    public function EquipedUnglazedCrescent(unit u, integer polar) {
        if (ht.exists(u) == false) {
            ht[u] = 0;
        }
        ht[u] = ht[u] + polar;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterDamagedEvent(damaged);
        BuffType.register(BID_ICON_OF_THE_UNGLAZED_CRESCENT, BUFF_MAGE, BUFF_POS);
    }

}
//! endzinc
