//! zinc
library LionHorn requires ItemAttributes {
#define BUFF_ID 'A07D'
#define ART_TARGET "Abilities\\Spells\\Other\\Tornado\\Tornado_Target.mdl"
    HandleTable ht;

    function oneffect(Buff buf) {
        UnitProp[buf.bd.target].ModAttackSpeed(buf.bd.i0);
    }

    function onremove(Buff buf) {
        UnitProp[buf.bd.target].ModAttackSpeed(0 - buf.bd.i0);
    }
    
    function damaged() {
        Buff buf;
        location loc;
        real x, y, z;
        if (DamageResult.isHit) {
            if (ht.exists(DamageResult.source)) {
                if (ht[DamageResult.source] > 0 && DamageResult.abilityName == DAMAGE_NAME_MELEE) {
                    if (GetRandomInt(0, 99) < 10 && !IsUnitICD(DamageResult.source, BUFF_ID)) {
                        buf = Buff.cast(DamageResult.source, DamageResult.source, BUFF_ID);
                        buf.bd.tick = -1;
                        buf.bd.interval = 5.0;
                        UnitProp[buf.bd.target].ModAttackSpeed(0 - buf.bd.i0);
                        buf.bd.i0 = 30;
                        if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_TARGET, buf, "weapon");}
                        buf.bd.boe = oneffect;
                        buf.bd.bor = onremove;
                        buf.run();
                        
                        SetUnitICD(DamageResult.source, BUFF_ID, 15);
                        
                        x = GetUnitX(DamageResult.source);
                        y = GetUnitY(DamageResult.source);
                        loc = Location(x, y);
                        z = GetLocationZ(loc);
                        AddTimedLight.atCoords3D("CLPB", x, y, z + 4000.0, x, y, z, 0.75);
                        AddTimedEffect.atUnit(ART_IMPACT, DamageResult.source, "origin", 0.2);
                        RemoveLocation(loc);
                        loc = null;
                    }
                }
            }
        }
    }

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        up.ModAP(25 * fac);
        up.damageDealt += 0.03 * fac;
        if (!ht.exists(u)) {ht[u] = 0;}
        ht[u] = ht[u] + fac;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterItemPropMod(ITID_LION_HORN, action);
        RegisterDamagedEvent(damaged);
        BuffType.register(BUFF_ID, BUFF_PHYX, BUFF_POS);
    }
#undef ART_TARGET
#undef BUFF_ID
}
//! endzinc
