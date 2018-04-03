const fs = require('fs');
const Translator = require('wc3maptranslator');

const test = JSON.parse(fs.readFileSync('./objects/A0Z9.json').toString());

console.log(test);

const someObjTranslator = new Translator.Objects('abilities', test);
someObjTranslator.write('objects');