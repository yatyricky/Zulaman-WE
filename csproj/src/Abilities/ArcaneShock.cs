public class ArcaneShock : AbilityModel
{
    public override void Process(Pipeline pipeline, int phase)
    {
        var dmgCtx = new Damage.Context
        {
            amount = 100,
            name = I2S(pipeline.SpellCtx.AbilityId),
            isPhyx = false,
            isAttack = false,
            isDirect = true,
            canCrit = true,
            canDodge = false,
            wtype = WEAPON_TYPE_WHOKNOWS,
        };
        pipeline.DamageCtx = dmgCtx;
    }
}
