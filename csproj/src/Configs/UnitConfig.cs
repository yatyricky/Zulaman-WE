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

    public static StatValue operator +(StatValue left, StatValue right)
    {
        return new StatValue
        {
            intVal = left.intVal + right.intVal,
            floatVal = left.floatVal + right.floatVal,
        };
    }

    public static bool operator ==(StatValue left, StatValue right)
    {
        return left.intVal == right.intVal && left.floatVal == right.floatVal;
    }

    public static bool operator !=(StatValue left, StatValue right)
    {
        return !(left == right);
    }
}

public class UnitConfig
{
    public static List<UnitConfigEntry> Data = new()
    {
        new UnitConfigEntry{UTID = FourCC("Hmkg"), BaseStats = new(){ {StatId.BaseHp, new (){intVal = 760}} }},
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