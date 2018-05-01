//! zinc
library BattleCommand requires DamageSystem {
/*
target ally deals 100% more damage
duration 12 seconds
magic positive effect
*/
constant real DURATION = 10.0;
constant string  ART_LEFT  = "Abilities\\Spells\\Orc\\Bloodlust\\BloodlustTarget.mdl";
constant string  ART_RIGHT  = "Abilities\\Spells\\Orc\\Bloodlust\\BloodlustSpecial.mdl";

    function onEffect(Buff buf) { 
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageDealt += buf.bd.r0;
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageDealt -= buf.bd.r0;
    }

    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BID_BATTLE_COMMAND);
        buf.bd.tick = -1;
        buf.bd.interval = DURATION;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageDealt -= buf.bd.r0;
        buf.bd.r0 = 1.0;
        if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_LEFT, buf, "hand,left");}
        if (buf.bd.e1 == 0) {buf.bd.e1 = BuffEffect.create(ART_RIGHT, buf, "hand,right");}
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }

    function onInit() {
        BuffType.register(BID_BATTLE_COMMAND, BUFF_MAGE, BUFF_POS);
        RegisterSpellEffectResponse(SID_BATTLE_COMMAND, onCast);
    }



}
//! endzinc
