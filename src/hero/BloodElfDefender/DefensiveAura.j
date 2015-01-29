//! zinc
library DefensiveAura requires TimerUtils, ZAMCore, UnitProperty {
#define INTERVAL 1.0
#define AOE 900.0
#define BUFF_ID 'A04B'

    function onEffect(Buff buf) {}

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].ModArmor(-6);
    }

    struct DefensiveAura {
        unit u;
        timer tm;
        
        static method check() {
            thistype this = GetTimerData(GetExpiredTimer());
            integer i = 0;
            Buff buf;
            if (!IsUnitDead(this.u)) {
                while (i < PlayerUnits.n) {
                    if (GetDistance.units2d(PlayerUnits.units[i], this.u) <= AOE && !IsUnitDead(PlayerUnits.units[i])) {
                        buf = Buff.cast(this.u, PlayerUnits.units[i], BUFF_ID);
                        buf.bd.tick = -1;
                        buf.bd.interval = INTERVAL * 2.0;
                        if (buf.bd.i0 != 6) {
                            UnitProp[buf.bd.target].ModArmor(6);
                            buf.bd.i0 = 6;
                        }
                        buf.bd.boe = onEffect;
                        buf.bd.bor = onRemove;
                        buf.run();  
                    }
                    i += 1;
                }
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
    
    function registerDA(unit u) {
        if (GetUnitTypeId(u) == UTIDBLOODELFDEFENDER) {
            DefensiveAura.register(u);
        }
    }
    
    function onInit() {
        RegisterUnitEnterMap(registerDA);
        BuffType.register(BUFF_ID, BUFF_PHYX, BUFF_POS);
    }
}
#undef BUFF_ID
#undef AOE
#undef INTERVAL
//! endzinc
