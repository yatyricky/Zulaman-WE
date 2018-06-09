const workbook = require("./node-xlsx-helper")("./Abilities.xlsm");
const assert = require("assert");

// anam	文本 - 名字
// aret	文本 - 提示工具 - 学习
// arut	文本 - 提示工具 - 学习 - 扩展
// atp1	文本 - 提示工具 - 普通
// aub1	文本 - 提示工具 - 普通 - 扩展

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
    cost: sheet.indexOfHeader("Cost"),
};

const objs = [];

for (let i = 1; i < sheet.data.length + 1; i++) {
    const row = sheet.data[i];
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
            obj.fields.push({id: "alev", type: "int", level: 0, column: 0, value: 1});
            lvl = 1;
        }

        // contants
        // Ncl5	数据 - 使其他技能无效  all 0
        for (let j = 1; j <= lvl; j++) {
            obj.fields.push({id: "Ncl5", type: "int", level: j, column: 5, value: 0});
        }
        // Ncl4	数据 - 动作持续时间 all 0
        for (let j = 1; j <= lvl; j++) {
            obj.fields.push({id: "Ncl4", type: "unreal", level: j, column: 4, value: 0});
        }
        // acat	显示 - 效果 - 施法者 // always ""
        obj.fields.push({id: "acat", type: "string", level: 0, column: 0, value: ""});
        // acap	显示 - 效果 - 施法者附加点1 // always ""
        obj.fields.push({id: "acap", type: "string", level: 0, column: 0, value: ""});
        // atat	显示 - 效果 - 目标 // always ""
        obj.fields.push({id: "atat", type: "string", level: 0, column: 0, value: ""});
        // aeat	显示 - 效果 - 目标点 // always ""
        obj.fields.push({id: "aeat", type: "string", level: 0, column: 0, value: ""});
        // ata0	显示 - 效果 - 目标附加点1 // always ""
        obj.fields.push({id: "ata0", type: "string", level: 0, column: 0, value: ""});
        // arac	状态 - 种族 // always human
        obj.fields.push({id: "arac", type: "string", level: 0, column: 0, value: "human"});
        // alsk	状态 - 跳级要求 // always 1
        obj.fields.push({id: "alsk", type: "int", level: 0, column: 0, value: 1});

        // other data
        // aher	状态 - 英雄技能
        if (sheet.cell(`${ci.isHero}${i}`) == 0) {
            obj.fields.push({id: "aher", type: "int", level: 0, column: 0, value: 0});
        }
        // areq	科技树 - 需求
        if (sheet.cell(`${ci.requirement}${i}`) != "") {
            obj.fields.push({id: "areq", type: "string", level: 0, column: 0, value: sheet.cell(`${ci.requirement}${i}`)});
        }
        // arar	显示 - 图标 - 学习
        // aart	显示 - 图标 - 普通
        obj.fields.push({id: "arar", type: "string", level: 0, column: 0, value: sheet.cell(`${ci.button}${i}`)});
        obj.fields.push({id: "aart", type: "string", level: 0, column: 0, value: sheet.cell(`${ci.button}${i}`)});
        // arhk	文本 - 热键 - 学习
        // ahky	文本 - 热键 - 普通
        obj.fields.push({id: "arhk", type: "string", level: 0, column: 0, value: sheet.cell(`${ci.hotkey}${i}`)});
        obj.fields.push({id: "ahky", type: "string", level: 0, column: 0, value: sheet.cell(`${ci.hotkey}${i}`)});
        // abpx	显示 - 按钮位置 - 普通X
        // abpy	显示 - 按钮位置 - 普通Y
        // arpx	显示 - 按钮位置 - 研究X
        // arpy	显示 - 按钮位置 - 研究Y
        obj.fields.push({id: "abpx", type: "int", level: 0, column: 0, value: sheet.cell(`${ci.buttonnx}${i}`, true)});
        obj.fields.push({id: "abpy", type: "int", level: 0, column: 0, value: sheet.cell(`${ci.buttonny}${i}`, true)});
        obj.fields.push({id: "arpx", type: "int", level: 0, column: 0, value: sheet.cell(`${ci.buttonrx}${i}`, true)});
        obj.fields.push({id: "arpy", type: "int", level: 0, column: 0, value: sheet.cell(`${ci.buttonry}${i}`, true)});
        // aani	显示 - 效果 - 施法动作
        obj.fields.push({id: "aani", type: "string", level: 0, column: 0, value: sheet.cell(`${ci.animName}${i}`)});
        
        // leveled data
        // Ncl6	数据 - 基础命令ID
        for (let j = 0; j < lvl; j++) {
            obj.fields.push({id: "Ncl6", type: "string", level: j + 1, column: 6, value: sheet.cell(`${ci.oid}${i}`)});
        }
        // atar	状态 - 目标允许
        for (let j = 0; j < lvl; j++) {
            if (sheet.cell(`${ci.targetsAllowed}${i + j}`) != "") {
                obj.fields.push({id: "atar", type: "string", level: j + 1, column: 0, value: sheet.cell(`${ci.targetsAllowed}${i + j}`)});
            }
        }
        // Ncl1	数据 - 施法持续时间
        for (let j = 0; j < lvl; j++) {
            obj.fields.push({id: "Ncl1", type: "unreal", level: j + 1, column: 1, value: sheet.cell(`${ci.followTime}${i}`, true)});
        }
        // Ncl2	数据 - 目标类型
        for (let j = 0; j < lvl; j++) {
            obj.fields.push({id: "Ncl2", type: "int", level: j + 1, column: 2, value: sheet.cell(`${ci.targetType}${i}`, true)});
        }
        // Ncl3	数据 - 选项
        for (let j = 0; j < lvl; j++) {
            obj.fields.push({id: "Ncl3", type: "int", level: j + 1, column: 3, value: sheet.cell(`${ci.options}${i}`, true)});
        }
        // aord	文本 - 命令串 - 使用/打开
        obj.fields.push({id: "aord", type: "string", level: 0, column: 0, value: sheet.cell(`${ci.oid}${i}`)});

        // datas
        // aare	状态 - 影响区域
        for (let j = 0; j < lvl; j++) {
            if (sheet.cell(`${ci.aoe}${i + j}`) != "") {
                obj.fields.push({id: "aare", type: "unreal", level: j + 1, column: 0, value: sheet.cell(`${ci.aoe}${i + j}`, true)});
            }
        }
        // aran	状态 - 施法距离
        for (let j = 0; j < lvl; j++) {
            if (sheet.cell(`${ci.range}${i + j}`) != "") {
                obj.fields.push({id: "aran", type: "unreal", level: j + 1, column: 0, value: sheet.cell(`${ci.range}${i + j}`, true)});
            }
        }
        // acdn	状态 - 魔法冷却时间
        for (let j = 0; j < lvl; j++) {
            if (sheet.cell(`${ci.cd}${i + j}`) != "") {
                obj.fields.push({id: "acdn", type: "unreal", level: j + 1, column: 0, value: sheet.cell(`${ci.cd}${i + j}`, true)});
            }
        }
        // acas	状态 - 魔法施放时间 // if cast or channel != 0, then 10
        for (let j = 0; j < lvl; j++) {
            if (sheet.cell(`${ci.cast}${i + j}`) != "" || sheet.cell(`${ci.channel}${i + j}`) != "") {
                obj.fields.push({id: "acas", type: "unreal", level: j + 1, column: 0, value: 10});
            }
        }
        // amcs	状态 - 魔法消耗 // if < 1, then 0
        for (let j = 0; j < lvl; j++) {
            if (sheet.cell(`${ci.cost}${i + j}`, true) >= 1) {
                obj.fields.push({id: "amcs", type: "int", level: j + 1, column: 0, value: sheet.cell(`${ci.cost}${i + j}`, true)});
            }
        }
    }
}