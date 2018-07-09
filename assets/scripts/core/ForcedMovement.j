//! zinc
library ForcedMovement requires TimerUtils, ZAMCore {

    public type ForcedMovementUpdate extends function(ForcedMovement);
    
    public struct ForcedMovement {
        private static HandleTable ht;
        private timer tm;
        unit u, target;
        real dx, dy, accr, step;
        private integer count, frames;
        private ForcedMovementUpdate update, onHit;

        private method destroy() {
            ReleaseTimer(this.tm);
            thistype.ht.flush(this.u);
            this.tm = null;
            this.u = null;
            this.deallocate();
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            real factor;
            if (IsUnitDead(this.u)) {
                this.destroy();
            } else {
                if (this.update != 0) {
                    this.update.evaluate(this);
                }
                factor = (this.frames - this.count) / this.frames * this.accr;
                SetUnitPosition(this.u, GetUnitX(this.u) + this.dx + this.dx * factor, GetUnitY(this.u) + this.dy + this.dy * factor);
                this.count -= 1;
                if (this.count <= 0) {
                    this.destroy();
                }
            }
        }

        method setUpdate(ForcedMovementUpdate action) -> thistype {
            this.update = action;
            return this;
        }

        method setOnHit(ForcedMovementUpdate action) -> thistype {
            this.onHit = action;
            return this;
        }

        static method start(unit u, real dx, real dy, integer frames, real accr) -> thistype {
            thistype this;
            if (thistype.ht.exists(u)) {
                this = thistype.ht[u];
            } else {
                this = thistype.allocate();
                thistype.ht[u] = this;
                this.tm = NewTimer();
                SetTimerData(this.tm, this);
                this.u = u;
                this.update = 0;
                this.onHit = 0;
            }
            this.dx = dx;
            this.dy = dy;
            this.accr = accr;
            this.count = frames;
            this.frames = frames;
            TimerStart(this.tm, 0.04, true, function thistype.run);
            return this;
        }

        static method towards(unit caster, unit target, real speed) -> thistype {
            thistype this;
            real dist;
            if (thistype.ht.exists(caster)) {
                this = thistype.ht[caster];
            } else {
                this = thistype.allocate();
                thistype.ht[caster] = this;
                this.tm = NewTimer();
                SetTimerData(this.tm, this);
                this.u = caster;
                this.update = 0;
                this.onHit = 0;
            }
            dist = GetDistance.units2d(caster, target);
            SetUnitFacing(caster, GetAngleDeg(GetUnitX(caster), GetUnitY(caster), GetUnitX(target), GetUnitY(target)));
            this.target = target;
            this.step = speed * 0.04;
            TimerStart(this.tm, 0.04, true, function() {
                thistype this = GetTimerData(GetExpiredTimer());
                real angle, dist;
                if (IsUnitDead(this.u) || IsUnitDead(this.target)) {
                    this.destroy();
                } else {
                    dist = GetDistance.units2d(this.u, this.target);
                    if (dist < 128) {
                        if (this.onHit != 0) {
                            this.onHit.evaluate(this);
                        }
                        this.destroy();
                    } else {
                        angle = GetAngle(GetUnitX(this.u), GetUnitY(this.u), GetUnitX(this.target), GetUnitY(this.target));
                        SetUnitFacing(this.u, angle * bj_RADTODEG);
                        this.dx = (GetUnitX(this.target) - GetUnitX(this.u)) * this.step / dist;
                        this.dy = (GetUnitY(this.target) - GetUnitY(this.u)) * this.step / dist;
                        if (this.update != 0) {
                            this.update.evaluate(this);
                        }
                        SetUnitPosition(this.u, GetUnitX(this.u) + this.dx, GetUnitY(this.u) + this.dy);
                    }
                }
            });
            return this;
        }
        
        private static method onInit() {
            thistype.ht = HandleTable.create();
        }
    }
    
    public function ForceMoveUnitPolar(unit u, real dx, real dy, integer frames, real accerlaration) {
        ForcedMovement.start(u, dx, dy, frames, accerlaration);
    }

}
//! endzinc
