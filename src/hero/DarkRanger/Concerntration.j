//! zinc
library Concerntration requires SpellEvent, DamageSystem, StunUtils, DarkRangerGlobal {
#define ART "Abilities\\Weapons\\DragonHawkMissile\\DragonHawkMissile.mdl"
#define BUFF_ID 'A03Z'
#define BUFF_ID1 'A040'

    struct NextStun {
        static HandleTable ht;
        
        static method setOne(unit u) {
            thistype.ht[u] = 1;
        }
        
        static method tryOne(unit u) -> boolean {
            if (!thistype.ht.exists(u)) {
                return false;
            } else {
                if (thistype.ht[u] == 0) {
                    return false;
                } else {
                    thistype.ht[u] = 0;
                    return true;
                }
            }
        }
        
        private static method onInit() {
            thistype.ht = HandleTable.create();
        }
    }

    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].ModArmor(0 - buf.bd.i0);
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].ModArmor(buf.bd.i0);
    }

    function onEffect1(Buff buf) {
        UnitProp[buf.bd.target].ModArmor(0 - buf.bd.i0);
    }

    function onRemove1(Buff buf) {
        UnitProp[buf.bd.target].ModArmor(buf.bd.i0);
    }
    
    function damaged() {
        Buff buf;
        integer lvl;
        if (DamageResult.isHit) {
            if (NextStun.tryOne(DamageResult.source)) {
                if (GetUnitTypeId(DamageResult.source) == UTIDDARKRANGER) {
                    buf = Buff.cast(DamageResult.source, DamageResult.target, BUFF_ID);
                    buf.bd.tick = -1;
                    buf.bd.interval = GetUnitAbilityLevel(DamageResult.source, SIDCONCERNTRATION) * 4;
                    UnitProp[buf.bd.target].ModArmor(buf.bd.i0);
                    buf.bd.i0 = GetUnitAbilityLevel(DamageResult.source, SIDCONCERNTRATION) + 1;
                    buf.bd.boe = onEffect;
                    buf.bd.bor = onRemove;
                    buf.run();
                } else if (GetUnitTypeId(DamageResult.source) == UTIDGHOUL) {
                    buf = Buff.cast(DamageResult.source, DamageResult.target, BUFF_ID1);
                    buf.bd.tick = -1;
                    lvl = GetUnitAbilityLevel(darkranger[GetPlayerId(GetOwningPlayer(DamageResult.source))], SIDCONCERNTRATION);
                    buf.bd.interval = lvl * 4;
                    UnitProp[buf.bd.target].ModArmor(buf.bd.i0);
                    buf.bd.i0 = lvl + 1;
                    buf.bd.boe = onEffect1;
                    buf.bd.bor = onRemove1;
                    buf.run();
                }
                StunUnit(DamageResult.source, DamageResult.target, 1.0);
                DestroyEffect(AddSpecialEffectTarget(ART, DamageResult.target, "origin"));
            }
        }
    }

    function onCast() {
        integer id = GetPlayerId(GetOwningPlayer(SpellEvent.CastingUnit));
        NextStun.setOne(SpellEvent.CastingUnit);
        if (ghoul[id] != null) {
            NextStun.setOne(ghoul[id]);
        }
    }

    function onInit() {
        RegisterSpellEffectResponse(SIDCONCERNTRATION, onCast);
        RegisterDamagedEvent(damaged);
        BuffType.register(BUFF_ID, BUFF_PHYX, BUFF_NEG);
        BuffType.register(BUFF_ID1, BUFF_PHYX, BUFF_NEG);
    }
#undef BUFF_ID1
#undef BUFF_ID
#undef ART
}
//! endzinc
