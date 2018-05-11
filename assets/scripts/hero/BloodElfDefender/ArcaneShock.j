//! zinc
library ArcaneShock requires DamageSystem, BuffSystem, UnitProperty, AggroSystem {
constant integer BUFF_ID = 'A025';
//constant integer BUFF_ID1 = 'A02D';
//constant integer BUFF_ID2 = 'A02H';
constant string  ART_TARGET  = "Abilities\\Spells\\Human\\ManaFlare\\ManaFlareBoltImpact.mdl";
//constant string  ART_IMPROVED  = "Abilities\\Spells\\Human\\MagicSentry\\MagicSentryCaster.mdl";
    
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
    
    //function onEffect1(Buff buf) {}
    //function onRemove1(Buff buf) {}

    //function onEffect2(Buff buf) {
    //    ModUnitMana(buf.bd.caster, 20.0);
    //}

    //function onRemove2(Buff buf) {}
    
    //function paladinHitted() {
    //    Buff buf;
    //    if (DamageResult.isBlocked || DamageResult.isDodged) {
    //        if (GetUnitAbilityLevel(DamageResult.target, SID_ARCANE_SHOCK) > 0) {
    //            buf = Buff.cast(DamageResult.target, DamageResult.target, BUFF_ID1);
    //            buf.bd.tick = -1;
    //            buf.bd.interval = 5.0;
    //            if (buf.bd.e0 == 0) {
    //                buf.bd.e0 = BuffEffect.create(ART_IMPROVED, buf, "overhead");
    //            }
    //            buf.bd.boe = onEffect1;
    //            buf.bd.bor = onRemove1;
    //            buf.run();
    //        }
    //    }
    //}
    
    function paladinDamaged() {
        real amt;
        if (DamageResult.isHit) {
            if (GetUnitAbilityLevel(DamageResult.source, BUFF_ID) > 0) {
                amt = DamageResult.amount * 0.1;
                if (GetUnitAbilityLevel(DamageResult.target, 'A023') > 0) {
                    amt *= 2.0;
                }
                ModUnitMana(DamageResult.target, amt);
                AddTimedEffect.atUnit(ART_ARCANE_TOWER_ATTACK, DamageResult.target, "origin", 0.1);
            }
        }
    }

    function onCast() {
        integer il = GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_ARCANE_SHOCK);        
        Buff buf;
        //BuffSlot bs;
        unit tmp;
        real dmg;        
        if (TryReflect(SpellEvent.TargetUnit)) {
            tmp = SpellEvent.TargetUnit;
            SpellEvent.TargetUnit = SpellEvent.CastingUnit;
            SpellEvent.CastingUnit = tmp;
        }
        
        // apply curse
        buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BUFF_ID);
        buf.bd.tick = -1;
        buf.bd.interval = 5.0;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).attackRate += buf.bd.r0;
        buf.bd.r0 = returnCurseAmt(il);
        if (buf.bd.e0 == 0) {
            buf.bd.e0 = BuffEffect.create(ART_CURSE, buf, "overhead");
        }
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();              // level > 1, curse on cast
        
        dmg = returnDamage(il) + UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).SpellPower() + UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).AttackPower() * 0.31;
        //bs = BuffSlot[SpellEvent.CastingUnit];
        //buf = bs.getBuffByBid(BUFF_ID1);
        //if (buf != 0) {
        //    dmg *= 1.75;
        //    bs.dispelByBuff(buf);
        //    buf.destroy();            

        //    buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BUFF_ID2);
        //    buf.bd.tick = 5;
        //    buf.bd.interval = 1.0;
        //    buf.bd.boe = onEffect2;
        //    buf.bd.bor = onRemove2;
        //    buf.run();
        //}
        AddTimedEffect.atUnit(ART_TARGET, SpellEvent.TargetUnit, "origin", 0.1);
        DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, dmg, SpellData.inst(SID_ARCANE_SHOCK, SCOPE_PREFIX).name, false, true, false, WEAPON_TYPE_WHOKNOWS);
        AggroTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, dmg * 3.0, SCOPE_PREFIX);
        tmp = null;
    }
    
    function onInit() {
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_NEG);
        //BuffType.register(BUFF_ID1, BUFF_PHYX, BUFF_POS);
        //BuffType.register(BUFF_ID2, BUFF_MAGE, BUFF_POS);
        RegisterSpellEffectResponse(SID_ARCANE_SHOCK, onCast);
        RegisterDamagedEvent(paladinDamaged);
    }
    
//

//
//

}
//! endzinc
