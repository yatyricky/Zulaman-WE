public class MeleeAttack
{
    private static EffectConfigEntry _melee = null!;
    private static EffectConfigEntry melee => _melee ??= EffectConfig.FindByID("002");

    private static void DamageEventFunc(DamagedEventData data)
    {
        if (!data.isAttack || data.damageType == DAMAGE_TYPE_DIVINE) return;

        var pipe = new Pipeline
        {
            SpellCtx = new SpellEventContext
            {
                CastingUnit = data.damageSource,
                RTTargets = [data.damageTarget]
            }
        };

        InvokeEffect.Exec(melee, pipe, data.damageTarget);
    }

    public MeleeAttack()
    {
        DamagedEvent.Instance.Register(DamageEventFunc);
    }
}
