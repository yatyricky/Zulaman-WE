//! zinc
library LightningTotemHex requires EarthBinderGlobal, GroupUtils, UnitProperty, BuffSystem {
#define TOTEM_ID_STORM 'u000'

    struct StormTotem {
        private unit u;
        private unit c;
        private timer tm;
		private integer tick;
        
        private method destroy() {
            ReleaseTimer(this.tm);
            KillUnit(this.u);
            this.c = null;
            this.tm = null;
            this.u = null;
            this.deallocate();
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            integer i = 0;
			real far = 1.0;
			unit select = null;
			real tmp;
			if (IsUnitDead(this.u)) {
				this.tick -= 30;
			}
			if (this.tick > 0) {
				while (i < PlayerUnits.n) {
                    if (!IsUnitDead(PlayerUnits.units[i])) {
                        tmp = GetWidgetLife(PlayerUnits.units[i]);
                        if (far <= tmp) {
                            select = PlayerUnits.units[i];
                            far = tmp;
                        }
                    }
					i += 1;
				}
				if (select != null) {
					AddTimedLight.atUnitsZ("CLPB", this.u, 80.0, select, 0.0, 0.5);
					AddTimedEffect.atUnit(ART_IMPACT, select, "origin", 0.3);
					DamageTarget(this.c, select, 100.0, SpellData[SIDLIGHTNINGTOTEMHEX].name, false, false, false, WEAPON_TYPE_WHOKNOWS);
				}
			}
			this.tick -= 1;
			if (this.tick < 1) {
				this.destroy();
			}
        }
    
        static method start(unit caster, unit totem) {
            thistype this = thistype.allocate();
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.u = totem;
            this.c = caster;
			this.tick = 30;
            TimerStart(this.tm, 1.0, true, function thistype.run);
        }
    }
    
    function onCastStorm() {
        unit totem;
        RandomPoint.aroundUnit(SpellEvent.CastingUnit, 100.0, 200.0);
		totem = CreateUnit(Player(MOB_PID), TOTEM_ID_STORM, RandomPoint.x, RandomPoint.y, 0.0);
        StormTotem.start(SpellEvent.CastingUnit, totem);
    }

    function onInit() {
        RegisterSpellEffectResponse(SIDLIGHTNINGTOTEMHEX, onCastStorm);
    }
#undef TOTEM_ID_STORM
}
//! endzinc
