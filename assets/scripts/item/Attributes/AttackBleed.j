//! zinc
library AttackBleed requires BuffSystem, DamageSystem {

    HandleTable ht;

    function onEffect(Buff buf) {
        DamageTarget(buf.bd.caster, buf.bd.target, buf.bd.r0, SpellData.inst(BID_BLEED, SCOPE_PREFIX).name, true, false, false, WEAPON_TYPE_WHOKNOWS, false);
        AddTimedEffect.atUnit(ART_BLEED, buf.bd.target, "origin", 0.2);
    }

    function damaged() {
        Buff buf;
        real newDmg;
        if (DamageResult.isHit == false) return;
        if (DamageResult.abilityName != DAMAGE_NAME_MELEE) return;
        if (ht.exists(DamageResult.source) == false) return;
        if (ht[DamageResult.source] <= 0) return;
        if (GetRandomReal(0, 0.99999) >= 0.2) return;

        newDmg = ItemExAttributes.getUnitAttrVal(DamageResult.source, IATTR_ATK_BLEED, SCOPE_PREFIX);

        buf = Buff.cast(DamageResult.source, DamageResult.target, BID_BLEED);
        buf.bd.interval = 2.0 / (1 + UnitProp.inst(DamageResult.source, SCOPE_PREFIX).AttackSpeed() / 200.0 + UnitProp.inst(DamageResult.source, SCOPE_PREFIX).SpellHaste() * 0.5);
        buf.bd.tick = Rounding(10 / buf.bd.interval);
        if (buf.bd.r0 < newDmg) {
            buf.bd.r0 = newDmg;
        }
        buf.bd.boe = onEffect;
        buf.bd.bor = Buff.noEffect;
        buf.run();
        
        AddTimedEffect.atUnit(ART_BLEED, DamageResult.target, "origin", 0.2);
    }

    public function EquipedAttackBleed(unit u, integer polar) {
        if (ht.exists(u) == false) {
            ht[u] = 0;
        }
        ht[u] = ht[u] + polar;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterDamagedEvent(damaged);
        BuffType.register(BID_BLEED, BUFF_PHYX, BUFF_NEG);
    }

}
//! endzinc
