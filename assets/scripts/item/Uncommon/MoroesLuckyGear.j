//! zinc
library MoroesLuckyGear requires ItemAttributes {
constant integer BUFF_ID = 'A06K';
    //HandleTable ht;

    function oneffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).dodge += buf.bd.r0;
    }

    function onremove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).dodge -= buf.bd.r0;
    }
    
    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BUFF_ID);
        buf.bd.tick = -1;
        buf.bd.interval = 10.0;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).dodge -= buf.bd.r0;
        buf.bd.r0 = 0.3;
        buf.bd.boe = oneffect;
        buf.bd.bor = onremove;
        buf.run();
    }

    function onInit() {
        //ht = HandleTable.create();
        RegisterSpellEffectResponse(SID_MOROES_LUCKY_GEAR, onCast);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
    }

}
//! endzinc
