
using StdLib;

public class BuffHolder : Component
{
    private StatsComponent _statsComp = null!;
    private List<Buff> _buffs = [];

    public override void Awake()
    {
        _statsComp = gameObject.GetComponent<StatsComponent>() ?? throw new System.Exception("unable to find StatsComponent in object");
    }

}
