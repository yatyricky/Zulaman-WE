using StdLib;

public enum TargetFrequency
{
    Once,
}

public class AbilityConfigEntry
{
    public int ID;
    // public 
}

public class AbilityConfig
{
    public static List<AbilityConfigEntry> Data = new List<AbilityConfigEntry>
    {
        new(){ID = SpellAbilityId.ArcaneShock, }
    };
}
