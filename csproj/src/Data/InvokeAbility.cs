
using System;
using StdLib;

public class InvokeAbility
{
    public static InvokeAbility _instance { get; private set; } = null!;

    public static InvokeAbility Instance
    {
        get
        {
            _instance ??= new InvokeAbility();
            return _instance;
        }
    }

    private static void Exec(SpellEventContext spellEventCtx)
    {
        var abilityConfig = AbilityConfig.FindByID(spellEventCtx.AbilityId);

        var pipeline = new Pipeline
        {
            SpellCtx = spellEventCtx
        };

        var targets = new List<unit>();
        switch (abilityConfig.SUType)
        {
            case SpellUnitType.TargetUnit:
                targets.Add(spellEventCtx.TargetUnit);
                break;
            default:
                throw new Exception($"Unhandled SpellUnitType: {abilityConfig.SUType}");
        }

        pipeline.SpellCtx.RTTargets.AddRange(targets);

        abilityConfig.Model.Process(pipeline, 0);

        foreach (var effectId in abilityConfig.Effects)
        {
            var effect = EffectConfig.FindByID(effectId);
            InvokeEffect.Exec(effect, pipeline);
        }
    }

    public void Init()
    {
        foreach (var entry in AbilityConfig.Data)
        {
            SpellEffectEvent.Instance.Register(entry.ID, Exec);
        }
    }
}