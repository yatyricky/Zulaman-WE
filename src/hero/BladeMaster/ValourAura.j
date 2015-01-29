//! zinc
library ValourAura requires TimerUtils, ZAMCore, UnitProperty, OrcCaptureFlag {
//*****************************************************************************
//* Known Bugs:
//**************
//* Overpower cannot trigger life rep due to judging by 
//* "DamageResult.wasDodgable"
//*****************************************************************************
#define INTERVAL 1.0
#define AOE 900.0
#define BUFF_ID 'A04M'

    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].attackCrit += buf.bd.r0;
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].attackCrit -= buf.bd.r0;
    }

    struct ValourAura {
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
                        UnitProp[buf.bd.target].attackCrit -= buf.bd.r0;                        
                        
                        // equiped orc capture flag
                        if (HasOrcCaptureFlag(this.u)) {
                            buf.bd.r0 = 0.05;
                        } else {
                            buf.bd.r0 = 0.03;
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
    
    function registerVA(unit u) {
        if (GetUnitTypeId(u) == UTIDBLADEMASTER) {
            ValourAura.register(u);
        }
    }
    
    function responsedamaged() {
        if (GetUnitAbilityLevel(DamageResult.source, BUFF_ID) > 0) {
            if (DamageResult.isCritical && DamageResult.isPhyx && DamageResult.wasDodgable) {
                HealTarget(DamageResult.source, DamageResult.source, GetUnitState(DamageResult.source, UNIT_STATE_MAX_LIFE) * 0.05, SpellData[SIDVALOURAURA].name, -3.0);
            }
        }
    }
    
    function onInit() {
        RegisterUnitEnterMap(registerVA);
        RegisterDamagedEvent(responsedamaged);
        BuffType.register(BUFF_ID, BUFF_PHYX, BUFF_POS);
    }
}
#undef BUFF_ID
#undef AOE
#undef INTERVAL
//! endzinc
