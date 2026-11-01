using System.Threading.Tasks;

public class PlaySFX : Effect
{
    public async static void Exec(EffectConfigEntry effect, Pipeline pipeline, unit currentTarget)
    {
        if (effect.Data is not PlaySFXData data) throw new System.Exception($"effect {effect.ID} expects PlaySFXData");

        var target = data.whichTarget switch
        {
            SpellUnitType.CastingUnit => pipeline.SpellCtx.CastingUnit,
            SpellUnitType.TargetUnit => pipeline.SpellCtx.TargetUnit,
            SpellUnitType.CurrentTargetUnit => currentTarget,
            _ => throw new System.Exception("Unhandled case"),
        };
        if (target == null) return;

        var eff = AddSpecialEffectTarget(data.filePath, target, data.attachPoint);
        await Task.Delay(Math.Max(0, data.duration));
        if (eff != null)
        {
            DestroyEffect(eff);
        }
    }
}
