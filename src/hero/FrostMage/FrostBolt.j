//! zinc
library FrostBolt requires CastingBar, Projectile, SpellReflection, FrostMageGlobal {
constant integer BUFF_ID = 'A022';
constant string  ART_MISSILE  = "Abilities\\Weapons\\LichMissile\\LichMissile.mdl";
constant string  ART_TARGET  = "Abilities\\Spells\\Other\\FrostDamage\\FrostDamage.mdl";
constant string  ART_FROZEN  = "Abilities\\Spells\\Undead\\FreezingBreath\\FreezingBreathTargetArt.mdl";

    function returnDamage(integer lvl, real sp) -> real {
        return (0 + 175 * lvl + sp * 1.2);
    }
    
    function onEffect1(Buff buf) {
        UnitProp[buf.bd.target].ModSpeed(0 - buf.bd.i0);
    }
    
    function onRemove1(Buff buf) {
        UnitProp[buf.bd.target].ModSpeed(buf.bd.i0);
    }

    function onhit(Projectile p) -> boolean {
        Buff buf;
        if (TryReflect(p.target)) {
            p.reverse();
            return false;
        } else {
            DamageTarget(p.caster, p.target, p.r0, SpellData[SID_FROST_BOLT].name, false, true, false, WEAPON_TYPE_WHOKNOWS);   
            
            // equiped Rage Winterchill's Phylactery
            if (HasRageWinterchillsPhylactery(p.caster)) {
                StunUnit(p.caster, p.target, 1);
                AddTimedEffect.atUnit(ART_FROZEN, p.target, "origin", 1);
            }
            
            buf = Buff.cast(p.caster, p.target, BUFF_ID);
            buf.bd.tick = -1;
            buf.bd.interval = 5.0;
            UnitProp[buf.bd.target].ModSpeed(buf.bd.i0);
            buf.bd.i0 = Rounding(UnitProp[buf.bd.target].Speed() * 0.45);
            if (buf.bd.e0 == 0) {
                buf.bd.e0 = BuffEffect.create(ART_TARGET, buf, "origin");
            }
            buf.bd.boe = onEffect1;
            buf.bd.bor = onRemove1;
            buf.run();
            return true;
        }
    }

    function response(CastingBar cd) {
        Projectile p = Projectile.create();
        integer lvl = GetUnitAbilityLevel(cd.caster, SID_FROST_BOLT);
        p.caster = cd.caster;
        p.target = cd.target;
        p.path = ART_MISSILE;
        p.pr = onhit;
        p.speed = 700;
        p.r0 = returnDamage(lvl, UnitProp[p.caster].SpellPower()) * returnFrostDamage(cd.caster);
        //BJDebugMsg("1??");
        p.launch();
    }
    
    function onChannel() {
        CastingBar.create(response).setSound(castSound).launch();
    }

    integer castSound;
    
    function onInit() {
        castSound = DefineSound("Sound\\Ambient\\DoodadEffects\\CityScapeMagicRunesLoop1.wav", 1149, true, false);
        RegisterSpellChannelResponse(SID_FROST_BOLT, onChannel);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_NEG);
    }




}
//! endzinc
