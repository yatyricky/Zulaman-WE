const xlsx = require("node-xlsx").default;

const col2Number = (col) => {
    let num = 0;
    for (let i = 0; i < col.length; i++) {
        num += (col.charCodeAt(i) - 64) * Math.pow(26, (col.length - i - 1));
    }
    return num;
};

const number2Col = (num) => {
    let sb = "";
    while (num > 0) {
        num --;
        let mod = num % 26;
        sb = String.fromCharCode(mod + 65) + sb;
        num = Math.floor(num / 26);
    }
    return sb;
};

const compromisedReturn = (any, num) => {
    if (!any) {
        if (num === true) {
            return 0;
        } else {
            return "";
        }
    } else {
        if (isNaN(any)) {
            if (num === true) {
                return 0;
            } else {
                return any;
            }
        } else {
            return parseFloat(any);
        }
    }
};

module.exports = (fpath) => {
    const raw = xlsx.parse(fpath);
    const sheets = {};
    for (let i = 0; i < raw.length; i++) {
        const sheet = raw[i];
        sheets[sheet.name] = {
            data: sheet.data,
            cell: (ref, enforceNumber = false) => {
                const regex = /([A-Z]+)([1-9][0-9]*)/g;
                const match = regex.exec(ref);
                const row = parseInt(match[2]);
                const col = col2Number(match[1]);
                return compromisedReturn(sheet.data[row - 1][col - 1], enforceNumber);
            },
            lookup: (col, val, valcol, enforceNumber = false) => {
                const index = col2Number(col) - 1;
                let f = -1;
                for (let j = 0; j < sheet.data.length && f === -1; j++) {
                    const row = sheet.data[j];
                    if (row.length > index && row[index] == val) {
                        f = j;
                    }
                }
                return compromisedReturn(sheet.data[f][col2Number(valcol) - 1], enforceNumber);
            },
            indexOfHeader: (header) => {
                let f = -1;
                for (let j = 0; j < sheet.data[0].length && f === -1; j++) {
                    const element = sheet.data[0][j];
                    if (element == header) {
                        f = j;
                    }
                }
                if (f === -1) {
                    return undefined;
                } else {
                    return number2Col(f + 1);
                }
            }
        };
    }
    return {
        sheets: sheets
    };
};
