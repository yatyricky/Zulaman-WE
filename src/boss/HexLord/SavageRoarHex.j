//! zinc
library SavageRoarHex requires BuffSystem, SpellEvent, UnitProperty {
constant string  ART_DEBUFF  = "Abilities\\Spells\\Other\\HowlOfTerror\\HowlTarget.mdl";
// constant string  ART_CASTER  = "Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl";

    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAP(0 - buf.bd.i0);
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).spellPower -= buf.bd.r0;
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAP(buf.bd.i0);
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).spellPower += buf.bd.r0;
    }

    function onCast() {
        Buff buf;
        integer i;
        
        for (0 <= i < PlayerUnits.n) {
            buf = Buff.cast(SpellEvent.CastingUnit, PlayerUnits.units[i], BID_SAVAGE_ROAR_HEX);
            buf.bd.tick = -1;
            buf.bd.interval = 6;
            UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAP(buf.bd.i0);
            UnitProp.inst(buf.bd.target, SCOPE_PREFIX).spellPower += buf.bd.r0;
            buf.bd.i0 = Rounding(0.5 * UnitProp.inst(buf.bd.target, SCOPE_PREFIX).AttackPower());
            buf.bd.r0 = UnitProp.inst(buf.bd.target, SCOPE_PREFIX).SpellPower() * 0.5;
            if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_DEBUFF, buf, "overhead");}
            buf.bd.boe = onEffect;
            buf.bd.bor = onRemove;
            buf.run();
        }
        // AddTimedEffect.atUnit(ART_CASTER, SpellEvent.CastingUnit, "origin", 0.5);
        
    }

    function onInit() {
        BuffType.register(BID_SAVAGE_ROAR_HEX, BUFF_PHYX, BUFF_NEG);
        RegisterSpellEffectResponse(SID_SAVAGE_ROAR_HEX, onCast);
    }
// 

}
//! endzinc
