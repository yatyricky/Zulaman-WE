//! zinc
library RabiesHex requires MangleHex {
#define BUFF_ID 'A05V'
    function RabiesOnEffect(Buff buf) {
        real dmg = 200.0;
        if (BuffSlot[buf.bd.target].getBuffByBid(MANGLEHEX_BUFF_ID) != 0) {
            dmg *= 2.0;
        }
        DamageTarget(buf.bd.caster, buf.bd.target, dmg, SpellData[SIDRABIESHEX].name, false, true, false, WEAPON_TYPE_WHOKNOWS);
        AddTimedEffect.atUnit(ART_BLEED, buf.bd.target, "origin", 0.2);
        AddTimedEffect.atUnit(ART_POISON, buf.bd.target, "origin", 0.2);
    }

    function RabiesOnRemove(Buff buf) {}

    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BUFF_ID);
        buf.bd.tick = 5;
        buf.bd.interval = 2.0;
        buf.bd.boe = RabiesOnEffect;
        buf.bd.bor = RabiesOnRemove;
        buf.run();
        
        AddTimedEffect.atUnit(ART_BLEED, SpellEvent.TargetUnit, "origin", 0.2);
        AddTimedEffect.atUnit(ART_POISON, SpellEvent.TargetUnit, "origin", 0.2);
    }

    function onInit() {
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_NEG);
        RegisterSpellEffectResponse(SIDRABIESHEX, onCast);
    }
#undef BUFF_ID
}
//! endzinc
