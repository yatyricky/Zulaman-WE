//! zinc
library FrostShock requires SpellReflection {
constant integer BUFF_ID = 'A096';
constant string  ART_FROST  = "Abilities\\Spells\\Other\\FrostDamage\\FrostDamage.mdl";
constant string  ART_TARGET  = "Abilities\\Weapons\\FrostWyrmMissile\\FrostWyrmMissile.mdl";
    
    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModSpeed(0 - buf.bd.i0);
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAttackSpeed(0 - buf.bd.i1);
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).spellHaste -= buf.bd.r0;
    }
    
    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModSpeed(buf.bd.i0);
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAttackSpeed(buf.bd.i1);
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).spellHaste += buf.bd.r0;
    }

    function onCast() {
        Buff buf;
        unit tmp;
        if (TryReflect(SpellEvent.TargetUnit)) {
            tmp = SpellEvent.TargetUnit;
            SpellEvent.TargetUnit = SpellEvent.CastingUnit;
            SpellEvent.CastingUnit = tmp;
        }
        AddTimedEffect.atUnit(ART_TARGET, SpellEvent.TargetUnit, "origin", 0.0);
        
        DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, 200.0, SpellData.inst(SID_FROST_SHOCK, SCOPE_PREFIX).name, false, true, false, WEAPON_TYPE_WHOKNOWS);   
        
        buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BUFF_ID);
        buf.bd.tick = -1;
        buf.bd.interval = 5.0;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModSpeed(buf.bd.i0);
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAttackSpeed(buf.bd.i1);
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).spellHaste += buf.bd.r0;
        buf.bd.i0 = Rounding(UnitProp.inst(buf.bd.target, SCOPE_PREFIX).Speed() * 0.3);
        buf.bd.i1 = 20;
        buf.bd.r0 = 0.2;
        if (buf.bd.e0 == 0) {
            buf.bd.e0 = BuffEffect.create(ART_FROST, buf, "origin");
        }
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_FROST_SHOCK, onCast);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_NEG);
    }



}
//! endzinc
