//! zinc
library SpiritHarvest requires Projectile {
#define ART_MISSILE "Abilities\\Spells\\Items\\OrbCorruption\\OrbCorruptionMissile.mdl"
#define ART_TARGET "Abilities\\Spells\\Orc\\LightningShield\\LightningShieldTarget.mdl"
#define BUFF_ID 'A05S'
#define DEBUFF_ID 'A05R'

    function onEffect1(Buff buf) {
        UnitProp[buf.bd.target].damageDealt += buf.bd.r0;
    }

    function onRemove1(Buff buf) {
        UnitProp[buf.bd.target].damageDealt -= buf.bd.r0;
    }

    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].damageDealt -= buf.bd.r0;
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].damageDealt += buf.bd.r0;
    }
    
    function onhit(Projectile p) -> boolean {return true;}

    function onCast() {
        integer i = 0;
        real newExtra = 0.0;
        Buff buf;
        Projectile p;
        while (i < PlayerUnits.n) {
            if (!IsUnitDead(PlayerUnits.units[i])) {
                buf = Buff.cast(SpellEvent.CastingUnit, PlayerUnits.units[i], DEBUFF_ID);
                buf.bd.tick = -1;
                buf.bd.interval = 60.0;
                UnitProp[buf.bd.target].damageDealt += buf.bd.r0;
                buf.bd.r0 += 0.02;
                buf.bd.boe = onEffect;
                buf.bd.bor = onRemove;
                buf.run();
                
                AddTimedEffect.atUnit(ART_TARGET, PlayerUnits.units[i], "origin", 1.0);
                
                if (IsUnitType(PlayerUnits.units[i], UNIT_TYPE_HERO)) {
                    newExtra += 0.02;
                    
                    p = Projectile.create();
                    p.caster = PlayerUnits.units[i];
                    p.target = SpellEvent.CastingUnit;
                    p.path = ART_MISSILE;
                    p.pr = onhit;
                    p.speed = 500;
                    p.launch();
                }
            }
            i += 1;
        }
        if (newExtra > 0.01) {
            buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BUFF_ID);
            buf.bd.tick = -1;
            buf.bd.interval = 60.0;
            UnitProp[buf.bd.target].damageDealt -= buf.bd.r0;
            buf.bd.r0 += newExtra;
            buf.bd.boe = onEffect1;
            buf.bd.bor = onRemove1;
            buf.run();
        }
    }

    function onInit() {
        RegisterSpellEffectResponse(SIDSPIRITHARVEST, onCast);
        BuffType.register(BUFF_ID, BUFF_PHYX, BUFF_POS);
        BuffType.register(DEBUFF_ID, BUFF_PHYX, BUFF_NEG);
    }
    
#undef DEBUFF_ID
#undef BUFF_ID
#undef ART_TARGET
#undef ART_MISSILE
}
//! endzinc
