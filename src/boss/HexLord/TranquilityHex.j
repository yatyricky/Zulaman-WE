//! zinc
library TranquilityHex requires CastingBar, KeeperOfGroveGlobal, ZAMCore {
#define ART "Abilities\\Spells\\NightElf\\Tranquility\\Tranquility.mdl"

    function response(CastingBar cd) {
        integer i = 0;
        while (i < MobList.n) {
            if (!IsUnitDead(MobList.units[i])) {
                HealTarget(cd.caster, MobList.units[i], 3000.0, SpellData[SIDTRANQUILITYHEX].name, -3.0);
                AddTimedEffect.atUnit(ART_HEAL, MobList.units[i], "origin", 0.5);
                //AddTimedEffect.atUnit(ART_MANA, PlayerUnits.units[i], "origin", 0.5);
                //AddTimedLight.atUnits("HWSB", cd.caster, PlayerUnits.units[i], 0.25);
            }
            i += 1;
        }
    }
    
    function onChannel() {
        CastingBar.create(response).channel(8);        
        AddTimedEffect.atCoord(ART, GetUnitX(SpellEvent.CastingUnit), GetUnitY(SpellEvent.CastingUnit), 4.75);
    }

    function onInit() {
        RegisterSpellChannelResponse(SIDTRANQUILITYHEX, onChannel);
    }
#undef BUFF_ID
#undef ART
}
//! endzinc
