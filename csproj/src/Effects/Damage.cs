using SFLib.Interop;

public class Damage : Effect
{
    public static void Exec(EffectConfigEntry effect, Pipeline pipeline)
    {
        var spellCtx = pipeline.SpellCtx;

        var data = effect.Data as DamageData;
        if (data == null) throw new System.Exception($"effect {effect.ID} expects DamageData, got null");

        var casterStats = StatsComponent.FindComp(spellCtx.CastingUnit);
        var amount = data.amount;
        if (data.isPhyx)
        {
            amount += GetRandomInt(casterStats.meleeLow, casterStats.meleeHigh) * data.apScale;
            amount *= 1 + casterStats.phyxDamageDealt;
        }
        else
        {
            amount += casterStats.sp * data.spScale;
            amount *= 1 + casterStats.mageDamageDealt;
        }
        foreach (var target in spellCtx.RTTargets)
        {
            var targetStats = StatsComponent.FindComp(target);
            var dmg = amount;
            if (data.isPhyx)
            {
                dmg *= targetStats.phyxDamageTakenPct;
            }
            else
            {
                dmg *= targetStats.mageDamageTakenPct + casterStats.GetStat(StatId.MagePierce).floatVal;
            }
            dmg = math.max(0, dmg);
            UnitDamageTarget(spellCtx.CastingUnit, target, dmg, false, true, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_DIVINE, data.wtype);
        }
    }
}
