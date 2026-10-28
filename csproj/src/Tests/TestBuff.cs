public class TestBuff : Buff
{
    public override void OnApply()
    {
        BJDebugMsg("[Buff] apply " + Config.Name + " -> " + Helper.GetUnitNameEx(Owner) + " stacks=" + I2S(Stacks));
    }

    public override void OnTick()
    {
        BJDebugMsg("[Buff] tick " + Config.Name + " -> " + Helper.GetUnitNameEx(Owner)
            + " remaining=" + I2S(RemainingMs())
            + " next=" + I2S(NextTickInMs())
            + " stacks=" + I2S(Stacks));
    }

    public override void OnStackChanged(int oldStacks, int newStacks)
    {
        BJDebugMsg("[Buff] stacks " + I2S(oldStacks) + " -> " + I2S(newStacks));
    }

    public override void OnRefresh()
    {
        BJDebugMsg("[Buff] refresh " + Config.Name + " -> " + Helper.GetUnitNameEx(Owner));
    }

    public override void OnRemove(BuffRemoveReason reason)
    {
        var name = Holder == null || !Holder.NativeValid ? "removed" : Helper.GetUnitNameEx(Owner);
        BJDebugMsg("[Buff] remove " + Config.Name + " -> " + name + " reason=" + I2S((int)reason));
    }

    public override void OnTransfer(BuffHolder from)
    {
        BJDebugMsg("[Buff] transfer " + Config.Name + " from " + Helper.GetUnitNameEx(from.Owner)
            + " to " + Helper.GetUnitNameEx(Owner)
            + " remaining=" + I2S(RemainingMs()));
    }
}
