//! zinc
library ArcaneShock requires DamageSystem, BuffSystem, UnitProperty, AggroSystem {
    
    function returnCurseAmt(integer lvl) -> real {
        return 0.04 * lvl;
    }
    
    function returnDamage(integer lvl) -> real {
        return 40.0 * lvl;
    }

    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).attackRate -= buf.bd.r0;
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).attackRate += buf.bd.r0;
    }
    
    function paladinDamaged() {
        real amt;
        if (DamageResult.isHit) {
            if (GetUnitAbilityLevel(DamageResult.source, BID_ARCANE_SHOCK) > 0) {
                amt = DamageResult.amount * 0.1;
                ModUnitMana(DamageResult.target, amt);
                AddTimedEffect.atUnit(ART_ARCANE_TOWER_ATTACK, DamageResult.target, "origin", 0.1);
            }
        }
    }

    function onCast() {
        integer il = GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_ARCANE_SHOCK);
        Buff buf;
        real dmg;
        
        // apply curse
        buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BID_ARCANE_SHOCK);
        buf.bd.tick = -1;
        buf.bd.interval = 5.0;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).attackRate += buf.bd.r0;
        buf.bd.r0 = returnCurseAmt(il);
        if (buf.bd.e0 == 0) {
            buf.bd.e0 = BuffEffect.create(ART_CURSE, buf, "overhead");
        }
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        
        dmg = returnDamage(il) + UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).SpellPower() + UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).AttackPower() * 0.31;
        AddTimedEffect.atUnit(ART_ManaFlareBoltImpact, SpellEvent.TargetUnit, "origin", 0.1);
        DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, dmg, SpellData.inst(SID_ARCANE_SHOCK, SCOPE_PREFIX).name, false, true, false, WEAPON_TYPE_WHOKNOWS, true);
        AggroTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, dmg * 3.0, SCOPE_PREFIX);
    }
    
    function onInit() {
        BuffType.register(BID_ARCANE_SHOCK, BUFF_MAGE, BUFF_NEG);
        RegisterSpellEffectResponse(SID_ARCANE_SHOCK, onCast);
        RegisterDamagedEvent(paladinDamaged);
    }

}
//! endzinc
