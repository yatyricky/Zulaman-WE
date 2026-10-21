public class Damage : Effect
{
    public class Context
    {
        public float amount;
        public string name = null!;
        public bool isPhyx;
        public bool isAttack;
        public bool isDirect;
        public bool canCrit;
        public bool canDodge;
        public weapontype wtype = null!;
    }

    public static void Exec(Pipeline pipeline)
    {
        var spellCtx = pipeline.SpellCtx;
        var dmgCtx = pipeline.DamageCtx ?? throw new System.Exception("Damage context is null");

        foreach (var target in spellCtx.RTTargets)
        {
            UnitDamageTarget(spellCtx.CastingUnit, target, dmgCtx.amount, dmgCtx.isAttack, true, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_DIVINE, dmgCtx.wtype);
        }
    }
}
