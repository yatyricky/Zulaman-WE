public class Damage : Effect
{
    public static void Exec(EffectConfigEntry effect, Pipeline pipeline, unit currentTarget)
    {
        if (effect.Data is not DamageData data) throw new System.Exception($"effect {effect.ID} expects DamageData, got null");

        var spellCtx = pipeline.SpellCtx;
        var casterStats = StatsComponent.FindComp(spellCtx.CastingUnit);
        var amount = data.amount;
        if (data.isPhyx)
        {
            amount += Math.RandomInt(casterStats.meleeLow, casterStats.meleeHigh) * data.apScale;
            amount *= 1 + casterStats.phyxDamageDealt;
        }
        else
        {
            amount += casterStats.sp * data.spScale;
            amount *= 1 + casterStats.mageDamageDealt;
        }

        var targetStats = StatsComponent.FindComp(currentTarget);
        var dmg = amount;
        if (data.isPhyx)
        {
            dmg *= targetStats.phyxDamageTakenPct;
        }
        else
        {
            dmg *= targetStats.mageDamageTakenPct + casterStats.GetStat(StatId.MagePierce);
        }
        dmg = Math.Max(0f, dmg);
        UnitDamageTarget(spellCtx.CastingUnit, currentTarget, dmg, false, true, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_DIVINE, data.wtype);
    }
}
