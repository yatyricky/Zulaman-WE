public class InvokeEffect
{
    public static void Exec(EffectConfigEntry effect, Pipeline pipeline)
    {
        switch (effect.Type)
        {
            case EffectType.Damage:
                Damage.Exec(effect, pipeline);
                break;
            default:
                throw new System.Exception($"Unhandled EffectType: {effect.Type}");
        }
    }
}