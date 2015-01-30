//! zinc
library LaserBeam requires CastingBar {
#define ART_GROUND "Abilities\\Spells\\Human\\FlameStrike\\FlameStrikeEmbers.mdl"
#define ART_SCORCH "Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl"
#define ART_TARGET "Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl"
#define AOE 30
#define VELOCITY 4.0

    public struct LaserFireDamage {
        static LaserFireDamage instances[];
        static integer num;
        effect eff;
        real x, y;
        timer tm;
        unit caster;
        integer count;
        
        private static method remove(LaserFireDamage d) {
            integer i = 0;
            boolean flag = true;
            while (i < thistype.num && flag) {
                if (thistype.instances[i] == d) {
                    thistype.num -= 1;
                    thistype.instances[i] = thistype.instances[thistype.num];
                    flag = false;
                }
                i += 1;
            }
        }
        
        private method destroy() {
            thistype.remove(this);
            DestroyEffect(this.eff);
            ReleaseTimer(this.tm);
            this.tm = null;
            this.eff = null;
            this.caster = null;
            this.deallocate();
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            integer i = 0;
            while (i < PlayerUnits.n) {
                if (!IsUnitDead(PlayerUnits.units[i]) && !IsUnitDummy(PlayerUnits.units[i]) && GetDistance.unitCoord2d(PlayerUnits.units[i], this.x, this.y) <= DBMArchTinker.laserBeamAOE) {
                    DamageTarget(this.caster, PlayerUnits.units[i], 200.0, SpellData[SID_LASER_BEAM].name, false, false, false, WEAPON_TYPE_WHOKNOWS);
                    AddTimedEffect.atUnit(ART_TARGET, PlayerUnits.units[i], "origin", 0.3);
                }
                i += 1;
            }
            this.count -= 1;
            if (this.count < 1) {
                this.destroy();
            }
        }
        
        static method add(unit caster, real x, real y) {
            integer i = 0;
            boolean flag = true;
            thistype this;
            while (i < thistype.num && flag) {
                if (GetDistance.coords2d(x, y, thistype.instances[i].x, thistype.instances[i].y) < AOE) {
                    flag = false;
                }
                i += 1;
            }
            if (flag) {
                this = thistype.allocate();
                this.caster = caster;
                this.x = x;
                this.y = y;
                this.count = 11;
                this.eff = AddSpecialEffect(ART_GROUND, x, y);
                this.tm = NewTimer();
                SetTimerData(this.tm, this);
                thistype.instances[thistype.num] = this;
                thistype.num += 1;
                TimerStart(this.tm, 1.0, true, function thistype.run);
            }
        }
        
        static method onInit() {
            thistype.num = 0;
        }
    }

    struct LaserBeamData {
        lightning l;
        real x1, y1, z1;
        real x2, y2, z2;
        
        method destroy() {
            DBMArchTinker.laserTarget = null;
            DestroyLightning(this.l);
            this.l = null;
            this.deallocate();
        }
    }

    function response(CastingBar cd) {
        //print("Target: (" + R2S(cd.targetX) + ", " + R2S(cd.targetY) + ")");
        LaserBeamData data = LaserBeamData(cd.extraData);
        real xt, yt, dis;
        integer i;
        // visual effect beam
        if (cd.nodes < 175) {
            xt = GetUnitX(cd.target);
            yt = GetUnitY(cd.target);
            dis = GetDistance.coords2d(data.x2, data.y2, xt, yt);
            if (dis < VELOCITY) {dis = VELOCITY;}
            data.x2 = data.x2 + (xt - data.x2) / dis * VELOCITY;
            data.y2 = data.y2 + (yt - data.y2) / dis * VELOCITY;
            MoveLightningEx(data.l, false, data.x1, data.y1, data.z1, data.x2, data.y2, data.z2);
            if (cd.nodes == -1) {
                data.destroy();
            }
            
            if (ModuloInteger(cd.nodes, 10) == 0) {
                i = 0;
                while (i < PlayerUnits.n) {
                    if (!IsUnitDead(PlayerUnits.units[i]) && !IsUnitDummy(PlayerUnits.units[i]) && GetDistance.unitCoord(PlayerUnits.units[i], data.x2, data.y2) < DBMArchTinker.laserBeamAOE) {
                        DamageTarget(cd.caster, PlayerUnits.units[i], 200.0, SpellData[SID_LASER_BEAM].name, false, false, false, WEAPON_TYPE_WHOKNOWS);
                    }
                    i += 1;
                }
            }
            
            DBMArchTinker.laserX = data.x2;
            DBMArchTinker.laserY = data.y2;
        }
        // visual effect fire
        if (ModuloInteger(cd.nodes, 5) == 0) {
            AddTimedEffect.atCoord(ART_SCORCH, data.x2, data.y2, 0.0);
            //TerrainDeformRipple(data.x2, data.y2, 200.0, 64, 20000, false);
        }
        // add fire 
        if (ModuloInteger(cd.nodes, 7) == 0) {
            LaserFireDamage.add(cd.caster, data.x2, data.y2);
        }
    }
    
    function onChannel() {
        CastingBar cb = CastingBar.create(response);
        location la = GetUnitLoc(SpellEvent.CastingUnit);
        location lb = GetUnitLoc(SpellEvent.TargetUnit);
        LaserBeamData lbd = LaserBeamData.create();
        cb.extraData = lbd;
        lbd.x1 = GetLocationX(la);
        lbd.y1 = GetLocationY(la);
        lbd.z1 = GetLocationZ(la) + GetUnitFlyHeight(SpellEvent.CastingUnit);
        lbd.x2 = GetLocationX(lb);
        lbd.y2 = GetLocationY(lb);
        lbd.z2 = GetLocationZ(lb);
        lbd.l = AddLightningEx("SPLK", false, lbd.x1, lbd.y1, lbd.z1, lbd.x2, lbd.y2, lbd.z2);
        SetLightningColor(lbd.l, 1.0, 0.6, 0.6, 1.0);
        cb.channel(250);
        
        DBMArchTinker.laserTarget = SpellEvent.TargetUnit;            
        DBMArchTinker.laserX = SpellEvent.TargetX;
        DBMArchTinker.laserY = SpellEvent.TargetY;
        
        RemoveLocation(la);
        RemoveLocation(lb);
        la = null;
        lb = null;
    }

    function onInit() {
        RegisterSpellChannelResponse(SID_LASER_BEAM, onChannel);
    }
#undef VELOCITY
#undef AOE
#undef ART_TARGET
#undef ART_SCORCH
#undef ART_GROUND
}
//! endzinc
