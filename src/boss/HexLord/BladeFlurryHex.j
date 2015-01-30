//! zinc
library BladeFlurryHex requires DamageSystem, SpellEvent, RogueGlobal {
#define ART "Abilities\\Spells\\NightElf\\BattleRoar\\RoarTarget.mdl"
#define ART_OPEN "Abilities\\Spells\\Other\\Silence\\SilenceAreaBirth.mdl"
#define BUFF_ID 'A05X'

    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].ModAttackSpeed(buf.bd.i0);
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].ModAttackSpeed(0 - buf.bd.i0);
    }
    
    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BUFF_ID);
        buf.bd.tick = -1;
        buf.bd.interval = 4.0;
        UnitProp[buf.bd.target].ModAttackSpeed(0 - buf.bd.i0);
        buf.bd.i0 = 100;
        if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART, buf, "overhead");}
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        AddTimedEffect.atCoord(ART_OPEN, GetUnitX(SpellEvent.CastingUnit), GetUnitY(SpellEvent.CastingUnit), 0.5);
    }

    function onInit() {
        RegisterSpellEffectResponse(SIDBLADEFLURRYHEX, onCast);
        BuffType.register(BUFF_ID, BUFF_PHYX, BUFF_POS);
    }
#undef BUFF_ID
#undef ART_OPEN
#undef ART
}
//! endzinc
