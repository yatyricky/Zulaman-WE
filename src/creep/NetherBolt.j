//! zinc
library NetherBolt {
/*
deals 20% of max hp damage to self, deals 1000 magical damage to target
*/

    function onhit(Projectile p) -> boolean {
        Buff buf;
        if (TryReflect(p.target)) {
            p.reverse();
            return false;
        } else {
            DamageTarget(p.caster, p.target, p.r0, SpellData[SID].name, false, true, false, WEAPON_TYPE_WHOKNOWS);   
            
            return true;
        }
    }

	function onCast() {
		Projectile p = Projectile.create();
		real amt;
        p.caster = SpellEvent.CastingUnit;
        p.target = SpellEvent.TargetUnit;
        p.path = ART_MISSILE;
        p.pr = onhit;
        p.speed = 600;
        p.r0 = 1000.0;
        //BJDebugMsg("1??");
        p.launch();

        amt = GetUnitState(SpellEvent.CastingUnit, UNIT_STATE_MAX_lIFE) * 0.2;
        DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, amt, SpellData[SID].name, false, false, false, WEAPON_TYPE_WHOKNOWS);   
	}

	function onInit() {
		RegisterSpellEffectResponse(SID, onCast);
	}
}
//! endzinc
