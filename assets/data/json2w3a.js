const fs = require("fs");
const Translator = require("wc3maptranslator");
const path = require("path");

const w3a = JSON.parse(fs.readFileSync(path.join("objects", "w3a.json")).toString());

const objTrans = new Translator.Objects("abilities", w3a);
objTrans.write("objects");
console.log("Success - war3map.w3a saved to ./objects");