#!/usr/bin/env node

const fs = require("fs")
const os = require("os")
const path = require("path")
const child_process = require("child_process")

// Configuration loader functionality (from funcs.js)
function loadConfig() {
    if (!fs.existsSync("config.json")) {
        fs.writeFileSync("config.json", "{\"wc3path\": \"\"}")
        console.log("Please edit config.json")
        process.exit(1)
    }
    
    const config = JSON.parse(fs.readFileSync("config.json").toString())
    return config
}

// Build functionality (from make.js)
function buildMap() {
    console.log("Building map...")
    
    if (!fs.existsSync("build")) {
        fs.mkdirSync("build")
    } else if (fs.statSync("build").isFile()) {
        fs.unlinkSync("build")
        fs.mkdirSync("build")
    }

    fs.copyFileSync("./ZAM_ruins.w3x", "./build/ZAM_ruins.w3x")

    const config = loadConfig()
    const fpJassHelper = path.join(config.wc3path, "_retail_/x86_64/JassHelper/jasshelper.exe")

    try {
        child_process.execSync(`"${fpJassHelper}" .\\assets\\data\\common.j .\\assets\\data\\blizzard.j .\\build\\ZAM_ruins.w3x`)
        console.log("Build completed successfully!")
    } catch (error) {
        console.error("Build failed:", error.message)
        process.exit(1)
    }
}

// Run functionality (from run.js)
function runGame(shouldBuild = true) {
    if (shouldBuild) {
        buildMap()
    }

    console.log("Starting Warcraft III...")
    
    const config = loadConfig()
    const fpExec = path.join(config.wc3path, "_retail_/x86_64/Warcraft III.exe")

    try {
        child_process.execSync(`"${fpExec}" -launch -window -loadfile "${path.join(__dirname, "build/ZAM_ruins.w3x")}"`)
    } catch (error) {
        console.error("Failed to start Warcraft III:", error.message)
        process.exit(1)
    }
}

// Replay functionality (from replay.js)
function runReplay() {
    console.log("Starting replay...")
    
    const config = loadConfig()
    const fpExec = path.join(config.wc3path, "_retail_/x86_64/Warcraft III.exe")
    const replayPath = path.join(os.homedir(), "Documents/Warcraft III/BattleNet/user_id/Replays/LastReplay.w3g")

    try {
        child_process.execSync(`"${fpExec}" -launch -window -loadfile "${replayPath}"`)
    } catch (error) {
        console.error("Failed to start replay:", error.message)
        process.exit(1)
    }
}

// Help function
function showHelp() {
    console.log(`
Zul'Aman World Editor Project CLI

Usage: node index.js [command] [options]

Commands:
  build                 Build the map using JassHelper
  run                   Build and run the map in Warcraft III
  run --no-build        Run the map without building (use existing build)
  replay                Launch the last replay in Warcraft III
  help                  Show this help message

Examples:
  node index.js build           # Build the map
  node index.js run             # Build and run the map
  node index.js run --no-build  # Run without building
  node index.js replay          # Watch last replay

Configuration:
  The first time you run this, a config.json file will be created.
  Edit it to set your Warcraft III installation path.
`)
}

// Main function to handle command line arguments
function main() {
    const args = process.argv.slice(2)
    
    if (args.length === 0) {
        showHelp()
        return
    }

    const command = args[0].toLowerCase()
    
    switch (command) {
        case 'build':
            buildMap()
            break
            
        case 'run':
            const noBuild = args.includes('--no-build')
            runGame(!noBuild)
            break
            
        case 'replay':
            runReplay()
            break
            
        case 'help':
        case '--help':
        case '-h':
            showHelp()
            break
            
        default:
            console.error(`Unknown command: ${command}`)
            console.log('Use "node index.js help" for usage information.')
            process.exit(1)
    }
}

// Run the main function
if (require.main === module) {
    main()
}

// Export functions for potential require() usage
module.exports = {
    loadConfig,
    buildMap,
    runGame,
    runReplay,
    showHelp
}