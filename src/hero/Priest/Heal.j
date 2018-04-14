//! zinc
library Heal requires BuffSystem, SpellEvent, UnitProperty, Benediction {
constant integer BUFF_ID = 'A03X';
constant integer BUFF_ID1 = 'A00U';
constant string  ART  = "Abilities\\Spells\\Orc\\EtherealForm\\SpiritWalkerChange.mdl";

    function returnHealHOT(integer lvl, real sp) -> real {
        return 100.0 + 50.0 * lvl + sp * 0.8;
    }

    public function PriestCastHeal(unit caster, unit target, integer times) {
        real amt = returnHealHOT(GetUnitAbilityLevel(caster, SID_HEAL), UnitProp.inst(caster, SCOPE_PREFIX).SpellPower()) * times;
        HealTarget(caster, target, amt, SpellData[SID_HEAL].name, 0.0);
        AddTimedEffect.atUnit(ART, target, "origin", 0.3);
    }

    function onEffect(Buff buf) {
        HealTarget(buf.bd.caster, buf.bd.target, buf.bd.r0, SpellData[SID_HEAL].name, 0.0);
        AddTimedEffect.atUnit(ART, buf.bd.target, "origin", 0.3);
    }

    function onRemove(Buff buf) {}
    
    function onEffect1(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).healTaken += buf.bd.r0;
    }

    function onRemove1(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).healTaken -= buf.bd.r0;
    }
    
    public function CastHeal(unit caster, unit target) {
        integer lvl = GetUnitAbilityLevel(caster, SID_HEAL);
        real mult = 1.0;
        Buff buf = Buff.cast(caster, target, BUFF_ID);
        buf.bd.interval = 2.0 / (1.0 + UnitProp.inst(caster, SCOPE_PREFIX).SpellHaste());
        buf.bd.tick = Rounding(12.0 / buf.bd.interval);
        buf.bd.r0 = returnHealHOT(lvl, UnitProp.inst(caster, SCOPE_PREFIX).SpellPower());
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        
        if (HasBenediction(caster)) {
            mult = 2.0;
        }
        
        buf = Buff.cast(caster, target, BUFF_ID1);
        buf.bd.tick = -1;
        buf.bd.interval = 12.0;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).healTaken -= buf.bd.r0;
        buf.bd.r0 = 0.04 * lvl * mult;
        buf.bd.boe = onEffect1;
        buf.bd.bor = onRemove1;
        buf.run();
        
        AddTimedEffect.atUnit(ART, target, "origin", 1.0);
    }

    function onCast() {
        CastHeal(SpellEvent.CastingUnit, SpellEvent.TargetUnit);
    }

    function onInit() {
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
        BuffType.register(BUFF_ID1, BUFF_MAGE, BUFF_POS);
        RegisterSpellEffectResponse(SID_HEAL, onCast);
    }



}
//! endzinc
