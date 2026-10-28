using StdLib;

public class DamageData : EffectDataBase
{
    public float amount = 0f;
    public float apScale = 0f;
    public float spScale = 0f;
    public string name = "unknown damage";
    public bool isPhyx = true;
    public bool isDirect = true;
    public float exCrit = 0f;
    public float exHit = 0f;
    public weapontype wtype = WEAPON_TYPE_WHOKNOWS;
}

public class PlaySFXData : EffectDataBase
{
    public SpellUnitType whichTarget;
    public string attachPoint = "origin";
    public int duration = 0;
    public string filePath = "";
}

public class EffectConfigEntry
{
    public string ID = null!;
    public EffectType Type; 
    public EffectDataBase Data = null!;
}

public class EffectConfig
{
    public static List<EffectConfigEntry> Data =
    [
        new() {ID = "001", Type = EffectType.Damage, Data = new DamageData(){amount = 100, spScale = 1, name = "arcane shock dmg", isPhyx = false}},
        new() {ID = "002", Type = EffectType.Damage, Data = new DamageData(){apScale = 1, name = "managed melee attack"}},
        new() { ID = "003", Type = EffectType.PlaySFX, Data = new PlaySFXData() { filePath = "Abilities/Spells/Human/ManaFlare/ManaFlareBoltImpact.mdl", whichTarget = SpellUnitType.CurrentTargetUnit } }
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
