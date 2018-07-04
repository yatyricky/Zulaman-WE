//! zinc
library DamageDeathCoil requires DamageSystem, BuffSystem {
    HandleTable ht;

    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageTaken += buf.bd.r0;
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageTaken -= buf.bd.r0;
    }

    function onHit(Projectile p) -> boolean {
        Buff buf;
        if (TryReflect(p.target)) {
            p.reverse();
            return false;
        } else {
            DamageTarget(p.caster, p.target, p.r0, SpellData.inst(BID_ATK_DEATH_COIL, SCOPE_PREFIX).name, false, true, false, WEAPON_TYPE_WHOKNOWS, false);

            buf = Buff.cast(p.caster, p.target, BID_ATK_DEATH_COIL);
            buf.bd.tick = -1;
            buf.bd.interval = 5.0;
            onRemove(buf);
            buf.bd.r0 = 0.03;
            buf.bd.boe = onEffect;
            buf.bd.bor = onRemove;
            buf.run();
            AddTimedEffect.atUnit(ART_DEATH_COIL_SPECIAL_ART, p.target, "origin", 0.5);
            return true;
        }
    }
    
    function damaged() {
        Projectile p;
        if (DamageResult.isHit == false) return;
        if (DamageResult.abilityName != DAMAGE_NAME_MELEE) return;
        if (ht.exists(DamageResult.source) == false) return;
        if (ht[DamageResult.source] <= 0) return;
        if (IsUnitICD(DamageResult.source, BID_ATK_DEATH_COIL) == true) return;
        if (GetRandomReal(0, 0.999) >= 0.15) return;

        p = Projectile.create();
        p.caster = DamageResult.source;
        p.target = DamageResult.target;
        p.path = ART_DEATH_COIL_MISSILE;
        p.pr = onHit;
        p.speed = 1000;
        p.r0 = UnitProp.inst(p.caster, SCOPE_PREFIX).SpellPower() + 400;
        p.launch();
        
        SetUnitICD(DamageResult.source, BID_ATK_DEATH_COIL, 10);
    }

    public function EquipedDamageDeathCoil(unit u, integer polar) {
        if (ht.exists(u) == false) {
            ht[u] = 0;
        }
        ht[u] = ht[u] + polar;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterDamagedEvent(damaged);
        BuffType.register(BID_ATK_DEATH_COIL, BUFF_MAGE, BUFF_NEG);
    }

}
//! endzinc
