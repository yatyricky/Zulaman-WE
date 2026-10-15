using StdLib;

public enum StatEventType
{
    NONE,
    MAX_HP,
}

public enum StatId
{
    BASE_HP,
    EX_MAX_HP,
}

public class StatConfigEntry
{
    public StatId ID;
    public string Name;
    public StatType Type;
    public string Description;
    public StatEventType EventType;
}

public class StatConfig
{
    public static List<StatConfigEntry> Data = new()
    {
        new StatConfigEntry{ID = StatId.BASE_HP, Name = "basehp", Type = StatType.INT, Description = "basehp pts", EventType = StatEventType.MAX_HP},
        new StatConfigEntry{ID = StatId.EX_MAX_HP, Name = "maxhp", Type = StatType.INT, Description = "ex max hp pts", EventType = StatEventType.MAX_HP},
    };

    public static StatConfigEntry FindByID(StatId id)
    {
        foreach (var item in Data)
        {
            if (item.ID == id)
            {
                return item;
            }
        }
        throw new System.Exception("Not implemented");
    }
}