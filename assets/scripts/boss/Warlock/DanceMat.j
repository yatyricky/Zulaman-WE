//! zinc
library DanceMat requires DamageSystem {

    struct DanceMat {
        lightning l1, l2;
        real dx1, dy1, dx2, dy2, z;
        real cx1, cy1, cx2, cy2;
        unit caster;
        timer tm;
        integer count;

        static method start(unit caster, real p1x, real p1y, real p2x, real p2y, real time) {
            thistype this = thistype.allocate();
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.caster = caster;
            this.z = GetLocZ(WLK_SQR_CENTRE_X, WLK_SQR_CENTRE_Y) + 36.0;
            this.l1 = AddLightningEx("SPLK", false, WLK_SQR_CENTRE_X, WLK_SQR_CENTRE_Y, this.z, WLK_SQR_CENTRE_X, WLK_SQR_CENTRE_Y, this.z);
            this.l2 = AddLightningEx("SPLK", false, WLK_SQR_CENTRE_X, WLK_SQR_CENTRE_Y, this.z, WLK_SQR_CENTRE_X, WLK_SQR_CENTRE_Y, this.z);
            this.cx1 = WLK_SQR_CENTRE_X;
            this.cy1 = WLK_SQR_CENTRE_Y;
            this.cx2 = WLK_SQR_CENTRE_X;
            this.cy2 = WLK_SQR_CENTRE_Y;
            this.count = Rounding(time * 25);
            this.dx1 = (p1x - WLK_SQR_CENTRE_X) / this.count;
            this.dy1 = (p1y - WLK_SQR_CENTRE_Y) / this.count;
            this.dx2 = (p2x - WLK_SQR_CENTRE_X) / this.count;
            this.dy2 = (p2y - WLK_SQR_CENTRE_Y) / this.count;
            TimerStart(this.tm, 0.04, true, function() {
                thistype this = GetTimerData(GetExpiredTimer());
                integer i;
                this.cx1 += this.dx1;
                this.cy1 += this.dy1;
                this.cx2 += this.dx2;
                this.cy2 += this.dy2;
                MoveLightningEx(this.l1, false, WLK_SQR_CENTRE_X, WLK_SQR_CENTRE_Y, this.z, this.cx1, this.cy1, this.z);
                MoveLightningEx(this.l2, false, WLK_SQR_CENTRE_X, WLK_SQR_CENTRE_Y, this.z, this.cx2, this.cy2, this.z);
                this.count -= 1;
                if (this.count < 1) {
                    // destroy lightning
                    DestroyLightning(this.l1);
                    DestroyLightning(this.l2);
                    // deal damage
                    i = 0;
                    while (i < PlayerUnits.n) {
                        if (IsPointInTriangle(GetUnitX(PlayerUnits.units[i]), GetUnitY(PlayerUnits.units[i]), WLK_SQR_CENTRE_X, WLK_SQR_CENTRE_Y, this.cx1, this.cy1, this.cx2, this.cy2) == true) {
                            DamageTarget(this.caster, PlayerUnits.units[i], 400 + GetRandomReal(0, 200), SpellData.inst(SID_DANCE_MAT, SCOPE_PREFIX).name, false, false, false, WEAPON_TYPE_WHOKNOWS, true);
                        }
                        i += 1;
                    }
                    // visual effects
                    VisualEffects.spamEffectsInTriangle(ART_VolcanoDeath, WLK_SQR_CENTRE_X, WLK_SQR_CENTRE_Y, this.cx1, this.cy1, this.cx2, this.cy2, 32, 0.5);
                    // destroy
                    ReleaseTimer(this.tm);
                    this.tm = null;
                    this.l1 = null;
                    this.l2 = null;
                    this.caster = null;
                    this.deallocate();
                }
            });
        }
    }

    function onCast() {
        DanceMatConst.getCurrent();
        DanceMat.start(SpellEvent.CastingUnit, DanceMatConst.p1x, DanceMatConst.p1y, DanceMatConst.p2x, DanceMatConst.p2y, DanceMatConst.currentCD);
        UnitAbilityCD.make(SpellEvent.CastingUnit, SID_DANCE_MAT, DanceMatConst.currentCD);
        DanceMatConst.nextSector();
    }
    
    function onInit() {
        RegisterSpellEffectResponse(SID_DANCE_MAT, onCast);
    }

}
//! endzinc
