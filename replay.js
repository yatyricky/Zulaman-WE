const os = require("os")
const path = require("path")
const child_process = require("child_process")
const config = require("./funcs")

const fpExec = path.join(config.wc3path, "_retail_/x86_64/Warcraft III.exe")

child_process.execSync(`"${fpExec}" -launch -window -loadfile ${path.join(os.homedir(), "Documents/Warcraft III/BattleNet/user_id/Replays/LastReplay.w3g")}`)
