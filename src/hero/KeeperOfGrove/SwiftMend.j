//! zinc
library SwiftMend requires KeeperOfGroveGlobal, SpellEvent, DamageSystem {
#define ART_TARGET "Objects\\Spawnmodels\\NightElf\\EntBirthTarget\\EntBirthTarget.mdl"
#define ART_TARGET1 "Abilities\\Spells\\Undead\\ReplenishHealth\\ReplenishHealthCasterOverhead.mdl"
#define BUFF_ID 'A02N'
#define ART_ATTACH "Abilities\\Spells\\Items\\ClarityPotion\\ClarityTarget.mdl"

	function returnArmor(integer lvl) -> integer {
		return 5 * lvl - 5;
	}

    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].ModArmor(buf.bd.i0);
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].ModArmor(0 - buf.bd.i0);
    }

    function onCast() {
        BuffSlot bs = BuffSlot[SpellEvent.TargetUnit];
        Buff buf = bs.getBuffByBid(BID_REGROWTH);
        integer ilvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDSWIFTMEND);
        if (buf != 0) {
            AddTimedEffect.atUnit(ART_TARGET, SpellEvent.TargetUnit, "origin", 0.3);
            AddTimedEffect.atUnit(ART_TARGET1, SpellEvent.TargetUnit, "overhead", 0.3);
            HealTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, buf.bd.r0 * 5, SpellData[SIDSWIFTMEND].name, 0.0);
        } else {
            buf = bs.getBuffByBid(BID_REJUVENATION);
            if (buf != 0) {
            AddTimedEffect.atUnit(ART_TARGET, SpellEvent.TargetUnit, "origin", 0.3);
            AddTimedEffect.atUnit(ART_TARGET1, SpellEvent.TargetUnit, "overhead", 0.3);
                HealTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, buf.bd.r0 * buf.bd.i1, SpellData[SIDSWIFTMEND].name, 0.0);
            }
        }
        if (buf != 0 && ilvl < 3) {
            bs.dispelByBuff(buf);
            buf.destroy();
        }
        if (ilvl > 1) {
            buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BUFF_ID);
            buf.bd.tick = -1;
            buf.bd.interval = 10.0;
            UnitProp[SpellEvent.TargetUnit].ModArmor(0 - buf.bd.i0);
            buf.bd.i0 = returnArmor(ilvl);
            if (buf.bd.e0 == 0) {
                buf.bd.e0 = BuffEffect.create(ART_ATTACH, buf, "origin");
            }
            buf.bd.boe = onEffect;
            buf.bd.bor = onRemove;
            buf.run();
        }
    }

    function onInit() {
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
        RegisterSpellEffectResponse(SIDSWIFTMEND, onCast);
    }
   
#undef ART_ATTACH
#undef BUFF_ID
#undef ART_TARGET1
#undef ART_TARGET
}
//! endzinc
