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

    public void Init()
    {
        SpellEffectEvent.Instance.Register(FourCC("A004"), (data) =>
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