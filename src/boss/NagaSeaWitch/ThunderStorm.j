//! zinc
library ThunderStorm requires SpellEvent, DamageSystem, PlayerUnitList, CombatFacts {
#define SPELL_ID 'A03O'
#define ART "Abilities\\Spells\\NightElf\\Cyclone\\CycloneTarget.mdl"
#define INDICATOR "Doodads\\Cinematic\\GlowingRunes\\GlowingRunes2.mdl"

    weathereffect rain;

    struct Lift {
        private timer tm;
        private unit b;
        private integer c;
        private real x;
        
        private method destroy() {
            ReleaseTimer(this.tm);
            this.tm = null;
            this.b = null;
            this.deallocate();
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            this.c += 1;
            SetUnitFlyHeight(this.b, Sin(3.1416 / 50 * this.c + this.x) * 500.0, 0.0);
            if (this.c > 24) {
                if (this.x < 1) {
                    SetUnitFlyHeight(this.b, 500.0, 0.0);
                } else {
                    SetUnitFlyHeight(this.b, 0.0, 0.0);
                }
                this.destroy();
            }
        }
    
        static method start(unit b, real x) {
            thistype this = thistype.allocate();
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.b = b;
            this.c = 0;
            this.x = x;
            SetUnitFlyable(b);
            TimerStart(this.tm, 0.04, true, function thistype.run);
        }
    }

    function response(CastingBar cd) {
        integer i;
        real box, boy;
        integer flip;
        // actual effect
        if (ModuloInteger(cd.nodes, 2) == 0) {
            box = 100.0 * Pow(1.5, 10 - cd.nodes / 2);
            i = 0;
            while (i < PlayerUnits.n) {  
                if (GetDistance.units2d(cd.target, PlayerUnits.units[i]) > DBMNagaSeaWitch.safeRange) {
                    DamageTarget(cd.caster, PlayerUnits.units[i], box, SpellData[SPELL_ID].name, false, false, false, WEAPON_TYPE_WHOKNOWS);
                    AddTimedLight.atUnits("CLSB", cd.target, PlayerUnits.units[i], 0.25);
                    AddTimedEffect.atCoord(ART_IMPACT, GetUnitX(PlayerUnits.units[i]), GetUnitY(PlayerUnits.units[i]), 0.3);
                }
                i += 1;
            }
        }
        // special effect
        AddTimedLight.atUnits("FORK", cd.caster, cd.target, 0.5);
        i = GetRandomInt(4, 7);
        while (i > 0) {
            flip = GetRandomInt(0, 1);
            if (flip == 0) {flip = -1;}
            box = GetUnitX(cd.target) + flip * (GetRandomInt(0, 900) + DBMNagaSeaWitch.safeRange);
            flip = GetRandomInt(0, 1);
            if (flip == 0) {flip = -1;}
            boy = GetUnitY(cd.target) + flip * (GetRandomInt(0, 900) + DBMNagaSeaWitch.safeRange);
            AddTimedLight.atUnitCoord("CLSB", cd.target, box, boy, GetRandomReal(0.4, 1.2));
            AddTimedEffect.atCoord(ART_IMPACT, box, boy, 0.3);
            i -= 1;
        }
        if (cd.nodes == -1) {
            RemoveWeatherEffect(rain);
            Lift.start(cd.target, 1.5708);
            DBMNagaSeaWitch.isStorm = false;
            DBMNagaSeaWitch.stormTarget = null;
        }
    }
    
    function onChannel() {
        //if (GetRandomInt(0, 1) == 0) {
        //    PlaySoundAtUnit("AkilzonSummonEagle", caster);
        //} else {
        //    PlaySoundAtUnit("AkilzonEvent02", caster);
        //}
        integer i = 0;
        while (i < 24) {
            AddTimedEffect.atCoord(INDICATOR, GetUnitX(SpellEvent.TargetUnit) + DBMNagaSeaWitch.safeRange * Cos(0.2618 * i), GetUnitY(SpellEvent.TargetUnit) + DBMNagaSeaWitch.safeRange * Sin(0.2618 * i), 10.0);
            i += 1;
        }
        Lift.start(SpellEvent.TargetUnit, 0.0);
        DestroyEffect(AddSpecialEffect(ART, GetUnitX(SpellEvent.TargetUnit), GetUnitY(SpellEvent.TargetUnit)));
        StunUnit(SpellEvent.CastingUnit, SpellEvent.TargetUnit, 10.0);
        //BJDebugMsg("|cffff3300天空中下起了雨.|r")
        rain = AddWeatherEffect(gg_rct_EagleRaining, 'RAhr');
        EnableWeatherEffect(rain, true);
        AddTimedLight.atUnits("FORK", SpellEvent.CastingUnit, SpellEvent.TargetUnit, 0.5);
        CastingBar.create(response).channel(20);
        DBMNagaSeaWitch.isStorm = true;
        DBMNagaSeaWitch.stormTarget = SpellEvent.TargetUnit;
    }

    function onInit() {
        RegisterSpellChannelResponse(SPELL_ID, onChannel);
    }
#undef INDICATOR
#undef ART
#undef SPELL_ID 
}
//! endzinc
