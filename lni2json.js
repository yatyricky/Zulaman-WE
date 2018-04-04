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
                    const cs = val.split(",");
                    if (cs.length == 1) {
                        currentArr.push({
                            id: 'amcs',
                            value: parseInt(val)
                        });
                    } else if (cs.length == 3) {
                        for (let i = 0; i < cs.length; i++) {
                            const ts = parseInt(cs[i]);
                            currentArr.push({
                                id: 'amcs',
                                value: ts,
                                column: 1,
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
                    // currentArr.push({
                    //     id: 'aart',
                    //     value: val.substring(1, val.length - 1)
                    // });
                    break;
                case 'DataB':
                    switch (currentComment) {
                        case '目标类型':
                            const cs = val.split(",");
                            if (cs.length == 1) {
                                // currentArr.push({
                                //     id: 'Ncl2',
                                //     value: parseInt(val),
                                //     type: "unreal"
                                // });
                            } else if (cs.length == 3) {
                                for (let i = 0; i < cs.length; i++) {
                                    const ts = parseInt(cs[i]);
                                    // currentArr.push({
                                    //     id: 'Ncl2',
                                    //     value: ts,
                                    //     column: 1,
                                    //     level: i + 1,
                                    //     type: "unreal"
                                    // });
                                }
                            } else {
                                counter += 99999999;
                                console.log(`Error: ${line}`);
                            }
                            break;
                        case '每秒魔法消耗':

                            break;
                        case '每秒伤害':

                            break;
                        case '生命回复增加':

                            break;
                        case '攻击速度增加(%)':

                            break;
                        case '攻击奖励':

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
            console.log("The file was saved!");
        });
    } else {
        console.log('Ultimate failure!');
    }
});