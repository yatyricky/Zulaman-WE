using StdLib;
using System.Threading.Tasks;

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
        UiTest(); // 临时 UI 验证，验证完可删
    }

    private void UiTest()
    {
        var root = new GameObject("UiTestRoot", Const.UiRoot);

        // 居中面板（点锚）
        var panel = root.AddComponent<FrameComponent>();
        panel.anchorMin = new Vector2(0.5f, 0.5f);
        panel.anchorMax = new Vector2(0.5f, 0.5f);
        panel.pivot = new Vector2(0.5f, 0.5f);
        panel.sizeDelta = new Vector2(0.3f, 0.2f);
        panel.anchoredPosition = new Vector2(0f, 0f);
        var panelImg = root.AddComponent<FrameImage>();
        panelImg.texture = "ReplaceableTextures\\TeamColor\\TeamColor08";

        // 顶部横条（x 轴拉伸锚，pivot 在顶部）
        var barGo = new GameObject("UiTestBar", root);
        var bar = barGo.AddComponent<FrameComponent>();
        bar.anchorMin = new Vector2(0f, 1f);
        bar.anchorMax = new Vector2(1f, 1f);
        bar.pivot = new Vector2(0.5f, 1f);
        bar.sizeDelta = new Vector2(0f, 0.04f);
        bar.anchoredPosition = new Vector2(0f, 0f);
        var barImg = barGo.AddComponent<FrameImage>();
        barImg.texture = "ReplaceableTextures\\TeamColor\\TeamColor00";

        // 右上角图标（pivot=(1,1) 贴角验证，偏移公式错会悬出角外）
        var iconGo = new GameObject("UiTestIcon", root);
        var icon = iconGo.AddComponent<FrameComponent>();
        icon.anchorMin = new Vector2(1f, 1f);
        icon.anchorMax = new Vector2(1f, 1f);
        icon.pivot = new Vector2(1f, 1f);
        icon.sizeDelta = new Vector2(0.049f, 0.049f);
        icon.anchoredPosition = new Vector2(-0.005f, -0.005f);
        var iconImg = iconGo.AddComponent<FrameImage>();
        iconImg.texture = "ReplaceableTextures\\CommandButtons\\BTNHeroPaladin";

        ToggleTest(root, barGo);
    }

    private static async void ToggleTest(GameObject root, GameObject bar)
    {
        await Task.Delay(2000);
        root.SetActive(false);
        await Task.Delay(1000);
        root.SetActive(true);
        await Task.Delay(1000);
        bar.SetActive(false);
        await Task.Delay(1000);
        bar.SetActive(true);
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
        Const.UiRoot = new GameObject("UI");

        Test();
    }

    public static void Main()
    {
        var program = new Program();
        program.Start();
    }
}
