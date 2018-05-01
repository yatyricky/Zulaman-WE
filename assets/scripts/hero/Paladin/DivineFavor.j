//! zinc
library DivineFavor requires SpellEvent, UnitProperty {

    function returnDuration(integer lvl) -> real {
        return 5.0 + lvl * 5;
    }

    function onEffectCrit(Buff buf) {}
    function onRemoveCrit(Buff buf) {}

    function onEffectHaste(Buff buf) {
        BlzSetUnitAbilityCooldown(buf.bd.target, SID_FLASH_LIGHT, GetUnitAbilityLevel(buf.bd.target, SID_FLASH_LIGHT), 1.0);
    }

    function onRemoveHaste(Buff buf) {
        BlzSetUnitAbilityCooldown(buf.bd.target, SID_FLASH_LIGHT, GetUnitAbilityLevel(buf.bd.target, SID_FLASH_LIGHT), 3.5);
    }

    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BID_DIVINE_FAVOR_CRIT);
        buf.bd.tick = -1;
        buf.bd.interval = 20.0;
        buf.bd.boe = onEffectCrit;
        buf.bd.bor = onRemoveCrit;
        buf.run();
        
        buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BID_DIVINE_FAVOR);
        buf.bd.tick = -1;
        buf.bd.interval = returnDuration(GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_DIVINE_FAVOR));
        buf.bd.boe = onEffectHaste;
        buf.bd.bor = onRemoveHaste;
        buf.run();
    }

    function onInit() {
        BuffType.register(BID_DIVINE_FAVOR, BUFF_MAGE, BUFF_POS);
        BuffType.register(BID_DIVINE_FAVOR_CRIT, BUFF_MAGE, BUFF_POS);
        RegisterSpellEffectResponse(SID_DIVINE_FAVOR, onCast);
    }

}
//! endzinc
