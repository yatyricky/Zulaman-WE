//! zinc
library FilthyLand {
// 污秽之地

// 对目标区域内的所有玩家每秒造成伤害，范围会逐渐扩大。

// |cff99ccff施法距离:|r 1200码
// |cff99ccff影响范围:|r 300码
// |cff99ccff持续时间:|r 15秒
// |cff99ccff冷却时间:|r 15秒

    function displayEffects(real x, real y, real r) {
        // AddTimedEffects
    }

    struct FilthyLand {
        real x, y, r;
        timer tm;
        unit caster;

        method destroy() {
            ReleaseTimer(this.tm);
            this.caster = null;
            this.tm = null;
            this.deallocate();
        }

        static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            integer i;
            this.r += 30.0;

            for (0 <= i < PlayerUnits.n) {
                if (GetDistance.unitCoord(PlayerUnits.units[i], this.x, this.y) < this.r) {
                    DamageTarget(this.caster, PlayerUnits.units[i], 200.0, SpellData[SID_FILTHY_LAND].name, false, false, false, WEAPON_TYPE_WHOKNOWS);
                }
            }

            if (this.r >= 750.0) {
                this.destroy();
            } else {
                displayEffects(this.x, this.y, this.r + 30.0);
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

            displayEffects(this.x, this.y, this.r + 30.0);

            TimerStart(this.tm, 1.0, true, function thistype.run);
        }
    }

    function onCast() {
        FilthyLand.start(SpellEvent.CastingUnit, GetUnitX(SpellEvent.TargetUnit), GetUnitY(SpellEvent.TargetUnit));
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_FILTHY_LAND, onCast);
    }
}
//! enzinc
