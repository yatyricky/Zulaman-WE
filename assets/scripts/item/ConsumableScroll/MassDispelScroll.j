//! zinc
library MassDispelScroll requires SpellEvent, ZAMCore {

    function onCast() {            
        unit tu;
        Buff buf;
        integer polarity;
        GroupUnitsInArea(ENUM_GROUP, SpellEvent.TargetX, SpellEvent.TargetY, 450.0);
        tu = FirstOfGroup(ENUM_GROUP);
        while (tu != null) {
            if (!IsUnitDummy(tu) && !IsUnitDead(tu)) {
                if (IsUnitEnemy(tu, GetOwningPlayer(SpellEvent.CastingUnit))) {
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
        AddTimedEffect.atCoord(ART_DISPEL, SpellEvent.TargetX, SpellEvent.TargetY, 0.2);
        tu = null;
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_MASS_DISPEL_SCROLL, onCast);        
    }
}
//! endzinc
