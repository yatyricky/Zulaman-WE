//! zinc
library HolyLight requires CastingBar, BeaconOfLight {

    integer castSound;

    function returnHeal(integer lvl) -> real {
        return 275.0 + 75.0 * lvl;
    }
    
    function casted(unit a, unit b) {
        Buff buf;
        integer id = GetPlayerId(GetOwningPlayer(a));
        integer ilvl = GetUnitAbilityLevel(a, SID_HOLY_LIGHT);
        real amt = returnHeal(ilvl) + UnitProp.inst(a, SCOPE_PREFIX).SpellPower() * 1.05;
        real exct = 0;
        BuffSlot bs;
        // must crit if divine favor
        bs = BuffSlot[a];
        buf = bs.getBuffByBid(BID_DIVINE_FAVOR_CRIT);
        if (buf != 0) {
            exct += 2.0;
            bs.dispelByBuff(buf);
            buf.destroy();
        }
        // heal
        HealTarget(a, b, amt, SpellData.inst(SID_HOLY_LIGHT, SCOPE_PREFIX).name, exct, true);
        AddTimedEffect.atUnit(ART_RESURRECT_TARGET, b, "origin", 0.2);
        // heal beacons
        BeaconOfLight[a].healBeacons(b, HealResult.amount, ART_RESURRECT_TARGET);
    }

    function response(CastingBar cd) {
        casted(cd.caster, cd.target);
    }
    
    function onChannel() {
        CastingBar cb = CastingBar.create(response).setSound(castSound).setVisuals(ART_FAERIE_DRAGON_MISSILE);
        BuffSlot bs;
        Buff buf;
        if (GetUnitAbilityLevel(SpellEvent.CastingUnit, BID_DIVINE_FAVOR) > 0) {
            cb.haste = SpellData.inst(SID_HOLY_LIGHT, SCOPE_PREFIX).Cast(GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_HOLY_LIGHT)) * 0.5;
        }
        bs = BuffSlot[SpellEvent.CastingUnit];
        buf = bs.getBuffByBid(BID_HOLY_LIGHT_IMPROVED);
        if (buf != 0) {
            cb.haste = SpellData.inst(SID_HOLY_LIGHT, SCOPE_PREFIX).Cast(GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_HOLY_LIGHT));
            bs.dispelByBuff(buf);
            buf.destroy();
        }
        cb.launch();
    }

    function onEffectImprove(Buff buf) {
        NFSetPlayerAbilityIcon(GetOwningPlayer(buf.bd.target), SID_HOLY_LIGHT, BTNInnerFire);
    }
    function onRemoveImprove(Buff buf) {
        NFSetPlayerAbilityIcon(GetOwningPlayer(buf.bd.target), SID_HOLY_LIGHT, BTNResurrection);
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
        BuffType.register(BID_HOLY_LIGHT_IMPROVED, BUFF_PHYX, BUFF_POS);
    }

}
//! endzinc
