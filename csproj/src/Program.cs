using StdLib;

public class Program
{
    private static void DamageEventFunc(DamagedEventData data)
    {
        var damage = data.damage;
        var damageSource = data.damageSource;
        var damageTarget = data.damageTarget;

        if (data.isAttack && data.damageType != DAMAGE_TYPE_DIVINE)
        {
            var dmg = new Damage
            {
                args = new Damage.Args
                {
                    source = damageSource,
                    target = damageTarget,
                    amount = data.damage,
                    name = "普通攻击",
                    isPhyx = true,
                    isAttack = true,
                    isDirect = true,
                    canCrit = true,
                    canDodge = true,
                    wtype = WEAPON_TYPE_WHOKNOWS,
                }
            };
            dmg.Run();
        }
    }

    private void Test()
    {
        DamagedEvent.Instance.Register(DamageEventFunc);
    }

    private void Start()
    {
        GameObject.RunGameObjects();
        _ = SpellChannelEvent.Instance;
        _ = SpellCastEvent.Instance;
        _ = SpellEffectEvent.Instance;
        _ = SpellFinishEvent.Instance;
        _ = SpellEndCastEvent.Instance;

        InvokeAbility.Instance.Init();
        StatsComponent.Init();
        Const.UnitsRoot = new GameObject("Units");

        Test();
    }

    public static void Main()
    {
        var program = new Program();
        program.Start();
    }
}
