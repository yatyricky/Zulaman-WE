//! zinc
library OneshotLowHealth requires BuffSystem, DamageSystem {
    HandleTable ht;

    function damaged() {
        if (DamageResult.isHit == false) return;
        if (ht.exists(DamageResult.source) == false) return;
        if (ht[DamageResult.source] <= 0) return;
        if (GetWidgetLife(DamageResult.source) <= GetWidgetLife(DamageResult.target)) return;

        KillUnit(DamageResult.target);
    }

    public function EquipedOneshotLowHealth(unit u, integer polar) {
        if (ht.exists(u) == false) {
            ht[u] = 0;
        }
        ht[u] = ht[u] + polar;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterDamagedEvent(damaged);
    }

}
//! endzinc
