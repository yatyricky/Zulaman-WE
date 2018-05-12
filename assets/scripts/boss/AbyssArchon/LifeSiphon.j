//! zinc
library LifeSiphon requires DamageSystem, BuffSystem {

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
                    StunUnit(this.caster, PlayerUnits.units[i], 1.1);

                    if (GetUnitAbilityLevel(PlayerUnits.units[i], BID_SUMMON_POISONOUS_CRAWLER) > 0) {
                        AddTimedLight.atUnits("DRAL", this.caster, PlayerUnits.units[i], 1.0);
                    } else {
                        AddTimedLight.atUnits("DRAL", this.caster, PlayerUnits.units[i], 1.0).setColour(1,0.2,0.2,1);
                        amt = GetUnitState(PlayerUnits.units[i], UNIT_STATE_MAX_LIFE) * 0.16;
                        DamageTarget(this.caster, PlayerUnits.units[i], amt, SpellData.inst(SID_LIFE_SIPHON, SCOPE_PREFIX).name, false, false, false, WEAPON_TYPE_WHOKNOWS, false);
                        HealTarget(this.caster, this.caster, amt * 30.0, SpellData.inst(SID_LIFE_SIPHON, SCOPE_PREFIX).name, 0.0, false);
                        AddTimedEffect.atUnit(ART_HEAL, this.caster, "origin", 0.2);
                    }
                }
            }
            if (this.ctr == 0) {
                // PauseUnit(caster, false);
                UnitProp.inst(caster, SCOPE_PREFIX).enable();
                for (0 <= i < PlayerUnits.n) {
                    buf = BuffSlot[PlayerUnits.units[i]].getBuffByBid(BID_SUMMON_POISONOUS_CRAWLER);
                    if (buf != 0) {
                        // print("remove buff for " + GetUnitNameEx(PlayerUnits.units[i]));
                        BuffSlot[PlayerUnits.units[i]].dispelByBuff(buf);
                        buf.destroy();
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
            // PauseUnit(caster, true);
            UnitProp.inst(caster, SCOPE_PREFIX).disable();
            SetTimerData(this.tm, this);
            TimerStart(this.tm, 0.1, true, function thistype.run);

            for (0 <= i < PlayerUnits.n) {
                StunUnit(caster, PlayerUnits.units[i], 0.15);

                if (GetUnitAbilityLevel(PlayerUnits.units[i], BID_SUMMON_POISONOUS_CRAWLER) > 0) {
                    AddTimedLight.atUnits("DRAL", caster, PlayerUnits.units[i], 1.0);
                } else {
                    AddTimedLight.atUnits("DRAL", caster, PlayerUnits.units[i], 1.0).setColour(1,0.2,0.2,1);
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
        RegisterSpellChannelResponse(SID_LIFE_SIPHON, onChannel);
    }
}
//! endzinc
