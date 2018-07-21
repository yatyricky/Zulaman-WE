//! zinc
library ArcanePotion requires SpellEvent, BuffSystem, DamageSystem, Projectile {

    HandleTable ht;

    function onhit(Projectile p) -> boolean {
        DamageTarget(p.caster, p.target, p.r0, SpellData.inst(SID_ARCANE_POTION, SCOPE_PREFIX).name, false, true, false, WEAPON_TYPE_WHOKNOWS, false);
        return true;
    }
    
    function damaged() {
        Projectile p;
        real amt;
        if (DamageResult.isHit == false) return;
        if (DamageResult.isPhyx == true) return;
        if (DamageResult.wasDirect == false) return;
        if (ht.exists(DamageResult.source) == false) return;
        if (ht[DamageResult.source] <= 0) return;
        if (IsUnitICD(DamageResult.source, SID_ARCANE_POTION) == true) return;
        if (GetRandomReal(0, 0.99999) >= 0.1) return;

        amt = ItemExAttributes.getUnitAttrVal(DamageResult.source, IATTR_MD_ARCANE, SCOPE_PREFIX);
        amt += UnitProp.inst(DamageResult.source, SCOPE_PREFIX).SpellPower() * 0.3;

        p = Projectile.create();
        p.caster = DamageResult.source;
        p.target = DamageResult.target;
        p.path = ART_OrbCorruptionMissile;
        p.pr = onhit;
        p.r0 = amt;
        p.speed = 900;
        p.launch();

        SetUnitICD(DamageResult.source, SID_ARCANE_POTION, 3);
    }

    public function EquipedArcanePotion(unit u, integer polar) {
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
