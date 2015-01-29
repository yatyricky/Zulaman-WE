//! zinc
library PrayerOfHealing requires CastingBar, UnitProperty, PlayerUnitList, Sounds {
#define ART "Abilities\\Spells\\Demon\\DarkPortal\\DarkPortalTarget.mdl"

    integer castSound;

    function returnTotalHealFactor(integer lvl) -> real {
        return 2.5;
    }

    function returnMaxHealPerUnit(integer lvl, real sp) -> real {
        return 50.0 + 50.0 * lvl + sp * 0.96;
    }

    struct POHVisualEffect {        
        static method start(real x, real y, real r, integer num, integer tick) {
            integer i = 0;
            real rad = 6.2832 / num;
            while (i < num) {
                AddTimedEffect.atCoord(ART, x + Cos(rad * i) * r, y + Sin(rad * i) * r, tick * 0.04);
                i += 1;
            }
        }
    }

    function response(CastingBar cd) {
        integer i = 0;
        integer lvl = GetUnitAbilityLevel(cd.caster, SIDPRAYEROFHEALING);
        integer count = 0;
        real amt, single;
        while (i < PlayerUnits.n) {  
            if (GetDistance.unitCoord2d(PlayerUnits.units[i], cd.targetX, cd.targetY) < 200 + 50 * lvl) {
                count += 1;
            }
            i += 1;
        }
        if (count > 0) {
            single = returnMaxHealPerUnit(lvl, UnitProp[cd.caster].SpellPower());
            amt = single * returnTotalHealFactor(lvl) / count;
            if (amt > single) {
                amt = single;
            }
            i = 0;
            while (i < PlayerUnits.n) {
                if (GetDistance.unitCoord2d(PlayerUnits.units[i], cd.targetX, cd.targetY) < 200 + 50 * lvl) {
                    HealTarget(cd.caster, PlayerUnits.units[i], amt, SpellData[SIDPRAYEROFHEALING].name, 0.0);
                    AddTimedEffect.atUnit(ART, PlayerUnits.units[i], "origin", 0.3);
                    //AddTimedLight.atUnits("HWSB", cd.caster, PlayerUnits.units[i], 0.25);
                }
                i += 1;
            }
        }
        POHVisualEffect.start(cd.targetX, cd.targetY, 200 + 50 * lvl, 15, 20);
    }
    
    function onChannel() {
        CastingBar.create(response).setSound(castSound).launch();
    }

    function onInit() {
        castSound = DefineSound("Sound\\Ambient\\DoodadEffects\\RunesGlow.wav", 5000, true, false);
        RegisterSpellChannelResponse(SIDPRAYEROFHEALING, onChannel);
    }
#undef ART
}
//! endzinc
