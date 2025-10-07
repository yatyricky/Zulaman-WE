Zul'Aman - Reinvented with World Editor
===
*My old Warcraft III World Editor project that pains in my ass.*

## System Requirements

- Windows NT
- Warcraft III Reforged 1.36
- Nodejs

You can try other versions, but not tested.

Not compatible with version lower than 1.29 because of the item editing APIs.

## Build

1. Create a file named `config.json` and config wc3path to your wc3 installation path
2. Use the new combined CLI:

### Quick Start
```bash
# Build and run the map
npm start
# or
node index.js run

# Build only
npm run build
# or  
node index.js build

# Run without building (use existing build)
npm run run
# or
node index.js run --no-build

# Watch last replay
npm run replay
# or
node index.js replay
```

### Windows Batch File
For convenience, you can also use the included batch file:
```cmd
# Build and run
zam.bat run

# Build only
zam.bat build

# Show help
zam.bat help
```

### Legacy Commands
The original separate files (`make.js`, `run.js`, `replay.js`) are still available if needed:
```bash
node make.js    # Build only
node run.js     # Build and run
node replay.js  # Watch replay
```

## Map Information

**Category**：RPG  
**Players**：1-6

## 11 Classes

Originally from WOW, redesigned to fit WC3 gameplay.

Hero | Type | Abilities
---|---|---
Bloodelf Defender | Tank | Shield Block, Sunfire Storm, Arcane Shock, Discord, Shield of Sin'dorei
Claw Druid | Tank | Lacerate, Savage Roar, Forest Cure, Natural Reflex, Survival Instincts
Keeper of the Grove | Healer | Life Bloom, Rejuvenation, Regrowth, Swiftmend, Tranquility
Paladin | Healer | Flash of Light, Holy Light, Holy Shock, Divine Favour, Beacon of Light
Priest | Healer | Heal, Dispel, Shield, Prayer of Mending, Prayer of Healing
Blade Master | Melee DPSer | Heroic Strike, Rend, Overpower, Mortal Strike, Execute
Dark Ranger | Ranged DPSer | Dark Arrow, Concentrate, Frost Trap, Power of Banshee, Death Pact
Rouge | Melee DPSer | Sinister Strike, Eviscerate, Assault, Blade Flurry, Stealth
Frost Mage | Magical DPSer | Frost Bolt, Blizzard, Frost Nova, Polymorph, Spell Transfer
Earth Binder | Magical DPSer | Storm Lash, Earth Shock, Purge, Enchanted Totem, Ascendance
Cultist | Magical DPSer | Pain, Marrow Squeeze, Mind Flay, Death, Terror

## Diablo-like Items

Every loot is different. Not fond of the affixes? Reforge it!

## Screenshots (Editor)

![](https://github.com/yatyricky/Zulaman-WE/blob/master/design/sc1.jpg)

![](https://github.com/yatyricky/Zulaman-WE/blob/master/design/sc2.jpg)
