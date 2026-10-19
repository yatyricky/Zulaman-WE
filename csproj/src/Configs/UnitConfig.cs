using StdLib;

public class UnitConfigEntry
{
    public int UTID;
    public Dictionary<StatId, StatValue> BaseStats = null!;
}


public class StatValue
{
    public int intVal;
    public float floatVal;
}

public class UnitConfig
{
    public static List<UnitConfigEntry> Data = new()
    {
        new UnitConfigEntry{UTID = FourCC("Hmkg"), BaseStats = new(){ {StatId.BaseHp, new (){intVal = 759}} }},
    };

    public static UnitConfigEntry FindByUTID(int utid)
    {
        foreach (var item in Data)
        {
            if (item.UTID == utid)
            {
                return item;
            }
        }
        throw new System.Exception($"unit not configured {utid}");
    }
}