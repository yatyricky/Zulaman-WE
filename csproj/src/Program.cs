using StdLib;

public class Program
{
    private void SetupDamagedEvent()
    {
        var obj = new GameObject("DamagedEventRoot");
        obj.AddComponent<DamagedEvent>();
    }

    private static int counter = 0;

    private static void DamageEventFunc(DamagedEvent.NativeDamageData data)
    {
        var damage = data.damage;
        var damageSource = data.damageSource;
        var damageTarget = data.damageTarget;
        counter++;

        BJDebugMsg($"{GetUnitName(damageSource)} damaged {GetUnitName(damageTarget)} for {damage} damage, isAttack: {data.isAttack}, damageType is {Helper.DamageType2String(data.damageType)}");

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

        SetupDamagedEvent();

        Test();
    }

    public static void Main()
    {
        var program = new Program();
        program.Start();
    }
}
