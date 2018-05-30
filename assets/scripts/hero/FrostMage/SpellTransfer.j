//! zinc
library SpellTransfer requires BuffSystem, SpellEvent, UnitProperty {

    function onCast() {
        Buff buf, tmp;
        integer lvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_SPELL_TRANSFER);
        BuffSlot bl;
        unit t;
        if (!IsUnitEnemy(SpellEvent.TargetUnit, GetOwningPlayer(SpellEvent.CastingUnit))) {
            // cast on ally
            buf = BuffSlot[SpellEvent.TargetUnit].dispel(BUFF_MAGE, BUFF_NEG);
            if (buf != 0) {
                bl = BuffSlot[buf.bd.caster];
                tmp = bl.getBuffByBid(buf.bd.bt.bid);
                if (tmp != 0) {
                    //print("removing duplicated buff");
                    tmp.onRemove();
                    tmp.destroy();
                }
                buf.bd.target = buf.bd.caster;
                buf.bd.caster = SpellEvent.CastingUnit;
                buf.refresh();
                bl.push(buf);
            }
        } else {
            buf = BuffSlot[SpellEvent.TargetUnit].dispel(BUFF_MAGE, BUFF_POS);
            if (buf != 0) {
                //print("positive buff catched");
                bl = BuffSlot[SpellEvent.CastingUnit];
                tmp = bl.getBuffByBid(buf.bd.bt.bid);
                if (tmp != 0) {
                    //print("removing duplicated buff");
                    tmp.onRemove();
                    tmp.destroy();
                }
                buf.bd.caster = SpellEvent.CastingUnit;
                buf.bd.target = SpellEvent.CastingUnit;
                buf.refresh();
                bl.push(buf);
                SetLastStolen(SpellEvent.CastingUnit, buf);
            }
        }
        AddTimedEffect.atUnit(ART_SpellStealMissile, SpellEvent.TargetUnit, "overhead", 0.5);
    }

    function onCast1() {
        BuffSlot bl;
        Buff tmp;
        Buff buf = GetLastStolen(SpellEvent.CastingUnit);
        if (buf != 0) {
            BuffSlot[SpellEvent.CastingUnit].dispelByBuff(buf);
            bl = BuffSlot[SpellEvent.TargetUnit];
            tmp = bl.getBuffByBid(buf.bd.bt.bid);
            if (tmp != 0) {
                //print("removing duplicated buff");
                tmp.onRemove();
                tmp.destroy();
            }
            buf.bd.caster = SpellEvent.CastingUnit;
            buf.bd.target = SpellEvent.TargetUnit;
            buf.refresh();
            bl.push(buf);
            SetLastStolen(SpellEvent.CastingUnit, 0);
        }
        AddTimedEffect.atUnit(ART_SpellStealMissile, SpellEvent.CastingUnit, "overhead", 0.5);
    }

    function level() -> boolean {
        unit u;
        integer lvl;
        if (GetLearnedSkill() == SID_SPELL_TRANSFER) {
            u = GetTriggerUnit();
            lvl = GetUnitAbilityLevel(u, SID_SPELL_TRANSFER);
            if (lvl == 3) {
                UnitAddAbility(u, SID_SPELL_CHANNEL);
            }
        }
        u = null;
        return false;
    }

    function onInit() {
        TriggerAnyUnit(EVENT_PLAYER_HERO_SKILL, function level);
        RegisterSpellEffectResponse(SID_SPELL_TRANSFER, onCast);
        RegisterSpellEffectResponse(SID_SPELL_CHANNEL, onCast1);
    }
}
//! endzinc
