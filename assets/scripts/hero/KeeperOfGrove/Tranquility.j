//! zinc
library Tranquility requires CastingBar, KeeperOfGroveGlobal, ZAMCore {
constant string  ART  = "Abilities\\Spells\\NightElf\\Tranquility\\Tranquility.mdl";
constant integer BUFF_ID = 'A04K';

    function returnHeal(integer lvl, real sp) -> real {
        return 100 + lvl * 100 + sp * 2.0;
    }
    
    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).aggroRate -= buf.bd.r0;
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).aggroRate += buf.bd.r0;
    }

    function response(CastingBar cd) {
        integer i = 0;
        real amt = returnHeal(GetUnitAbilityLevel(cd.caster, SID_TRANQUILITY), UnitProp.inst(cd.caster, SCOPE_PREFIX).SpellPower());
        while (i < PlayerUnits.n) {
            if (GetDistance.unitCoord2d(PlayerUnits.units[i], GetUnitX(cd.caster), GetUnitY(cd.caster)) < 1200.0 && !IsUnitDead(PlayerUnits.units[i])) {
                HealTarget(cd.caster, PlayerUnits.units[i], amt, SpellData.inst(SID_TRANQUILITY, SCOPE_PREFIX).name, 0.0);
                ModUnitMana(PlayerUnits.units[i], GetUnitState(PlayerUnits.units[i], UNIT_STATE_MAX_MANA) * 0.0375);
                AddTimedEffect.atUnit(ART_HEAL, PlayerUnits.units[i], "origin", 0.5);
                //AddTimedEffect.atUnit(ART_MANA, PlayerUnits.units[i], "origin", 0.5);
                //AddTimedLight.atUnits("HWSB", cd.caster, PlayerUnits.units[i], 0.25);
            }
            i += 1;
        }
    }
    
    function onChannel() {
        CastingBar cb = CastingBar.create(response);
        Buff buf;
        cb.cost = 150 + GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_TRANQUILITY) * 50;
        cb.channel(Rounding(8.0 * (1.0 + UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).SpellHaste())));
        
        AddTimedEffect.atCoord(ART, GetUnitX(SpellEvent.CastingUnit), GetUnitY(SpellEvent.CastingUnit), 4.75);
        
        buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BUFF_ID);
        buf.bd.tick = -1;
        buf.bd.interval = 8.0;
        UnitProp.inst(SpellEvent.TargetUnit, SCOPE_PREFIX).aggroRate += buf.bd.r0;
        buf.bd.r0 = 1.0;
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }
    
    struct delayedDosth1 {
        private timer tm;
        private unit sor;
    
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            SetPlayerAbilityAvailable(GetOwningPlayer(this.sor), SID_TRANQUILITY_1, false);
            SetPlayerAbilityAvailable(GetOwningPlayer(this.sor), SID_TRANQUILITY, true);
            
            ReleaseTimer(this.tm);
            this.tm = null;
            this.sor = null;
            this.deallocate();
        }
    
        static method start(unit sor) {
            thistype this = thistype.allocate();
            this.sor = sor;
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            TimerStart(this.tm, 40.0, false, function thistype.run);
        }
    }
    
    function onEndCast() {
        SetPlayerAbilityAvailable(GetOwningPlayer(SpellEvent.CastingUnit), SID_TRANQUILITY, false);
        SetPlayerAbilityAvailable(GetOwningPlayer(SpellEvent.CastingUnit), SID_TRANQUILITY_1, true);
        IssueImmediateOrderById(SpellEvent.CastingUnit, SpellData.inst(SID_TRANQUILITY_1, SCOPE_PREFIX).oid);
        delayedDosth1.start(SpellEvent.CastingUnit);
    }
    
    function registered(unit u) {
        if (GetUnitTypeId(u) == UTID_KEEPER_OF_GROVE) {
            SetPlayerAbilityAvailable(GetOwningPlayer(u), SID_TRANQUILITY_1, false);
        }
    }
    
    function lvlup() -> boolean {
        if (GetLearnedSkill() == SID_TRANQUILITY) {
            SetUnitAbilityLevel(GetTriggerUnit(), SID_TRANQUILITY_1, GetUnitAbilityLevel(GetTriggerUnit(), SID_TRANQUILITY));
        }
        return false;
    }

    function onInit() {
        RegisterSpellChannelResponse(SID_TRANQUILITY, onChannel);
        RegisterSpellEndCastResponse(SID_TRANQUILITY, onEndCast);
        BuffType.register(BUFF_ID, BUFF_PHYX, BUFF_POS);
        RegisterUnitEnterMap(registered);
        TriggerAnyUnit(EVENT_PLAYER_HERO_SKILL, function lvlup);
    }


}
//! endzinc
