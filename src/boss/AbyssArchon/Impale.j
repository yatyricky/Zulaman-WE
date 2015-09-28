//! zinc
library Impale requires SpellEvent, BuffSystem {
#define ART "blood effect"

    struct Impale {
        private static HandleTable ht1;
        private static HandleTable ht2;
        private unit spike;
        private unit target;
        private unit source;
        private timer tm;

        private method terminate() {
            RemoveStun(this.target);
            ReleaseTimer(this.tm);
            thistype.ht1.flush(this.target);
            thistype.ht2.flush(this.spike);
            this.spike = null;
            this.source = null;
            this.target = null;
            this.tm = null;
            this.deallocate();
        }

        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            DamageTarget(this.source, this.target, 300.0, SpellData[SPELL_ID], true, false, false, WEAPON_TYPE_WHOKNOWS);

            AddTimedEffect.atUnit(ART, this.target, "origin", 0.5);
        }

        static method start(unit source, unit target) {
            thistype this;
            if (thistype.ht1.exists(target)) {
                this = thistype.ht1[target];
                SetWidgetLife(this.spike, GetUnitState(this.spike, UNIT_STATE_MAX_LIFE));
            } else {
                this = thistype.allocate();
                this.source = source;
                this.target = target;
                this.spike = CreateUnit(Player(MOB_PID), UTID, GetUnitX(target), GetUnitY(target), GetUnitFacing(target));
                this.tm = NewTimer();
                SetTimerData(this.tm, this);
                thistype.ht1[this.target] = this;
                thistype.ht2[this.spike] = this;

                TimerStart(this.tm, 2.0, true, function thistype.run);
            }

            StunUnit(source, target, 999);
            AddTimedEffect.atUnit(ART, target, "origin", 1.0);
        }

        static method playerDeath(unit u) {
            thistype this;
            if (thistype.ht1.exists(u)) {
                this = thistype.ht1[u];
                KillUnit(this.spike);
            }
        }

        static method spikeDeath(unit u) {
            thistype this;
            if (thistype.ht2.exists(u)) {
                this = thistype.ht2[u];
                this.terminate();
            }   
        }

        private static method onInit() {
            thistype.ht1 = HandleTable.create();
            thistype.ht2 = HandleTable.create();
        }
    }

    function impalePlayerDeath(unit u) {
        Impale.playerDeath(u);
    }

    function impaleSpikeDeath(unit u) {
        if (GetUnitTypeId(u) == UTID) {
            Impale.spikeDeath(u);
        }
    }

    function onCast() {       
        Impale.start(SpellEvent.CastingUnit, SpellEvent.TargetUnit);
    }

    function onInit() {
        RegisterSpellEffectResponse(SPELL_ID, onCast);
        RegisterUnitDeath(impalePlayerDeath);
        RegisterUnitDeath(impaleSpikeDeath);
    }
#undef ART
}
//! endzinc
