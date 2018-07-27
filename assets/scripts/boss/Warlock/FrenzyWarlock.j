//! zinc
library FrenzyWarlock requires SpellEvent, BuffSystem {

    private struct FrenzyWarlock {
        private timer tm;
        
        private method destroy() {
            ReleaseTimer(this.tm);
            this.tm = null;
            this.deallocate();
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            unit u = GetFireRune();
            if (u != null) {
                CreateUnit(Player(MOB_PID), UTID_LAVA_SPAWN, GetUnitX(u), GetUnitY(u), GetRandomReal(0, 360));
                AddTimedEffect.atCoord(ART_DOOM, GetUnitX(u), GetUnitY(u), 0.5);
                KillUnit(u);
                NextFireRune();
            } else {
                this.destroy();
            }
        }
    
        static method start() {
            thistype this = thistype.allocate();
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            TimerStart(this.tm, 0.6, true, function thistype.run);
        }
    }

    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAttackSpeed(buf.bd.i0);
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAttackSpeed(0 - buf.bd.i0);
    }
    
    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BID_FRENZY_WARLOCK);
        buf.bd.tick = -1;
        buf.bd.interval = 200;
        onRemove(buf);
        buf.bd.i0 = 50;
        if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_BLOOD_LUST_LEFT, buf, "hand, left");}
        if (buf.bd.e1 == 0) {buf.bd.e1 = BuffEffect.create(ART_BLOOD_LUST_RIGHT, buf, "hand, right");}
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        FrenzyWarlock.start();
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_FRENZY_WARLOCK, onCast);
        BuffType.register(BID_FRENZY_WARLOCK, BUFF_PHYX, BUFF_POS);
    }

}
//! endzinc
