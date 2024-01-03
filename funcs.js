const fs = require("fs")

if (!fs.existsSync("config.json")) {
    fs.writeFileSync("config.json", "{\"wc3path\": \"\"}")
    console.log("Please edit config.json")
    process.exit(1)
}

const config = JSON.parse(fs.readFileSync("config.json").toString())

module.exports = config
