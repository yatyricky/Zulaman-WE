# Zulaman（祖阿曼 RPG）SharpForge 重写计划

> 日期：2026-10-05
> 状态：草案（已存档，未批准实施）
> 决定：脚本全部抛弃、从零重写；配置层抛弃 assets/data/export.js，改用 gbuilder；SharpForge 作为 C#→Lua 工具链。

---

## 1. 可行性结论

**可行，且成功条件比一般"换语言重写"好得多。**

| 维度 | 现状 | 判断 |
|---|---|---|
| 平台 | 现图已是 Reforged 1.36（JassHelper 构建） | SharpForge 同样只面向 Reforged Lua 地图，无版本冲突 |
| 资产 | 地形、装饰物、放置单位（war3mapUnits.doo）、对象数据（war3mapSkin.w3a/.w3b/.w3d/.w3h/.w3t/.w3u）、导入资源、rawcode | **全部保留，不需要重写** |
| 脚本 | ~3.7 万行 zinc（363 文件）+ ~6 千行 vJass import 库 | 全部抛弃；旧代码仅作"逻辑规格书"参考阅读 |
| 工具链 | 本机已有 SharpForge 检出（含 publish 产物）、lua-maps 参考工程（CSProject/LuaProject + .w3x 样例） | sf-jassgen 直接吃本仓库 assets/data 的 common.j/blizzard.j 生成 C# 原生绑定，natives 名称不变 |
| 配置 | 8 张 xlsx + export.js 生成 zinc 配置库 | **抛弃**；改用 gbuilder（见 §2） |

重构红利（旧债务在新架构下整体消失）：

- handle-id / TimerUtils / Table 一整套 JASS 时代机制 → GC 语言 + 原生闭包/表。
- 克隆族模板债：27 个药水文件、24 个词缀文件、HexLord 复制的 ~30 个技能。
- ~1100 行手工 rawcode 常量（Const.j / SpellData.j / ModelInfo.j）→ 配置表列 + 校验。
- 双源真相问题（脚本真身压缩在 w3x 里，assets\scripts 是手工同步镜像）→ C#/JSON 源码成为唯一真相，构建注入副本。
- Log_legacy 里的已知怪异行为（卡施法、死亡残留光环等）多属上述类别，重写顺带消灭。

## 2. 配置层：gbuilder（WIP，需补能力）

gbuilder 现状（`C:\Users\yatyr\workspace\gvbasic-mir-remaster\gbuilder`）：

- 通用"智能配置表编辑器"：Node ESM + Express 5 + Svelte 5，JSON 为唯一真相源，schema 驱动（project.json），工作区概念，无游戏特定耦合。
- 已有：行 CRUD、FK 链导航、FK/枚举/主键校验、可视化 schema 编辑、引用检查阻止删除、xlsx 一次性导入器、多工作区切换、~750 行 vitest。
- **缺（本次补）**：代码生成发射器（JSON → C#）、以及按需的 CLI 入口。
- 参照物：mir 仓库被删的 `gen_config.js`（`git show 5602a47^:gen_config.js`）。

### 数据流架构

```
旧 xlsx（只读历史，不再维护）
   └─ 一次性迁移脚本 → 种子数据（平衡数值/多语言文案/掉落）
gbuilder 工作区（Zulaman-WE/config/：project.json schema + data/*.json）   ← 编辑期用 gbuilder UI
   └─ codegen 发射器（新功能，CLI，写入 gbuilder 仓库）
        → 强类型 C# 配置类 → sharp/CSProject/Config/
        → sf-transpile → sf-build → 注入 .w3x 副本
```

原则：

- **构建期只读工作区 JSON 文件**，不依赖 gbuilder 服务器；服务器只在编辑配置时以 `GBUILDER_PROJECT` 指向本工程启动。耦合天然松散。
- schema 按新架构重新设计（旧配置设计已判定不合理），**不照搬**旧 8 张 xlsx 的结构；rawcode 纳入表列并做格式校验。
- 旧 xlsx 中有长期调出的存量数据（数值/文案/掉落）通过一次性脚本导入为种子，只导能对上的列。

## 3. 本次执行范围：Milestone 0 —— 双地基 + 垂直切片

### 3.1 存档保护
- `git tag zam-zinc-final`；旧 zinc 构建流程（index.js build/run/replay）原样保留，旧图继续可玩、充当行为对照。
- 检查 war3map.wtg，确认无藏在世界编辑器 GUI 触发器里的逻辑（若有，登记为待重写清单）。

### 3.2 gbuilder 接入（Zulaman-WE 侧）
- 建 `config/` 工作区：project.json（核心表 schema：Ability/Buff/Item/Affix/Loot/ItemSet/Language/Attribute，按新架构设计）+ data/。
- 写一次性 xlsx→JSON 迁移脚本（适配 gbuilder 的 scripts/xlsx-to-json.js 或独立小脚本）。
- Milestone 0 只迁移垂直切片用到的表；全量迁移放后续。
- 验证：用 gbuilder UI（FK 链导航、校验）编辑跑通。

### 3.3 gbuilder codegen 发射器（gvbasic-mir-remaster 仓库侧，新功能）
- CLI 形式：如 `node cli.js gen <workspace> --out <dir> --lang csharp`。
- 输出强类型 C# 静态配置类：枚举、`List<T>`/`Dictionary<K,V>`、FK 解析为直接引用或按主键查找表。
- 对 SharpForge 支持的 C# 子集保持兼容（编译期类型检查替代旧 zinc 的 Table 运行时查找）。
- 带 vitest 测试（沿用 gbuilder 现有测试风格）。

### 3.4 sharp/ 工程搭建
- `sharp/CSProject/`：IntelliSense 用 .csproj；sf-transpile 首次运行拷入 libs stubs；sf-jassgen 生成 `generated/`（Handles/Natives/Globals 绑定，源用 assets/data/common.j + blizzard.j）。
- 源码组织：`Core/`（游戏循环、定时器、事件总线、伤害、仇恨、Buff、属性、施法、投射物）、`Config/`（codegen 产物）、`Heroes/`、`Bosses/`、`Creeps/`、`Items/`、`AI/`。
- Node 构建脚本加 `sharp` 管线：gbuilder codegen → sf-transpile → sf-build（注入地图副本）→ 启动加载；与旧 zinc 管线并存。

### 3.5 地图去脚本化（一次性）
- 复制 ZAM_ruins.w3x 为 SharpForge 工作图；移除全部旧脚本产物（war3map.j 等），建最小 war3map.lua（sf-build 会把 bundle splice 进 `function main()`）。
- 用 lua-maps/tools 或等价 MPQ 工具操作；**原 .w3x 不动**。

### 3.6 垂直切片（配置驱动，证明双地基跑通完整链路）
- 基础设施：GameLoop/Tick/DelayTask（原生闭包+定时器，替代 TimerUtils/NefUnion）、事件总线（C# 委托，替代 21 个 function-pointer type）、浮动数字。
- 一条完整玩法链：英雄技能（如 FrostBolt）→ 最小伤害管线（直伤+浮动数字+死亡）→ 小怪掉落（Loot 最小版）→ 数据驱动治疗药水——**技能/药水/掉落全部读 gbuilder 生成的配置**。
- 验证门禁：
  1. 单机进图跑通；
  2. 条件允许做一次联机同步测试（1–6 人 RPG，同步是硬门禁）；
  3. 性能冒烟：批量单位受击帧率。

### 3.7 决策门
复盘后决定铺开、调整或止损：SharpForge transpiler 缺口清单（反哺其 TODO）、gbuilder codegen 缺口、生成 Lua 性能、三项目开发体验。

## 4. 后续路线图（Milestone 0 通过后）

1. **框架层**：UnitProperty 属性模型、BuffSystem、AggroSystem、CastingBar、Projectile、Regeneration——按旧逻辑行为对照重写，架构换代。
2. **英雄层**：11 职业 ~65 技能 → "技能数据（gbuilder 表）+ 可复用效果组件"，消灭每技能一文件模板债。
3. **Boss 层**：8 个 Boss；HexLord 直接复用玩家技能组件，消灭 ~30 个 Hex 副本。
4. **AI 层**：AllianceAI（~2000 行）与 CreepsAction（~1600 行）→ "AI 行为组件 + 每单位数据"。
5. **物品层**：词缀引擎（旧 ItemAttributes 1213 行）→ 通用属性总线 + gbuilder Affix 表（FK 引用完整性直接受益）。
6. **收尾**：GameProcess 流程、TownPortal、HeroSelection、多语言（Language 表）、WELA 战斗日志导出；全量 xlsx 存量迁移。

## 5. 主要风险

- **三个 WIP 项目互相依赖**（地图重写 ← SharpForge ← gbuilder 补功能），互相拉扯开发时间；靠 §3.7 决策门尽早止损或调整。
- gbuilder 无 codegen 先例，发射器与 schema 设计会随首批真实表返工一两次，属预期成本。
- SharpForge 尚无 release（under active development），transpiler 缺口会持续暴露；好处是作者是自己，缺口可直接修。
- 多人同步与生成 Lua 性能必须在垂直切片阶段就设门禁验证，不能拖到后期。
- 工作量诚实估计：数月量级（旧代码 3.7 万行作规格书阅读重写 + 配置/框架双地基）。

## 附：关键事实备查

- 现图：`ZAM_ruins.w3x`（1.1 MB，126 commits），Reforged 1.36；`zaruins.w3x\` 为解包的对象数据/资源；`assets\scripts\` 为脚本镜像（379 文件 / 36,981 行）。
- 构建：`node index.js build|run|replay`（JassHelper 用 Reforged 自带）；配置 `node assets\data\export.js`（xlsx → zinc 库）。
- SharpForge：`C:\Users\yatyr\workspace\SharpForge`（MIT，.NET 10，sf-transpile / sf-build / sf-jassgen / sf-gui）；注入方式为 splice 进 war3map.lua 的 `main()`，只支持 Lua 地图；文档 docs/cli.md、docs/generated-lua.md。
- gbuilder：`C:\Users\yatyr\workspace\gvbasic-mir-remaster\gbuilder`（v0.1.0，无 README；ODIN_PLAN.md 为后继构想）；示例工作区 `gbuilder/example`。
- 参考工程：`C:\Users\yatyr\workspace\lua-maps`（CSProject/LuaProject 结构、melee 地图全套、tools/、apitest.w3x）。
