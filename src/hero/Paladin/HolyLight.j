//! zinc
library HolyLight requires CastingBar, MultipleAbility, PaladinGlobal, BeaconOfLight {
#define ART "Abilities\\Spells\\Human\\DivineShield\\DivineShieldTarget.mdl"
#define BUFF_ID1 'A029'

    integer castSound;

	function returnHeal(integer lvl) -> real {
		return 275.0 + 75.0 * lvl;
	}
    
    function returnExholy(integer lvl) -> real {
        return 0.05 * lvl;
    }

    function onEffect(Buff buf) {}
    function onRemove(Buff buf) {}

    function casted(unit a, unit b) {
        Buff buf;
        integer id = GetPlayerId(GetOwningPlayer(a));
        integer ilvl = GetUnitAbilityLevel(a, SIDHOLYLIGHT);
        real amt = returnHeal(ilvl) + UnitProp[a].SpellPower() * 1.05;
        real exct = healCrit[id];
        Buff baf = BuffSlot[b].getBuffByBid(BUFF_ID_HOLY_LIGHT);
        if (baf != 0) {
            exct += baf.bd.r0;
        }
        HealTarget(a, b, amt, SpellData[SIDHOLYLIGHT].name, exct);
        if (healCrit[id] > 0) {
            healCrit[id] = 0.0;
        }
        AddTimedEffect.atUnit(ART_HOLY_LIGHT, b, "origin", 0.2);
        
        buf = Buff.cast(a, b, BUFF_ID_HOLY_LIGHT);
        buf.bd.tick = -1;
        buf.bd.interval = 5.0;
        buf.bd.r0 = returnExholy(ilvl);
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        
        if (ilvl > 2) {
            if (HealResult.effective < HealResult.amount) {
                buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BUFF_ID1);
                buf.bd.tick = -1;
                buf.bd.interval = 4.0;
                buf.bd.isShield = true;
                buf.bd.r0 += HealResult.amount - HealResult.effective;
                if (buf.bd.e0 == 0) {
                    buf.bd.e0 = BuffEffect.create(ART, buf, "origin");
                }
                buf.bd.boe = onEffect;
                buf.bd.bor = onRemove;
                buf.run();
            }
        }
        BeaconOfLight[a].healBeacons(b, HealResult.amount, ART_HOLY_LIGHT);
    }

    function response(CastingBar cd) {
        casted(cd.caster, cd.target);
        
        if (instantHolyBoltTab.exists(cd.caster)) {
            instantHolyBoltTab.flush(cd.caster);
        }
    }
    
    function onCast() {
        casted(SpellEvent.CastingUnit, SpellEvent.TargetUnit);
		MultipleAbility[SIDHOLYLIGHT].showPrimary(GetOwningPlayer(SpellEvent.CastingUnit));
    }
    
    function onChannel() {
        CastingBar cb = CastingBar.create(response).setSound(castSound);
        if (GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDDIVINEFAVOR) == 3) {
            cb.haste = 0.4;
        }
        cb.launch();
    }
    
    function registerentered(unit u) {           
        if (GetUnitTypeId(u) == UTIDPALADIN) {
            MultipleAbility[SIDHOLYLIGHT].showPrimary(GetOwningPlayer(u));
        }                
    }

    function onInit() {
        castSound = DefineSound("Sound\\Ambient\\DoodadEffects\\RunesGlow.wav", 5000, true, false);
        RegisterSpellChannelResponse(SIDHOLYLIGHT, onChannel);
        MultipleAbility.register(SIDHOLYLIGHT, SIDHOLYLIGHT1);
        RegisterSpellEffectResponse(SIDHOLYLIGHT1, onCast);
        BuffType.register(BUFF_ID_HOLY_LIGHT, BUFF_MAGE, BUFF_POS);
        BuffType.register(BUFF_ID1, BUFF_MAGE, BUFF_POS);
        RegisterUnitEnterMap(registerentered);
    }
#undef BUFF_ID1
#undef ART
}
//! endzinc
