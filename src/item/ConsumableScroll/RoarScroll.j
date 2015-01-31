//! zinc
library RoarScroll requires SpellEvent, ZAMCore {
#define ART_CASTER "Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl"
#define BUFF_ID 'A071'
    
    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].ModAP(buf.bd.i0);
    }
    
    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].ModAP(0 - buf.bd.i0);
    }

    function onCast() {
        integer i = 0;
        Buff buf;
        while (i < PlayerUnits.n) {
            if (GetDistance.units2d(PlayerUnits.units[i], SpellEvent.CastingUnit) <= 900.0 && !IsUnitDead(PlayerUnits.units[i])) {
                buf = Buff.cast(SpellEvent.CastingUnit, PlayerUnits.units[i], BUFF_ID);
                buf.bd.tick = -1;
                buf.bd.interval = 20.0;
                UnitProp[buf.bd.target].ModAP(0 - buf.bd.i0);
                buf.bd.i0 = 15;
                buf.bd.boe = onEffect;
                buf.bd.bor = onRemove;
                buf.run();
            }
            i += 1;
        }
        AddTimedEffect.atUnit(ART_CASTER, SpellEvent.CastingUnit, "origin", 1.0);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_ROAR_SCROLL, onCast);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
        
    }
#undef BUFF_ID
#undef ART_CASTER
}
//! endzinc
