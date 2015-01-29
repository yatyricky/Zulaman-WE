//! zinc
library DivineFavor requires PaladinGlobal, SpellEvent, UnitProperty, AggroSystem {
#define BUFF_ID 'A02A'
    function onCast() {
        healCrit[GetPlayerId(GetOwningPlayer(SpellEvent.CastingUnit))] = 2.0;
        if (GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDDIVINEFAVOR) > 1) {
            AggroClear(SpellEvent.CastingUnit, 0.35);
        }
    }
    
    function lvlup() -> boolean {
        if (GetLearnedSkill() == SIDDIVINEFAVOR) {
            if (GetUnitAbilityLevel(GetTriggerUnit(), SIDDIVINEFAVOR) == LEVEL_TO_IMPROVE_FLASH_LIGHT) {
                SetPlayerAbilityAvailable(GetOwningPlayer(GetTriggerUnit()), SIDIMPROVEFLASHLIGHT, false);
                UnitAddAbility(GetTriggerUnit(), SIDIMPROVEFLASHLIGHT);
            }
        }
        return false;
    }

    function onInit() {
        RegisterSpellEffectResponse(SIDDIVINEFAVOR, onCast);
        TriggerAnyUnit(EVENT_PLAYER_HERO_SKILL, function lvlup);
    }
#undef BUFF_ID
}
//! endzinc
