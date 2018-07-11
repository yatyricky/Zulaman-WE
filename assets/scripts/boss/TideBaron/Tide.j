//! zinc
library Tide requires BuffSystem, SpellEvent, UnitProperty, DamageSystem, GroupUtils {

    struct Tide {
        private timer tm;
        private unit a;
        private integer tick;
        private real x, y;
        private group damaged;
        
        private method destroy() {
            SetUnitVertexColor(this.a, 255, 255, 255, 255);
            PauseUnit(this.a, false);
            SetUnitPathing(this.a, true);
            ReleaseGroup(this.damaged);
            ReleaseTimer(this.tm);
            this.tm = null;
            this.damaged = null;
            this.a = null;
            this.deallocate();
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            real nextx;
            real nexty;
            integer i = 0;
            if (IsUnitDead(this.a)) {
                this.tick += 36;
            } else {
                nextx = GetUnitX(this.a) + this.x;
                nexty = GetUnitY(this.a) + this.y;
                if (!IsTerrainWalkable(nextx, nexty)) {
                    this.tick += 36;
                }
            }
            if (this.tick < 20) {
                SetUnitX(this.a, nextx);
                SetUnitY(this.a, nexty);
                this.tick += 1;
                
                while (i < PlayerUnits.n) {
                    if (GetDistance.units2d(PlayerUnits.units[i], this.a) < 200 && !IsUnitDead(PlayerUnits.units[i]) && !IsUnitInGroup(PlayerUnits.units[i], this.damaged)) {
                        DamageTarget(this.a, PlayerUnits.units[i], 700, SpellData.inst(SID_TIDE, SCOPE_PREFIX).name, false, false, false, WEAPON_TYPE_WHOKNOWS, false);
                        GroupAddUnit(this.damaged, PlayerUnits.units[i]);
                    }
                    i += 1;
                }
                
                if (ModuloInteger(this.tick, 3) == 0) {
                    AddTimedEffect.atCoord(ART_WATER, nextx, nexty, 0.3);
                }
            } else {
                this.destroy();
            }
        }
        
        static method start(unit a, unit b) {
            thistype this = thistype.allocate();
            real angle = GetAngle(GetUnitX(a), GetUnitY(a), GetUnitX(b), GetUnitY(b));
            this.a = a;
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.x = Cos(angle) * 48.0;
            this.y = Sin(angle) * 48.0;
            this.tick = 0;
            this.damaged = NewGroup();
            IssueImmediateOrderById(this.a, OID_STOP);
            SetUnitVertexColor(this.a, 255, 255, 255, 0);
            PauseUnit(this.a, true);
            SetUnitPathing(this.a, false);
            TimerStart(this.tm, 0.04, true, function thistype.run);
        }
    }

    function delayedCast(DelayTask dt) {
        Tide.start(dt.u0, dt.u1);
    }

    function response(CastingBar cd) {
        DelayTask dt = DelayTask.create(delayedCast, 0.03);
        dt.u0 = cd.caster;
        dt.u1 = cd.target;
    }

    function onChannel() {
        real angle;
        real x1, y1, x2, y2;
        CastingBar.create(response).setVisuals(ART_SeaElementalMissile).launch();
        x1 = GetUnitX(SpellEvent.CastingUnit);
        y1 = GetUnitY(SpellEvent.CastingUnit);
        x2 = GetUnitX(SpellEvent.TargetUnit);
        y2 = GetUnitY(SpellEvent.TargetUnit);
        angle = GetAngle(x1, y1, x2, y2);
        x2 = Cos(angle) * 940 + x1;
        y2 = Sin(angle) * 940 + y1;
        VisualEffects.line(ART_GlowingRunes4, x1, y1, x2, y2, 128, 2);
    }

    function onInit() {
        RegisterSpellChannelResponse(SID_TIDE, onChannel);
    }
}
//! endzinc
