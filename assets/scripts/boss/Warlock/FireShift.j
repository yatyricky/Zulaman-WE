//! zinc
library FireShift requires WarlockGlobal {

    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageTaken += buf.bd.r0;
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageTaken -= buf.bd.r0;
    }

    function response(CastingBar cd) {
        integer i;
        Buff buf;
        Point p;
        // AOE damage & debuff
        i = 0;
        while (i < PlayerUnits.n) {
            if (GetDistance.unitCoord2d(PlayerUnits.units[i], cd.targetX, cd.targetY) <= FireShiftConsts.AOE) {
                // damage
                DamageTarget(cd.caster, PlayerUnits.units[i], 500, SpellData.inst(SID_FIRE_SHIFT, SCOPE_PREFIX).name, false, false, false, WEAPON_TYPE_WHOKNOWS, true);
                // amp
                buf = Buff.cast(cd.caster, PlayerUnits.units[i], BID_FIRE_SHIFT);
                buf.bd.tick = -1;
                buf.bd.interval = 30.0;
                onRemove(buf);
                buf.bd.r0 += 0.1;
                if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_FaerieFireTarget, buf, "head");}
                buf.bd.boe = onEffect;
                buf.bd.bor = onRemove;
                buf.run();
            }
            i += 1;
        }
        // self damage
        DummyDamageTarget(cd.caster, GetUnitState(cd.caster, UNIT_STATE_MAX_LIFE) * FireShiftConsts.selfDamageRatio, SpellData.inst(SID_FIRE_SHIFT, SCOPE_PREFIX).name);
        // teleport
        SetUnitPosition(cd.caster, cd.targetX, cd.targetY);
        // visual effect
        AddTimedEffect.atCoord(ART_VolcanoMissile, cd.targetX, cd.targetY, 0).setScale(2.0);
        // remove DBM
        p = Point(cd.extraData);
        p.destroy();
        FireShiftConsts.ps.remove(p);
    }

    function onChannel() {
        CastingBar cb = CastingBar.create(response);
        cb.extraData = Point.new(SpellEvent.TargetX, SpellEvent.TargetY);
        cb.setVisuals(ART_FireBallMissile);
        cb.launch();
        VisualEffects.drawCircle(ART_FireTrapUp, SpellEvent.TargetX, SpellEvent.TargetY, FireShiftConsts.AOE, 15, 0.15, 2.0);
        FireShiftConsts.ps.push(cb.extraData);
    }

    function onInit() {
        RegisterSpellChannelResponse(SID_FIRE_SHIFT, onChannel);
        BuffType.register(BID_FIRE_SHIFT, BUFF_MAGE, BUFF_NEG);
    }

}
//! endzinc
