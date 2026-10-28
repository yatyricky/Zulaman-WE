using System;
using StdLib;

[Flags]
public enum BuffCategory
{
    Magic = 1,
    Physical = 2,
    Any = 3,
}

[Flags]
public enum BuffPolarity
{
    Positive = 1,
    Negative = 2,
    Any = 3,
}

public enum BuffStackMode
{
    Refresh,
    AddStack,
}

public enum BuffRefreshMode
{
    ResetDuration,
    AddDuration,
    KeepDuration,
}

public enum BuffRemoveReason
{
    Expired,
    Dispelled,
    Death,
    CasterDeath,
    UnitRemoved,
    Merged,
    Manual,
}

public enum BuffDetachReason
{
    Removed,
    Transferred,
}

public class BuffEffectDef
{
    public string Path = "";
    public string AttachPoint = "origin";
}

public class BuffConfigEntry
{
    public string ID = "";
    public string Name = "";
    public BuffCategory Category;
    public BuffPolarity Polarity;
    public bool Dispellable = true;
    public int Duration = -1;
    public int Interval = 0;
    public int FirstTickDelay = -1;
    public int MaxStacks = 1;
    public BuffStackMode StackMode = BuffStackMode.Refresh;
    public BuffRefreshMode RefreshMode = BuffRefreshMode.ResetDuration;
    public bool RefreshResetsTickPhase = false;
    public bool RemoveOnDeath = true;
    public bool RemoveOnCasterDeath = false;
    public string IconPath = "";
    public List<BuffEffectDef> Effects = [];
    public Dictionary<StatId, StatValue> StatModsPerStack = [];
    public List<string> TickEffectIds = [];
    public List<string> AttachEffectIds = [];
    public List<string> DetachEffectIds = [];
}

public class BuffConfig
{
    public static List<BuffConfigEntry> Data =
    [
        new BuffConfigEntry
        {
            ID = "001",
            Name = "Test Buff",
            Category = BuffCategory.Magic,
            Polarity = BuffPolarity.Positive,
            Duration = 5000,
            Interval = 1000,
            MaxStacks = 3,
            StackMode = BuffStackMode.AddStack,
            StatModsPerStack = new() { { StatId.AllDamageRes, 0.25f } },
        },
    ];

    public static BuffConfigEntry FindByID(string id)
    {
        foreach (var def in Data)
        {
            if (def.ID == id) return def;
        }
        throw new Exception("BuffConfig not found for ID: " + id);
    }
}
