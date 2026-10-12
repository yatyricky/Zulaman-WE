using StdLib;

public class Transform : Component
{
    public Vector3 localPosition;
    public Quaternion localRotation;
    public Vector3 localScale;

    public List<Transform> children = new List<Transform>();
    public Transform? parent { get; private set; }

    public Vector3 position
    {
        get
        {
            if (parent == null) return localPosition;
            var globalPos = localPosition;
            var globalRot = localRotation;
            var globalScale = localScale;
            var myParent = parent;
            while (myParent != null)
            {
                globalPos = myParent.localPosition + myParent.localRotation * Vector3.Scale(myParent.localScale, globalPos);
                globalRot = myParent.localRotation * globalRot;
                globalScale = Vector3.Scale(myParent.localScale, globalScale);
                myParent = myParent.parent;
            }
            return globalPos;
        }
        set
        {
            if (parent == null)
            {
                localPosition = value;
                return;
            }
            var pos = value;
            var myParent = parent;
            while (myParent != null)
            {
                pos = pos - myParent.localPosition;
                pos = Vector3.Scale(new Vector3(1f / myParent.localScale.x, 1f / myParent.localScale.y, 1f / myParent.localScale.z), pos);
                pos = Quaternion.Inverse(myParent.localRotation) * pos;
                myParent = myParent.parent;
            }
            localPosition = pos;
        }
    }

    public Transform()
    {
        localPosition = new Vector3(0f, 0f, 0f);
        localRotation = Quaternion.Euler(0f, 0f, 0f);
        localScale = new Vector3(1f, 1f, 1f);
    }

    public override string GetInspectorText()
    {
        return "Position: " + localPosition.ToString() + "\n"
             + "Rotation: " + localRotation.eulerAngles.ToString() + "\n"
             + "Scale: " + localScale.ToString() + "\n"
             + "Children: " + children.Count;
    }

    public void SetParent(Transform? newParent)
    {
        if (parent != null)
        {
            parent.children.Remove(this);
        }

        parent = newParent;

        if (parent != null)
        {
            parent.children.Add(this);
        }
    }

    private static Transform? _Find(Transform current, string[] parts, int index)
    {
        if (index >= parts.Length) return current;
        foreach (var child in current.children)
        {
            if (child.gameObject.name == parts[index])
            {
                var found = _Find(child, parts, index + 1);
                if (found != null) return found;
            }
        }
        return null;
    }

    /// <summary>
    /// Finds a child by name n and returns it.
    /// If no child with name n can be found, null is returned. If n contains a '/' character it will access the Transform in the hierarchy like a path name.
    /// </summary>
    /// <param name="name"></param>
    /// <returns></returns>
    public Transform? Find(string name)
    {
        var parts = name.Split('/');
        return _Find(this, parts, 0);
    }
}
