const fs = require("fs")
const path = require("path")
const child_process = require("child_process")
const config = require("./funcs")

if (!fs.existsSync("build")) {
    fs.mkdirSync("build")
} else if (fs.statSync("build").isFile()) {
    fs.unlinkSync("build")
    fs.mkdirSync("build")
}

fs.copyFileSync("./ZAM_ruins.w3x", "./build/ZAM_ruins.w3x")

const fpJassHelper = path.join(config.wc3path, "_retail_/x86_64/JassHelper/jasshelper.exe")

child_process.execSync(`"${fpJassHelper}" .\\assets\\data\\common.j .\\assets\\data\\blizzard.j .\\build\\ZAM_ruins.w3x`)
