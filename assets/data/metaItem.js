const path = require("path");
const fs = require("fs");
const assert = require("assert");
const workbook = require("./node-xlsx-helper/index")(path.join(__dirname, "Items.xlsm"));
const forges = require("./forges");

// working on items
const all = [];
function parseSheet(sheet) {
    let entry = {
        itid: "",
        name: "",
        lore: "",
        attrs: []
    };
    for (let j = 3; j <= sheet.data.length; j++) {
        if (sheet.cell(`A${j}`, "number") < 0 && sheet.cell(`A${j}`, "number") > -10) {
            let color = "";
            switch (sheet.cell(`A${j}`, "number")) {
                case -1:
                    color = "11ff11";
                    break;
                case -2:
                    color = "8b66ff";
                    break;
                case -3:
                    color = "ff8c00";
                    break;
                case -4:
                    color = "ff8c00";
                    break;
                default:
                    color = "[BAD NAME COLOR]";
                    break;
            }
            entry = {
                itid: `ITID_${sheet.cell(`G${j}`).replace(/[',]/g, "").replace(/ /g, "_").toUpperCase()}`,
                name: `|cff${color}${sheet.cell(`G${j}`)}|r`,
                lore: "",
                attrs: []
            };
            all.push(entry);
        } else if (sheet.cell(`A${j}`, "number") > 0) {
            entry.attrs.push({
                id: sheet.cell(`A${j}`, "number"),
                lo: sheet.cell(`B${j}`, "number"),
                hi: sheet.cell(`C${j}`, "number")
            });
        } else if (sheet.cell(`A${j}`, "number") <= -10) {
            let color = "";
            switch (sheet.cell(`A${j}`, "number")) {
                case -10:
                    color = "999999";
                    break;
                case -11:
                    color = "ffdead";
                    break;
                default:
                    color = "[BAD LORE COLOR]";
                    break;
            }
            entry.lore = `|cff${color}${sheet.cell(`G${j}`)}|r`;
        }
    }
}

parseSheet(workbook.sheets["Uncommon"]);
parseSheet(workbook.sheets["Rare"]);
parseSheet(workbook.sheets["Legendary"]);
parseSheet(workbook.sheets["Relic"]);

// working on Attributes
let sheet = workbook.sheets["Attributes"];
let dump = "";
const allAttributes = [];
for (let i = 2; i <= sheet.data.length; i++) {
    let id = `IATTR_${sheet.cell("G" + i)}`;
    let cate = sheet.cell("B" + i, "number");
    let sort = sheet.cell("C" + i, "number");
    let lpf = sheet.cell("D" + i, "number");

    let strs = sheet.cell("F" + i).split("#");
    assert.strictEqual(strs.length === 1 || strs.length === 2, true);
    let str1, str2;
    if (cate == 2) {
        str1 = "|cff33ff33" + strs[0];
    } else if (cate == 3) {
        str1 = "|cff87ceeb" + strs[0];
    } else {
        str1 = strs[0];
    }
    if (strs.length === 2) {
        str2 = strs[1];
    } else {
        str2 = "";
    }
    if (cate !== 1) {
        str2 += "|r";
    }
    let callback = `thistype.callback${sheet.cell("G" + i)}`;
    allAttributes.push(`thistype.put(${id},${cate},${sort},${lpf},"${str1}","${str2}",${callback});`);

    // buff text
    if (sheet.cell("H" + i) !== "") {
        let result = forges.forgeBuffData(sheet.cell("H" + i), sheet.cell("I" + i), sheet.cell("K" + i), sheet.cell("J" + i), sheet.cell("L" + i), sheet.cell("M" + i));
        dump += `${result.id}\n${result.tip}\n${result.uber}\n\n`;
    }
}

const fpath = path.join("assets", "scripts", "item", "ItemAttributes.j");

const lineReader = require("readline").createInterface({
    input: fs.createReadStream(fpath)
});

const TEMPLATE_HEADER = 1;
const TEMPLATE_BODY = 3;
const TEMPLATE_OUTSIDE = 4;
let outBuffer = "";
let stateStack = [];
let templateId = "";
let templateIndentation = 0;
stateStack.push(TEMPLATE_OUTSIDE);
lineReader.on("line", function(line) {
    const regex = /\s*\/\/:template.([a-zA-Z_][a-zA-Z0-9_]*)(\s*=\s*([a-zA-Z0-9_]+))?\s*/g;
    const match = regex.exec(line);
    if (match) {
        if (match[1] === "end") {
            assert.strictEqual(stateStack[stateStack.length - 1] === TEMPLATE_BODY || stateStack[stateStack.length - 1] === TEMPLATE_HEADER, true);
            // pop
            stateStack.pop();
            if (stateStack[stateStack.length - 1] === TEMPLATE_HEADER) {
                stateStack.pop();
            }
            assert.strictEqual(stateStack[stateStack.length - 1], TEMPLATE_OUTSIDE);
            // flush
            if (templateId === "itemmeta") {
                let indentation = "";
                for (let i = 0; i < templateIndentation; i++) {
                    indentation += "    ";
                }
                for (let i = 0; i < all.length; i++) {
                    let attrs = "";
                    for (let k = 0; k < all[i].attrs.length; k++) {
                        const attr = all[i].attrs[k];
                        attrs += `.append(${attr.id},${attr.lo},${attr.hi})`;
                    }
                    outBuffer += `${indentation}thistype.create(${all[i].itid},"${all[i].name}","${all[i].lore}")${attrs};\n`;
                }
            } else if (templateId === "attributeMeta") {
                let indentation = "";
                for (let i = 0; i < templateIndentation; i++) {
                    indentation += "    ";
                }
                for (let i = 0; i < allAttributes.length; i++) {
                    outBuffer += indentation + allAttributes[i] + "\n";
                }
            }
            outBuffer += line + "\n";
        } else {
            assert.strictEqual(stateStack[stateStack.length - 1] === TEMPLATE_OUTSIDE || stateStack[stateStack.length - 1] === TEMPLATE_HEADER, true);
            if (stateStack[stateStack.length - 1] === TEMPLATE_OUTSIDE) {
                stateStack.push(TEMPLATE_HEADER);
            }
            if (match[1] === "id") {
                templateId = match[3];
                outBuffer += line + "\n";
            } else if (match[1] === "indentation") {
                templateIndentation = match[3];
                outBuffer += line + "\n";
            } else {
                throw new Error(`Unexpected directive ${match[1]}`);
            }
        }
    } else {
        if (stateStack[stateStack.length - 1] === TEMPLATE_HEADER) {
            stateStack.push(TEMPLATE_BODY);
        } else if (stateStack[stateStack.length - 1] === TEMPLATE_BODY) {
            if (templateId === "itemmeta" || templateId === "attributeMeta") {
                // skip if itemmeta
            } else {
                outBuffer += line + "\n";
            }
        } else if (stateStack[stateStack.length - 1] === TEMPLATE_OUTSIDE) {
            outBuffer += line + "\n";
        }
    }
}).on("close", () => {
    console.log("success");
    fs.writeFileSync(fpath, outBuffer);
});

// work on consumables
let consumSheet = workbook.sheets["Consumable"];
for (let i = 2; i <= consumSheet.data.length; i++) {
    if (consumSheet.cell("I"+i) !== "") {
        let result = forges.forgeBuffData(consumSheet.cell("I" + i), consumSheet.cell("J" + i), consumSheet.cell("L" + i), consumSheet.cell("K" + i), consumSheet.cell("M" + i), consumSheet.cell("N" + i));
        dump += `${result.id}\n${result.tip}\n${result.uber}\n\n`;
    }
}

fs.writeFileSync("tmp.txt", dump);