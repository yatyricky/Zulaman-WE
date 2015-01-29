//! zinc
library PrayerOfMending requires BuffSystem, SpellEvent, UnitProperty, Projectile, DamageSystem {
#define BUFF_ID 'A01K'
#define PATH "Abilities\\Weapons\\FaerieDragonMissile\\FaerieDragonMissile.mdl"

    function findNearestOf(unit u) -> unit {
        unit tu;
        unit ret;
        real dis = 950.0;
        real tmp;
        GroupUnitsInArea(ENUM_GROUP, GetUnitX(u), GetUnitY(u), 800.0);
        tu = FirstOfGroup(ENUM_GROUP);
        ret = tu;
        while (tu != null) {
            GroupRemoveUnit(ENUM_GROUP, tu);
            if (!IsUnitDummy(tu) && !IsUnitDead(tu) && IsUnitAlly(tu, GetOwningPlayer(u)) && !IsUnit(tu, u)) {
                tmp = GetDistance.units2d(u, tu);
                if (tmp < dis) {
                    ret = tu;
                    dis = tmp;
                }
            }
            tu = FirstOfGroup(ENUM_GROUP);
        }
        tu = null;
        return ret;
    }

    function onEffect(Buff buf) {        
        // equiped benediction
        //if (HasBenediction(buf.bd.u0)) {
        //    CastHeal(buf.bd.u0, buf.bd.target);
        //}
    }
    
    function onRemove(Buff buf) {}

    function onhit(Projectile p) -> boolean {
        Buff buf = Buff.cast(p.caster, p.target, BUFF_ID);
        buf.bd.tick = -1;
        buf.bd.interval = 20.0;
        buf.bd.r0 = p.r0;
        buf.bd.i0 = p.i0;
        buf.bd.u0 = p.u0;
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        return true;
    }
    
    function damaged() {
        Buff buf;
        Projectile p;
        unit next;
        real amt;
        if (DamageResult.isHit) {
            buf = BuffSlot[DamageResult.target].getBuffByBid(BUFF_ID);
            if (buf != 0) {
                // has POM
                // heal first
                amt = DamageResult.amount * buf.bd.r0;
                if (amt < buf.bd.r0 * 80) {
                    amt = buf.bd.r0 * 80;
                }
                amt += UnitProp[buf.bd.u0].SpellPower() / 9.0;
                HealTarget(buf.bd.u0, buf.bd.target, amt, SpellData[SIDPRAYEROFMENDING].name, 0.0);
                AddTimedEffect.atUnit(ART_HEAL, buf.bd.target, "origin", 0.3);
                // deduction
                buf.bd.i0 -= 1;
                if (buf.bd.i0 < 1 || GetUnitAbilityLevel(buf.bd.u0, SIDPRAYEROFMENDING) < 3 || GetUnitStatePercent(buf.bd.target, UNIT_STATE_LIFE, UNIT_STATE_MAX_LIFE) > 50) {
                    // remove
                    BuffSlot[DamageResult.target].dispelByBuff(buf);
                    if (buf.bd.i0 > 0) {
                        // transfer
                        next = findNearestOf(buf.bd.target);
                        if (next != null) {
                            p = Projectile.create();
                            p.caster = buf.bd.target;
                            p.target = next;
                            p.path = PATH;
                            p.pr = onhit;
                            p.speed = 900;
                            p.i0 = buf.bd.i0;
                            p.r0 = buf.bd.r0;
                            p.u0 = buf.bd.u0;
                            //BJDebugMsg("1??");
                            p.launch();
                        }
                    }
                    buf.destroy();
                }
            }
            // otherwise do nothing
        }
        next = null;
    }

    function onCast() {
        Projectile p = Projectile.create();
        integer lvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDPRAYEROFMENDING);
        p.caster = SpellEvent.CastingUnit;
        p.target = SpellEvent.TargetUnit;
        p.path = PATH;
        p.pr = onhit;
        p.speed = 900;
        p.i0 = lvl + 2;
        p.r0 = 0.5 * lvl;
        p.u0 = SpellEvent.CastingUnit;
        //BJDebugMsg("1??");
        p.launch();
    }

    function onInit() {
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
        RegisterSpellEffectResponse(SIDPRAYEROFMENDING, onCast);
        RegisterDamagedEvent(damaged);
    }
#undef PATH
#undef BUFF_ID
}
//! endzinc
