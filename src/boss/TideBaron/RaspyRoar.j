//! zinc
library RaspyRoar requires BuffSystem, SpellEvent {
#define BUFF_ID 'A052'
    function onEffect(Buff buf) {}
    
    function onRemove(Buff buf) {
        UnitRemoveAbility(buf.bd.target, 'B02I');
    }

    function onCast() {
        integer i = 0;
        Buff buf;
        DummyCastPoint(SpellEvent.CastingUnit, SIDRASPYROARDUMMY, "silence", GetUnitX(SpellEvent.CastingUnit), GetUnitY(SpellEvent.CastingUnit));
        while (i < PlayerUnits.n) {
            if (GetDistance.units2d(PlayerUnits.units[i], SpellEvent.CastingUnit) < 3600.0 && !IsUnitDead(PlayerUnits.units[i])) {                
                buf = Buff.cast(SpellEvent.CastingUnit, PlayerUnits.units[i], BUFF_ID);
                buf.bd.tick = -1;
                buf.bd.interval = 3.0;
                buf.bd.boe = onEffect;
                buf.bd.bor = onRemove;
                buf.run();
            }
            i += 1;
        }
    }

    function onInit() {
        RegisterSpellEffectResponse(SIDRASPYROAR, onCast);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_NEG);
    }
#undef BUFF_ID
}
//! endzinc
