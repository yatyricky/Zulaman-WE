public class Component
{
    public GameObject gameObject { get; internal set; } = null!;

    public Transform transform => gameObject.transform;

    internal bool _started;
    internal bool _awoke;
    private bool _enabled = true;
    internal bool _on;

    /// <summary>
    /// 启用状态（Unity Behaviour.enabled 语义）。组件实际生效还需要
    /// gameObject.activeInHierarchy；OnEnable/OnDisable 随 (enabled && activeInHierarchy)
    /// 的有效状态变化触发，分别只在其为 true/false 时调用。
    /// Update/LateUpdate 只在生效期间执行；Start 只在生效时消费。
    /// </summary>
    public bool enabled
    {
        get { return _enabled; }
        set
        {
            if (_enabled == value) return;
            _enabled = value;
            UpdateOnState();
        }
    }

    /// <summary>按当前 enabled 与 activeInHierarchy 收敛有效状态，供 enabled setter 与 GameObject 分支迁移共用。</summary>
    internal void UpdateOnState()
    {
        var should = _enabled && gameObject.activeInHierarchy;
        if (should == _on) return;
        if (should)
        {
            if (!_awoke)
            {
                Awake();
                _awoke = true;
            }
            _on = true;
            OnEnable();
        }
        else
        {
            _on = false;
            OnDisable();
        }
    }

    public virtual string GetInspectorText()
    {
        return string.Empty;
    }

    public virtual void Awake()
    {
    }

    public virtual void OnEnable()
    {
    }

    public virtual void Start()
    {
    }

    public virtual void Update()
    {
    }

    public virtual void LateUpdate()
    {
    }

    public virtual void OnDisable()
    {
    }

    public virtual void OnDestroy()
    {
    }
}
