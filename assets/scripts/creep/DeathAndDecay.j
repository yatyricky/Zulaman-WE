//! zinc
library DeathAndDecay requires DamageSystem {

    public ListObject deathAndDecayPoints;

    private struct DeathAndDecay {
        timer tm;
        Point p;
        integer counter;
        unit caster;
        unit target;

        private method destroy() {
            deathAndDecayPoints.remove(this.p);
            this.p.destroy();
            ReleaseTimer(this.tm);
            this.tm = null;
            this.caster = null;
            this.target = null;
            this.deallocate();
        }

        static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            real dx, dy, dis;
            integer i;

            for (0 <= i < PlayerUnits.n) {
                if (GetDistance.unitCoord(PlayerUnits.units[i], this.p.x, this.p.y) <= 300.0) {
                    DamageTarget(this.caster, PlayerUnits.units[i], GetUnitState(PlayerUnits.units[i], UNIT_STATE_MAX_LIFE) * 0.03, SpellData.inst(SID_DEATH_AND_DECAY, SCOPE_PREFIX).name, false, false, false, WEAPON_TYPE_WHOKNOWS, false);
                }
            }

            // speed = 20
            if (this.target != null && !IsUnitDead(this.target)) {
                dis = GetDistance.unitCoord(this.target, this.p.x, this.p.y) + 1;
                dx = (GetUnitX(this.target) - this.p.x) * 2.0 / dis;
                dy = (GetUnitY(this.target) - this.p.y) * 2.0 / dis;
                this.p.x += dx;
                this.p.y += dy;
            }

            SpamEffectsInCircle(ART_DEATH_AND_DECAY, this.p.x, this.p.y, 300.0, 10, 0.1);

            this.counter -= 1;
            if (this.counter <= 0) {
                this.destroy();
            }
        }

        static method start(unit caster, unit target) {
            thistype this = thistype.allocate();
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.caster = caster;
            this.target = target;
            this.counter = 50;

            this.p = Point.new(GetUnitX(target), GetUnitY(target));
            deathAndDecayPoints.push(p);

            TimerStart(this.tm, 0.1, true, function thistype.run);
        }
    }

    function onCast() {
        DeathAndDecay.start(SpellEvent.CastingUnit, SpellEvent.TargetUnit);
    }

    function onInit() {
        deathAndDecayPoints = ListObject.create();
        RegisterSpellEffectResponse(SID_DEATH_AND_DECAY, onCast);
    }
}
//! endzinc
