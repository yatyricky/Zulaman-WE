using System.Threading.Tasks;

public class PlaySFX : Effect
{
    public async static void Exec(EffectConfigEntry effect, Pipeline pipeline, unit currentTarget)
    {
        var data = effect.Data as PlaySFXData;
        if (data == null) throw new System.Exception($"effect {effect.ID} expects DamageData, got null");

        unit t;
        switch (data.whichTarget)
        {
            case SpellUnitType.CurrentTargetUnit:
                t = currentTarget;
                break;
            default:
                throw new System.Exception("Unhandled case");
        }
        var eff = AddSpecialEffectTarget(data.filePath, t, data.attachPoint);
        await Task.Delay(Math.Max(0, data.duration));
        DestroyEffect(eff);
    }
}
