//! zinc
library Parasite requires BuffSystem, DamageSystem {

    function onEffect(Buff buf) {
        DummyDamageTarget(buf.bd.target, GetUnitState(buf.bd.target, UNIT_STATE_MAX_LIFE) * 0.2, SpellData.inst(SID_PARASITE, SCOPE_PREFIX).name);
        AddTimedEffect.atUnit(ART_BLEED, buf.bd.target, "origin", 1.0);
    }

    function onRemove(Buff buf) {
        unit u;
        u = CreateUnit(Player(MOB_PID), UTID_PARASITICAL_ROACH, GetUnitX(buf.bd.target), GetUnitY(buf.bd.target), GetRandomReal(0, 359));
        UnitAbilityCD.make(u, SID_PARASITE, 30);
        u = CreateUnit(Player(MOB_PID), UTID_PARASITICAL_ROACH, GetUnitX(buf.bd.target), GetUnitY(buf.bd.target), GetRandomReal(0, 359));
        UnitAbilityCD.make(u, SID_PARASITE, 30);
        u = null;
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
