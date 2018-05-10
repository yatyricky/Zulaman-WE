//! zinc
library WoeStave requires ItemAttributes, DamageSystem {
constant integer BUFF_ID = 'A067';
constant string  ART  = "Abilities\\Spells\\Undead\\Cripple\\CrippleTarget.mdl";
    HandleTable ht;
    
    function onEffect(Buff buf) {}

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModSpeed(100);
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAttackSpeed(30);
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModArmor(3);
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).attackRate += 0.1;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageDealt += 0.04;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).healTaken += 0.35;
    }
    
    function damaged() {
        Buff buf;
        if (DamageResult.isHit) {
            if (ht.exists(DamageResult.source)) {
                if (ht[DamageResult.source] > 0 && DamageResult.abilityName == DAMAGE_NAME_MELEE) {
                    buf = Buff.cast(DamageResult.source, DamageResult.target, BUFF_ID);
                    buf.bd.tick = -1;
                    buf.bd.interval = 5;
                    if (buf.bd.e0 == 0) {
                        buf.bd.e0 = BuffEffect.create(ART, buf, "origin");
                    }
                    if (buf.bd.i0 == 0) {
                        buf.bd.i0 = 17;
                        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModSpeed(-100);
                        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAttackSpeed(-30);
                        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModArmor(-3);
                        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).attackRate -= 0.1;
                        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageDealt -= 0.04;
                        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).healTaken -= 0.35;
                    }
                    buf.bd.boe = onEffect;
                    buf.bd.bor = onRemove;
                    buf.run();
                }
            }
        }
    }

    function action(unit u, item i, integer fac) {
        UnitProp up = UnitProp.inst(u, SCOPE_PREFIX);
        up.ModAP(7 * fac);
        
        if (!ht.exists(u)) {ht[u] = 0;}
        ht[u] = ht[u] + fac;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterItemPropMod(ITID_WOESTAVE, action);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_NEG);
        RegisterDamagedEvent(damaged);
    }


}
//! endzinc
