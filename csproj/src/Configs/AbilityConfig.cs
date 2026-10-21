using StdLib;

public class AbilityConfigEntry
{
    public int ID;
    public SpellUnitType SUType;
    public AbilityModel Model = null!;
    public List<string> Effects = null!;
}

public class AbilityConfig
{
    public static List<AbilityConfigEntry> Data =
    [
        new(){ID = FourCC("A004"), Model = new ArcaneShock(), SUType = SpellUnitType.TargetUnit, Effects = ["001"]},
    ];

    public static AbilityConfigEntry FindByID(int id)
    {
        foreach (var entry in Data)
        {
            if (entry.ID == id)
            {
                return entry;
            }
        }
        throw new System.Exception($"AbilityConfig not found for ID: {id}");
    }
}
