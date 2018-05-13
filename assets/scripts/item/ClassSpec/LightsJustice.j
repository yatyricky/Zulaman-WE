//! zinc
library LightsJustice requires ItemAttributes, DamageSystem {
constant integer BUFF_ID = 'A06D';
constant integer DEBUFF_ID = 'A06E';
    HandleTable ht;
    
    public function HasLightsJustice(unit u) -> boolean {
        if (!ht.exists(u)) {
            return false;
        } else {
            return ht[u] > 0;
        }
    }

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp.inst(u, SCOPE_PREFIX);
        up.ModInt(10 * fac);
        up.spellPower += 20 * fac;
        up.spellCrit += 0.05 * fac;
        if (!ht.exists(u)) {ht[u] = 0;}
        ht[u] = ht[u] + fac;
    }
    
    function onEffect(Buff buf) {            
        Buff dispel = BuffSlot[buf.bd.target].dispel(BUFF_MAGE, buf.bd.i0);
        if (dispel != 0) {
            dispel.destroy();
        }
        AddTimedEffect.atUnit(ART_DISPEL, buf.bd.target, "origin", 1.0);
    }

    function onRemove(Buff buf) {}
    
    function onCast() {
        Buff buf;
        if (IsUnitAlly(SpellEvent.TargetUnit, GetOwningPlayer(SpellEvent.CastingUnit))) {
            buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BUFF_ID);
            buf.bd.i0 = BUFF_NEG;
        } else {
            buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, DEBUFF_ID);
            buf.bd.i0 = BUFF_POS;
        }
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.bd.tick = 4;
        buf.bd.interval = 3.0;
        buf.run();
        buf.bd.boe.evaluate(buf);
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterSpellEffectResponse(SID_LIGHTS_JUSTICE, onCast);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
        BuffType.register(DEBUFF_ID, BUFF_MAGE, BUFF_NEG);
    }


}
//! endzinc
