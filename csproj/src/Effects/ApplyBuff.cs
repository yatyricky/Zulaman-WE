public class ApplyBuff : Effect
{
    public static void Exec(EffectConfigEntry effect, Pipeline pipeline, unit currentTarget)
    {
        if (effect.Data is not ApplyBuffData data) throw new System.Exception("effect " + effect.ID + " expects ApplyBuffData");

        var caster = pipeline.SpellCtx.CastingUnit;
        var target = data.whichTarget switch
        {
            SpellUnitType.CastingUnit => caster,
            SpellUnitType.TargetUnit => pipeline.SpellCtx.TargetUnit,
            SpellUnitType.CurrentTargetUnit => currentTarget,
            _ => throw new System.Exception("Unhandled buff target type: " + data.whichTarget),
        };

        if (target == null) throw new System.Exception("ApplyBuff effect " + effect.ID + " has a null target");

        var applied = BuffSystem.Apply(target, data.BuffId, caster, data.duration, data.stacks);
        if (applied != null) return;

        // Apply deliberately ignores dead/removed targets. Anything else is a
        // configuration/coverage error and must not be swallowed.
        if (GetUnitTypeId(target) == 0 || Helper.IsUnitDead(target)) return;
        throw new System.Exception("ApplyBuff effect " + effect.ID + " could not apply buff " + data.BuffId);
    }
}
