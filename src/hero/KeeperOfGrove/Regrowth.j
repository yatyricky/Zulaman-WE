//! zinc
library Regrowth requires CastingBar, KeeperOfGroveGlobal, HornOfCenarius {
#define ART "Objects\\Spawnmodels\\NightElf\\EntBirthTarget\\EntBirthTarget.mdl"
#define BUFF_ID 'A04I'

    function returnDH(integer lvl, real sp) -> real {
        return 100.0 + 100.0 * lvl + sp * 1.2;
    }

    function returnHOT(integer lvl, real sp) -> real {
        return 40.0 * lvl + sp * 2.0;
    }

    function onEffect1(Buff buf) {}
    function onRemove1(Buff buf) {}

    function onEffect(Buff buf) {
        HealTarget(buf.bd.caster, buf.bd.target, buf.bd.r0, SpellData[SIDREGROWTH].name, 0.0);
        AddTimedEffect.atUnit(ART_HEAL, buf.bd.target, "origin", 0.3);
    }

    function onRemove(Buff buf) {
    }

    function response(CastingBar cd) {
        Buff buf = Buff.cast(cd.caster, cd.target, BID_REGROWTH);
        integer lvl = GetUnitAbilityLevel(cd.caster, SIDREGROWTH);
        real sp = UnitProp[cd.caster].SpellPower();
        buf.bd.interval = 5.0 / (1.0 + UnitProp[cd.caster].SpellHaste());
        buf.bd.tick = Rounding(25.0 / buf.bd.interval);
        buf.bd.r0 = returnHOT(lvl, sp);
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
		
        AddTimedEffect.atUnit(ART, cd.target, "origin", 0.3);
        HealTarget(cd.caster, cd.target, returnDH(lvl, sp), SpellData[SIDREGROWTH].name, 0.0);
    }
    
    function onChannel() {
        CastingBar cb = CastingBar.create(response).setSound(castSound);
        integer reduction = 0;
		Buff buf;
        
        if (HasHornOfCenarius(SpellEvent.CastingUnit)) {
            reduction = 10;
        }
        
        if (GetWidgetLife(SpellEvent.TargetUnit) / GetUnitState(SpellEvent.TargetUnit, UNIT_STATE_MAX_LIFE) < 0.35) {
			buf = BuffSlot[SpellEvent.CastingUnit].getBuffByBid(BUFF_ID);
			if (buf == 0) {
				cb.haste = 5.0;
				
				buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BUFF_ID);
				buf.bd.interval = 45 - GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDREGROWTH) * 10 - reduction;
				buf.bd.tick = -1;
				buf.bd.boe = onEffect1;
				buf.bd.bor = onRemove1;
				buf.run();
			}
        }
        cb.launch();
    }
    
    function lvlup() -> boolean {
        if (GetLearnedSkill() == SIDREGROWTH) {
            if (GetUnitAbilityLevel(GetTriggerUnit(), SIDREGROWTH) == 2) {
                lbtick[GetPlayerId(GetOwningPlayer(GetTriggerUnit()))] = 10;
            }
            if (GetUnitAbilityLevel(GetTriggerUnit(), SIDREGROWTH) == 3) {
                rejuvtick[GetPlayerId(GetOwningPlayer(GetTriggerUnit()))] = 6;
            }
        }
        return false;
    }
    
    integer castSound;

    function onInit() {
        castSound = DefineSound("Sound\\NAtureMissileLoop.mp3", 3639, true, false);
        RegisterSpellChannelResponse(SIDREGROWTH, onChannel);
        BuffType.register(BID_REGROWTH, BUFF_MAGE, BUFF_POS);
        BuffType.register(BUFF_ID, BUFF_PHYX, BUFF_NEG);
        TriggerAnyUnit(EVENT_PLAYER_HERO_SKILL, function lvlup);
    }
#undef BUFF_ID
#undef ART
}
//! endzinc
