//! zinc
library CthunsDerangement requires ItemAttributes, DamageSystem {
#define BUFF_ID 'A06P'
#define BUFF_ID1 'A06R'
#define ART "Abilities\\Spells\\Undead\\UnholyFrenzy\\UnholyFrenzyTarget.mdl"
    HandleTable ht;
    
    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].damageTaken += buf.bd.r0;
        UnitProp[buf.bd.target].ModAttackSpeed(buf.bd.i0);
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].damageTaken -= buf.bd.r0;
        UnitProp[buf.bd.target].ModAttackSpeed(0 - buf.bd.i0);
    }
    
    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BUFF_ID);
        buf.bd.tick = -1;
        buf.bd.interval = 10;
        UnitProp[buf.bd.target].damageTaken -= buf.bd.r0;
        buf.bd.r0 = 1.0;
        UnitProp[buf.bd.target].ModAttackSpeed(0 - buf.bd.i0);
        buf.bd.i0 = 40;
        if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART, buf, "overhead");}
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }

    struct CthunsDerangementData {
        private static HandleTable enigtable;
        // mod
        integer ap;
        
        static method operator[] (item it) -> thistype {
            thistype this;
            if (!thistype.enigtable.exists(it)) {
                this = thistype.allocate();
                thistype.enigtable[it] = this;
                // mod
                this.ap = 0;
            } else {
                this = thistype.enigtable[it];
            }
            return this;
        }
        
        private static method onInit() {thistype.enigtable = HandleTable.create();}
    }

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        CthunsDerangementData cd = CthunsDerangementData[it];
        
        up.ModStr(20 * fac);
        up.attackCrit += 0.04 * fac;
        up.lifeRegen -= 40.0 * fac;
	    up.ll += 0.14 * fac;
        
        if (fac == 1) {
            cd.ap = 5 * GetHeroLevel(u);
        }
        up.ModAP(cd.ap * fac);
        
        if (!ht.exists(u)) {ht[u] = 0;}
        ht[u] = ht[u] + fac;
    }
    
    // i0 = current increment; i1 = final decrement
    function onEffect1(Buff buf) {
        UnitProp[buf.bd.target].ModAttackSpeed(buf.bd.i0);
    }

    function onRemove1(Buff buf) {
        UnitProp[buf.bd.target].ModAttackSpeed(0 - buf.bd.i1);
    }
    
    function damaged() {
        Buff buf;
        if (DamageResult.isHit) {
            if (ht.exists(DamageResult.source)) {
                if (ht[DamageResult.source] > 0 && DamageResult.abilityName == DAMAGE_NAME_MELEE) {
                    buf = Buff.cast(DamageResult.source, DamageResult.source, BUFF_ID1);
                    buf.bd.tick = -1;
                    buf.bd.interval = 3.0;    
                    if (buf.bd.i1 < 10) {
                        buf.bd.i0 = 1;
                    } else {
                        buf.bd.i0 = 0;
                    }
                    buf.bd.i1 += buf.bd.i0;
                    buf.bd.boe = onEffect1;
                    buf.bd.bor = onRemove1;
                    buf.run();
                }
            }
        }
    }
    
    function lvledup() -> boolean {
        unit u = GetTriggerUnit();
        integer i;
        item tmpi;
        ItemPropModType ipmt;
        if (ht.exists(u)) {
            if (ht[u] > 0) {
                ipmt = action;
                i = 0;
                while (i < 6) {
                    tmpi = UnitItemInSlot(u, i);
                    if (GetItemTypeId(tmpi) == ITID_CTHUNS_DERANGEMENT) {
                        ipmt.evaluate(u, tmpi, -1);
                        ipmt.evaluate(u, tmpi, 1);
                    }
                    i += 1;
                }
            }
        }
        return false;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterItemPropMod(ITID_CTHUNS_DERANGEMENT, action);
        RegisterSpellEffectResponse(SID_CTHUNS_DERANGEMENT, onCast);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
        BuffType.register(BUFF_ID1, BUFF_PHYX, BUFF_POS);
        RegisterDamagedEvent(damaged);
        TriggerAnyUnit(EVENT_PLAYER_HERO_LEVEL, function lvledup);
    }
#undef ART
#undef BUFF_ID1
#undef BUFF_ID
}
//! endzinc
