//! zinc
library ArcanePotion requires SpellEvent, BuffSystem, DamageSystem, Projectile {
#define BUFF_ID 'A089'
#define PATH "Abilities\\Spells\\Items\\OrbCorruption\\OrbCorruptionMissile.mdl"

    function onhit(Projectile p) -> boolean {
        DamageTarget(p.caster, p.target, 100.0, SpellData[SID_ARCANE_POTION].name, false, true, false, WEAPON_TYPE_WHOKNOWS);
        return true;
    }
    
    function damaged() {
        Projectile p;
        if (DamageResult.isHit && !DamageResult.isPhyx) {
            if (BuffSlot[DamageResult.source].getBuffByBid(BUFF_ID) != 0) {
                if (GetRandomInt(0, 99) < 40) {
                    p = Projectile.create();
                    p.caster = DamageResult.source;
                    p.target = DamageResult.target;
                    p.path = PATH;
                    p.pr = onhit;
                    p.speed = 900;
                    p.launch();
                }
            }
        }
    }
    
    function onEffect(Buff buf) {}    
    function onRemove(Buff buf) {}

    function onCast() {           
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BUFF_ID);
        buf.bd.tick = -1;
        buf.bd.interval = 20.0;
        //if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_TARGET, buf, "origin");}
        //if (buf.bd.e1 == 0) {buf.bd.e1 = BuffEffect.create(ART_RIGHT, buf, "hand, right");}
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_ARCANE_POTION, onCast);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
        RegisterDamagedEvent(damaged);        
    }
#undef PATH
#undef BUFF_ID
}
//! endzinc
