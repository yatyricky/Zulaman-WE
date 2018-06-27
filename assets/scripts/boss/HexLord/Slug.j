//! zinc
library Slug requires DamageSystem {

    function onEffect(Buff buf) {
        ListObject list = ListObject(buf.bd.i0);
        NodeObject iter;
        HandleTable damaged = HandleTable.create();
        effect eff = AddSpecialEffect(ART_PLAGUE, GetUnitX(buf.bd.target), GetUnitY(buf.bd.target));
        integer i;
        list.push(Eff2Int(eff));
        iter = list.head;
        while (iter != 0) {
            eff = IntRefEff(iter.data);
            i = 0;
            while (i < PlayerUnits.n) {
                if (GetDistance.unitCoord2d(PlayerUnits.units[i], BlzGetLocalSpecialEffectX(eff), BlzGetLocalSpecialEffectY(eff)) < 100.0 && damaged.exists(PlayerUnits.units[i]) == false) {
                    DamageTarget(buf.bd.target, PlayerUnits.units[i], 200.0, SpellData.inst(SID_SLUG, SCOPE_PREFIX).name, false, false, false, WEAPON_TYPE_WHOKNOWS, false);
                    damaged[PlayerUnits.units[i]] = 1;
                }
                i += 1;
            }
            iter = iter.next;
        }
        damaged.destroy();
        eff = null;
    }

    function onRemove(Buff buf) {
        ListObject list = ListObject(buf.bd.i0);
        NodeObject iter = list.head;
        effect eff;
        while (iter != 0) {
            eff = Int2Eff(iter.data);
            DestroyEffect(eff);
            iter = iter.next;
        }
        list.destroy();
        eff = null;
    }

    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BID_Slug);
        buf.bd.tick = 600;
        buf.bd.interval = 1;
        buf.bd.i0 = ListObject.create();
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_SLUG, onCast);
        BuffType.register(BID_Slug, BUFF_PHYX, BUFF_POS);
    }

}
//! endzinc
