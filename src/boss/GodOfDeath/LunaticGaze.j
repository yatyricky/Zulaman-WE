//! zinc
library LunaticGaze {

	function playLightningAnimation(unit origin) {
		integer i;
		for (0 <= i < PlayerUnits.n) {
			AddTimedLight.atUnits("LEAS", origin, PlayerUnits.units[i], 1.05);
		}
	}
	
    function response(CastingBar cd) {
        integer i;
        vector origin = vector.create(GetUnitX(cd.caster), GetUnitY(cd.caster), 0);
        vector v = vector.create(0, 0, 0);
        vector normal = vector.create(0, 0, 1);
        vector target = vector.create(0, 0, 0);
		for (0 <= i < PlayerUnits.n) {
			v.reset(1, 0, 0);
			v.rotate(normal, GetUnitFacing(PlayerUnits.units[i]) / bj_RADTODEG);
			target.reset(GetUnitX(PlayerUnits.units[i]), GetUnitY(PlayerUnits.units[i]), 0);
			target.subtract(origin);
			if (vector.getAngle(target, v) < bj_PI * 0.5) {
				ModUnitMana(cd.caster, 1);

				AddTimedLight.atUnits("LEAS", cd.caster, PlayerUnits.units[i], 1.05);
			}
		}
		origin.destroy();
		v.destroy();
		normal.destroy();
		target.destroy();

        playLightningAnimation(cd.caster);
    }
    
    function onChannel() {
        CastingBar cb = CastingBar.create(response);
        cb.channel(10);
        playLightningAnimation(SpellEvent.CastingUnit);
    }

    function onInit() {
        RegisterSpellChannelResponse(SID, onChannel);
    }
}
//! endzinc
