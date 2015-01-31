//! zinc
library DefendScroll requires SpellEvent, ZAMCore {
#define ART_CASTER "Abilities\\Spells\\Items\\AIda\\AIdaCaster.mdl"
#define ART_TARGET "Abilities\\Spells\\Items\\AIda\\AIdaTarget.mdl"
#define BUFF_ID 'A06W'
    
    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].ModArmor(buf.bd.i0);
    }
    
    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].ModArmor(0 - buf.bd.i0);
    }

    function onCast() {
        integer i = 0;
        Buff buf;
        while (i < PlayerUnits.n) {
            if (GetDistance.units2d(PlayerUnits.units[i], SpellEvent.CastingUnit) <= 600.0 && !IsUnitDead(PlayerUnits.units[i])) {
                buf = Buff.cast(SpellEvent.CastingUnit, PlayerUnits.units[i], BUFF_ID);
                buf.bd.tick = -1;
                buf.bd.interval = 10.0;
                UnitProp[buf.bd.target].ModArmor(0 - buf.bd.i0);
                buf.bd.i0 = 8;
                if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_TARGET, buf, "overhead");}
                buf.bd.boe = onEffect;
                buf.bd.bor = onRemove;
                buf.run();
            }
            i += 1;
        }
        AddTimedEffect.atUnit(ART_CASTER, SpellEvent.CastingUnit, "origin", 1.0);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_DEFEND_SCROLL, onCast);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
        
    }
#undef BUFF_ID
#undef ART_TARGET
#undef ART_CASTER
}
//! endzinc
