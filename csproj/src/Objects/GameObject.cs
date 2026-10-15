using StdLib;
using System.Threading.Tasks;

public class GameObject
{
    private static readonly List<GameObject> _gameObjs = new();
    private static readonly List<GameObject> _destroyQueue = new();

    public static async void RunGameObjects()
    {
        while (true)
        {
            await Task.Delay(Const.DT);
            var count = _gameObjs.Count;
            for (int i = 0; i < count; i++)
            {
                _gameObjs[i].StartPendingComponents();
            }
            for (int i = 0; i < count; i++)
            {
                _gameObjs[i].Update();
            }
            for (int i = 0; i < count; i++)
            {
                _gameObjs[i].LateUpdate();
            }

            FlushDestroyQueue();
        }
    }

    private static void FlushDestroyQueue()
    {
        for (int i = 0; i < _destroyQueue.Count; i++)
        {
            DestroyQueued(_destroyQueue[i]);
        }

        _destroyQueue.Clear();
    }

    private static void MarkDestroyQueuedDepthFirst(GameObject obj)
    {
        if (obj.isDestroyQueued || obj.isDestroyed)
        {
            return;
        }

        obj.isDestroyQueued = true;

        foreach (var child in obj.transform.children)
        {
            MarkDestroyQueuedDepthFirst(child.gameObject);
        }
    }

    private static void DestroyDepthFirst(GameObject obj)
    {
        if (obj.isDestroyed)
        {
            return;
        }

        var children = obj.transform.children;
        for (int i = children.Count - 1; i >= 0; i--)
        {
            DestroyDepthFirst(children[i].gameObject);
        }

        obj.transform.SetParent(null);
        foreach (var comp in obj._components)
        {
            comp.OnDisable();
            comp.OnDestroy();
        }

        obj._components.Clear();
        _gameObjs.Remove(obj);
        obj.isDestroyed = true;
    }


    public string name { get; private set; }
    public Transform transform { get; private set; }
    private List<Component> _components = new List<Component>();
    public List<Component> components => _components;
    public bool isDestroyQueued { get; private set; }
    public bool isDestroyed { get; private set; }

    public GameObject(string name)
    {
        this.name = name;
        transform = AddComponent<Transform>();

        _gameObjs.Add(this);
    }

    public GameObject(string name, GameObject parent) : this(name)
    {
        transform.SetParent(parent.transform);
    }

    public T? GetComponent<T>() where T : Component
    {
        foreach (var comp in _components)
        {
            if (comp is T tComp)
            {
                return tComp;
            }
        }
        return null;
    }

    public T AddComponent<T>() where T : Component, new()
    {
        var comp = new T
        {
            gameObject = this
        };
        _components.Add(comp);
        comp.Awake();
        comp.OnEnable();
        return comp;
    }

    public void RemoveAllComponents<T>() where T : Component
    {
        for (int i = _components.Count - 1; i >= 0; i--)
        {
            if (_components[i] is T)
            {
                _components[i].OnDisable();
                _components[i].OnDestroy();
                _components.RemoveAt(i);
            }
        }
    }

    internal void StartPendingComponents()
    {
        if (isDestroyQueued || isDestroyed) return;
        var snapshot = new List<Component>(_components);
        foreach (var comp in snapshot)
        {
            if (comp._started) continue;
            comp._started = true;
            comp.Start();
        }
    }

    public void Update()
    {
        if (isDestroyQueued || isDestroyed) return;
        var snapshot = new List<Component>(_components);
        foreach (var comp in snapshot)
        {
            if (!comp._started) continue;
            comp.Update();
        }
    }

    public void LateUpdate()
    {
        if (isDestroyQueued || isDestroyed) return;
        var snapshot = new List<Component>(_components);
        foreach (var comp in snapshot)
        {
            if (!comp._started) continue;
            comp.LateUpdate();
        }
    }

    public void Destroy()
    {
        if (isDestroyQueued || isDestroyed)
        {
            return;
        }

        MarkDestroyQueuedDepthFirst(this);

        _destroyQueue.Add(this);
    }

    internal static void DestroyQueued(GameObject obj)
    {
        DestroyDepthFirst(obj);
    }

    public T? GetComponentInChildren<T>() where T : Component
    {
        foreach (var child in transform.children)
        {
            var comp = child.gameObject.GetComponent<T>();
            if (comp != null)
            {
                return comp;
            }
            comp = child.gameObject.GetComponentInChildren<T>();
            if (comp != null)
            {
                return comp;
            }
        }
        return null;
    }
}
