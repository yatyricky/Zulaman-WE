//! zinc
library AlkalineWater requires CastingBar, UnitProperty, PlayerUnitList, DamageSystem, TideBaronGlobal {
    function onEffect(Buff buf) {}
    function onRemove(Buff buf) {}

    function response(CastingBar cd) {
        integer i = 0;
        Buff buf;
        while (i < PlayerUnits.n) {
            if (GetDistance.units2d(PlayerUnits.units[i], cd.target) < DBMTideBaron.alkalineWaterAOE && !IsUnitDead(PlayerUnits.units[i])) {
                DamageTarget(cd.caster, PlayerUnits.units[i], 380.0 + GetRandomReal(0.0, 40.0), SpellData[SIDALKALINEWATER].name, false, false, false, WEAPON_TYPE_WHOKNOWS);
                
                buf = Buff.cast(cd.caster, PlayerUnits.units[i], BUFF_ID_ALKALINE_WATER);
                buf.bd.tick = -1;
                buf.bd.interval = 60.0;
                buf.bd.boe = onEffect;
                buf.bd.bor = onRemove;
                buf.run();
            }
            i += 1;
        }
        
        AddTimedEffect.atUnit(ART_WATER, cd.target, "origin", 0.3);
    }
    
    function onChannel() {
        CastingBar.create(response).launch();
    }

    function onInit() {
        RegisterSpellChannelResponse(SIDALKALINEWATER, onChannel);
        BuffType.register(BUFF_ID_ALKALINE_WATER, BUFF_PHYX, BUFF_NEG);
    }
}
//! endzinc
