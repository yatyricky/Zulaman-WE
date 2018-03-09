//! zinc
library FilthyTentacle {
constant real INTERVAL = 0.04;
constant integer SPEED = 72;
constant real SLOW = 0.5;
    
    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].ModSpeed(0 - buf.bd.i0);
    }
    
    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].ModSpeed(buf.bd.i0);
    }

	struct FilthyTentacle {
		private timer tm;
		private unit caster, target;
		private vector vo, vt, dir;

		private method destroy() {
			this.vo.destroy();
			this.vt.destroy();
			this.dir.destroy();
			ReleaseTimer(this.tm);
			this.tm = null;
			this.caster = null;
			this.target = null;
			this.deallocate();
		}

		private static method run() {
			thistype this = GetTimerData(GetExpiredTimer());
			if (!IsUnitDead(this.target)) {
				// Move target towards the tentacle
				this.vt.reset(GetUnitX(this.target), GetUnitY(this.target), 0);
				this.dir.copy(this.vo);
				this.dir.subtract(this.vt);
				if (this.dir.getLength() < SPEED) {
					// arrived
					this.destroy();
				} else {
					this.dir.setLength(SPEED);
					this.vt.add(this.dir);
					SetUnitPosition(this.target, this.vt.x, this.vt.y);
				}

				AddTimedLight.atUnits("BPSE", this.target, this.caster, INTERVAL);
			}
		}

		static method start(unit caster, unit target) {
			thistype this = thistype.allocate();
			Buff buf;
			this.caster = caster;
			this.target = target;
			this.tm = NewTimer();
			this.vo = vector.create(GetUnitX(caster), GetUnitY(caster), 0);
			this.vt = vector.create(GetUnitX(target), GetUnitY(target), 0);
			this.dir = vector.create(0, 0, 0);
			SetTimerData(this.tm, this);
			TimerStart(this.tm, INTERVAL, true, function thistype.run);

			// slow effect
	        buf = Buff.cast(caster, target, BID);
	        buf.bd.tick = -1;
	        buf.bd.interval = 10;
	        UnitProp[buf.bd.target].ModSpeed(buf.bd.i0);
	        buf.bd.i0 = Rounding(UnitProp[buf.bd.target].Speed() * SLOW);
	        // effect
	        buf.bd.boe = onEffect;
	        buf.bd.bor = onRemove;
	        buf.run();

	        //
	        // AddTimedEffect.atUnit(ART_PLAGUE, SpellEvent.TargetUnit, "origin", 0.2);
		}
	}

	function onCast() {
		FilthyTentacle.start(SpellEvent.CastingUnit, SpellEvent.TargetUnit);
	}

	function onInit() {
		RegisterSpellEffectResponse(SID, onCast);
		BuffType.register(BID, BUFF_MAGE, BUFF_NEG);
	}



}
//! endzinc
