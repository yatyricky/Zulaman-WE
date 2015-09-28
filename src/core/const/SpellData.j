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
    
        static method operator[](integer sid) -> SpellData {
            if (SpellData.db.exists(sid)) {
                return SpellData(SpellData.db[sid]);
            } else {
                BJDebugMsg(SCOPE_PREFIX+">Unknown spell ID: " + ID2S(sid));
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
SpellData.create(0,"Dummy",0,0,0,0,1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SIDATTACKLL,"Leech Attack",0,0,1,0,1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_GENERAL_STUN,"Stun",0,0,1,0,1,ORDER_TYPE_TARGET);
SpellData.create(SID_HAUNT,"Haunt",0,0,5,852581,1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SIDHEALTESTER,"Fuck Around",0,0,5,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SIDSHIELDBLOCK,"Shield Block",30,0,7,852055,1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SIDSUNFIRESTORM,"Sunfire Storm",20,0,8,852488,1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SIDARCANESHOCK,"Arcane Shock",10,0,2,852480,1,ORDER_TYPE_TARGET).setCCC2(17,0,2).setCCC3(24,0,2);
SpellData.create(SIDDISCORD,"Discord",0,0,14,852128,1,ORDER_TYPE_TARGET).setCCC2(0,0,12).setCCC3(0,0,10);
SpellData.create(SIDSHIELDOFSINDOREI,"Shield of Sindorei",0,0,30,852090,1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_LACERATE,"Lacerate",0,0,1.5,OrderId("coldarrowstarg"),1,ORDER_TYPE_TARGET);
SpellData.create(SID_SAVAGE_ROAR,"Savage Roar",0,0,5,OrderId("purge"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_FOREST_CURE,"Forest Cure",0,0,1,OrderId("deathcoil"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_NATURAL_REFLEX,"Natural Reflex",0,0,15,OrderId("dispel"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_SURVIVAL_INSTINCTS,"Survival Instincts",0,0,60,OrderId("cripple"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SIDLIFEBLOOM,"Life Bloom",50,0,1,OrderId("cripple"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDREJUVENATION,"Rejuvenation",75,0,1,OrderId("rejuvination"),1,ORDER_TYPE_TARGET).setCCC2(110,0,1).setCCC3(145,0,1);
SpellData.create(SIDREGROWTH,"Regrowth",100,3,0,OrderId("healingwave"),1,ORDER_TYPE_TARGET).setCCC2(120,3,0).setCCC3(140,3,0);
SpellData.create(SIDSWIFTMEND,"Swift Mend",150,0,11,OrderId("replenishlife"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDTRANQUILITY,"Tranquility",200,8,40,OrderId("tranquility"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SIDTRANQUILITY1,"Tranquility",200,8,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SIDFLASHLIGHT,"Flash Light",50,0,3.5,OrderId("innerfire"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDFLASHLIGHT1,"Flash Light",50,0,2.2,OrderId("cripple"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDHOLYLIGHT,"Holy Light",100,2.6,0,OrderId("holybolt"),1,ORDER_TYPE_TARGET).setCCC2(115,2.6,0).setCCC3(130,2.6,0);
SpellData.create(SIDHOLYLIGHT1,"Holy Light",0,0,1,OrderId("curse"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDHOLYSHOCK,"Holy Shock",100,0,15,OrderId("resurrection"),1,ORDER_TYPE_TARGET).setCCC2(150,0,15).setCCC3(200,0,15);
SpellData.create(SIDDIVINEFAVOR,"Divine Favor",50,0,20,OrderId("massteleport"),1,ORDER_TYPE_IMMEDIATE).setCCC2(50,0,18).setCCC3(50,0,16);
SpellData.create(SIDBEACONOFLIGHT,"Beacon of Light",10,0,10,OrderId("summonphoenix"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDHEAL,"Heal",75,0,1,852063,1,ORDER_TYPE_TARGET).setCCC2(100,0,1).setCCC3(125,0,1);
SpellData.create(SIDPRAYEROFHEALING,"Prayer of Healing",100,2.4,0,OrderId("blizzard"),1,ORDER_TYPE_POINT).setCCC2(100,2.1,0).setCCC3(100,1.8,0);
SpellData.create(SIDSHIELD,"Shield",100,0,4,852055,1,ORDER_TYPE_TARGET).setCCC2(125,0,4).setCCC3(150,0,4);
SpellData.create(BID_SHIELD,"Shield",0,0,0,1,1,ORDER_TYPE_TARGET);
SpellData.create(SIDPRAYEROFMENDING,"Prayer of Mending",75,0,9,852075,1,ORDER_TYPE_TARGET).setCCC2(85,0,7).setCCC3(95,0,5);
SpellData.create(SIDDISPEL,"Dispel",45,0,3,852057,1,ORDER_TYPE_TARGET).setCCC2(60,0,3).setCCC3(75,0,3);
SpellData.create(SIDDARKARROW,"Black Arrow",4,0,5,OrderId("thunderbolt"),1,ORDER_TYPE_TARGET).setCCC2(5,0,5).setCCC2(6,0,5);
SpellData.create(SIDCONCERNTRATION,"Concerntration",0,0,13,OrderId("thunderclap"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SIDFREEZINGTRAP,"Freezing Trap",0,0,16,OrderId("blizzard"),1,ORDER_TYPE_POINT).setCCC2(0,0,13).setCCC3(0,0,10);
SpellData.create(SIDPOWEROFABOMINATION,"Power of Abomination",0,0,1,OID_IMMOLATIONON,1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SIDDEATHPACT,"Death Pact",0,0,5,OrderId("stomp"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SIDSUMMONGHOUL,"Summon Ghoul",50,0,60,852503,1,ORDER_TYPE_IMMEDIATE).setCCC2(0,0,45).setCCC3(0,0,30);
SpellData.create(SIDLIFELEECH,"Life Leech",0,0,1,0,1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SIDHEROICSTRIKE,"Heroic Strike",0,0,1,OID_IMMOLATIONON,1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SIDREND,"Rend",30,0,6,OrderId("whirlwind"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDOVERPOWER,"Overpower",0,0,3.5,OrderId("windwalk"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDMORTALSTRIKE,"Mortal Strike",15,0,9,OrderId("drunkenhaze"),1,ORDER_TYPE_TARGET).setCCC2(25,0,8).setCCC3(35,0,7);
SpellData.create(SIDEXECUTELEARN,"Execute",0,0,1,OrderId("massteleport"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDEXECUTESTART,"Execute",0,0,1,OrderId("spiritwolf"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDEXECUTE1,"Execute",0,0,1,OrderId("stomp"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDEXECUTE2,"Execute",0,0,1,OrderId("slow"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDEXECUTE3,"Execute",0,0,1,OrderId("channel"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDEXECUTE4,"Execute",0,0,1,OrderId("voodoo"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDEXECUTEEND,"Execute",0,0,1,OrderId("frostarmor"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDFROSTBOLT,"Frost Bolt",15,2,0,OrderId("heal"),1,ORDER_TYPE_TARGET).setCCC2(30,2,0).setCCC3(45,2,0);
SpellData.create(SIDBLIZZARD,"Blizzard",100,5,0,OrderId("blizzard"),1,ORDER_TYPE_POINT);
SpellData.create(SIDBLIZZARD1,"Blizzard",170,0,5,OrderId("blizzard"),1,ORDER_TYPE_POINT);
SpellData.create(SIDFROSTNOVA,"Frost Nova",70,0,15,OrderId("frostnova"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SIDPOLYMORPH,"Polymorph",25,0,30,OrderId("polymorph"),1,ORDER_TYPE_TARGET).setCCC2(25,0,22).setCCC3(25,0,14);
SpellData.create(SIDPOLYMORPHDUMMY,"Polymorph",25,0,5,OrderId("hex"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDSPELLTRANSFER,"Spell Transfer",70,0,6,OrderId("dispel"),1,ORDER_TYPE_TARGET).setCCC2(210,0,3).setCCC3(350,0,1);
SpellData.create(SIDINTELLIGENCECHANNEL,"Intelligence Channel",0,0,1,OrderId("channel"),1,ORDER_TYPE_TARGET);
SpellData.create(SID_STORM_LASH,"Storm Lash",10,2,0,OrderId("forkedlightning"),1,ORDER_TYPE_TARGET).setCCC2(13,2,0).setCCC3(16,2,0);
SpellData.create(SIDSTORMSTRIKE,"Storm Strike",0,0,1,OrderId("forkedlightning"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDEARTHSHOCK,"Earth Shock",85,0,9,OrderId("thunderbolt"),1,ORDER_TYPE_TARGET).setCCC2(95,0,9).setCCC3(105,0,9);
SpellData.create(SIDEARTHSHOCK1,"Earth Shock",0,0,9,OrderId("frostarmor"),1,ORDER_TYPE_TARGET).setCCC2(0,0,9).setCCC3(0,0,9);
SpellData.create(SIDPURGE,"Purge",15,0,15,OrderId("purge"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDENCHANTEDTOTEM,"Enchanted Totem",0,0,1,OrderId("healingward"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SIDLIGHTNINGTOTEM,"Lightning Totem",0,0,10,OrderId("blizzard"),1,ORDER_TYPE_POINT);
SpellData.create(SIDTORRENTTOTEM,"Torrent Totem",0,0,10,OrderId("flamestrike"),1,ORDER_TYPE_POINT);
SpellData.create(SIDEARTHBINDTOTEM,"Earthbind Totem",0,0,10,OrderId("dispel"),1,ORDER_TYPE_POINT);
SpellData.create(SID_ASCENDANCE,"Ascendance",25,0,40,OrderId("metamorphosis"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SIDSINISTERSTRIKE,"Sinister Strike",0,0,2,OrderId("slow"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDEVISCERATE,"Eviscerate",0,0,2,OrderId("impale"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDASSAULT,"Assault",0,0,16,OrderId("deathcoil"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDBLADEFLURRY,"Blade Flurry",0,0,30,OrderId("starfall"),1,ORDER_TYPE_IMMEDIATE).setCCC2(0,0,26).setCCC2(0,0,22);
SpellData.create(SIDSTEALTH,"Stealth",0,0,45,OrderId("cyclone"),1,ORDER_TYPE_IMMEDIATE).setCCC2(0,0,35).setCCC2(0,0,25);
SpellData.create(SIDGARROTE,"Garrote",0,0,1,OrderId("shadowstrike"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDAMBUSH,"Ambush",0,0,1,OrderId("thunderbolt"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDPAIN,"Shadow Word Pain",100,0,2,OrderId("slow"),1,ORDER_TYPE_TARGET).setCCC2(115,0,2).setCCC3(130,0,2);
SpellData.create(SIDMARROWSQUEEZE,"Marrow Squeeze",70,2.3,0,OrderId("dispel"),1,ORDER_TYPE_TARGET).setCCC2(130,2.0,0).setCCC3(190,1.7,0);
SpellData.create(SIDMINDFLAY,"Mind Flay",50,3,0,OrderId("heal"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDDEATH,"Shadow Word Death",0,0,7,OrderId("innerfire"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDTERROR,"Shadow Word Terror",75,0,12,OrderId("unholyfrenzy"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SIDFRENZYCREEP,"Frenzy",0,0,200,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SIDRAGECREEP,"Rage",0,0,200,OrderId("charm"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_GRIP_OF_STATIC_ELECTRICITY,"Grip of Static Electricity",0,0,1,OrderId("healingwave"),1,ORDER_TYPE_TARGET);
SpellData.create(SID_PULSE_BOMB,"Pulse Bomb",0,0,10,OrderId("charm"),1,ORDER_TYPE_TARGET);
SpellData.create(SID_LASER_BEAM,"Laser Beam",0,10,25,OrderId("heal"),2,ORDER_TYPE_TARGET);
SpellData.create(SID_TINKER_MORPH,"Tank Form",0,0,0,OID_BEARFORM,1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_LIGHTNING_SHIELD,"Lightning Shield",0,0,1,OrderId("lightningshield"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_POCKET_FACTORY,"Pocket Factory",0,0,10,OrderId("summonfactory"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_SUMMON_CLOCKWORK_GOBLIN,"Summon Clockwork Goblin",0,4,1,OrderId("summonfactory"),2,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_SELF_DESTRUCT,"Self Destruct",0,3,1,OrderId("selfdestruct"),2,ORDER_TYPE_TARGET);
SpellData.create(SID_CLUSTER_ROCKETS,"Cluster Rockets",0,1,1,OrderId("clusterrockets"),2,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_FUCKED_LIGHTNING,"Forked Lightning",100,0,7,852063,1,ORDER_TYPE_TARGET);
SpellData.create(SID_STRONG_BREEZE,"Strong Breeze",100,0,14,852555,1,ORDER_TYPE_TARGET);
SpellData.create(SID_SUMMON_SERPENTS,"Summon Serpents",100,0,30,852066,1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_THUNDER_STORM,"Thunder Storm",0,10,40,852069,2,ORDER_TYPE_TARGET);
SpellData.create(SIDALKALINEWATER,"Alkaline Water",0,3.5,5,OrderId("heal"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDTIDE,"Tide",0,0,12,OrderId("slow"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDTIDEBARONMORPH,"Tidal Form",0,0,35,OID_BEARFORM,1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SIDTEARUP,"Tear Up",0,0,12,OrderId("slow"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDLANCINATE,"Lancinate",0,0,15,OrderId("channel"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDRASPYROAR,"Raspy Roar",0,0,25,OrderId("impale"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SIDRASPYROARDUMMY,"Raspy Roar",0,0,1,OrderId("silence"),1,ORDER_TYPE_POINT);
SpellData.create(SIDFLAMETHROW,"Flame Throw",100,0,5,OrderId("sleep"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDFLAMEBOMB,"Flame Bomb",100,10,40,OrderId("slow"),2,ORDER_TYPE_IMMEDIATE);
SpellData.create(SIDSUMMONLAVASPAWN,"Summon Lava Spawn",100,10,30,OrderId("soulburn"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SIDFRENZYWARLOCK,"Frenzy",0,0,200,OrderId("stomp"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_IMPALE,"Impale",0,0,15,OrderId("impale"),1,ORDER_TYPE_TARGET);
SpellData.create(SID_SUMMON_POISONOUS_CRAWLER,"Summon Poisonous Crawler",0,0,25,OrderId("slow"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_SUMMON_ABOMINATION,"Summon Abomination",0,0,15,OrderId("charm"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_SUMMON_WRAITH,"Summon Wraith",0,0,15,OrderId("invisibility"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_LIFE_SIPHON,"Life Siphon",0,5,25,OrderId("sleep"),2,ORDER_TYPE_IMMEDIATE);
SpellData.create(SIDSPIRITBOLT,"Spirit Bolt",50,10,40,OrderId("heal"),2,ORDER_TYPE_IMMEDIATE);
SpellData.create(SIDSPIRITHARVEST,"Spirit Harvest",0,0,35,OrderId("hex"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SIDSUNFIRESTORMHEX,"Sunfire Storm",100,0,10,OrderId("slow"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SIDSHIELDOFSINDOREIHEX,"Shield of Sindorei",0,0,10,OrderId("sleep"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_SAVAGE_ROAR_HEX,"Savage Roar",0,0,10,OrderId("sleep"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_NATURAL_REFLEX_HEX,"Natural Reflex",0,0,12,OrderId("slow"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SIDTRANQUILITYHEX,"Tranquility",100,8,10,OrderId("slow"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SIDLIFEBLOOMHEX,"Life Bloom",25,0,10,OrderId("sleep"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDHOLYBOLTHEX,"Holy Light",100,4,10,OrderId("slow"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDHOLYSHOCKHEX,"Holy Shock",50,0,10,OrderId("sleep"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDHEALHEX,"Heal",50,0,10,OrderId("slow"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDSHIELDHEX,"Shield",100,0,10,OrderId("sleep"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDMORTALSTRIKEHEX,"Mortal Strike",0,0,10,OrderId("slow"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDOVERPOWERHEX,"Overpower",0,0,7,OrderId("sleep"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDDARKARROWHEX,"Black Arrow",0,0,4,OrderId("slow"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDFREEZINGTRAPHEX,"Freezing Trap",0,0,10,OrderId("sleep"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SIDFROSTBOLTHEX,"Frost Bolt",50,3,5,OrderId("slow"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDPOLYMORPHHEX,"Polymorph",50,0,10,OrderId("sleep"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDLIGHTNINGTOTEMHEX,"Lightning Totem",0,0,10,OrderId("slow"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SIDCHARGEHEX,"Charge",100,0,15,OrderId("sleep"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SIDSTEALTHHEX,"Stealth",0,0,15,OrderId("slow"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDSTEALTHAMBUSH,"Ambush",0,0,1,OrderId("stomp"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDBLADEFLURRYHEX,"Blade Flurry",0,0,10,OrderId("sleep"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SIDPAINHEX,"Shadow Word Pain",100,0,15,OrderId("slow"),1,ORDER_TYPE_TARGET);
SpellData.create(SIDTERRORHEX,"Shadow Word Terror",100,0,10,OrderId("sleep"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_LIGHTNING_BOLT,"Lightning Bolt",75,3,2,852063,1,ORDER_TYPE_TARGET);
SpellData.create(SID_FROST_SHOCK,"Frost Shock",0,0,8,OrderId("freezingbreath"),1,ORDER_TYPE_TARGET);
SpellData.create(SID_CHAIN_HEALING,"Chain Healing",200,3,5,OrderId("healingwave"),1,ORDER_TYPE_TARGET);
SpellData.create(SID_HEALING_WARD,"Healing Ward",100,0,15,OrderId("healingward"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_PROTECTION_WARD,"Protection Ward",100,0,30,OrderId("evileye"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_NAGA_FRENZY,"Frenzy",0,0,20,OrderId("unholyfrenzy"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_ARMOR_CRUSHING,"Armor Crushing",0,0,20,OrderId("sleep"),1,ORDER_TYPE_TARGET);
SpellData.create(SID_THUNDER_CLAP,"Thunder Clap",0,0,12,OrderId("thunderclap"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_RAGE_ROAR,"Rage Roar",0,0,20,OrderId("slow"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_STING,"Sting",0,0,1,0,1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_CHARGED_BREATH,"Charged Breath",0,0,10,OrderId("heal"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_MANA_LEECH,"Mana Leech",0,0,5,OrderId("healingwave"),1,ORDER_TYPE_TARGET);
SpellData.create(SID_BLAZING_HASTE,"Blazing Haste",75,0,5,852063,1,ORDER_TYPE_TARGET);
SpellData.create(SIDCALLTOARMS,"Call To Arms",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_CTHUNS_DERANGEMENT,"Cthuns Derangement",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SIDENIGMA,"Enigma",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_GOBLIN_ROCKET_BOOTS_LIMITED_EDITION,"Goblin Rocket Boots",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_HEALTH_STONE,"Health Stone",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_MANA_STONE,"Mana Stone",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_HEX_SHRUNKEN_HEAD,"Hex Shrunken Head",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_ICON_OF_THE_UNGLAZED_CRESCENT,"Icon of the Unglazed Crescent",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SIDLIGHTSJUSTICE,"Lights Justice",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_MOROES_LUCKY_GEAR,"Moroes Lucky Gear",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SIDREFORGEDBADGEOFTENACITY,"Reforged Badge of Tenacity",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_TYRAELS_MIGHT,"Tyraels Might",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_VOODOO_VIAL,"Voodoo Vial",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
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
SpellData.create(SID_SANCTUARY_SCROLL,"Sancturay Scroll",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
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
SpellData.create(SID_SMALL_INVUL_POTION,"Small Invulnerability Potion",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_INVUL_POTION,"Invulnerability Potion",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_STONE_SKIN_POTION,"Stone Skin Potion",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_SPELL_POWER_POTION,"Spell Power Potion",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_SPELL_MASTER_POTION,"Spell Master Potion",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_ARCANE_POTION,"Arcane Potion",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
SpellData.create(SID_ANGRY_CAST_POTION,"Angry Caster Potion",0,0,1,OrderId("channel"),1,ORDER_TYPE_IMMEDIATE);
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
        }
    }
}
//! endzinc
