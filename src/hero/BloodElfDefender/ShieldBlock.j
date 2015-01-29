//! zinc
library ShieldBlock requires BuffSystem, DamageSystem, SpellEvent, UnitProperty, AggroSystem {
#define BUFF_ID 'A023'
#define ART_CASTER "Abilities\\Spells\\Items\\SpellShieldAmulet\\SpellShieldCaster.mdl"
#define ART_REFLECTION "Abilities\\Spells\\NightElf\\ThornsAura\\ThornsAuraDamage.mdl"

    // 0.0~1.0
    function returnBlockRate(integer lvl) -> real {
        return 0.3 + lvl * 0.15;
    }

    // multiply with block points
    function returnBlockPointsAmp(integer lvl) -> real {
        return 1.5 + lvl * 0.5;
    }

    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].blockRate += buf.bd.r0;
        UnitProp[buf.bd.target].ModSpellReflect(1);
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].blockRate -= buf.bd.r0;
        UnitProp[buf.bd.target].spellReflect -= 1;
        if (UnitProp[buf.bd.target].spellReflect < 0) {
            UnitProp[buf.bd.target].spellReflect = 0;
        }
    }
    
    function paladinHitted() {
        Buff buf = BuffSlot[DamageResult.target].getBuffByBid(BUFF_ID);
        if (buf != 0 && DamageResult.isBlocked) {
            if (GetDistance.units2d(DamageResult.source, DamageResult.target) < 200.0) {
                //BJDebugMsg("Exe once!!!");
                DelayedDamageTarget(DamageResult.target, DamageResult.source, buf.bd.r1, SpellData[SIDSHIELDBLOCK].name, false, false, false, WEAPON_TYPE_WHOKNOWS);
                AddTimedEffect.atUnit(ART_REFLECTION, DamageResult.source, "origin", 0.5);   
                AggroTarget(DamageResult.target, DamageResult.source, buf.bd.r1 * 7.0);
            } else {
                //BJDebugMsg("Too far away");
            }
        }
        //DamageResult.display();
    }

    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BUFF_ID);
        buf.bd.tick = -1;
        buf.bd.interval = 5.0;
        buf.bd.i0 = GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDSHIELDBLOCK);
        UnitProp[SpellEvent.CastingUnit].blockRate -= buf.bd.r0;
        buf.bd.r0 = returnBlockRate(buf.bd.i0);
		buf.bd.r1 = UnitProp[buf.bd.target].BlockPoint() * returnBlockPointsAmp(buf.bd.i0);
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        AddTimedEffect.atUnit(ART_CASTER, SpellEvent.CastingUnit, "origin", 0.1);   
    }
    
    function onInit() {
        BuffType.register(BUFF_ID, BUFF_PHYX, BUFF_POS);
        RegisterSpellEffectResponse(SIDSHIELDBLOCK, onCast);
        RegisterDamagedEvent(paladinHitted);
    }
    
#undef ART_REFLECTION
#undef ART_CASTER
#undef BUFF_ID
}
//! endzinc
