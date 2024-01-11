//! zinc
library LanguageConfig requires Table {
    public struct LanguageConfig {
        // indexes
        private static Table dbKey;
        // properties
        integer Key;
        integer ID;
        string English;
        string Chinese;

        // Find config by specified index
        static method FindByKey(integer Key) -> thistype {
            if (thistype.dbKey.exists(Key)) {
                return thistype(thistype.dbKey[Key]);
            } else {
                print(SCOPE_PREFIX + " Unknown Key: " + I2S(Key));
                return 0;
            }
        }


        // new config
        private static method create(integer Key, integer ID, string English, string Chinese) -> thistype {
            thistype this = thistype.allocate();
            thistype.dbKey[Key] = this;
            this.Key = Key;
            this.ID = ID;
            this.English = English;
            this.Chinese = Chinese;
            return this;
        }

        // initialization
        private static method onInit() {
            thistype.dbKey = Table.create();
            thistype.create(lkey_item_belt_of_giant, 1, "Belt of Giant", "巨人腰带");
            thistype.create(lkey_item_boots_of_quelthalas, 2, "Boots of Quel'Thalas", "奎尔萨拉斯长靴");
            thistype.create(lkey_item_robe_of_magi, 3, "Robe of Magi", "魔法师长袍");
            thistype.create(lkey_item_circlet_of_nobility, 4, "Circlet of Nobility", "贵族头环");
            thistype.create(lkey_item_boots_of_speed, 5, "Boots of Speed", "速度之靴");
            thistype.create(lkey_item_helm_of_valor, 6, "Helm of Valor", "英勇面具");
            thistype.create(lkey_item_medalion_of_courage, 7, "Medalion of Courage", "勇气勋章");
            thistype.create(lkey_item_hood_of_cunning, 8, "Hood of Cunning", "灵巧头巾");
            thistype.create(lkey_item_claws_of_attack, 9, "Claws of Attack", "攻击之爪");
            thistype.create(lkey_item_gloves_of_haste, 10, "Gloves of Haste", "急速手套");
            thistype.create(lkey_item_sword_of_assassination, 11, "Sword of Assassination", "刺杀剑");
            thistype.create(lkey_item_vitality_periapt, 12, "Vitality Periapt", "生命护身符");
            thistype.create(lkey_item_ring_of_protection, 13, "Ring of Protection", "守护指环");
            thistype.create(lkey_item_talisman_of_evasion, 14, "Talisman of Evasion", "闪避护符");
            thistype.create(lkey_item_mana_periapt, 15, "Mana Periapt", "法力护身符");
            thistype.create(lkey_item_sobi_mask, 16, "Sobi Mask", "艺人面罩");
            thistype.create(lkey_item_magic_book, 17, "Magic Book", "魔法书");
            thistype.create(lkey_item_crystal_ball, 18, "Crystal Ball", "水晶球");
            thistype.create(lkey_item_long_staff, 19, "Long Staff", "长杖");
            thistype.create(lkey_item_health_stone, 20, "Health Stone", "医疗石");
            thistype.create(lkey_item_mana_stone, 21, "Mana Stone", "魔法石");
            thistype.create(lkey_item_romulos_expired_poison, 22, "Romulo's Expired Poison", "罗密欧的过期毒药");
            thistype.create(lkey_item_moroes_lucky_gear, 23, "Moroes' Lucky Gear", "莫罗斯的幸运齿轮");
            thistype.create(lkey_item_runed_belt, 24, "Runed Belt", "符文腰带");
            thistype.create(lkey_item_unglazed_crescent_icon, 25, "Unglazed Icon of the Crescent", "无光的新月徽记");
            thistype.create(lkey_item_maul_of_warlord, 26, "Maul of Warlord", "战争领主大锤");
            thistype.create(lkey_item_cloak_of_stealth, 27, "Cloak of Stealth", "潜行斗篷");
            thistype.create(lkey_item_scepter_of_archon, 28, "Scepter of Archon", "执政官权杖");
            thistype.create(lkey_item_colossus_blade, 29, "Colossus Blade", "巨神之刃");
            thistype.create(lkey_item_the_x_ring, 30, "The X Ring", "至尊X戒");
            thistype.create(lkey_item_goblin_rocket_boots, 31, "Goblin Rocket Boots Limited Edition", "限量版地精火箭靴");
            thistype.create(lkey_item_warsong_battle_drums, 32, "Warsong Battle Drums", "战歌战鼓");
            thistype.create(lkey_item_troll_bane, 33, "Troll Bane", "托尔贝恩");
            thistype.create(lkey_item_gorehowl, 34, "Gorehowl", "血吼");
            thistype.create(lkey_item_core_hound_tooth, 35, "Core Hound Tooth", "熔火犬牙");
            thistype.create(lkey_item_viskag, 36, "Vis'kag", "维斯卡格");
            thistype.create(lkey_item_lion_horn, 37, "Lion Horn", "风暴狮角");
            thistype.create(lkey_item_armor_damned, 38, "Armor of the Damned", "诅咒铠甲");
            thistype.create(lkey_item_bulwark_amani_empire, 39, "Bulwark of the Amani Empire", "阿曼尼帝国壁垒");
            thistype.create(lkey_item_shining_jewel_of_tanaris, 40, "Shining Jewel of Tanaris", "塔纳利斯明珠");
            thistype.create(lkey_item_drakkari_decapitator, 41, "Drakkari Decapitator", "达卡莱斩首者");
            thistype.create(lkey_item_signet_of_the_last_defender, 42, "Signet of the Last Defender", "末日防御者徽记");
            thistype.create(lkey_item_arans_soothing_emerald, 43, "Aran's Soothing Emerald", "埃兰的镇静玛瑙");
            thistype.create(lkey_item_pure_arcane, 44, "Pure Arcane", "纯净秘法");
            thistype.create(lkey_item_hex_shrunken_head, 45, "Hex Shrunken Head", "妖术之颅");
            thistype.create(lkey_item_staff_of_the_shadow_flame, 46, "Staff of the Shadow Flame", "暗影烈焰法杖");
            thistype.create(lkey_item_tidal_loop, 47, "Tidal Loop", "潮汐指环");
            thistype.create(lkey_item_eagle_god_gauntlets, 48, "Eagle God Gauntlets", "猎鹰之王护手");
            thistype.create(lkey_item_moonstone, 49, "Moonstone", "月亮石");
            thistype.create(lkey_item_shadow_orb, 50, "Shadow Orb", "暗影宝珠");
            thistype.create(lkey_item_orb_of_the_sindorei, 51, "Orb of the Sin'dorei", "辛多雷宝珠");
            thistype.create(lkey_item_reforged_badge_of_tenacity, 52, "Reforged Badge of Tenacity", "重铸的坚韧徽章");
            thistype.create(lkey_item_lights_justice, 53, "Light's Justice", "圣光的正义");
            thistype.create(lkey_item_benediction, 54, "Benediction", "祈福");
            thistype.create(lkey_item_horn_of_cenarius, 55, "Horn of Cenarius", "塞纳留斯的号角");
            thistype.create(lkey_item_banner_of_the_horde, 56, "Banner of the Horde", "部落旗帜");
            thistype.create(lkey_item_kelens_dagger_of_assassination, 57, "Kelen's Dagger of Assassination", "科勒恩的刺杀匕首");
            thistype.create(lkey_item_rhokdelar, 58, "Rhokdelar", "上古守护者的长弓");
            thistype.create(lkey_item_rage_winterchills_phylactery, 59, "Rage Winterchill's Phylactery", "雷基·冬寒的护命匣");
            thistype.create(lkey_item_anathema, 60, "Anathema", "咒逐");
            thistype.create(lkey_item_rare_shimmer_weed, 61, "Rare Shimmer Weed", "罕见的雷电花芯");
            thistype.create(lkey_item_call_to_arms, 62, "Call To Arms", "战争召唤");
            thistype.create(lkey_item_woestave, 63, "Woestave", "烦恼诗集");
            thistype.create(lkey_item_enigma, 64, "Enigma", "谜团");
            thistype.create(lkey_item_breath_of_the_dying, 65, "Breath of the Dying", "死亡呼吸");
            thistype.create(lkey_item_windforce, 66, "Windforce", "风之力");
            thistype.create(lkey_item_derangement_of_cthun, 67, "Derangement of C'Thun", "克苏恩的疯狂");
            thistype.create(lkey_item_might_of_the_angel_of_justice, 68, "Might of the Angel of Justice", "正义天使之力");
            thistype.create(lkey_item_infinity, 69, "Infinity", "无限");
            thistype.create(lkey_item_insight, 70, "Insight", "洞察");
            thistype.create(lkey_item_gurubashi_voodoo_vials, 71, "Gurubashi Voodoo Vials", "古拉巴什巫毒瓶");
            thistype.create(lkey_item_moonlight_greatsword, 72, "Moonlight Greatsword", "月光大剑");
            thistype.create(lkey_item_zuls_staff, 73, "Zul's Staff", "祖尔的法杖");
            thistype.create(lkey_item_mc_sword, 74, "MC Sword", "MC剑");
            thistype.create(lkey_item_thunderfury_blade_of_windseeker, 75, "Thunderfury, Blessed Blade of the Windseeker", "雷霆之怒，逐风者的祝福之剑");
            thistype.create(lkey_item_determination_of_vengeance, 76, "Determination of Vengeance", "复仇的决心");
            thistype.create(lkey_item_stratholme_tragedy, 77, "Stratholme Tragedy", "斯坦索姆悲剧");
            thistype.create(lkey_item_patricide, 78, "Patricide", "弑父");
            thistype.create(lkey_item_frostmourne, 79, "Frostmourne", "霜之哀伤");
            thistype.create(lkey_lore_romulos_expired_poison, 80, "Still usable.", "还能用。");
            thistype.create(lkey_lore_moroes_lucky_gear, 81, "Disassembled from Moroes' Lucky Pocket Watch.", "从莫罗斯的幸运怀表上面卸下来的。");
            thistype.create(lkey_lore_runed_belt, 82, "A bracelet belonged to an ogre.", "所谓护腕，是对食人魔而言。");
            thistype.create(lkey_lore_unglazed_crescent_icon, 83, "The beautiful silver texture is hardly visible.", "依稀可以看出这个徽记曾经是漂亮的银色。");
            thistype.create(lkey_lore_colossus_blade, 84, "A rough greatsword, the most popular mass-production weapon in Harrogath.", "一把粗犷的巨剑，做工不是很精良，在哈洛加斯这是最受欢迎的量产武器。");
            thistype.create(lkey_lore_the_x_ring, 85, "All the former 20 are trash!", "前面二十个都是渣！");
            thistype.create(lkey_lore_goblin_rocket_boots, 86, "Limited edition, but it's a goblin product after all. So use it with caution.", "限量发售，可毕竟是地精产品。");
            thistype.create(lkey_lore_warsong_battle_drums, 87, "High morale.", "士气高涨，牛头人的秘密武器。");
            thistype.create(lkey_lore_troll_bane, 88, "You know this blade...", "“你认得这把斧头……”");
            thistype.create(lkey_lore_gorehowl, 89, "The axe of Grom Hellscream has sown terror across hundreds of battlefields.", "“这把格罗姆地狱咆哮的战斧曾在无数的战场上令敌人闻风丧胆。”");
            thistype.create(lkey_lore_viskag, 90, "The blood letter.", "“血书。”");
            thistype.create(lkey_lore_lion_horn, 91, "Way better than Dragonspine Trophy.", "比龙脊奖章好多了。");
            thistype.create(lkey_lore_armor_of_the_damned, 92, "Slow, Curse, Weakness, Misfortune", "“迟缓大法，恶咒附身，虚弱无力，大难临头”");
            thistype.create(lkey_lore_bulwark_of_the_amani_empire, 93, "It still seems to linger with the resentment of the first guardian warrior of the Brothers Guild.", "似乎仍然缭绕着兄弟公会的第一任防护战士和守护骑士的怨念。");
            thistype.create(lkey_lore_signet_of_the_last_defender, 94, "The signet originally belongs to a demon lord and was later stolen by an orc thief.", "这个戒指本属于一个恶魔领主，后来被一个兽人盗贼偷走。");
            thistype.create(lkey_lore_arans_soothing_emerald, 95, "Aran had made all kinds of precious stones into soothing gems. It should be a sapphire that adventurers are most familiar with.", "埃兰将所有不同种类的宝石都制成过镇定宝石，冒险者们比较熟悉的应该是一颗蓝宝石。");
            thistype.create(lkey_lore_pure_arcane, 96, "Megatorque despises this, he thinks that one simple capacitor can achieve this effect.", "“梅卡托克对此不屑一顾，他认为一个简单的电容器就能达到这个效果。”");
            thistype.create(lkey_lore_hex_shrunken_head, 97, "The Hex Lord is strong enough to abandon such trinkets.", "妖术领主现在已经足够强大，不再需要这样的小玩意了。");
            thistype.create(lkey_lore_staff_of_the_shadow_flame, 98, "The dark flame at the end of the staff is so pure and contains tremendous energy.", "法杖末端的暗影烈焰是如此之纯净，蕴含着巨大的能量。");
            thistype.create(lkey_lore_tidal_loop, 99, "The ring was crafted to fight against the Lord of Fire's legion. But now its ability of fire resistance has dissipated.", "这枚戒指当年是为了对抗火焰之王的军团而打造的，现在已经找不到其火焰抵抗能力了。");
            thistype.create(lkey_lore_orb_of_the_sindorei, 100, "The glory sign of remarkable bloodelf defenders.", "杰出血精灵卫士的荣耀象征。");
            thistype.create(lkey_lore_reforged_badge_of_tenacity, 101, "Originally forged by a demon overseer named Shartuul.", "据说这枚徽章最早是由恶魔沙图尔打造的。");
            thistype.create(lkey_lore_lights_justice, 102, "Open your heart to the light.", "向圣光打开你的心扉。");
            thistype.create(lkey_lore_benediction, 103, "Behind the light, it's shadow.", "在光的背后，是阴影。");
            thistype.create(lkey_lore_horn_of_cenarius, 104, "Legend tells that this Night Elf artifact can summon fallen Night Elf souls.", "这个暗夜精灵族的神器据说能召唤来所有暗夜精灵的灵魂。");
            thistype.create(lkey_lore_banner_of_the_horde, 105, "Carrying the glory of the Horde, countless foes were executed.", "带着部落的荣耀，斩下入侵者的头颅。");
            thistype.create(lkey_lore_kelens_dagger_of_assassination, 106, "Kelen is not merely a master escaper.", "科勒恩不仅仅是逃脱大师而已。");
            thistype.create(lkey_lore_rhokdelar, 107, "Longbow of the Ancient Keepers", "远古守护者的长弓");
            thistype.create(lkey_lore_rage_winterchills_phylactery, 108, "For some people, the value of his phylactery is greater than the Chronicle of Dark Secrets.", "对于某些人来说，他的护命匣的价值要大于黑暗秘密编年史。");
            thistype.create(lkey_lore_anathema, 109, "Before the shadows, it's light.", "在阴影前面，那是光。");
            thistype.create(lkey_lore_rare_shimmer_weed, 110, "Gathered from Thunder Mountain, this shimmer weed seems to contain real thunder energy.", "采自雷霆山，这颗雷电花芯似乎拥有真正的雷电能量。");
            thistype.create(lkey_lore_call_to_arms, 111, "When Zakarum was exiled, he led a mercenary team. It is this very battle axe and his Holy Shield lead his brothers through the bodies of countless enemies.", "撒卡兰姆在被流放的时候，曾领导一支佣兵队伍，他正是靠着这把战斗召唤和圣盾带领着兄弟们踏过无数敌人的尸体。");
            thistype.create(lkey_lore_woestave, 112, "Cause of the great plague.", "“似青苔悄然蔓延毫不经意，又如困兽走投无路歇斯底里”");
            thistype.create(lkey_lore_enigma, 113, "Not recorded.", "不详。");
            thistype.create(lkey_lore_breath_of_the_dying, 114, "The master piece by Griswold the Undead. On the unglazed handle six obscure runes glow: Vex-Hel-El-Eld-Zod-Eth.", "格里斯华尔德变为不死生物以后的巅峰之作，在暗淡无光的矛柄上隐隐闪动着六个晦涩难懂的神符：伐克斯-海尔-埃尔-艾德-萨德-爱斯。");
            thistype.create(lkey_lore_windforce, 115, "The wind carries life for those enveloped in its flow, and death for those arrayed against it.", "“顺风者昌，逆风者亡！”");
            thistype.create(lkey_lore_derangement_of_cthun, 116, "Although the main body of the Old God C'Thun was eliminated, the faceless one formed by his degraded tentacles was everywhere in the abyss of the earth.", "上古之神克苏恩的本体虽然被消灭，可是他的堕落触须形成的无面者在地之深渊无处不在。");
            thistype.create(lkey_lore_might_of_the_angel_of_justice, 117, "The armor used by Tyrael, the Archangel of Wisdom when he was once the incarnation of justice.", "伟大的智慧天使秦端雨曾经作为正义的化身之时所使用的护甲。");
            thistype.create(lkey_lore_infinity, 118, "Infinity is the essence of the Will o'wisps. The energy of lightning contained in it excites the Farseer Drek'Thar. It is said that the soul of the bleak soul with a green cloud-like halo is a nightmare for all adventurers.", "无限是薄暮之魂的精华，里面迸发的闪电能量令先知德雷克萨尔着迷。据说有一种带有绿色光环的苍白薄暮之魂是所有冒险者的噩梦！");
            thistype.create(lkey_lore_insight, 119, "During the war against the forest trolls, the Blood Elf Rangers were inspired by this enchanted orb from Kirin Tor and eventually established Quel'Thalas.", "在抵抗森林巨魔的战斗中，血精灵游侠们挥舞着受到这颗来自肯瑞托的法珠附魔的武器所向披靡，最终成功地建立了奎尔萨拉斯。");
            thistype.create(lkey_lore_gurubashi_voodoo_vials, 120, "Zanzil *makes* friends by these small vials.", "赞吉尔自己*做*朋友。");
            thistype.create(lkey_lore_moonlight_greatsword, 121, "Ludwig the Holy Blade.", "“圣剑路德维希”");
            thistype.create(lkey_lore_thunderfury_blade_of_windseeker, 122, "Once wielded by Thunderaan, Prince of Air.", "曾由风王子桑德兰所使用。");
            thistype.create(lkey_lore_determination_of_vengeance, 123, "The determination to revenge Mal'Ganis is unshakeable.", "“向梅尔甘尼斯复仇的决心无可动摇。”");
            thistype.create(lkey_lore_stratholme_tragedy, 124, "In disregard of Jaina's advice, Stratholme became a hell on earth in merely one night.", "“无视吉安娜的劝告，斯坦索姆一夜之间成了人间地狱，或许这次清洗是正确的？”");
            thistype.create(lkey_lore_patricide, 125, "One last step!", "“最后一步！”");
            thistype.create(lkey_lore_frostmourne, 126, "A gift from the Lich King.", "“巫妖王的礼物。”");
        }
    }
}
//! endzinc
