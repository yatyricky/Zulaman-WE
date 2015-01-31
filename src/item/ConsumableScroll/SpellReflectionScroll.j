//! zinc
library SpellReflectionScroll requires SpellEvent, SpellReflection {
#define FIELD_DUMMY_ID 'e00F'
#define BUFF_ID 'A077'
#define ART_EXPLOSION "Objects\\Spawnmodels\\NightElf\\NEDeathSmall\\NEDeathSmall.mdl"
#define DURATION 10
#define MAX_REFL 8
    
    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].ModSpellReflect(buf.bd.i0);
    }
    
    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].ModSpellReflect(0 - buf.bd.i0);
    }
    
    struct ArcaneField {
        private timer tm;
        private unit shieldUnit, caster;
        private integer tick;
        private integer max;
        
        private method destroy() {
            KillUnit(this.shieldUnit);
            this.tm = null;
            this.shieldUnit = null;
            this.caster = null;
            this.deallocate();
        }
        
        method reduce() {
            integer i = 0;
            BuffSlot bs;
            Buff buf;
            this.max -= 1;
            if (this.max < 1) {
                ReleaseTimer(this.tm);
                while (i < PlayerUnits.n) {
                    if (!IsUnitDead(PlayerUnits.units[i])) {
                        bs = BuffSlot[PlayerUnits.units[i]];
                        buf = bs.getBuffByBid(BUFF_ID);
                        if (buf.bd.i1 == this) {
                            bs.dispelByBuff(buf);
                            buf.destroy();
                        }
                    }
                    i += 1;
                }
                ShowUnit(this.shieldUnit, false);
                AddTimedEffect.atCoord(ART_EXPLOSION, GetUnitX(this.shieldUnit), GetUnitY(this.shieldUnit), 1.0);
                this.destroy();
            }
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            integer i;
            Buff buf;
            BuffSlot bs;
            if (this.tick == 98) {
                PauseUnit(this.shieldUnit, true);
                SetUnitTimeScale(this.shieldUnit, 0.0);
            }
            if (this.tick == 5) {
                PauseUnit(this.shieldUnit, false);
                SetUnitTimeScale(this.shieldUnit, 1.0);
            }
            this.tick -= 1;
            if (this.tick < 1) {
                ReleaseTimer(this.tm);
                this.destroy();
            }

            i = 0;
            while (i < PlayerUnits.n) {
                if (!IsUnitDead(PlayerUnits.units[i])) {
                    bs = BuffSlot[PlayerUnits.units[i]];
                    buf = bs.getBuffByBid(BUFF_ID);
                    if (GetDistance.units2d(PlayerUnits.units[i], this.shieldUnit) <= 400.0) {
                        if (buf == 0) {
                            buf = Buff.cast(this.caster, PlayerUnits.units[i], BUFF_ID);
                            buf.bd.tick = -1;
                            buf.bd.interval = this.tick / 10.0;
                            buf.bd.i0 = MAX_REFL;
                            buf.bd.i1 = this;
                            buf.bd.boe = onEffect;
                            buf.bd.bor = onRemove;
                            buf.run();
                        }
                    } else {
                        if (buf != 0) {
                            bs.dispelByBuff(buf);
                            buf.destroy();
                        }
                    }
                }
                i += 1;
            }
        }
    
        static method start(unit caster) {
            thistype this = thistype.allocate();
            this.shieldUnit = CreateUnit(GetOwningPlayer(caster), FIELD_DUMMY_ID, GetUnitX(caster), GetUnitY(caster), 0.0);
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.tick = 100;
            this.caster = caster;
            this.max = MAX_REFL;
            TimerStart(this.tm, 0.1, true, function thistype.run);
        }
    }
    
    function reflected(unit u) {
        Buff buf = BuffSlot[u].getBuffByBid(BUFF_ID);
        if (buf != 0) {
            buf.bd.i0 -= 1;
            ArcaneField(buf.bd.i1).reduce();
        }
    }
    
    function onCast() {
        ArcaneField.start(SpellEvent.CastingUnit);
    }
    
    function onInit() {
        RegisterSpellEffectResponse(SID_SPELL_REFLECTION_SCROLL, onCast);
        BuffType.register(BUFF_ID, BUFF_PHYX, BUFF_POS);
        RegisterSpellReflectionEvent(reflected);
    }
#undef MAX_REFL
#undef DURATION
#undef ART_EXPLOSION
#undef BUFF_ID
#undef FIELD_DUMMY_ID
}
//! endzinc
