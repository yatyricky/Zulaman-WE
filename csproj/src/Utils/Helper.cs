public class Helper
{
    private static int _abilIdAmrf = FourCC("Amrf");

    public static void SetUnitFlyable(unit u)
    {
        UnitAddAbility(u, _abilIdAmrf);
        UnitRemoveAbility(u, _abilIdAmrf);
    }

    public static bool IsUnitDummy(unit u)
    {
        return GetUnitPointValue(u) % 2 == 0;
    }

    public static string DamageType2String(damagetype dt)
    {
        if (dt == DAMAGE_TYPE_UNKNOWN) return "UNKNOWN";
        if (dt == DAMAGE_TYPE_NORMAL) return "NORMAL";
        if (dt == DAMAGE_TYPE_ENHANCED) return "ENHANCED";
        if (dt == DAMAGE_TYPE_FIRE) return "FIRE";
        if (dt == DAMAGE_TYPE_COLD) return "COLD";
        if (dt == DAMAGE_TYPE_LIGHTNING) return "LIGHTNING";
        if (dt == DAMAGE_TYPE_POISON) return "POISON";
        if (dt == DAMAGE_TYPE_DISEASE) return "DISEASE";
        if (dt == DAMAGE_TYPE_DIVINE) return "DIVINE";
        if (dt == DAMAGE_TYPE_MAGIC) return "MAGIC";
        if (dt == DAMAGE_TYPE_SONIC) return "SONIC";
        if (dt == DAMAGE_TYPE_ACID) return "ACID";
        if (dt == DAMAGE_TYPE_FORCE) return "FORCE";
        if (dt == DAMAGE_TYPE_DEATH) return "DEATH";
        if (dt == DAMAGE_TYPE_MIND) return "MIND";
        if (dt == DAMAGE_TYPE_PLANT) return "PLANT";
        if (dt == DAMAGE_TYPE_DEFENSIVE) return "DEFENSIVE";
        if (dt == DAMAGE_TYPE_DEMOLITION) return "DEMOLITION";
        if (dt == DAMAGE_TYPE_SLOW_POISON) return "SLOW_POISON";
        if (dt == DAMAGE_TYPE_SPIRIT_LINK) return "SPIRIT_LINK";
        if (dt == DAMAGE_TYPE_SHADOW_STRIKE) return "SHADOW_STRIKE";
        if (dt == DAMAGE_TYPE_UNIVERSAL) return "UNIVERSAL";
        return "UNDEFINED";
    }
}