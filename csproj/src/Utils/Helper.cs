public class Helper
{
    private static int _abilIdAmrf = FourCC("Amrf");

    public static void SetUnitFlyable(unit u)
    {
        UnitAddAbility(u, _abilIdAmrf);
        UnitRemoveAbility(u, _abilIdAmrf);
    }
}