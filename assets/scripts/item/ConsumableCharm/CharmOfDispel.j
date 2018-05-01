//! zinc
library CharmOfDispel requires SpellEvent, ZAMCore {

    function onCast() {
        Buff buf;
        integer polarity;
        if (IsUnitEnemy(SpellEvent.TargetUnit, GetOwningPlayer(SpellEvent.CastingUnit))) {
            polarity = BUFF_POS;
        } else {
            polarity = BUFF_NEG;
        }
        buf = BuffSlot[SpellEvent.TargetUnit].dispel(BUFF_MAGE, polarity);
        if (buf != 0) {
            buf.destroy();
        }
        AddTimedEffect.atUnit(ART_DISPEL, SpellEvent.TargetUnit, "origin", 0.2);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_CHARM_OF_DISPEL, onCast);        
    }
}
//! endzinc
