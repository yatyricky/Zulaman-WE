const xlsx = require("node-xlsx").default;
const path = require("path");

const workbook = xlsx.parse(path.join("design", "Items.xlsm"));

let counter = 0;
for (let i = 0; i < workbook.length; i++) {
    const element = workbook[i];
    const all = [];
    if (element.name == "Uncommon" || element.name == "Rare" || element.name == "Legendary") {
        let entry = {
            itid: "",
            name: "",
            lore: "",
            attrs: []
        };
        for (let j = 0; j < element.data.length; j++) {
            const row = element.data[j];
            if (row.length == 7 && !isNaN(row[0])) {
                if (row[0] < 0 && row[0] > -10) {
                    let color = "";
                    switch (row[0]) {
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
                            color = "[BAD NAME COLOR]"
                            break;
                    }
                    entry = {
                        itid: `ITID_${row[6].replace(/'/g, "").replace(/ /g, "_").toUpperCase()}`,
                        name: `|cff${color}${row[6]}|r`,
                        lore: "",
                        attrs: []
                    };
                    all.push(entry);
                } else if (row[0] > 0) {
                    entry.attrs.push({
                        id: row[0],
                        lo: row[1],
                        hi: row[2]
                    });
                } else if (row[0] <= -10) {
                    let color = "";
                    switch (row[0]) {
                        case -10:
                            color = "999999";
                            break;
                        case -11:
                            color = "ffdead";
                            break;
                        default:
                            color = "[BAD LORE COLOR]"
                            break;
                    }
                    entry.lore = `|cff${color}${row[6]}|r`;
                }
            }
        }
        for (let j = 0; j < all.length; j++) {
            let attrs = "";
            for (let k = 0; k < all[j].attrs.length; k++) {
                const attr = all[j].attrs[k];
                attrs += `.append(${attr.id},${attr.lo},${attr.hi})`;
            }
            console.log(`thistype.create(${all[j].itid},"${all[j].name}","${all[j].lore}")${attrs};`);
        }
    }
}
