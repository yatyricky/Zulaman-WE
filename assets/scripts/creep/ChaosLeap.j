//! zinc
library ChaosLeap requires DamageSystem {
/*
Leap to target. Deals 200 AOE damage on landing. Damaged targets deal 300% extra threat.
Duration 10 seconds
Physical negative effect
*/
constant string  EFF  = "Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile_mini.mdl";
constant string  ART  = "Abilities\\Spells\\Orc\\Bloodlust\\BloodlustTarget.mdl";
constant string  IMPACT  = "Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl";
constant real INTERVAL = 0.04;
constant real SPEED = 900.0;
constant real MAX_HEIGHT = 400.0;
constant real AOE = 250.0;
constant real DAMAGE = 300.0;
    
    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).aggroRate += buf.bd.r0;
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).aggroRate -= buf.bd.r0;
    }

    struct Leap {
        private timer tm;
        private unit caster;
        private effect eff;
        private real dx, dy;
        private real maxHeight;
        private integer count, ctr;
        
        private method destroy() {
            SetUnitPathing(this.caster, true);
            RemoveStun(this.caster);
            DestroyEffect(this.eff);
            ReleaseTimer(this.tm);
            this.tm = null;
            this.caster = null;
            this.eff = null;
            this.deallocate();
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            integer i;
            Buff buf;
            real height;
            this.ctr += 1;
            SetUnitX(this.caster, GetUnitX(this.caster) + this.dx);
            SetUnitY(this.caster, GetUnitY(this.caster) + this.dy);
            height = Sin(this.ctr / this.count * 3.1415) * this.maxHeight;
            if (height < 0.0) {
                height = 0.0;
            }
            SetUnitFlyHeight(this.caster, height, 0.0);
            if (this.ctr >= this.count) {
                AddTimedEffect.atCoord(IMPACT, GetUnitX(this.caster), GetUnitY(this.caster), 0.1);
                for (0 <= i < PlayerUnits.n) {
                    if (GetDistance.units(this.caster, PlayerUnits.units[i]) < AOE) {
                        DamageTarget(this.caster, PlayerUnits.units[i], DAMAGE, SpellData.inst(SID_CHAOS_LEAP, SCOPE_PREFIX).name, false, true, false, WEAPON_TYPE_WHOKNOWS);

                        buf = Buff.cast(this.caster, PlayerUnits.units[i], BID_CHAOS_LEAP);
                        buf.bd.tick = -1;
                        buf.bd.interval = 10;
                        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).aggroRate -= buf.bd.r0;
                        buf.bd.r0 = 3.0;
                        if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART, buf, "overhead");}
                        buf.bd.boe = onEffect;
                        buf.bd.bor = onRemove;
                        buf.run();
                    }
                }
                this.destroy();
            }
        }
        
        static method start(unit caster, unit target) {
            thistype this = thistype.allocate();
            real distance = GetDistance.units(caster, target);
            real step = SPEED * INTERVAL;
            this.maxHeight = MAX_HEIGHT * distance / SPEED;
            this.caster = caster;
            SetUnitFlyable(this.caster);
            SetUnitPathing(this.caster, false);
            StunUnit(this.caster, this.caster, 99);
            this.eff = AddSpecialEffectTarget(EFF, this.caster, "origin");
            this.dx = step * (GetUnitX(target) - GetUnitX(this.caster)) / distance;
            this.dy = step * (GetUnitY(target) - GetUnitY(this.caster)) / distance;
            this.count = Rounding(distance / step);
            this.ctr = 0;
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            TimerStart(this.tm, INTERVAL, true, function thistype.run);
        }
    }

    function onCast() {
        Leap.start(SpellEvent.CastingUnit, SpellEvent.TargetUnit);
    }

    function onInit() {
        BuffType.register(BID_CHAOS_LEAP, BUFF_PHYX, BUFF_NEG);
        RegisterSpellEffectResponse(SID_CHAOS_LEAP, onCast);
    }








}
//! endzinc
