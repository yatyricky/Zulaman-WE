//! zinc
library SanctuaryScroll requires SpellEvent, StunUtils {
#define ART_CASTER "Abilities\\Spells\\Items\\AIda\\AIdaCaster.mdl"
#define BUFF_ID 'A075'
    
    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].damageTaken -= buf.bd.r0;
    }
    
    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].damageTaken += buf.bd.r0;
    }
    
    function actualAct(DelayTask dt) {
        integer i = 0;
        Buff buf;
        while (i < PlayerUnits.n) {
            if (GetDistance.units2d(PlayerUnits.units[i], dt.u0) <= 1200.0 && !IsUnitDead(PlayerUnits.units[i])) {
                buf = Buff.cast(dt.u0, PlayerUnits.units[i], BUFF_ID);
                buf.bd.tick = -1;
                buf.bd.interval = 9.0;
                UnitProp[buf.bd.target].damageTaken += buf.bd.r0;
                buf.bd.r0 = 2.0;
                buf.bd.boe = onEffect;
                buf.bd.bor = onRemove;
                buf.run();
                StunUnit(dt.u0, PlayerUnits.units[i], 8.0);
                AddTimedEffect.atUnit(ART_INVULNERABLE, PlayerUnits.units[i], "origin", 8.0);
            }
            i += 1;
        }
    }

    function onCast() {
        DelayedTaskExecute callback = actualAct;
        DelayTask dt = DelayTask.create(callback, 1.0);
        dt.u0 = SpellEvent.CastingUnit;
        AddTimedEffect.atUnit(ART_CASTER, SpellEvent.CastingUnit, "origin", 1.0);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_SANCTUARY_SCROLL, onCast);
        BuffType.register(BUFF_ID, BUFF_PHYX, BUFF_POS);
        
    }
#undef BUFF_ID
#undef ART_CASTER
}
//! endzinc
