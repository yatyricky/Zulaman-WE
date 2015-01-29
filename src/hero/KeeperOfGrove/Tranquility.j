//! zinc
library Tranquility requires CastingBar, KeeperOfGroveGlobal, ZAMCore {
#define ART "Abilities\\Spells\\NightElf\\Tranquility\\Tranquility.mdl"
#define BUFF_ID 'A04K'

    function returnHeal(integer lvl, real sp) -> real {
        return 100 + lvl * 100 + sp * 2.0;
    }
    
    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].aggroRate -= buf.bd.r0;
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].aggroRate += buf.bd.r0;
    }

    function response(CastingBar cd) {
        integer i = 0;
        real amt = returnHeal(GetUnitAbilityLevel(cd.caster, SIDTRANQUILITY), UnitProp[cd.caster].SpellPower());
        while (i < PlayerUnits.n) {
            if (GetDistance.unitCoord2d(PlayerUnits.units[i], GetUnitX(cd.caster), GetUnitY(cd.caster)) < 1200.0 && !IsUnitDead(PlayerUnits.units[i])) {
                HealTarget(cd.caster, PlayerUnits.units[i], amt, SpellData[SIDTRANQUILITY].name, 0.0);
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
        cb.cost = 150 + GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDTRANQUILITY) * 50;
        cb.channel(Rounding(8.0 * (1.0 + UnitProp[SpellEvent.CastingUnit].SpellHaste())));
        
        AddTimedEffect.atCoord(ART, GetUnitX(SpellEvent.CastingUnit), GetUnitY(SpellEvent.CastingUnit), 4.75);
        
        buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BUFF_ID);
        buf.bd.tick = -1;
        buf.bd.interval = 8.0;
        UnitProp[SpellEvent.TargetUnit].aggroRate += buf.bd.r0;
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
            SetPlayerAbilityAvailable(GetOwningPlayer(this.sor), SIDTRANQUILITY1, false);
            SetPlayerAbilityAvailable(GetOwningPlayer(this.sor), SIDTRANQUILITY, true);
            
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
        SetPlayerAbilityAvailable(GetOwningPlayer(SpellEvent.CastingUnit), SIDTRANQUILITY, false);
        SetPlayerAbilityAvailable(GetOwningPlayer(SpellEvent.CastingUnit), SIDTRANQUILITY1, true);
        IssueImmediateOrderById(SpellEvent.CastingUnit, SpellData[SIDTRANQUILITY1].oid);
        delayedDosth1.start(SpellEvent.CastingUnit);
    }
    
    function registered(unit u) {
        if (GetUnitTypeId(u) == UTIDKEEPEROFGROVE) {
            SetPlayerAbilityAvailable(GetOwningPlayer(u), SIDTRANQUILITY1, false);
        }
    }
    
    function lvlup() -> boolean {
        if (GetLearnedSkill() == SIDTRANQUILITY) {
            SetUnitAbilityLevel(GetTriggerUnit(), SIDTRANQUILITY1, GetUnitAbilityLevel(GetTriggerUnit(), SIDTRANQUILITY));
        }
        return false;
    }

    function onInit() {
        RegisterSpellChannelResponse(SIDTRANQUILITY, onChannel);
        RegisterSpellEndCastResponse(SIDTRANQUILITY, onEndCast);
        BuffType.register(BUFF_ID, BUFF_PHYX, BUFF_POS);
        RegisterUnitEnterMap(registered);
        TriggerAnyUnit(EVENT_PLAYER_HERO_SKILL, function lvlup);
    }
#undef BUFF_ID
#undef ART
}
//! endzinc
