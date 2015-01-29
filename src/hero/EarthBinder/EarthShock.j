//! zinc
library EarthShock requires DamageSystem, SpellData, BuffSystem, EarthBinderGlobal, MultipleAbility {
#define ART "Abilities\\Spells\\Orc\\Disenchant\\DisenchantSpecialArt.mdl"

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
        real dmg = returnDamage(GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDEARTHSHOCK), UnitProp[SpellEvent.CastingUnit].SpellPower());
        //Buff buf;
        AddTimedEffect.atUnit(ART, SpellEvent.TargetUnit, "origin", 0.2);
        //buf = BuffSlot[SpellEvent.TargetUnit].getBuffByBid(BUFF_ID_STORM_STRIKE);
        //if (buf != 0) {
        //    //BJDebugMsg("Amp!");
        //    dmg *= buf.bd.r0;
        //}
        
        //print("Free earth shock used!");
        freeESAvailability.flush(SpellEvent.CastingUnit);
        
        DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, dmg, SpellData[SIDEARTHSHOCK].name, false, true, false, WEAPON_TYPE_WHOKNOWS);
        CounterSpell(SpellEvent.TargetUnit);
        if (SpellEvent.AbilityId == SIDEARTHSHOCK1) {
            RecoverOriginalEarthShock.start(SpellEvent.CastingUnit, 9.0);
            //SystemOrderIndicator = true;
            delayedDosth1.start(SpellEvent.CastingUnit);
            //SystemOrderIndicator = false;
        }
        if (GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDENCHANTEDTOTEM) > 0) {
            p = GetOwningPlayer(SpellEvent.CastingUnit);
            SetPlayerAbilityAvailable(p, SIDTORRENTTOTEM, false);
            SetPlayerAbilityAvailable(p, SIDLIGHTNINGTOTEM, false);
            SetPlayerAbilityAvailable(p, SIDEARTHBINDTOTEM, true);
            currentTotemId[GetPlayerId(p)] = SIDEARTHBINDTOTEM;
            p = null;
        }
    }
    
    function initMultipleAbil(unit u) {
        if (GetUnitTypeId(u) == 'Hapm') {
            MultipleAbility[SIDEARTHSHOCK].showPrimary(GetOwningPlayer(u));
        }
    }

    function onInit() {
        RegisterSpellEffectResponse(SIDEARTHSHOCK, onCast);
        RegisterSpellEffectResponse(SIDEARTHSHOCK1, onCast);
        MultipleAbility.register(SIDEARTHSHOCK, SIDEARTHSHOCK1);
        RegisterUnitEnterMap(initMultipleAbil);
    }
#undef ART
}
//! endzinc
