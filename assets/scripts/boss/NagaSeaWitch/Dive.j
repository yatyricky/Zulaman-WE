//! zinc
library Dive requires CastingBar {

    HandleTable ht;

    function postMove(DelayTask dt) {
        ForcedMovement.start(dt.u0, dt.r0, dt.r1, dt.i0, dt.r2);
    }

    function moveTogether(ForcedMovement fm) {
        real dis = GetDistance.units(fm.u, fm.target);
        real dx = (GetUnitX(fm.target) - GetUnitX(fm.u)) * 36 / dis;
        real dy = (GetUnitY(fm.target) - GetUnitY(fm.u)) * 36 / dis;
        DelayTask dt;
        SetUnitFlyHeight(fm.u, 240, 1000);
        dt = DelayTask.create(postMove, 0.04);
        dt.u0 = fm.u;
        dt.r0 = dx;
        dt.r1 = dy;
        dt.i0 = 20;
        dt.r2 = -0.5;
        ForcedMovement.start(fm.target, dx, dy, 20, -0.5);
    }

    function descending(ForcedMovement fm) {
        real fh = GetUnitFlyHeight(fm.u);
        real desc = fh * 2 * 0.04;
        if (desc < 5) {
            desc = 5;
        }
        desc = fh - desc;
        if (desc < 240) {
            desc = 240;
        }
        SetUnitFlyHeight(fm.u, desc, 0);
    }

    struct Dive {
        unit caster;
        timer tm;

        method destroy() {
            ReleaseTimer(this.tm);
            this.caster = null;
            this.tm = null;
            this.deallocate();
        }

        static method ascending() {
            thistype this = GetTimerData(GetExpiredTimer());
            real currentHeight;
            unit target;
            if (IsUnitDead(this.caster) == true) {
                this.destroy();
            } else {
                if (UnitProp.inst(this.caster, SCOPE_PREFIX).stunned == false) {
                    currentHeight = GetUnitFlyHeight(this.caster);
                    if (currentHeight >= 540) {
                        target = PlayerUnits.getFarest(this.caster);
                        if (target != null) {
                            SetUnitPathing(this.caster, false);
                            ForcedMovement.towards(this.caster, target, 500).setUpdate(descending).setOnHit(moveTogether);
                            AddTimedEffect.atUnit(ART_Phoenix_Missile_mini, this.caster, "hand, left", 2.0);
                            AddTimedEffect.atUnit(ART_Phoenix_Missile_mini, this.caster, "hand, right", 2.0);
                        } else {
                            SetUnitFlyHeight(this.caster, 0, 0);
                            AddTimedEffect.atUnit(ART_WATER, this.caster, "origin", 0.3);
                        }
                        target = null;
                        this.destroy();
                    } else {
                        SetUnitFlyHeight(this.caster, currentHeight + 4, 0);
                    }
                }
            }
        }

        static method start(unit caster) {
            thistype this = thistype.allocate();
            SetUnitFlyable(caster);
            this.caster = caster;

            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            TimerStart(this.tm, 0.04, true, function thistype.ascending);
        }
    }

    function onCast() {
        Dive.start(SpellEvent.CastingUnit);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_DIVE, onCast);
    }

}
//! endzinc
