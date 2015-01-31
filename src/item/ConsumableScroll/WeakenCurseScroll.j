//! zinc
library WeakenCurseScroll requires SpellEvent, CastingBar {
#define ART_CASTER "Abilities\\Spells\\Other\\HowlOfTerror\\HowlCaster.mdl"
#define ART_TARGET "Abilities\\Spells\\Human\\slow\\slowtarget.mdl"
#define BUFF_ID 'A07N'
    
    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].damageDealt -= buf.bd.r0;
    }
    
    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].damageDealt += buf.bd.r0;
    }

    function onCast() {
        integer i = 0;
        Buff buf;
        while (i < MobList.n) {
            if (GetDistance.units2d(MobList.units[i], SpellEvent.CastingUnit) <= 600.0 + 197.0 && !IsUnitDead(MobList.units[i])) {                
                buf = Buff.cast(SpellEvent.CastingUnit, MobList.units[i], BUFF_ID);
                buf.bd.tick = -1;
                buf.bd.interval = 10.0;
                UnitProp[buf.bd.target].damageDealt += buf.bd.r0;
                buf.bd.r0 = 0.75;
                if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_TARGET, buf, "origin");}
                //if (buf.bd.e1 == 0) {buf.bd.e1 = BuffEffect.create(ART_RIGHT, buf, "hand, right");}
                buf.bd.boe = onEffect;
                buf.bd.bor = onRemove;
                buf.run();
            }
            i += 1;
        }
        AddTimedEffect.atUnit(ART_CASTER, SpellEvent.CastingUnit, "origin", 1.0);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_WEAKEN_CURSE_SCROLL, onCast);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_NEG);
    }
#undef BUFF_ID
#undef ART_TARGET
#undef ART_CASTER
}
//! endzinc
