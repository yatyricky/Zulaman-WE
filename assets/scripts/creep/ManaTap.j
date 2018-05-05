//! zinc
library ManaTap requires SpellEvent, ZAMCore {

    function onEffect(Buff buf) {}
    function onRemove(Buff buf) {}

    function onCast() {
        integer i;
        Buff buf;
        for (0 <= i < PlayerUnits.n) {
            if (!IsUnitDead(PlayerUnits.units[i]) && GetDistance.unitCoord(PlayerUnits.units[i], SpellEvent.TargetX, SpellEvent.TargetY) <= 300.0) {
                // magic effect
                buf = Buff.cast(SpellEvent.CastingUnit, PlayerUnits.units[i], BID_MANA_TAP);
                buf.bd.tick = -1;
                buf.bd.interval = 10;
                buf.bd.boe = onEffect;
                buf.bd.bor = onRemove;
                buf.run();
            }
        }
    }

    function endCast() {
        if (GetUnitAbilityLevel(SpellEvent.CastingUnit, BID_MANA_TAP) > 0) {
            ModUnitMana(SpellEvent.CastingUnit, 0.0 - SpellData.inst(SpellEvent.AbilityId, SCOPE_PREFIX).Cost(GetUnitAbilityLevel(SpellEvent.CastingUnit, SpellEvent.AbilityId)));
            AddTimedEffect.atUnit(ART_MANA_DRAIN_TARGET, SpellEvent.CastingUnit, "origin", 0.2);
        }
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_MANA_TAP, onCast);
        RegisterSpellEndCastResponse(0, endCast);
        BuffType.register(BID_MANA_TAP, BUFF_MAGE, BUFF_NEG);
    }
}
//! endzinc
