//! zinc
library SavageRoarHex requires BuffSystem, SpellEvent, UnitProperty {
#define ART_DEBUFF "Abilities\\Spells\\Other\\HowlOfTerror\\HowlTarget.mdl"
// #define ART_CASTER "Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl"

    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].ModAP(0 - buf.bd.i0);
        UnitProp[buf.bd.target].spellPower -= buf.bd.r0;
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].ModAP(buf.bd.i0);
        UnitProp[buf.bd.target].spellPower += buf.bd.r0;
    }

    function onCast() {
        Buff buf;
        integer i;
        
        for (0 <= i < PlayerUnits.n) {
            buf = Buff.cast(SpellEvent.CastingUnit, PlayerUnits.units[i], BID_SAVAGE_ROAR_HEX);
            buf.bd.tick = -1;
            buf.bd.interval = 6;
            UnitProp[buf.bd.target].ModAP(buf.bd.i0);
            UnitProp[buf.bd.target].spellPower += buf.bd.r0;
            buf.bd.i0 = Rounding(0.5 * UnitProp[buf.bd.target].AttackPower());
            buf.bd.r0 = UnitProp[buf.bd.target].SpellPower() * 0.5;
            if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_DEBUFF, buf, "overhead");}
            buf.bd.boe = onEffect;
            buf.bd.bor = onRemove;
            buf.run();
        }
        // AddTimedEffect.atUnit(ART_CASTER, SpellEvent.CastingUnit, "origin", 0.5);
        
    }

    function onInit() {
        BuffType.register(BID_SAVAGE_ROAR_HEX, BUFF_PHYX, BUFF_NEG);
        RegisterSpellEffectResponse(SID_SAVAGE_ROAR_HEX, onCast);
    }
// #undef ART_CASTER
#undef ART_DEBUFF
}
//! endzinc
