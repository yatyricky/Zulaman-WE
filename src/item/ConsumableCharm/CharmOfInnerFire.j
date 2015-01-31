//! zinc
library CharmOfInnerFire requires SpellEvent, BuffSystem, UnitProperty {
#define BUFF_ID 'A0AD'
#define ART_TARGET "Abilities\\Spells\\Human\\InnerFire\\InnerFireTarget.mdl"
    
    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].ModArmor(buf.bd.i0);
        UnitProp[buf.bd.target].ModAP(buf.bd.i1);
    }
    
    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].ModArmor(0 - buf.bd.i0);
        UnitProp[buf.bd.target].ModAP(0 - buf.bd.i1);
    }

    function onCast() {           
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BUFF_ID);
        buf.bd.interval = 15.0;
        buf.bd.tick = -1;
        UnitProp[buf.bd.target].ModArmor(0 - buf.bd.i0);
        UnitProp[buf.bd.target].ModAP(0 - buf.bd.i1);
        buf.bd.i0 = 8;
        buf.bd.i1 = 10;
        if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_TARGET, buf, "overhead");}
        //if (buf.bd.e1 == 0) {buf.bd.e1 = BuffEffect.create(ART_RIGHT, buf, "hand, right");}
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_CHARM_OF_INNER_FIRE, onCast);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
        
    }
#undef ART_TARGET
#undef BUFF_ID
}
//! endzinc
