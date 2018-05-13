//! zinc
library CursedCuirass requires BuffSystem, DamageSystem {
    HandleTable ht;
    
    function onEffect(Buff buf) {}

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAP(buf.bd.i1);
    }
    
    function damaged() {
        Buff buf;
        integer amt;
        if (DamageResult.isHit == false) return;
        if (DamageResult.abilityName != DAMAGE_NAME_MELEE) return;
        if (ht.exists(DamageResult.target) == false) return;
        if (ht[DamageResult.target] <= 0) return;

        buf = Buff.cast(DamageResult.target, DamageResult.source, BID_ARMOR_OF_THE_DAMNED);
        buf.bd.tick = -1;
        buf.bd.interval = 5;
        amt = Rounding(ItemExAttributes.getUnitAttributeValue(buf.bd.caster, IATTR_ATKED_WEAK, 0.2, SCOPE_PREFIX));
        if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_HOWL_TARGET, buf, "overhead");}
        if (buf.bd.i0 == 0) {
            buf.bd.i0 = 17;
            UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAP(0 - amt);
            buf.bd.i1 = amt;
        } else {
            if (amt > buf.bd.i1) {
                UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAP(buf.bd.i1 - amt);
                buf.bd.i1 = amt;
            }
        }
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }

    public function EquipedCursedCuirass(unit u, integer polar) {
        if (ht.exists(u) == false) {
            ht[u] = 0;
        }
        ht[u] = ht[u] + polar;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterDamagedEvent(damaged);
        BuffType.register(BID_ARMOR_OF_THE_DAMNED, BUFF_MAGE, BUFF_NEG);
    }

}
//! endzinc
