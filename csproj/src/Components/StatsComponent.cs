public class StatsComponent : Component
{
    

    public override void Awake()
    {
        
    }

    public static void NewUnit(CreateUnitEventData data)
    {

        var obj = new GameObject(Helper.GetUnitNameEx(data.u), Const.UnitsRoot);
        obj.AddComponent<StatsComponent>();
    }

    public static void Init()
    {
        CreateUnitEvent.Instance.Register(NewUnit);
    }
}
