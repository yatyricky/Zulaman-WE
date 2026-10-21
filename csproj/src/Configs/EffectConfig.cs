using StdLib;

public class EffectConfigEntry
{
    public string ID = null!;
    public EffectType Type; 
    // public 
}

public class EffectConfig
{
    public static List<EffectConfigEntry> Data =
    [
        new() {ID = "001", Type = EffectType.Damage},
    ];

    public static EffectConfigEntry FindByID(string id)
    {
        foreach (var entry in Data)
        {
            if (entry.ID == id)
            {
                return entry;
            }
        }
        throw new System.Exception($"EffectConfig not found for ID: {id}");
    }
}
