//! zinc
library ItemAttributes requires UnitProperty, ItemAffix, BreathOfTheDying, WindForce, Infinity, ConvertAttackMagic, MagicPoison, VoodooVial, RomulosExpiredPoison, Drum {
    public constant real AFFIX_FACTOR_BASE = 15000;
    public constant real AFFIX_FACTOR_DELTA = 2500;
    public constant real SUFIX_MULTIPLIER = 4;
    public constant real PREFIX_STATIC_MOD = -0.5;
    public constant real SUFIX_STATIC_MOD = -0.2;
    public constant real PREFIX_MAX_PROB = 0.9;
    public constant real SUFIX_MAX_PROB = 0.75;

    public type ItemPropModType extends function(unit, item, integer);
    public type ItemAttributeCallback extends function(unit, real, integer);
    //public HandleTable itemInst;
    Table ItemAttributes;

    IntegerPool ipPrefix1;
    IntegerPool ipPrefix2;
    IntegerPool ipSufix;

    struct DefaultItemAttributesData {
        static Table ht;
        thistype next;
        integer id;
        real lo, hi;
        string name;
        string loreText;

        static method create(integer id, real lo, real hi) -> thistype {
            thistype this = thistype.allocate();
            this.id = id;
            this.lo = lo;
            this.hi = hi;
            this.name = "";
            this.loreText = "";
            this.next = 0;
            return this;
        }

        static method inst(integer itid, string trace) -> thistype {
            if (thistype.ht.exists(itid)) {
                return thistype.ht[itid];
            } else {
                print("Unknown ITID: " + ID2S(itid) + ", trace: " + trace);
                return 0;
            }
        }

        static method setLoreText(integer itid, string name, string lore) {
            thistype this = thistype.inst(itid, "setLoretext");
            this.name = name;
            this.loreText = lore;
        }

        static method append(integer itid, integer id, real lo, real hi) {
            thistype data = thistype.create(id, lo, hi);
            thistype index;
            if (thistype.ht.exists(itid)) {
                index = thistype.ht[itid];
                while (index.next != 0) {
                    index = index.next;
                }
                index.next = data;
            } else {
                thistype.ht[itid] = data;
            }
        }

        static method onInit() {
            thistype.ht = Table.create();
            thistype.append(ITID_CIRCLET_OF_NOBILITY,7,2,4);
            thistype.setLoreText(ITID_CIRCLET_OF_NOBILITY,"|CFF11FF11Circlet of Nobility|R","");

            thistype.append(ITID_HEAVY_BOOTS,8,1,3);
            thistype.setLoreText(ITID_HEAVY_BOOTS,"|CFF11FF11Heavy Boots|R","|CFF999999It's just heavy, nothing special.|R");

            thistype.append(ITID_HELM_OF_VALOR,4,3,5);
            thistype.append(ITID_HELM_OF_VALOR,13,3,5);
            thistype.setLoreText(ITID_HELM_OF_VALOR,"|CFF11FF11Helm of Valor|R","");

            thistype.append(ITID_MEDALION_OF_COURAGE,4,3,5);
            thistype.append(ITID_MEDALION_OF_COURAGE,14,3,5);
            thistype.setLoreText(ITID_MEDALION_OF_COURAGE,"|CFF11FF11Medalion of Courage|R","");

            thistype.append(ITID_HOOD_OF_CUNNING,13,3,5);
            thistype.append(ITID_HOOD_OF_CUNNING,14,3,5);
            thistype.setLoreText(ITID_HOOD_OF_CUNNING,"|CFF11FF11Hood of Cunning|R","");

            thistype.append(ITID_CLAWS_OF_ATTACK,9,4,7);
            thistype.setLoreText(ITID_CLAWS_OF_ATTACK,"|CFF11FF11Claws of Attack|R","");

            thistype.append(ITID_GLOVES_OF_HASTE,12,4,7);
            thistype.setLoreText(ITID_GLOVES_OF_HASTE,"|CFF11FF11Gloves of Haste|R","");

            thistype.append(ITID_SWORD_OF_ASSASSINATION,11,0.02,0.04);
            thistype.setLoreText(ITID_SWORD_OF_ASSASSINATION,"|CFF11FF11Sword of Assassination|R","");

            thistype.append(ITID_VITALITY_PERIAPT,21,80,120);
            thistype.setLoreText(ITID_VITALITY_PERIAPT,"|CFF11FF11Vitality Periapt|R","");

            thistype.append(ITID_RING_OF_PROTECTION,8,2,2);
            thistype.setLoreText(ITID_RING_OF_PROTECTION,"|CFF11FF11Ring of Protection|R","");

            thistype.append(ITID_TALISMAN_OF_EVASION,27,0.02,0.03);
            thistype.setLoreText(ITID_TALISMAN_OF_EVASION,"|CFF11FF11Talisman of Evasion|R","");

            thistype.append(ITID_MANA_PERIAPT,17,100,200);
            thistype.setLoreText(ITID_MANA_PERIAPT,"|CFF11FF11Mana Periapt|R","");

            thistype.append(ITID_SOBI_MASK,72,3,5);
            thistype.setLoreText(ITID_SOBI_MASK,"|CFF11FF11Sobi Mask|R","");

            thistype.append(ITID_STAFF_OF_THE_WITCH_DOCTOR,18,6,16);
            thistype.setLoreText(ITID_STAFF_OF_THE_WITCH_DOCTOR,"|CFF11FF11Staff of the Witch Doctor|R","");

            thistype.append(ITID_HEALTH_STONE,73,3,5);
            thistype.append(ITID_HEALTH_STONE,31,400,800);
            thistype.setLoreText(ITID_HEALTH_STONE,"|CFF11FF11Health Stone|R","");

            thistype.append(ITID_MANA_STONE,72,2,4);
            thistype.append(ITID_MANA_STONE,30,200,400);
            thistype.setLoreText(ITID_MANA_STONE,"|CFF11FF11Mana Stone|R","");

            thistype.append(ITID_ROMULOS_EXPIRED_POISON,53,80,115);
            thistype.setLoreText(ITID_ROMULOS_EXPIRED_POISON,"|CFF11FF11Romulo's Expired Poison|R","|CFF999999Still usable.|R");

            thistype.append(ITID_MOROES_LUCKY_GEAR,27,0.01,0.02);
            thistype.append(ITID_MOROES_LUCKY_GEAR,35,4,7);
            thistype.setLoreText(ITID_MOROES_LUCKY_GEAR,"|CFF11FF11Moroes' Lucky Gear|R","|CFF999999Disassembled from Moroes' Lucky Pocket Watch|R");

            thistype.append(ITID_RUNED_BELT,21,60,90);
            thistype.append(ITID_RUNED_BELT,2,0.03,0.07);
            thistype.setLoreText(ITID_RUNED_BELT,"|CFF11FF11Runed Belt|R","|CFF999999Was a bracelet of an ogre.|R");

            thistype.append(ITID_UNGLAZED_ICON_OF_THE_CRESCENT,14,8,10);
            thistype.append(ITID_UNGLAZED_ICON_OF_THE_CRESCENT,33,12,18);
            thistype.setLoreText(ITID_UNGLAZED_ICON_OF_THE_CRESCENT,"|CFF11FF11Unglazed Icon of the Crescent|R","|CFF999999It can be seen vaguely that this icon was once beautiful silver.|R");

            // rare
            thistype.append(ITID_COLOSSUS_BLADE,9,25,40);
            thistype.append(ITID_COLOSSUS_BLADE,12,12,18);
            thistype.setLoreText(ITID_COLOSSUS_BLADE,"|CFF11FF11Colossus Blade|R","|CFF999999A rough sword, the workmanship is not very good. But it's the most popular production weapons in Harrogath.|R");

            thistype.append(ITID_THE_X_RING,7,9,12);
            thistype.setLoreText(ITID_THE_X_RING,"|CFF8B66FFThe X Ring|R","|CFF999999All the former 20 are trash!|R");

            thistype.append(ITID_GOBLIN_ROCKET_BOOTS_LIMITED_EDITION,21,100,140);
            thistype.append(ITID_GOBLIN_ROCKET_BOOTS_LIMITED_EDITION,17,75,100);
            thistype.append(ITID_GOBLIN_ROCKET_BOOTS_LIMITED_EDITION,27,0.01,0.02);
            thistype.append(ITID_GOBLIN_ROCKET_BOOTS_LIMITED_EDITION,24,15,20);
            thistype.append(ITID_GOBLIN_ROCKET_BOOTS_LIMITED_EDITION,36,8,12);
            thistype.setLoreText(ITID_GOBLIN_ROCKET_BOOTS_LIMITED_EDITION,"|CFF8B66FFGoblin Rocket Boots Limited Edition|R","|CFF999999Limited edition, but it's a goblin product after all. So use it with caution.|R");

            thistype.append(ITID_WARSONG_BATTLE_DRUMS,12,1,3);
            thistype.append(ITID_WARSONG_BATTLE_DRUMS,56,0.01,0.02);
            thistype.append(ITID_WARSONG_BATTLE_DRUMS,84,0.01,0.02);
            thistype.setLoreText(ITID_WARSONG_BATTLE_DRUMS,"|CFF8B66FFWarsong Battle Drums|R","|CFF999999High morale.|R");

            thistype.append(ITID_TROLL_BANE,4,5,8);
            thistype.append(ITID_TROLL_BANE,13,8,12);
            thistype.append(ITID_TROLL_BANE,9,10,20);
            thistype.setLoreText(ITID_TROLL_BANE,"|CFF8B66FFTroll Bane|R","|CFFFFDEAD\"You know this blade...\"|R");

            thistype.append(ITID_GOREHOWL,4,10,13);
            thistype.append(ITID_GOREHOWL,9,10,15);
            thistype.append(ITID_GOREHOWL,11,0.03,0.05);
            thistype.setLoreText(ITID_GOREHOWL,"|CFF8B66FFGorehowl|R","|CFFFFDEAD\"The axe of Grom Hellscream has sown terror across hundreds of battlefields.\"|R");

            thistype.append(ITID_CORE_HOUND_TOOTH,21,50,75);
            thistype.append(ITID_CORE_HOUND_TOOTH,9,15,22);
            thistype.append(ITID_CORE_HOUND_TOOTH,12,5,7);
            thistype.append(ITID_CORE_HOUND_TOOTH,11,0.02,0.04);
            thistype.setLoreText(ITID_CORE_HOUND_TOOTH,"|CFF8B66FFCore Hound Tooth|R","");

            thistype.append(ITID_VISKAG,13,8,12);
            thistype.append(ITID_VISKAG,9,12,18);
            thistype.append(ITID_VISKAG,12,7,12);
            thistype.append(ITID_VISKAG,44,0.04,0.05);
            thistype.setLoreText(ITID_VISKAG,"|CFF8B66FFVis'kag|R","|CFFFFDEAD\"The blood letter\"|R");

            thistype.append(ITID_LION_HORN,9,12,15);
            thistype.append(ITID_LION_HORN,3,0.01,0.02);
            thistype.append(ITID_LION_HORN,48,0.05,0.07);
            thistype.setLoreText(ITID_LION_HORN,"|CFF8B66FFLion Horn|R","|CFF999999Much better than Dragonspine Trophy.|R");

            thistype.append(ITID_ARMOR_OF_THE_DAMNED,8,2,3);
            thistype.append(ITID_ARMOR_OF_THE_DAMNED,4,8,12);
            thistype.append(ITID_ARMOR_OF_THE_DAMNED,15,20,45);
            thistype.append(ITID_ARMOR_OF_THE_DAMNED,74,4,8);
            thistype.append(ITID_ARMOR_OF_THE_DAMNED,41,50,75);
            thistype.setLoreText(ITID_ARMOR_OF_THE_DAMNED,"|CFF8B66FFArmor of the Damned|R","|CFFFFDEAD\"Slow, Curse, Weakness, Misfortune\"|R");

            thistype.append(ITID_BULWARK_OF_THE_AMANI_EMPIRE,8,1,2);
            thistype.append(ITID_BULWARK_OF_THE_AMANI_EMPIRE,4,5,7);
            thistype.append(ITID_BULWARK_OF_THE_AMANI_EMPIRE,21,150,240);
            thistype.append(ITID_BULWARK_OF_THE_AMANI_EMPIRE,15,14,28);
            thistype.setLoreText(ITID_BULWARK_OF_THE_AMANI_EMPIRE,"|CFF8B66FFBulwark of the Amani Empire|R","|CFF999999It still seems to linger with the resentment of the first guardian warrior of the Brothers' Guild.|R");

            thistype.append(ITID_SIGNET_OF_THE_LAST_DEFENDER,8,1,2);
            thistype.append(ITID_SIGNET_OF_THE_LAST_DEFENDER,4,7,9);
            thistype.append(ITID_SIGNET_OF_THE_LAST_DEFENDER,27,0.01,0.01);
            thistype.append(ITID_SIGNET_OF_THE_LAST_DEFENDER,6,0.03,0.06);
            thistype.setLoreText(ITID_SIGNET_OF_THE_LAST_DEFENDER,"|CFF8B66FFSignet of the Last Defender|R","|CFF999999The signet originally belongs to a demon lord and was later stolen by an orc thief.|R");

            thistype.append(ITID_ARANS_SOOTHING_EMERALD,14,5,8);
            thistype.append(ITID_ARANS_SOOTHING_EMERALD,18,10,15);
            thistype.append(ITID_ARANS_SOOTHING_EMERALD,19,2,4);
            thistype.append(ITID_ARANS_SOOTHING_EMERALD,72,2,4);
            thistype.setLoreText(ITID_ARANS_SOOTHING_EMERALD,"|CFF8B66FFAran's Soothing Emerald|R","|CFF999999Aran had made all kinds of precious stones into soothing gems. It should be a sapphire that adventurers are most familiar with.|R");

            thistype.append(ITID_PURE_ARCANE,77,170,220);
            thistype.setLoreText(ITID_PURE_ARCANE,"|CFF8B66FFPure Arcane|R","|CFF999999Megatorque despises this, he thinks \"One simple capacitor can achieve this effect\".|R");

            thistype.append(ITID_HEX_SHRUNKEN_HEAD,14,8,12);
            thistype.append(ITID_HEX_SHRUNKEN_HEAD,18,10,15);
            thistype.append(ITID_HEX_SHRUNKEN_HEAD,34,35,64);
            thistype.setLoreText(ITID_HEX_SHRUNKEN_HEAD,"|CFF8B66FFHex Shrunken Head|R","|CFF999999The Hex Lord is now strong enough to no longer need such trinkets.|R");

            thistype.append(ITID_STAFF_OF_THE_SHADOW_FLAME,14,5,8);
            thistype.append(ITID_STAFF_OF_THE_SHADOW_FLAME,18,10,21);
            thistype.append(ITID_STAFF_OF_THE_SHADOW_FLAME,20,0.04,0.05);
            thistype.setLoreText(ITID_STAFF_OF_THE_SHADOW_FLAME,"|CFF8B66FFStaff of the Shadow Flame|R","|CFFFFDEADThe dark flame at the end of the staff is so pure and contains tremendous energy.|R");

            thistype.append(ITID_TIDAL_LOOP,4,7,10);
            thistype.append(ITID_TIDAL_LOOP,14,8,12);
            thistype.append(ITID_TIDAL_LOOP,72,3,5);
            thistype.append(ITID_TIDAL_LOOP,87,60,90);
            thistype.setLoreText(ITID_TIDAL_LOOP,"|CFF8B66FFTidal Loop|R","|CFF999999The ring was crafted to fight against the Lord of Fire's legion. But now its ability of fire resistance has lost.|R");

            thistype.append(ITID_ORB_OF_THE_SINDOREI,4,5,7);
            thistype.append(ITID_ORB_OF_THE_SINDOREI,21,60,80);
            thistype.append(ITID_ORB_OF_THE_SINDOREI,18,14,20);
            thistype.append(ITID_ORB_OF_THE_SINDOREI,16,0.04,0.06);
            thistype.append(ITID_ORB_OF_THE_SINDOREI,86,0.03,0.07);
            thistype.setLoreText(ITID_ORB_OF_THE_SINDOREI,"|CFF8B66FFOrb of the Sin'dorei|R","|CFFFFDEADThe glory sign of remarkable bloodelf defenders.|R");

            thistype.append(ITID_REFORGED_BADGE_OF_TENACITY,13,5,7);
            thistype.append(ITID_REFORGED_BADGE_OF_TENACITY,8,3,4);
            thistype.append(ITID_REFORGED_BADGE_OF_TENACITY,21,80,120);
            thistype.append(ITID_REFORGED_BADGE_OF_TENACITY,27,0.02,0.04);
            thistype.append(ITID_REFORGED_BADGE_OF_TENACITY,78,0.08,0.1);
            thistype.append(ITID_REFORGED_BADGE_OF_TENACITY,92,3,7);
            thistype.setLoreText(ITID_REFORGED_BADGE_OF_TENACITY,"|CFF8B66FFReforged Badge of Tenacity|R","|CFFFFDEADOriginally forged by a demon overseer named Shartuul.|R");

            thistype.append(ITID_LIGHTS_JUSTICE,14,5,6);
            thistype.append(ITID_LIGHTS_JUSTICE,18,10,20);
            thistype.append(ITID_LIGHTS_JUSTICE,20,0.03,0.04);
            thistype.append(ITID_LIGHTS_JUSTICE,79,0,0);
            thistype.append(ITID_LIGHTS_JUSTICE,91,0,0);
            thistype.setLoreText(ITID_LIGHTS_JUSTICE,"|CFF8B66FFLight's Justice|R","|CFFFFDEADOpen your heart to the light.|R");

            thistype.append(ITID_BENEDICTION,14,6,8);
            thistype.append(ITID_BENEDICTION,21,60,75);
            thistype.append(ITID_BENEDICTION,18,8,16);
            thistype.append(ITID_BENEDICTION,72,3,6);
            thistype.append(ITID_BENEDICTION,76,4,6);
            thistype.append(ITID_BENEDICTION,80,0,0);
            thistype.setLoreText(ITID_BENEDICTION,"|CFF8B66FFBenediction|R","|CFFFFDEADBehind the light, it's shadow.|R");

            thistype.append(ITID_HORN_OF_CENARIUS,7,4,5);
            thistype.append(ITID_HORN_OF_CENARIUS,21,50,80);
            thistype.append(ITID_HORN_OF_CENARIUS,17,80,130);
            thistype.append(ITID_HORN_OF_CENARIUS,18,10,14);
            thistype.append(ITID_HORN_OF_CENARIUS,69,3,4);
            thistype.setLoreText(ITID_HORN_OF_CENARIUS,"|CFF8B66FFHorn of Cenarius|R","|CFFFFDEADThis Night Elf artifact is said to be able to summon the souls of all night elves.|R");

            thistype.append(ITID_BANNER_OF_THE_HORDE,4,6,8);
            thistype.append(ITID_BANNER_OF_THE_HORDE,13,6,8);
            thistype.append(ITID_BANNER_OF_THE_HORDE,9,10,12);
            thistype.append(ITID_BANNER_OF_THE_HORDE,11,0.03,0.04);
            thistype.append(ITID_BANNER_OF_THE_HORDE,39,0.4,0.6);
            thistype.setLoreText(ITID_BANNER_OF_THE_HORDE,"|CFF8B66FFBanner of the Horde|R","|CFFFFDEADWith the tribal glory, the head of the enemies were left behind.|R");

            thistype.append(ITID_KELENS_DAGGER_OF_ASSASSINATION,13,7,8);
            thistype.append(ITID_KELENS_DAGGER_OF_ASSASSINATION,9,12,16);
            thistype.append(ITID_KELENS_DAGGER_OF_ASSASSINATION,12,7,9);
            thistype.append(ITID_KELENS_DAGGER_OF_ASSASSINATION,66,0,0);
            thistype.append(ITID_KELENS_DAGGER_OF_ASSASSINATION,65,0.04,0.06);
            thistype.append(ITID_KELENS_DAGGER_OF_ASSASSINATION,90,0.05,0.06);
            thistype.setLoreText(ITID_KELENS_DAGGER_OF_ASSASSINATION,"|CFF8B66FFKelen's Dagger of Assassination|R","|CFFFFDEADKelen is not just a master escaper.|R");

            thistype.append(ITID_RHOKDELAR,13,5,8);
            thistype.append(ITID_RHOKDELAR,9,11,13);
            thistype.append(ITID_RHOKDELAR,11,3,5);
            thistype.append(ITID_RHOKDELAR,24,10,20);
            thistype.append(ITID_RHOKDELAR,94,1,1);
            thistype.setLoreText(ITID_RHOKDELAR,"|CFF8B66FFRhok'delar|R","|CFFFFDEADLongbow of the Ancient Keepers|R");

            thistype.append(ITID_RAGE_WINTERCHILLS_PHYLACTERY,14,5,8);
            thistype.append(ITID_RAGE_WINTERCHILLS_PHYLACTERY,21,70,90);
            thistype.append(ITID_RAGE_WINTERCHILLS_PHYLACTERY,20,2,3);
            thistype.append(ITID_RAGE_WINTERCHILLS_PHYLACTERY,96,0.03,0.04);
            thistype.append(ITID_RAGE_WINTERCHILLS_PHYLACTERY,70,0.01,0.02);
            thistype.setLoreText(ITID_RAGE_WINTERCHILLS_PHYLACTERY,"|CFF8B66FFRage Winterchill's Phylactery|R","|CFFFFDEADFor some people, the value of his phylactery is greater than the Chronicle of Dark Secrets.|R");

            thistype.append(ITID_ANATHEMA,21,90,150);
            thistype.append(ITID_ANATHEMA,18,10,15);
            thistype.append(ITID_ANATHEMA,19,0.02,0.03);
            thistype.append(ITID_ANATHEMA,20,0.02,0.03);
            thistype.append(ITID_ANATHEMA,81,2,3);
            thistype.setLoreText(ITID_ANATHEMA,"|CFF8B66FFAnathema|R","|CFFFFDEADBefore the shadows, it's light.|R");

            thistype.append(ITID_RARE_SHIMMER_WEED,7,3,4);
            thistype.append(ITID_RARE_SHIMMER_WEED,18,10,12);
            thistype.append(ITID_RARE_SHIMMER_WEED,12,5,6);
            thistype.append(ITID_RARE_SHIMMER_WEED,19,0.02,0.04);
            thistype.append(ITID_RARE_SHIMMER_WEED,93,0.09,0.11);
            thistype.setLoreText(ITID_RARE_SHIMMER_WEED,"|CFF8B66FFRare Shimmer Weed|R","|CFFFFDEADGathered from Thunder Mountain, this shimmer weed seems to have real thunder energy.|R");

            thistype.append(ITID_CALL_TO_ARMS,9,10,15);
            thistype.append(ITID_CALL_TO_ARMS,9,10,15);
            thistype.append(ITID_CALL_TO_ARMS,18,12,18);
            thistype.append(ITID_CALL_TO_ARMS,73,10,17);
            thistype.append(ITID_CALL_TO_ARMS,57,20,40);
            thistype.append(ITID_CALL_TO_ARMS,45,0.03,0.05);
            thistype.append(ITID_CALL_TO_ARMS,29,0.06,0.12);
            thistype.setLoreText(ITID_CALL_TO_ARMS,"|CFFFF8C00Call To Arms|R","|CFFFFCC00Lore|R|N|CFFFFDEADWhen Zakarum was exiled, he led a mercenary team. It is this very battle axe and his Holy Shield that lead his brothers through the bodies of countless enemies.|R");

            thistype.append(ITID_WOESTAVE,9,7,21);
            thistype.append(ITID_WOESTAVE,63,0.01,0.03);
            thistype.append(ITID_WOESTAVE,62,0.02,0.04);
            thistype.append(ITID_WOESTAVE,61,1,2);
            thistype.append(ITID_WOESTAVE,60,0.03,0.04);
            thistype.append(ITID_WOESTAVE,64,0.01,0.01);
            thistype.append(ITID_WOESTAVE,59,0.11,0.17);
            thistype.setLoreText(ITID_WOESTAVE,"|CFFFF8C00Woestave|R","|CFFFFDEAD\"Cause of the great plague.\"|R");

            thistype.append(ITID_ENIGMA,1,0.01,0.02);
            thistype.append(ITID_ENIGMA,3,0.01,0.02);
            thistype.append(ITID_ENIGMA,24,12,20);
            thistype.append(ITID_ENIGMA,IATTR_STR,8,13);
            thistype.append(ITID_ENIGMA,40,0.01,0.02);
            thistype.append(ITID_ENIGMA,28,0,0);
            thistype.setLoreText(ITID_ENIGMA,"|CFFFF8C00Enigma|R","|CFFFFCC00Lore|R|N|CFFFFDEADNot recorded.|R");

            thistype.append(ITID_BREATH_OF_THE_DYING,7,4,6);
            thistype.append(ITID_BREATH_OF_THE_DYING,9,18,22);
            thistype.append(ITID_BREATH_OF_THE_DYING,12,6,9);
            thistype.append(ITID_BREATH_OF_THE_DYING,45,0.03,0.04);
            thistype.append(ITID_BREATH_OF_THE_DYING,50,18,23);
            thistype.setLoreText(ITID_BREATH_OF_THE_DYING,"|CFFFF8C00Breath of the Dying|R","|CFFFFCC00Lore|R|N|CFFFFDEADThe master piece by Griswold the Undead. On the unglazed handle six obscure runes glow: Vex-Hel-El-Eld-Zod-Eth.|R");

            thistype.append(ITID_WINDFORCE,13,8,12);
            thistype.append(ITID_WINDFORCE,9,11,16);
            thistype.append(ITID_WINDFORCE,12,6,8);
            thistype.append(ITID_WINDFORCE,11,0.02,0.03);
            thistype.append(ITID_WINDFORCE,47,0.05,0.1);
            thistype.setLoreText(ITID_WINDFORCE,"|CFFFF8C00Windforce|R","|CFFFFDEAD\"The wind carries life for those enveloped in its flow, and death for those arrayed against it.\"|R");

            thistype.append(ITID_DERANGEMENT_OF_CTHUN,4,7,10);
            thistype.append(ITID_DERANGEMENT_OF_CTHUN,9,17,24);
            thistype.append(ITID_DERANGEMENT_OF_CTHUN,11,0.01,0.02);
            thistype.append(ITID_DERANGEMENT_OF_CTHUN,74,3,30);
            thistype.append(ITID_DERANGEMENT_OF_CTHUN,44,0.03,0.06);
            thistype.append(ITID_DERANGEMENT_OF_CTHUN,46,0.04,0.06);
            thistype.append(ITID_DERANGEMENT_OF_CTHUN,37,0.05,0.5);
            thistype.setLoreText(ITID_DERANGEMENT_OF_CTHUN,"|CFFFF8C00Derangement of C'Thun|R","|CFFFFCC00Lore|R|N|CFFFFDEADAlthough the main body of the Old God C'Thun was eliminated, the faceless one formed by his degraded tentacles was everywhere in the abyss of the earth.|R");

            thistype.append(ITID_MIGHT_OF_THE_ANGEL_OF_JUSTICE,4,5,7);
            thistype.append(ITID_MIGHT_OF_THE_ANGEL_OF_JUSTICE,8,2,3);
            thistype.append(ITID_MIGHT_OF_THE_ANGEL_OF_JUSTICE,1,0.01,0.02);
            thistype.append(ITID_MIGHT_OF_THE_ANGEL_OF_JUSTICE,2,0.01,0.03);
            thistype.append(ITID_MIGHT_OF_THE_ANGEL_OF_JUSTICE,24,12,15);
            thistype.append(ITID_MIGHT_OF_THE_ANGEL_OF_JUSTICE,42,2,5);
            thistype.append(ITID_MIGHT_OF_THE_ANGEL_OF_JUSTICE,38,25,35);
            thistype.setLoreText(ITID_MIGHT_OF_THE_ANGEL_OF_JUSTICE,"|CFFFF8C00Might of the Angel of Justice|R","|CFFFFCC00Lore|R|N|CFFFFDEADThe armor used by Tyrael, the Archangel of Wisdom when he was once the incarnation of justice.|R");

            thistype.append(ITID_INFINITY,14,4,6);
            thistype.append(ITID_INFINITY,21,70,166);
            thistype.append(ITID_INFINITY,18,8,12);
            thistype.append(ITID_INFINITY,82,0.01,0.02);
            thistype.append(ITID_INFINITY,89,60,75);
            thistype.setLoreText(ITID_INFINITY,"|CFFFF8C00Infinity|R","|CFFFFCC00Lore|R|N|CFFFFDEADInfinity is the essence of the Will o'wisps. The energy of lightning contained in it excites the prophet Drexel. It is said that the soul of the bleak soul with a green cloud-like halo is a nightmare for all adventurers.|R");

            thistype.append(ITID_INSIGHT,14,3,4);
            thistype.append(ITID_INSIGHT,9,3,5);
            thistype.append(ITID_INSIGHT,18,10,17);
            thistype.append(ITID_INSIGHT,19,0.03,0.06);
            thistype.append(ITID_INSIGHT,57,17,30);
            thistype.append(ITID_INSIGHT,68,0,0);
            thistype.append(ITID_INSIGHT,83,2,4);
            thistype.setLoreText(ITID_INSIGHT,"|CFFFF8C00Insight|R","|CFFFFCC00Lore|R|N|CFFFFDEADIn the fight against the forest trolls, the Blood Elf Rangers used this enchanted orb from Kirin Tor and eventually succeeded in establishing Quel'Thalas.|R");

            thistype.append(ITID_VOODOO_VIALS,14,3,5);
            thistype.append(ITID_VOODOO_VIALS,17,83,110);
            thistype.append(ITID_VOODOO_VIALS,20,0.01,0.01);
            thistype.append(ITID_VOODOO_VIALS,19,0.01,0.02);
            thistype.append(ITID_VOODOO_VIALS,88,12,20);
            thistype.append(ITID_VOODOO_VIALS,32,15,30);
            thistype.setLoreText(ITID_VOODOO_VIALS,"|CFFFF8C00Voodoo Vials|R","|CFFFFCC00Lore|R|N|CFFFFDEADZanzil \"makes\" friends by these small vials.|R");

            thistype.append(ITID_HOLY_MOONLIGHT_SWORD,4,4,6);
            thistype.append(ITID_HOLY_MOONLIGHT_SWORD,21,75,100);
            thistype.append(ITID_HOLY_MOONLIGHT_SWORD,57,11,19);
            thistype.append(ITID_HOLY_MOONLIGHT_SWORD,43,0.03,0.04);
            thistype.append(ITID_HOLY_MOONLIGHT_SWORD,75,75,100);
            thistype.append(ITID_HOLY_MOONLIGHT_SWORD,49,60,80);
            thistype.setLoreText(ITID_HOLY_MOONLIGHT_SWORD,"|CFFFF8C00Holy Moonlight Sword|R","|CFFFFDEAD\"Ludwig the Holy Blade\"|R");

        }
    }

    public struct ItemExAttributes {
        static HandleTable ht;
        static item droppingItem;
        integer id;
        real value;
        thistype next;
        ItemAffix affix;

        static method inst(item it, string trace) -> thistype {
            if (thistype.ht.exists(it)) {
                return thistype.ht[it];
            } else {
                print("Unknown item: " + ID2S(GetItemTypeId(it)) + ", trace: " + trace);
                return 0;
            }
        }

        static method findAttribute(item it, integer id) -> thistype {
            thistype head = thistype.inst(it, "ItemExAttributes.findAttribute");
            boolean found = false;
            while (found == false && head != 0) {
                if (head.id == id) {
                    found = true;
                } else {
                    head = head.next;
                }
            }
            if (found == true) {
                return head;
            } else {
                return 0;
            }
        }

        static method getAttributeValue(item it, integer id, string trace) -> real {
            thistype attr = thistype.findAttribute(it, id);
            if (attr == 0) {
                return 0.0;
            } else {
                return attr.value;
            }
        }

        static method getAttrVal(item it, integer id, boolean inclLP, string trace) -> real {
            thistype attr = thistype.findAttribute(it, id);
            thistype lp;
            ItemAttributeMeta meta;
            if (attr == 0) {
                return 0.0;
            } else {
                lp = thistype.findAttribute(it, IATTR_LP);
                meta = ItemAttributeMeta.inst(id, "getAttrVal");
                if (inclLP == true) {
                    return attr.value * (1 + lp * meta.lpAmp);
                } else {
                    return attr.value;
                }
            }
        }

        static method getUnitAttrVal(unit u, integer id, string trace) -> real {
            item ti;
            integer ii = 0;
            real amt = 0;
            ItemAttributeMeta meta = ItemAttributeMeta.inst(id, "getUnitAttrVal");
            while (ii < 6) {
                ti = UnitItemInSlot(u, ii);
                if (ti != null && ti != thistype.droppingItem) {
                    amt += ItemExAttributes.getAttributeValue(ti, id, trace + " > getUnitAttrVal") * (1 + ItemExAttributes.getAttributeValue(ti, IATTR_LP, trace + " > getUnitAttrVal") * meta.lpAmp);
                }
                ii += 1;
            }
            ti = null;
            return amt;
        }

        static method getUnitAttrValMax(unit u, integer id, string trace) -> real {
            item ti;
            integer ii = 0;
            real amt = 0;
            real sel = -99999;
            boolean found = false;
            ItemAttributeMeta meta = ItemAttributeMeta.inst(id, "getUnitAttrVal");
            while (ii < 6) {
                ti = UnitItemInSlot(u, ii);
                if (ti != null && ti != thistype.droppingItem) {
                    amt = ItemExAttributes.getAttributeValue(ti, id, trace + " > getUnitAttrVal") * (1 + ItemExAttributes.getAttributeValue(ti, IATTR_LP, trace + " > getUnitAttrVal") * meta.lpAmp);
                    if (sel < amt) {
                        sel = amt;
                        found = true;
                    }
                }
                ii += 1;
            }
            ti = null;
            if (found == true) {
                return sel;
            } else {
                return 0.00;
            }
        }

        static method getUnitAttrValMin(unit u, integer id, string trace) -> real {
            item ti;
            integer ii = 0;
            real amt = 0;
            real sel = 99999;
            boolean found = false;
            ItemAttributeMeta meta = ItemAttributeMeta.inst(id, "getUnitAttrVal");
            while (ii < 6) {
                ti = UnitItemInSlot(u, ii);
                if (ti != null && ti != thistype.droppingItem) {
                    amt = ItemExAttributes.getAttributeValue(ti, id, trace + " > getUnitAttrVal") * (1 + ItemExAttributes.getAttributeValue(ti, IATTR_LP, trace + " > getUnitAttrVal") * meta.lpAmp);
                    if (sel > amt) {
                        sel = amt;
                        found = true;
                    }
                }
                ii += 1;
            }
            ti = null;
            if (sel < 0) {
                sel = 0.0;
            }
            if (found == true) {
                return sel;
            } else {
                return 0.00;
            }
        }

        static method create(integer id, real val) -> thistype {
            thistype this = thistype.allocate();
            this.id = id;
            this.value = val;
            this.next = 0;
            return this;
        }

        static method updateUbertip(item it) {
            thistype head;
            string str;
            string valstr;
            real finalValue;
            real lp = 0;
            boolean hasLP;
            ItemAttributeMeta meta;
            DefaultItemAttributesData raw;
            if (thistype.ht.exists(it)) {
                head = thistype.ht[it];
                str = "";
                hasLP = false;
                while (head != 0) {
                    meta = ItemAttributeMeta.inst(head.id, "ItemExAttributes.updateUbertip.meta");
                    if (head.id == IATTR_LP) {
                        hasLP = true;
                        lp = head.value;
                    }
                    if (head.value == 0) {
                        str = str + meta.str1 + meta.str2;
                    } else {
                        finalValue = head.value;
                        if (hasLP == true && meta.cate == 2) { // 2: improvable
                            finalValue = head.value * (1 + lp * meta.lpAmp);
                        }
                        if (finalValue < 0) {
                            finalValue = 0;
                        }
                        if (finalValue < 1 || head.id == IATTR_USE_CTHUN || head.id == IATTR_BM_VALOR) {
                            valstr = I2S(Rounding(finalValue * 100)) + "%";
                        } else {
                            valstr = I2S(Rounding(finalValue));
                        }
                        str = str + meta.str1 + valstr + meta.str2;
                    }
                    if (head.next != 0) {
                        str = str + "|N";
                    }
                    head = head.next;
                }
                // raw = DefaultItemAttributesData.inst(GetItemTypeId(it), "updateUberTip");
                print(str);
                // BlzSetItemExtendedTooltip(it, str);
            } else {
                print("ItemExAttributes.updateUbertip no such item " + ID2S(GetItemTypeId(it)));
            }
        }

        static method updateName(item it) {
            thistype this = thistype.inst(it, "ItemExAttributes.updateName");
            string rawName = DefaultItemAttributesData.inst(GetItemTypeId(it), "updateName").name;
            ItemAffix head = this.affix;
            AffixRawData meta;
            string sufix = "";
            string prefix = "";
            while (head != 0) {
                meta = AffixRawData.inst(head.id, "ItemExAttributes.updateName");
                if (meta.slot == 1) {
                    prefix = prefix + meta.text[1];
                } else if (meta.slot == 2) {
                    sufix = sufix + meta.text[1];
                } else {
                    print("WTF??? ItemExAttributes.updateName 155");
                }
                head = head.next;
            }
            BlzSetItemName(it, prefix + rawName + sufix);
        }

        static method apply(item it, real exp) {
            DefaultItemAttributesData raw = DefaultItemAttributesData.inst(GetItemTypeId(it), "ItemExAttributes.intantiate");
            thistype data;
            thistype head, index;
            boolean found;
            ItemAttributeMeta metaIndex, metaData;
            if (raw == 0) {
                print("Raw data does not exist ItemExAttributes 73");
            } else {
                head = thistype.create(raw.id, GetRandomReal(raw.lo, raw.hi) * exp);
                head.affix = 0;
                thistype.ht[it] = head;
                raw = raw.next;
                while (raw != 0) {
                    data = thistype.create(raw.id, GetRandomReal(raw.lo, raw.hi) * exp);
                    // insert
                    index = head;
                    found = false;
                    while (index.next != 0 && found == false) {
                        metaIndex = ItemAttributeMeta.inst(index.next.id, "ItemExAttributes.intantiate.metaIndex");
                        metaData = ItemAttributeMeta.inst(data.id, "ItemExAttributes.intantiate.metaData");
                        if (metaIndex.sort < metaData.sort) {
                            index = index.next;
                        } else {
                            found = true;
                        }
                    }
                    if (index.next != 0) {
                        data.next = index.next;
                    }
                    index.next = data;
                    raw = raw.next;
                }
            }
        }

        static method append(item it, integer id, real val) {
            thistype attr = thistype.findAttribute(it, id);
            thistype head;
            thistype data;
            boolean found;
            ItemAttributeMeta metaHead, metaData;
            if (attr != 0) {
                attr.value += val;
            } else {
                data = thistype.create(id, val);
                head = thistype.inst(it, "ItemExAttributes.append");
                found = false;
                while (found == false && head.next != 0) {
                    metaHead = ItemAttributeMeta.inst(head.next.id, "ItemExAttributes.intantiate.metaHead");
                    metaData = ItemAttributeMeta.inst(data.id, "ItemExAttributes.intantiate.metaData");
                    if (metaHead.sort < metaData.sort) {
                        head = head.next;
                    } else {
                        found = true;
                    }
                }
                if (head.next != 0) {
                    data.next = head.next;
                }
                head.next = data;
            }
        }

        static method appendAffix(item it, ItemAffix affix) {
            thistype this = thistype.inst(it, "ItemExAttributes.appendAffix");
            integer i;
            ItemAffix index = this.affix;
            while (index != 0 && index.next != 0) {
                index = index.next;
            }
            if (index == 0) {
                this.affix = affix;
            } else {
                index.next = affix;
            }
            i = 0;
            while (i < affix.attributeN) {
                if (affix.attribute[i] == AFFIX_TYPE_STR) {
                    thistype.append(it, IATTR_STR, affix.value[i]);
                } else if (affix.attribute[i] == AFFIX_TYPE_AGI) {
                    thistype.append(it, IATTR_AGI, affix.value[i]);
                } else if (affix.attribute[i] == AFFIX_TYPE_INT) {
                    thistype.append(it, IATTR_INT, affix.value[i]);
                } else if (affix.attribute[i] == AFFIX_TYPE_HP) {
                    thistype.append(it, IATTR_HP, affix.value[i]);
                } else if (affix.attribute[i] == AFFIX_TYPE_AP) {
                    thistype.append(it, IATTR_AP, affix.value[i]);
                } else if (affix.attribute[i] == AFFIX_TYPE_CRIT) {
                    thistype.append(it, IATTR_CRIT, affix.value[i]);
                } else if (affix.attribute[i] == AFFIX_TYPE_IAS) {
                    thistype.append(it, IATTR_IAS, affix.value[i]);
                } else if (affix.attribute[i] == AFFIX_TYPE_SP) {
                    thistype.append(it, IATTR_SP, affix.value[i]);
                } else if (affix.attribute[i] == AFFIX_TYPE_SCRIT) {
                    thistype.append(it, IATTR_SCRIT, affix.value[i]);
                } else if (affix.attribute[i] == AFFIX_TYPE_SHASTE) {
                    thistype.append(it, IATTR_SHASTE, affix.value[i]);
                } else if (affix.attribute[i] == AFFIX_TYPE_MREGEN) {
                    thistype.append(it, IATTR_MREG, affix.value[i]);
                } else if (affix.attribute[i] == AFFIX_TYPE_DEF) {
                    thistype.append(it, IATTR_DEF, affix.value[i]);
                } else if (affix.attribute[i] == AFFIX_TYPE_DODGE) {
                    thistype.append(it, IATTR_DODGE, affix.value[i]);
                } else if (affix.attribute[i] == AFFIX_TYPE_SLVL) {
                    thistype.append(it, IATTR_LP, affix.value[i]);
                }
                i += 1;
            }
        }

        static method onInit() {
            thistype.ht = HandleTable.create();
            thistype.droppingItem = null;
        }
    }
    
    public function CreateItemEx(integer itid, real x, real y, real lootValue) -> item {
        item it = CreateItem(itid, x + GetRandomReal(-50, 50), y + GetRandomReal(-50, 50));
        real prefixFactor;
        real sufixFactor;
        real prob, prob1;
        boolean prefixDone;
        string itemName;
        real exp;
        if (lootValue < ILVL_THRESHOLD[0]) {
            exp = 1.0;
        } else if (lootValue < ILVL_THRESHOLD[1]) {
            exp = 1.0 + lootValue / (ILVL_THRESHOLD[1] - ILVL_THRESHOLD[0]);
        } else {
            exp = 2.0 + lootValue / (ILVL_THRESHOLD[2] - ILVL_THRESHOLD[1]);
        }
        ItemExAttributes.apply(it, exp);
        prefixFactor = AFFIX_FACTOR_BASE + (GetItemLevel(it) - 1) * AFFIX_FACTOR_DELTA;
        sufixFactor = prefixFactor * SUFIX_MULTIPLIER;
        prob = lootValue / prefixFactor + PREFIX_STATIC_MOD;
        prefixDone = false;
        if (prob > 1.0) {
            prob1 = prob - 1.0;
            if (prob1 > PREFIX_MAX_PROB) {
                prob1 = PREFIX_MAX_PROB;
            }
            if (GetRandomReal(0, 1) < prob1) {
                prefixDone = true;
                ItemExAttributes.appendAffix(it, ItemAffix.instantiate(ipPrefix2.get()));
            }
        }
        if (prefixDone == false) {
            if (GetRandomReal(0, 1) < prob) {
                prefixDone = true;
                ItemExAttributes.appendAffix(it, ItemAffix.instantiate(ipPrefix1.get()));
            }
        }
        prob = (lootValue - prefixFactor) / sufixFactor + SUFIX_STATIC_MOD;
        if (prob > SUFIX_MAX_PROB) {
            prob = SUFIX_MAX_PROB;
        }
        if (GetRandomReal(0, 1) < prob) {
            ItemExAttributes.appendAffix(it, ItemAffix.instantiate(ipSufix.get()));
        }
        ItemExAttributes.updateUbertip(it);
        ItemExAttributes.updateName(it);
        // itemName = GetAllItemAffixesText(it, 1);
        // BlzSetItemTooltip(it, itemName);
        // BlzSetItemName(it, itemName);
        // print("Set item " + I2HEX(GetHandleId(it)) + " name to: " + itemName);
        return it;
    }

    function itemon() -> boolean {
        item it = GetManipulatedItem();
        integer itid = GetItemTypeId(it);
        integer i;
        item tmpi;
        unit u = GetTriggerUnit();
        ItemExAttributes attr;
        ItemAttributeMeta meta;
        attr = ItemExAttributes.inst(it, "item on");
        while (attr != 0) {
            meta = ItemAttributeMeta.inst(attr.id, "item on");
            if (meta != 0) {
                meta.callback.evaluate(u, attr.value, 1);
            }
            attr = attr.next;
        }
        // stack charges
        if (IsItemTypeConsumable(itid)) {
            i = 0;
            while (i < 6) {
                tmpi = UnitItemInSlot(u, i);
                if (GetItemTypeId(tmpi) == itid && GetHandleId(tmpi) != GetHandleId(it)) {
                    SetItemCharges(tmpi, GetItemCharges(tmpi) + GetItemCharges(it));
                    RemoveItem(it);
                    i += 6;
                }
                i += 1;
                tmpi = null;
            }
        }
        u = null;
        it = null;
        return false;
    }
    
    function itemoff() -> boolean {
        // integer itid = GetItemTypeId(GetManipulatedItem());
        ItemExAttributes attr;
        ItemAttributeMeta meta;
        attr = ItemExAttributes.inst(GetManipulatedItem(), "itemoff");
        ItemExAttributes.droppingItem = GetManipulatedItem();
        while (attr != 0) {
            meta = ItemAttributeMeta.inst(attr.id, "item off");
            if (meta != 0) {
                meta.callback.evaluate(GetTriggerUnit(), attr.value, -1);
            }
            attr = attr.next;
        }
        ItemExAttributes.droppingItem = null;
        return false;
    }

    struct ItemAttributeMeta {
        static Table ht;
        integer sort;
        integer cate;
        string str1, str2;
        real lpAmp;
        ItemAttributeCallback callback;

        static method inst(integer id, string trace) -> thistype {
            if (thistype.ht.exists(id)) {
                return thistype.ht[id];
            } else {
                print("ItemAttributeMeta.inst not found: " + ID2S(id) + ", trace: " + trace);
                return 0;
            }
        }

        static method create(integer id, integer cate, integer sort, real lpAmp, string str1, string str2, ItemAttributeCallback callback) -> thistype {
            thistype this = thistype.allocate();
            thistype.ht[id] = this;
            this.cate = cate;
            this.sort = sort;
            this.lpAmp = lpAmp;
            this.str1 = str1;
            this.str2 = str2;
            this.callback = callback;
            return this;
        }

        static method callbackSTR(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackSTR").ModStr(Rounding(val) * polar);
        }
        static method callbackSTRPL(unit u, real val, integer polar) {
            print("[Warn] callbackSTRPL not implemented");
        }
        static method callbackAGI(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackAGI").ModAgi(Rounding(val) * polar);
        }
        static method callbackINT(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackINT").ModInt(Rounding(val) * polar);
        }
        static method callbackALLSTAT(unit u, real val, integer polar) {
            UnitProp up = UnitProp.inst(u, "ItemAttributeMeta.callback7");
            up.ModStr(Rounding(val) * polar);
            up.ModAgi(Rounding(val) * polar);
            up.ModInt(Rounding(val) * polar);
        }
        static method callbackHP(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackHP").ModLife(Rounding(val) * polar);
        }
        static method callbackHPPCT(unit u, real val, integer polar) {
            print("[Warn] callbackHPPCT not implemented");
        }
        static method callbackHPPL(unit u, real val, integer polar) {
            print("[Warn] callbackHPPL not implemented");
        }
        static method callbackMP(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackMP").ModMana(Rounding(val) * polar);
        }
        static method callbackAP(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackAP").ModAP(Rounding(val) * polar);
        }
        static method callbackAPPL(unit u, real val, integer polar) {
            print("[Warn] callbackAPPL not implemented");
        }
        static method callbackCRIT(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackAP").attackCrit += val * polar;
        }
        static method callbackIAS(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackIAS").ModAttackSpeed(Rounding(val) * polar);
        }
        static method callbackSP(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackAP").spellPower += val * polar;
        }
        static method callbackSCRIT(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackAP").spellCrit += val * polar;
        }
        static method callbackSHASTE(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackAP").spellHaste += val * polar;
        }
        static method callbackDEF(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackIAS").ModArmor(Rounding(val) * polar);
        }
        static method callbackDEFPL(unit u, real val, integer polar) {
            print("[Warn] callbackDEFPL not implemented");
        }
        static method callbackBR(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackAP").blockRate += val * polar;
        }
        static method callbackBP(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackAP").blockPoint += val * polar;
        }
        static method callbackDODGE(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackAP").dodge += val * polar;
        }
        static method callbackDR(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackAP").damageTaken -= val * polar;
        }
        static method callbackMDR(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackAP").spellTaken -= val * polar;
        }
        static method callbackAMP(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackAP").damageDealt += val * polar;
        }
        static method callbackHAMP(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackAP").healTaken += val * polar;
        }
        static method callbackMREG(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackAP").manaRegen += val * polar;
        }
        static method callbackHREG(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackAP").lifeRegen += val * polar;
        }
        static method callbackHLOST(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackAP").lifeRegen -= val * polar;
        }
        static method callbackMS(unit u, real val, integer polar) {
            UnitProp.inst(u, "callbackIAS").ModSpeed(Rounding(val) * polar);
        }
        static method callbackMSPL(unit u, real val, integer polar) {
            print("[Warn] callbackMSPL not implemented");
        }
        static method callbackLP(unit u, real val, integer polar) {}
        static method callbackBM_VALOR(unit u, real val, integer polar) {}
        static method callbackRG_ONESHOT(unit u, real val, integer polar) {
            EquipedOneshotLowHealth(u, polar);
        }
        static method callbackRG_RUSH(unit u, real val, integer polar) {}
        static method callbackCRKILLER(unit u, real val, integer polar) {}
        static method callbackMCVT(unit u, real val, integer polar) {
            EquipedConvertAttackMagic(u, polar);
        }
        static method callbackKG_REGRCD(unit u, real val, integer polar) {}
        static method callbackLEECHAURA(unit u, real val, integer polar) {}
        static method callbackPR_POHDEF(unit u, real val, integer polar) {}
        static method callbackDR_MAXHP(unit u, real val, integer polar) {}
        static method callbackPL_SHOCK(unit u, real val, integer polar) {}
        static method callbackPR_SHIELD(unit u, real val, integer polar) {}
        static method callbackCT_PAIN(unit u, real val, integer polar) {}
        static method callbackBD_SHIELD(unit u, real val, integer polar) {}
        static method callbackRG_PARALZ(unit u, real val, integer polar) {}
        static method callbackPL_LIGHT(unit u, real val, integer polar) {}
        static method callbackDR_CDR(unit u, real val, integer polar) {
            EquipedReforgedBadgeOfTenacity(u, polar);
        }
        static method callbackSM_LASH(unit u, real val, integer polar) {}
        static method callbackDK_ARROW(unit u, real val, integer polar) {}
        static method callbackMG_FDMG(unit u, real val, integer polar) {}
        static method callbackMG_BLZ(unit u, real val, integer polar) {}
        static method callbackATK_ML(unit u, real val, integer polar) {
            UnitProp.inst(u, "ItemAttributeMeta.callback45").ml += val * polar;
        }
        static method callbackATK_LL(unit u, real val, integer polar) {
            UnitProp.inst(u, "ItemAttributeMeta.callback45").ll += val * polar;
        }
        static method callbackATK_LLML(unit u, real val, integer polar) {
            UnitProp up = UnitProp.inst(u, "ItemAttributeMeta.callback45");
            up.ll += val * polar;
            up.ml += val * polar;
        }
        static method callbackATK_CTHUN(unit u, real val, integer polar) {
            EquipedAttackStackableIAS(u, polar);
        }
        static method callbackATK_WF(unit u, real val, integer polar) {
            EquipedWindforce(u, polar);
        }
        static method callbackATK_LION(unit u, real val, integer polar) {
            EquipedLionHorn(u, polar);
        }
        static method callbackATK_MOONWAVE(unit u, real val, integer polar) {}
        static method callbackATK_POISNOVA(unit u, real val, integer polar) {
            EquipedBOTD(u, polar);
        }
        static method callbackATK_COIL(unit u, real val, integer polar) {}
        static method callbackATK_BLEED(unit u, real val, integer polar) {}
        static method callbackATK_MDC(unit u, real val, integer polar) {
            EquipedChanceMagicDamage(u, polar);
        }
        static method callbackATK_STUN(unit u, real val, integer polar) {}
        static method callbackATK_CRIT(unit u, real val, integer polar) {}
        static method callbackATK_AMP(unit u, real val, integer polar) {
            EquipedAttackAmplifiedDamage(u, polar);
        }
        static method callbackATK_MD(unit u, real val, integer polar) {
            EquipedExtraMagicDamage(u, polar);
        }
        static method callbackATK_MDK(unit u, real val, integer polar) {}
        static method callbackATK_MORTAL(unit u, real val, integer polar) {
            EquipedAttackDecreaseHealed(u, polar);
        }
        static method callbackATK_MISS(unit u, real val, integer polar) {
            EquipedAttackDecreaseAttackRate(u, polar);
        }
        static method callbackATK_DDEF(unit u, real val, integer polar) {
            EquipedAttackDecreaseArmor(u, polar);
        }
        static method callbackATK_DAS(unit u, real val, integer polar) {
            EquipedAttackDecreaseAttackSpeed(u, polar);
        }
        static method callbackATK_DMS(unit u, real val, integer polar) {
            EquipedAttackDecreaseMoveSpeed(u, polar);
        }
        static method callbackATK_WEAK(unit u, real val, integer polar) {
            EquipedAttackDecreaseDamage(u, polar);
        }
        static method callback3ATK_MOONEXP(unit u, real val, integer polar) {}
        static method callbackMD_MREGEN(unit u, real val, integer polar) {
            EquipedTidalLoop(u, polar);
        }
        static method callbackMD_POISON(unit u, real val, integer polar) {
            EquipedMagicPoison(u, polar);
        }
        static method callbackMD_CHAIN(unit u, real val, integer polar) {
            EquipedMagicChainLightning(u, polar);
        }
        static method callbackMDC_ARCANE(unit u, real val, integer polar) {
            EquipedPureArcane(u, polar);
        }
        static method callbackDT_MREGEN(unit u, real val, integer polar) {
            UnitProp.inst(u, "ItemAttributeMeta.callback45").damageGoesMana += val * polar;
        }
        static method callbackATKED_WEAK(unit u, real val, integer polar) {
            EquipedCursedCuirass(u, polar);
        }
        static method callbackHEAL_HOLY(unit u, real val, integer polar) {
            EquipedHealedStackHoly(u, polar);
        }
        static method callbackAURA_CONVIC(unit u, real val, integer polar) {
            EquipedConvictionAura(u, polar);
        }
        static method callbackAURA_MEDITA(unit u, real val, integer polar) {
            EquipedInsightAura(u, polar);
        }
        static method callbackAURA_WARSONG(unit u, real val, integer polar) {
            EquipedWarsongAura(u, polar);
        }
        static method callbackAURA_UNHOLY(unit u, real val, integer polar) {}
        static method callbackUSE_TP(unit u, real val, integer polar) {}
        static method callbackUSE_BATTLE(unit u, real val, integer polar) {}
        static method callbackUSE_MREGEN(unit u, real val, integer polar) {}
        static method callbackUSE_HREGEN(unit u, real val, integer polar) {}
        static method callbackUSE_VOODOO(unit u, real val, integer polar) {
            EquipedVoodooVials(u, polar);
        }
        static method callbackUSE_INT(unit u, real val, integer polar) {}
        static method callbackUSE_SP(unit u, real val, integer polar) {}
        static method callbackUSE_DODGE(unit u, real val, integer polar) {}
        static method callbackUSE_MS(unit u, real val, integer polar) {}
        static method callbackUSE_CTHUN(unit u, real val, integer polar) {}
        static method callbackUSE_HOLYHEAL(unit u, real val, integer polar) {}

        static method onInit() {
            thistype.ht = Table.create();
thistype.create(IATTR_STR,1,100,0,"+"," Strength",thistype.callbackSTR);
thistype.create(IATTR_STRPL,1,101,0,"+"," Strength/level",thistype.callbackSTRPL);
thistype.create(IATTR_AGI,1,102,0,"+"," Agility",thistype.callbackAGI);
thistype.create(IATTR_INT,1,104,0,"+"," Intelligence",thistype.callbackINT);
thistype.create(IATTR_ALLSTAT,1,106,0,"+"," All stats",thistype.callbackALLSTAT);
thistype.create(IATTR_HP,1,110,0,"+"," Max HP",thistype.callbackHP);
thistype.create(IATTR_HPPCT,1,111,0,"+"," Max HP",thistype.callbackHPPCT);
thistype.create(IATTR_HPPL,1,112,0,"+"," Max HP/level",thistype.callbackHPPL);
thistype.create(IATTR_MP,1,114,0,"+"," Max MP",thistype.callbackMP);
thistype.create(IATTR_AP,1,120,0,"+"," Attack power",thistype.callbackAP);
thistype.create(IATTR_APPL,1,121,0,"+"," Attack power/level",thistype.callbackAPPL);
thistype.create(IATTR_CRIT,1,122,0,"+"," Attack critical",thistype.callbackCRIT);
thistype.create(IATTR_IAS,1,124,0,"+","% Attack speed",thistype.callbackIAS);
thistype.create(IATTR_SP,1,130,0,"+"," Spell power",thistype.callbackSP);
thistype.create(IATTR_SCRIT,1,132,0,"+"," Spell critical",thistype.callbackSCRIT);
thistype.create(IATTR_SHASTE,1,134,0,"+"," Spell haste",thistype.callbackSHASTE);
thistype.create(IATTR_DEF,1,140,0,"+"," Armor",thistype.callbackDEF);
thistype.create(IATTR_DEFPL,1,141,0,"+"," Armor/level",thistype.callbackDEFPL);
thistype.create(IATTR_BR,1,142,0,"+"," Block chance",thistype.callbackBR);
thistype.create(IATTR_BP,1,144,0,"+"," Block points",thistype.callbackBP);
thistype.create(IATTR_DODGE,1,146,0,"+"," Dodge chance",thistype.callbackDODGE);
thistype.create(IATTR_DR,1,150,0,"-"," All damage taken",thistype.callbackDR);
thistype.create(IATTR_MDR,1,152,0,"-"," magic damage taken",thistype.callbackMDR);
thistype.create(IATTR_AMP,1,154,0,"+"," Damage and healing dealt",thistype.callbackAMP);
thistype.create(IATTR_HAMP,1,156,0,"+"," Healing taken",thistype.callbackHAMP);
thistype.create(IATTR_MREG,1,160,0,"Regens "," MP per second",thistype.callbackMREG);
thistype.create(IATTR_HREG,1,162,0,"Regens "," HP per second",thistype.callbackHREG);
thistype.create(IATTR_HLOST,1,164,0,"Lost "," HP per second during combat",thistype.callbackHLOST);
thistype.create(IATTR_MS,1,170,0,"+"," Movement speed",thistype.callbackMS);
thistype.create(IATTR_MSPL,1,171,0,"+"," Movement speed/level",thistype.callbackMSPL);
thistype.create(IATTR_LP,1,195,0,"Improve item |cff33ff33special power|r + ","",thistype.callbackLP);
thistype.create(IATTR_ATK_ML,3,200,0,"|cff87ceeb+"," Mana stolen per hit|r",thistype.callbackATK_ML);
thistype.create(IATTR_ATK_LL,3,202,0,"|cff87ceeb+"," Life stolen per hit|r",thistype.callbackATK_LL);
thistype.create(IATTR_ATK_LLML,3,204,0,"|cff87ceeb+"," Life and mana stolen per hit|r",thistype.callbackATK_LLML);
thistype.create(IATTR_ATK_MD,3,210,0,"|cff87ceebDeals "," extra magic damage per hit|r",thistype.callbackATK_MD);
thistype.create(IATTR_ATK_MDK,3,211,0,"|cff87ceebDeals "," extra magic damage per hit, scaled up by target HP lost|r",thistype.callbackATK_MDK);
thistype.create(IATTR_RG_ONESHOT,3,250,0,"|cff87ceebOne-shot target when it's HP is less than yours","|r",thistype.callbackRG_ONESHOT);
thistype.create(IATTR_MCVT,3,253,0,"|cff87ceebConverts your normal attacks into magic damage","|r",thistype.callbackMCVT);
thistype.create(IATTR_PL_SHOCK,3,256,0,"|cff87ceebHoly Shock always deals critical healing","|r",thistype.callbackPL_SHOCK);
thistype.create(IATTR_PR_SHIELD,3,259,0,"|cff87ceebRemoves weakness effect of Shield","|r",thistype.callbackPR_SHIELD);
thistype.create(IATTR_PL_LIGHT,3,262,0,"|cff87ceebFlash Light dispels one debuff from target","|r",thistype.callbackPL_LIGHT);
thistype.create(IATTR_DT_MREGEN,3,266,0,"|cff87ceebRegens MP from "," of the damage taken|r",thistype.callbackDT_MREGEN);
thistype.create(IATTR_USE_TP,3,268,0,"|cff87ceebUse: Teleports to an ally","|r",thistype.callbackUSE_TP);
thistype.create(IATTR_BM_VALOR,2,300,0.33,"|cff33ff33Regenerates "," more valor points|r",thistype.callbackBM_VALOR);
thistype.create(IATTR_RG_RUSH,2,302,0.16,"|cff33ff33Sinister Strike and Eviscerate deal "," extra damage to target below 30% max HP|r",thistype.callbackRG_RUSH);
thistype.create(IATTR_CRKILLER,2,303,0.5,"|cff33ff33Deals "," extra damage to non-hero targets|r",thistype.callbackCRKILLER);
thistype.create(IATTR_KG_REGRCD,2,305,0.33,"|cff33ff33Reduce cooldown of Instant Regrowth by "," seconds (unique)|r",thistype.callbackKG_REGRCD);
thistype.create(IATTR_LEECHAURA,2,307,0.33,"|cff33ff33Absorb "," HP from all enemies nearby every second|r",thistype.callbackLEECHAURA);
thistype.create(IATTR_PR_POHDEF,2,308,0.2,"|cff33ff33Prayer of healing increases armor of target by ","|r",thistype.callbackPR_POHDEF);
thistype.create(IATTR_DR_MAXHP,2,310,0.16,"|cff33ff33Survival Instincts provides "," extra healing and max HP|r",thistype.callbackDR_MAXHP);
thistype.create(IATTR_CT_PAIN,2,313,0.4,"|cff33ff33Marrow Squeeze extends the Pain on target by "," seconds|r",thistype.callbackCT_PAIN);
thistype.create(IATTR_BD_SHIELD,2,314,0.33,"|cff33ff33Shield of Sin'dorei provides "," extra damage reduction, and forces all nearby enemies to attack you|r",thistype.callbackBD_SHIELD);
thistype.create(IATTR_RG_PARALZ,2,315,0.33,"|cff33ff33Sinister Strike has a "," chance to paralyze target, reduce target spell haste by 20% and gain an extra combo point|r",thistype.callbackRG_PARALZ);
thistype.create(IATTR_DR_CDR,2,317,0.16,"|cff33ff33Reduce cooldown of Survival Instincts by "," seconds (unique)|r",thistype.callbackDR_CDR);
thistype.create(IATTR_SM_LASH,2,318,0.1,"|cff33ff33Storm Lash has "," extra chance to cooldown Earth Shock (unique)|r",thistype.callbackSM_LASH);
thistype.create(IATTR_DK_ARROW,2,319,0.12,"|cff33ff33Number of Dark Arrows increased by "," (unique)|r",thistype.callbackDK_ARROW);
thistype.create(IATTR_MG_FDMG,2,320,0.2,"|cff33ff33Increase ice spell damage by ","|r",thistype.callbackMG_FDMG);
thistype.create(IATTR_MG_BLZ,2,322,0.16,"|cff33ff33"," chance to cast an instant Frost Bolt to targets damaged by Blizzard|r",thistype.callbackMG_BLZ);
thistype.create(IATTR_ATK_CTHUN,2,403,0.15,"|cff33ff33On Attack: Increase attack speed by 1% per attack, stacks up to ",", lasts for 3 seconds|r",thistype.callbackATK_CTHUN);
thistype.create(IATTR_ATK_WF,2,404,0.2,"|cff33ff33On Attack: "," chance to knock back target|r",thistype.callbackATK_WF);
thistype.create(IATTR_ATK_LION,2,405,0.16,"|cff33ff33On Attack: "," chance to increase 30% attack speed, lasts for 5 seconds|r",thistype.callbackATK_LION);
thistype.create(IATTR_ATK_MOONWAVE,2,406,0.7,"|cff33ff33On Attack: 10% chance to consume 5% of max MP, deals "," magic damage to all enemies in a row|r",thistype.callbackATK_MOONWAVE);
thistype.create(IATTR_ATK_POISNOVA,2,407,0.7,"|cff33ff33On Attack: 15% chance to cast poison nova, dealing "," magic damage over time to all enemies within 600 yards|r",thistype.callbackATK_POISNOVA);
thistype.create(IATTR_ATK_COIL,2,408,0.7,"|cff33ff33On Attack: 15% chance to cast Death Coil, deals "," magic damage to target. Target takes 3% extra damge|r",thistype.callbackATK_COIL);
thistype.create(IATTR_ATK_BLEED,2,409,0.7,"|cff33ff33On Attack: 20% chance to deal bleed effect to target. Target takes "," physical damage over time, lasts for 10 seconds|r",thistype.callbackATK_BLEED);
thistype.create(IATTR_ATK_MDC,2,410,0.7,"|cff33ff33On Attack: 25% chance to deal "," magic damage to target|r",thistype.callbackATK_MDC);
thistype.create(IATTR_ATK_STUN,2,411,0.2,"|cff33ff33On Attack: 5% chance to stun target for "," seconds|r",thistype.callbackATK_STUN);
thistype.create(IATTR_ATK_CRIT,2,412,0.2,"|cff33ff33On Attack: 5% chance to increase "," attack critical chance, lasts for 5 seconds|r",thistype.callbackATK_CRIT);
thistype.create(IATTR_ATK_AMP,2,413,0.1,"|cff33ff33On Attack: Target takes "," extra damage|r",thistype.callbackATK_AMP);
thistype.create(IATTR_ATK_MORTAL,2,416,0.1,"|cff33ff33On Attack: Decrease target healing taken by ","|r",thistype.callbackATK_MORTAL);
thistype.create(IATTR_ATK_MISS,2,417,0.1,"|cff33ff33On Attack: Decrease target attack hit chance by ","|r",thistype.callbackATK_MISS);
thistype.create(IATTR_ATK_DDEF,2,418,0.1,"|cff33ff33On Attack: Decrease target armor by ","|r",thistype.callbackATK_DDEF);
thistype.create(IATTR_ATK_DAS,2,419,0.1,"|cff33ff33On Attack: Decrease target attack speed by ","|r",thistype.callbackATK_DAS);
thistype.create(IATTR_ATK_DMS,2,420,0.1,"|cff33ff33On Attack: Decrease target movement speed by ","|r",thistype.callbackATK_DMS);
thistype.create(IATTR_ATK_WEAK,2,421,0.1,"|cff33ff33On Attack: Decrease target damage and healing dealt by ","|r",thistype.callbackATK_WEAK);
thistype.create(IATTR_3ATK_MOONEXP,2,430,0.7,"|cff33ff33Every Third Attack: Consumes 5% of max MP, deals "," magic damage to all enemies nearby|r",thistype.callback3ATK_MOONEXP);
thistype.create(IATTR_MD_MREGEN,2,450,0.5,"|cff33ff33Dealing Magic Damage: 1% chance to regen "," MP|r",thistype.callbackMD_MREGEN);
thistype.create(IATTR_MD_POISON,2,451,0.7,"|cff33ff33Dealing Magic Damage: 10% chance to poison target, dealing "," magic damage over time|r",thistype.callbackMD_POISON);
thistype.create(IATTR_MD_CHAIN,2,452,0.7,"|cff33ff33Dealing Magic Damage: 10% chance to cast Chain Lightning to target, dealing "," magic damage|r",thistype.callbackMD_CHAIN);
thistype.create(IATTR_MDC_ARCANE,2,460,0.5,"|cff33ff33Magic Damage Critical: Charges with arcane power. All arcane power will be released automatically after 3 stacks, dealing "," magic damage to target|r",thistype.callbackMDC_ARCANE);
thistype.create(IATTR_HEAL_HOLY,2,501,0.33,"|cff33ff33On Healed: Charges 1 holy power, stacks up to "," points|r",thistype.callbackHEAL_HOLY);
thistype.create(IATTR_ATKED_WEAK,2,600,0.33,"|cff33ff33On Attacked: Decreases attacker's attack power by ","|r",thistype.callbackATKED_WEAK);
thistype.create(IATTR_AURA_CONVIC,2,800,0.1,"|cff33ff33Grant Aura of Conviction: All enemies within 600 yards take "," more magic damage|r",thistype.callbackAURA_CONVIC);
thistype.create(IATTR_AURA_MEDITA,2,801,0.2,"|cff33ff33Grant Aura of Meditation: All allies within 600 yards regen "," MP per second|r",thistype.callbackAURA_MEDITA);
thistype.create(IATTR_AURA_WARSONG,2,802,0.1,"|cff33ff33Grant Aura of Warsong: All allies deal "," more damage and healing, take 10% more healing within 600 yards|r",thistype.callbackAURA_WARSONG);
thistype.create(IATTR_AURA_UNHOLY,2,803,0.7,"|cff33ff33Grant Aura of Unholy: All allies within 600 yards regen "," HP per second|r",thistype.callbackAURA_UNHOLY);
thistype.create(IATTR_USE_BATTLE,2,901,0.16,"|cff33ff33Use: Battle Orders, increases "," max HP to all allies within 900 yards, lasts for 75 seconds|r",thistype.callbackUSE_BATTLE);
thistype.create(IATTR_USE_MREGEN,2,902,0.4,"|cff33ff33Use: Regens "," MP|r",thistype.callbackUSE_MREGEN);
thistype.create(IATTR_USE_HREGEN,2,903,0.4,"|cff33ff33Use: Regens "," HP|r",thistype.callbackUSE_HREGEN);
thistype.create(IATTR_USE_VOODOO,2,904,0.2,"|cff33ff33Use: Deals "," magic damage to all enemies within range over time|r",thistype.callbackUSE_VOODOO);
thistype.create(IATTR_USE_INT,2,905,0.3,"|cff33ff33Use: Increase intelligence by ",", lasts for 20 seconds|r",thistype.callbackUSE_INT);
thistype.create(IATTR_USE_SP,2,906,0.3,"|cff33ff33Use: Increase spell power by ",", lasts for 15 seconds|r",thistype.callbackUSE_SP);
thistype.create(IATTR_USE_DODGE,2,907,0.1,"|cff33ff33Use: Increase dodge chance by 30%, lasts for "," seconds|r",thistype.callbackUSE_DODGE);
thistype.create(IATTR_USE_MS,2,908,0.1,"|cff33ff33Use: Increase movement speed by 300, lasts for "," seconds. Possible failures.|r",thistype.callbackUSE_MS);
thistype.create(IATTR_USE_CTHUN,2,909,-0.33,"|cff33ff33Use: Increase attack speed by 100%, take "," extra damage (unique)|r",thistype.callbackUSE_CTHUN);
thistype.create(IATTR_USE_HOLYHEAL,2,910,0.33,"|cff33ff33Use: Release all holy power to heal yourself, each point heals "," HP|r",thistype.callbackUSE_HOLYHEAL);
        }
    }

    function onInit() {
        ItemAttributes = Table.create();
        
        TriggerAnyUnit(EVENT_PLAYER_UNIT_PICKUP_ITEM, function itemon);
        TriggerAnyUnit(EVENT_PLAYER_UNIT_DROP_ITEM, function itemoff);

        ipPrefix1 = IntegerPool.create();
        ipPrefix2 = IntegerPool.create();
        ipSufix = IntegerPool.create();

        ipPrefix1.add(PREFIX_HEAVY, 10);
        ipPrefix1.add(PREFIX_SHARP, 10);
        ipPrefix1.add(PREFIX_SHIMERING, 10);
        ipPrefix1.add(PREFIX_ENDURABLE, 10);
        ipPrefix1.add(PREFIX_SKILLED, 10);
        ipPrefix1.add(PREFIX_ENCHANTED, 10);
        ipPrefix1.add(PREFIX_MYSTERIOUS, 10);
        ipPrefix1.add(PREFIX_STEADY, 10);

        ipPrefix2.add(PREFIX_STRONG, 10);
        ipPrefix2.add(PREFIX_AGILE, 10);
        ipPrefix2.add(PREFIX_INTELLIGENT, 10);
        ipPrefix2.add(PREFIX_VIBRANT, 10);
        ipPrefix2.add(PREFIX_CRUEL, 10);
        ipPrefix2.add(PREFIX_SORCEROUS, 10);
        ipPrefix2.add(PREFIX_ETERNAL, 10);
        ipPrefix2.add(PREFIX_TOUGH, 10);

        ipSufix.add(SUFIX_LETHALITY, 10);
        ipSufix.add(SUFIX_SNAKE, 10);
        ipSufix.add(SUFIX_QUICKNESS, 10);
        ipSufix.add(SUFIX_WIND_SERPENT, 10);
        ipSufix.add(SUFIX_BRUTE, 10);
        ipSufix.add(SUFIX_DEXTERITY, 10);
        ipSufix.add(SUFIX_WISDOM, 10);
        ipSufix.add(SUFIX_VITALITY, 10);
        ipSufix.add(SUFIX_CHAMPION, 10);
        ipSufix.add(SUFIX_BUTCHER, 10);
        ipSufix.add(SUFIX_ASSASSIN, 10);
        ipSufix.add(SUFIX_RANGER, 10);
        ipSufix.add(SUFIX_WIZARD, 10);
        ipSufix.add(SUFIX_PRIEST, 10);
        ipSufix.add(SUFIX_GUARDIAN, 10);
        ipSufix.add(SUFIX_MASTERY, 100);
        ipSufix.add(SUFIX_BLUR, 10);
        ipSufix.add(SUFIX_STRONGHOLD, 10);
        ipSufix.add(SUFIX_DEEP_SEA, 10);
        ipSufix.add(SUFIX_VOID, 10);
    }
}
//! endzinc
