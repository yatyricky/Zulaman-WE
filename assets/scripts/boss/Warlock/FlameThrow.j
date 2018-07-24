//! zinc
library FlameThrow requires SpellEvent, DamageSystem, GroupUtils {

    struct FlameThrow {
        timer tm;
        unit caster;
        integer tick;
        real dx, dy;
        effect eff;

        method destroy() {
            ReleaseTimer(this.tm);
            DestroyEffect(this.eff);
            this.tm = null;
            this.caster = null;
            this.eff = null;
            this.deallocate();

            FlameThrowAux.theBolt = null;
        }

        static method onHit(Projectile p) -> boolean {
            if (TryReflect(p.target)) {
                p.reverse();
                return false;
            } else {
                DamageTarget(p.caster, p.target, p.r0, SpellData.inst(SID_FLAME_THROW, SCOPE_PREFIX).name, false, false, false, WEAPON_TYPE_WHOKNOWS, true);
                return true;
            }
        }
        
        static method start(unit caster, unit target) {
            thistype this = thistype.allocate();
            real angle = GetAngle(GetUnitX(caster), GetUnitY(caster), GetUnitX(target), GetUnitY(target));
            this.caster = caster;
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.dx = Cos(angle) * 6.0;
            this.dy = Sin(angle) * 6.0;
            this.tick = 0;
            this.eff = AddSpecialEffect(ART_RedDragonMissile, GetUnitX(caster), GetUnitY(caster));
            BlzSetSpecialEffectRoll(this.eff, angle);
            BlzSetSpecialEffectScale(this.eff, 2.0);
            TimerStart(this.tm, 0.04, true, function() {
                thistype this = GetTimerData(GetExpiredTimer());
                real nx;
                real ny;
                Projectile p;
                unit tar;
                if (this.tick < 257) {
                    nx = BlzGetLocalSpecialEffectX(this.eff) + this.dx;
                    ny = BlzGetLocalSpecialEffectY(this.eff) + this.dy;
                    BlzSetSpecialEffectPosition(this.eff, nx, ny, GetLocZ(nx, ny) + 40.0);
                    this.tick += 1;
                    
                    if (ModuloInteger(this.tick, 8) == 0) {
                        tar = PlayerUnits.getRandomInRangeCoord(nx, ny, 200);
                        if (tar != null) {
                            p = Projectile.create();
                            p.caster = this.caster;
                            p.target = tar;
                            p.path = ART_FireBallMissile;
                            p.pr = thistype.onHit;
                            p.speed = 600.0;
                            p.r0 = 250.0;
                            p.overrideStartXY(nx, ny);
                            p.homingMissile();
                        }
                    }
                } else {
                    this.destroy();
                }
            });
            // DBM
            FlameThrowAux.theBolt = this.eff;
        }
    }

    function onCast() {
        FlameThrow.start(SpellEvent.CastingUnit, SpellEvent.TargetUnit);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_FLAME_THROW, onCast);
    }

}
//! endzinc
