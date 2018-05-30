//! zinc
library FrostNova requires SpellEvent, StunUtils, UnitProperty, DamageSystem, FrostMageGlobal {

    public function FrostMageGetFrostNovaAOE(integer lvl) -> real {
        return 200.0 + 100 * lvl;
    }

    function oneffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).spellTaken += buf.bd.r0;
    }

    function onremove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).spellTaken -= buf.bd.r0;
    }

    function onCast() {
        integer lvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_FROST_NOVA);
        unit tu;
        real dmg = (25 + 25 * lvl + UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).SpellPower() * 1.5) * returnFrostDamage(SpellEvent.CastingUnit);
        Buff buf;
        GroupUnitsInArea(ENUM_GROUP, GetUnitX(SpellEvent.CastingUnit), GetUnitY(SpellEvent.CastingUnit), FrostMageGetFrostNovaAOE(lvl));
        tu = FirstOfGroup(ENUM_GROUP);
        while (tu != null) {
            GroupRemoveUnit(ENUM_GROUP, tu);
            if (!IsUnitDummy(tu) && !IsUnitDead(tu) && IsUnitEnemy(tu, GetOwningPlayer(SpellEvent.CastingUnit))) {
                // damage
                DamageTarget(SpellEvent.CastingUnit, tu, dmg, SpellData.inst(SID_FROST_NOVA, SCOPE_PREFIX).name, false, true, false, WEAPON_TYPE_WHOKNOWS, true);
                // stun
                StunUnit(SpellEvent.CastingUnit, tu, 3 + lvl);
                AddTimedEffect.atUnit(ART_FREEZING_BREATH, tu, "origin", 3 + lvl);
                // spell taken amp
                buf = Buff.cast(SpellEvent.CastingUnit, tu, BID_FROST_NOVA);
                buf.bd.tick = -1;
                buf.bd.interval = 12.0;
                UnitProp.inst(buf.bd.target, SCOPE_PREFIX).spellTaken -= buf.bd.r0;
                buf.bd.r0 = 0.03 * lvl;
                buf.bd.boe = oneffect;
                buf.bd.bor = onremove;
                buf.run();
            }
            tu = FirstOfGroup(ENUM_GROUP);
        }
        tu = null;
        VisualEffects.nova(ART_BREATH_OF_FROST_MISSILE, GetUnitX(SpellEvent.CastingUnit), GetUnitY(SpellEvent.CastingUnit), FrostMageGetFrostNovaAOE(lvl), 800.0, 18);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_FROST_NOVA, onCast);
        BuffType.register(BID_FROST_NOVA, BUFF_MAGE, BUFF_NEG);
    }

}
//! endzinc
