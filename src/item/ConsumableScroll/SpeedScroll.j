//! zinc
library SpeedScroll requires SpellEvent, CastingBar {
#define ART_TARGET "Abilities\\Spells\\Items\\AIsp\\SpeedTarget.mdl"
#define BUFF_ID 'A06S'
    
    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].ModSpeed(buf.bd.i0);
    }
    
    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].ModSpeed(0 - buf.bd.i0);
    }

    function onCast() {
        integer i = 0;
        Buff buf;
        while (i < PlayerUnits.n) {
            if (GetDistance.units2d(PlayerUnits.units[i], SpellEvent.CastingUnit) <= 900.0 && !IsUnitDead(PlayerUnits.units[i])) {
                buf = Buff.cast(SpellEvent.CastingUnit, PlayerUnits.units[i], BUFF_ID);
                buf.bd.tick = -1;
                buf.bd.interval = 5.0;
                UnitProp[buf.bd.target].ModSpeed(0 - buf.bd.i0);
                buf.bd.i0 = 200;
                if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_TARGET, buf, "origin");}
                buf.bd.boe = onEffect;
                buf.bd.bor = onRemove;
                buf.run();
            }
            i += 1;
        }
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_SPEED_SCROLL, onCast);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
        
    }
#undef BUFF_ID
#undef ART_TARGET
}
//! endzinc
