//! zinc
library Blizzard requires CastingBar, GroupUtils, FrostMageGlobal, DamageSystem, Sounds {

    function returnDamage(integer lvl, real sp) -> real {
        real app = sp * 0.4;
        if (lvl == 1) {
            return 70 + app;
        } else {
            return 110 + app;
        }
    }

    function fallWave(unit caster, real x, real y) {
        integer lvl;
        real dmg;
        unit tu;
        real length, rad, aoe;
        if (GetUnitAbilityLevel(caster, SIDBLIZZARD1) == 1) {
            lvl = 3;
        } else {
            lvl = GetUnitAbilityLevel(caster, SIDBLIZZARD);
        }
        dmg = returnDamage(lvl, UnitProp[caster].SpellPower()) * returnFrostDamage(caster);
        aoe = 150.0 + 100.0 * lvl;
        GroupUnitsInArea(ENUM_GROUP, x, y, aoe);
        tu = FirstOfGroup(ENUM_GROUP);
        while (tu != null) {
            GroupRemoveUnit(ENUM_GROUP, tu);
            if (!IsUnitDummy(tu) && !IsUnitDead(tu) && IsUnitEnemy(tu, GetOwningPlayer(caster))) {
                DamageTarget(caster, tu, dmg, SpellData[SIDBLIZZARD].name, false, false, false, WEAPON_TYPE_WHOKNOWS);
            }
            tu = FirstOfGroup(ENUM_GROUP);
        }
        tu = null;
        SpamEffectsInCircle(ART_BLIZZARD_TARGET, x, y, aoe, lvl * 10, 0.5);
        RunSoundAtPoint2d(SND_BLIZZARD, x, y);
    }

    function response(CastingBar cd) {
        fallWave(cd.caster, cd.targetX, cd.targetY);
    }
    
    function onChannel() {
        CastingBar cb = CastingBar.create(response);
        integer lvl;
        if (GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDBLIZZARD1) == 1) {
            lvl = 3;
        } else {
            lvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDBLIZZARD);
        }
        cb.cost = 65 + lvl * 35;
        cb.channel(Rounding(5.0 * (1.0 + UnitProp[SpellEvent.CastingUnit].SpellHaste())));
    }
    
    struct BlizzardAuto {
        private timer tm;
        private unit c;
        private real x, y;
        private integer tick;
        
        private method destroy() {
            ReleaseTimer(this.tm);
            this.tm = null;
            this.c = null;
            this.deallocate();
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            this.tick -= 1;
            fallWave(this.c, this.x, this.y);
            if (this.tick < 1) {
                this.destroy();
            }
        }
    
        static method start(unit c, real x, real y) {
            thistype this = thistype.allocate();
            real intv;
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.c = c;
            this.x = x;
            this.y = y;
            intv = 1.0 / (1.0 + UnitProp[c].SpellHaste());
            this.tick = Rounding(5.0 / intv);
            TimerStart(this.tm, intv, true, function thistype.run);
        }
    }
    
    function onCast() {
        BlizzardAuto.start(SpellEvent.CastingUnit, SpellEvent.TargetX, SpellEvent.TargetY);
    }
    
    function lvlup() -> boolean {
        if (GetLearnedSkill() == SIDBLIZZARD) {
            if (GetUnitAbilityLevel(GetTriggerUnit(), SIDBLIZZARD) == 3) {
                TimedUnitRemoveAbility.start(GetTriggerUnit(), SIDBLIZZARD);
                UnitAddAbility(GetTriggerUnit(), SIDBLIZZARD1);
            }
        }
        return false;
    }

    function onInit() {
        RegisterSpellChannelResponse(SIDBLIZZARD, onChannel);
        RegisterSpellEffectResponse(SIDBLIZZARD1, onCast);
        TriggerAnyUnit(EVENT_PLAYER_HERO_SKILL, function lvlup);
    }
}
//! endzinc
