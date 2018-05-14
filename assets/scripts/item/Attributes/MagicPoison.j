//! zinc
library MagicPoison requires Table, BuffSystem {
    HandleTable ht;

    function onEffect(Buff buf) {
        DamageTarget(buf.bd.caster, buf.bd.target, buf.bd.r0, SpellData.inst(SID_VOODOO_VIALS, SCOPE_PREFIX).name, false, true, false, WEAPON_TYPE_WHOKNOWS, false);
        AddTimedEffect.atUnit(ART_POISON, buf.bd.target, "origin", 0.5);
    }

    function onRemove(Buff buf) {}

    function damaged() {
        real amt;
        Buff buf;
        if (DamageResult.isHit == true && DamageResult.isPhyx == false && DamageResult.wasDirect == true) {
            if (ht.exists(DamageResult.source) && ht[DamageResult.source] > 0 && GetRandomReal(0, 0.999) < 0.1) {
                amt = ItemExAttributes.getUnitAttrVal(DamageResult.source, IATTR_MD_POISON, SCOPE_PREFIX);
                amt += UnitProp.inst(DamageResult.source, SCOPE_PREFIX).SpellPower() * 0.05;
                
                buf = Buff.cast(DamageResult.source, DamageResult.target, BID_VOODOO_VIALS);
                buf.bd.interval = 2.0 / (1.0 + UnitProp.inst(buf.bd.caster, SCOPE_PREFIX).SpellHaste());
                buf.bd.tick = Rounding(10.0 / buf.bd.interval);
                buf.bd.r0 = amt;
                buf.bd.boe = onEffect;
                buf.bd.bor = onRemove;
                buf.run();
            }
        }
    }

    public function EquipedMagicPoison(unit u, integer polar) {
        if (ht.exists(u) == false) {
            ht[u] = 0;
        }
        ht[u] = ht[u] + polar;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterDamagedEvent(damaged);
        BuffType.register(BID_VOODOO_VIALS, BUFF_MAGE, BUFF_NEG);
    }

}
//! endzinc
