using StdLib;

/// <summary>
/// FrameComponent 的图片填充：在同名 GameObject 上创建 BACKDROP 子帧，
/// BlzFrameSetAllPoints 跟随 FrameComponent 的 rect。texture 为 null 时隐藏。
/// 可见性 = enabled（组件有效状态）∧ GameObject activeInHierarchy ∧ texture != null，
/// 不暴露独立 visible。
/// </summary>
public class FrameImage : Component
{
    private static int _nextId = 1;

    private string? _texture;
    private bool _dirty = true;
    private framehandle? _native;
    private FrameComponent? _frame;

    /// <summary>贴图路径，如 "ReplaceableTextures\\CommandButtons\\BTNHeroPaladin"；null = 隐藏。</summary>
    public string? texture
    {
        get { return _texture; }
        set { _texture = value; SetDirty(); }
    }

    public override void Start()
    {
        _frame = gameObject.GetComponent<FrameComponent>();
        if (_frame != null)
        {
            _frame.RegisterImage(this);
        }
    }

    public override void OnEnable()
    {
        SetDirty();
    }

    public override void OnDisable()
    {
        // 失活后 LateUpdate 不再执行，必须在此同步推送隐藏
        var native = _native;
        if (native != null)
        {
            BlzFrameSetVisible(native, false);
        }
    }

    public override void LateUpdate()
    {
        if (!_dirty) return;
        var frame = _frame;
        if (frame == null) return;
        var parentNative = frame.nativeFrame;
        if (parentNative == null) return; // FrameComponent 尚未创建，保持脏，下帧重试

        var native = _native;
        if (native == null)
        {
            native = BlzCreateFrameByType("BACKDROP", "SFUI_Img_" + _nextId, parentNative, "", 0);
            _nextId++;
            BlzFrameSetAllPoints(native, parentNative);
            _native = native;
        }

        var tex = _texture;
        if (tex != null)
        {
            BlzFrameSetTexture(native, tex, 0, false);
            BlzFrameSetVisible(native, true); // 能执行到这里说明 enabled 且 activeInHierarchy
        }
        else
        {
            BlzFrameSetVisible(native, false);
        }

        _dirty = false;
    }

    public framehandle? nativeFrame
    {
        get { return _native; }
    }

    internal void DestroyNative()
    {
        var native = _native;
        if (native == null) return;
        BlzDestroyFrame(native);
        _native = null;
    }

    private void SetDirty()
    {
        _dirty = true;
    }
}
