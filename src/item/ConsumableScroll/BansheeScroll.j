//! zinc
library BansheeScroll requires SpellEvent, CastingBar, Projectile, Sounds {
#define MISSILE "Abilities\\Weapons\\BansheeMissile\\BansheeMissile.mdl"
#define ART_CURSE "Abilities\\Spells\\Undead\\Curse\\CurseTarget.mdl"
#define BUFF_ID 'A07L'

    function onhit(Projectile p) -> boolean {
        return true;
    }
    
    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].attackRate -= buf.bd.r0;
    }
    
    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].attackRate += buf.bd.r0;
    }

    function onCast() {
        integer i = 0;
        Buff buf;
        Projectile p;
        while (i < MobList.n) {
            if (GetDistance.units2d(MobList.units[i], SpellEvent.CastingUnit) <= 600.0 + 197.0 && !IsUnitDead(MobList.units[i])) {
                p = Projectile.create();
                p.caster = SpellEvent.CastingUnit;
                p.target = MobList.units[i];
                p.path = MISSILE;
                p.pr = onhit;
                p.speed = 1200;
                p.launch();
                
                buf = Buff.cast(SpellEvent.CastingUnit, MobList.units[i], BUFF_ID);
                buf.bd.tick = -1;
                buf.bd.interval = 8.0;
                UnitProp[buf.bd.target].attackRate += buf.bd.r0;
                buf.bd.r0 = 0.5;
                if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_CURSE, buf, "overhead");}
                //if (buf.bd.e1 == 0) {buf.bd.e1 = BuffEffect.create(ART_RIGHT, buf, "hand, right");}
                buf.bd.boe = onEffect;
                buf.bd.bor = onRemove;
                buf.run();
            }
            i += 1;
        }
        RunSoundOnUnit(SND_BANSHEE, SpellEvent.CastingUnit);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_BANSHEE_SCROLL, onCast);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_NEG);
    }
#undef BUFF_ID
#undef ART_CURSE
#undef MISSILE
}
//! endzinc
