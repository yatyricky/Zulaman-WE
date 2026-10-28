using System.Threading.Tasks;

public class Program
{
    private static async void Test()
    {
        CreateUnit(Player(11), FourCC("hfoo"), 6287, -12370, 0);
    }

    private void Start()
    {
        GameTime.Init();
        GameObject.RunGameObjects();
        _ = SpellChannelEvent.Instance;
        _ = SpellCastEvent.Instance;
        _ = SpellEffectEvent.Instance;
        _ = SpellFinishEvent.Instance;
        _ = SpellEndCastEvent.Instance;

        _ = new MeleeAttack();

        InvokeAbility.Instance.Init();

        Const.SystemRoot = new GameObject("Systems");
        Const.SystemRoot.AddComponent<BuffSystem>();
        Const.UnitsRoot = new GameObject("Units");
        Const.UiRoot = new GameObject("UI");

        StatsComponent.Init();
        Selection.Init();
        Command.Init();

        Test();
    }

    public static void Main()
    {
        var program = new Program();
        program.Start();
    }
}
