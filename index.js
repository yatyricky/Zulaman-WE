const fs = require('fs');
const Translator = require('wc3maptranslator');
const path = require('path');

const w3a = JSON.parse(fs.readFileSync(path.join("objects", "w3a.json")).toString());

const objTrans = new Translator.Objects('abilities', w3a);
objTrans.write('objects');


const cmd = require('child_process').exec;

cmd('"D:\\Applications\\MPQEditor\\MPQEditor.exe" add "D:\\Documents\\Warcraft III\\Maps\\Zulaman-WE\\ZAM ruins WIP.w3x" "D:\\Documents\\Warcraft III\\Maps\\Zulaman-WE\\objects\\war3map.w3a" "war3map.w3a"', (err, stdout, stderr) => {
    if (err) {
        console.log(err);
        return;
    }

    // cmd('"D:\\Applications\\SharpCraft World Editor Extended Bundle\\SharpCraft WEX Bundle (0.1.2.9)\\profiles\\Warcraft III - World Editor (WEX)\\plugins\\JassHelper\\clijasshelper.exe" "D:\\Applications\\SharpCraft World Editor Extended Bundle\\SharpCraft WEX Bundle (0.1.2.9)\\profiles\\Warcraft III - World Editor (WEX)\\plugins\\temp\\common.j" "D:\\Applications\\SharpCraft World Editor Extended Bundle\\SharpCraft WEX Bundle (0.1.2.9)\\profiles\\Warcraft III - World Editor (WEX)\\plugins\\temp\\blizzard.j" "D:\\Documents\\Warcraft III\\Maps\\Zulaman-WE\\ZAM ruins WIP.w3x"', (err, stdout, stderr) => {
    //     if (err) {
    //         console.log(err);

    //         // node couldn't execute the command
    //         return;
    //     }

    //     // the *entire* stdout and stderr (buffered)
    //     console.log(`jasshelper stdout: ${stdout}`);
    //     console.log(`jasshelper stderr: ${stderr}`);
    // });

    // the *entire* stdout and stderr (buffered)
    console.log(`mpq stdout: ${stdout}`);
    console.log(`mpq stderr: ${stderr}`);
});