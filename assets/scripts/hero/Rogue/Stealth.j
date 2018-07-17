//! zinc
library Stealth requires AggroSystem, SpellEvent, UnitProperty, DamageSystem {

    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageDealt += buf.bd.r0;
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageDealt -= buf.bd.r0;
    }

    function removeAPIV(DelayTask dt) {
        UnitRemoveAbility(dt.u0, SID_APIV);
    }
    
    function unstealth(unit u) {
        Buff buf;
        DelayTask.create(removeAPIV, 0.001).u0 = u;
        UnitProp.inst(u, SCOPE_PREFIX).ModSpeed(-120);
        NFSetPlayerAbilityIcon(GetOwningPlayer(u), SID_SINISTER_STRIKE, BTNSacrifice);
        
        if (!IsUnitDead(u)) {
            buf = Buff.cast(u, u, BID_STEALTH_AMP);
            buf.bd.tick = -1;
            buf.bd.interval = 10;
            UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageDealt -= buf.bd.r0;
            buf.bd.r0 = 0.3;
            if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_AVENGER_MISSILE, buf, "hand, left");}
            if (buf.bd.e1 == 0) {buf.bd.e1 = BuffEffect.create(ART_AVENGER_MISSILE, buf, "hand, left");}
            buf.bd.boe = onEffect;
            buf.bd.bor = onRemove;
            buf.run();
        }
    }
    
    function stealth(unit u) {
        if (IsInCombat()) {
            MobList.setForAll(u, 0.1);
        }

        if (GetUnitAbilityLevel(u, SID_APIV) == 0) {
            UnitAddAbility(u, SID_APIV);
            UnitProp.inst(u, SCOPE_PREFIX).ModSpeed(120);
            NFSetPlayerAbilityIcon(GetOwningPlayer(u), SID_SINISTER_STRIKE, BTNImprovedSinisterStrike);
            AddTimedEffect.atCoord(ART_CloudOfFog, GetUnitX(u), GetUnitY(u), 1.0);
        }
    }

    function onCast() {
        stealth(SpellEvent.CastingUnit);
    }
    
    function attacked() -> boolean {
        unit u = null;
        if (GetUnitAbilityLevel(GetAttacker(), SID_APIV) > 0 && GetUnitAbilityLevel(GetAttacker(), SID_STEALTH) > 0) {
            u = GetAttacker();
        } else if (GetUnitAbilityLevel(GetTriggerUnit(), SID_APIV) > 0 && GetUnitAbilityLevel(GetTriggerUnit(), SID_STEALTH) > 0) {
            u = GetTriggerUnit();
        }
        if (u != null) {
            unstealth(u);
        }
        u = null;
        return false;
    }
    
    function onCastAnySpell() {
        if (GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_APIV) > 0 && GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_STEALTH) > 0) {
            unstealth(SpellEvent.CastingUnit);
        }
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_STEALTH, onCast);
        RegisterSpellEffectResponse(0, onCastAnySpell);
        BuffType.register(BID_STEALTH_AMP, BUFF_PHYX, BUFF_POS);
        TriggerAnyUnit(EVENT_PLAYER_UNIT_ATTACKED, function attacked);
    }

}
//! endzinc
