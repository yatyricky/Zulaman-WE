//! zinc
library LifeSiphon {

	struct LifeSiphon {
		private timer tm;
		private unit caster;
		private integer ctr;

		private method destroy() {
			ReleaseTimer(this.tm);
			this.tm = null;
			this.caster = null;
			this.deallocate();
		}

		private static method run() {
			thistype this = GetTimerData(GetExpiredTimer());
			integer i;
			Buff buf;
			real amt;
			this.ctr -= 1;
			if (ModuloInteger(this.ctr, 10) == 0) {
				for (0 <= i < PlayerUnits.n) {
					StunUnit(this.caster, PlayerUnits.units[i], 0.15);

					if (GetUnitAbilityLevel(PlayerUnits.units[i], BID) > 0) {
						AddTimedLight.atUnits("DRAL", this.caster, PlayerUnits.units[i], 0.1);
					} else {
						AddTimedLight.atUnits("DRAM", this.caster, PlayerUnits.units[i], 0.1);
						amt = GetUnitState(PlayerUnits.units[i], UNIT_STATE_MAX_LIFE) * 0.16;
						DamageTarget(this.caster, PlayerUnits.units[i], amt, SpellData[SID].name, false, false, false, WEAPON_TYPE_WHOKNOWS);
						HealTarget(this.caster, this.caster, amt * 30.0, SpellData[SID].name, 0.0);
						AddTimedEffect.atUnit(ART_HEAL, this.caster, "origin", 0.2);
					}
				}
			}
			if (this.ctr == 0) {
				UnitProp[caster].enable();
				for (0 <= i < PlayerUnits.n) {
					buf = BuffSlot[PlayerUnits.units[i]].getBuffByBid(BID);
					if (buf != 0) {
						BuffSlot[PlayerUnits.units[i]].dispelByBuff(buf);
					}
				}
				this.destroy();
			}
		}

		static method start(unit caster) {
			thistype this = thistype.allocate();
			integer i;
			this.caster = caster;
			this.ctr = 50;
			this.tm = NewTimer();
			UnitProp[caster].disable();
			SetTimerData(this.tm, this);
			TimerStart(this.tm, 0.1, true, function thistype.run);

			for (0 <= i < PlayerUnits.n) {
				StunUnit(caster, PlayerUnits.units[i], 0.15);

				if (GetUnitAbilityLevel(PlayerUnits.units[i], BID) > 0) {
					AddTimedLight.atUnits("DRAL", caster, PlayerUnits.units[i], 0.1);
				} else {
					AddTimedLight.atUnits("DRAM", caster, PlayerUnits.units[i], 0.1);
				}
			}
		}
	}

    function response(CastingBar cd) {
    	LifeSiphon.start(cd.caster);
    }

    function onChannel() {
        CastingBar.create(response).launch();
    }

    function onInit() {
        RegisterSpellChannelResponse(SID, onChannel);
    }
}
//! endzinc
