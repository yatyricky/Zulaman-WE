//! zinc
library MassDispelScroll requires SpellEvent, ZAMCore {

    function takeEffect(RepeatTask rt) {
        unit tu;
        Buff buf;
        integer polarity;
        GroupUnitsInArea(ENUM_GROUP, rt.r0, rt.r1, 450.0);
        tu = FirstOfGroup(ENUM_GROUP);
        while (tu != null) {
            if (!IsUnitDummy(tu) && !IsUnitDead(tu)) {
                if (IsUnitEnemy(tu, GetOwningPlayer(rt.u0))) {
                    polarity = BUFF_POS;
                } else {
                    polarity = BUFF_NEG;
                }
                buf = BuffSlot[tu].dispel(BUFF_MAGE, polarity);
                if (buf != 0) {
                    buf.destroy();
                    AddTimedEffect.atUnit(ART_DISPEL, tu, "origin", 0.2);
                }
            }
            GroupRemoveUnit(ENUM_GROUP, tu);
            tu = FirstOfGroup(ENUM_GROUP);
        }
        AddTimedEffect.atCoord(ART_DISPEL, rt.r0, rt.r1, 0.2);
        tu = null;
    }

    function onCast() {
        RepeatTask rt = RepeatTask.create(takeEffect, 2, 2);
        rt.u0 = SpellEvent.CastingUnit;
        rt.r0 = SpellEvent.TargetX;
        rt.r1 = SpellEvent.TargetY;

        takeEffect(rt);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_MASS_DISPEL_SCROLL, onCast);
    }
}
//! endzinc
