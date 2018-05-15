//! zinc
library ShieldOfSindorei requires SpellEvent, BuffSystem {

    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageTaken -= buf.bd.r0;
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageTaken += buf.bd.r0;
    }
    
    function onCast() {
        integer i;
        AggroList al;
        real aggro;
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BID_SHIELD_OF_SINDOREI);
        buf.bd.tick = -1;
        buf.bd.interval = 8.0;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageTaken += buf.bd.r0;
        buf.bd.r0 = 0.05 + 0.15 * GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_SHIELD_OF_SINDOREI) + ItemExAttributes.getUnitAttrVal(SpellEvent.CastingUnit, IATTR_BD_SHIELD, SCOPE_PREFIX);
        
        // equiped orb of the sindorei
        if (UnitHasItemType(SpellEvent.CastingUnit, ITID_ORB_OF_THE_SINDOREI) == true) {
            i = 0;
            while (i < MobList.n) {
                if (GetDistance.units2d(MobList.units[i], SpellEvent.CastingUnit) <= 900.0) {
                    al = AggroList[MobList.units[i]];
                    aggro = al.getAggro(al.sort());
                    al.setAggro(SpellEvent.CastingUnit, aggro * 1.1 + 100.0);
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
        RegisterSpellEffectResponse(SID_SHIELD_OF_SINDOREI, onCast);
        BuffType.register(BID_SHIELD_OF_SINDOREI, BUFF_MAGE, BUFF_POS);
    }

}
//! endzinc
