//! zinc
library DaggerOfAssassination requires ItemAttributes, DamageSystem {
#define BUFF_ID 'A06A'
    HandleTable ht;
    
    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].spellHaste -= buf.bd.r0;
    }
    
    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].spellHaste += buf.bd.r0;
    }
    
    public function CastParalysisPoison(unit caster, unit target) {
        Buff buf = Buff.cast(caster, target, BUFF_ID);
        buf.bd.tick = -1;
        buf.bd.interval = 9;
        UnitProp[buf.bd.target].spellHaste += buf.bd.r0;
        buf.bd.r0 = 0.2;
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }
    
    public function HasDaggerOfAssassination(unit u) -> boolean {
        if (!ht.exists(u)) {
            return false;
        } else {
            return ht[u] > 0;
        }
    }

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        up.ModAgi(10 * fac);
        up.ModAP(20 * fac);
        up.ModAttackSpeed(15 * fac);
        if (!ht.exists(u)) {ht[u] = 0;}
        ht[u] = ht[u] + fac;
    }
    
    function ondamaging() {
        if (DamageResult.isHit) {
            if (ht.exists(DamageResult.source)) {
                if (ht[DamageResult.source] > 0) {
                    if (GetWidgetLife(DamageResult.source) > GetWidgetLife(DamageResult.target)) {
                        DamageResult.amount += GetUnitState(DamageResult.target, UNIT_STATE_MAX_LIFE);
                    }
                }
            }
        }
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterItemPropMod(ITIDDAGGEROFASSASSINATION, action);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_NEG);
        RegisterOnDamageEvent(ondamaging);
    }
#undef BUFF_ID
}
//! endzinc
