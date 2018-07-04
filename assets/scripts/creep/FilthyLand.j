//! zinc
library FilthyLand requires DamageSystem {

    struct FilthyLand {
        real x, y, r;
        timer tm;
        unit caster;
        unit art;
        effect eff;
        integer count;

        method destroy() {
            ReleaseTimer(this.tm);
            DestroyEffect(this.eff);
            KillUnit(this.art);
            this.eff = null;
            this.art = null;
            this.caster = null;
            this.tm = null;
            this.deallocate();
        }

        method resizeEffect() {
            real size = (this.r - 270) / 80.0 + 3;
            SetUnitScale(this.art, size, size, size);
        }

        static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            integer i;
            this.r += 1.2;
            this.count += 1;

            if (ModuloInteger(this.count, 25) == 0) {
                for (0 <= i < PlayerUnits.n) {
                    if (GetDistance.unitCoord(PlayerUnits.units[i], this.x, this.y) < this.r) {
                        DamageTarget(this.caster, PlayerUnits.units[i], 200.0, SpellData.inst(SID_FILTHY_LAND, SCOPE_PREFIX).name, false, false, false, WEAPON_TYPE_WHOKNOWS, false);
                    }
                }
            }

            if (this.r >= 750.0) {
                this.destroy();
            } else {
                this.resizeEffect();
            }
        }

        static method start(unit caster, real x, real y) {
            thistype this = thistype.allocate();
            this.tm = NewTimer();
            SetTimerData(this.tm, this);

            this.caster = caster;
            this.x = x;
            this.y = y;
            this.r = 270.0;
            this.count = 0;

            this.art = CreateUnit(Player(MOB_PID), DUMMY_ID, x - 20, y + 50, 0.0);
            this.eff = AddSpecialEffectTarget(ART_UnholyAura, this.art, "origin");

            this.resizeEffect();

            TimerStart(this.tm, 0.04, true, function thistype.run);
        }
    }

    function onCast() {
        FilthyLand.start(SpellEvent.CastingUnit, GetUnitX(SpellEvent.TargetUnit), GetUnitY(SpellEvent.TargetUnit));
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_FILTHY_LAND, onCast);
    }
}
//! endzinc
