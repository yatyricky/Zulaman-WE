//! zinc
library Frenzy requires SpellEvent, BuffSystem {
#define SPELL_ID 'A03P'
#define BUFF_ID 'A03S'
#define ART_LEFT "Abilities\\Spells\\Orc\\Bloodlust\\BloodlustTarget.mdl"
#define ART_RIGHT "Abilities\\Spells\\Orc\\Bloodlust\\BloodlustSpecial.mdl"
    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].damageDealt += buf.bd.r0;
        UnitProp[buf.bd.target].ModAttackSpeed(buf.bd.i0);
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].damageDealt -= buf.bd.r0;
        UnitProp[buf.bd.target].ModAttackSpeed(0 - buf.bd.i0);
    }
    
    function onCast() {       
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BUFF_ID);
        buf.bd.tick = -1;
        buf.bd.interval = 300;
        UnitProp[buf.bd.target].damageDealt -= buf.bd.r0;
        buf.bd.r0 = 0.3;
        UnitProp[buf.bd.target].ModAttackSpeed(0 - buf.bd.i0);
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
#undef ART_RIGHT
#undef ART_LEFT
#undef BUFF_ID
#undef SPELL_ID
}
//! endzinc
