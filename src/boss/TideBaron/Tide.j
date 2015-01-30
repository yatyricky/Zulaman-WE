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
                        DamageTarget(this.a, PlayerUnits.units[i], 180.0 + GetRandomReal(0.0, 40.0), SpellData[SIDTIDE].name, false, false, false, WEAPON_TYPE_WHOKNOWS);
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

    function onCast() {
        Tide.start(SpellEvent.CastingUnit, SpellEvent.TargetUnit);
    }

    function onInit() {
        RegisterSpellEffectResponse(SIDTIDE, onCast);
    }
}
//! endzinc
