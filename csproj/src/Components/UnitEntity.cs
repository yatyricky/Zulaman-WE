public class UnitEntity : Component
{
    public unit owner { get; private set; } = null!;

    internal void Bind(unit u)
    {
        owner = u;
    }
}
