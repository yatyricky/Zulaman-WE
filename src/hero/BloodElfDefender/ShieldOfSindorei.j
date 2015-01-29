//! zinc
library ShieldOfSindorei requires SpellEvent, BuffSystem, OrbOfTheSindorei {
#define SPELL_ID 'A006'
#define BUFF_ID 'A031'
    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].damageTaken -= buf.bd.r0;
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].damageTaken += buf.bd.r0;
    }
    
    function onCast() {   
        integer i;
        AggroList al;
        real aggro;
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BUFF_ID);
        buf.bd.tick = -1;
        buf.bd.interval = 8.0;
        UnitProp[buf.bd.target].damageTaken += buf.bd.r0;
        buf.bd.r0 = 0.2 + 0.15 * GetUnitAbilityLevel(SpellEvent.CastingUnit, SPELL_ID);
        
        // equiped orb of the sindorei
        if (HasOrbOfTheSindorei(SpellEvent.CastingUnit)) {
            buf.bd.r0 += 0.2;            
            
            i = 0;
            while (i < MobList.n) {
                if (GetDistance.units2d(MobList.units[i], SpellEvent.CastingUnit) <= 900.0) {                    
                    al = AggroList[MobList.units[i]];
                    aggro = al.getAggro(al.sort());
                    al.setAggro(SpellEvent.CastingUnit, aggro + 100.0);
                }
                i += 1;
            }
        }
        
        if (buf.bd.e0 == 0) {
            buf.bd.e0 = BuffEffect.create(ART_INVULNERABLE, buf, "origin");
        }
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }

    function onInit() {
        RegisterSpellEffectResponse(SPELL_ID, onCast);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
    }
#undef BUFF_ID
#undef SPELL_ID
}
//! endzinc
