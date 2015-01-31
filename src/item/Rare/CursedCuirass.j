//! zinc
library CursedCuirass requires ItemAttributes {
#define BUFF_ID 'A06M'
#define ART_TARGET "Abilities\\Spells\\Undead\\OrbOfDeath\\AnnihilationMissile.mdl"
    HandleTable ht;
    
    function onEffect(Buff buf) {}

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].ModAP(30);
    }
    
    function damaged() {
        Buff buf;
        if (DamageResult.isHit) {
            if (ht.exists(DamageResult.target)) {
                if (ht[DamageResult.target] > 0 && DamageResult.abilityName == DAMAGE_NAME_MELEE) {
                    buf = Buff.cast(DamageResult.target, DamageResult.source, BUFF_ID);
                    buf.bd.tick = -1;
                    buf.bd.interval = 5;
                    if (buf.bd.i0 == 0) {
                        buf.bd.i0 = 17;
                        UnitProp[buf.bd.target].ModAP(-30);
                        AddTimedEffect.atUnit(ART_TARGET, buf.bd.target, "origin", 0.0);
                    }
                    buf.bd.boe = onEffect;
                    buf.bd.bor = onRemove;
                    buf.run();
                }
            }
        }
    }

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        up.ModArmor(4 * fac);
        up.ModStr(15 * fac);
        up.blockPoint += 35 * fac;
        up.lifeRegen -= 5 * fac;
        
        if (!ht.exists(u)) {ht[u] = 0;}
        ht[u] = ht[u] + fac;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterItemPropMod(ITID_CURSED_CUIRASS, action);
        RegisterDamagedEvent(damaged);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_NEG);
    }
#undef ART_TARGET
#undef BUFF_ID
}
//! endzinc
