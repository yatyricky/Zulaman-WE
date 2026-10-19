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
        // EnableLogTest(); // 上轮已 24/24 全过，本轮聚焦 UI；需要时恢复
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

        ToggleTest(root, barGo, panel, bar, panelImg, iconImg);
    }

    private static string B(bool b)
    {
        if (b) return "1";
        return "0";
    }

    private static string FrameState(string label, framehandle? f)
    {
        var n = f;
        if (n == null) return label + ": native=null";
        return label + ": visible=" + B(BlzFrameIsVisible(n)) + " w=" + BlzFrameGetWidth(n) + " h=" + BlzFrameGetHeight(n);
    }

    // 临时 UI 回读验证，验证完可删。期望序列见各行注释；visible/w/h 为引擎回读值，
    // 拉伸/浮点存在微小误差属正常。
    private static async void ToggleTest(GameObject root, GameObject bar, FrameComponent panel, FrameComponent barFrame, FrameImage panelImg, FrameImage iconImg)
    {
        await Task.Delay(500); // 等首轮 LateUpdate apply；屏幕上应出现：灰面板 + 顶部红条 + 右上角圣骑士图标
        Log.Info("[UI] init " + FrameState("panel", panel.nativeFrame) + " " + FrameState("bar", barFrame.nativeFrame) + " " + FrameState("icon", iconImg.nativeFrame));
        // 期望: panel visible=1 w≈0.3 h≈0.2 | bar visible=1 w≈0.3 h≈0.04 | icon visible=1 w≈0.049 h≈0.049

        root.SetActive(false); // 视觉：整组消失 1 秒
        await Task.Delay(1000);
        Log.Info("[UI] root off " + FrameState("panel", panel.nativeFrame) + " " + FrameState("icon", iconImg.nativeFrame));
        // 期望: panel/icon visible=0（OnDisable 同步推送，整组隐藏）

        root.SetActive(true); // 视觉：整组重现
        await Task.Delay(1000);
        Log.Info("[UI] root on " + FrameState("panel", panel.nativeFrame) + " " + FrameState("icon", iconImg.nativeFrame));
        // 期望: panel/icon visible=1（激活后 apply 恢复）

        bar.SetActive(false); // 视觉：仅红条消失
        await Task.Delay(1000);
        Log.Info("[UI] bar off " + FrameState("bar", barFrame.nativeFrame) + " " + FrameState("panel", panel.nativeFrame));
        // 期望: bar visible=0, panel visible=1

        bar.SetActive(true); // 视觉：红条重现
        await Task.Delay(1000);
        Log.Info("[UI] bar on " + FrameState("bar", barFrame.nativeFrame));
        // 期望: bar visible=1

        iconImg.enabled = false; // 视觉：仅圣骑士图标消失（灰面板与红条不动）
        await Task.Delay(1000);
        Log.Info("[UI] iconImg disabled " + FrameState("icon", iconImg.nativeFrame) + " " + FrameState("panel", panel.nativeFrame));
        // 期望: icon visible=0, panel visible=1（组件级开关只影响自身图像）

        iconImg.enabled = true; // 视觉：图标重现
        await Task.Delay(1000);
        Log.Info("[UI] iconImg enabled " + FrameState("icon", iconImg.nativeFrame));
        // 期望: icon visible=1
    }

    // ============ 临时：Component.enabled 生命周期日志测试（验证完可删） ============
    //
    // 进图后屏幕应逐行出现以下序列（probeN 按创建顺序编号）：
    //
    // [E1] A. enabled 去重
    //   probe1: Awake                      (AddComponent)
    //   probe1: OnEnable                   (AddComponent)
    //   probe1: OnDisable                  (enabled=false)
    //   （无）                             (再置 false)
    //   probe1: OnEnable                   (enabled=true)
    //   （无）                             (再置 true)
    //
    // [E2] B. enabled × SetActive 组合
    //   probe1: OnDisable                  (GO SetActive(false))
    //   （无）                             (再 false)
    //   probe1: OnEnable                   (GO SetActive(true))
    //   probe1: OnDisable                  (enabled=false)
    //   （无）                             (GO SetActive(false)，组件已失效)
    //   （无）                             (GO SetActive(true)，组件仍禁用)
    //   probe1: OnEnable                   (enabled=true，激活链已通)
    //
    // [E4] D. 子分支传播
    //   probe2: Awake, OnEnable            (child AddComponent)
    //   probe2: OnDisable                  (parent SetActive(false))
    //   probe2: OnEnable                   (parent SetActive(true))
    //   probe2: OnDisable                  (probe.enabled=false)
    //   （无）×2                           (parent false / true，子组件禁用中)
    //   probe2: OnEnable                   (enabled=true)
    //
    // [E3] C. Start/Update 门控
    //   probe3: Awake, OnEnable            (AddComponent)
    //   probe3: OnDisable                  (enabled=false)
    //   [E3] 标记后无 Start/Update         (禁用 3 帧)
    //   probe3: OnEnable                   (enabled=true)
    //   probe3: Start, Update#1, LateUpdate#1, Update#2, LateUpdate#2   (启用后 3 帧内)
    //   probe3: OnDisable                  (enabled=false)
    //   [E3] 标记后无 Update               (禁用 2 帧)
    //
    // [E5] E. 销毁路径（probe3 启用状态下 Destroy 其 GO）
    //   probe3: OnEnable                   (enabled=true)
    //   probe3: OnDisable, OnDestroy       (下帧 Flush 阶段)
    // ==============================================================================

    private void EnableLogTest()
    {
        // [E1] A. enabled 去重
        var go = new GameObject("EnableTestGO");
        var p = go.AddComponent<EnableProbe>();
        p.enabled = false;
        p.enabled = false;
        p.enabled = true;
        p.enabled = true;
        Log.Info("[E1] expect Awake+OnEnable+OnDisable+OnEnable above");

        // [E2] B. enabled × SetActive 组合
        go.SetActive(false);
        go.SetActive(false);
        go.SetActive(true);
        p.enabled = false;
        go.SetActive(false);
        go.SetActive(true);
        p.enabled = true;
        Log.Info("[E2] expect OnDisable+OnEnable+OnDisable+OnEnable above");

        // [E4] D. 子分支传播
        var parent = new GameObject("EnableTestParent");
        var child = new GameObject("EnableTestChild", parent);
        var pc = child.AddComponent<EnableProbe>();
        parent.SetActive(false);
        parent.SetActive(true);
        pc.enabled = false;
        parent.SetActive(false);
        parent.SetActive(true);
        pc.enabled = true;
        Log.Info("[E4] expect probe2 Awake/OnEnable/OnDisable/OnEnable/OnDisable/OnEnable above");

        EnableLogTestAsync(go);
    }

    private static async void EnableLogTestAsync(GameObject go)
    {
        // [E3] C. Start/Update 门控
        var go2 = new GameObject("EnableTestGO2");
        var p2 = go2.AddComponent<EnableProbe>();
        p2.enabled = false;
        await Task.Delay(80);
        Log.Info("[E3] expect probe3 Awake/OnEnable/OnDisable above, then nothing");
        p2.enabled = true;
        await Task.Delay(80);
        Log.Info("[E3] expect probe3 OnEnable + Start + Update/LateUpdate#1-2 above");
        p2.enabled = false;
        await Task.Delay(60);
        Log.Info("[E3] expect probe3 OnDisable above, then nothing");

        // [E5] E. 销毁路径（probe1 所在 GO 处于启用状态下销毁；probe3 仅重新启用）
        p2.enabled = true;
        go.Destroy();
        await Task.Delay(60);
        Log.Info("[E5] expect probe3 OnEnable above, then probe1 OnDisable+OnDestroy");
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

public class EnableProbe : Component
{
    private static int _nextId = 1;

    private readonly string _tag;
    private int _updateCount;
    private int _lateUpdateCount;

    public EnableProbe()
    {
        _tag = "probe" + _nextId;
        _nextId++;
    }

    public override void Awake()
    {
        Log.Info(_tag + ": Awake");
    }

    public override void OnEnable()
    {
        Log.Info(_tag + ": OnEnable");
    }

    public override void OnDisable()
    {
        Log.Info(_tag + ": OnDisable");
    }

    public override void Start()
    {
        Log.Info(_tag + ": Start");
    }

    public override void Update()
    {
        if (_updateCount >= 2) return;
        _updateCount++;
        Log.Info(_tag + ": Update#" + _updateCount);
    }

    public override void LateUpdate()
    {
        if (_lateUpdateCount >= 2) return;
        _lateUpdateCount++;
        Log.Info(_tag + ": LateUpdate#" + _lateUpdateCount);
    }

    public override void OnDestroy()
    {
        Log.Info(_tag + ": OnDestroy");
    }
}
