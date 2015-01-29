//! zinc
library EvilImbue requires SpellEvent, DamageSystem, DarkRangerGlobal {
#define ART "Abilities\\Spells\\Undead\\DarkRitual\\DarkRitualTarget.mdl"
#define BUFF_ID 'A045'

    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].ModAttackSpeed(buf.bd.i0);
        UnitProp[buf.bd.target].ModAP(buf.bd.i1);
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].ModAttackSpeed(0 - buf.bd.i0);
        UnitProp[buf.bd.target].ModAP(0 - buf.bd.i1);
    }

    function response(unit u) {
        integer id;
        Buff buf;
        if (GetUnitTypeId(u) == UTIDGHOUL) {
            id = GetPlayerId(GetOwningPlayer(u));
            ghoul[id] = null;
            if (!IsUnitDead(darkranger[id])) {
                AddTimedEffect.atUnit(ART, darkranger[id], "origin", 0.5);
                
                buf = Buff.cast(darkranger[id], darkranger[id], BUFF_ID);
                buf.bd.tick = -1;
                buf.bd.interval = 15.0;
                UnitProp[buf.bd.target].ModAttackSpeed(0 - buf.bd.i0);
                buf.bd.i0 = 20;
                UnitProp[buf.bd.target].ModAP(0 - buf.bd.i1);
                buf.bd.i1 = 10;
                buf.bd.boe = onEffect;
                buf.bd.bor = onRemove;
                buf.run();
            }
        }
    }

    function onInit() {
        RegisterUnitDeath(response);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
    }
#undef BUFF_ID
#undef ART
}
//! endzinc
