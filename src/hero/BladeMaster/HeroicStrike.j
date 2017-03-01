//! zinc
library HeroicStrike requires DamageSystem, SpellEvent, OrcCaptureFlag {
    
    public function BladeMasterIsHSOn(unit u) -> boolean {
        return GetUnitAbilityLevel(u, BID_HEROIC_STRIKE) > 0;
    }

    function dispelHeroicStrike(unit u) {
        BuffSlot bs = BuffSlot[u];
        Buff buf = bs.getBuffByBid(BID_HEROIC_STRIKE);
        bs.dispelByBuff(buf);
        buf.destroy();
    }

    function ondamageresponse() {
        real scost = 10.0;
        if (BladeMasterIsHSOn(DamageResult.source) && DamageResult.abilityName == DAMAGE_NAME_MELEE) {
            DamageResult.amount += 40 + GetUnitAbilityLevel(DamageResult.source, SID_HEROIC_STRIKE) * 10;
            if (HasOrcCaptureFlag(DamageResult.source)) {
                scost -= 5.0;
            }
            ModUnitMana(DamageResult.source, 0.0 - scost);
            if (GetUnitMana(DamageResult.source) < scost) {
                dispelHeroicStrike(DamageResult.source);
            }
        }
    }
    
    function level() -> boolean {
        if (GetLearnedSkill() == SID_HEROIC_STRIKE) {
            if (GetUnitAbilityLevel(GetTriggerUnit(), SID_HEROIC_STRIKE) > 2) {
                UnitProp[GetTriggerUnit()].attackCrit += 0.1;
            }
        }
        return false;
    }
    
    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].ModAttackSpeed(buf.bd.i0);
    }
    
    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].ModAttackSpeed(0 - buf.bd.i0);
    }

    function onCast() {           
        Buff buf;
        if (BladeMasterIsHSOn(SpellEvent.CastingUnit)) {
            // deacitvate
            dispelHeroicStrike(SpellEvent.CastingUnit);
        } else {
            // activate
            buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BID_HEROIC_STRIKE);
            buf.bd.interval = 60.0;
            buf.bd.tick = -1;
            UnitProp[buf.bd.target].ModAttackSpeed(0 - buf.bd.i0);
            buf.bd.i0 = 7 + GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_HEROIC_STRIKE) * 3;
            if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_PHOENIX_MISSILE, buf, "weapon");}
            buf.bd.boe = onEffect;
            buf.bd.bor = onRemove;
            buf.run();
        }
    }

    function onInit() {
        RegisterOnDamageEvent(ondamageresponse); // damage
        TriggerAnyUnit(EVENT_PLAYER_HERO_SKILL, function level); // level 3 + 10% crit
        RegisterSpellEffectResponse(SID_HEROIC_STRIKE, onCast); // active
        BuffType.register(BID_HEROIC_STRIKE, BUFF_PHYX, BUFF_POS); // buff registration
    }
}
//! endzinc

