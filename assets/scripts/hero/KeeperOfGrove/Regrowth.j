//! zinc
library Regrowth requires CastingBar, KeeperOfGroveGlobal {

    function returnDH(integer lvl, real sp) -> real {
        return 100.0 + 100.0 * lvl + sp * 1.2;
    }

    function returnHOT(integer lvl, real sp) -> real {
        return 40.0 * lvl + sp * 2.0;
    }

    function onEffect1(Buff buf) {}
    function onRemove1(Buff buf) {}

    function onEffect(Buff buf) {
        HealTarget(buf.bd.caster, buf.bd.target, buf.bd.r0, SpellData.inst(SID_REGROWTH, SCOPE_PREFIX).name, 0.0, false);
        AddTimedEffect.atUnit(ART_HEAL, buf.bd.target, "origin", 0.3);
    }

    function onRemove(Buff buf) {
    }

    function response(CastingBar cd) {
        Buff buf = Buff.cast(cd.caster, cd.target, BID_REGROWTH);
        integer lvl = GetUnitAbilityLevel(cd.caster, SID_REGROWTH);
        real sp = UnitProp.inst(cd.caster, SCOPE_PREFIX).SpellPower();
        buf.bd.interval = 5.0 / (1.0 + UnitProp.inst(cd.caster, SCOPE_PREFIX).SpellHaste());
        buf.bd.tick = Rounding(25.0 / buf.bd.interval);
        buf.bd.r0 = returnHOT(lvl, sp);
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        
        AddTimedEffect.atUnit(ART_ENT_BIRTH_TARGET, cd.target, "origin", 0.3);
        HealTarget(cd.caster, cd.target, returnDH(lvl, sp), SpellData.inst(SID_REGROWTH, SCOPE_PREFIX).name, 0.0, true);
    }
    
    function onChannel() {
        CastingBar cb = CastingBar.create(response).setVisuals(ART_KEEPER_GROVE_MISSILE).setSound(castSound);
        Buff buf;
        real icd;
        if (GetWidgetLife(SpellEvent.TargetUnit) / GetUnitState(SpellEvent.TargetUnit, UNIT_STATE_MAX_LIFE) < 0.35) {
            buf = BuffSlot[SpellEvent.CastingUnit].getBuffByBid(BID_REGROWTH_NO_INSTANT);
            if (buf == 0) {
                cb.haste = 5.0;
                icd = 50 - GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_REGROWTH) * 10 - ItemExAttributes.getUnitAttrVal(SpellEvent.CastingUnit, IATTR_KG_REGRCD, SCOPE_PREFIX);
                if (icd > 0) {
                    buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BID_REGROWTH_NO_INSTANT);
                    buf.bd.interval = icd;
                    buf.bd.tick = -1;
                    buf.bd.boe = onEffect1;
                    buf.bd.bor = onRemove1;
                    buf.run();
                }
            }
        }
        cb.launch();
    }
    
    function lvlup() -> boolean {
        if (GetLearnedSkill() == SID_REGROWTH) {
            if (GetUnitAbilityLevel(GetTriggerUnit(), SID_REGROWTH) == 2) {
                lbtick[GetPlayerId(GetOwningPlayer(GetTriggerUnit()))] = 10;
            }
            if (GetUnitAbilityLevel(GetTriggerUnit(), SID_REGROWTH) == 3) {
                rejuvtick[GetPlayerId(GetOwningPlayer(GetTriggerUnit()))] = 6;
            }
        }
        return false;
    }
    
    integer castSound;

    function onInit() {
        castSound = DefineSound("Sound\\NAtureMissileLoop.mp3", 3639, true, false);
        RegisterSpellChannelResponse(SID_REGROWTH, onChannel);
        BuffType.register(BID_REGROWTH, BUFF_MAGE, BUFF_POS);
        BuffType.register(BID_REGROWTH_NO_INSTANT, BUFF_PHYX, BUFF_NEG);
        TriggerAnyUnit(EVENT_PLAYER_HERO_SKILL, function lvlup);
    }


}
//! endzinc
