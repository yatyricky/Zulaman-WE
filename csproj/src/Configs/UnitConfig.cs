using StdLib;

public class UnitConfigEntry
{
    public int UTID;
    public UnitAttrType PrimaryAttr;
    public Dictionary<StatId, StatValue> BaseStats = null!;
}

public class UnitConfig
{
    public static List<UnitConfigEntry> Data = new()
    {
        new UnitConfigEntry{UTID = FourCC("Hmkg"), PrimaryAttr = UnitAttrType.Strength, BaseStats = new(){ {StatId.BaseHp, 760},{StatId.BaseMp, 220} }},
        new UnitConfigEntry{UTID = FourCC("Hjai"), PrimaryAttr = UnitAttrType.Intelligence, BaseStats = new(){ {StatId.BaseHp, 350},{StatId.BaseMp,  440} }},
        new UnitConfigEntry{UTID = FourCC("hfoo"), PrimaryAttr = UnitAttrType.None, BaseStats = new(){ {StatId.BaseHp,  420} }},
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
