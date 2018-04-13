//! zinc
library HolyLight requires CastingBar, PaladinGlobal, BeaconOfLight {
constant string  ART  = "Abilities\\Spells\\Human\\DivineShield\\DivineShieldTarget.mdl";

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
        integer ilvl = GetUnitAbilityLevel(a, SID_HOLY_LIGHT);
        real amt = returnHeal(ilvl) + UnitProp[a].SpellPower() * 1.05;
        real exct = healCrit[id];
        Buff baf = BuffSlot[b].getBuffByBid(BID_HOLY_LIGHT_AMP);
        if (baf != 0) {
            exct += baf.bd.r0;
        }
        HealTarget(a, b, amt, SpellData[SID_HOLY_LIGHT].name, exct);
        if (healCrit[id] > 0) {
            healCrit[id] = 0.0;
        }
        AddTimedEffect.atUnit(ART_RESURRECT_TARGET, b, "origin", 0.2);
        
        buf = Buff.cast(a, b, BID_HOLY_LIGHT_AMP);
        buf.bd.tick = -1;
        buf.bd.interval = 5.0;
        buf.bd.r0 = returnExholy(ilvl);
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        
        if (ilvl > 2) {
            if (HealResult.effective < HealResult.amount) {
                buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BID_HOLY_LIGHT_SHIELD);
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
        BeaconOfLight[a].healBeacons(b, HealResult.amount, ART_RESURRECT_TARGET);
    }

    function response(CastingBar cd) {
        casted(cd.caster, cd.target);
    }
    
    function onChannel() {
        CastingBar cb = CastingBar.create(response).setSound(castSound);
        BuffSlot bs;
        Buff buf;
        if (GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_DIVINE_FAVOR) == 3) {
            cb.haste = 0.4;
        }
        bs = BuffSlot[SpellEvent.CastingUnit];
        buf = bs.getBuffByBid(BID_HOLY_LIGHT_IMPROVED);
        if (buf != 0) {
            cb.haste = SpellData[SID_HOLY_LIGHT].Cast(GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_HOLY_LIGHT));
            bs.dispelByBuff(buf);
            buf.destroy();
        }
        cb.launch();
    }

    function onEffectImprove(Buff buf) {
        BlzSetAbilityIcon(SID_HOLY_LIGHT, BTNInnerFire);
    }
    function onRemoveImprove(Buff buf) {
        BlzSetAbilityIcon(SID_HOLY_LIGHT, BTNResurrection);
    }

    public function ImproveHolyLight(unit u) {
        Buff buf = Buff.cast(u, u, BID_HOLY_LIGHT_IMPROVED);
        buf.bd.interval = 10;
        buf.bd.tick = -1;
        buf.bd.boe = onEffectImprove;
        buf.bd.bor = onRemoveImprove;
        buf.run();
    }

    function onInit() {
        castSound = DefineSound("Sound\\Ambient\\DoodadEffects\\RunesGlow.wav", 5000, true, false);
        RegisterSpellChannelResponse(SID_HOLY_LIGHT, onChannel);
        BuffType.register(BID_HOLY_LIGHT_AMP, BUFF_MAGE, BUFF_POS);
        BuffType.register(BID_HOLY_LIGHT_SHIELD, BUFF_MAGE, BUFF_POS);
        BuffType.register(BID_HOLY_LIGHT_IMPROVED, BUFF_PHYX, BUFF_POS);
    }

}
//! endzinc
