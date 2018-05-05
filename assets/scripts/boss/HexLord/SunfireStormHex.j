//! zinc
library SunfireStorm requires SpellEvent, TimerUtils, AggroSystem, HexLordGlobal {
constant string  ART_CASTER  = "Abilities\\Weapons\\DemolisherFireMissile\\DemolisherFireMissile.mdl";
constant string  ART_EFFECT  = "Abilities\\Spells\\Orc\\LiquidFire\\Liquidfire.mdl";

    struct SunFieldHex {
        real dmg;
        integer count;
        unit caster;
        real aoe;
        timer tm;
        Point p;
        
        method destroy() {
            SunFireStormHexSpots.remove(this.p);
            this.p.destroy();
            ReleaseTimer(this.tm);
            this.caster = null;
            this.tm = null;
            this.deallocate();
            // BJDebugMsg(I2S(SunFireStormHexSpots.size()));
        }
        
        static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            integer i = 0;
            if (IsInCombat()) {
                while (i < PlayerUnits.n) {
                    if (GetDistance.unitCoord(PlayerUnits.units[i], this.p.x, this.p.y) < HexLordGlobalConst.sunFireAOE && !IsUnitDead(PlayerUnits.units[i])) {
                        DamageTarget(this.caster, PlayerUnits.units[i], this.dmg, SpellData.inst(SID_SUN_FIRE_STORMHEX, SCOPE_PREFIX).name, false, false, false, WEAPON_TYPE_WHOKNOWS);
                    }
                    i += 1;
                }
            }
            this.count -= 1;
            if (this.count < 1) {
                this.destroy();
            }
        }
    
        static method new(unit u, Point p) {
            thistype this = thistype.allocate();
            this.caster = u;
            this.aoe = 150.0;
            this.count = 8;
            this.dmg = 300.0;
            this.p = p;
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            TimerStart(this.tm, 1.0, true, function thistype.run);
            SunFireStormHexSpots.push(this.p);
            AddTimedEffect.atCoord(ART_CASTER, this.p.x, this.p.y, 0.0);
            AddTimedEffect.atCoord(ART_EFFECT, this.p.x, this.p.y, this.count);
        }
    }

    function onCast() {
        unit target = AggroList[SpellEvent.CastingUnit].getFirst();
        real x = GetUnitX(target);
        real y = GetUnitY(target);
        unit tar = PlayerUnits.getRandomInRange(SpellEvent.CastingUnit, 3600.0);
        if (tar != null) {
            x = GetUnitX(tar);
            y = GetUnitY(tar);
        }
        SunFieldHex.new(SpellEvent.CastingUnit, Point.new(x, y));  
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_SUN_FIRE_STORMHEX, onCast);
    }


}
//! endzinc
