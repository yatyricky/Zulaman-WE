//! zinc
library PoisonousCrawler {

	HandleTable ownerHT;

	struct LowEfficiencyWrapper {
		private static HandleTable ht;
		unit u;

		static method new(unit u) -> thistype {
			thistype this;
			if (thistype.ht.exists(u)) {
				this = thistype.ht[u];
			} else {
				this = thistype.allocate();
				this.u = u;
				thistype.ht[u] = this;
			}
			return this;
		}

		private static method onInit() {
			thistype.ht = HandleTable.create();
		}
	}

    function onEffect(Buff buf) {
        DamageTarget(buf.bd.caster, buf.bd.target, buf.bd.r0, SpellData[SID].name, false, false, false, WEAPON_TYPE_WHOKNOWS);
        AddTimedEffect.atUnit(ART_PLAGUE, buf.bd.target, "origin", 0.2);
    }

    function onRemove(Buff buf) {}

	struct PoisonousCrawlerPoison {
		private unit caster;
		private Point p;
		private timer tm;
		private integer ctr;

		private method destroy() {
			ReleaseTimer(this.tm);
			this.p.destroy();
			this.tm = null;
			this.caster = null;
			this.deallocate();
		}

		private static method run() {
			thistype this = GetTimerData(GetExpiredTimer());
			integer i;
			Buff buf;
			for (0 <= i < PlayerUnits.n) {
				// if any player unit is in range, debuff them
				if (GetDistance.unitCoord(PlayerUnits.units[i], this.p.x, this.p.y) < 400.0) {
			        buf = Buff.cast(this.caster, PlayerUnits.units[i], BID);
			        buf.bd.interval = 2.0;
			        buf.bd.tick = 15;
			        buf.bd.r0 = 200.0;
			        buf.bd.boe = onEffect;
			        buf.bd.bor = onRemove;
			        buf.run();
				}
			}

			this.ctr -= 1;
			if (this.ctr <= 0) {
				this.destroy();
			}
		}

		static method start(unit caster, Point p) {
			thistype this = thistype.allocate();
			this.caster = caster;
			this.p = p;
			this.ctr = 100;
			this.tm = NewTimer();
			SetTimerData(this.tm, this);
			StartTimer(this.tm, 0.1, true, function thistype.run);

			AddTimedEffect.atCoord(ART, p.x, p.y, 10.0);
			AddTimedEffect.atCoord(ART, p.x, p.y, 10.0);
			AddTimedEffect.atCoord(ART, p.x, p.y, 10.0);
			AddTimedEffect.atCoord(ART, p.x, p.y, 10.0);
			AddTimedEffect.atCoord(ART, p.x, p.y, 10.0);
		}
	}

	function poisonousCrawlerDeath(unit u) {
		if (GetUnitTypeId(u) == UTID) {
			PoisonousCrawlerPoison.start(LowEfficiencyWrapper(ownerHT[u]).u, Point.new(GetUnitX(u), GetUnitY(u)));
			ownerHT.flush(u);
		}
	}

	function onCast() {
		unit crawler;
		crawler = CreateUnit(Player(MOB_PID), UTID, AbyssArchonGlobalConst.summonX, AbyssArchonGlobalConst.summonY, GetRandomReal(0, 359));
		ownerHT[crawler] = LowEfficiencyWrapper.new(SpellEvent.CastingUnit);
		crawler = null;
	}

    function onInit() {
        RegisterSpellEffectResponse(SPELL_ID, onCast);
        BuffType.register(BID, BUFF_PHYX, BUFF_NEG);
        RegisterUnitDeath(poisonousCrawlerDeath);
        ownerHT = HandleTable.create();
    }
}
//! endzinc
