//! zinc
library NagaFrenzy requires SpellEvent, BuffSystem {
constant integer BUFF_ID = 'A09V';
constant string  ART  = "Abilities\\Spells\\Undead\\UnholyFrenzy\\UnholyFrenzyTarget.mdl";
    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAttackSpeed(buf.bd.i0);
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAttackSpeed(0 - buf.bd.i0);
    }
    
    function onCast() {       
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BUFF_ID);
        buf.bd.tick = -1;
        buf.bd.interval = 10;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAttackSpeed(0 - buf.bd.i0);
        buf.bd.i0 = 100;
        if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART, buf, "overhead");}
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_NAGA_FRENZY, onCast);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
    }


}
//! endzinc
