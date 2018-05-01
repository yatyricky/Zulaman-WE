//! zinc
library Sounds requires SoundUtils {
    public integer SND_ARCHER;
    public integer SND_BANSHEE;
    public integer SND_BLIZZARD;
    public integer SND_CONVICTION_AURA;
    public integer SND_DOOR;
    
    function onInit() {
        SND_ARCHER = DefineSound("Abilities\\Weapons\\Arrow\\ArrowAttack1.wav", 672, false, true);
        SND_BANSHEE = DefineSound("Units\\Undead\\Banshee\\BansheeDeath.wav", 2380, false, true);
        SND_BLIZZARD = DefineSound("Abilities\\Spells\\Human\\Blizzard\\BlizzardTarget3.wav", 3000, false, true);
        SND_CONVICTION_AURA = DefineSound("Sound\\ConvictionAura.mp3", 1932, false, true);
        SND_DOOR = DefineSound("Doodads\\LordaeronSummer\\Terrain\\Gate\\GateEpicDeath.wav", 1582, false, true);
        //SND_RUNES_GLOW = ;
    }
}
//! endzinc
