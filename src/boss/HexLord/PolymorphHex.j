//! zinc
library PolymorphHex requires CastingBar, SpellReflection {
#define BUFF_ID 'A03E'

    struct periodicallyDosth1 {
        private timer tm;
        private unit sor;
        private integer tick;
    
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            this.tick -= 1;
            if (this.tick > 0) {
                if (GetUnitAbilityLevel(this.sor, 'B00I') > 0) {
                    UnitRemoveAbility(this.sor, 'B00I');
                }
            } else {
                ReleaseTimer(this.tm);
                this.tm = null;
                this.sor = null;
                this.deallocate();
            }
        }
    
        static method start(unit sor) {
            thistype this = thistype.allocate();
            this.sor = sor;
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.tick = 5;
            TimerStart(this.tm, 0.1, true, function thistype.run);
        }
    }
    
    function onEffect(Buff buf) {            
        if (!IsUnitBoss(buf.bd.target)) {
            DummyCast(buf.bd.caster, SIDPOLYMORPHDUMMY, "hex", buf.bd.target);        
            UnitProp[buf.bd.target].disabled += 1;
        }
    }
    
    function onRemove(Buff buf) {
        // need a timer to clear B00I for a while, but no boss will be turned
        if (GetUnitAbilityLevel(buf.bd.target, 'B00I') > 0) {
            UnitRemoveAbility(buf.bd.target, 'B00I');
        }
        periodicallyDosth1.start(buf.bd.target);
        UnitProp[buf.bd.target].disabled -= 1;
    }
    
    function onCasst() {
        Buff buf;
		unit tmp;
        boolean canSheep = true; // TODO
        if (canSheep) {
			if (TryReflect(SpellEvent.TargetUnit)) {
				tmp = SpellEvent.CastingUnit;
				SpellEvent.CastingUnit = SpellEvent.TargetUnit;
				SpellEvent.TargetUnit = tmp;
			}
			if (canSheep) {
				buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BUFF_ID);
				buf.bd.tick = -1;
				buf.bd.interval = 10.0;
				buf.bd.boe = onEffect;
				buf.bd.bor = onRemove;
				buf.run();
			}
			tmp = null;
        }
    }
    
    //function damagedres() {
    //    Buff buf = BuffSlot[DamageResult.target].getBuffByBid(BUFF_ID);
    //    if (buf != 0) {
    //        BuffSlot[DamageResult.target].dispelByBuff(buf);
    //        buf.destroy();
    //    }
    //}

    function onInit() {
        RegisterSpellEffectResponse(SIDPOLYMORPHHEX, onCasst);
        //BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_NEG);
        //RegisterDamagedEvent(damagedres);
    }
#undef BUFF_ID
}
//! endzinc
