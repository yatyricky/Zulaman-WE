public class Damage : Effect
{
    public struct Args
    {
        public unit source;
        public unit target;
        public float amount;
        public string name;
        public bool isPhyx;
        public bool isAttack;
        public bool isDirect;
        public bool canCrit;
        public bool canDodge;
        public weapontype wtype;
    }

    public Args args;

    public void Run()
    {
        UnitDamageTarget(args.source, args.target, args.amount, args.isAttack, true, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_DIVINE, args.wtype);
    }
}
