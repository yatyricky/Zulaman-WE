//! zinc
library Sting requires SpellEvent, DamageSystem, BuffSystem {
#define BUFF_ID 'A09Z'

    function onEffect(Buff buf) {
        DamageTarget(buf.bd.caster, buf.bd.target, buf.bd.r0, SpellData[SID_STING].name, false, false, false, WEAPON_TYPE_WHOKNOWS);
        AddTimedEffect.atUnit(ART_POISON, buf.bd.target, "origin", 0.0);
    }

    function onRemove(Buff buf) {}

    function response() {
        Buff buf;
        if (GetUnitAbilityLevel(DamageResult.source, SID_STING) > 0) {
            if (DamageResult.isHit && DamageResult.abilityName == DAMAGE_NAME_MELEE) {
                AddTimedEffect.atUnit(ART_POISON, DamageResult.target, "origin", 0.0);
                buf = Buff.cast(DamageResult.source, DamageResult.target, BUFF_ID);
                buf.bd.tick = 8;
                buf.bd.interval = 2;
                buf.bd.r0 = 50.0;
                buf.bd.boe = onEffect;
                buf.bd.bor = onRemove;
                buf.run();
            }
        }
    }

    function onInit() {
        RegisterDamagedEvent(response);
        BuffType.register(BUFF_ID, BUFF_PHYX, BUFF_NEG);
    }
#undef BUFF_ID
}
//! endzinc
