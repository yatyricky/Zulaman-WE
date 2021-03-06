//! zinc
library AlkalineWater requires CastingBar, UnitProperty, PlayerUnitList, DamageSystem, TideBaronGlobal {

    function response(CastingBar cd) {
        integer i = 0;
        Buff buf;
        while (i < PlayerUnits.n) {
            if (GetDistance.units2d(PlayerUnits.units[i], cd.target) < DBMTideBaron.alkalineWaterAOE && !IsUnitDead(PlayerUnits.units[i])) {
                DamageTarget(cd.caster, PlayerUnits.units[i], 480.0 + GetRandomReal(0.0, 40.0), SpellData.inst(SID_ALKALINE_WATER, SCOPE_PREFIX).name, false, false, false, WEAPON_TYPE_WHOKNOWS, false);
                
                buf = Buff.cast(cd.caster, PlayerUnits.units[i], BUFF_ID_ALKALINE_WATER);
                buf.bd.tick = -1;
                buf.bd.interval = 60.0;
                buf.bd.boe = Buff.noEffect;
                buf.bd.bor = Buff.noEffect;
                buf.run();
            }
            i += 1;
        }
        
        AddTimedEffect.atUnit(ART_WATER, cd.target, "origin", 0.3);
    }
    
    function onChannel() {
        CastingBar.create(response).setVisuals(ART_SeaElementalMissile).launch();
        AddTimedEffect.followUnit(ART_CIRCLE, SpellEvent.TargetUnit, 3).setColor(255, 0, 0).setScale(4);
    }

    function onInit() {
        RegisterSpellChannelResponse(SID_ALKALINE_WATER, onChannel);
        BuffType.register(BUFF_ID_ALKALINE_WATER, BUFF_PHYX, BUFF_NEG);
    }
}
//! endzinc
