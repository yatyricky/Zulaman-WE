//! zinc
library SpiritBolt requires CastingBar, Projectile, CombatFacts {
constant string  ART_MISSILE  = "Abilities\\Weapons\\ZigguratMissile\\ZigguratMissile.mdl";
constant integer BUFF_ID = 'A05T';
constant string  ART_ABSORB  = "Objects\\Spawnmodels\\Undead\\UndeadDissipate\\UndeadDissipate.mdl";

    Table spell1Tab, spell2Tab;

    function onEffect(Buff buf) {
        AddTimedEffect.atUnit(ART_ABSORB, buf.bd.target, "origin", 1.0);
    }

    function onRemove(Buff buf) {}

    function onhit(Projectile p) -> boolean {
        if (TryReflect(p.target)) {
            p.reverse();
            return false;
        } else {
            DamageTarget(p.caster, p.target, 30.0, SpellData.inst(SID_SPIRIT_BOLT, SCOPE_PREFIX).name, false, false, false, WEAPON_TYPE_WHOKNOWS);
            return true;
        }
    }

    function response(CastingBar cd) {
        Projectile p;
        integer i = 0;
        unit pick;
        Buff buf;
        while (i < PlayerUnits.n) {
            if (!IsUnitDead(PlayerUnits.units[i])) {
                p = Projectile.create();
                p.caster = cd.caster;
                p.target = PlayerUnits.units[i];
                p.path = ART_MISSILE;
                p.pr = onhit;
                p.speed = 700;
                p.launch();
            }
            i += 1;
        }
        if (cd.nodes == -1) {
            pick = PlayerUnits.getRandomHero();
            buf = Buff.cast(cd.caster, pick, BUFF_ID);
            buf.bd.tick = 6;
            buf.bd.interval = 5.0;
            buf.bd.boe = onEffect;
            buf.bd.bor = onRemove;
            buf.run();
            
            AddTimedEffect.atUnit(ART_ABSORB, pick, "origin", 1.0);
            
            DBMHexLord.absorb = GetUnitTypeId(pick);
            if (GetUnitAbilityLevel(cd.caster, DBMHexLord.spell1) > 0) {UnitRemoveAbility(cd.caster, DBMHexLord.spell1);}
            if (GetUnitAbilityLevel(cd.caster, DBMHexLord.spell2) > 0) {UnitRemoveAbility(cd.caster, DBMHexLord.spell2);}
            DBMHexLord.spell1 = spell1Tab[DBMHexLord.absorb];
            DBMHexLord.spell2 = spell2Tab[DBMHexLord.absorb];
            UnitAddAbility(cd.caster, DBMHexLord.spell1);
            UnitAddAbility(cd.caster, DBMHexLord.spell2);
        }
    }
    
    function onChannel() {
        CastingBar.create(response).channel(20);
    }

    function onInit() {
        RegisterSpellChannelResponse(SID_SPIRIT_BOLT, onChannel);
        BuffType.register(BUFF_ID, BUFF_PHYX, BUFF_NEG);
        
        spell1Tab = Table.create();
        spell2Tab = Table.create();
        spell1Tab[UTID_BLOOD_ELF_DEFENDER] = SID_SUN_FIRE_STORMHEX;
        spell2Tab[UTID_BLOOD_ELF_DEFENDER] = SID_SHIELD_OF_SINDOREIHEX;
        spell1Tab[UTID_CLAW_DRUID] = SID_SAVAGE_ROAR_HEX;
        spell2Tab[UTID_CLAW_DRUID] = SID_NATURAL_REFLEX_HEX;
        spell1Tab[UTID_KEEPER_OF_GROVE] = SID_TRANQUILITY_HEX;
        spell2Tab[UTID_KEEPER_OF_GROVE] = SID_LIFE_BLOOMHEX;
        spell1Tab[UTID_PALADIN] = SID_HOLY_BOLT_HEX;
        spell2Tab[UTID_PALADIN] = SID_HOLY_SHOCK_HEX;
        spell1Tab[UTID_PRIEST] = SID_HEAL_HEX;
        spell2Tab[UTID_PRIEST] = SID_SHIELD_HEX;
        spell1Tab[UTID_BLADE_MASTER] = SID_MORTAL_STRIKE_HEX;
        spell2Tab[UTID_BLADE_MASTER] = SID_OVER_POWER_HEX;
        spell1Tab[UTID_DARK_RANGER] = SID_DARK_ARROW_HEX;
        spell2Tab[UTID_DARK_RANGER] = SID_FREEZING_TRAP_HEX;
        spell1Tab[UTID_FROST_MAGE] = SID_FROST_BOLT_HEX;
        spell2Tab[UTID_FROST_MAGE] = SID_POLYMORPH_HEX;
        spell1Tab[UTID_EARTH_BINDER] = SID_LIGHTNING_TOTEM_HEX;
        spell2Tab[UTID_EARTH_BINDER] = SID_CHARGE_HEX;
        spell1Tab[UTID_ROGUE] = SID_STEALTH_HEX;
        spell2Tab[UTID_ROGUE] = SID_BLADE_FLURRY_HEX;
        spell1Tab[UTID_HEATHEN] = SID_PAIN_HEX;
        spell2Tab[UTID_HEATHEN] = SID_TERROR_HEX;        
    }



}
//! endzinc
