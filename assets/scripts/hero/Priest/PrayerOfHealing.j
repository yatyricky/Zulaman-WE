//! zinc
library PrayerOfHealing requires CastingBar, UnitProperty, PlayerUnitList, Sounds {

    integer castSound;

    function returnTotalHealFactor(integer lvl) -> real {
        return 2.5;
    }

    function returnMaxHealPerUnit(integer lvl, real sp) -> real {
        return 50.0 + 50.0 * lvl + sp * 0.96;
    }

    function onEffect(Buff buf) {}

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModArmor(0 - buf.bd.i1);
    }

    function response(CastingBar cd) {
        integer i = 0;
        integer lvl = GetUnitAbilityLevel(cd.caster, SID_PRAYER_OF_HEALING);
        integer count = 0;
        real amt, single;
        integer armorAmp;
        Buff buf;
        while (i < PlayerUnits.n) {  
            if (GetDistance.unitCoord2d(PlayerUnits.units[i], cd.targetX, cd.targetY) < 200 + 50 * lvl) {
                count += 1;
            }
            i += 1;
        }
        if (count > 0) {
            single = returnMaxHealPerUnit(lvl, UnitProp.inst(cd.caster, SCOPE_PREFIX).SpellPower());
            amt = single * returnTotalHealFactor(lvl) / count;
            if (amt > single) {
                amt = single;
            }
            i = 0;
            while (i < PlayerUnits.n) {
                if (GetDistance.unitCoord2d(PlayerUnits.units[i], cd.targetX, cd.targetY) < 200 + 50 * lvl) {
                    HealTarget(cd.caster, PlayerUnits.units[i], amt, SpellData.inst(SID_PRAYER_OF_HEALING, SCOPE_PREFIX).name, 0.0, true);
                    AddTimedEffect.atUnit(ART_DARK_PORTAL_TARGET, PlayerUnits.units[i], "origin", 0.3);

                    armorAmp = Rounding(ItemExAttributes.getUnitAttrVal(cd.caster, IATTR_PR_POHDEF, SCOPE_PREFIX));
                    if (armorAmp > 0) {
                        buf = Buff.cast(cd.caster, PlayerUnits.units[i], BID_PRAYER_OF_HEALING);
                        buf.bd.tick = -1;
                        buf.bd.interval = 7.0;
                        if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_INNER_FIRE_TARGET, buf, "overhead");}
                        if (buf.bd.i0 == 0) {
                            buf.bd.i0 = 11;
                            buf.bd.i1 = armorAmp;
                            UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModArmor(buf.bd.i1);
                        } else {
                            if (armorAmp > buf.bd.i1) {
                                UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModArmor(armorAmp - buf.bd.i1);
                                buf.bd.i1 = armorAmp;
                            }
                        }
                        buf.bd.boe = onEffect;
                        buf.bd.bor = onRemove;
                        buf.run();
                    }
                }
                i += 1;
            }
        }
    }
    
    function onChannel() {
        CastingBar.create(response).setVisuals(ART_FAERIE_DRAGON_MISSILE).launch();
        VisualEffects.circle(ART_GlowingRunes8, SpellEvent.TargetX, SpellEvent.TargetY, 200 + 50 * GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_PRAYER_OF_HEALING), 15, 1);
    }

    function onInit() {
        castSound = DefineSound("Sound\\Ambient\\DoodadEffects\\RunesGlow.wav", 5000, true, false);
        RegisterSpellChannelResponse(SID_PRAYER_OF_HEALING, onChannel);
        BuffType.register(BID_PRAYER_OF_HEALING, BUFF_MAGE, BUFF_POS);
    }

}
//! endzinc
