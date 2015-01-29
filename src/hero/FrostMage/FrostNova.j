//! zinc
library FrostNova requires SpellEvent, StunUtils, UnitProperty, DamageSystem, FrostMageGlobal {
#define BUFF_ID 'A03I'
#define MISSILE 'e000'
#define ART "Abilities\\Spells\\Undead\\FreezingBreath\\FreezingBreathTargetArt.mdl"

    public function FrostMageGetFrostNovaAOE(integer lvl) -> real {
        return 200.0 + 100 * lvl;
    }

    struct NovaEffect {
        private timer tm;
        private unit missiles[32];
        private integer n;
        private real step;
        private integer c;
        
        private method destroy() {
            ReleaseTimer(this.tm);
            while (this.n > 0) {
                this.n -= 1;
                KillUnit(this.missiles[this.n]);
                this.missiles[this.n] = null;
            }
            this.tm = null;
            this.deallocate();
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            real ang = 6.283 / this.n;
            integer n = this.n;
            while (n > 0) {
                n -= 1;
                SetUnitX(this.missiles[n], GetUnitX(this.missiles[n]) + Cos(ang * n) * this.step);
                SetUnitY(this.missiles[n], GetUnitY(this.missiles[n]) + Sin(ang * n) * this.step);
            }
            this.c -= 1;
            if (this.c < 1) {
                this.destroy();
            }
        }
        
        static method start(integer mid, real x, real y, real r, real speed, integer n) {
            thistype this = thistype.allocate();
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.n = n;
            while (n > 0) {
                n -= 1;
                this.missiles[n] = CreateUnit(Player(0), mid, x, y, 360.0 / this.n * n);                
            }
            this.step = speed / 25.0;
            this.c = R2I(r / this.step);
            TimerStart(this.tm, 0.04, true, function thistype.run);
        }
    }

    function oneffect(Buff buf) {
        UnitProp[buf.bd.target].spellTaken += buf.bd.r0;
    }

    function onremove(Buff buf) {
        UnitProp[buf.bd.target].spellTaken -= buf.bd.r0;
    }

    function onCast() {
        //AddTimedEffect.atUnit("Abilities\\Spells\\Undead\\FreezingBreath\\FreezingBreathMissile.mdl", SpellEvent.CastingUnit, "origin", 0.0);
        integer lvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDFROSTNOVA);
        unit tu;
        real dmg = (25 + 25 * lvl + UnitProp[SpellEvent.CastingUnit].SpellPower() * 1.5) * returnFrostDamage(SpellEvent.CastingUnit);
        Buff buf;
        GroupUnitsInArea(ENUM_GROUP, GetUnitX(SpellEvent.CastingUnit), GetUnitY(SpellEvent.CastingUnit), FrostMageGetFrostNovaAOE(lvl));
        tu = FirstOfGroup(ENUM_GROUP);
        while (tu != null) {
            GroupRemoveUnit(ENUM_GROUP, tu);
            if (!IsUnitDummy(tu) && !IsUnitDead(tu) && IsUnitEnemy(tu, GetOwningPlayer(SpellEvent.CastingUnit))) {
                // damage
                DamageTarget(SpellEvent.CastingUnit, tu, dmg, SpellData[SIDFROSTNOVA].name, false, true, false, WEAPON_TYPE_WHOKNOWS);
                // stun
                StunUnit(SpellEvent.CastingUnit, tu, 3 + lvl);
                AddTimedEffect.atUnit(ART, tu, "origin", 3 + lvl);
                // spell taken amp
                buf = Buff.cast(SpellEvent.CastingUnit, tu, BUFF_ID);
                buf.bd.tick = -1;
                buf.bd.interval = 12.0;
                UnitProp[buf.bd.target].spellTaken -= buf.bd.r0;
                buf.bd.r0 = 0.03 * lvl;
                buf.bd.boe = oneffect;
                buf.bd.bor = onremove;
                buf.run();
            }
            tu = FirstOfGroup(ENUM_GROUP);
        }
        tu = null;
        NovaEffect.start(MISSILE, GetUnitX(SpellEvent.CastingUnit), GetUnitY(SpellEvent.CastingUnit), FrostMageGetFrostNovaAOE(lvl), 800.0, 12);
    }

    function onInit() {
        RegisterSpellEffectResponse(SIDFROSTNOVA, onCast);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_NEG);
    }
#undef ART
#undef MISSILE
#undef BUFF_ID
}
//! endzinc
