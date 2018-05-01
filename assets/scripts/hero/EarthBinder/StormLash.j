//! zinc
library StormLash requires DamageSystem, CastingBar, SpellEvent, RareShimmerWeed, EarthShock {
    integer castSound;

    function returnDamageMultiplier(integer lvl) -> real {
        return 1.0 + 0.1 * lvl;
    }
    
    function returnCDChance(integer lvl) -> real {
        return lvl * 20.0;
    }

    function response(CastingBar cd) {
        integer lvl = GetUnitAbilityLevel(cd.caster, SID_STORM_LASH);
        real dmg = UnitProp.inst(cd.caster, SCOPE_PREFIX).AttackPower() * returnDamageMultiplier(lvl) + UnitProp.inst(cd.caster, SCOPE_PREFIX).SpellPower() * 0.8;
        real fxdur = cd.cast;
        player p;

        DamageTarget(cd.caster, cd.target, dmg, SpellData[SID_STORM_LASH].name, false, true, false, WEAPON_TYPE_WHOKNOWS);
        AddTimedEffect.atUnit(ART_IMPACT, cd.target, "origin", 0.3);
        if (fxdur > 0.75) {fxdur = 0.75;}
        AddTimedLight.atUnits("CLSB", cd.caster, cd.target, fxdur);
        
        // cool down Earth Shock
        if (GetUnitAbilityLevel(cd.caster, SID_EARTH_SHOCK) > 0) {
            if (GetRandomInt(0, 100) < returnCDChance(lvl) || HasRareShimmerWeed(cd.caster)) {
                ImproveEarthShock(cd.caster);
            }
        }
        
        // change totem
        if (GetUnitAbilityLevel(cd.caster, SID_ENCHANTED_TOTEM) > 0) {
            p = GetOwningPlayer(cd.caster);
            SetPlayerAbilityAvailable(p, SID_EARTH_BIND_TOTEM, false);
            SetPlayerAbilityAvailable(p, SID_TORRENT_TOTEM, false);
            SetPlayerAbilityAvailable(p, SID_LIGHTNING_TOTEM, true);
            currentTotemId[GetPlayerId(p)] = SID_LIGHTNING_TOTEM;
            p = null;
        }
    }
    
    function onChannel() {
        CastingBar cb = CastingBar.create(response).setSound(castSound);
        real hst = 2.0 - 2.0 / (1.0 + UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).AttackSpeed() / 100.0);
        if (GetUnitTypeId(SpellEvent.CastingUnit) == UTID_EARTH_BINDER) {
            cb.haste = hst;
        } else {
            cb.haste = hst / 2.0 + 1;
        }
        cb.launch();
    }

    function onInit() {
        castSound = DefineSound("Sound\\Ambient\\DoodadEffects\\BlueFireBurstLoop.wav", 4000, true, false);
        RegisterSpellChannelResponse(SID_STORM_LASH, onChannel);
    }
}
//! endzinc
