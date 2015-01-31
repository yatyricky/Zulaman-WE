//! zinc
library ArmageddonScroll requires SpellEvent, DamageSystem {
#define ART_TARGET "Abilities\\Spells\\Demon\\RainOfFire\\RainOfFireTarget.mdl"
#define ART_TARGET1 "Units\\Demon\\Infernal\\InfernalBirth.mdl"
#define ART_CRATER "Objects\\Spawnmodels\\Other\\NeutralBuildingExplosion\\NeutralBuildingExplosion.mdl"
#define ART_FIRE "Environment\\LargeBuildingFire\\LargeBuildingFire0.mdl"

    struct Armageddon {
        private timer tm;
        private unit caster;
        private integer tick;
        private real x, y;
        
        private method destroy() {
            ReleaseTimer(this.tm);
            this.tm = null;
            this.caster = null;
            this.deallocate();
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            unit tu;
            integer rnd;
            real dis, ang;
            this.tick -= 1;
            if (this.tick < 61) {
                if (ModuloInteger(this.tick, 5) == 0) {
                    GroupUnitsInArea(ENUM_GROUP, this.x, this.y, 600.0);
                    tu = FirstOfGroup(ENUM_GROUP);
                    while (tu != null) {
                        if (!IsUnitDummy(tu) && !IsUnitDead(tu)) {
                            DamageTarget(this.caster, tu, GetRandomReal(1000, 1500), SpellData[SID_ARMAGEDDON_SCROLL].name, false, true, false, WEAPON_TYPE_WHOKNOWS);
                            AddTimedEffect.atUnit(ART_FIRE, tu, "origin", 0.5);
                        }
                        GroupRemoveUnit(ENUM_GROUP, tu);
                        tu = FirstOfGroup(ENUM_GROUP);
                    }
                    tu = null;
                }
                ang = GetRandomReal(0.0, 6.283);
                dis = GetRandomReal(1.0, 360000.0);
                dis = SquareRoot(dis);
                rnd = GetRandomInt(0, 99);
                if (rnd < 25) {
                    AddTimedEffect.atCoord(ART_TARGET, this.x + Cos(ang) * dis, this.y + Sin(ang) * dis, 1.0);
                } else if (rnd < 50) {
                    AddTimedEffect.atCoord(ART_TARGET1, this.x + Cos(ang) * dis, this.y + Sin(ang) * dis, 1.0);
                    DelayedAddTimedEffect.atCoord(ART_CRATER, this.x + Cos(ang) * dis, this.y + Sin(ang) * dis, 1.0, 0.7);
                }
            }
            if (this.tick < 1) {
                this.destroy();
            }
        }
        
        static method start(unit caster, real x, real y) {
            thistype this = thistype.allocate();
            this.x = x;
            this.y = y;
            this.caster = caster;
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.tick = 75;
            TimerStart(this.tm, 0.1, true, function thistype.run);
        }
    }

    function onCast() {
        Armageddon.start(SpellEvent.CastingUnit, SpellEvent.TargetX, SpellEvent.TargetY);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_ARMAGEDDON_SCROLL, onCast);
        
    }
#undef ART_FIRE
#undef ART_CRATER
#undef ART_TARGET1
#undef ART_TARGET
}
//! endzinc
