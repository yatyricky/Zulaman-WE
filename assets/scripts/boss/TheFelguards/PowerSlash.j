//! zinc
library PowerSlash requires DamageSystem {

    function onCast() {
        integer i = 0;
        ListObject list = ListObject.create();
        real amt;
        NodeObject iter;
        unit tu;
        while (i < PlayerUnits.n) {
            if (GetDistance.units(SpellEvent.TargetUnit, PlayerUnits.units[i]) <= 100.0) {
                list.push(Unit2Int(PlayerUnits.units[i]));
            }
            i += 1;
        }
        amt = 1.5 / list.count();
        iter = list.head;
        while (iter != 0) {
            tu = Int2Unit(iter.data);
            DamageTarget(SpellEvent.CastingUnit, tu, GetUnitState(tu, UNIT_STATE_MAX_LIFE) * amt, SpellData.inst(SID_POWER_SLASH, SCOPE_PREFIX).name, true, false, false, WEAPON_TYPE_WHOKNOWS, true);
            AddTimedEffect.atUnit(ART_BLEED, tu, "origin", 0.1);
            iter = iter.next;
        }
        AddTimedEffect.atCoord(ART_STOMP, GetUnitX(SpellEvent.CastingUnit), GetUnitY(SpellEvent.CastingUnit), 0.1);
        tu = null;
        list.destroy();
    }

    function onInit() {
       RegisterSpellEffectResponse(SID_POWER_SLASH, onCast);
    }
}
//! endzinc
