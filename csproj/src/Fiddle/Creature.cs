public class Creature : Component
{
    public virtual void Cry()
    {
        BJDebugMsg("Creature is crying");
    }

    public override void Update()
    {
        Cry();
    }
}