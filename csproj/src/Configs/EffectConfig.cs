using StdLib;

public class EffectConfigEntry
{
    public string ID;
    public EffectType Type; 
    // public 
}

public class EffectConfig
{
    public static List<EffectConfigEntry> Data = new List<EffectConfigEntry>
    {
        // new EffectConfigEntry{ID = "001", Type = EffectType.DAMAGE, DamageArgs},
    };
}
