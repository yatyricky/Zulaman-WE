//! zinc
library DivineFavor requires PaladinGlobal, SpellEvent, UnitProperty, AggroSystem {
constant integer BUFF_ID = 'A02A';
    function onCast() {
        healCrit[GetPlayerId(GetOwningPlayer(SpellEvent.CastingUnit))] = 2.0;
        if (GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_DIVINE_FAVOR) > 1) {
            AggroClear(SpellEvent.CastingUnit, 0.35);
        }
    }
    
    function lvlup() -> boolean {
        if (GetLearnedSkill() == SID_DIVINE_FAVOR) {
            if (GetUnitAbilityLevel(GetTriggerUnit(), SID_DIVINE_FAVOR) == LEVEL_TO_IMPROVE_FLASH_LIGHT) {
                SetPlayerAbilityAvailable(GetOwningPlayer(GetTriggerUnit()), SID_IMPROVE_FLASH_LIGHT, false);
                UnitAddAbility(GetTriggerUnit(), SID_IMPROVE_FLASH_LIGHT);
            }
        }
        return false;
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_DIVINE_FAVOR, onCast);
        TriggerAnyUnit(EVENT_PLAYER_HERO_SKILL, function lvlup);
    }

}
//! endzinc
