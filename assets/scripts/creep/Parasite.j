//! zinc
library Parasite requires BuffSystem, DamageSystem {

    function onEffect(Buff buf) {
        DamageTarget(buf.bd.caster, buf.bd.target, GetUnitState(buf.bd.target, UNIT_STATE_MAX_LIFE) * 0.2, SpellData[SID_PARASITE].name, false, false, false, WEAPON_TYPE_WHOKNOWS);
        AddTimedEffect.atUnit(ART_BLEED, buf.bd.target, "origin", 1.0);
    }

    function onRemove(Buff buf) {
        CreateUnit(Player(MOB_PID), UTID_PARASITICAL_ROACH, GetUnitX(buf.bd.target), GetUnitY(buf.bd.target), GetRandomReal(0, 359));
        CreateUnit(Player(MOB_PID), UTID_PARASITICAL_ROACH, GetUnitX(buf.bd.target), GetUnitY(buf.bd.target), GetRandomReal(0, 359));
    }

    public function ParasiteOnTarget(unit caster, unit target) {
        Buff buf = Buff.cast(caster, target, BID_PARASITE);
        buf.bd.interval = 1;
        buf.bd.tick = 5;
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        if (buf.bd.e0 == 0) {
            buf.bd.e0 = BuffEffect.create(ART_PARASITE_TARGET, buf, "overhead");
        }
        buf.run();
        
        KillUnit(caster);
        AddTimedEffect.atUnit(ART_BLEED, buf.bd.target, "origin", 1.0);
    }

    function onInit() {
        BuffType.register(BID_PARASITE, BUFF_PHYX, BUFF_NEG);
    }
}
//! endzinc
