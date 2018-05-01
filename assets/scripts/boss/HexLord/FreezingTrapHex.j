//! zinc
library FreezingTrapHex requires SpellEvent, StunUtils, AggroSystem {
constant string  ART  = "Doodads\\Cinematic\\FrostTrapUp\\FrostTrapUp.mdl";
constant string  ART1  = "Abilities\\Spells\\Undead\\FrostNova\\FrostNovaTarget.mdl";
constant string  PATH  = "Doodads\\Cinematic\\GlowingRunes\\GlowingRunes4.mdl";
constant string  PATH1  = "Abilities\\Spells\\NightElf\\TrueshotAura\\TrueshotAura.mdl";
constant string  SFX  = "Abilities\\Spells\\Undead\\FreezingBreath\\FreezingBreathTargetArt.mdl";
    
    struct FreezngTrap {
        private timer tm;
        private unit u;
        private Point p;
        private effect trap;
        private integer count;
        
        private method destroy() {
            FreezingTrapHexSpots.remove(this.p);
            this.p.destroy();
            ReleaseTimer(this.tm);
            this.tm = null;
            this.u = null;
            this.trap = null;
            this.deallocate();
        }
        
        private static method watchout() {
            thistype this = GetTimerData(GetExpiredTimer());
            integer i = 0;
            unit near = null;
            real dis = HexLordGlobalConst.freezingTrapAOE;
            real tmp;
            while (i < PlayerUnits.n) {
                tmp = GetDistance.unitCoord2d(PlayerUnits.units[i], this.p.x, this.p.y);
                if (tmp <= dis) {
                    near = PlayerUnits.units[i];
                    dis = tmp;
                }
                i += 1;
            }
            if (near != null) {
                AddTimedEffect.atCoord(ART, this.p.x, this.p.y, 2.0);
                AddTimedEffect.atCoord(ART1, this.p.x, this.p.y, 0.1);
                StunUnit(this.u, near, 5.0);                
                AddTimedEffect.atUnit(SFX, near, "origin", 5.0);
                AggroClear(near, 0.99);
                DestroyEffect(this.trap);
                this.destroy();
            } else {
                this.count -= 1;
                if (this.count < 1) {
                    DestroyEffect(this.trap);
                    this.destroy();
                }
            }
        }
        
        private static method trapReady() {
            thistype this = GetTimerData(GetExpiredTimer());
            this.trap = AddSpecialEffect(PATH, this.p.x, this.p.y);
            this.count = 100;
            TimerStart(this.tm, 0.3, true, function thistype.watchout);
        }
    
        static method start(unit u, Point p, real dur) {
            thistype this = thistype.allocate();
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.u = u;
            this.p = p;
            FreezingTrapHexSpots.add(this.p);
            AddTimedEffect.atCoord(PATH1, this.p.x, this.p.y, 0.1);
            TimerStart(this.tm, dur, false, function thistype.trapReady);
        }
    }

    function onCast() {
        unit target = AggroList[SpellEvent.CastingUnit].getFirst();
        FreezngTrap.start(SpellEvent.CastingUnit, Point.new(GetUnitX(target), GetUnitY(target)), 2.0);
        //TerrainChange.start(SpellEvent.TargetX, SpellEvent.TargetY);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_FREEZING_TRAP_HEX, onCast);
    }





}
//! endzinc
