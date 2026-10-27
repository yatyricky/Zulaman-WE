public class InvokeEffect
{
    public static void Exec(EffectConfigEntry effect, Pipeline pipeline, unit currentTarget)
    {
        switch (effect.Type)
        {
            case EffectType.Damage:
                Damage.Exec(effect, pipeline, currentTarget);
                break;
            case EffectType.PlaySFX:
                PlaySFX.Exec(effect, pipeline, currentTarget);
                break;
            default:
                throw new System.Exception($"Unhandled EffectType: {effect.Type}");
        }
    }
}