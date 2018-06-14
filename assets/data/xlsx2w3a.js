const path = require("path");
const workbook = require("./node-xlsx-helper")(path.join(__dirname, "Abilities.xlsm"));
const assert = require("assert");
const fs = require("fs");

const sheet = workbook.sheets["PlayerAbilities"];

const ci = {
    paid: sheet.indexOfHeader("paid"),
    aid: sheet.indexOfHeader("aid"),
    isHero: sheet.indexOfHeader("is_hero"),
    requirement: sheet.indexOfHeader("requirement"),
    button: sheet.indexOfHeader("button"),
    buttonnx: sheet.indexOfHeader("button_position_normal_x"),
    buttonny: sheet.indexOfHeader("button_position_normal_y"),
    buttonrx: sheet.indexOfHeader("button_position_research_x"),
    buttonry: sheet.indexOfHeader("button_position_research_y"),
    animName: sheet.indexOfHeader("anim_names"),
    oid: sheet.indexOfHeader("order_id"),
    hotkey: sheet.indexOfHeader("Hotkey"),
    targetsAllowed: sheet.indexOfHeader("targets_allowed"),
    followTime: sheet.indexOfHeader("follow_through_time"),
    targetType: sheet.indexOfHeader("target_type"),
    options: sheet.indexOfHeader("options"),
    aoe: sheet.indexOfHeader("AOE"),
    range: sheet.indexOfHeader("Range"),
    cd: sheet.indexOfHeader("CD"),
    cast: sheet.indexOfHeader("Cast"),
    channel: sheet.indexOfHeader("Channel"),
    duration: sheet.indexOfHeader("Duration"),
    cost: sheet.indexOfHeader("Cost"),
    name: sheet.indexOfHeader("name"),
    description: sheet.indexOfHeader("description"),
    levelTemplate: sheet.indexOfHeader("level_description_template"),
    tooltipTemplate: sheet.indexOfHeader("tooltip_template"),
    var1: sheet.indexOfHeader("var1"),
    var2: sheet.indexOfHeader("var2"),
    var3: sheet.indexOfHeader("var3"),
    buffAid: sheet.indexOfHeader("buffaid"),
    buffBid: sheet.indexOfHeader("buffbid"),
    buffPolar: sheet.indexOfHeader("buffpolar"),
    buffType: sheet.indexOfHeader("bufftype"),
    buffTip: sheet.indexOfHeader("bufftip"),
    buffUber: sheet.indexOfHeader("buffuber"),
};

const objs = [];
const buffs = [];

const arrayAllEqual = (arr) => {
    if (arr.length < 2) {
        return true;
    } else {
        const elem0 = arr[0];
        for (let i = 1; i < arr.length; i++) {
            if (elem0 != arr[i]) {
                return false;
            }
        }
        return true;
    }
};

const fillTemplateWithData = (template, data) => {
    const regex = /{(\d[#%])}/g;
    let ret = template;
    let match = regex.exec(ret);
    let i = 0;
    while (match != null) {
        if (match[1][1] === "%") {
            ret = ret.replace(`{${match[1]}}`, (data[i] * 100).toFixed(0) + "%");
        } else {
            ret = ret.replace(`{${match[1]}}`, data[i]);
        }
        i ++;
        match = regex.exec(template);
    }
    return ret;
};

const forgeResearchUberTip = (desc, data, levelDesc) => {
    let ret = `${desc}|n|n`;
    let hasData = false;
    if (data.cast.length != 0) {
        ret = ret + "|cff99ccffCast:|r ";
        if (arrayAllEqual(data.cast)) {
            ret = ret + data.cast[0];
        } else {
            ret = ret + data.cast.join("/");
        }
        ret = ret + "|n";
        hasData = true;
    }
    if (data.channel.length != 0) {
        ret = ret + "|cff99ccffChannel:|r ";
        if (arrayAllEqual(data.channel)) {
            ret = ret + data.channel[0];
        } else {
            ret = ret + data.channel.join("/");
        }
        ret = ret + "|n";
        hasData = true;
    }
    if (data.range.length != 0) {
        if (arrayAllEqual(data.range)) {
            if (data.range[0] > 128) {
                ret = ret + "|cff99ccffRange:|r ";
                ret = ret + data.range[0];
                ret = ret + "|n";
                hasData = true;
            }
        } else {
            ret = ret + "|cff99ccffRange:|r ";
            ret = ret + data.range.join("/");
            ret = ret + "|n";
            hasData = true;
        }
    }
    if (data.aoe.length != 0) {
        ret = ret + "|cff99ccffAOE:|r ";
        if (arrayAllEqual(data.aoe)) {
            ret = ret + data.aoe[0];
        } else {
            ret = ret + data.aoe.join("/");
        }
        ret = ret + "|n";
        hasData = true;
    }
    if (data.cost.length != 0) {
        ret = ret + "|cff99ccffCost:|r ";
        if (arrayAllEqual(data.cost)) {
            ret = ret + (data.cost[0] < 1 ? data.cost[0] * 100 + "%" : data.cost[0]);
        } else {
            ret = ret + data.cost.map(x => (x < 1 ? x * 100 : x)).join("/") + (data.cost[0] < 1 ? "%" : "");
        }
        ret = ret + "|n";
        hasData = true;
    }
    if (data.duration.length != 0) {
        ret = ret + "|cff99ccffDuration:|r ";
        if (arrayAllEqual(data.duration)) {
            ret = ret + data.duration[0];
        } else {
            ret = ret + data.duration.join("/");
        }
        ret = ret + "|n";
        hasData = true;
    }
    if (data.cd.length != 0) {
        if (arrayAllEqual(data.cd)) {
            if (data.cd[0] > 1) {
                ret = ret + "|cff99ccffCooldown:|r ";
                ret = ret + data.cd[0];
                ret = ret + "|n";
                hasData = true;
            }
        } else {
            ret = ret + "|cff99ccffCooldown:|r ";
            ret = ret + data.cd.join("/");
            ret = ret + "|n";
            hasData = true;
        }
    }
    if (hasData === true) {
        ret = ret + "|n";
    }
    const levelDescs = levelDesc.map((str, i) => {
        const replaced = fillTemplateWithData(str, [data.var1[i], data.var2[i], data.var3[i]]);
        return `|cffffcc00Level ${i + 1}|r - ${replaced}`;
    });
    ret = ret + levelDescs.join("|n");
    return ret;
};

const forgeUberTip = (template, vars, dataSet) => {
    let ret = fillTemplateWithData(template, vars);
    ret += "|n";
    if (dataSet.cast !== undefined) {
        ret += `|n|cff99ccffCast:|r ${dataSet.cast}`;
    }
    if (dataSet.channel !== undefined) {
        ret += `|n|cff99ccffChannel:|r ${dataSet.channel}`;
    }
    if (dataSet.range !== undefined && dataSet.range > 128) {
        ret += `|n|cff99ccffRange:|r ${dataSet.range}`;
    }
    if (dataSet.aoe !== undefined) {
        ret += `|n|cff99ccffAOE:|r ${dataSet.aoe}`;
    }
    if (dataSet.cost !== undefined) {
        ret += `|n|cff99ccffCost:|r ${dataSet.cost < 1 ? dataSet.cost * 100 + "%" : dataSet.cost}`;
    }
    if (dataSet.duration !== undefined) {
        ret += `|n|cff99ccffDuration:|r ${dataSet.duration}`;
    }
    if (dataSet.cd !== undefined && dataSet.cd > 1) {
        ret += `|n|cff99ccffCooldown:|r ${dataSet.cd}`;
    }
    return ret;
};

for (let i = 1; i < sheet.data.length + 1; i++) {
    let obj = { id: "", fields: [] };
    if (sheet.cell(`${ci.paid}${i}`) === "ANcl") {
        // start
        obj = {
            id: sheet.cell(`${ci.aid}${i}`) + ":ANcl",
            fields: []
        };
        objs.push(obj);

        // alev	状态 - 等级
        let lvl = 3;
        if (sheet.cell(`${ci.paid}${i + 1}`) != "") {
            obj.fields.push({ id: "alev", type: "int", level: 0, column: 0, value: 1 });
            lvl = 1;
        }

        // contants
        // Ncl5	数据 - 使其他技能无效  all 0
        for (let j = 1; j <= lvl; j++) {
            obj.fields.push({ id: "Ncl5", type: "int", level: j, column: 5, value: 0 });
        }
        // Ncl4	数据 - 动作持续时间 all 0
        for (let j = 1; j <= lvl; j++) {
            obj.fields.push({ id: "Ncl4", type: "unreal", level: j, column: 4, value: 0 });
        }
        // acat	显示 - 效果 - 施法者 // always ""
        obj.fields.push({ id: "acat", type: "string", level: 0, column: 0, value: "" });
        // acap	显示 - 效果 - 施法者附加点1 // always ""
        obj.fields.push({ id: "acap", type: "string", level: 0, column: 0, value: "" });
        // atat	显示 - 效果 - 目标 // always ""
        obj.fields.push({ id: "atat", type: "string", level: 0, column: 0, value: "" });
        // aeat	显示 - 效果 - 目标点 // always ""
        obj.fields.push({ id: "aeat", type: "string", level: 0, column: 0, value: "" });
        // ata0	显示 - 效果 - 目标附加点1 // always ""
        obj.fields.push({ id: "ata0", type: "string", level: 0, column: 0, value: "" });
        // arac	状态 - 种族 // always human
        obj.fields.push({ id: "arac", type: "string", level: 0, column: 0, value: "human" });
        // alsk	状态 - 跳级要求 // always 1
        obj.fields.push({ id: "alsk", type: "int", level: 0, column: 0, value: 1 });

        // other data
        // aher	状态 - 英雄技能
        if (sheet.cell(`${ci.isHero}${i}`) == 0) {
            obj.fields.push({ id: "aher", type: "int", level: 0, column: 0, value: 0 });
        }
        // areq	科技树 - 需求
        if (sheet.cell(`${ci.requirement}${i}`) != "") {
            obj.fields.push({ id: "areq", type: "string", level: 0, column: 0, value: sheet.cell(`${ci.requirement}${i}`) });
        }
        // arar	显示 - 图标 - 学习
        // aart	显示 - 图标 - 普通
        obj.fields.push({ id: "arar", type: "string", level: 0, column: 0, value: sheet.cell(`${ci.button}${i}`) });
        obj.fields.push({ id: "aart", type: "string", level: 0, column: 0, value: sheet.cell(`${ci.button}${i}`) });
        // arhk	文本 - 热键 - 学习
        // ahky	文本 - 热键 - 普通
        let hotkey = sheet.cell(`${ci.hotkey}${i}`);
        obj.fields.push({ id: "arhk", type: "string", level: 0, column: 0, value: hotkey });
        obj.fields.push({ id: "ahky", type: "string", level: 0, column: 0, value: hotkey });
        // abpx	显示 - 按钮位置 - 普通X
        // abpy	显示 - 按钮位置 - 普通Y
        // arpx	显示 - 按钮位置 - 研究X
        // arpy	显示 - 按钮位置 - 研究Y
        obj.fields.push({ id: "abpx", type: "int", level: 0, column: 0, value: sheet.cell(`${ci.buttonnx}${i}`, true) });
        obj.fields.push({ id: "abpy", type: "int", level: 0, column: 0, value: sheet.cell(`${ci.buttonny}${i}`, true) });
        obj.fields.push({ id: "arpx", type: "int", level: 0, column: 0, value: sheet.cell(`${ci.buttonrx}${i}`, true) });
        obj.fields.push({ id: "arpy", type: "int", level: 0, column: 0, value: sheet.cell(`${ci.buttonry}${i}`, true) });
        // aani	显示 - 效果 - 施法动作
        obj.fields.push({ id: "aani", type: "string", level: 0, column: 0, value: sheet.cell(`${ci.animName}${i}`) });

        // leveled data
        // Ncl6	数据 - 基础命令ID
        for (let j = 0; j < lvl; j++) {
            obj.fields.push({ id: "Ncl6", type: "string", level: j + 1, column: 6, value: sheet.cell(`${ci.oid}${i}`) });
        }
        // atar	状态 - 目标允许
        for (let j = 0; j < lvl; j++) {
            if (sheet.cell(`${ci.targetsAllowed}${i + j}`) != "") {
                obj.fields.push({ id: "atar", type: "string", level: j + 1, column: 0, value: sheet.cell(`${ci.targetsAllowed}${i + j}`) });
            }
        }
        // Ncl1	数据 - 施法持续时间
        for (let j = 0; j < lvl; j++) {
            obj.fields.push({ id: "Ncl1", type: "unreal", level: j + 1, column: 1, value: sheet.cell(`${ci.followTime}${i}`, true) });
        }
        // Ncl2	数据 - 目标类型
        for (let j = 0; j < lvl; j++) {
            obj.fields.push({ id: "Ncl2", type: "int", level: j + 1, column: 2, value: sheet.cell(`${ci.targetType}${i}`, true) });
        }
        // Ncl3	数据 - 选项
        for (let j = 0; j < lvl; j++) {
            obj.fields.push({ id: "Ncl3", type: "int", level: j + 1, column: 3, value: sheet.cell(`${ci.options}${i}`, true) });
        }
        // aord	文本 - 命令串 - 使用/打开
        obj.fields.push({ id: "aord", type: "string", level: 0, column: 0, value: sheet.cell(`${ci.oid}${i}`) });

        // datas
        // aare	状态 - 影响区域
        for (let j = 0; j < lvl; j++) {
            if (sheet.cell(`${ci.aoe}${i + j}`) != "") {
                obj.fields.push({ id: "aare", type: "unreal", level: j + 1, column: 0, value: sheet.cell(`${ci.aoe}${i + j}`, true) });
            }
        }
        // aran	状态 - 施法距离
        for (let j = 0; j < lvl; j++) {
            if (sheet.cell(`${ci.range}${i + j}`) != "") {
                obj.fields.push({ id: "aran", type: "unreal", level: j + 1, column: 0, value: sheet.cell(`${ci.range}${i + j}`, true) });
            }
        }
        // acdn	状态 - 魔法冷却时间
        for (let j = 0; j < lvl; j++) {
            if (sheet.cell(`${ci.cd}${i + j}`) != "") {
                obj.fields.push({ id: "acdn", type: "unreal", level: j + 1, column: 0, value: sheet.cell(`${ci.cd}${i + j}`, true) });
            }
        }
        // acas	状态 - 魔法施放时间 // if cast or channel != 0, then 10
        for (let j = 0; j < lvl; j++) {
            if (sheet.cell(`${ci.cast}${i + j}`) != "" || sheet.cell(`${ci.channel}${i + j}`) != "") {
                obj.fields.push({ id: "acas", type: "unreal", level: j + 1, column: 0, value: 10 });
            }
        }
        // amcs	状态 - 魔法消耗 // if < 1, then 0
        for (let j = 0; j < lvl; j++) {
            if (sheet.cell(`${ci.cost}${i + j}`, true) >= 1) {
                obj.fields.push({ id: "amcs", type: "int", level: j + 1, column: 0, value: sheet.cell(`${ci.cost}${i + j}`, true) });
            }
        }

        // data
        const dataSet = {
            cast: [],
            channel: [],
            range: [],
            aoe: [],
            cost: [],
            duration: [],
            cd: [],
            var1: [],
            var2: [],
            var3: []
        };
        const dataSetKeys = Object.keys(dataSet);
        for (let j = 0; j < dataSetKeys.length; j++) {
            for (let k = 0; k < lvl; k++) {
                dataSet[dataSetKeys[j]].push(sheet.cell(`${ci[dataSetKeys[j]]}${i + k}`, true));
            }
            let allZero = true;
            for (let k = 0; k < dataSet[dataSetKeys[j]].length && allZero === true; k++) {
                if (dataSet[dataSetKeys[j]][k] != 0) {
                    allZero = false;
                }
            }
            if (allZero === true) {
                dataSet[dataSetKeys[j]] = [];
            }
            const setLength = dataSet[dataSetKeys[j]].length;
            assert.strictEqual(setLength == 0 || setLength == 1 || setLength == 3, true);
        }
        const levelDesc = [];
        for (let j = 0; j < lvl; j++) {
            levelDesc.push(sheet.cell(`${ci.levelTemplate}${i + j}`));
        }
        const tooltipDesc = [];
        for (let j = 0; j < lvl; j++) {
            tooltipDesc.push(sheet.cell(`${ci.tooltipTemplate}${i + j}`));
        }

        // texts
        // anam	文本 - 名字
        let name = sheet.cell(`${ci.name}${i}`);
        obj.fields.push({ id: "anam", type: "string", level: 0, column: 0, value: name });
        // aret	文本 - 提示工具 - 学习
        obj.fields.push({ id: "aret", type: "string", level: 0, column: 0, value: `Learn ${name}(|cffffcc00${hotkey}|r) - [|cffffcc00Level %d|r]` });
        // arut	文本 - 提示工具 - 学习 - 扩展
        obj.fields.push({
            id: "arut",
            type: "string",
            level: 0,
            column: 0,
            value: forgeResearchUberTip(sheet.cell(`${ci.description}${i}`), dataSet, levelDesc)
        });
        // atp1	文本 - 提示工具 - 普通
        for (let j = 0; j < lvl; j++) {
            obj.fields.push({ id: "atp1", type: "string", level: j + 1, column: 0, value: `${name}(|cffffcc00${hotkey}|r) - [|cffffcc00Level ${j + 1}|r]` });
        }
        // aub1	文本 - 提示工具 - 普通 - 扩展
        for (let j = 0; j < lvl; j++) {
            obj.fields.push({
                id: "aub1",
                type: "string",
                level: j + 1,
                column: 0,
                value: forgeUberTip(tooltipDesc[j], [dataSet.var1[j], dataSet.var2[j], dataSet.var3[j]], {
                    cast: dataSet.cast[j],
                    channel: dataSet.channel[j],
                    range: dataSet.range[j],
                    aoe: dataSet.aoe[j],
                    cost: dataSet.cost[j],
                    duration: dataSet.duration[j],
                    cd: dataSet.cd[j],
                })
            });
        }
    }
    if (sheet.cell(`${ci.buffAid}${i}`) !== "" && sheet.cell(`${ci.buffAid}${i}`)[0] == "A") {
        let tip = sheet.cell(`${ci.buffTip}${i}`);
        if (sheet.cell(`${ci.buffPolar}${i}`) == "P") {
            tip = `|cff00ff00${tip}|r`;
        }
        let prefix;
        if (sheet.cell(`${ci.buffType}${i}`) == "P") {
            prefix = "Physical: ";
        } else {
            prefix = "|cff6666ffMagical|r: ";
        }
        const uber = prefix + sheet.cell(`${ci.buffUber}${i}`);
        buffs.push({
            id: `${sheet.cell(`${ci.buffAid}${i}`)}:${sheet.cell(`${ci.buffBid}${i}`)}`,
            tip: tip,
            uber: uber
        });
    }
}

// temporal solution, copy and paste
let dump = "";
for (let i = 0; i < objs.length; i++) {
    for (let j = 0; j < objs[i].fields.length; j++) {
        const element = objs[i].fields[j];
        if (element.id == "aret" || element.id == "arut" || element.id == "atp1" || element.id == "aub1") {
            dump += element.value + "\n";
        }
    }
    dump += "\n";
}
for (let i = 0; i < buffs.length; i++) {
    const element = buffs[i];
    dump += element.id + "\n";
    dump += element.tip + "\n";
    dump += element.uber + "\n\n";
}
fs.writeFileSync("./tmp.txt", dump);

// // merge with default abilities.json
// const defaultData = JSON.parse(fs.readFileSync("./abilities.json"));

// for (let i = 0; i < objs.length; i++) {
//     const elem = objs[i];
//     assert.strictEqual(defaultData.custom.hasOwnProperty(elem.id), true);
//     defaultData.custom[elem.id] = elem.fields;
// }

// // build war3map.w3a
// const Translator = require("wc3maptranslator");
// const objTrans = new Translator.Objects.jsonToWar("abilities", defaultData);
// const fis = fs.openSync("./war3map.w3a", "w+");
// fs.writeSync(fis, objTrans.buffer, 0, objTrans.buffer.length);
// fs.closeSync(fis);

// // inject w3a into map
// const cmd = require("child_process").exec;
// cmd("MPQEditor.exe add ..\\..\\ZAM_ruins.w3x .\\war3map.w3a \"war3map.w3a\"", (err, stdout, stderr) => {
//     if (err) {
//         return;
//     }

// });