//! zinc
library DarkArrow requires SpellEvent, DamageSystem, Projectile, RhokDelar {
#define PATH "Abilities\\Spells\\Other\\BlackArrow\\BlackArrowMissile.mdl"

    function returnDamage(integer lvl, real ap) -> real {
        return ap * (0.8 + 0.4 * lvl);
    }

    function onhit(Projectile p) -> boolean {
        DamageTarget(p.caster, p.target, p.r0, SpellData[SIDDARKARROW].name, true, true, false, WEAPON_TYPE_WHOKNOWS);
        return true;
    }
    
    function shootArrow(unit caster, unit target) {
        Projectile p = Projectile.create();
        p.caster = caster;
        p.target = target;
        p.path = PATH;
        p.pr = onhit;
        p.speed = 900;
        p.r0 = returnDamage(GetUnitAbilityLevel(p.caster, SIDDARKARROW), UnitProp[p.caster].AttackPower());
        p.launch();
    }
    
    struct DarkArrowShoot {
        timer tm;
        integer tick;
        unit u, tar;
        
        private method destroy() {
            ReleaseTimer(this.tm);
            this.tm = null;
            this.u = null;
            this.tar = null;
            this.deallocate();
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            this.tick -= 1;
            if (this.tick > 0) {
                shootArrow(this.u, this.tar);
            } else {
                this.destroy(); 
            }
        }
    
        static method start(unit u, unit tar, integer arrows) {
            thistype this = thistype.allocate();
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.u = u;
            this.tar = tar;
            this.tick = arrows;
            TimerStart(this.tm, 0.5, true, function thistype.run);
            shootArrow(u, tar);
        }
    }

    function onCast() {
        integer lvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDDARKARROW);
        integer arrows = 1;    
        integer rnd;
            
        // equiped Rhok' Delar
        if (HasRhokDelar(SpellEvent.CastingUnit)) {
            arrows = 2;
        }
        
        if (lvl == 2 && GetRandomInt(0, 99) < 40) {
            arrows += 1;
        } else if (lvl == 3) {
            rnd = GetRandomInt(0, 99);
            if (rnd < 80) {
                arrows += 1;
                if (rnd < 40) {
                    arrows += 1;
                }
            }
        }
        
        DarkArrowShoot.start(SpellEvent.CastingUnit, SpellEvent.TargetUnit, arrows);
    }

    function onInit() {
        RegisterSpellEffectResponse(SIDDARKARROW, onCast);
    }
   
#undef PATH
}
//! endzinc
