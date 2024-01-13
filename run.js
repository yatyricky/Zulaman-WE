const path = require("path")
const child_process = require("child_process")
const config = require("./funcs")

if (process.argv[2] === undefined) {
    require("./make")
}

const fpExec = path.join(config.wc3path, "_retail_/x86_64/Warcraft III.exe")

child_process.execSync(`"${fpExec}" -launch -window -loadfile "${path.join(__dirname, "build/ZAM_ruins.w3x")}"`)
