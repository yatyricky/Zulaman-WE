//! zinc
library LightningShield requires DamageSystem, AggroSystem {
#define HEIGHT 600
#define RADIUS 200
#define ART_TARGET "Abilities\\Spells\\Orc\\Purge\\PurgeBuffTarget.mdl"

    function onEffectNeg(Buff buf) {
        UnitProp[buf.bd.target].damageTaken += buf.bd.r0;
    }

    function onRemoveNeg(Buff buf) {
        UnitProp[buf.bd.target].damageTaken -= buf.bd.r0;
    }

    public struct LightningShield {
        private static HandleTable ht;
        private integer stack;
        private unit caster;
        private timer tm;
        private unit orbs[3];
        private unit mainOrb;
        private integer count;
        
        private method destroy() {
            integer i = 0;
            while (i < 3) {
                KillUnit(this.orbs[i]);
                this.orbs[i] = null;
                i += 1;
            }
            KillUnit(this.mainOrb);
            ReleaseTimer(this.tm);
            thistype.ht.flush(this.caster);
            this.tm = null;
            this.mainOrb = null;
            this.caster = null;
            this.deallocate();
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            integer i = 0;
            real ang, x, y;
            while (i < this.stack) {
                //ShowUnit(this.orbs[i], true);
                ang = ModuloReal(GetGameTime(), 6.0) / 6.0 * bj_PI * 2.0 + i * bj_PI * 2.0 / 3.0;
                x = Cos(ang) * RADIUS + GetUnitX(this.caster);
                y = Sin(ang) * RADIUS + GetUnitY(this.caster);
                if (this.orbs[i] == null) {
                    this.orbs[i] = CreateUnit(Player(MOB_PID), UTID_LIGHTNING_SHIELD_FX, x, y, 0.0);
                    SetUnitFlyable(this.orbs[i]);
//                    SetUnitFlyHeight(this.orbs[i], HEIGHT, 0.0);
                } else {
                    SetUnitX(this.orbs[i], x);
                    SetUnitY(this.orbs[i], y);
                }
                SetUnitX(this.mainOrb, GetUnitX(this.caster));
                SetUnitY(this.mainOrb, GetUnitY(this.caster));
                AddTimedLight.atUnitsZ("CLSB", this.orbs[i], 0.0, this.caster, HEIGHT, 0.04);
                //AddTimedEffect.atCoord(ART_IMPACT, x, y, 0.04);
                i += 1;
            }
            while (i < 3) {
                if (!IsUnitDead(this.orbs[i])) {
                    KillUnit(this.orbs[i]);
                    this.orbs[i] = null;
                }
                //ShowUnit(this.orbs[i], false);
                i += 1;
            }
        }
    
        static method start(unit caster) {
            thistype this;
            integer i;
            if (thistype.ht.exists(caster)) {
                this = thistype(thistype.ht[caster]);
            } else {
                this = thistype.allocate();
                thistype.ht[caster] = this;
                this.caster = caster;
                
                i = 0;
                while (i < 3) {
                    this.orbs[i] = null;
                    i += 1;
                }
                this.mainOrb = CreateUnit(Player(MOB_PID), UTID_LIGHTNING_SHIELD_FX, GetUnitX(caster), GetUnitY(caster), 0.0);
                SetUnitFlyable(this.mainOrb);
                SetUnitFlyHeight(this.mainOrb, HEIGHT, 0.0);
                
                this.tm = NewTimer();
                SetTimerData(this.tm, this);
            }
            this.stack = 3;
            TimerStart(this.tm, 0.04, true, function thistype.run);
        }
        
        static method shatter(unit caster) {
            thistype this;
            Buff buf;
            BuffSlot bs;
            if (thistype.ht.exists(caster)) {
                this = thistype(thistype.ht[caster]);
                this.stack -= 1;
                if (this.stack < 1) {
                    KillUnit(this.orbs[0]);
                    this.orbs[0] = null;
                    bs = BuffSlot[caster];
                    buf = bs.getBuffByBid(BID_LIGHTNING_SHIELD);
                    if (buf != 0) {
                        bs.dispelByBuff(buf);
                        buf.destroy();
                    }
                }
            }
        }
        
        private static method runBreakDown() {
            thistype this = GetTimerData(GetExpiredTimer());
            AddTimedLight.atUnits("CLSB", this.caster, this.mainOrb, 0.1);
            if (IsInCombat()) {
                this.count -= 1;
            } else {
                this.count = 0;
            }            
            if (this.count < 1) {
                this.destroy();
            }
        }
        
        // only called by buff onRemove
        static method terminate(unit caster) {
            thistype this;
            Buff buf;
            if (thistype.ht.exists(caster)) {
                this = thistype(thistype.ht[caster]);

                buf = Buff.cast(caster, caster, BID_LIGHTNING_SHIELD_NEG);
                buf.bd.interval = 20.0;
                buf.bd.tick = -1;
                UnitProp[buf.bd.target].damageTaken -= buf.bd.r0;
                buf.bd.r0 = 5.0;
                if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_TARGET, buf, "origin");}
                buf.bd.boe = onEffectNeg;
                buf.bd.bor = onRemoveNeg;
                buf.run();
                
                StunBoss(caster, caster, 20.0);
                //print(GetUnitNameEx(this.mainOrb));
                AddTimedLight.atUnits("CLSB", this.caster, this.mainOrb, 0.1);
                this.count = 200;
                TimerStart(this.tm, 0.1, true, function thistype.runBreakDown);
            }
        }
        
        private static method onInit() {
            thistype.ht = HandleTable.create();
        }
    }

    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].damageTaken -= buf.bd.r0;
        LightningShield.start(buf.bd.target);
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].damageTaken += buf.bd.r0;
        LightningShield.terminate(buf.bd.target);
    }

    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BID_LIGHTNING_SHIELD);
        buf.bd.interval = 500.0;
        buf.bd.tick = -1;
        UnitProp[buf.bd.target].damageTaken += buf.bd.r0;
        buf.bd.r0 = 5.0;
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_LIGHTNING_SHIELD, onCast);
        BuffType.register(BID_LIGHTNING_SHIELD, BUFF_PHYX, BUFF_POS);
        BuffType.register(BID_LIGHTNING_SHIELD_NEG, BUFF_PHYX, BUFF_NEG);
    }
#undef ART_TARGET
#undef RADIUS
#undef HEIGHT
}
//! endzinc
