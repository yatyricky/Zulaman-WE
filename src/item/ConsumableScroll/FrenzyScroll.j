//! zinc
library FrenzyScroll requires SpellEvent, ZAMCore {
#define ART_LEFT "Abilities\\Spells\\Orc\\Bloodlust\\BloodlustTarget.mdl"
#define ART_RIGHT "Abilities\\Spells\\Orc\\Bloodlust\\BloodlustSpecial.mdl"
#define BUFF_ID 'A06U'
    
    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].ModAttackSpeed(buf.bd.i0);
    }
    
    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].ModAttackSpeed(0 - buf.bd.i0);
    }

    function onCast() {
        integer i = 0;
        Buff buf;
        while (i < PlayerUnits.n) {
            if (GetDistance.units2d(PlayerUnits.units[i], SpellEvent.CastingUnit) <= 900.0 && !IsUnitDead(PlayerUnits.units[i])) {
                buf = Buff.cast(SpellEvent.CastingUnit, PlayerUnits.units[i], BUFF_ID);
                buf.bd.tick = -1;
                buf.bd.interval = 10.0;
                UnitProp[buf.bd.target].ModAttackSpeed(0 - buf.bd.i0);
                buf.bd.i0 = 30;
                if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_LEFT, buf, "hand, left");}
                if (buf.bd.e1 == 0) {buf.bd.e1 = BuffEffect.create(ART_RIGHT, buf, "hand, right");}
                buf.bd.boe = onEffect;
                buf.bd.bor = onRemove;
                buf.run();
            }
            i += 1;
        }
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_FRENZY_SCROLL, onCast);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
        
    }
#undef BUFF_ID
#undef ART_RIGHT
#undef ART_LEFT
}
//! endzinc
