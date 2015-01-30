//! zinc
library SpiritBolt requires CastingBar, Projectile, CombatFacts {
#define ART_MISSILE "Abilities\\Weapons\\ZigguratMissile\\ZigguratMissile.mdl"
#define BUFF_ID 'A05T'
#define ART_ABSORB "Objects\\Spawnmodels\\Undead\\UndeadDissipate\\UndeadDissipate.mdl"

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
            DamageTarget(p.caster, p.target, 30.0, SpellData[SIDSPIRITBOLT].name, false, false, false, WEAPON_TYPE_WHOKNOWS);
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
        RegisterSpellChannelResponse(SIDSPIRITBOLT, onChannel);
        BuffType.register(BUFF_ID, BUFF_PHYX, BUFF_NEG);
        
        spell1Tab = Table.create();
        spell2Tab = Table.create();
        spell1Tab[UTIDBLOODELFDEFENDER] = SIDSUNFIRESTORMHEX;
        spell2Tab[UTIDBLOODELFDEFENDER] = SIDSHIELDOFSINDOREIHEX;
        spell1Tab[UTIDCLAWDRUID] = SIDMANGLEHEX;
        spell2Tab[UTIDCLAWDRUID] = SIDRABIESHEX;
        spell1Tab[UTIDKEEPEROFGROVE] = SIDTRANQUILITYHEX;
        spell2Tab[UTIDKEEPEROFGROVE] = SIDLIFEBLOOMHEX;
        spell1Tab[UTIDPALADIN] = SIDHOLYBOLTHEX;
        spell2Tab[UTIDPALADIN] = SIDHOLYSHOCKHEX;
        spell1Tab[UTIDPRIEST] = SIDHEALHEX;
        spell2Tab[UTIDPRIEST] = SIDSHIELDHEX;
        spell1Tab[UTIDBLADEMASTER] = SIDMORTALSTRIKEHEX;
        spell2Tab[UTIDBLADEMASTER] = SIDOVERPOWERHEX;
        spell1Tab[UTIDDARKRANGER] = SIDDARKARROWHEX;
        spell2Tab[UTIDDARKRANGER] = SIDFREEZINGTRAPHEX;
        spell1Tab[UTIDFROSTMAGE] = SIDFROSTBOLTHEX;
        spell2Tab[UTIDFROSTMAGE] = SIDPOLYMORPHHEX;
        spell1Tab[UTIDEARTHBINDER] = SIDLIGHTNINGTOTEMHEX;
        spell2Tab[UTIDEARTHBINDER] = SIDCHARGEHEX;
        spell1Tab[UTIDROGUE] = SIDSTEALTHHEX;
        spell2Tab[UTIDROGUE] = SIDBLADEFLURRYHEX;
        spell1Tab[UTIDHEATHEN] = SIDPAINHEX;
        spell2Tab[UTIDHEATHEN] = SIDTERRORHEX;        
    }
#undef ART_ABSORB
#undef BUFF_ID
#undef ART_MISSILE
}
//! endzinc
