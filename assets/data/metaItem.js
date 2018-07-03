const path = require("path");
const fs = require("fs");
const assert = require("assert");
const workbook = require("./node-xlsx-helper/index")(path.join(__dirname, "Items.xlsm"));

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
                    color = "ffcc00";
                    break;
                default:
                    color = "[BAD NAME COLOR]";
                    break;
            }
            entry = {
                itid: `ITID_${sheet.cell(`G${j}`).replace(/'/g, "").replace(/ /g, "_").toUpperCase()}`,
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
            if (templateId === "itemmeta") {
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