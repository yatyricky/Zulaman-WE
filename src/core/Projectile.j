//! zinc
library Projectile requires TimerUtils, Table, ZAMCore {
    
    public type ProjectileReaches extends function(Projectile) -> boolean;
    
    public struct Projectile {
        unit caster, target;
        ProjectileReaches pr;
        real speed;
        string path;
        timer tm;
        unit pro;
        effect eff;
        real r0;
        integer i0;
        unit u0;
        
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
    }
    
}
//! endzinc
