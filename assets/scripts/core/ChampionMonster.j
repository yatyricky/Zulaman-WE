//! zinc
library ChampionMonster requires UnitProperty, DamageSystem {

    public constant integer CHMP_ROCK = 1;
    public constant integer CHMP_FANATIC = 2;
    public constant integer CHMP_BRAMBLE = 3;
    public constant integer CHMP_VAMPIRE = 4;
    public constant integer CHMP_LESSER = 5;

    HandleTable ht;
    HandleTable effectTable;

    public function ChampionizeLesser(unit u) {
        UnitProp up = UnitProp.inst(u, SCOPE_PREFIX);
        up.ModLife(R2I(GetUnitState(u, UNIT_STATE_MAX_LIFE) * 0.25));
        effectTable[u] = 0;
        SetUnitScale(u, 1.5, 1.5, 1.5);
        ht[u] = CHMP_LESSER;
    }

    public function ChampionizeRock(unit u) {
        UnitProp up = UnitProp.inst(u, SCOPE_PREFIX);
        up.ModLife(R2I(GetUnitState(u, UNIT_STATE_MAX_LIFE)));
        up.damageTaken -= 0.4;
        effectTable[u] = Eff2Int(AddSpecialEffectTarget(ART_DevotionAura, u, "origin"));
        SetUnitScale(u, 1.5, 1.5, 1.5);
        ht[u] = CHMP_ROCK;
    }

    public function ChampionizeFanatic(unit u) {
        UnitProp up = UnitProp.inst(u, SCOPE_PREFIX);
        up.ModLife(R2I(GetUnitState(u, UNIT_STATE_MAX_LIFE)));
        up.ModAttackSpeed(100);
        up.ModSpeed(120);
        up.ModAP(R2I(up.AttackPower() * 0.5));
        effectTable[u] = Eff2Int(AddSpecialEffectTarget(ART_CommandAura, u, "origin"));
        SetUnitScale(u, 1.5, 1.5, 1.5);
        ht[u] = CHMP_FANATIC;
    }

    public function ChampionizeBramble(unit u) {
        UnitProp up = UnitProp.inst(u, SCOPE_PREFIX);
        up.ModLife(R2I(GetUnitState(u, UNIT_STATE_MAX_LIFE)));
        effectTable[u] = Eff2Int(AddSpecialEffectTarget(ART_ThornsAura, u, "origin"));
        SetUnitScale(u, 1.5, 1.5, 1.5);
        ht[u] = CHMP_BRAMBLE;
    }

    public function ChampionizeVampire(unit u) {
        UnitProp up = UnitProp.inst(u, SCOPE_PREFIX);
        up.ModLife(R2I(GetUnitState(u, UNIT_STATE_MAX_LIFE)));
        up.ll += 10;
        effectTable[u] = Eff2Int(AddSpecialEffectTarget(ART_VAMPIRIC_AURA, u, "origin"));
        SetUnitScale(u, 1.5, 1.5, 1.5);
        ht[u] = CHMP_VAMPIRE;
    }

    public function ChampionizeRandom(unit u) {
        integer roll = GetRandomInt(0, 3);
        if (roll == 0) {
            ChampionizeRock(u);
        } else if (roll == 1) {
            ChampionizeFanatic(u);
        } else if (roll == 2) {
            ChampionizeBramble(u);
        } else if (roll == 3) {
            ChampionizeVampire(u);
        }
    }

    function delayedThornsDamage(DelayTask dt) {
        DamageTarget(dt.u0, dt.u1, dt.r0, SpellData.inst(SID_CHAMPION_THORNS, SCOPE_PREFIX).name, false, false, false, WEAPON_TYPE_WHOKNOWS, false);
    }

    function thornsMissileOnHit(Projectile p) -> boolean {
        DamageTarget(p.caster, p.target, p.r0, SpellData.inst(SID_CHAMPION_THORNS, SCOPE_PREFIX).name, false, false, false, WEAPON_TYPE_WHOKNOWS, false);
        return true;
    }

    function damaged() {
        DelayTask dt;
        Projectile p;
        real dmg;
        if (DamageResult.isHit == false) return;
        if (DamageResult.wasDirect == false) return;
        if (ht.exists(DamageResult.target) == false) return;
        if (ht[DamageResult.target] != CHMP_BRAMBLE) return;

        dmg = DamageResult.amount * 1;
        if (DamageResult.isPhyx == true) {
            dt = DelayTask.create(delayedThornsDamage, 0.02);
            dt.u0 = DamageResult.target;
            dt.u1 = DamageResult.source;
            dt.r0 = dmg;
            AddTimedEffect.atUnit(ART_ThornsAuraDamage, dt.u1, "origin", 0.2);
        } else {
            p = Projectile.create();
            p.caster = DamageResult.target;
            p.target = DamageResult.source;
            p.path = ART_FanOfKnivesMissile;
            p.pr = thornsMissileOnHit;
            p.speed = 800;
            p.r0 = dmg;
            p.launch();
        }
    }

    function championDeath(unit u) {
        if (effectTable.exists(u) == false) return;
        if (effectTable[u] == 0) return;
        DestroyEffect(Int2Eff(effectTable[u]));
        effectTable.flush(u);
        ht.flush(u);
    }

    function onInit() {
        ht = HandleTable.create();
        effectTable = HandleTable.create();
        RegisterDamagedEvent(damaged);
        RegisterUnitDeath(championDeath);
    }

}
//! endzinc
