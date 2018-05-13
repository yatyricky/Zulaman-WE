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
        lvl = GetUnitAbilityLevel(caster, SID_BLIZZARD);
        dmg = returnDamage(lvl, UnitProp.inst(caster, SCOPE_PREFIX).SpellPower()) * returnFrostDamage(caster);
        aoe = 150.0 + 100.0 * lvl;
        GroupUnitsInArea(ENUM_GROUP, x, y, aoe);
        tu = FirstOfGroup(ENUM_GROUP);
        while (tu != null) {
            GroupRemoveUnit(ENUM_GROUP, tu);
            if (!IsUnitDummy(tu) && !IsUnitDead(tu) && IsUnitEnemy(tu, GetOwningPlayer(caster))) {
                DamageTarget(caster, tu, dmg, SpellData.inst(SID_BLIZZARD, SCOPE_PREFIX).name, false, true, false, WEAPON_TYPE_WHOKNOWS, true);
            }
            tu = FirstOfGroup(ENUM_GROUP);
        }
        tu = null;
        SpamEffectsInCircle(ART_BLIZZARD_TARGET, x, y, aoe, lvl * 10, 0.5);
        RunSoundAtPoint2d(SND_BLIZZARD, x, y);
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
            intv = 1.0 / (1.0 + UnitProp.inst(c, SCOPE_PREFIX).SpellHaste());
            this.tick = Rounding(5.0 / intv);
            TimerStart(this.tm, intv, true, function thistype.run);
        }
    }
    
    function onCast() {
        BlizzardAuto.start(SpellEvent.CastingUnit, SpellEvent.TargetX, SpellEvent.TargetY);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_BLIZZARD, onCast);
    }
}
//! endzinc
