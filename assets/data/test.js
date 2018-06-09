const fs = require("fs");
const assert = require("assert");
const abilJson = JSON.parse(fs.readFileSync("./abilities.json"));

const schemaValidator = (obj) => {
    const okeys = Object.keys(obj);
    for (let i = 0; i < okeys.length; i++) {
        const abilelem = obj[okeys[i]];
        const akeys = Object.keys(abilelem);
        for (let j = 0; j < akeys.length; j++) {
            const entries = abilelem[akeys[j]];
            for (let k = 0; k < entries.length; k++) {
                const entry = entries[k];
                assert.strictEqual(Object.keys(entry).length, 5);
                assert.strictEqual(entry.hasOwnProperty("id"), true);
                assert.strictEqual(entry.hasOwnProperty("type"), true);
                assert.strictEqual(entry.hasOwnProperty("level"), true);
                assert.strictEqual(entry.hasOwnProperty("column"), true);
                assert.strictEqual(entry.hasOwnProperty("value"), true);
            }
        }
    }
};

schemaValidator(abilJson.original);
schemaValidator(abilJson.custom);

// const candidates = ["A002","A003","A004","A005","A006","A01F","A010","A0A1","A016","A0A2","A00D","A01X","A01Y","A020","A01Z","A00K","A00L","A00M","A00N","A00O","A03V","A03W","A01C","A01D","A00R","A009","A00A","A00C","A0CJ","A00G","A02X","A0BO","A00B","A027","A00E","A02S","A01S","A03H","A01U","A01W","A00V","A00Q","A0AG","A01G","A01H","A01M","A00W","A00X","A00Z","A013","A017","A01L","A01N","A01O","A01Q","A01R"];
// const keys = Object.keys(abilJson.custom);

// let count = 0;
// const objs = {};
// for (let i = 0; i < keys.length; i++) {
//     const element = keys[i];
//     const tokens = element.split(":");
//     if (candidates.indexOf(tokens[0]) !== -1) {
//         objs[element] = abilJson.custom[element];
//         count ++;
//     }
// }
// assert.strictEqual(count, candidates.length);
// fs.writeFileSync("./tmp.txt", JSON.stringify(objs, null, 4));

const need = ["A002","A003","A004","A005","A006","A01F","A010","A0A1","A016","A0A2","A00D","A01X","A01Y","A020","A01Z","A00K","A00L","A00M","A00N","A00O","A03V","A03W","A01C","A01D","A00R","A009","A00A","A00C","A0CJ","A00G","A02X","A0BO","A00B","A027","A00E","A02S","A01S","A03H","A01U","A01W","A00V","A00Q","A0AG","A01G","A01H","A01M","A00W","A00X","A00Z","A013","A017","A01L","A01N","A01O","A01Q","A01R"];

for (let i = 0; i < need.length; i++) {
    if (abilJson.custom.hasOwnProperty(`${need[i]}:ANcl`)) {
        const elem = abilJson.custom[`${need[i]}:ANcl`];
        for (let j = 0; j < elem.length; j++) {
            const field = elem[j];
            if (field.id == "amcs") {
                console.log(need[i], field);
                console.count();
            }
        }
    }
}