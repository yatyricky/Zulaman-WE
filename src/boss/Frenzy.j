//! zinc
library Frenzy requires SpellEvent, BuffSystem {
constant integer SPELL_ID = 'A03P';
constant integer BUFF_ID = 'A03S';
constant string  ART_LEFT  = "Abilities\\Spells\\Orc\\Bloodlust\\BloodlustTarget.mdl";
constant string  ART_RIGHT  = "Abilities\\Spells\\Orc\\Bloodlust\\BloodlustSpecial.mdl";
    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageDealt += buf.bd.r0;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAttackSpeed(buf.bd.i0);
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageDealt -= buf.bd.r0;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAttackSpeed(0 - buf.bd.i0);
    }
    
    function onCast() {       
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BUFF_ID);
        buf.bd.tick = -1;
        buf.bd.interval = 300;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageDealt -= buf.bd.r0;
        buf.bd.r0 = 0.3;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAttackSpeed(0 - buf.bd.i0);
        buf.bd.i0 = 50;
        if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_LEFT, buf, "hand, left");}
        if (buf.bd.e1 == 0) {buf.bd.e1 = BuffEffect.create(ART_RIGHT, buf, "hand, right");}
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }

    function onInit() {
        RegisterSpellEffectResponse(SPELL_ID, onCast);
        BuffType.register(BUFF_ID, BUFF_PHYX, BUFF_POS);
    }




}
//! endzinc
