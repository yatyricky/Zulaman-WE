//! zinc
library Projectile requires TimerUtils, Table, ZAMCore {
    
    public type ProjectileReaches extends function(Projectile) -> boolean;
    
    public struct Projectile {
        unit caster, target;
        real targetX, targetY, targetZ;
        ProjectileReaches pr;
        real speed, scale;
        string path;
        timer tm;
        unit pro;
        effect eff;
        real r0;
        integer i0;
        unit u0;

        real angle, distance, dx, dy, step, travelled;
        real height, heightA, heightB, originalHeight;
        integer count;
        
        method destroy() {
            ReleaseTimer(this.tm);
            AddTimedEffect.atCoord(this.path, GetUnitX(this.pro), GetUnitY(this.pro), 0.01);
            KillUnit(this.pro);
            DestroyEffect(this.eff);
            this.caster = null;
            this.target = null;
            this.tm = null;
            this.pro = null;
            this.eff = null;
            this.deallocate();
        }
        
        method destroyEffect() {
            ReleaseTimer(this.tm);
            DestroyEffect(this.eff);
            this.caster = null;
            this.target = null;
            this.tm = null;
            this.eff = null;
            this.deallocate();
        }
        
        method reverse() {
            unit tmp = this.caster;
            this.caster = this.target;
            this.target = tmp;
            KillUnit(this.pro);
            DestroyEffect(this.eff);
            this.pro = CreateUnit(GetOwningPlayer(this.caster), DUMMY_ID, GetUnitX(this.caster), GetUnitY(this.caster) + 30, GetAngleDeg(GetUnitX(this.caster), GetUnitY(this.caster), GetUnitX(this.target), GetUnitY(this.target)));
            SetUnitFlyable(this.pro);
            SetUnitFlyHeight(this.pro, 25, 0);
            this.eff = AddSpecialEffectTarget(this.path, this.pro, "origin");
            
        }
        
        static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            real dist;
            if (!IsUnitDead(this.target)) {
                dist = GetDistance.units2d(this.pro, this.target);
                if (dist < this.speed) {
                    if (this.pr.evaluate(this)) {
                        this.destroy();
                    }
                } else {
                    SetUnitX(this.pro, GetUnitX(this.pro) + (GetUnitX(this.target) - GetUnitX(this.pro)) * this.speed / dist);
                    SetUnitY(this.pro, GetUnitY(this.pro) + (GetUnitY(this.target) - GetUnitY(this.pro)) * this.speed / dist);
                    SetUnitFacing(this.pro, GetAngleDeg(GetUnitX(this.pro), GetUnitY(this.pro), GetUnitX(this.target), GetUnitY(this.target)));
                }
            } else {
                this.destroy();
            }
        }

        static method runPierce() {
            thistype this = GetTimerData(GetExpiredTimer());
            SetUnitX(this.pro, GetUnitX(this.pro) + this.dx);
            SetUnitY(this.pro, GetUnitY(this.pro) + this.dy);
            this.count -= 1;
            if (this.count < 0) {
                this.destroy();
            }
        }
        
        method launch() {
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.pro = CreateUnit(GetOwningPlayer(this.caster), DUMMY_ID, GetUnitX(this.caster), GetUnitY(this.caster) + 30, GetAngleDeg(GetUnitX(this.caster), GetUnitY(this.caster), GetUnitX(this.target), GetUnitY(this.target)));
            SetUnitFlyable(this.pro);
            SetUnitFlyHeight(this.pro, 25, 0);
            this.eff = AddSpecialEffectTarget(this.path, this.pro, "origin");
            this.speed = this.speed / 25.0;
            TimerStart(this.tm, 0.04, true, function thistype.run);
        }

        method pierce() {
            this.tm = NewTimer();
            SetTimerData(this.tm, this);

            this.pro = CreateUnit(GetOwningPlayer(this.caster), DUMMY_ID, GetUnitX(this.caster), GetUnitY(this.caster) + 30, this.angle * bj_RADTODEG);
            SetUnitFlyable(this.pro);
            SetUnitFlyHeight(this.pro, 25, 0);
            this.eff = AddSpecialEffectTarget(this.path, this.pro, "origin");

            this.count = Rounding(25.0 * this.distance / this.speed);
            this.dx = Cos(this.angle) * this.speed * 0.04;
            this.dy = Sin(this.angle) * this.speed * 0.04;
            TimerStart(this.tm, 0.04, true, function thistype.runPierce);
        }

        method homingMissile() {
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.eff = AddSpecialEffect(this.path, GetUnitX(this.caster), GetUnitY(this.caster));
            this.angle = GetAngle(GetUnitX(this.caster), GetUnitY(this.caster), GetUnitX(this.target), GetUnitY(this.target)) + GetRandomReal(1.745329, 4.537856); // plus 100 - 260 degs
            this.step = this.speed * 0.04;
            this.count = 0;
            BlzSetSpecialEffectRoll(this.eff, this.angle);
            TimerStart(this.tm, 0.04, true, function() {
                thistype this = GetTimerData(GetExpiredTimer());
                real desiredAngle, diff;
                real cx, cy;
                real dist;
                if (!IsUnitDead(this.target)) {
                    this.count += 1;
                    cx = BlzGetLocalSpecialEffectX(this.eff);
                    cy = BlzGetLocalSpecialEffectY(this.eff);
                    this.dx = Cos(this.angle) * this.step;
                    this.dy = Sin(this.angle) * this.step;
                    BlzSetSpecialEffectPosition(this.eff, cx + this.dx, cy + this.dy, GetLocZ(cx + this.dx, cy + this.dy) + 30.0);
                    BlzSetSpecialEffectRoll(this.eff, this.angle);
                    desiredAngle = GetAngle(cx + this.dx, cy + this.dy, GetUnitX(this.target), GetUnitY(this.target));
                    diff = AngleBetweenAngles(desiredAngle, this.angle);
                    if (RAbsBJ(diff) > 0.261799 && this.count < 50) {
                        diff = diff / RAbsBJ(diff) * 0.261799;
                    }
                    this.angle -= diff;

                    dist = GetDistance.unitCoord(this.target, BlzGetLocalSpecialEffectX(this.eff), BlzGetLocalSpecialEffectY(this.eff));
                    if (dist < this.step) {
                        if (this.pr.evaluate(this)) {
                            this.destroyEffect();
                        }
                    }
                } else {
                    this.destroyEffect();
                }
            });
        }

        method spill(real maxHeight) {
            real heightDiff;
            this.tm = NewTimer();
            SetTimerData(this.tm, this);

            // h = height, d = distance, s = target z level difference from origin, s can't be greater than h
            // b = 2 * h / d * (1 + √(1 - s / h))
            // a = -1 * b * b / 4 / h
            this.distance = GetDistance.unitCoord2d(this.caster, this.targetX, this.targetY);
            this.originalHeight = GetUnitZ(this.caster);
            heightDiff = this.targetZ - this.originalHeight;
            if (heightDiff > this.height) {this.height = heightDiff + 1;}
            this.heightB = 2.0 * this.height / this.distance * (1 + SquareRoot(1.0 - heightDiff / this.height));
            this.heightA = -1.0 * this.heightB * this.heightB / 4.0 / this.height;

            this.eff = AddSpecialEffect(this.path, GetUnitX(this.caster), GetUnitY(this.caster));
            if (this.scale != 0.0) {BlzSetSpecialEffectScale(this.eff, this.scale);}
            this.angle = GetAngle(GetUnitX(this.caster), GetUnitY(this.caster), this.targetX, this.targetY);
            BlzSetSpecialEffectRoll(this.eff, this.angle);
            this.step = this.speed * 0.04;
            this.travelled = 0;
            this.dx = Cos(this.angle) * this.step;
            this.dy = Sin(this.angle) * this.step;
            TimerStart(this.tm, 0.04, true, function() {
                thistype this = GetTimerData(GetExpiredTimer());
                real h;
                this.travelled += this.step;
                h = this.heightA * this.travelled * this.travelled + this.heightB * this.travelled;
                BlzSetSpecialEffectPosition(this.eff, BlzGetLocalSpecialEffectX(this.eff) + this.dx, BlzGetLocalSpecialEffectY(this.eff) + this.dy, h + this.originalHeight);
                if (RAbsBJ(this.travelled - this.distance) < this.step) {
                    if (this.pr.evaluate(this)) {
                        this.destroyEffect();
                    }
                }
            });
        }
    }

}
//! endzinc
