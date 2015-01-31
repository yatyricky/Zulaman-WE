//! zinc
library CallToArms requires ItemAttributes, DamageSystem {
#define ART_CASTER "Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl"
#define BUFF_ID 'A068'
    HandleTable ht;
    
    function onEffect(Buff buf) {}

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].ModLife(0 - buf.bd.i1);
    }

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        up.ModAP(20 * fac);
        up.spellPower += 15.0 * fac;
        up.lifeRegen += 12.0 * fac;
	    up.ll += 0.07 * fac;
        if (!ht.exists(u)) {ht[u] = 0;}
        ht[u] = ht[u] + fac;
    }
    
    function onCast() {
        integer i = 0;
        Buff buf;
        integer diff;
        while (i < PlayerUnits.n) {
            if (GetDistance.units2d(PlayerUnits.units[i], SpellEvent.CastingUnit) <= 900.0 && !IsUnitDead(PlayerUnits.units[i])) {
                buf = Buff.cast(SpellEvent.CastingUnit, PlayerUnits.units[i], BUFF_ID);
                buf.bd.tick = -1;
                buf.bd.interval = 20.0;
                if (buf.bd.i0 != 6) {
                    buf.bd.i1 = Rounding(GetUnitState(PlayerUnits.units[i], UNIT_STATE_MAX_LIFE) * 0.12);
                    UnitProp[buf.bd.target].ModLife(buf.bd.i1);
                    buf.bd.i0 = 6;
                } else {
                    diff = Rounding(GetUnitState(PlayerUnits.units[i], UNIT_STATE_MAX_LIFE) * 0.12);
                    UnitProp[buf.bd.target].ModLife(diff);
                    buf.bd.i1 += diff;
                }
                buf.bd.boe = onEffect;
                buf.bd.bor = onRemove;
                buf.run();  
            }
            i += 1;
        }
        AddTimedEffect.atUnit(ART_CASTER, SpellEvent.CastingUnit, "origin", 1.0);
    }
    
    function ondamaging() {
        if (DamageResult.abilityName == DAMAGE_NAME_MELEE) {
            if (ht.exists(DamageResult.source)) {
                if (ht[DamageResult.source] > 0) {
                    DamageResult.amount += 30.0;
                }
            }
        }
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterItemPropMod(ITIDCALLTOARMS, action);
        RegisterSpellEffectResponse(SIDCALLTOARMS, onCast);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
        RegisterOnDamageEvent(ondamaging);
    }
#undef BUFF_ID
#undef ART_CASTER
}
//! endzinc
