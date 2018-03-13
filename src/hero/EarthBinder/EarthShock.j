//! zinc
library EarthShock requires DamageSystem, SpellData, BuffSystem, EarthBinderGlobal, MultipleAbility {
constant string  ART  = "Abilities\\Spells\\Orc\\Disenchant\\DisenchantSpecialArt.mdl";

    function returnDamage(integer lvl, real sp) -> real {
        return 300 + 100 * lvl + sp * 3.6;
    }
    
    struct delayedDosth1 {
        private timer tm;
        private unit u;
    
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            IssueImmediateOrderById(this.u, OID_FROSTARMOROFF);
            ReleaseTimer(this.tm);
            this.tm = null;
            this.u = null;
            this.deallocate();
        }
    
        static method start(unit u) {
            thistype this = thistype.allocate();
            this.u = u;
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            TimerStart(this.tm, 0.02, false, function thistype.run);
        }
    }
    
    function onCast() {
        player p;
        real dmg = returnDamage(GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_EARTH_SHOCK), UnitProp[SpellEvent.CastingUnit].SpellPower());
        //Buff buf;
        AddTimedEffect.atUnit(ART, SpellEvent.TargetUnit, "origin", 0.2);
        //buf = BuffSlot[SpellEvent.TargetUnit].getBuffByBid(BUFF_ID_STORM_STRIKE);
        //if (buf != 0) {
        //    //BJDebugMsg("Amp!");
        //    dmg *= buf.bd.r0;
        //}
        
        //print("Free earth shock used!");
        freeESAvailability.flush(SpellEvent.CastingUnit);
        
        DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, dmg, SpellData[SID_EARTH_SHOCK].name, false, true, false, WEAPON_TYPE_WHOKNOWS);
        CounterSpell(SpellEvent.TargetUnit);
        if (SpellEvent.AbilityId == SID_EARTH_SHOCK_1) {
            RecoverOriginalEarthShock.start(SpellEvent.CastingUnit, 9.0);
            //SystemOrderIndicator = true;
            delayedDosth1.start(SpellEvent.CastingUnit);
            //SystemOrderIndicator = false;
        }
        if (GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_ENCHANTED_TOTEM) > 0) {
            p = GetOwningPlayer(SpellEvent.CastingUnit);
            SetPlayerAbilityAvailable(p, SID_TORRENT_TOTEM, false);
            SetPlayerAbilityAvailable(p, SID_LIGHTNING_TOTEM, false);
            SetPlayerAbilityAvailable(p, SID_EARTH_BIND_TOTEM, true);
            currentTotemId[GetPlayerId(p)] = SID_EARTH_BIND_TOTEM;
            p = null;
        }
    }
    
    function initMultipleAbil(unit u) {
        if (GetUnitTypeId(u) == 'Hapm') {
            MultipleAbility[SID_EARTH_SHOCK].showPrimary(GetOwningPlayer(u));
        }
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_EARTH_SHOCK, onCast);
        RegisterSpellEffectResponse(SID_EARTH_SHOCK_1, onCast);
        MultipleAbility.register(SID_EARTH_SHOCK, SID_EARTH_SHOCK_1);
        RegisterUnitEnterMap(initMultipleAbil);
    }

}
//! endzinc
