using StdLib;

public class AbilityConfig
{

    public class AbilityConfigEntry
    {
        public int ID { get; internal set; }
        public SpellUnitType SUType { get; internal set; }
        public List<string> Effects { get; internal set; } = null!;
    }

    public static List<AbilityConfigEntry> Data =
    [
        new(){ID = FourCC("A004"), SUType = SpellUnitType.TargetUnit, Effects = ["001", "003", "004"]},
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
