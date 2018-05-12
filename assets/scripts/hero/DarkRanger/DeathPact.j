//! zinc
library DeathPact requires SpellEvent, DamageSystem, DarkRangerGlobal {
constant string  ART  = "Abilities\\Spells\\Undead\\DeathPact\\DeathPactTarget.mdl";

    function onCast() {
        integer id = GetPlayerId(GetOwningPlayer(SpellEvent.CastingUnit));
        real life;
        if (ghoul[id] != null) {
            life = GetWidgetLife(ghoul[id]) * GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_DEATH_PACT) * 0.5;
            KillUnit(ghoul[id]);
            HealTarget(SpellEvent.CastingUnit, SpellEvent.CastingUnit, life, SpellData.inst(SID_DEATH_PACT, SCOPE_PREFIX).name, 0.0, false);
            AddTimedEffect.atUnit(ART_HEAL, SpellEvent.CastingUnit, "origin", 0.1);
        }
    }
    
    function learnt() -> boolean {
        if (GetLearnedSkill() == SID_DEATH_PACT) {
            SetUnitAbilityLevel(GetTriggerUnit(), SID_SUMMON_GHOUL, GetUnitAbilityLevel(GetTriggerUnit(), SID_DEATH_PACT));
        }
        return false;
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_DEATH_PACT, onCast);
        TriggerAnyUnit(EVENT_PLAYER_HERO_SKILL, function learnt);
    }

}
//! endzinc
