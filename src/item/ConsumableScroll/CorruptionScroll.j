//! zinc
library CorruptionScroll requires SpellEvent, CastingBar, Projectile {
#define MISSILE "Abilities\\Spells\\Items\\OrbCorruption\\OrbCorruptionMissile.mdl"
#define BUFF_ID 'A07J'

    function onhit(Projectile p) -> boolean {
        return true;
    }
    
    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].ModArmor(0 - buf.bd.i0);
    }
    
    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].ModArmor(buf.bd.i0);
    }

    function onCast() {
        integer i = 0;
        Buff buf;
        Projectile p;
        while (i < MobList.n) {
            if (GetDistance.units2d(MobList.units[i], SpellEvent.CastingUnit) <= 600.0 && !IsUnitDead(MobList.units[i])) {
                p = Projectile.create();
                p.caster = SpellEvent.CastingUnit;
                p.target = MobList.units[i];
                p.path = MISSILE;
                p.pr = onhit;
                p.speed = 1200;
                p.launch();
                
                buf = Buff.cast(SpellEvent.CastingUnit, MobList.units[i], BUFF_ID);
                buf.bd.tick = -1;
                buf.bd.interval = 10.0;
                UnitProp[buf.bd.target].ModArmor(buf.bd.i0);
                buf.bd.i0 = 8;
                //if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_LEFT, buf, "hand, left");}
                //if (buf.bd.e1 == 0) {buf.bd.e1 = BuffEffect.create(ART_RIGHT, buf, "hand, right");}
                buf.bd.boe = onEffect;
                buf.bd.bor = onRemove;
                buf.run();
            }
            i += 1;
        }
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_CORRUPTION_SCROLL, onCast);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_NEG);
    }
#undef BUFF_ID
#undef MISSILE
}
//! endzinc
