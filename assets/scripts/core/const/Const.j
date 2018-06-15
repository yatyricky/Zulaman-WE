//! zinc
library Constants {
public constant integer NUMBER_OF_MAX_PLAYERS = 6;
public constant integer MOB_PID = 10;
public constant integer NUMBER_OF_BOSSES = 8;
public constant string FORCE_NPCS = "Adventurers";
public constant string FORCE_ENEMY = "The Dark Below";

public constant real INIT_X = 5902.0;
public constant real INIT_Y = -12016.0;

public constant string DAMAGE_NAME_MELEE = "Normal Attack";
public constant string NULL_STR = "";

public constant integer ATT_STR = 1;
public constant integer ATT_AGI = 2;
public constant integer ATT_INT = 3;
public constant integer ATT_NON = 4;

public constant integer CAREER_TYPE_TANK = 32;
public constant integer CAREER_TYPE_HEALER = 2;
public constant integer CAREER_TYPE_DPS = 4;
public constant integer CAREER_TYPE_MINION = 64;
public constant integer CAREER_TYPE_BOSS = 8;
public constant integer CAREER_TYPE_CREEP = 16;

public constant integer BUFF_CATE_ALL = 2;
public constant integer BUFF_PHYX = 4;
public constant integer BUFF_MAGE = 5;
public constant integer BUFF_POS = 10;
public constant integer BUFF_NEG = 20;

public constant integer UTID_TOWN_PORTAL = 'n00P';
public constant integer ITID_PORTAL_0 = 'I025';
public constant integer ITID_PORTAL_1 = 'I024';
public constant integer ITID_PORTAL_2 = 'I026';
public constant integer ITID_PORTAL_3 = 'I027';
public constant integer ITID_PORTAL_4 = 'I028';
public constant integer ITID_PORTAL_5 = 'I029';

public constant integer DUMMY_X = -8500;
public constant integer DUMMY_Y = -11000;

public constant string COLOR_CFF = "|cff";
public constant string COLOR_R = "|r";
public constant string COLOR_ITEM_UNCOMMON = "11ff11";
public constant string COLOR_ITEM_RARE = "8b66ff";
public constant string COLOR_ITEM_LEGENDARY = "ff8c00";
public constant string COLOR_ITEM_RELIC = "ffcc00";
public constant string COLOR_ITEM_LORE_TRIVIA = "999999";
public constant string COLOR_ITEM_LORE_SIGNIFICANT = "ffdead";
public constant string COLOR_DAMAGE_MOB = "ffffff";
public constant string COLOR_DAMAGE_PLAYER = "ff3333";
public constant string COLOR_HEAL = "33ff33";
public constant string COLOR_DAMAGE_CRITICAL = "ffd000";

public constant integer OID_ATTACK = 851983;
public constant integer OID_MOVE = 851986;
public constant integer OID_SMART = 851971;
public constant integer OID_STOP = 851972;
public constant integer OID_HOLD = 851993;
public constant integer OID_FROSTARMORON = 852458;
public constant integer OID_FROSTARMOROFF = 852459;
public constant integer OID_IMMOLATIONON = 852177;
public constant integer OID_IMMOLATIONOFF = 852178;
public constant integer OID_BEARFORM = 852138;
public constant integer OID_UNBEARFORM = 852139;

public constant integer ORDER_TYPE_IMMEDIATE = 1;
public constant integer ORDER_TYPE_TARGET = 4;
public constant integer ORDER_TYPE_POINT = 2;

// dummy ability
public constant integer SID_ATTACK_LL = 1;
public constant integer SID_EXTRA_MAGIC_DAMAGE = 2;
public constant integer SID_GENERAL_STUN = 'A001';
public constant integer SID_HAUNT = 'A04A';
public constant integer SID_HEAL_TESTER = 'A04H';

// blood elf defender
public constant integer UTID_BLOOD_ELF_DEFENDER = 'Hmkg';
public constant integer SID_SHIELD_BLOCK = 'A002';
public constant integer BID_SHIELD_BLOCK = 'A023';
public constant integer SID_SUN_FIRE_STORM = 'A003';
public constant integer SID_ARCANE_SHOCK = 'A004';
public constant integer BID_ARCANE_SHOCK = 'A025';
public constant integer SID_DISCORD = 'A005';
public constant integer BID_DISCORD = 'A030';
public constant integer SID_SHIELD_OF_SINDOREI = 'A006';
public constant integer BID_SHIELD_OF_SINDOREI = 'A031';
// claw druid
public constant integer UTID_CLAW_DRUID = 'Hlgr';
public constant integer SID_LACERATE = 'A01F';
public constant integer BID_LACERATE = 'A02K';
public constant integer SID_SAVAGE_ROAR = 'A010';
public constant integer BID_SAVAGE_ROAR = 'A02L';
public constant integer SID_FOREST_CURE = 'A0A1';
public constant integer SID_NATURAL_REFLEX = 'A016';
public constant integer BID_NATURAL_REFLEX = 'A02M';
public constant integer SID_SURVIVAL_INSTINCTS = 'A0A2';
public constant integer BID_SURVIVAL_INSTINCTS = 'A0A3';
// keeper of grove
public constant integer UTID_KEEPER_OF_GROVE = 'Emfr';
public constant integer SID_LIFE_BLOOM = 'A00D';
public constant integer BID_LIFE_BLOOM = 'A011';
public constant integer SID_REJUVENATION = 'A01X';
public constant integer BID_REJUVENATION = 'A02G';
public constant integer SID_REGROWTH = 'A01Y';
public constant integer BID_REGROWTH = 'A02J';
public constant integer BID_REGROWTH_NO_INSTANT = 'A04I';
public constant integer SID_SWIFT_MEND = 'A020';
public constant integer BID_SWIFT_MEND = 'A02N';
public constant integer SID_TRANQUILITY = 'A01Z';
public constant integer SID_TRANQUILITY_1 = 'A04J';
public constant integer BID_TRANQUILITY = 'A04K';
// paladin
public constant integer UTID_PALADIN = 'Hart';
public constant integer SID_FLASH_LIGHT = 'A00K';
public constant integer SID_HOLY_LIGHT = 'A00L';
public constant integer BID_HOLY_LIGHT_AMP = 'A024';
public constant integer BID_HOLY_LIGHT_SHIELD = 'A029';
public constant integer BID_HOLY_LIGHT_IMPROVED = 'A0CH';
public constant integer SID_HOLY_SHOCK = 'A00M';
public constant integer BID_HOLY_SHOCK = 'A02E';
public constant integer SID_DIVINE_FAVOR = 'A00N';
public constant integer BID_DIVINE_FAVOR = 'A02A';
public constant integer BID_DIVINE_FAVOR_CRIT = 'A0CI';
public constant integer SID_BEACON_OF_LIGHT = 'A00O';
// priest
public constant integer UTID_PRIEST = 'Ofar';
public constant integer SID_HEAL = 'A03V';
public constant integer BID_HEAL = 'A03X';
public constant integer SID_DISPEL = 'A00R';
public constant integer SID_SHIELD = 'A01C';
public constant integer BID_SHIELD = 'A01I';
public constant integer BID_SHIELD_SOUL_WEAK = 'A01J';
public constant integer SID_PRAYER_OF_MENDING = 'A01D';
public constant integer SID_PRAYER_OF_HEALING = 'A03W';
public constant integer BID_PRAYER_OF_HEALING = 'A0CS';
// dark ranger
public constant integer UTID_DARK_RANGER = 'Nbrn';
public constant integer SID_DARK_ARROW = 'A009';
public constant integer SID_CONCERNTRATION = 'A00A';
public constant integer SID_FREEZING_TRAP = 'A00C';
public constant integer SID_POWER_OF_BANSHEE = 'A0CJ';
public constant integer BID_POWER_OF_BANSHEE_CURSE = 'A042';
public constant integer BID_POWER_OF_BANSHEE_FRENZY = 'A043';
public constant integer SID_DEATH_PACT = 'A00G';
public constant integer SID_SUMMON_GHOUL = 'A02X';
public constant integer UTID_GHOUL = 'ugho';
public constant integer SID_LIFE_LEECH = 'A03Y';
public constant integer BID_FREEZING_TRAP = 'A041';
// blade master
public constant integer UTID_BLADE_MASTER = 'Obla';
public constant integer SID_HEROIC_STRIKE = 'A0BO';
public constant integer BID_HEROIC_STRIKE = 'A0BP';
public constant integer SID_REND = 'A00B';
public constant integer BID_REND = 'A008';
public constant integer SID_OVER_POWER = 'A027';
public constant integer SID_MORTAL_STRIKE = 'A00E';
public constant integer SID_EXECUTE = 'A00I';
// frost mage
public constant integer UTID_FROST_MAGE = 'Hjai';
public constant integer SID_FROST_BOLT = 'A01S';
public constant integer SID_BLIZZARD = 'A03H';
public constant integer SID_FROST_NOVA = 'A01U';
public constant integer BID_FROST_NOVA = 'A03I';
public constant integer SID_POLYMORPH = 'A01W';
public constant integer SID_POLYMORPH_1 = 'A03F';
public constant integer BID_POLYMORPH = 'A03E';
public constant integer SID_POLYMORPH_DUMMY = 'A02F';
public constant integer SID_SPELL_TRANSFER = 'A00V';
public constant integer SID_SPELL_CHANNEL = 'A00Q';
// earth binder
public constant integer UTID_EARTH_BINDER = 'Hapm';
public constant integer UTID_EARTH_BINDER_ASC = 'H006';
public constant integer UTID_LIGHTNING_TOTEM = 'u000';
public constant integer UTID_EARTH_BIND_TOTEM = 'u001';
public constant integer UTID_TORRENT_TOTEM = 'u002';
public constant integer SID_STORM_LASH = 'A0AG';
public constant integer SID_EARTH_SHOCK = 'A01G';
public constant integer BID_EARTH_SHOCK_IMPROVED = 'A0CG';
public constant integer SID_PURGE = 'A01H';
public constant integer SID_ENCHANTED_TOTEM = 'A01M';
public constant integer SID_LIGHTNING_TOTEM = 'A036';
public constant integer SID_EARTH_BIND_TOTEM = 'A038';
public constant integer SID_TORRENT_TOTEM = 'A037';
public constant integer SID_ASCENDANCE = 'A0A0';
public constant integer BID_ELEMENTAL_ENPOWER = 'A03C';
public constant integer BID_EARTH_BIND_TOTEM = 'A03A';
// rogue
public constant integer UTID_ROGUE = 'Edem';
public constant integer UTID_NON_STEALTH = 'e003';
public constant integer SID_APIV = 'Apiv';
public constant integer SID_SINISTER_STRIKE = 'A00W';
public constant integer BID_SINISTER_STRIKE = 'A046';
public constant integer SID_EVISCERATE = 'A00X';
public constant integer BID_EVISCERATE = 'A0AT';
public constant integer SID_ASSAULT = 'A00Z';
public constant integer SID_BLADE_FLURRY = 'A013';
public constant integer SID_STEALTH = 'A017';
public constant integer BID_STEALTH_AMP = 'A049';
public constant integer SID_GARROTE = 'A04N';
public constant integer SID_AMBUSH = 'A04O';
// Heretic
public constant integer UTID_HEATHEN = 'Hblm';
public constant integer SID_PAIN = 'A01L';
public constant integer BID_PAIN = 'A01V';
public constant integer BID_PAIN_WEAKNESS = 'A021';
public constant integer SID_MARROW_SQUEEZE = 'A01N';
public constant integer SID_MIND_FLAY = 'A01O';
public constant integer SID_DEATH = 'A01Q';
public constant integer SID_TERROR = 'A01R';

// BOSS
public constant integer SID_FRENZY_CREEP = 'A03P';
public constant integer SID_RAGE_CREEP = 'A03Q';

// Arch Tinker
public constant integer UTID_ARCH_TINKER = 'Ntin';
public constant integer UTID_ARCH_TINKER_MORPH = 'Nrob';
public constant integer SID_GRIP_OF_STATIC_ELECTRICITY = 'A0AF';
public constant integer SID_PULSE_BOMB = 'A0AH';
public constant integer BID_PULSE_BOMB = 'A0AO';
public constant integer SID_LASER_BEAM = 'A0AI';
public constant integer SID_TINKER_MORPH = 'A0AJ';
public constant integer SID_LIGHTNING_SHIELD = 'A0AK';
public constant integer BID_LIGHTNING_SHIELD = 'A0AP';
public constant integer BID_LIGHTNING_SHIELD_NEG = 'A0AQ';
public constant integer UTID_LIGHTNING_SHIELD_FX = 'e00H';
public constant integer SID_POCKET_FACTORY = 'A0AL';
public constant integer UTID_POCKET_FACTORY = 'nfac';
public constant integer SID_SUMMON_CLOCKWORK_GOBLIN = 'A0AR';
public constant integer UTID_CLOCKWORK_GOBLIN = 'ncgb';
public constant integer SID_CLUSTER_ROCKETS = 'A0AM';
public constant integer SID_SELF_DESTRUCT = 'A0AN';

// Naga Sea Witch
public constant integer UTID_NAGA_SEA_WITCH = 'Hvsh';
public constant integer SID_FUCKED_LIGHTNING = 'A03L';
public constant integer BID_FUCKED_LIGHTNING = 'A03R';
public constant integer UTID_FLYING_SERPENT = 'n003';
public constant integer SID_STRONG_BREEZE = 'A03M';
public constant integer SID_SUMMON_SERPENTS = 'A03N';
public constant integer SID_THUNDER_STORM = 'A03O';

// 潮汐男爵
public constant integer UTID_TIDE_BARON = 'Udea';
public constant integer UTID_TIDE_BARON_WATER = 'Udre';
public constant integer SID_ALKALINE_WATER = 'A04U';
public constant integer SID_TIDE = 'A04V';
public constant integer SID_TIDE_BARON_MORPH = 'A04S';
public constant integer SID_TEAR_UP = 'A04W';
public constant integer SID_LANCINATE = 'A04X';
public constant integer SID_RASPY_ROAR = 'A04Y';
public constant integer SID_RASPY_ROAR_DUMMY = 'A051';

// 术士
public constant real WLK_SQR_CENTRE_X = 4608.00;
public constant real WLK_SQR_CENTRE_Y = 768.00;
public constant integer UTID_WARLOCK = 'Ulic';
public constant integer UTID_FIRE_RUNE = 'e004';
public constant integer UTID_FIRE_BOMB = 'e00G';
public constant integer UTID_LAVA_SPAWN = 'n009';
public constant integer SID_FLAME_THROW = 'A05Z';
public constant integer SID_FLAME_BOMB = 'A060';
public constant integer SID_SUMMON_LAVA_SPAWN = 'A061';
public constant integer SID_FRENZY_WARLOCK = 'A062';
public constant integer BID_FRENZY_WARLOCK = 'A0AW';

// Abyss Archon
public constant integer UTID_PIT_ARCHON = 'Ucrl';
public constant integer SID_IMPALE = 'A0B1';
public constant integer UTID_SPIKE = 'n00O';
public constant integer SID_SUMMON_POISONOUS_CRAWLER = 'A0B2';
public constant integer UTID_POISONOUS_CRAWLER = 'ucry';
public constant integer BID_SUMMON_POISONOUS_CRAWLER = 'A0B6';
public constant integer SID_SUMMON_ABOMINATION = 'A0B4';
public constant integer UTID_ABOMINATION = 'uabo';
public constant integer BID_SUMMON_ABOMINATION = 'A0B7';
public constant integer SID_SUMMON_WRAITH = 'A0B5';
public constant integer UTID_WRAITH = 'ushd';
public constant integer BID_SUMMON_WRAITH = 'A0B8';
public constant integer SID_LIFE_SIPHON = 'A0B3';

// The Felguards
public constant integer UTID_FEL_GUARD = 'Nplh';
public constant integer SID_FEL_EXECUTION = 'A0CW';
public constant integer SID_POWER_SLASH = 'A0CX';
public constant integer SID_FEL_FRENZY = 'A0CY';
public constant integer BID_FEL_FRENZY = 'A0CZ';
public constant integer UTID_FEL_DEFENDER = 'Opgh';
public constant integer SID_POWER_SHADOW_SHIFT = 'A0D0';
public constant integer SID_SHADOW_DETONATION = 'A0D1';
public constant integer SID_SOUL_LINK = 'A0D3';
public constant integer BID_SOUL_LINK = 'A0D2';
public constant integer BID_PORTAL_INVULNERABLE = 'A0D4';

// hex lord
public constant integer UTID_HEX_LORD = 'Oshd';
public constant integer SID_SPIRIT_BOLT = 'A053';
public constant integer SID_SPIRIT_HARVEST = 'A05Q';
public constant integer SID_SUN_FIRE_STORMHEX = 'A054';
public constant integer SID_SHIELD_OF_SINDOREIHEX = 'A055';
public constant integer SID_SAVAGE_ROAR_HEX = 'A0AX';
public constant integer BID_SAVAGE_ROAR_HEX = 'A0AZ';
public constant integer SID_NATURAL_REFLEX_HEX = 'A0AY';
public constant integer BID_NATURAL_REFLEX_HEX = 'A0B0';
public constant integer SID_TRANQUILITY_HEX = 'A058';
public constant integer SID_LIFE_BLOOMHEX = 'A059';
public constant integer SID_HOLY_BOLT_HEX = 'A05A';
public constant integer SID_HOLY_SHOCK_HEX = 'A05B';
public constant integer SID_HEAL_HEX = 'A05C';
public constant integer SID_SHIELD_HEX = 'A05D';
public constant integer SID_MORTAL_STRIKE_HEX = 'A05E';
public constant integer SID_OVER_POWER_HEX = 'A05F';
public constant integer SID_DARK_ARROW_HEX = 'A05G';
public constant integer SID_FREEZING_TRAP_HEX = 'A05H';
public constant integer SID_FROST_BOLT_HEX = 'A05I';
public constant integer SID_POLYMORPH_HEX = 'A05J';
public constant integer SID_LIGHTNING_TOTEM_HEX = 'A05K';
public constant integer SID_CHARGE_HEX = 'A05L';
public constant integer SID_STEALTH_HEX = 'A05M';
public constant integer SID_STEALTH_AMBUSH_HEX = 'A05W';
public constant integer SID_BLADE_FLURRY_HEX = 'A05N';
public constant integer SID_PAIN_HEX = 'A05O';
public constant integer SID_TERROR_HEX = 'A05P';

// God of Death
public constant integer UTID_GOD_OF_DEATH = 'Uear';
public constant integer SID_ANNIHILATION = 'XXXX';
public constant integer SID_MIND_BLAST = 'XXXX';
public constant integer SID_ETERNAL_GUARDIAN = 'XXXX';
public constant integer UTID_ETERNAL_GUARDIAN = 'XXXX';
public constant integer SID_ETERNAL_GUARDIAN_FRENZY = 'XXXX';
public constant integer BID_ETERNAL_GUARDIAN_FRENZY = 'XXXX';

// # All creeps

// ## Area 1
// naga siren
public constant integer UTID_NAGA_SIREN = 'n000';
public constant integer SID_LIGHTNING_BOLT = 'A02W';
public constant integer SID_FROST_SHOCK = 'A097';
// naga tide priest
public constant integer UTID_NAGA_TIDE_PRIEST = 'n00B';
public constant integer SID_CHAIN_HEALING = 'A098';
public constant integer SID_HEALING_WARD = 'A099';
public constant integer SID_PROTECTION_WARD = 'A09A';
public constant integer UTID_NTR_HEALING_WARD = 'h004';
public constant integer UTID_NTR_PROTECTION_WARD = 'h005';
// naga myrmidon
public constant integer UTID_NAGA_MYRMIDON = 'n00A';
public constant integer UTID_CHMP_NAGA_MYRMIDON = 'n00Q';
public constant integer SID_NAGA_FRENZY = 'A09C';
public constant integer SID_ARMOR_CRUSHING = 'A09D';
// naga royal guard
public constant integer UTID_NAGA_ROYAL_GUARD = 'n00E';
public constant integer SID_THUNDER_CLAP = 'A09E';
public constant integer SID_RAGE_ROAR = 'A09F';
// sea lizard
public constant integer UTID_SEA_LIZARD = 'n00F';
public constant integer SID_STING = 'A09G';
// murloc slave
public constant integer UTID_MURLOC_SLAVE = 'n00G';
// wind serpent
public constant integer UTID_WIND_SERPENT = 'n00N';
public constant integer SID_CHARGED_BREATH = 'A0AU';
public constant integer SID_MANA_LEECH = 'A0AV';

// ## Area 3
// fel peon
public constant integer UTID_FEL_PEON = 'xxxx';
public constant integer SID_BLOOD_BOIL = 'xxxx';
// fel grunt
public constant integer UTID_FEL_GRUNT = 'n00C';
public constant integer SID_UNHOLY_FRENZY = 'A09H';
public constant integer BID_UNHOLY_FRENZY = 'A0B9';
// fel rider
public constant integer UTID_FEL_RIDER = 'n00H';
public constant integer SID_CHAOS_LEAP = 'A09I';
public constant integer BID_CHAOS_LEAP = 'A0BA';
// fel war bringer
public constant integer UTID_FEL_WAR_BRINGER = 'n00D';
public constant integer SID_WAR_STOMP = 'A0BB';
public constant integer SID_BATTLE_COMMAND = 'A0BC';
public constant integer BID_BATTLE_COMMAND = 'A0BD';
// demonic witch
public constant integer UTID_DEMONIC_WITCH = 'n001';
public constant integer SID_BLAZING_HASTE = 'A02Y';
public constant integer BID_BLAZING_HASTE = 'A02Z';
public constant integer SID_FIRE_BALL = 'A09L';
public constant integer SID_FLAME_SHOCK = 'A09M';
public constant integer BID_FLAME_SHOCK = 'A0BE';
// smoldering tower
public constant integer UTID_SMOLDERING_TOWER = 'ntx2';
public constant integer SID_SMOLDER = 'A0CK';

// ## Area 4
// Noxious Spider
public constant integer UTID_NOXIOUS_SPIDER = 'u003';
public constant integer SID_SUMMON_PARASITICAL_ROACH = 'xxxx';
// Parasitical Roach
public constant integer UTID_PARASITICAL_ROACH = 'ucs1';
public constant integer SID_PARASITE = 'A0BL';
public constant integer BID_PARASITE = 'A0BM';
// Zombie
public constant integer UTID_ZOMBIE = 'nzom';
public constant integer SID_GNAW = 'A0BK';
// skeletal mage
public constant integer UTID_SKELETAL_MAGE = 'uskm';
public constant integer SID_CURSE_OF_THE_DEAD = 'A0CU';
public constant integer BID_CURSE_OF_THE_DEAD = 'A0CT';
public constant integer SID_DEATH_ORB = 'A0CV';
// Obsdian Statue
public constant integer UTID_OBSIDIAN_CONSTRUCT = 'uobs';
public constant integer BID_REFLECTION_AURA = 'A0BH';
public constant integer SID_MANA_TAP = 'A0BI';
public constant integer BID_MANA_TAP = 'A0BJ';
// Dracolich
public constant integer UTID_DRACOLICH = 'ufro';
public constant integer SID_DEATH_AND_DECAY = 'A0BF';
public constant integer SID_FROST_GRAVE = 'A0BG';

// ## Area 5
// Void Walker
public constant integer UTID_VOID_WALKER = 'n00I';
public constant integer SID_NETHER_BOLT = 'A09N';
public constant integer SID_SHADOW_SHIFT = 'A09O';
// Fel Hound
public constant integer UTID_FEL_HOUND = 'n00J';
public constant integer SID_MANA_BURN = 'A09Q';
// Maid of Agony
public constant integer UTID_MAID_OF_AGONY = 'n00K';
public constant integer SID_SHADOW_SPIKE = 'A09R';
public constant integer BID_SHADOW_SPIKE = 'A0BT';
public constant integer SID_MARK_OF_AGONY = 'A0BU';
public constant integer BID_MARK_OF_AGONY = 'A0BV';
// Nether Drake
public constant integer UTID_NETHER_DRAKE = 'nndr';
public constant integer SID_NETHER_IMPLOSION = 'A0BW';
public constant integer SID_NETHER_BREATH = 'A0BX';
public constant integer BID_NETHER_BREATH = 'A0BY';
// Nether Hatchling
public constant integer UTID_NETHER_HATCHLING = 'nnht';
public constant integer SID_NETHER_SLOW = 'A0BZ';
public constant integer BID_NETHER_SLOW = 'A0C0';
// Inferno Construct
public constant integer UTID_INFERNO_CONSTRUCT = 'ninf';
public constant integer SID_METEOR = 'A0BN';
public constant integer SID_BURNING = 'A0C2';
public constant integer BID_BURNING = 'A0C1';

// ## Area 6
// Forest Troll
public constant integer UTID_FOREST_TROLL = 'n00L';
public constant integer SID_CRUSHING_BLOW = 'A0C3';
public constant integer SID_FOREST_STOMP = 'A0C4';
public constant integer BID_FOREST_STOMP = 'A0C5';
// Cursed Hunter
public constant integer UTID_CURSED_HUNTER = 'ohun';
public constant integer BID_ZEAL = 'A0C6';
// Deranged Priest
public constant integer UTID_DERANGED_PRIEST = 'odoc';
public constant integer SID_CORPSE_RAIN = 'A0C7';
public constant integer SID_VOODOO_DOLL = 'A0C8';
public constant integer SID_VOODOO_DOLL_ILLUSION = 'A0C9';
// Gargantuan
public constant integer UTID_GARGANTUAN = 'u004';
public constant integer SID_SLAM_STRIKE = 'A0CA';
public constant integer SID_VOMIT = 'A0CB';
public constant integer UTID_VOMIT_MAGGOT = 'n00R';
public constant integer BID_VOMIT_MAGGOT_BITE = 'A0CC';
// Twilight Witch Doctor
public constant integer UTID_TWILIGHT_WITCH_DOCTOR = 'ndtp';
public constant integer UTID_GRIM_TOTEM = 'h007';
public constant integer SID_GRIM_TOTEM = 'A0BQ';
public constant integer BID_GRIM_TOTEM = 'A0BR';
public constant integer SID_POISON_DART = 'A0BS';
// Faceless One
public constant integer UTID_FACELESS_ONE = 'nfod';
public constant integer SID_VICIOUS_STRIKE = 'A0CD';
public constant integer BID_VICIOUS_STRIKE = 'A0CE';
public constant integer SID_FILTHY_LAND = 'A0CF';

// test unit type id
public constant integer UTID_DAMAGE_DUMMY = 'e00I';
public constant integer UTID_STATIC_TARGET = 'h000';
public constant integer UTID_TARGET = 'h001';
public constant integer UTID_TANK_TESTER = 'h002';
public constant integer UTID_HEALER_TESTER = 'h003';

// Items
// reforge
public constant integer ITID_REFORGE_UNCOMMON_L1 = 'I01L';
public constant integer ITID_REFORGE_UNCOMMON_L2 = 'I01M';
public constant integer ITID_REFORGE_UNCOMMON_L3 = 'I01V';
public constant integer ITID_REFORGE_RARE_L2 = 'I01R';
public constant integer ITID_REFORGE_RARE_L3 = 'I01U';
public constant integer ITID_REFORGE_LEGENDARY_L3 = 'I01W';
// Scrolls
public constant integer ITID_ARMAGEDDON_SCROLL = 'I003';
public constant integer SID_ARMAGEDDON_SCROLL = 'A070';
public constant integer ITID_WEAKEN_CURSE_SCROLL = 'I00D';
public constant integer SID_WEAKEN_CURSE_SCROLL = 'A07O';

public constant integer ITID_HEAL_SCROLL = 'shea';
public constant integer SID_HEAL_SCROLL = 'A06Z';
public constant integer ITID_SLAYER_SCROLL = 'srrc';
public constant integer SID_SLAYER_SCROLL = 'A074';
public constant integer ITID_SANCTUARY_SCROLL = 'I006';
public constant integer SID_SANCTUARY_SCROLL = 'A076';
public constant integer ITID_BANSHEE_SCROLL = 'I00C';
public constant integer SID_BANSHEE_SCROLL = 'A07M';

public constant integer ITID_ARANS_COUNTER_SPELL_SCROLL = 'Ial0';
public constant integer SID_ARANS_COUNTER_SPELL_SCROLL = 'A06H';
public constant integer ITID_SPEED_SCROLL = 'shas';
public constant integer SID_SPEED_SCROLL = 'A06T';
public constant integer ITID_FRENZY_SCROLL = 'Ifz0';
public constant integer SID_FRENZY_SCROLL = 'A06V';
public constant integer ITID_DEFEND_SCROLL = 'spro';
public constant integer SID_DEFEND_SCROLL = 'A06X';
public constant integer ITID_MANA_SCROLL = 'sman';
public constant integer SID_MANA_SCROLL = 'A06Y';
public constant integer ITID_ROAR_SCROLL = 'sror';
public constant integer SID_ROAR_SCROLL = 'A072';
public constant integer ITID_SPELL_REFLECTION_SCROLL = 'I00M';
public constant integer SID_SPELL_REFLECTION_SCROLL = 'A078';
public constant integer ITID_MASS_DISPEL_SCROLL = 'I017';
public constant integer SID_MASS_DISPEL_SCROLL = 'A07G';
public constant integer ITID_MASS_TELEPORT_SCROLL = 'I002';
public constant integer SID_MASS_TELEPORT_SCROLL = 'A07H';
public constant integer ITID_CORRUPTION_SCROLL = 'I004';
public constant integer SID_CORRUPTION_SCROLL = 'A07I';

// potions
public constant integer ITID_MANA_SOURCE_POTION = 'I00E';
public constant integer SID_MANA_SOURCE_POTION = 'A08J';

public constant integer ITID_ARCH_MAGE_POTION = 'I00J';
public constant integer SID_ARCH_MAGE_POTION = 'A08L';
public constant integer ITID_COMBAT_MASTER_POTION = 'I00N';
public constant integer SID_COMBAT_MASTER_POTION = 'A08M';
public constant integer ITID_SHIELD_POTION = 'I00S';
public constant integer SID_SHIELD_POTION = 'A08P';
public constant integer ITID_FORTRESS_POTION = 'I00V';
public constant integer SID_FORTRESS_POTION = 'A08Q';
public constant integer ITID_INVUL_POTION = 'pnvu';
public constant integer SID_INVUL_POTION = 'A08T';
public constant integer ITID_UNSTABLE_POTION = 'I010';
public constant integer SID_UNSTABLE_POTION = 'A090';

public constant integer ITID_LEECH_POTION = 'I00A';
public constant integer SID_LEECH_POTION = 'A08G';
public constant integer ITID_LIFE_REGEN_POTION = 'I00Q';
public constant integer SID_LIFE_REGEN_POTION = 'A08H';
public constant integer ITID_MANA_REGEN_POTION = 'I00R';
public constant integer SID_MANA_REGEN_POTION = 'A08I';
public constant integer ITID_TRANQUILITY_POTION = 'I00F';
public constant integer SID_TRANQUILITY_POTION = 'A08K';
public constant integer ITID_BIG_LIFE_POTION = 'I00I';
public constant integer SID_BIG_LIFE_POTION = 'A094';
public constant integer ITID_EMPERORS_NEW_POTION = 'I00O';
public constant integer SID_EMPERORS_NEW_POTION = 'A08N';
public constant integer ITID_TRANSFER_POTION = 'I01J';
public constant integer SID_TRANSFER_POTION = 'A08O';
public constant integer ITID_DODGE_POTION = 'I00W';
public constant integer SID_DODGE_POTION = 'A08R';
public constant integer ITID_SMALL_INVUL_POTION = 'pnvl';
public constant integer SID_SMALL_INVUL_POTION = 'A08S';
public constant integer ITID_STONE_SKIN_POTION = 'I008';
public constant integer SID_STONE_SKIN_POTION = 'A08U';
public constant integer ITID_SPELL_POWER_POTION = 'I00B';
public constant integer SID_SPELL_POWER_POTION = 'A08V';
public constant integer ITID_SPELL_MASTER_POTION = 'I00X';
public constant integer SID_SPELL_MASTER_POTION = 'A08W';
public constant integer ITID_ARCANE_POTION = 'I01Q';
public constant integer SID_ARCANE_POTION = 'A08X';
public constant integer ITID_ANGRY_CAST_POTION = 'I007';
public constant integer SID_ANGRY_CAST_POTION = 'A08Y';
public constant integer ITID_SPELL_PIERCE_POTION = 'I00Z';
public constant integer SID_SPELL_PIERCE_POTION = 'A08Z';
public constant integer ITID_AGILITY_POTION = 'I009';
public constant integer SID_AGILITY_POTION = 'A091';
public constant integer ITID_ACUTE_POTION = 'I011';
public constant integer SID_ACUTE_POTION = 'A092';
public constant integer ITID_DEXTERITY_POTION = 'I00Y';
public constant integer SID_DEXTERITY_POTION = 'A093';

public constant integer ITID_LIFE_POTION = 'phea';
public constant integer SID_LIFE_POTION = 'A07P';
public constant integer ITID_MANA_POTION = 'pman';
public constant integer SID_MANA_POTION = 'A07Q';

// Charms
public constant integer ITID_CHARM_OF_CHAIN_LIGHTNING = 'I005';
public constant integer SID_CHARM_OF_CHAIN_LIGHTNING = 'A0A8';
public constant integer ITID_CHARM_OF_DEATH_FINGER = 'I00G';
public constant integer SID_CHARM_OF_DEATH_FINGER = 'A0A9';

public constant integer ITID_CHARM_OF_SIMPLE_HEAL = 'I01I';
public constant integer SID_CHARM_OF_SIMPLE_HEAL = 'A0A4';
public constant integer ITID_CHARM_OF_DISPEL = 'I01G';
public constant integer SID_CHARM_OF_DISPEL = 'A0A5';
public constant integer ITID_CHARM_OF_HEALING_WARD = 'I01F';
public constant integer SID_CHARM_OF_HEALING_WARD = 'A0A6';
public constant integer ITID_CHARM_OF_INNER_FIRE = 'I01E';
public constant integer SID_CHARM_OF_INNER_FIRE = 'A0A7';
public constant integer ITID_CHARM_OF_SIPHON_LIFE = 'I020';
public constant integer SID_CHARM_OF_SIPHON_LIFE = 'A0AA';
public constant integer ITID_DEMONIC_RUNE = 'I012';
public constant integer SID_DEMONIC_RUNE = 'A0AB';
public constant integer ITID_STRANGE_WAND = 'I023';
public constant integer SID_STRANGE_WAND = 'A0AC';

// origin uncommon gear
public constant integer ITID_BELT_OF_GIANT = 'I02B';
public constant integer ITID_BOOTS_OF_QUELTHALAS = 'I02E';
public constant integer ITID_ROBE_OF_MAGI = 'I02C';
public constant integer ITID_CIRCLET_OF_NOBILITY = 'Igh0';
public constant integer ITID_BOOTS_OF_SPEED = 'I000';
public constant integer ITID_HELM_OF_VALOR = 'hval';
public constant integer ITID_MEDALION_OF_COURAGE = 'mcou';
public constant integer ITID_HOOD_OF_CUNNING = 'hcun';
public constant integer ITID_CLAWS_OF_ATTACK = 'Igz0';
public constant integer ITID_GLOVES_OF_HASTE = 'Ijs0';
public constant integer ITID_SWORD_OF_ASSASSINATION = 'Ics0';
public constant integer ITID_VITALITY_PERIAPT = 'Ixp0';
public constant integer ITID_RING_OF_PROTECTION = 'Ish0';
public constant integer ITID_TALISMAN_OF_EVASION = 'Isb0';
public constant integer ITID_MANA_PERIAPT = 'Inl0';
public constant integer ITID_SOBI_MASK = 'Imz0';
public constant integer ITID_MAGIC_BOOK = 'Iwz0';
public constant integer ITID_CRYSTAL_BALL = 'I02D';
public constant integer ITID_LONG_STAFF = 'I02F';
public constant integer ITID_HEALTH_STONE = 'hlst';
public constant integer SID_HEALTH_STONE = 'A06I';
public constant integer ITID_MANA_STONE = 'mnst';
public constant integer SID_MANA_STONE = 'A06J';
public constant integer ITID_ROMULOS_EXPIRED_POISON = 'I00T';
public constant integer SID_ROMULOS_EXPIRED_POISION = 'drxp';
public constant integer ITID_MOROES_LUCKY_GEAR = 'I01H';
public constant integer SID_MOROES_LUCKY_GEAR = 'A06L';
public constant integer BID_MOROES_LUCKY_GEAR = 'A06K';
public constant integer ITID_RUNED_BELT = 'brac';
public constant integer ITID_UNGLAZED_ICON_OF_THE_CRESCENT = 'I01K';
public constant integer SID_ICON_OF_THE_UNGLAZED_CRESCENT = 'A06G';
public constant integer BID_ICON_OF_THE_UNGLAZED_CRESCENT = 'A06F';
// origin rare gear
public constant integer ITID_COLOSSUS_BLADE = 'I01Y';
public constant integer ITID_ARANS_SOOTHING_EMERALD = 'I019';
public constant integer ITID_BULWARK_OF_THE_AMANI_EMPIRE = 'Iams';
public constant integer ITID_CORE_HOUND_TOOTH = 'I015';
public constant integer ITID_ARMOR_OF_THE_DAMNED = 'I00K';
public constant integer BID_ARMOR_OF_THE_DAMNED = 'A06M';
public constant integer ITID_WARSONG_BATTLE_DRUMS = 'I014';
public constant integer BID_AMPLIFIED_DAMAGE = 'A07B';
public constant integer BID_WARSONG_AURA = 'A07C';
public constant integer ITID_GOBLIN_ROCKET_BOOTS_LIMITED_EDITION = 'I013';
public constant integer SID_GOBLIN_ROCKET_BOOTS_LIMITED_EDITION = 'A079';
public constant integer BID_GOBLIN_ROCKET_BOOTS_LIMITED_EDITION = 'A07A';
public constant integer ITID_GOREHOWL = 'I01N';
public constant integer ITID_HEX_SHRUNKEN_HEAD = 'I02I';
public constant integer SID_HEX_SHRUNKEN_HEAD = 'A07F';
public constant integer BID_HEX_SHRUNKEN_HEAD = 'A07E';
public constant integer ITID_LION_HORN = 'I018';
public constant integer BID_LION_HORN = 'A07D';
public constant integer ITID_PURE_ARCANE = 'I00H';
public constant integer SID_PURE_ARCANE = 'dpan';
public constant integer ITID_SIGNET_OF_THE_LAST_DEFENDER = 'I01A';
public constant integer ITID_STAFF_OF_THE_SHADOW_FLAME = 'I01B';
public constant integer ITID_THE_X_RING = 'I012';
public constant integer ITID_TIDAL_LOOP = 'I01C';
public constant integer ITID_TROLL_BANE = 'I022';
public constant integer ITID_VISKAG = 'I016';
// class spec gear
public constant integer ITID_ORB_OF_THE_SINDOREI = 'Isin';
public constant integer ITID_REFORGED_BADGE_OF_TENACITY = 'Idru';
public constant integer SID_REFORGED_BADGE_OF_TENACITY = 'A06B';
public constant integer ITID_LIGHTS_JUSTICE = 'I00U';
public constant integer SID_LIGHTS_JUSTICE = 'A06C';
public constant integer ITID_BENEDICTION = 'Iben';
public constant integer ITID_HORN_OF_CENARIUS = 'Ihor';
public constant integer ITID_BANNER_OF_THE_HORDE = 'Ifla';
public constant integer ITID_KELENS_DAGGER_OF_ASSASSINATION = 'Iass';
public constant integer BID_KELENS_DAGGER_OF_ASSASSINATION = 'A06A';
public constant integer ITID_RHOKDELAR = 'Ihun';
public constant integer ITID_RAGE_WINTERCHILLS_PHYLACTERY = 'Ifro';
public constant integer ITID_ANATHEMA = 'Iana';
public constant integer ITID_RARE_SHIMMER_WEED = 'Ithu';
// legendary
public constant integer ITID_BREATH_OF_THE_DYING = 'I001';
public constant integer BID_BREATH_OF_THE_DYING = 'A063';
public constant integer ITID_CALL_TO_ARMS = 'Icta';
public constant integer SID_CALL_TO_ARMS = 'A069';
public constant integer BID_CALL_TO_ARMS = 'A068';
public constant integer ITID_DERANGEMENT_OF_CTHUN = 'I00L';
public constant integer SID_CTHUNS_DERANGEMENT = 'A06Q';
public constant integer BID_CTHUNS_DERANGEMENT_IAS = 'A0CR';
public constant integer BID_CTHUNS_ACTIVE_IAS = 'A06P';
public constant integer ITID_ENIGMA = 'Ieng';
public constant integer SID_ENIGMA = 'A064';
public constant integer ITID_INFINITY = 'I01P';
public constant integer SID_INFINITY = 'dinf';
public constant integer BID_INFINITY = 'A065';
public constant integer ITID_INSIGHT = 'Iins';
public constant integer BID_INSIGHT = 'A066';
public constant integer ITID_MIGHT_OF_THE_ANGEL_OF_JUSTICE = 'I01D';
public constant integer SID_TYRAELS_MIGHT = 'A07K';
public constant integer ITID_VOODOO_VIALS = 'I00P';
public constant integer SID_VOODOO_VIALS = 'A06N';
public constant integer BID_VOODOO_VIALS = 'A06O';
public constant integer ITID_WOESTAVE = 'Iwoe';
public constant integer BID_DECREASE_MOVESPEED = 'A0CL';
public constant integer BID_DECREASE_ATTACKSPEED = 'A0CM';
public constant integer BID_DECREASE_ARMOR = 'A0CN';
public constant integer BID_DECREASE_ATTACKRATE = 'A0CO';
public constant integer BID_DECREASE_DAMAGEDEALT = 'A0CP';
public constant integer BID_DECREASE_HEALTAKEN = 'A0CQ';
public constant integer ITID_MOONLIGHT_GREATSWORD = 'I02A';
public constant integer ITID_WINDFORCE = 'Iwf0';
// relic set
// Athas's Corruption
public constant integer ITID_DETERMINATION_OF_VENGEANCE = 'I01S';
public constant integer ITID_DETERMINATION_OF_VENGEANCE1 = 'I01R';
public constant integer ITID_STRATHOLME_TRAGEDY = 'I01T';
public constant integer ITID_STRATHOLME_TRAGEDY1 = 'I01U';
public constant integer ITID_PATRICIDE = 'I01X';
public constant integer ITID_PATRICIDE1 = 'I01W';
public constant integer ITID_PATRICIDE2 = 'I01V';
public constant integer ITID_FROSTMOURNE = 'I01O';
public constant integer ITID_FROSTMOURNE1 = 'I01L';
public constant integer ITID_FROSTMOURNE2 = 'I01M';

// Item Attributes
public constant integer IATTR_STR = 4;
public constant integer IATTR_STRPL = 5;
public constant integer IATTR_AGI = 13;
public constant integer IATTR_INT = 14;
public constant integer IATTR_ALLSTAT = 7;
public constant integer IATTR_HP = 21;
public constant integer IATTR_HPPCT = 22;
public constant integer IATTR_HPPL = 23;
public constant integer IATTR_MP = 17;
public constant integer IATTR_AP = 9;
public constant integer IATTR_APPL = 10;
public constant integer IATTR_CRIT = 11;
public constant integer IATTR_IAS = 12;
public constant integer IATTR_SP = 18;
public constant integer IATTR_SCRIT = 20;
public constant integer IATTR_SHASTE = 19;
public constant integer IATTR_DEF = 8;
public constant integer IATTR_DEFPL = 95;
public constant integer IATTR_BR = 16;
public constant integer IATTR_BP = 15;
public constant integer IATTR_DODGE = 27;
public constant integer IATTR_DR = 1;
public constant integer IATTR_MDR = 2;
public constant integer IATTR_AMP = 3;
public constant integer IATTR_HAMP = 6;
public constant integer IATTR_MREG = 72;
public constant integer IATTR_HREG = 73;
public constant integer IATTR_HLOST = 74;
public constant integer IATTR_MS = 24;
public constant integer IATTR_MSPL = 25;
public constant integer IATTR_LP = 26;
public constant integer IATTR_BM_VALOR = 39;
public constant integer IATTR_RG_ONESHOT = 66;
public constant integer IATTR_RG_RUSH = 65;
public constant integer IATTR_CRKILLER = 67;
public constant integer IATTR_MCVT = 68;
public constant integer IATTR_KG_REGRCD = 69;
public constant integer IATTR_LEECHAURA = 71;
public constant integer IATTR_PR_POHDEF = 76;
public constant integer IATTR_DR_MAXHP = 78;
public constant integer IATTR_PL_SHOCK = 79;
public constant integer IATTR_PR_SHIELD = 80;
public constant integer IATTR_CT_PAIN = 81;
public constant integer IATTR_BD_SHIELD = 86;
public constant integer IATTR_RG_PARALZ = 90;
public constant integer IATTR_PL_LIGHT = 91;
public constant integer IATTR_DR_CDR = 92;
public constant integer IATTR_SM_LASH = 93;
public constant integer IATTR_DK_ARROW = 94;
public constant integer IATTR_MG_FDMG = 96;
public constant integer IATTR_MG_BLZ = 70;
public constant integer IATTR_ATK_ML = 43;
public constant integer IATTR_ATK_LL = 44;
public constant integer IATTR_ATK_LLML = 45;
public constant integer IATTR_ATK_CTHUN = 46;
public constant integer IATTR_ATK_WF = 47;
public constant integer IATTR_ATK_LION = 48;
public constant integer IATTR_ATK_MOONWAVE = 49;
public constant integer IATTR_ATK_POISNOVA = 50;
public constant integer IATTR_ATK_COIL = 51;
public constant integer IATTR_ATK_BLEED = 52;
public constant integer IATTR_ATK_MDC = 53;
public constant integer IATTR_ATK_STUN = 54;
public constant integer IATTR_ATK_CRIT = 55;
public constant integer IATTR_ATK_AMP = 56;
public constant integer IATTR_ATK_MD = 57;
public constant integer IATTR_ATK_MDK = 58;
public constant integer IATTR_ATK_MORTAL = 59;
public constant integer IATTR_ATK_MISS = 60;
public constant integer IATTR_ATK_DDEF = 61;
public constant integer IATTR_ATK_DAS = 62;
public constant integer IATTR_ATK_DMS = 63;
public constant integer IATTR_ATK_WEAK = 64;
public constant integer IATTR_3ATK_MOONEXP = 75;
public constant integer IATTR_MD_MREGEN = 87;
public constant integer IATTR_MD_POISON = 88;
public constant integer IATTR_MD_CHAIN = 89;
public constant integer IATTR_MDC_ARCANE = 77;
public constant integer IATTR_DT_MREGEN = 40;
public constant integer IATTR_ATKED_WEAK = 41;
public constant integer IATTR_HEAL_HOLY = 42;
public constant integer IATTR_AURA_CONVIC = 82;
public constant integer IATTR_AURA_MEDITA = 83;
public constant integer IATTR_AURA_WARSONG = 84;
public constant integer IATTR_AURA_UNHOLY = 85;
public constant integer IATTR_USE_TP = 28;
public constant integer IATTR_USE_BATTLE = 29;
public constant integer IATTR_USE_MREGEN = 30;
public constant integer IATTR_USE_HREGEN = 31;
public constant integer IATTR_USE_VOODOO = 32;
public constant integer IATTR_USE_INT = 33;
public constant integer IATTR_USE_SP = 34;
public constant integer IATTR_USE_DODGE = 35;
public constant integer IATTR_USE_MS = 36;
public constant integer IATTR_USE_CTHUN = 37;
public constant integer IATTR_USE_HOLYHEAL = 38;

// Item Affix
public constant integer SUFIX_LETHALITY = 1;
public constant integer SUFIX_SNAKE = 2;
public constant integer SUFIX_QUICKNESS = 3;
public constant integer SUFIX_WIND_SERPENT = 4;
public constant integer SUFIX_BRUTE = 5;
public constant integer SUFIX_DEXTERITY = 6;
public constant integer SUFIX_WISDOM = 7;
public constant integer SUFIX_VITALITY = 8;
public constant integer SUFIX_CHAMPION = 9;
public constant integer SUFIX_BUTCHER = 10;
public constant integer SUFIX_ASSASSIN = 11;
public constant integer SUFIX_RANGER = 12;
public constant integer SUFIX_WIZARD = 13;
public constant integer SUFIX_PRIEST = 14;
public constant integer SUFIX_GUARDIAN = 15;
public constant integer SUFIX_MASTERY = 16;
public constant integer SUFIX_BLUR = 17;
public constant integer SUFIX_STRONGHOLD = 18;
public constant integer SUFIX_DEEP_SEA = 19;
public constant integer SUFIX_VOID = 20;
public constant integer PREFIX_HEAVY = 21;
public constant integer PREFIX_STRONG = 22;
public constant integer PREFIX_SHARP = 23;
public constant integer PREFIX_AGILE = 24;
public constant integer PREFIX_SHIMERING = 25;
public constant integer PREFIX_INTELLIGENT = 26;
public constant integer PREFIX_ENDURABLE = 27;
public constant integer PREFIX_VIBRANT = 28;
public constant integer PREFIX_SKILLED = 29;
public constant integer PREFIX_CRUEL = 30;
public constant integer PREFIX_ENCHANTED = 31;
public constant integer PREFIX_SORCEROUS = 32;
public constant integer PREFIX_MYSTERIOUS = 33;
public constant integer PREFIX_ETERNAL = 34;
public constant integer PREFIX_STEADY = 35;
public constant integer PREFIX_TOUGH = 36;

public constant string ART_ANGEL = "Abilities\\Spells\\Human\\Resurrect\\ResurrectCaster.mdl";
public constant string ART_ANNIHILATION_MISSILE = "Abilities\\Spells\\Undead\\OrbOfDeath\\AnnihilationMissile.mdl";
public constant string ART_ARCANE_TOWER_ATTACK = "Abilities\\Spells\\Human\\Feedback\\ArcaneTowerAttack.mdl";
public constant string ART_BANISH_TARGET = "Abilities\\Spells\\Human\\Banish\\BanishTarget.mdl";
public constant string ART_BLEED = "Objects\\Spawnmodels\\Human\\HumanBlood\\HeroBloodElfBlood.mdl";
public constant string ART_BLINK = "Abilities\\Spells\\NightElf\\Blink\\BlinkTarget.mdl";
public constant string ART_BLIZZARD_TARGET = "Abilities\\Spells\\Human\\Blizzard\\BlizzardTarget.mdl";
public constant string ART_BLOOD_IMPACT = "Abilities\\Weapons\\Blood\\BloodImpact.mdl";
public constant string ART_BLOOD_LUST_LEFT = "Abilities\\Spells\\Orc\\Bloodlust\\BloodlustTarget.mdl";
public constant string ART_BLOOD_LUST_RIGHT = "Abilities\\Spells\\Orc\\Bloodlust\\BloodlustSpecial.mdl";
public constant string ART_BREATH_OF_FROST_MISSILE = "Abilities\\Spells\\Other\\BreathOfFrost\\BreathOfFrostMissile.mdl";
public constant string ART_CRATER = "Objects\\Spawnmodels\\Other\\NeutralBuildingExplosion\\NeutralBuildingExplosion.mdl";
public constant string ART_CURSE = "Abilities\\Spells\\Undead\\Curse\\CurseTarget.mdl";
public constant string ART_DEATH_AND_DECAY = "Abilities\\Spells\\Undead\\DeathandDecay\\DeathandDecayTarget.mdl";
public constant string ART_DISPEL = "Abilities\\Spells\\Human\\DispelMagic\\DispelMagicTarget.mdl";
public constant string ART_DOOM = "Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl";
public constant string ART_DRYAD_MISSILE = "Abilities\\Weapons\\Dryadmissile\\Dryadmissile.mdl";
public constant string ART_DUST = "Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl";
public constant string ART_FREEZING_BREATH = "Abilities\\Spells\\Undead\\FreezingBreath\\FreezingBreathTargetArt.mdl";
public constant string ART_FROST_NOVA = "Abilities\\Spells\\Undead\\FrostNova\\FrostNovaTarget.mdl";
public constant string ART_GORE = "Objects\\Spawnmodels\\Orc\\OrcLargeDeathExplode\\OrcLargeDeathExplode.mdl";
public constant string ART_GREEN_LARGE_FIRE = "Environment\\UndeadBuildingFire\\UndeadLargeBuildingFire0.mdl";
public constant string ART_HEAL = "Abilities\\Spells\\Items\\AIhe\\AIheTarget.mdl";
public constant string ART_HEAL_SALVE = "Abilities\\Spells\\Items\\HealingSalve\\HealingSalveTarget.mdl";
public constant string ART_ILLUSION_TARGET = "Abilities\\Spells\\Items\\AIil\\AIilTarget.mdl";
public constant string ART_IMPACT = "Abilities\\Weapons\\Bolt\\BoltImpact.mdl";
public constant string ART_INFERNAL_BIRTH = "Units\\Demon\\Infernal\\InfernalBirth.mdl";
public constant string ART_INVULNERABLE = "Abilities\\Spells\\Human\\DivineShield\\DivineShieldTarget.mdl";
public constant string ART_MANA = "Abilities\\Spells\\Items\\AIma\\AImaTarget.mdl";
public constant string ART_MANA_DRAIN_TARGET = "Abilities\\Spells\\Other\\Drain\\ManaDrainTarget.mdl";
public constant string ART_MASS_TELEPORT_TARGET = "Abilities\\Spells\\Human\\MassTeleport\\MassTeleportTarget.mdl";
public constant string ART_MEATWAGON_MISSILE = "Abilities\\Weapons\\MeatwagonMissile\\MeatwagonMissile.mdl";
public constant string ART_OBSIDIAN_REGEN_AURA = "Abilities\\Spells\\Undead\\UnholyAura\\UnholyAura.mdl";
public constant string ART_PARASITE_TARGET = "Abilities\\Spells\\Other\\Parasite\\ParasiteTarget.mdl";
public constant string ART_PHOENIX_MISSILE = "Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile.mdl";
public constant string ART_PLAGUE = "units\\undead\\PlagueCloud\\PlagueCloud.mdl";
public constant string ART_POISON = "Abilities\\Weapons\\PoisonSting\\PoisonStingTarget.mdl";
public constant string ART_POISON_SLIME = "Abilities\\Weapons\\ChimaeraAcidMissile\\ChimaeraAcidMissile.mdl";
public constant string ART_RED_IMPACT = "Abilities\\Spells\\Demon\\DemonBoltImpact\\DemonBoltImpact.mdl";
public constant string ART_SHADOW_STRIKE_MISSILE = "Abilities\\Spells\\NightElf\\shadowstrike\\ShadowStrikeMissile.mdl";
public constant string ART_SHADOW_STRIKE_TARGET = "Abilities\\Spells\\NightElf\\shadowstrike\\shadowstrike.mdl";
public constant string ART_SHIELD = "Abilities\\Spells\\Items\\StaffOfSanctuary\\Staff_Sanctuary_Target.mdl";
public constant string ART_SLOW = "Abilities\\Spells\\Human\\slow\\slowtarget.mdl";
public constant string ART_SPELLSTEAL = "Abilities\\Spells\\Human\\SpellSteal\\SpellStealTarget.mdl";
public constant string ART_STAMPEDE_MISSILE_DEATH = "Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl";
public constant string ART_STOMP = "Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl";
public constant string ART_THUNDER_CLAPCASTER = "Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl";
public constant string ART_WATER = "Objects\\Spawnmodels\\Naga\\NagaDeath\\NagaDeath.mdl";
public constant string ART_WISP_EXPLODE = "Units\\NightElf\\Wisp\\WispExplode.mdl";
public constant string ART_MORTAR_MISSILE = "Abilities\\Weapons\\Mortar\\MortarMissile.mdl";
public constant string ART_FAERIE_DRAGON_MISSILE = "Abilities\\Weapons\\FaerieDragonMissile\\FaerieDragonMissile.mdl";
public constant string ART_ANCIENT_PROTECTOR_MISSILE = "Abilities\\Weapons\\AncientProtectorMissile\\AncientProtectorMissile.mdl";
public constant string ART_HOLY_BOLT_SPECIAL_ART = "Abilities\\Spells\\Human\\HolyBolt\\HolyBoltSpecialArt.mdl";
public constant string ART_RESURRECT_TARGET = "Abilities\\Spells\\Human\\Resurrect\\ResurrectTarget.mdl";
public constant string ART_AVENGER_MISSILE = "Abilities\\Weapons\\AvengerMissile\\AvengerMissile.mdl";
public constant string ART_TOME_OF_RETRAINING_CASTER = "Abilities\\Spells\\Items\\TomeOfRetraining\\TomeOfRetrainingCaster.mdl";
public constant string ART_BREATH_OF_FIRE_DAMAGE = "Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl";
public constant string ART_ABOMINATION_EXPLOSION = "Units\\Undead\\Abomination\\AbominationExplosion.mdl";
public constant string ART_CRIPPLE_TARGET = "Abilities\\Spells\\Undead\\Cripple\\CrippleTarget.mdl";
public constant string ART_ROAR_CASTER = "Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl";
public constant string ART_UNHOLY_FRENZY_TARGET = "Abilities\\Spells\\Undead\\UnholyFrenzy\\UnholyFrenzyTarget.mdl";
public constant string ART_VAMPIRIC_AURA = "Abilities\\Spells\\Undead\\VampiricAura\\VampiricAura.mdl";
public constant string ART_BRILLIANCE = "Abilities\\Spells\\Human\\Brilliance\\Brilliance.mdl";
public constant string ART_BOTTLE_MISSILE = "Abilities\\Spells\\Other\\AcidBomb\\BottleMissile.mdl";
public constant string ART_ARROW_MARK = "Abilities\\Spells\\Other\\Aneu\\AneuTarget.mdl";
public constant string ART_BOTTLE_IMPACT = "Abilities\\Spells\\Other\\AcidBomb\\BottleImpact.mdl";
public constant string ART_DRUMS_CASTER_HEAL = "Abilities\\Spells\\Orc\\WarDrums\\DrumsCasterHeal.mdl";
public constant string ART_TORNADO_TARGET = "Abilities\\Spells\\Other\\Tornado\\Tornado_Target.mdl";
public constant string ART_HOWL_TARGET = "Abilities\\Spells\\Other\\HowlOfTerror\\HowlTarget.mdl";
public constant string ART_ELF_EXPLOSION = "Objects\\Spawnmodels\\NightElf\\NEDeathSmall\\NEDeathSmall.mdl";
public constant string ART_INTELLIGENCE = "Abilities\\Spells\\Items\\AIim\\AIimTarget.mdl";
public constant string ART_ROAR_TARGET = "Abilities\\Spells\\NightElf\\BattleRoar\\RoarTarget.mdl";
public constant string ART_DARK_PORTAL_TARGET = "Abilities\\Spells\\Demon\\DarkPortal\\DarkPortalTarget.mdl";
public constant string ART_INNER_FIRE_TARGET = "Abilities\\Spells\\Human\\InnerFire\\InnerFireTarget.mdl";
public constant string ART_ENT_BIRTH_TARGET = "Objects\\Spawnmodels\\NightElf\\EntBirthTarget\\EntBirthTarget.mdl";
public constant string ART_KEEPER_GROVE_MISSILE = "Abilities\\Weapons\\KeeperGroveMissile\\KeeperGroveMissile.mdl";
public constant string ART_ANTI_MAGIC_SHELL = "Abilities\\Spells\\Undead\\AntiMagicShell\\AntiMagicShell.mdl";
public constant string ART_SKELETAL_MAGE_MISSILE = "Abilities\\Weapons\\SkeletalMageMissile\\SkeletalMageMissile.mdl";
public constant string ART_DEATH_COIL_MISSILE = "Abilities\\Spells\\Undead\\DeathCoil\\DeathCoilMissile.mdl";
public constant string ART_DEATH_COIL_SPECIAL_ART = "Abilities\\Spells\\Undead\\DeathCoil\\DeathCoilSpecialArt.mdl";
public constant string ART_RAISE_SKELETON = "Abilities\\Spells\\Undead\\RaiseSkeletonWarrior\\RaiseSkeleton.mdl";
public constant string ART_FLAME_STRIKE_TARGET = "Abilities\\Spells\\Human\\FlameStrike\\FlameStrikeTarget.mdl";
public constant string ART_DarkSummonTarget = "Abilities\\Spells\\Undead\\Darksummoning\\DarkSummonTarget.mdl";
public constant string ART_SpellStealMissile = "Abilities\\Spells\\Human\\SpellSteal\\SpellStealMissile.mdl";
public constant string ART_Progressbar = "Progressbar.mdl";
public constant string ART_SpiritOfVengeanceMissile = "Abilities\\Weapons\\SpiritOfVengeanceMissile\\SpiritOfVengeanceMissile.mdl";
public constant string ART_IllidanMissile = "Abilities\\Weapons\\IllidanMissile\\IllidanMissile.mdl";
public constant string ART_FarseerMissile = "Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl";
public constant string ART_CloudOfFog = "Abilities\\Spells\\Human\\CloudOfFog\\CloudOfFog.mdl";
public constant string ART_ManaFlareBoltImpact = "Abilities\\Spells\\Human\\ManaFlare\\ManaFlareBoltImpact.mdl";
public constant string ART_PurgeBuffTarget = "Abilities\\Spells\\Orc\\Purge\\PurgeBuffTarget.mdl";
public constant string ART_SpellShieldCaster = "Abilities\\Spells\\Items\\SpellShieldAmulet\\SpellShieldCaster.mdl";
public constant string ART_ThornsAuraDamage = "Abilities\\Spells\\NightElf\\ThornsAura\\ThornsAuraDamage.mdl";
public constant string ART_DemolisherFireMissile = "Abilities\\Weapons\\DemolisherFireMissile\\DemolisherFireMissile.mdl";
public constant string ART_Liquidfire = "Abilities\\Spells\\Orc\\LiquidFire\\Liquidfire.mdl";
public constant string ART_Owl = "Units\\NightElf\\Owl\\Owl.mdl";
public constant string ART_InvisibilityTarget = "Abilities\\Spells\\Human\\Invisibility\\InvisibilityTarget.mdl";
public constant string ART_RejuvenationTarget = "Abilities\\Spells\\NightElf\\Rejuvenation\\RejuvenationTarget.mdl";
public constant string ART_ReplenishHealthCasterOverhead = "Abilities\\Spells\\Undead\\ReplenishHealth\\ReplenishHealthCasterOverhead.mdl";
public constant string ART_ClarityTarget = "Abilities\\Spells\\Items\\ClarityPotion\\ClarityTarget.mdl";
public constant string ART_Tranquility = "Abilities\\Spells\\NightElf\\Tranquility\\Tranquility.mdl";

public constant string BTNVolcano = "ReplaceableTextures\\CommandButtons\\BTNVolcano.blp";
public constant string BTNEarthquake = "ReplaceableTextures\\CommandButtons\\BTNEarthquake.blp";
public constant string BTNInnerFire = "ReplaceableTextures\\CommandButtons\\BTNInnerFire.blp";
public constant string BTNResurrection = "ReplaceableTextures\\CommandButtons\\BTNResurrection.blp";
public constant string BTNExecute0 = "ReplaceableTextures\\CommandButtons\\BTNExecute0.blp";
public constant string BTNExecute1 = "ReplaceableTextures\\CommandButtons\\BTNExecute1.blp";
public constant string BTNExecute2 = "ReplaceableTextures\\CommandButtons\\BTNExecute2.blp";
public constant string BTNExecute3 = "ReplaceableTextures\\CommandButtons\\BTNExecute3.blp";
public constant string BTNExecute4 = "ReplaceableTextures\\CommandButtons\\BTNExecute4.blp";
public constant string BTNCleavingAttack = "ReplaceableTextures\\CommandButtons\\BTNCleavingAttack.blp";
public constant string BTNPossession = "ReplaceableTextures\\CommandButtons\\BTNPossession.blp";
public constant string BTNUnholyFrenzy = "ReplaceableTextures\\CommandButtons\\BTNUnholyFrenzy.blp";
}
//! endzinc
