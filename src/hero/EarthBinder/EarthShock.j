//! zinc
library EarthShock requires DamageSystem, SpellData, BuffSystem {

    function returnDamage(integer lvl, real sp) -> real {
        return 300 + 100 * lvl + sp * 3.6;
    }

    function onEffect(Buff buf) {
        BlzSetAbilityIcon(SID_EARTH_SHOCK, BTNVolcano);
    }

    function onRemove(Buff buf) {
        BlzSetAbilityIcon(SID_EARTH_SHOCK, BTNEarthquake);
    }
    
    function onCast() {
        player p;
        Buff buf;
        BuffSlot bs = BuffSlot[SpellEvent.CastingUnit];
        integer lvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_EARTH_SHOCK);
        real dmg = returnDamage(lvl, UnitProp[SpellEvent.CastingUnit].SpellPower());
        AddTimedEffect.atUnit(ART_ANCIENT_PROTECTOR_MISSILE, SpellEvent.TargetUnit, "origin", 0.2);
        buf = bs.getBuffByBid(BID_EARTH_SHOCK_IMPROVED);
        if (buf != 0) {
            dmg *= 1.1;
            ModUnitMana(SpellEvent.CastingUnit, BlzGetAbilityManaCost(SID_EARTH_SHOCK, lvl));
            bs.dispelByBuff(buf);
            buf.destroy();
        }
        
        DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, dmg, SpellData[SID_EARTH_SHOCK].name, false, true, false, WEAPON_TYPE_WHOKNOWS);
        CounterSpell(SpellEvent.TargetUnit);
        if (GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_ENCHANTED_TOTEM) > 0) {
            p = GetOwningPlayer(SpellEvent.CastingUnit);
            SetPlayerAbilityAvailable(p, SID_TORRENT_TOTEM, false);
            SetPlayerAbilityAvailable(p, SID_LIGHTNING_TOTEM, false);
            SetPlayerAbilityAvailable(p, SID_EARTH_BIND_TOTEM, true);
            currentTotemId[GetPlayerId(p)] = SID_EARTH_BIND_TOTEM;
            p = null;
        }
    }

    public function ImproveEarthShock(unit u) {
        Buff buf;
        CoolDown(u, SID_EARTH_SHOCK);
        buf = Buff.cast(u, u, BID_EARTH_SHOCK_IMPROVED);
        buf.bd.interval = 4;
        buf.bd.tick = -1;
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }

    function onInit() {
        BuffType.register(BID_EARTH_SHOCK_IMPROVED, BUFF_PHYX, BUFF_POS);
        RegisterSpellEffectResponse(SID_EARTH_SHOCK, onCast);
    }

}
//! endzinc
