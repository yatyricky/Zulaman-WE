//! zinc
library Concerntration requires SpellEvent, DamageSystem, StunUtils, DarkRangerGlobal {
constant string  ART  = "Abilities\\Weapons\\DragonHawkMissile\\DragonHawkMissile.mdl";
constant integer BUFF_ID = 'A03Z';
constant integer BUFF_ID1 = 'A040';

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
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModArmor(0 - buf.bd.i0);
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModArmor(buf.bd.i0);
    }

    function onEffect1(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModArmor(0 - buf.bd.i0);
    }

    function onRemove1(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModArmor(buf.bd.i0);
    }
    
    function damaged() {
        Buff buf;
        integer lvl;
        if (DamageResult.isHit) {
            if (NextStun.tryOne(DamageResult.source)) {
                if (GetUnitTypeId(DamageResult.source) == UTID_DARK_RANGER) {
                    buf = Buff.cast(DamageResult.source, DamageResult.target, BUFF_ID);
                    buf.bd.tick = -1;
                    buf.bd.interval = GetUnitAbilityLevel(DamageResult.source, SID_CONCERNTRATION) * 4;
                    UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModArmor(buf.bd.i0);
                    buf.bd.i0 = GetUnitAbilityLevel(DamageResult.source, SID_CONCERNTRATION) + 1;
                    buf.bd.boe = onEffect;
                    buf.bd.bor = onRemove;
                    buf.run();
                } else if (GetUnitTypeId(DamageResult.source) == UTID_GHOUL) {
                    buf = Buff.cast(DamageResult.source, DamageResult.target, BUFF_ID1);
                    buf.bd.tick = -1;
                    lvl = GetUnitAbilityLevel(darkranger[GetPlayerId(GetOwningPlayer(DamageResult.source))], SID_CONCERNTRATION);
                    buf.bd.interval = lvl * 4;
                    UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModArmor(buf.bd.i0);
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
        RegisterSpellEffectResponse(SID_CONCERNTRATION, onCast);
        RegisterDamagedEvent(damaged);
        BuffType.register(BUFF_ID, BUFF_PHYX, BUFF_NEG);
        BuffType.register(BUFF_ID1, BUFF_PHYX, BUFF_NEG);
    }



}
//! endzinc
