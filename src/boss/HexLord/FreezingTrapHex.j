//! zinc
library FreezingTrapHex requires SpellEvent, StunUtils, AggroSystem {
#define ART "Doodads\\Cinematic\\FrostTrapUp\\FrostTrapUp.mdl"
#define ART1 "Abilities\\Spells\\Undead\\FrostNova\\FrostNovaTarget.mdl"
#define PATH "Doodads\\Cinematic\\GlowingRunes\\GlowingRunes4.mdl"
#define PATH1 "Abilities\\Spells\\NightElf\\TrueshotAura\\TrueshotAura.mdl"
#define SFX "Abilities\\Spells\\Undead\\FreezingBreath\\FreezingBreathTargetArt.mdl"
    
    struct FreezngTrap {
        private timer tm;
        private unit u;
        private real x, y;
        private effect trap;
        private integer count;
        
        private method destroy() {
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
            real dis = 100.0;
            real tmp;
            while (i < PlayerUnits.n) {
                tmp = GetDistance.unitCoord2d(PlayerUnits.units[i], this.x, this.y);
                if (tmp <= dis) {
                    near = PlayerUnits.units[i];
                    dis = tmp;
                }
                i += 1;
            }
            if (near != null) {
                AddTimedEffect.atCoord(ART, this.x, this.y, 2.0);
                AddTimedEffect.atCoord(ART1, this.x, this.y, 0.1);
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
            this.trap = AddSpecialEffect(PATH, this.x, this.y);
            this.count = 100;
            TimerStart(this.tm, 0.3, true, function thistype.watchout);
        }
    
        static method start(unit u, real x, real y, real dur) {
            thistype this = thistype.allocate();
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.u = u;
            this.x = x;
            this.y = y;
            AddTimedEffect.atCoord(PATH1, x, y, 0.1);
            TimerStart(this.tm, dur, false, function thistype.trapReady);
        }
    }

    function onCast() {
        unit target = AggroList[SpellEvent.CastingUnit].getFirst();
        FreezngTrap.start(SpellEvent.CastingUnit, GetUnitX(target), GetUnitY(target), 2.0);
        //TerrainChange.start(SpellEvent.TargetX, SpellEvent.TargetY);
    }

    function onInit() {
        RegisterSpellEffectResponse(SIDFREEZINGTRAPHEX, onCast);
    }
#undef SFX
#undef PATH1
#undef PATH
#undef ART1
#undef ART
}
//! endzinc
