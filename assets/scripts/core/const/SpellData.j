//! zinc
library SpellData requires Table, Integer {
//==============================================================================
//  Constants:
//              ORDER_TYPE_IMMEDIATE
//              ORDER_TYPE_TARGET
//              ORDER_TYPE_POINT
//  SpellData:
//              string:     name
//              real:       cost
//              real:       cast
//              real:       cd
//              integer：   otp // order type
//              integer:    oid // order id
//      static  SpellData:  [integer spellId]
//==============================================================================
    public struct SpellData {
        private static Table db;
        real cost, cast, cd;
        real cost2, cast2, cd2;
        real cost3, cast3, cd3;
        integer otp; // order type
        integer oid; // order id
        string name;
        integer level;
        integer sid;
    
        static method inst(integer sid, string trace) -> SpellData {
            if (SpellData.db.exists(sid)) {
                return SpellData(SpellData.db[sid]);
            } else {
                print(SCOPE_PREFIX+" Unknown spell ID: " + ID2S(sid) + ", trace: " + trace);
                return 0;
            }
        }
        
        method setCCC2(real cost, real cast, real cd) -> thistype {
            this.cost2 = cost;
            this.cast2 = cast;
            this.cd2 = cd;
            return this;
        }
        
        method setCCC3(real cost, real cast, real cd) -> thistype {
            this.cost3 = cost;
            this.cast3 = cast;
            this.cd3 = cd;
            return this;
        }
        
        method Cost(integer lvl) -> real {
            if (lvl == 1) {
                return this.cost;
            } else if (lvl == 2) {
                return this.cost2;
            } else {
                return this.cost3;
            }
        }
        
        method Cast(integer lvl) -> real {
            if (lvl == 1) {
                return this.cast;
            } else if (lvl == 2) {
                return this.cast2;
            } else {
                return this.cast3;
            }
        }
        
        method CD(integer lvl) -> real {
            if (lvl == 1) {
                return this.cd;
            } else if (lvl == 2) {
                return this.cd2;
            } else {
                return this.cd3;
            }
        }
        
        private static method create(integer sid, string name, real cost, real cast, real cd, integer oid, integer level, integer otp) -> thistype {
            thistype this = thistype.allocate();
            thistype.db[sid] = this;
            this.sid = sid;
            this.cost = cost;
            this.cost2 = cost;
            this.cost3 = cost;
            this.cast = cast;
            this.cast2 = cast;
            this.cast3 = cast;
            this.cd = cd;
            this.cd2 = cd;
            this.cd3 = cd;
            this.oid = oid;
            this.otp = otp;
            this.level = level;
            this.name = name;
            return this;
        }
    
        private static method onInit() {
            thistype.db = Table.create();
            //:template.id = spellmeta
            //:template.indentation = 3
            SpellData.create(0,"Dummy",0,0,0,0,1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_ATTACK_LL,"Attack LL",0,0,1,0,1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_EXTRA_MAGIC_DAMAGE,"Extra Magic Damage",0,0,0,0,1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_GENERAL_STUN,"General Stun",0,0,1,0,1,ORDER_TYPE_TARGET);
            SpellData.create(SID_HAUNT,"Haunt",0,0,5,852581,1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_HEAL_TESTER,"Heal Tester",0,0,5,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_CHAMPION_THORNS,"Champion Thorns",0,0,0,0,1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_SHIELD_BLOCK,"Shield Block",30,0,7,852055,1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_SUN_FIRE_STORM,"Sun Fire Storm",20,0,8,852488,1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_ARCANE_SHOCK,"Arcane Shock",10,0,2,852480,1,ORDER_TYPE_TARGET).setCCC2(17,0,2).setCCC3(24,0,2);
            SpellData.create(SID_DISCORD,"Discord",0,0,14,852128,1,ORDER_TYPE_TARGET).setCCC2(0,0,12).setCCC3(0,0,10);
            SpellData.create(SID_SHIELD_OF_SINDOREI,"Shield of Sindorei",0,0,30,852090,1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_LACERATE,"Lacerate",0,0,1.5,OrderId("coldarrowstarg"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_SAVAGE_ROAR,"Savage Roar",0,0,5,OrderId("purge"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_FOREST_CURE,"Forest Cure",0,0,1,OrderId("deathcoil"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_NATURAL_REFLEX,"Natural Reflex",0,0,15,OrderId("dispel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_SURVIVAL_INSTINCTS,"Survival Instincts",0,0,60,OrderId("cripple"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_LIFE_BLOOM,"Life Bloom",50,0,1,OrderId("cripple"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_REJUVENATION,"Rejuvenation",75,0,1,OrderId("rejuvination"),1,ORDER_TYPE_TARGET).setCCC2(110,0,1).setCCC3(145,0,1);
            SpellData.create(SID_REGROWTH,"Regrowth",100,3,0,OrderId("healingwave"),1,ORDER_TYPE_TARGET).setCCC2(120,3,0).setCCC3(140,3,0);
            SpellData.create(SID_SWIFT_MEND,"Swift Mend",150,0,11,OrderId("replenishlife"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_TRANQUILITY,"Tranquility",200,8,40,OrderId("tranquility"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_TRANQUILITY_1,"Tranquility 1",200,8,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_FLASH_LIGHT,"Flash Light",50,0,3.5,OrderId("innerfire"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_HOLY_LIGHT,"Holy Light",100,2.6,0,OrderId("holybolt"),1,ORDER_TYPE_TARGET).setCCC2(115,2.6,0).setCCC3(130,2.6,0);
            SpellData.create(SID_HOLY_SHOCK,"Holy Shock",100,0,15,OrderId("resurrection"),1,ORDER_TYPE_TARGET).setCCC2(150,0,15).setCCC3(200,0,15);
            SpellData.create(SID_DIVINE_FAVOR,"Divine Favor",50,0,40,OrderId("massteleport"),1,ORDER_TYPE_IMMEDIATE).setCCC2(50,0,40).setCCC3(50,0,40);
            SpellData.create(SID_BEACON_OF_LIGHT,"Beacon of Light",10,0,10,OrderId("summonphoenix"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_HEAL,"Heal",75,0,1,852063,1,ORDER_TYPE_TARGET).setCCC2(100,0,1).setCCC3(125,0,1);
            SpellData.create(SID_PRAYER_OF_HEALING,"Prayer of Healing",100,2.4,0,OrderId("blizzard"),1,ORDER_TYPE_POINT).setCCC2(100,2.1,0).setCCC3(100,1.8,0);
            SpellData.create(SID_SHIELD,"Shield",100,0,4,852055,1,ORDER_TYPE_TARGET).setCCC2(125,0,4).setCCC3(150,0,4);
            SpellData.create(BID_SHIELD,"Shield",0,0,0,1,1,ORDER_TYPE_TARGET);
            SpellData.create(SID_PRAYER_OF_MENDING,"Prayer of Mending",75,0,9,852075,1,ORDER_TYPE_TARGET).setCCC2(85,0,7).setCCC3(95,0,5);
            SpellData.create(SID_DISPEL,"Dispel",45,0,3,852057,1,ORDER_TYPE_TARGET).setCCC2(60,0,3).setCCC3(75,0,3);
            SpellData.create(SID_DARK_ARROW,"Dark Arrow",4,0,5,OrderId("thunderbolt"),1,ORDER_TYPE_TARGET).setCCC2(5,0,5).setCCC2(6,0,5);
            SpellData.create(SID_CONCERNTRATION,"Concerntration",0,0,13,OrderId("thunderclap"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_FREEZING_TRAP,"Freezing Trap",0,0,16,OrderId("blizzard"),1,ORDER_TYPE_POINT).setCCC2(0,0,13).setCCC3(0,0,10);
            SpellData.create(SID_POWER_OF_BANSHEE,"Power of Banshee",0,0,1,OrderId("howlofterror"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_DEATH_PACT,"Death Pact",0,0,5,OrderId("stomp"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_SUMMON_GHOUL,"Summon Ghoul",50,0,60,OrderId("voodoo"),1,ORDER_TYPE_IMMEDIATE).setCCC2(0,0,45).setCCC3(0,0,30);
            SpellData.create(SID_LIFE_LEECH,"Life Leech",0,0,1,0,1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_HEROIC_STRIKE,"Heroic Strike",0,0,1,OrderId("roar"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_REND,"Rend",0,0,6,OrderId("whirlwind"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_OVER_POWER,"Over Power",0,0,3.5,OrderId("windwalk"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_MORTAL_STRIKE,"Mortal Strike",15,0,9,OrderId("drunkenhaze"),1,ORDER_TYPE_TARGET).setCCC2(25,0,8).setCCC3(35,0,7);
            SpellData.create(SID_EXECUTE,"Execute",0,0,1,OrderId("slow"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_FROST_BOLT,"Frost Bolt",15,2,0,OrderId("heal"),1,ORDER_TYPE_TARGET).setCCC2(30,2,0).setCCC3(45,2,0);
            SpellData.create(SID_BLIZZARD,"Blizzard",100,0,10,OrderId("blizzard"),1,ORDER_TYPE_POINT).setCCC2(135,0,10).setCCC3(170,0,10);
            SpellData.create(SID_FROST_NOVA,"Frost Nova",50,0,15,OrderId("frostnova"),1,ORDER_TYPE_IMMEDIATE).setCCC2(50,0,15).setCCC3(50,0,12);
            SpellData.create(SID_POLYMORPH,"Polymorph",25,0,30,OrderId("polymorph"),1,ORDER_TYPE_TARGET).setCCC2(25,0,22).setCCC3(25,0,14);
            SpellData.create(SID_POLYMORPH_DUMMY,"Polymorph dummy",25,0,5,OrderId("hex"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_SPELL_TRANSFER,"Spell Transfer",25,0,6,OrderId("dispel"),1,ORDER_TYPE_TARGET).setCCC2(25,0,3).setCCC3(25,0,1);
            SpellData.create(SID_SPELL_CHANNEL,"Spell Channel",15,0,2,OrderId("channel"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_STORM_LASH,"Storm Lash",10,2,0,OrderId("forkedlightning"),1,ORDER_TYPE_TARGET).setCCC2(13,2,0).setCCC3(16,2,0);
            SpellData.create(SID_EARTH_SHOCK,"Earth Shock",85,0,9,OrderId("thunderbolt"),1,ORDER_TYPE_TARGET).setCCC2(95,0,9).setCCC3(105,0,9);
            SpellData.create(SID_PURGE,"Purge",15,0,15,OrderId("purge"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_ENCHANTED_TOTEM,"Enchanted Totem",0,0,1,OrderId("healingward"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_LIGHTNING_TOTEM,"Lightning Totem",0,0,10,OrderId("blizzard"),1,ORDER_TYPE_POINT);
            SpellData.create(SID_TORRENT_TOTEM,"Torrent Totem",0,0,10,OrderId("flamestrike"),1,ORDER_TYPE_POINT);
            SpellData.create(SID_EARTH_BIND_TOTEM,"Earth Bind Totem",0,0,10,OrderId("dispel"),1,ORDER_TYPE_POINT);
            SpellData.create(SID_ASCENDANCE,"Ascendance",25,0,40,OrderId("metamorphosis"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_SINISTER_STRIKE,"Sinister Strike",0,0,2,OrderId("slow"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_EVISCERATE,"Eviscerate",0,0,2,OrderId("impale"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_ASSAULT,"Assault",0,0,16,OrderId("deathcoil"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_BLADE_FLURRY,"Blade Flurry",0,0,30,OrderId("starfall"),1,ORDER_TYPE_IMMEDIATE).setCCC2(0,0,26).setCCC2(0,0,22);
            SpellData.create(SID_STEALTH,"Stealth",0,0,45,OrderId("cyclone"),1,ORDER_TYPE_IMMEDIATE).setCCC2(0,0,35).setCCC2(0,0,25);
            SpellData.create(SID_GARROTE,"Garrote",0,0,1,OrderId("shadowstrike"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_AMBUSH,"Ambush",0,0,1,OrderId("thunderbolt"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_PAIN,"Pain",100,0,2,OrderId("slow"),1,ORDER_TYPE_TARGET).setCCC2(115,0,2).setCCC3(130,0,2);
            SpellData.create(SID_MARROW_SQUEEZE,"Marrow Squeeze",70,2.3,0,OrderId("dispel"),1,ORDER_TYPE_TARGET).setCCC2(130,2.0,0).setCCC3(190,1.7,0);
            SpellData.create(SID_MIND_FLAY,"Mind Flay",50,3,0,OrderId("heal"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_DEATH,"Death",0,0,7,OrderId("innerfire"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_TERROR,"Terror",75,0,12,OrderId("unholyfrenzy"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_FRENZY_CREEP,"Frenzy Creep",0,0,200,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_RAGE_CREEP,"Rage Creep",0,0,200,OrderId("charm"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_GRIP_OF_STATIC_ELECTRICITY,"Grip of Static Electricity",0,0,1,OrderId("healingwave"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_PULSE_BOMB,"Pulse Bomb",0,0,10,OrderId("charm"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_LASER_BEAM,"Laser Beam",0,10,25,OrderId("heal"),2,ORDER_TYPE_TARGET);
            SpellData.create(SID_TINKER_MORPH,"Tinker Morph",0,0,0,OID_BEARFORM,1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_LIGHTNING_SHIELD,"Lightning Shield",0,0,1,OrderId("lightningshield"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_POCKET_FACTORY,"Pocket Factory",0,0,10,OrderId("summonfactory"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_SUMMON_CLOCKWORK_GOBLIN,"Summon Clockwork Goblin",0,4,1,OrderId("summonfactory"),2,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_SELF_DESTRUCT,"Self Destruct",0,3,1,OrderId("slow"),2,ORDER_TYPE_TARGET);
            SpellData.create(SID_CLUSTER_ROCKETS,"Cluster Rockets",0,1,1,OrderId("clusterrockets"),2,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_FUCKED_LIGHTNING,"Fucked Lightning",100,0,7,852063,1,ORDER_TYPE_TARGET);
            SpellData.create(SID_STRONG_BREEZE,"Strong Breeze",100,0,14,852555,1,ORDER_TYPE_TARGET);
            SpellData.create(SID_SUMMON_SERPENTS,"Summon Serpents",100,0,30,852066,1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_THUNDER_STORM,"Thunder Storm",0,10,40,852069,2,ORDER_TYPE_TARGET);
            SpellData.create(SID_ALKALINE_WATER,"Alkaline Water",0,3.5,5,OrderId("heal"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_TIDE,"Tide",0,0,12,OrderId("slow"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_TIDE_BARON_MORPH,"Tide Baron Morph",0,0,35,OID_BEARFORM,1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_TEAR_UP,"Tear Up",0,0,12,OrderId("slow"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_LANCINATE,"Lancinate",0,0,15,OrderId("channel"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_RASPY_ROAR,"Raspy Roar",0,0,25,OrderId("impale"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_RASPY_ROAR_DUMMY,"Raspy Roar DUMMY",0,0,1,OrderId("silence"),1,ORDER_TYPE_POINT);
            SpellData.create(SID_FLAME_THROW,"Flame Throw",100,0,5,OrderId("sleep"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_FLAME_BOMB,"Flame Bomb",100,10,40,OrderId("slow"),2,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_SUMMON_LAVA_SPAWN,"Summon Lava Spawn",100,10,30,OrderId("soulburn"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_FRENZY_WARLOCK,"Frenzy Warlock",0,0,200,OrderId("stomp"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_IMPALE,"Impale",0,0,20,OrderId("impale"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_SUMMON_POISONOUS_CRAWLER,"Summon Poisonous Crawler",0,0,25,OrderId("slow"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_SUMMON_ABOMINATION,"Summon Abomination",0,0,20,OrderId("charm"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_SUMMON_WRAITH,"Summon Wraith",0,0,20,OrderId("invisibility"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_LIFE_SIPHON,"Life Siphon",0,5,30,OrderId("sleep"),2,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_FEL_EXECUTION,"Fel Execution",0,0,20,OrderId("sleep"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_POWER_SLASH,"Power Slash",0,0,10,OrderId("purge"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_FEL_FRENZY,"Fel Frenzy",0,0,20,OrderId("howlofterror"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_POWER_SHADOW_SHIFT,"Power Shadow Shift",0,4,8,OrderId("slow"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_SHADOW_DETONATION,"Shadow Detonation",0,0,15,OrderId("blizzard"),1,ORDER_TYPE_POINT);
            SpellData.create(SID_SOUL_LINK,"Soul Link",0,0,1,OrderId("charm"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_SPIRIT_BOLT,"Spirit Bolt",50,10,40,OrderId("heal"),2,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_SPIRIT_HARVEST,"Spirit Harvest",0,0,35,OrderId("hex"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_SUN_FIRE_STORMHEX,"Sun fire Stormhex",100,0,10,OrderId("slow"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_SHIELD_OF_SINDOREIHEX,"Shield of Sindoreihex",0,0,10,OrderId("sleep"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_SAVAGE_ROAR_HEX,"Savage Roar hex",0,0,10,OrderId("sleep"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_NATURAL_REFLEX_HEX,"Natural Reflex hex",0,0,12,OrderId("slow"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_TRANQUILITY_HEX,"Tranquility hex",100,8,10,OrderId("slow"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_LIFE_BLOOMHEX,"Life Bloomhex",25,0,10,OrderId("sleep"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_HOLY_BOLT_HEX,"Holy Bolt hex",100,4,10,OrderId("slow"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_HOLY_SHOCK_HEX,"Holy Shock hex",50,0,10,OrderId("sleep"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_HEAL_HEX,"Heal hex",50,0,10,OrderId("slow"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_SHIELD_HEX,"Shield hex",100,0,10,OrderId("sleep"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_MORTAL_STRIKE_HEX,"Mortal Strike hex",0,0,10,OrderId("slow"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_OVER_POWER_HEX,"Over power hex",0,0,7,OrderId("sleep"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_DARK_ARROW_HEX,"Dark Arrow hex",0,0,4,OrderId("slow"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_FREEZING_TRAP_HEX,"Freezing Trap hex",0,0,10,OrderId("sleep"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_FROST_BOLT_HEX,"Frost Bolt hex",50,3,5,OrderId("slow"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_POLYMORPH_HEX,"Polymorph hex",50,0,10,OrderId("sleep"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_LIGHTNING_TOTEM_HEX,"Lightning Totem hex",0,0,10,OrderId("slow"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_CHARGE_HEX,"Charge hex",100,0,15,OrderId("sleep"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_STEALTH_HEX,"Stealth hex",0,0,15,OrderId("slow"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_STEALTH_AMBUSH_HEX,"Stealth Ambush hex",0,0,1,OrderId("stomp"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_BLADE_FLURRY_HEX,"Blade Flurry hex",0,0,10,OrderId("sleep"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_PAIN_HEX,"Pain hex",100,0,15,OrderId("slow"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_TERROR_HEX,"Terror hex",100,0,10,OrderId("sleep"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_FIRE_BOLT,"Fire Bolt",0,1,1,OrderId("roar"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_FIRE_NOVA,"Fire Nova",0,2,10,OrderId("roar"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_PSYCHIC_WAIL,"Psychic Wail",0,0,1,OrderId("roar"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_FAST_HEAL,"Fast Heal",0,1.5,1,OrderId("slow"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_SLUG,"Slug",0,0,0,OrderId("roar"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_COLD_GAZE,"Cold Gaze",0,0,10,OrderId("slow"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_ANNIHILATION,"annihilation",0,0,0,OrderId("roar"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_MIND_BLAST,"mind blast",0,0,15,OrderId("blizzard"),1,ORDER_TYPE_POINT);
            SpellData.create(SID_SUMMON_UNHOLY_TENTACLES,"summon unholy tentacles",0,0,40,OrderId("howlofterror"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_TELEPORT_PLAYERS,"teleport players",0,0,20,OrderId("divineshield"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_SUMMON_FILTHY_TENTACLE,"summon filthy tentacle",0,0,40,OrderId("resurrection"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_PSYCHIC_LINK,"psychic link",0,0,40,OrderId("thunderclap"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_SUMMON_VICIOUS_TENTACLE,"summon vicious tentacle",0,0,40,OrderId("stomp"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_EYE_BEAM,"eye beam",0,18,50,OrderId("tranquility"),2,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_SUMMON_FOUL_TENTACLE,"summon foul tentacle",0,0,40,OrderId("fanofknives"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_LUNATIC_GAZE,"lunatic gaze",0,8,30,OrderId("starfall"),2,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_SUMMON_ETERNAL_GUARDIAN,"summon eternal guardian",0,0,20,OrderId("summonphoenix"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_STING,"Sting",0,0,1,0,1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_LIGHTNING_BOLT,"Lightning Bolt",75,3,2,OrderId("heal"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_FROST_SHOCK,"Frost Shock",0,0,8,OrderId("freezingbreath"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_CHAIN_HEALING,"Chain Healing",200,3,5,OrderId("healingwave"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_HEALING_WARD,"Healing Ward",100,0,15,OrderId("healingward"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_PROTECTION_WARD,"Protection Ward",100,0,30,OrderId("evileye"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_CHARGED_BREATH,"Charged Breath",0,0,5,OrderId("heal"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_MANA_LEECH,"Mana Leech",0,0,5,OrderId("healingwave"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_NAGA_FRENZY,"Naga Frenzy",0,0,20,OrderId("unholyfrenzy"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_ARMOR_CRUSHING,"Armor Crushing",0,0,20,OrderId("sleep"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_THUNDER_CLAP,"Thunder Clap",0,0,12,OrderId("thunderclap"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_RAGE_ROAR,"Rage Roar",0,0,20,OrderId("slow"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_BLOOD_BOIL,"Blood Boil",0,0,20,OrderId("howlofterror"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_UNHOLY_FRENZY,"Unholy Frenzy",0,0,12,OrderId("sleep"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_CHAOS_LEAP,"Chaos Leap",0,0,20,OrderId("sleep"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_WAR_STOMP,"War Stomp",0,4,8,OrderId("sleep"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_BATTLE_COMMAND,"Battle Command",0,0,6,OrderId("slow"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_BLAZING_HASTE,"Blazing Haste",75,0,5,OrderId("heal"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_FIRE_BALL,"Fire Ball",100,3,1,OrderId("sleep"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_FLAME_SHOCK,"Flame Shock",50,0,5,OrderId("slow"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_SMOLDER,"Smolder",0,1,0,OrderId("howlofterror"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_SUMMON_PARASITICAL_ROACH,"Summon Parasitical Roach",0,0,15,OrderId("howlofterror"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_PARASITE,"Parasite",0,0,0,0,1,ORDER_TYPE_TARGET);
            SpellData.create(SID_GNAW,"Gnaw",0,5,0,OrderId("sleep"),2,ORDER_TYPE_TARGET);
            SpellData.create(SID_CURSE_OF_THE_DEAD,"Curse of the Dead",0,0,15,OrderId("sleep"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_DEATH_ORB,"Death Orb",0,3,0,OrderId("slow"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_MANA_TAP,"Mana Tap",0,0,13,OrderId("sleep"),1,ORDER_TYPE_POINT);
            SpellData.create(SID_FROST_GRAVE,"Frost Grave",0,0,8,OrderId("sleep"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_DEATH_AND_DECAY,"Death and Decay",0,0,8,OrderId("heal"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_NETHER_BOLT,"Nether Bolt",0,0,7,OrderId("sleep"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_SHADOW_SHIFT,"Shadow Shift",0,0,5,OrderId("slow"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_MANA_BURN,"Mana Burn",0,0,7,OrderId("sleep"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_SHADOW_SPIKE,"Shadow Spike",0,0,5,OrderId("sleep"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_MARK_OF_AGONY,"Mark of Agony",0,0,15,OrderId("slow"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_NETHER_IMPLOSION,"Nether Implosion",0,4,12,OrderId("roar"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_NETHER_BREATH,"Nether Breath",0,0,9,OrderId("howlofterror"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_NETHER_SLOW,"Nether Slow",0,0,7,OrderId("slow"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_METEOR,"Meteor",0,0,7,OrderId("blizzard"),1,ORDER_TYPE_POINT);
            SpellData.create(SID_BURNING,"Burning",0,0,20,OrderId("roar"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_CRUSHING_BLOW,"Crushing Blow",0,2,6,OrderId("sleep"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_FOREST_STOMP,"Forest Stomp",0,0,12,OrderId("roar"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_CORPSE_RAIN,"Corpse Rain",0,0,12,OrderId("slow"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_VOODOO_DOLL,"Voodoo Doll",0,0,20,OrderId("sleep"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_VOODOO_DOLL_ILLUSION,"Voodoo Doll illusion",0,0,0,852274,1,ORDER_TYPE_TARGET);
            SpellData.create(SID_SLAM_STRIKE,"Slam Strike",0,0,0,OrderId("roar"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_VOMIT,"Vomit",0,4,0,OrderId("howlofterror"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_POISON_DART,"Poison Dart",0,0,4,OrderId("sleep"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_GRIM_TOTEM,"Grim Totem",0,0,8,OrderId("healingward"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_VICIOUS_STRIKE,"Vicious Strike",0,0,12,OrderId("sleep"),1,ORDER_TYPE_TARGET);
            SpellData.create(SID_FILTHY_LAND,"Filthy Land",0,0,18,OrderId("roar"),1,ORDER_TYPE_POINT);
            SpellData.create(SID_CALL_TO_ARMS,"Call To Arms",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_CTHUNS_DERANGEMENT,"Cthuns Derangement",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(BID_BREATH_OF_THE_DYING,"Breath of the Dying",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_INFINITY,"Infinity",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_ENIGMA,"Enigma",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_PURE_ARCANE,"Pure Arcane",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_GOBLIN_ROCKET_BOOTS_LIMITED_EDITION,"Goblin Rocket Boots LIMITED EDITION",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_HEALTH_STONE,"Health Stone",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_MANA_STONE,"Mana Stone",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_HEX_SHRUNKEN_HEAD,"Hex Shrunken Head",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_ICON_OF_THE_UNGLAZED_CRESCENT,"Icon of the Unglazed Crescent",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_LIGHTS_JUSTICE,"Lights Justice",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_ROMULOS_EXPIRED_POISION,"Romulos Expired Poision",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_MOROES_LUCKY_GEAR,"Moroes Lucky Gear",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_REFORGED_BADGE_OF_TENACITY,"Reforged Badge of Tenacity",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_TYRAELS_MIGHT,"Tyraels Might",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_VOODOO_VIALS,"Voodoo Vials",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_MOONLIGHT_GREATSWORD_EXPLOSION,"Moonlight Greatsword Explosion",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_MOONLIGHT_GREATSWORD_BURST,"Moonlight Greatsword Burst",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(BID_BLEED,"Bleed",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_LEECH_AURA,"Leech Aura",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(BID_ATK_DEATH_COIL,"ATK Death Coil",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_UNHOLY_AURA,"Unholy Aura",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_ARMAGEDDON_SCROLL,"Armageddon Scroll",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_ARANS_COUNTER_SPELL_SCROLL,"Arans Counter Spell Scroll",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_BANSHEE_SCROLL,"Banshee Scroll",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_CORRUPTION_SCROLL,"Corruption Scroll",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_DEFEND_SCROLL,"Defend Scroll",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_FRENZY_SCROLL,"Frenzy Scroll",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_HEAL_SCROLL,"Heal Scroll",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_MANA_SCROLL,"Mana Scroll",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_MASS_DISPEL_SCROLL,"Mass Dispel Scroll",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_MASS_TELEPORT_SCROLL,"Mass Teleport Scroll",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_ROAR_SCROLL,"Roar Scroll",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_SANCTUARY_SCROLL,"Sanctuary Scroll",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_SLAYER_SCROLL,"Slayer Scroll",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_SPEED_SCROLL,"Speed Scroll",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_SPELL_REFLECTION_SCROLL,"Spell Reflection Scroll",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_WEAKEN_CURSE_SCROLL,"Weaken Curse Scroll",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_LIFE_POTION,"Life Potion",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_MANA_POTION,"Mana Potion",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_LEECH_POTION,"Leech Potion",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_LIFE_REGEN_POTION,"Life Regen Potion",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_MANA_REGEN_POTION,"Mana Regen Potion",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_MANA_SOURCE_POTION,"Mana Source Potion",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_TRANQUILITY_POTION,"Tranquility Potion",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_BIG_LIFE_POTION,"Big Life Potion",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_ARCH_MAGE_POTION,"Arch Mage Potion",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_COMBAT_MASTER_POTION,"Combat Master Potion",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_EMPERORS_NEW_POTION,"Emperors New Potion",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_TRANSFER_POTION,"Transfer Potion",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_SHIELD_POTION,"Shield Potion",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_FORTRESS_POTION,"Fortress Potion",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_DODGE_POTION,"Dodge Potion",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_SMALL_INVUL_POTION,"Small Invul Potion",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_INVUL_POTION,"Invul Potion",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_STONE_SKIN_POTION,"Stone Skin Potion",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_SPELL_POWER_POTION,"Spell Power Potion",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_SPELL_MASTER_POTION,"Spell Master Potion",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_ARCANE_POTION,"Arcane Potion",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_ANGRY_CAST_POTION,"Angry Cast Potion",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_SPELL_PIERCE_POTION,"Spell Pierce Potion",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_UNSTABLE_POTION,"Unstable Potion",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_AGILITY_POTION,"Agility Potion",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_ACUTE_POTION,"Acute Potion",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_DEXTERITY_POTION,"Dexterity Potion",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_CHARM_OF_SIMPLE_HEAL,"Charm of Simple Heal",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_CHARM_OF_DISPEL,"Charm of Dispel",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_CHARM_OF_HEALING_WARD,"Charm of Healing Ward",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_CHARM_OF_INNER_FIRE,"Charm of Inner Fire",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_CHARM_OF_CHAIN_LIGHTNING,"Charm of Chain Lightning",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_CHARM_OF_DEATH_FINGER,"Charm of Death Finger",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_CHARM_OF_SIPHON_LIFE,"Charm of Siphon Life",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_DEMONIC_RUNE,"Demonic Rune",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            SpellData.create(SID_STRANGE_WAND,"Strange Wand",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
            //:template.end
        }
    }
}
//! endzinc
