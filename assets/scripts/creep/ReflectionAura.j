//! zinc
library ReflectionAura requires SpellEvent, SpellReflection, AggroSystem {
constant real INTERVAL = 1.0;
    
    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModSpellReflect(buf.bd.i0);
    }
    
    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModSpellReflect(0 - buf.bd.i0);
    }

    struct ReflectionAura {
        unit u;
        timer tm;

        private method destroy() {
            ReleaseTimer(this.tm);
            this.u = null;
            this.tm = null;
            this.deallocate();
        }
        
        static method check() {
            thistype this = GetTimerData(GetExpiredTimer());
            integer i = 0;
            Buff buf;
            if (!IsUnitDead(this.u)) {
                while (i < MobList.n) {
                    if (GetDistance.units2d(MobList.units[i], this.u) <= 600.0 && !IsUnitDead(MobList.units[i])) {
                        buf = Buff.cast(this.u, MobList.units[i], BID_REFLECTION_AURA);
                        buf.bd.tick = -1;
                        buf.bd.interval = INTERVAL * 2.0;
                        buf.bd.i0 = 999;
                        buf.bd.boe = onEffect;
                        buf.bd.bor = onRemove;
                        buf.run();
                    }
                    i += 1;
                }
            } else {
                this.destroy();
            }
        }
        
        static method register(unit u) {
            thistype this = thistype.allocate();
            this.u = u;
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            TimerStart(this.tm, INTERVAL, true, function thistype.check);
        }
    }
    
    function registerReflectionAura(unit u) {
        if (GetUnitTypeId(u) == UTID_OBSIDIAN_CONSTRUCT) {
            ReflectionAura.register(u);
        }
    }
    
    function onInit() {
        RegisterUnitEnterMap(registerReflectionAura);
        BuffType.register(BID_REFLECTION_AURA, BUFF_PHYX, BUFF_POS);
    }


}
//! endzinc
