//! zinc
library HexShrunkenHead requires ItemAttributes {
#define BUFF_ID 'A07E'
#define ART_CASTER "Abilities\\Spells\\Items\\AIim\\AIimTarget.mdl"
    //HandleTable ht;

    function oneffect(Buff buf) {
        UnitProp[buf.bd.target].spellPower += buf.bd.r0;
    }

    function onremove(Buff buf) {
        UnitProp[buf.bd.target].spellPower -= buf.bd.r0;
    }
    
    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BUFF_ID);
        buf.bd.tick = -1;
        buf.bd.interval = 15.0;
        UnitProp[buf.bd.target].spellPower -= buf.bd.r0;
        buf.bd.r0 = 35;
        buf.bd.boe = oneffect;
        buf.bd.bor = onremove;
        buf.run();
        
        AddTimedEffect.atUnit(ART_CASTER, SpellEvent.CastingUnit, "origin", 0.5);
    }

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        up.ModInt(17 * fac);
        up.spellPower += 17 * fac;
        //if (!ht.exists(u)) {ht[u] = 0;}
        //ht[u] = ht[u] + fac;
    }

    function onInit() {
        //ht = HandleTable.create();
        RegisterItemPropMod(ITID_HEX_SHRUNKEN_HEAD, action);
        RegisterSpellEffectResponse(SID_HEX_SHRUNKEN_HEAD, onCast);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
    }
#undef ART_CASTER
#undef BUFF_ID
}
//! endzinc
