//! zinc
library Purge requires BuffSystem, SpellEvent, UnitProperty {
#define BUFF_ID 'A034'
#define BUFF_ID1 'A035'
#define ART "units\\human\\WaterElemental\\WaterElemental.mdl"

    struct internalCD {
        private static HandleTable ht;
        private timer tm;
        private unit u;
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            ReleaseTimer(this.tm);
            thistype.ht.flush(this.u);
            this.tm = null;
            this.u = null;
            this.deallocate();
        }
        
        static method start(unit u, real timeout) {
            thistype this;
            if (thistype.ht.exists(u)) {
                this = thistype.ht[u];
            } else {
                this = thistype.allocate();
                this.tm = NewTimer();
                SetTimerData(this.tm, this);
                thistype.ht[u] = this;
                this.u = u;
            }
            TimerStart(this.tm, timeout, false, function thistype.run);
        }
        
        static method has(unit u) -> boolean {
            return thistype.ht.exists(u);
        }
        
        private static method onInit() {
            thistype.ht = HandleTable.create();
        }
    }

    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].ModAttackSpeed(buf.bd.i0);
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].ModAttackSpeed(0 - buf.bd.i0);
    }

    function onEffect1(Buff buf) {
        UnitProp[buf.bd.target].ModAttackSpeed(0 - buf.bd.i0);
    }

    function onRemove1(Buff buf) {
        UnitProp[buf.bd.target].ModAttackSpeed(buf.bd.i0);
    }

    function onCast() {
        Buff buf;
        player p;
        if (IsUnitAlly(SpellEvent.TargetUnit, GetOwningPlayer(SpellEvent.CastingUnit))) {
            buf = BuffSlot[SpellEvent.TargetUnit].dispel(BUFF_MAGE, BUFF_NEG);
            if (buf != 0) {
                buf.destroy();
            }
            if (!internalCD.has(SpellEvent.CastingUnit)) {
                buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BUFF_ID);
                buf.bd.tick = -1;
                buf.bd.interval = 6.0;
                UnitProp[buf.bd.target].ModAttackSpeed(0 - buf.bd.i0);
                buf.bd.i0 = 15;
                buf.bd.boe = onEffect;
                buf.bd.bor = onRemove;
                buf.run();
                internalCD.start(SpellEvent.CastingUnit, 30 - 5 * GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDPURGE));
                AddTimedEffect.atUnit(ART, SpellEvent.TargetUnit, "origin", 0.0);
            }
        } else {
            buf = BuffSlot[SpellEvent.TargetUnit].dispel(BUFF_MAGE, BUFF_POS);
            if (buf != 0) {
                buf.destroy();
            }
            if (!internalCD.has(SpellEvent.CastingUnit)) {
                buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BUFF_ID1);
                buf.bd.tick = -1;
                buf.bd.interval = 6.0;
                UnitProp[buf.bd.target].ModAttackSpeed(buf.bd.i0);
                buf.bd.i0 = 15;
                buf.bd.boe = onEffect1;
                buf.bd.bor = onRemove1;
                buf.run();
                internalCD.start(SpellEvent.CastingUnit, 30 - 5 * GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDPURGE));
                AddTimedEffect.atUnit(ART, SpellEvent.TargetUnit, "origin", 0.0);
            }
        }
        AddTimedEffect.atUnit(ART_WATER, SpellEvent.TargetUnit, "origin", 0.2);
        if (GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDENCHANTEDTOTEM) > 0) {
            p = GetOwningPlayer(SpellEvent.CastingUnit);
            SetPlayerAbilityAvailable(p, SIDLIGHTNINGTOTEM, false);
            SetPlayerAbilityAvailable(p, SIDEARTHBINDTOTEM, false);
            SetPlayerAbilityAvailable(p, SIDTORRENTTOTEM, true);
            currentTotemId[GetPlayerId(p)] = SIDTORRENTTOTEM;
            p = null;
        }
    }

    function onInit() {
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
        BuffType.register(BUFF_ID1, BUFF_MAGE, BUFF_NEG);
        RegisterSpellEffectResponse(SIDPURGE, onCast);
    }
#undef ART
#undef BUFF_ID1
#undef BUFF_ID
}
//! endzinc
