//! zinc
library FrenzyWarlock requires SpellEvent, BuffSystem {
#define ART_LEFT "Abilities\\Spells\\Orc\\Bloodlust\\BloodlustTarget.mdl"
#define ART_RIGHT "Abilities\\Spells\\Orc\\Bloodlust\\BloodlustSpecial.mdl"
	private struct FrenzyWarlock {
		private timer tm;
		
		private method destroy() {
			ReleaseTimer(this.tm);
			this.tm = null;
			this.deallocate();
		}
		
		private static method run() {
			thistype this = GetTimerData(GetExpiredTimer());
			unit u = GetFireRune();
			if (u != null) {
				CreateUnit(Player(MOB_PID), UTID_LAVA_SPAWN, GetUnitX(u), GetUnitY(u), GetRandomReal(0, 360));
				CreateUnit(Player(MOB_PID), UTID_LAVA_SPAWN, GetUnitX(u), GetUnitY(u), GetRandomReal(0, 360));
				CreateUnit(Player(MOB_PID), UTID_LAVA_SPAWN, GetUnitX(u), GetUnitY(u), GetRandomReal(0, 360));
				AddTimedEffect.atCoord(ART_DOOM, GetUnitX(u), GetUnitY(u), 0.5);
				KillUnit(u);
				NextFireRune();
			} else {
				this.destroy();
			}
		}
	
		static method start() {
			thistype this = thistype.allocate();
			this.tm = NewTimer();
			SetTimerData(this.tm, this);
			TimerStart(this.tm, 0.6, true, function thistype.run);
		}
	}

    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].damageDealt += buf.bd.r0;
        UnitProp[buf.bd.target].ModAttackSpeed(buf.bd.i0);
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].damageDealt -= buf.bd.r0;
        UnitProp[buf.bd.target].ModAttackSpeed(0 - buf.bd.i0);
    }
    
    function onCast() {       
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BID_FRENZY_WARLOCK);
        buf.bd.tick = -1;
        buf.bd.interval = 200;
        UnitProp[buf.bd.target].damageDealt -= buf.bd.r0;
        buf.bd.r0 = 0.3;
        UnitProp[buf.bd.target].ModAttackSpeed(0 - buf.bd.i0);
        buf.bd.i0 = 50;
        if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_LEFT, buf, "hand, left");}
        if (buf.bd.e1 == 0) {buf.bd.e1 = BuffEffect.create(ART_RIGHT, buf, "hand, right");}
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
		FrenzyWarlock.start();
    }

    function onInit() {
        RegisterSpellEffectResponse(SIDFRENZYWARLOCK, onCast);
        BuffType.register(BID_FRENZY_WARLOCK, BUFF_PHYX, BUFF_POS);
    }
#undef ART_RIGHT
#undef ART_LEFT
}
//! endzinc
