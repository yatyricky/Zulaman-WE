//! zinc
library DeathPact requires SpellEvent, DamageSystem, DarkRangerGlobal {
#define ART "Abilities\\Spells\\Undead\\DeathPact\\DeathPactTarget.mdl"

    function onCast() {
        integer id = GetPlayerId(GetOwningPlayer(SpellEvent.CastingUnit));
        real life;
        if (ghoul[id] != null) {
            life = GetWidgetLife(ghoul[id]) * GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDDEATHPACT) * 0.5;
            KillUnit(ghoul[id]);
            HealTarget(SpellEvent.CastingUnit, SpellEvent.CastingUnit, life, SpellData[SIDDEATHPACT].name, 0.0);
            AddTimedEffect.atUnit(ART_HEAL, SpellEvent.CastingUnit, "origin", 0.1);
        }
    }
    
    function learnt() -> boolean {
        if (GetLearnedSkill() == SIDDEATHPACT) {
            SetUnitAbilityLevel(GetTriggerUnit(), SIDSUMMONGHOUL, GetUnitAbilityLevel(GetTriggerUnit(), SIDDEATHPACT));
        }
        return false;
    }

    function onInit() {
        RegisterSpellEffectResponse(SIDDEATHPACT, onCast);
        TriggerAnyUnit(EVENT_PLAYER_HERO_SKILL, function learnt);
    }
#undef ART
}
//! endzinc
