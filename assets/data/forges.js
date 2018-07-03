module.exports = {
    forgeBuffData: (aid, bid, buffType, buffPolar, tip, ubertip) => {
        if (buffPolar == "P") {
            tip = `|cff00ff00${tip}|r`;
        }
        let prefix;
        if (buffType == "P") {
            prefix = "Physical: ";
        } else {
            prefix = "|cff6666ffMagical|r: ";
        }
        const uber = prefix + ubertip;
        return {
            id: `${aid}:${bid}`,
            tip: tip,
            uber: uber
        };
    }
};