const fs = require('fs');
const path = require('path');
const readline = require('readline');

const reader = readline.createInterface({
    input: fs.createReadStream(path.join("objects", "ability.ini"))
});

let outobj = {
    original: {},
    custom: {}
};
let currentComment = "";
let currentKey = {};
let currentArr = [];
let currentParent = "";
let counter = 0;
let num = 0;

reader.on('line', (line) => {
    if (line != "") {
        let matched = false;

        // ID
        let ret = line.match(/\[(.{4})\]/);
        if (ret) {
            matched = true;
            if (ret.length != 2) {
                throw new Exception(`Error ${line}`);
            }
            // console.log(`ID: ${ret[1]}`);
            currentKey = ret[1];
            counter++;
            num++;
        }

        // KV
        ret = line.match(/(.+) = (.+)/);
        if (ret && matched == false) {
            matched = true;
            if (ret.length != 3) {
                throw new Exception(`Error ${line}`);
            }
            let key = ret[1];
            let val = ret[2];

            const cs = val.split(",");
            switch (key) {
                case '_parent':
                    val = val.substring(1, 5);
                    currentParent = val;
                    if (val != currentKey) {
                        currentKey = currentKey + ":" + val;
                        currentArr = [];
                        outobj.custom[currentKey] = currentArr;
                    } else {
                        currentArr = [];
                        outobj.original[currentKey] = currentArr;
                    }
                    break;

                case 'Cost':
                    if (cs.length == 1) {
                        currentArr.push({
                            id: 'amcs',
                            type: 'int',
                            value: parseInt(val),
                            level: 1
                        });
                    } else if (cs.length == 3) {
                        for (let i = 0; i < cs.length; i++) {
                            const ts = parseInt(cs[i]);
                            currentArr.push({
                                id: 'amcs',
                                type: 'int',
                                value: ts,
                                level: i + 1
                            });
                        }
                    } else {
                        counter += 99999999;
                        console.log(`Error: ${line}`);
                    }
                    break;
                case 'Name':
                    currentArr.push({
                        id: 'anam',
                        value: val.substring(1, val.length - 1)
                    });
                    break;
                case 'EditorSuffix':
                    currentArr.push({
                        id: 'ansf',
                        value: val.substring(1, val.length - 1)
                    });
                    break;
                case 'Art':
                    currentArr.push({
                        id: 'aart',
                        value: val.substring(1, val.length - 1)
                    });
                    break;
                case 'DataB':
                    switch (currentComment) {
                        case '目标类型':
                            if (cs.length == 1) {
                                currentArr.push({
                                    id: 'Ncl2',
                                    value: parseInt(val),
                                    level: 1,
                                    column: 2
                                });
                            } else if (cs.length == 3) {
                                for (let i = 0; i < cs.length; i++) {
                                    const ts = parseInt(cs[i]);
                                    currentArr.push({
                                        id: 'Ncl2',
                                        value: ts,
                                        level: i + 1,
                                        column: 2
                                    });
                                }
                            } else {
                                counter += 99999999;
                                console.log(`Error: ${line}`);
                            }
                            break;
                        case '每秒魔法消耗':
                            if (cs.length == 1) {
                                currentArr.push({
                                    id: 'Eim2',
                                    type: 'unreal',
                                    value: parseFloat(val),
                                    level: 1,
                                    column: 2
                                });
                            } else if (cs.length == 3) {
                                for (let i = 0; i < cs.length; i++) {
                                    const ts = parseFloat(cs[i]);
                                    currentArr.push({
                                        id: 'Eim2',
                                        type: 'unreal',
                                        value: ts,
                                        level: i + 1,
                                        column: 2
                                    });
                                }
                            } else {
                                counter += 99999999;
                                console.log(`Error: ${line}`);
                            }
                            break;
                        case '每秒伤害':
                            currentArr.push({
                                id: 'Poa2',
                                type: 'real',
                                value: parseFloat(val),
                                column: 2,
                                level: 1
                            });
                            break;
                        case '生命回复增加':
                            currentArr.push({
                                id: 'Uau2',
                                type: 'unreal',
                                value: parseFloat(val),
                                column: 2,
                                level: 1
                            });
                            break;
                        case '攻击速度增加(%)':
                            currentArr.push({
                                id: 'Oae2',
                                type: 'unreal',
                                value: parseFloat(val),
                                column: 2,
                                level: 1
                            });
                            break;
                        case '攻击奖励':
                            currentArr.push({
                                id: 'Neg2',
                                type: 'unreal',
                                value: parseFloat(val),
                                column: 2,
                                level: 1
                            });
                            break;
                        case '防御奖励':

                            break;
                        case '智力奖励':

                            break;
                        case '变形单位 - 地面':

                            break;
                        case '受到伤害倍数':

                            break;

                        default:
                            console.log(`Uncaught comment ${currentComment}`);

                            break;
                    }
                    break;
                case 'levels':
                    currentArr.push({
                        id: 'alev',
                        value: parseInt(val)
                    });
                    break;
                default:
                    // console.log(`Uncaught key ${key}`);
                    break;
            }

            // console.log(`Key: ${ret[1]} Value: ${ret[2]}`);
        }

        ret = line.match(/-- (.+)/);
        if (ret && matched == false) {
            matched = true;
            currentComment = ret[1];
        }

        if (matched == false) {
            throw new Exception(`Uncaught ${line}`);
        }
    } else {
        counter--;
    }
}).on('close', () => {
    if (counter == 0) {
        console.log();
        fs.writeFile(path.join("objects", "w3a.json"), JSON.stringify(outobj, null, 4), (err) => {
            if (err) {
                return console.log(err);
            }
            console.log("Success - w3a.json saved to ./objects");
        });
    } else {
        console.log('Ultimate failure!');
    }
});