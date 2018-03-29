//! zinc
library MindBlast requires GodOfDeathGlobal {
constant real H_OVER_D = 0.45;

    struct Parabola {
        private timer tm;
        private unit missile;
        private effect eff;
        private real cosAng, sinAng;
        private real distance;
        private integer count;
        private unit caster;
        private Point p;
        
        private method destroy() {
            MindBlastSpots.remove(this.p);
            this.p.destroy();
            DestroyEffect(this.eff);
            KillUnit(this.missile);
            ReleaseTimer(this.tm);
            this.tm = null;
            this.missile = null;
            this.eff = null;
            this.deallocate();
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            real tx = GetUnitX(this.missile) + this.cosAng * MISSILE_SPEED;
            real ty = GetUnitY(this.missile) + this.sinAng * MISSILE_SPEED;
            real height;
            integer i;
            this.count += 1;
            height = Sin(this.count * MISSILE_SPEED / this.distance * 3.1415) * this.distance * H_OVER_D;
            if (height < 0.0) {
                height = 0.0;
                // explosion
                for (0 <= i < PlayerUnits.n) {
                    if (GetDistance.unitCoord(PlayerUnits.units[i], GetUnitX(this.missile), GetUnitY(this.missile)) <= GodOfDeathGlobalConst.mindBlastAOE) {
                        DamageTarget(this.caster, PlayerUnits.units[i], 1200.0, SpellData[SID_MIND_BLAST].name, false, false, false, WEAPON_TYPE_WHOKNOWS);
                        ModUnitMana(this.caster, 1);
                    }
                }

                AddTimedEffect.atCoord(ART_MORTAR_MISSILE, GetUnitX(this.missile), GetUnitY(this.missile), 0.5);

                this.destroy();
            } else {
                SetUnitX(this.missile, tx);
                SetUnitY(this.missile, ty);
            }
            SetUnitFlyHeight(this.missile, height, 0.0);
        }
        
        static method start(unit caster, Point p) {
            thistype this = thistype.allocate();
            real angle = GetAngle(GetUnitX(caster), GetUnitY(caster), p.x, p.y);
            this.missile = CreateUnit(Player(MOB_PID), DUMMY_ID, GetUnitX(caster), GetUnitY(caster), angle * bj_RADTODEG);
            SetUnitFlyable(this.missile);
            this.eff = AddSpecialEffectTarget(ART_PHOENIX_MISSILE, this.missile, "origin");
            this.cosAng = Cos(angle);
            this.sinAng = Sin(angle);
            this.distance = GetDistance.coords2d(GetUnitX(caster), GetUnitY(caster), p.x, p.y);
            this.count = 0;
            this.caster = caster;
            this.p = p;
            MindBlastSpots.add(this.p);
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            TimerStart(this.tm, 0.04, true, function thistype.run);
        }
    }

    function onCast() {
        Parabola.start(SpellEvent.CastingUnit, Point.new(SpellEvent.TargetX, SpellEvent.TargetY));
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_MIND_BLAST, onCast);
    }

}
//! endzinc
