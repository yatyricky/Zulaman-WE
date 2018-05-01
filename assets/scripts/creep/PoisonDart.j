//! zinc
library PoisonDart requires DamageSystem, Sounds {

    struct PoisonDart {
        private timer tm;
        private unit shooter, caster, mis;
        private integer tick;
        private real x, y;
        private group damaged;
        private effect eff;
        
        private method destroy() {
            DestroyEffect(this.eff);
            KillUnit(this.mis);
            ReleaseGroup(this.damaged);
            ReleaseTimer(this.tm);
            this.tm = null;
            this.damaged = null;
            this.caster = null;
            this.shooter = null;
            this.mis = null;
            this.deallocate();
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            real nextx;
            real nexty;
            integer i = 0;
            nextx = GetUnitX(this.mis) + this.x;
            nexty = GetUnitY(this.mis) + this.y;
            if (this.tick < 56) {
                SetUnitX(this.mis, nextx);
                SetUnitY(this.mis, nexty);
                this.tick += 1;
                
                for (0 <= i < PlayerUnits.n) {
                    if (GetDistance.units2d(PlayerUnits.units[i], this.mis) < 150.0 && !IsUnitDead(PlayerUnits.units[i]) && !IsUnitInGroup(PlayerUnits.units[i], this.damaged)) {
                        DamageTarget(this.caster, PlayerUnits.units[i], 300.0, SpellData[SID_POISON_DART].name, false, false, false, WEAPON_TYPE_WHOKNOWS);
                        AddTimedEffect.atUnit(ART_STAMPEDE_MISSILE_DEATH, PlayerUnits.units[i], "origin", 0.0);
                        GroupAddUnit(this.damaged, PlayerUnits.units[i]);
                    }
                }
            } else {
                this.destroy();
            }
        }
        
        static method start(unit caster, unit shooter, unit target) {
            thistype this = thistype.allocate();
            real angle = GetAngle(GetUnitX(shooter), GetUnitY(shooter), GetUnitX(target), GetUnitY(target));
            this.caster = caster;
            this.shooter = shooter;
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.x = Cos(angle) * 32.0;
            this.y = Sin(angle) * 32.0;
            this.tick = 0;
            this.damaged = NewGroup();
            this.mis = CreateUnit(Player(0), DUMMY_ID, GetUnitX(shooter), GetUnitY(shooter), Rad2Deg(angle));
            SetUnitFlyable(this.mis);
            SetUnitFlyHeight(this.mis, 50.0, 0.0);
            //SetUnitScale(this.mis, 2.0, 2.0, 2.0);
            this.eff = AddSpecialEffectTarget(ART_DRYAD_MISSILE, this.mis, "origin");
            TimerStart(this.tm, 0.04, true, function thistype.run);
        }
    }

    function onCast() {
        integer i;
        integer utid;
        for (0 <= i < MobList.n) {
            utid = GetUnitTypeId(MobList.units[i]);
            if (utid == UTID_CURSED_HUNTER || utid == UTID_TWILIGHT_WITCH_DOCTOR || utid == UTID_GRIM_TOTEM) {
                if (GetDistance.units2d(MobList.units[i], SpellEvent.CastingUnit) <= 750.0) {
                    PoisonDart.start(SpellEvent.CastingUnit, MobList.units[i], SpellEvent.TargetUnit);
                }
            }
        }
        RunSoundAtPoint2d(SND_ARCHER, GetUnitX(SpellEvent.CastingUnit), GetUnitY(SpellEvent.CastingUnit));
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_POISON_DART, onCast);
    }
}
//! endzinc
