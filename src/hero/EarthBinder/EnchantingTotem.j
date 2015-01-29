//! zinc
library EnchantingTotem requires EarthBinderGlobal, GroupUtils, UnitProperty, BuffSystem {
#define TOTEM_ID_STORM 'u000'
#define TOTEM_ID_WATER 'u002'
#define TOTEM_ID_EARTH 'u001'
#define BUFF_STORM 'A039'
#define BUFF_EARTH 'A03A'
#define DURATION 20
    
    // torrent totem
    
    function returnRegen(integer lvl) -> real {
        return 3.0 + 3 * lvl;
    }
    
    struct WaterTotem {
        private unit u;
        private unit c;
        private timer tm;
        private integer count;
        private real regen;
        
        private method destroy() {
            ReleaseTimer(this.tm);
            this.c = null;
            this.tm = null;
            this.u = null;
            this.deallocate();
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            integer i;
            Buff buf;
            if (!IsUnitDead(this.u)) {
                i = 0;
                while (i < PlayerUnits.n) {
                    if (GetDistance.units2d(PlayerUnits.units[i], this.u) < 300.0 + 197.0) {
                        ModUnitMana(PlayerUnits.units[i], this.regen);
                    }
                    i += 1;
                }
                this.count -= 1;
            } else {
                this.count = 0;
            }
            if (this.count < 1) {
                if (!IsUnitDead(this.u)) {
                    KillUnit(this.u);
                }
                this.destroy();
            }
        }
    
        static method start(unit caster, unit totem) {
            thistype this = thistype.allocate();
            this.u = totem;
            this.c = caster;
            this.regen = returnRegen(GetUnitAbilityLevel(caster, SIDENCHANTEDTOTEM));
            this.count = DURATION;
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            TimerStart(this.tm, 1, true, function thistype.run);
        }
    }
    
    // earth bind totem
    
    function returnRange(integer lvl) -> real {
        return 450.0 + 150.0 * lvl;
    }
    
    function returnSlow(integer lvl) -> real {
        return 0.35 + 0.15 * lvl;
    }

    function onEffectEarth(Buff buf) { 
        UnitProp[buf.bd.target].ModSpeed(0 - buf.bd.i0);
    }

    function onRemoveEarth(Buff buf) {
        UnitProp[buf.bd.target].ModSpeed(buf.bd.i0);
    }
    
    struct EarthTotem {
        private unit u;
        private unit c;
        private timer tm;
        private integer count;
        private real slow;
        private real aoe;
        
        private method destroy() {
            ReleaseTimer(this.tm);
            this.c = null;
            this.tm = null;
            this.u = null;
            this.deallocate();
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            integer i;
            Buff buf;
            if (!IsUnitDead(this.u)) {
                i = 0;
                while (i < MobList.n) {
                    if (CanUnitAttack(MobList.units[i]) && (GetDistance.units2d(MobList.units[i], this.u) < this.aoe + 197.0)) {
                        buf = Buff.cast(this.c, MobList.units[i], BUFF_EARTH);
                        buf.bd.tick = -1;
                        buf.bd.interval = 2.0;
                        UnitProp[buf.bd.target].ModSpeed(buf.bd.i0);
                        buf.bd.i0 = Rounding(UnitProp[buf.bd.target].Speed() * this.slow);
                        if (buf.bd.e0 == 0) {
                            buf.bd.e0 = BuffEffect.create(ART_SLOW, buf, "origin");
                        }
                        buf.bd.boe = onEffectEarth;
                        buf.bd.bor = onRemoveEarth;
                        buf.run();
                    }
                    i += 1;
                }
                this.count -= 1;
            } else {
                this.count = 0;
            }
            if (this.count < 1) {
                if (!IsUnitDead(this.u)) {
                    KillUnit(this.u);
                }
                this.destroy();
            }
        }
    
        static method start(unit caster, unit totem) {
            thistype this = thistype.allocate();
            integer lvl = GetUnitAbilityLevel(caster, SIDENCHANTEDTOTEM);
            this.u = totem;
            this.c = caster;
            this.aoe = returnRange(lvl);
            this.slow = returnSlow(lvl);
            this.count = DURATION;
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            TimerStart(this.tm, 1, true, function thistype.run);
        }
    }
    
    // storm totem
    
    function returnDamage(integer lvl) -> real {
        return 10.0 * lvl;
    }
    
    function returnSpellTaken(integer lvl) -> real {
        return 0.05 + 0.02 * lvl;
    }
    
    function returnLightAOE(integer lvl) -> real {
        return 600.0;
    }
    
    function returnSpeedBoost(integer lvl) -> real {
        return 1.1 - 0.2 * lvl;
    }

    function onEffectStorm(Buff buf) { 
        UnitProp[buf.bd.target].spellTaken += buf.bd.r0;
    }

    function onRemoveStorm(Buff buf) {
        UnitProp[buf.bd.target].spellTaken -= buf.bd.r0;
    }

    struct StormTotem {
        private unit u;
        private unit c;
        private timer tm;
        private integer count;
        private real intv;
        private integer lvl;
        private real aoe;
        
        private method destroy() {
            ReleaseTimer(this.tm);
            this.c = null;
            this.tm = null;
            this.u = null;
            this.deallocate();
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            real dmg = returnDamage(this.lvl) + UnitProp[this.c].SpellPower() * 0.1;
            unit tu;
            real efx;
            Buff buf;
            //BJDebugMsg("Unit totem level = " + I2S(lvl));
            if (!IsUnitDead(this.u)) {
                tu = MobList.getNearestFromWithin(this.u, this.aoe + 197.0);
                
                if (tu != null) {
                    buf = Buff.cast(this.c, tu, BUFF_STORM);
                    buf.bd.tick = -1;
                    buf.bd.interval = this.intv + 1.0;
                    UnitProp[buf.bd.target].spellTaken -= buf.bd.r0;
                    buf.bd.r0 = returnSpellTaken(this.lvl);
                    buf.bd.boe = onEffectStorm;
                    buf.bd.bor = onRemoveStorm;
                    buf.run();

                    efx = this.intv;
                    if (efx > 0.75) {efx = 0.75;}
                    AddTimedLight.atUnitsZ("AFOD", this.u, 80.0, tu, 0.0, efx);
                    AddTimedEffect.atUnit(ART_RED_IMPACT, tu, "origin", 0.3);
                    DamageTarget(this.c, tu, dmg, SpellData[SIDLIGHTNINGTOTEM].name, false, true, false, WEAPON_TYPE_WHOKNOWS);
                }
                this.count -= 1;
            } else {
                this.count = 0;
            }
            if (this.count < 1) {
                if (!IsUnitDead(this.u)) {
                    KillUnit(this.u);
                }
                this.destroy();
            }
        }
    
        static method start(unit caster, unit totem) {
            thistype this = thistype.allocate();
            this.lvl = GetUnitAbilityLevel(caster, SIDENCHANTEDTOTEM);
            this.u = totem;
            this.c = caster;
            this.aoe = returnLightAOE(lvl);
            this.intv = 2.0 / (1.0 + UnitProp[caster].SpellHaste() + UnitProp[caster].AttackSpeed() / 100.0) * returnSpeedBoost(this.lvl);
            if (GetUnitTypeId(caster) == UTID_EARTH_BINDER_ASC) {
                this.intv *= 0.5;
            }
            this.count = Rounding(DURATION / this.intv);
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            TimerStart(this.tm, this.intv, true, function thistype.run);
        }
    }
    
    // end totem spells
    
    unit totems[NUMBER_OF_MAX_PLAYERS];
    integer castSound;
    
    public function EarthBinderHasLightningTotem(unit u) -> boolean {
        integer pid = GetPidofu(u);
        if (totems[pid] == null) {
            return false;
        } else if (IsUnitDead(totems[pid])) {
            return false;
        } else {
            return (GetUnitTypeId(totems[pid]) == TOTEM_ID_STORM);
        }
    }
    
    function onCastWater() {
        integer pid = GetPlayerId(GetOwningPlayer(SpellEvent.CastingUnit));
        if (totems[pid] != null) {
            if (!IsUnitDead(totems[pid])) {
                KillUnit(totems[pid]);
            }
        }
        RunSoundAtPoint2d(castSound, GetUnitX(SpellEvent.CastingUnit), GetUnitY(SpellEvent.CastingUnit));
        totems[pid] = CreateUnit(Player(pid), TOTEM_ID_WATER, SpellEvent.TargetX, SpellEvent.TargetY, GetRandomReal(0, 359.99));
        WaterTotem.start(SpellEvent.CastingUnit, totems[pid]);
    }
    
    function onCastEarth() {
        integer pid = GetPlayerId(GetOwningPlayer(SpellEvent.CastingUnit));
        if (totems[pid] != null) {
            if (!IsUnitDead(totems[pid])) {
                KillUnit(totems[pid]);
            }
        }
        RunSoundAtPoint2d(castSound, GetUnitX(SpellEvent.CastingUnit), GetUnitY(SpellEvent.CastingUnit));
        totems[pid] = CreateUnit(Player(pid), TOTEM_ID_EARTH, SpellEvent.TargetX, SpellEvent.TargetY, GetRandomReal(0, 359.99));
        EarthTotem.start(SpellEvent.CastingUnit, totems[pid]);
    }
    
    function onCastStorm() {
        integer pid = GetPlayerId(GetOwningPlayer(SpellEvent.CastingUnit));
        if (totems[pid] != null) {
            if (!IsUnitDead(totems[pid])) {
                KillUnit(totems[pid]);
            }
        }
        RunSoundAtPoint2d(castSound, GetUnitX(SpellEvent.CastingUnit), GetUnitY(SpellEvent.CastingUnit));
        totems[pid] = CreateUnit(Player(pid), TOTEM_ID_STORM, SpellEvent.TargetX, SpellEvent.TargetY, GetRandomReal(0, 359.99));
        StormTotem.start(SpellEvent.CastingUnit, totems[pid]);
    }
    
    function disableAll(unit u) {
        player p = GetOwningPlayer(u);
        if (GetUnitTypeId(u) == UTIDEARTHBINDER) {
            SetPlayerAbilityAvailable(p, SIDLIGHTNINGTOTEM, false);
            SetPlayerAbilityAvailable(p, SIDEARTHBINDTOTEM, false);
            SetPlayerAbilityAvailable(p, SIDTORRENTTOTEM, false);
        }
        p = null;
    }

    function level() -> boolean {
        unit u;
        integer i;
        if (GetLearnedSkill() == SIDENCHANTEDTOTEM) {
            u = GetTriggerUnit();
            i = GetUnitAbilityLevel(u, SIDENCHANTEDTOTEM);
            if (i == 1) {
                SetPlayerAbilityAvailable(GetOwningPlayer(u), SIDLIGHTNINGTOTEM, true);
                currentTotemId[GetPidofu(u)] = SIDLIGHTNINGTOTEM;
            } else {
                SetUnitAbilityLevel(u, SIDLIGHTNINGTOTEM, i);
                SetUnitAbilityLevel(u, SIDEARTHBINDTOTEM, i);
                SetUnitAbilityLevel(u, SIDTORRENTTOTEM, i);
            } 
        }
        u = null;
        return false;
    }

    function onInit() {
        integer i;
        castSound = DefineSound("Units\\Orc\\HealingWard\\PlaceAncestralGuardian.wav", 3063, false, false);
        TriggerAnyUnit(EVENT_PLAYER_HERO_SKILL, function level);
        RegisterUnitEnterMap(disableAll);
        RegisterSpellEffectResponse(SIDLIGHTNINGTOTEM, onCastStorm);
        RegisterSpellEffectResponse(SIDTORRENTTOTEM, onCastWater);
        RegisterSpellEffectResponse(SIDEARTHBINDTOTEM, onCastEarth);
        BuffType.register(BUFF_STORM, BUFF_MAGE, BUFF_NEG);
        BuffType.register(BUFF_EARTH, BUFF_MAGE, BUFF_NEG);
        i = 0;
        while (i < NUMBER_OF_MAX_PLAYERS) {
            totems[i] = null;
            i += 1;
        }
    }
#undef DURATION
#undef BUFF_EARTH
#undef BUFF_STORM
#undef TOTEM_ID_EARTH
#undef TOTEM_ID_WATER
#undef TOTEM_ID_STORM
}
//! endzinc
