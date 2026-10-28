public class ApplyBuff : Effect
{
    public static void Exec(EffectConfigEntry effect, Pipeline pipeline, unit currentTarget)
    {
        var data = effect.Data as ApplyBuffData;
        if (data == null) throw new System.Exception("effect " + effect.ID + " expects ApplyBuffData, got null");

        var caster = pipeline.SpellCtx.CastingUnit;
        var target = data.whichTarget == SpellUnitType.CastingUnit ? caster : currentTarget;
        BuffSystem.Apply(target, data.BuffId, caster, data.duration, data.stacks);
    }
}
