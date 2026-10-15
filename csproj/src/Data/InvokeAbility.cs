
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

    public static Dictionary<int, Func<unit, unit, float>> Formulas = new()
    {
        {
            SpellAbilityId.ArcaneShock, (caster, target) =>
            {
                return 0f;
            }
        }
    };

    public void Init()
    {
        SpellEffectEvent.Instance.Register(SpellAbilityId.ArcaneShock, (data) =>
        {
            var dmg = new Damage
            {
                args = new Damage.Args
                {
                    source = data.CastingUnit,
                    target = data.TargetUnit,
                    amount = 100,
                    name = I2S(data.AbilityId),
                    isPhyx = false,
                    isAttack = false,
                    isDirect = true,
                    canCrit = true,
                    canDodge = false,
                    wtype = WEAPON_TYPE_WHOKNOWS,
                }
            };
            dmg.Run();
        });
    }
}