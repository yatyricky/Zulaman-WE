//! zinc
library StormLash requires DamageSystem, CastingBar, SpellEvent, RareShimmerWeed {
    integer castSound;

    function returnDamageMultiplier(integer lvl) -> real {
        return 1.0 + 0.1 * lvl;
    }
    
    function returnCDChance(integer lvl) -> real {
        return lvl * 20.0;
    }
    
    struct delayedDosth {
        private timer tm;
        private unit u;
    
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            MultipleAbility[SID_EARTH_SHOCK].showSecondary(GetOwningPlayer(this.u));
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
    
    struct delayedDosth1 {
        private timer tm;
        private unit u;
    
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            IssueImmediateOrderById(this.u, OID_FROSTARMORON);
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
            TimerStart(this.tm, 0.05, false, function thistype.run);
        }
    }

    function response(CastingBar cd) {
        integer lvl = GetUnitAbilityLevel(cd.caster, SID_STORM_LASH);
        real dmg = UnitProp[cd.caster].AttackPower() * returnDamageMultiplier(lvl) + UnitProp[cd.caster].SpellPower() * 0.8;
        real fxdur = cd.cast;
        player p;
        DamageTarget(cd.caster, cd.target, dmg, SpellData[SID_STORM_LASH].name, false, true, false, WEAPON_TYPE_WHOKNOWS);
        AddTimedEffect.atUnit(ART_IMPACT, cd.target, "origin", 0.3);
        if (fxdur > 0.75) {fxdur = 0.75;}
        AddTimedLight.atUnits("CLSB", cd.caster, cd.target, fxdur);
        
        // cool down Earth Shock
        if (GetUnitAbilityLevel(cd.caster, SID_EARTH_SHOCK) > 0) {
            if (GetRandomInt(0, 100) < returnCDChance(lvl) || HasRareShimmerWeed(cd.caster)) {
                CoolDown(cd.caster, SID_EARTH_SHOCK);
                CoolDown(cd.caster, SID_EARTH_SHOCK_1);
                delayedDosth1.start(cd.caster);
                //BJDebugMsg("����CD��??");
                delayedDosth.start(cd.caster);
                RecoverOriginalEarthShock.start(cd.caster, 3.0);
                //BJDebugMsg("6");
                
                //print("Free earth shock now available!");
                freeESAvailability[cd.caster] = 1;
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
        real hst = 2.0 - 2.0 / (1.0 + UnitProp[SpellEvent.CastingUnit].AttackSpeed() / 100.0);
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
