const path = require("path")
const fs = require("fs")
const xlsx = require("xlsx")

const FileList = [
    // path.join(__dirname, "ItemConfig.xlsx"),
    path.join(__dirname, "LanguageConfig.xlsx"),
]

const FpConstConfig = `assets/scripts/config/ConstConfig.j`
const Constants = []

class Utils {
    static ReadString(ws, c, r) {
        const address = xlsx.utils.encode_cell({ c, r })
        const cell = ws[address]
        if (cell === undefined) {
            return ""
        } else {
            return cell.v
        }
    }

    static ObjectEquals(a, b) {
        const sa = { ...a }
        for (const bk in b) {
            if (Object.hasOwnProperty.call(b, bk)) {
                const bv = b[bk];
                const av = a[bk]
                if (av !== bv) {
                    return false
                }
                delete sa[bk]
            }
        }
        return Object.keys(sa).length === 0
    }

    static StringEmpty(s) {
        return s === undefined || s === null || s.length === 0
    }

    static GetOrAddObject(obj, key) {
        let v = obj[key]
        if (v === undefined) {
            v = {}
            obj[key] = v
        }
        return v
    }
}

const TypeDefines = {
    int32: {
        jassTypeName: "integer",
        emitLiteral: function (raw) {
            return raw
        },
    },
    string: {
        jassTypeName: "string",
        emitLiteral: function (raw) {
            return `"${raw.replace(/"/g, "\\\"")}"`
        }
    },
    identifier: {
        jassTypeName: "identifier",
        emitLiteral: function (raw) {
            return raw
        },
    }
}

class Field {
    constructor(name, type, meta) {
        this.name = name
        this.type = type
        this.meta = meta
        this.values = []
        this.jassType = TypeDefines[type].jassTypeName
    }

    static ParseMeta(metaRaw) {
        const metaTokens = metaRaw.split(" ")
        const meta = {}
        for (const metaToken of metaTokens) {
            const metaTokenTrimmed = metaToken.trim()
            if (metaTokenTrimmed.length === 0) {
                continue
            }
            const metaKv = metaTokenTrimmed.split(":")
            meta[metaKv[0].trim()] = metaKv[1].trim()
        }
        return meta
    }

    static Equals(a, b) {
        return a.name === b.name
            && a.type === b.type
            && Utils.ObjectEquals(a.meta, b.meta)
    }
}

function UniqueCheck(field) {
    const set = new Set(field.values)
    return set.size === field.values.length
}

function MetaCheckTrue(metaValue) {
    return metaValue === "true"
}

const MetaBehaviours = {
    MakeIndex: {
        enable: MetaCheckTrue,
        validation: UniqueCheck,
    },
    RepeatCheck: {
        enable: MetaCheckTrue,
        validation: UniqueCheck,
    },
    ConstName: {
        validation: UniqueCheck,
    },
    ConstValue: {
        validation: UniqueCheck,
    },
    InternalType: {
        enable: function (metaValue) {
            return metaValue.length > 0
        },
        action: function (field) {
            field.jassType = field.meta.InternalType
        }
    },
}

function exportConfig(filePath) {
    const configName = path.parse(filePath).name
    console.log(`Working with ${filePath}: ${configName}`);
    const wb = xlsx.readFile(filePath)

    // read fileds
    const fields = []
    for (const sheetName in wb.Sheets) {
        if (Object.hasOwnProperty.call(wb.Sheets, sheetName)) {
            const ws = wb.Sheets[sheetName];
            const range = xlsx.utils.decode_range(ws["!ref"])
            for (let c = range.s.c; c <= range.e.c; c++) {
                const name = Utils.ReadString(ws, c, 0)
                const type = Utils.ReadString(ws, c, 1)
                const meta = Field.ParseMeta(Utils.ReadString(ws, c, 2))
                const currentField = new Field(name, type, meta)
                const existingField = fields.find(e => e.name === name)
                if (existingField === undefined) {
                    fields.push(currentField)
                } else if (!Field.Equals(currentField, existingField)) {
                    throw new Error("Redefined field")
                }
            }
        }
    }

    // read data
    for (const sheetName in wb.Sheets) {
        if (Object.hasOwnProperty.call(wb.Sheets, sheetName)) {
            const ws = wb.Sheets[sheetName];
            const range = xlsx.utils.decode_range(ws["!ref"])
            for (let c = range.s.c; c <= range.e.c; c++) {
                const fieldName = Utils.ReadString(ws, c, 0)
                const field = fields.find(e => e.name === fieldName)
                for (let r = 4; r <= range.e.r; r++) {
                    field.values.push(Utils.ReadString(ws, c, r))
                }
            }
        }
    }

    // validation
    for (const field of fields) {
        const validations = new Set()
        const actions = new Set()
        for (const metaName in field.meta) {
            if (!Object.hasOwnProperty.call(field.meta, metaName)) {
                continue
            }
            const metaValue = field.meta[metaName];
            const metaBehaviour = MetaBehaviours[metaName]
            if (metaBehaviour.enable !== undefined && !metaBehaviour.enable(metaValue)) {
                continue
            }
            if (metaBehaviour.validation !== undefined) {
                validations.add(metaBehaviour.validation)
            }
            if (metaBehaviour.action !== undefined) {
                actions.add(metaBehaviour.action)
            }
        }

        for (const validation of validations) {
            if (!validation(field)) {
                throw new Error(`Field ${field.name} Validation failed`)
            }
        }

        for (const action of actions) {
            action(field)
        }
    }

    // emit ConstConfig.j
    const constKvMap = {}
    for (const field of fields) {
        if (!Utils.StringEmpty(field.meta.ConstName)) {
            const map = Utils.GetOrAddObject(constKvMap, field.meta.ConstName)
            map.nameField = field
        }
        if (!Utils.StringEmpty(field.meta.ConstValue)) {
            const map = Utils.GetOrAddObject(constKvMap, field.meta.ConstValue)
            map.valueField = field
        }
    }

    for (const kvMap of Object.values(constKvMap)) {
        for (let i = 0; i < kvMap.nameField.values.length; i++) {
            const nameValue = kvMap.nameField.values[i];
            const valueValue = kvMap.valueField.values[i]
            const typeDefine = TypeDefines[kvMap.valueField.type]
            Constants.push(`    public constant ${typeDefine.jassTypeName} ${nameValue} = ${typeDefine.emitLiteral(valueValue)};`)
        }
    }
    fs.writeFileSync(FpConstConfig, `//! zinc
library ConstConfig {
${Constants.join("\n")}
}
//! endzinc
`)

    // infer internal type for identifier
    for (const field of fields) {
        if (field.jassType === "identifier") {
            const kvMap = constKvMap[field.meta.ConstName]
            field.jassType = kvMap.valueField.jassType
        }
    }

    // emit code
    const indexes = fields.filter(e => e.meta.MakeIndex !== undefined && MetaBehaviours.MakeIndex.enable(e.meta.MakeIndex))
    fs.writeFileSync(`assets/scripts/config/${configName}.j`, `//! zinc
library ${configName} requires Table {
    public struct ${configName} {
        // indexes
${indexes.map(e => `        private static Table db${e.name};`).join("\n")}
        // properties
${fields.map(e => `        ${e.jassType} ${e.name};`).join("\n")}

        // Find config by specified index
${indexes.map(e => `        static method FindBy${e.name}(integer ${e.name}) -> thistype {
            if (thistype.db${e.name}.exists(${e.name})) {
                return thistype(thistype.db${e.name}[${e.name}]);
            } else {
                print(SCOPE_PREFIX + " Unknown ${e.name}: " + I2S(${e.name}));
                return 0;
            }
        }
`).join("\n")}

        // new config
        private static method create(${fields.map(e => `${e.jassType} ${e.name}`).join(", ")}) -> thistype {
            thistype this = thistype.allocate();
${indexes.map(e => `            thistype.db${e.name}[${e.name}] = this;`).join("\n")}
${fields.map(e => `            this.${e.name} = ${e.name};`).join("\n")}
            return this;
        }

        // initialization
        private static method onInit() {
${indexes.map(e => `            thistype.db${e.name} = Table.create();`).join("\n")}
${fields[0].values.map((_, i) => `            thistype.create(${fields.map(e => TypeDefines[e.type].emitLiteral(e.values[i])).join(", ")});`).join("\n")}
        }
    }
}
//! endzinc
`)

}

for (const file of FileList) {
    exportConfig(file)
}
