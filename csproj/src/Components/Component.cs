public class Component
{
    public GameObject gameObject { get; internal set; } = null!;

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
