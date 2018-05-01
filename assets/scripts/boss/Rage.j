//! zinc
library Rage requires SpellEvent, BuffSystem {
constant integer SPELL_ID = 'A03Q';
constant integer BUFF_ID = 'A03T';
constant string  ART  = "Abilities\\Spells\\Undead\\UnholyFrenzy\\UnholyFrenzyTarget.mdl";
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
        buf.bd.r0 = 5.0;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAttackSpeed(0 - buf.bd.i0);
        buf.bd.i0 = 150;
        if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART, buf, "overhead");}
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
