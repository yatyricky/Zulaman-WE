using StdLib;

/// <summary>
/// uGUI RectTransform 风格的布局组件。每个组件对应一个 war3 native FRAME，
/// 父子关系沿 GameObject 层级映射（祖先最近一个 FrameComponent 为布局父，无则挂 GAME_UI）。
/// 坐标单位为 war3 frame 单位（全屏 0.8×0.6，原点左下）。war3 frame 无旋转，故无 rotation 属性。
/// </summary>
public class FrameComponent : Component
{
    private static int _nextId = 1;

    private Vector2 _anchorMin = new Vector2(0.5f, 0.5f);
    private Vector2 _anchorMax = new Vector2(0.5f, 0.5f);
    private Vector2 _anchoredPosition = new Vector2(0f, 0f);
    private Vector2 _sizeDelta = new Vector2(0.1f, 0.1f);
    private Vector2 _pivot = new Vector2(0.5f, 0.5f);
    private float _scale = 1f;
    private bool _visible = true;
    private bool _raycastTarget = false;
    private string? _frameName;

    private bool _dirty = true;
    private bool _enableDirty = true;
    private framehandle? _native;
    private Vector2 _appliedSize;
    private List<FrameImage> _images = new List<FrameImage>();

    /// <summary>相对父矩形的 0..1 锚点。anchorMin == anchorMax 为点锚，否则为拉伸锚。</summary>
    public Vector2 anchorMin
    {
        get { return _anchorMin; }
        set { _anchorMin = value; SetDirty(); }
    }

    public Vector2 anchorMax
    {
        get { return _anchorMax; }
        set { _anchorMax = value; SetDirty(); }
    }

    /// <summary>pivot 相对锚点的位置。</summary>
    public Vector2 anchoredPosition
    {
        get { return _anchoredPosition; }
        set { _anchoredPosition = value; SetDirty(); }
    }

    /// <summary>点锚时为实际尺寸；拉伸时为超出锚点区域的尺寸修正量（与 Unity 同规则）。</summary>
    public Vector2 sizeDelta
    {
        get { return _sizeDelta; }
        set { _sizeDelta = value; SetDirty(); }
    }

    public Vector2 pivot
    {
        get { return _pivot; }
        set { _pivot = value; SetDirty(); }
    }

    /// <summary>
    /// 仅放大 sizeDelta 贡献的尺寸，不参与 anchoredPosition/offsets（v1 简化，与 Unity 有差异）。
    /// 不使用 BlzFrameSetScale，规避偏移被 scale 除的引擎行为。
    /// </summary>
    public float scale
    {
        get { return _scale; }
        set { _scale = value; SetDirty(); }
    }

    public bool visible
    {
        get { return _visible; }
        set { _visible = value; SetDirty(); }
    }

    /// <summary>false 时 BlzFrameSetEnable(false)；FRAME 默认会抢占鼠标事件，容器保持 false。</summary>
    public bool raycastTarget
    {
        get { return _raycastTarget; }
        set { _raycastTarget = value; _enableDirty = true; }
    }

    /// <summary>native frame 名，创建后不可改；未设置则自动生成。</summary>
    public string? frameName
    {
        get { return _frameName; }
        set { _frameName = value; }
    }

    public framehandle? nativeFrame
    {
        get { return _native; }
    }

    /// <summary>上次应用后的实际尺寸，供子帧布局使用。</summary>
    public Vector2 appliedSize
    {
        get { return _appliedSize; }
    }

    public void RegisterImage(FrameImage image)
    {
        _images.Add(image);
    }

    public override void OnEnable()
    {
        // 分支激活后 LateUpdate 恢复执行，下帧 apply 恢复显示
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
        ApplyWithAncestors();
    }

    public override void OnDestroy()
    {
        for (int i = 0; i < _images.Count; i++)
        {
            _images[i].DestroyNative();
        }
        _images.Clear();

        var native = _native;
        if (native != null)
        {
            BlzDestroyFrame(native);
            _native = null;
        }
    }

    private void SetDirty()
    {
        _dirty = true;
    }

    private void ApplyWithAncestors()
    {
        var parentFrame = FindParentFrame();
        if (parentFrame != null)
        {
            parentFrame.ApplyWithAncestors();
        }
        ApplyNow();
    }

    private FrameComponent? FindParentFrame()
    {
        var t = transform.parent;
        while (t != null)
        {
            var f = t.gameObject.GetComponent<FrameComponent>();
            if (f != null)
            {
                return f;
            }
            t = t.parent;
        }
        return null;
    }

    private void ApplyNow()
    {
        if (!_dirty && !_enableDirty) return;
        EnsureNative();
        var native = _native;
        if (native == null) return;

        framehandle parentNative;
        float parentW;
        float parentH;
        var parentFrame = FindParentFrame();
        if (parentFrame != null)
        {
            // ApplyWithAncestors 已保证父帧已应用，此处只读其结果
            var pn = parentFrame._native;
            if (pn == null) return;
            parentNative = pn;
            parentW = parentFrame._appliedSize.x;
            parentH = parentFrame._appliedSize.y;
        }
        else
        {
            parentNative = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0);
            parentW = 0.8f;
            parentH = 0.6f;
        }

        var sdX = _sizeDelta.x * _scale;
        var sdY = _sizeDelta.y * _scale;

        if (_anchorMin == _anchorMax)
        {
            // 点锚：尺寸 + 中心点偏移
            BlzFrameSetSize(native, sdX, sdY);
            var px = (_anchorMin.x - 0.5f) * parentW + _anchoredPosition.x + (0.5f - _pivot.x) * sdX;
            var py = (_anchorMin.y - 0.5f) * parentH + _anchoredPosition.y + (0.5f - _pivot.y) * sdY;
            BlzFrameSetPoint(native, FRAMEPOINT_CENTER, parentNative, FRAMEPOINT_CENTER, px, py);
        }
        else
        {
            // 拉伸：双角点定尺寸，不调 SetSize
            var blx = _anchorMin.x * parentW + (_anchoredPosition.x - _pivot.x * sdX) - parentW * 0.5f;
            var bly = _anchorMin.y * parentH + (_anchoredPosition.y - _pivot.y * sdY) - parentH * 0.5f;
            var trx = _anchorMax.x * parentW + (_anchoredPosition.x + (1f - _pivot.x) * sdX) - parentW * 0.5f;
            var trY = _anchorMax.y * parentH + (_anchoredPosition.y + (1f - _pivot.y) * sdY) - parentH * 0.5f;
            BlzFrameSetPoint(native, FRAMEPOINT_BOTTOMLEFT, parentNative, FRAMEPOINT_CENTER, blx, bly);
            BlzFrameSetPoint(native, FRAMEPOINT_TOPRIGHT, parentNative, FRAMEPOINT_CENTER, trx, trY);
        }

        var newSize = new Vector2(
            (_anchorMax.x - _anchorMin.x) * parentW + sdX,
            (_anchorMax.y - _anchorMin.y) * parentH + sdY);
        var sizeChanged = newSize != _appliedSize;
        _appliedSize = newSize;

        if (_enableDirty)
        {
            BlzFrameSetEnable(native, _raycastTarget);
            _enableDirty = false;
        }

        BlzFrameSetVisible(native, _visible);

        _dirty = false;
        if (sizeChanged)
        {
            MarkDescendantsDirty(transform);
        }
    }

    private void EnsureNative()
    {
        if (_native != null) return;

        if (_frameName == null)
        {
            _frameName = "SFUI_Frame_" + _nextId;
            _nextId++;
        }

        framehandle parentNative;
        var parentFrame = FindParentFrame();
        if (parentFrame != null)
        {
            parentFrame.EnsureNative();
            var pn = parentFrame._native;
            if (pn == null) return;
            parentNative = pn;
        }
        else
        {
            parentNative = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0);
        }

        _native = BlzCreateFrameByType("FRAME", _frameName, parentNative, "", 0);
    }

    private static void MarkDescendantsDirty(Transform t)
    {
        var children = t.children;
        for (int i = 0; i < children.Count; i++)
        {
            var child = children[i];
            var f = child.gameObject.GetComponent<FrameComponent>();
            if (f != null)
            {
                f.SetDirty();
            }
            MarkDescendantsDirty(child);
        }
    }
}
