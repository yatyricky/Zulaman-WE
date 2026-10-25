using StdLib;

public class UnitConfigEntry
{
    public int UTID;
    public UnitAttrType PrimaryAttr;
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

    // public static implicit operator float(StatValue v)
    // {
    //     return v.floatVal;
    // }
}

public class UnitConfig
{
    public static List<UnitConfigEntry> Data = new()
    {
        new UnitConfigEntry{UTID = FourCC("Hmkg"), PrimaryAttr = UnitAttrType.Strength, BaseStats = new(){ {StatId.BaseHp, new (){intVal = 760}},{StatId.BaseMp, new (){intVal = 220}} }},
        new UnitConfigEntry{UTID = FourCC("Hjai"), PrimaryAttr = UnitAttrType.Intelligence, BaseStats = new(){ {StatId.BaseHp, new (){intVal = 350}},{StatId.BaseMp, new (){intVal = 440}} }},
        new UnitConfigEntry{UTID = FourCC("hfoo"), PrimaryAttr = UnitAttrType.None, BaseStats = new(){ {StatId.BaseHp, new (){intVal = 420}} }},
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