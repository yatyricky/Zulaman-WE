# Warcraft III UI Frame 开发参考（3.0.0 / Lua）

> 面向 agent/harness 的结构化参考。基于 Tasyen《The Big UI-Frame Tutorial》（Hive Workshop, 最后更新 2026-01）整理，并合并 3.0.0 `common.j` 新增 API。
> 本项目（Zulaman-WE）为 C#→Lua 转译运行时，本文所有 native 在 `csproj/libs/Jass-3.0.0/Natives.g.cs` 与生成的 `war3map.lua` 中以同名直通调用；示例用 Lua 书写，C# 侧调用形式一致。
> 版本基线：**3.0.0**。标注（≥1.32.6）的能力在 3.0.0 可用；标注（1.31）的历史坑已无影响，仅供避坑时理解缘由。

---

## 目录

1. [心智模型与家族划分](#1-心智模型与家族划分)
2. [坐标系统与定位](#2-坐标系统与定位)
3. [获取 Frame](#3-获取-frame)
4. [创建 Frame](#4-创建-frame)
5. [父子关系与层级](#5-父子关系与层级)
6. [事件与同步语义](#6-事件与同步语义)
7. [Tooltip](#7-tooltip)
8. [键盘焦点](#8-键盘焦点)
9. [多人与防 Desync 规则](#9-多人与防-desync-规则)
10. [TOC / FDF 参考](#10-toc--fdf-参考)
11. [默认 Frame 名录（精选）](#11-默认-frame-名录精选)
12. [3.0.0 新增 UI 相关 API](#12-300-新增-ui-相关-api)
13. [崩溃与坑清单](#13-崩溃与坑清单)
14. [常用配方 Recipes](#14-常用配方-recipes)

---

## 任务速查表

| 需求 | 方案 | 章节 |
|---|---|---|
| 屏幕上显示一张图 | `BlzCreateFrameByType("BACKDROP", ...)` + SetTexture/SetSize/SetAbsPoint | §14.1 |
| 显示文本 | `BlzCreateFrameByType("TEXT", ...)`（SimpleFrame 用 String 子帧） | §14.2 |
| 可点击按钮 | `GLUETEXTBUTTON` + inherit `ScriptDialogButton`；或 `BUTTON` + `ScoreScreenTabButtonTemplate` | §14.3 |
| 图标按钮（点击有按压缩放） | `GLUETEXTBUTTON` inherit `ScriptDialogButton`，child 0/1 是默认/按下态 BACKDROP | §14.4 |
| 血条/进度条 | `SIMPLESTATUSBAR`（代码直建）或 `STATUSBAR`（模型条） | §14.5 |
| 滑条/复选框 | SLIDER inherit `QuestMainListScrollBar`；CHECKBOX 用 `QuestCheckBox2` | §14.6/14.7 |
| 滚动文本区 | TEXTAREA，必须给尺寸（高度≥0.03 否则崩溃） | §14.8 |
| 修改默认 UI（金币文本等） | `BlzGetFrameByName` + SetText/SetPoint | §3/§11 |
| 隐藏默认 UI | `BlzHideOriginFrames(true)` + 补刀（ConsoleUIBackdrop 等） | §14.10 |
| 探测鼠标悬停某按钮 | 给按钮挂空 SIMPLEFRAME tooltip，轮询其可见性（async） | §14.9 |
| 像素级布局 | 3.0.0：`BlzPixelToFrameX/Y`、`BlzFrameToPixelX/Y` | §12 |
| 查询按键/鼠标键状态 | 3.0.0：`BlzIsKeyPressed`、`BlzIsMetaKeyPressed`、`BlzIsMouseButtonPressed` | §12 |

---

## 1. 心智模型与家族划分

Frame 是 WC3 的 UI 元素（小地图、命令按钮、聊天框、排行榜……均由 Frame 构成）。家族划分决定一切规则，**先判族，再写代码**：

| 家族 | 类型名 | 可否代码创建 | 4:3 限制 | 事件 | 渲染层 |
|---|---|---|---|---|---|
| **Frame 族** | `BACKDROP` `BUTTON` `GLUETEXTBUTTON` `TEXT` `TEXTAREA` `EDITBOX` `SLIDER` `CHECKBOX` `POPUPMENU` `DIALOG` `FRAME` `HIGHLIGHT` `SPRITE` `MODEL` `STATUSBAR` `SCROLLBAR` `LISTBOX` `MENU` 等 | 任意方式 | 受限（越界即畸形：TEXT 截字、BACKDROP 缩小） | 多数支持 | 高 |
| **SimpleFrame 族** | `SIMPLEFRAME` `SIMPLEBUTTON` `SIMPLESTATUSBAR` `SIMPLECHECKBOX` | 需 FDF 预定义（`BlzCreateSimpleFrame`） | **不受限** | 仅 SIMPLEBUTTON 支持 CONTROL_CLICK | 中 |
| **String/Texture** | `String` `Texture` | 只能作为 SimpleFrame 的子帧存在 | 不受限 | 无 | 父帧所在层 |

硬规则：

- Frame 族与 SimpleFrame 族**不能**互为父子。强行混挂不会报错，但引擎会静默替换成"替身父帧"（比较 `BlzFrameGetParent` 的 handleId 可发现不一致），可见性/alpha 继承全部失效。
- 判断任意 handle 属于哪一族：用 §14.11 的 `WhatTypeOfFrame(frame)`（返回 0=Frame 族，1=SimpleFrame 族，2=String/Texture，nil=无效）。
- `BlzFrameSetFont` 只对 String（SimpleFrame 子帧）有效；对 TEXT 帧无效（不崩溃但无效果），对 SimpleFrame 本体则**崩溃**。

---

## 2. 坐标系统与定位

### 2.1 坐标系

- 4:3 参考区：`x ∈ [0, 0.8]`，`y ∈ [0, 0.6]`，(0,0) 在 4:3 区域**左下**（约小地图左下角），(0.8, 0.6) 在右上（维护费等级文本右上角）。
- 与分辨率无关，永远是这组值。Size 也用同一单位。
- 像素换算：3.0.0 起直接用 `BlzPixelToFrameX/Y` / `BlzFrameToPixelX/Y`（§12），旧版需自行按 `BlzGetLocalClientWidth/Height` 换算。

### 2.2 定位 natives

```lua
BlzFrameSetPoint(frame, point, relative, relativePoint, x, y) -- 将 frame 的 point 锚到 relative 的 relativePoint，偏移 x(+右)/y(+上)。relative 移动时跟随。偏移量受 frame 自身 Scale 影响
BlzFrameSetAbsPoint(frame, point, x, y)                        -- 锚到 4:3 绝对坐标，解除原有绑定
BlzFrameClearAllPoints(frame)                                  -- 清除全部锚点。移动已定位的 Frame 前必须先调用
BlzFrameSetAllPoints(frame, relative)                          -- 复制 relative 的位置与尺寸，且持续跟随
```

`framepointtype` 九个常量：`FRAMEPOINT_TOPLEFT / TOP / TOPRIGHT / LEFT / CENTER / RIGHT / BOTTOMLEFT / BOTTOM / BOTTOMRIGHT`。

### 2.3 单锚点的伸展方向（决定 size 往哪边扩）

| 锚点含 | 伸展方向 |
|---|---|
| LEFT | 只向右扩 |
| RIGHT | 只向左扩 |
| CENTER | 两边均分 |
| TOP | 只向下扩 |
| BOTTOM | 只向上扩 |

可以给一个 Frame 设多个锚点，引擎会尽量满足成矩形（常用于双点拉伸：同时锚 BOTTOMLEFT 与 TOPRIGHT）。

### 2.4 相对定位的"反直觉"方向

要把 A 放到 B 的**左侧**，是把 **A 的 RIGHT** 锚到 **B 的 LEFT**：

```lua
BlzFrameSetPoint(frameLeft,  FRAMEPOINT_RIGHT, target, FRAMEPOINT_LEFT,  0, 0)      -- A 在 B 左
BlzFrameSetPoint(frameRight, FRAMEPOINT_LEFT,  target, FRAMEPOINT_RIGHT, 0, 0)      -- A 在 B 右
BlzFrameSetPoint(frameBelow, FRAMEPOINT_TOP,   target, FRAMEPOINT_BOTTOM,0, 0)      -- A 在 B 下
```

链式排布无需算坐标：`BlzFrameSetPoint(new, FRAMEPOINT_LEFT, prev, FRAMEPOINT_RIGHT, 0.003, 0)` 即从左到右排开（向左排则偏移要用负数，否则重叠）。

### 2.5 4:3 越界（Frame 族）

| 手段 | 代价 |
|---|---|
| 父帧改为 `BlzGetFrameByName("ConsoleUIBackdrop", 0)` | 层级降到 SimpleFrame 之下 |
| 父帧改为 Leaderboard/Multiboard（需先用旧 API 创建并隐藏装饰） | 层级在 SimpleFrame 之上；Leaderboard 会被重定位逻辑影响 |
| 自建全屏 FRAME 锚点参照物（§14.12） | 需定时器按分辨率刷新；**窗口最小化时 `BlzGetLocalClientHeight()` 返回 0，除以 0 会崩线程，必须先判 0** |

SimpleFrame 族天然不受 4:3 限制。

---

## 3. 获取 Frame

### 3.1 三种获取方式

```lua
BlzGetFrameByName(name, createContext) -> framehandle  -- 按名查存储槽；查无返回 handleId==0 的空 handle（Lua 中不是 nil！必须用 GetHandleId(f)==0 判空）
BlzGetOriginFrame(originframetype, index) -> framehandle
BlzFrameGetChild(frame, index) / BlzFrameGetChildrenCount(frame)  -- (≥1.32.6) 遍历子帧
```

**createContext**：创建 Frame 时指定的存储分区号。同名的子帧跟随主帧的 createContext。复用同一 FDF 模板创建多实例时，用不同 createContext 区分访问。单实例默认 0。

### 3.2 ORIGIN_FRAME 常量表

`BlzGetOriginFrame(常量, index)`，未标注 index 的用 0；给出范围的使用 `0..max`：

| 常量 | index | 说明 |
|---|---|---|
| `ORIGIN_FRAME_GAME_UI` | | 万物之根；自定义 Frame 的默认父帧 |
| `ORIGIN_FRAME_WORLD_FRAME` | | 可见游戏世界；可 SetPoint 缩小可玩区（左右限制不完善） |
| `ORIGIN_FRAME_COMMAND_BUTTON` | 0..11 | 命令卡按钮。1.32+ 移动会闪烁，**改用 `CommandButton_N` 按名移动** |
| `ORIGIN_FRAME_HERO_BAR` | | 所有英雄按钮的父帧 |
| `ORIGIN_FRAME_HERO_BUTTON` | 0..6 | 英雄头像按钮（移动需先 `BlzHideOriginFrames(true)` 或 `BlzEnableUIAutoPosition(false)`） |
| `ORIGIN_FRAME_HERO_HP_BAR` / `HERO_MANA_BAR` | 0..6 | 锚在各自英雄按钮上 |
| `ORIGIN_FRAME_HERO_BUTTON_INDICATOR` | 0..6 | 升级光效；隐藏后英雄获得新技能点会重新出现 |
| `ORIGIN_FRAME_ITEM_BUTTON` | 0..5 | 物品栏。1.32+ 改用 `InventoryButton_N` 按名移动 |
| `ORIGIN_FRAME_MINIMAP` | | 小地图；移动建议双锚点（BOTTOMLEFT+TOPRIGHT） |
| `ORIGIN_FRAME_MINIMAP_BUTTON` | 0..4 | 小地图侧按钮（0 顶 → 4 底） |
| `ORIGIN_FRAME_SYSTEM_BUTTON` | 0..3 | 任务/菜单/结盟/聊天；与按名版本等价（名字见 §11） |
| `ORIGIN_FRAME_PORTRAIT` | | 头像。使用独立坐标系（绝对左下为 0,0，非 4:3 语义） |
| `ORIGIN_FRAME_TOOLTIP` / `ORIGIN_FRAME_UBERTOOLTIP` | | Tooltip 框体 |
| `ORIGIN_FRAME_CHAT_MSG` / `UNIT_MSG` / `TOP_MSG` | | 聊天/游戏消息/维护费警告。**错误尺寸/坐标可崩溃**：UNIT_MSG 高度勿超 0.25；TOP_MSG 建议 ClearAllPoints 后只锚一个点 |
| `ORIGIN_FRAME_PORTRAIT_HP_TEXT` / `MANA_TEXT` | | ≥1.32；**选择过单位后才存在**；只支持 FRAMEPOINT_CENTER 移动；是 String 类（见 §13 禁用 native 表） |
| `ORIGIN_FRAME_UNIT_PANEL_BUFF_BAR` / `..._LABEL` | | ≥1.32；Buff 条；LABEL 是 String 类 |
| `ORIGIN_FRAME_SIMPLE_UI_PARENT` | | ≥1.32；ConsoleUI 之父 |

### 3.3 Child API 规则（≥1.32.6）

- `BlzFrameGetChildrenCount` **不含** String/Texture 子帧；`BlzFrameGetChild` 也**取不到** SimpleFrame 的 String/Texture 子帧。
- 索引按 Level 排：**Level 最高 → 索引最大**；同 Level 后加的在后。
- GLUETEXTBUTTON 的子帧固定顺序：`[各状态 BACKDROP...] → [TEXT] → [松散子帧（按添加序）] → [HIGHLIGHT]`。即使 FDF 没写 TEXT 也会有一个默认 TEXT 子帧。
- 代码添加的子帧排在松散区末尾，会把 HIGHLIGHT 的索引往后推。
- **无越界检查**：index 越界的行为未定义，先 `GetChildrenCount` 再循环。
- 已知 bug（1.32.6）：若某 origin frame 先经 `BlzFrameGetChild` 拿到过，再调 `BlzGetOriginFrame` 取同一帧会得到 handleId 0 的空帧。规避：先用 `BlzGetOriginFrame` 取并缓存。

遍历工具：

```lua
local function PrintChildFrames(frame, prefix)
    print(prefix, BlzFrameGetName(frame))
    for i = 0, BlzFrameGetChildrenCount(frame) - 1 do
        PrintChildFrames(BlzFrameGetChild(frame, i), prefix .. "." .. i)
    end
end
```

### 3.4 懒创建的默认 Frame

部分默认 Frame **在首次使用前不存在**（handleId 0）：

- Quest 全家：先 `BlzFrameClick(BlzGetFrameByName("UpperButtonBarQuestsButton", 0))` 打开、再 `BlzFrameClick(BlzGetFrameByName("QuestAcceptButton", 0))` 关闭，强制生成。
- LogDialog 仅单机存在；ChatDialog 仅多人存在。
- Leaderboard / Multiboard / TimerDialog 需先用对应旧 API（`CreateLeaderboardBJ` 等）创建。
- 头像 HP/MP 文本：需发生过一次选择并稍等。
- 最小化恢复、切换窗口后也有延迟创建的帧——涉及 handleId 的同步敏感操作注意时序（§9）。

---

## 4. 创建 Frame

```lua
BlzCreateFrame(name, owner, priority, createContext)                  -- 创建 FDF 中定义的 MainFrame（Frame 族）
BlzCreateSimpleFrame(name, owner, createContext)                      -- 创建 FDF 中定义的 MainFrame（SimpleFrame 族）
BlzCreateFrameByType(typeName, name, owner, inherits, createContext)  -- 免 FDF 直接定义并创建（两族皆可）
```

参数语义：

- `name`/`typeName`：FDF 里 `Frame "TYPE" "NAME"` 的两个词；`BlzCreateFrameByType` 的 `inherits` 等价 FDF 的 `INHERITS WITHCHILDREN "模板名"`。
- `owner`：父帧（必须同族，见 §1）。`BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)` 是万能默认。
- `priority`：≥0 的整数（传 0 即可）。
- `createContext`：存储槽号，配合 `BlzGetFrameByName`。

流程模板：取父帧 → 创建 → SetSize/SetPoint/SetTexture/SetText（顺序无关）。

**默认已加载、可直接 inherit 的常用模板**（无需 TOC）：

| 模板名 | 用途 |
|---|---|
| `ScriptDialogButton` | 对话框风格文字按钮（注意：与 Dialog 系统硬编码冲突，用 ByType 另起名字规避） |
| `ScoreScreenTabButtonTemplate` | 黄色悬停发光、屏蔽右键穿透 |
| `IconButtonTemplate` | 蓝色悬停发光 |
| `QuestButtonBaseTemplate` / `QuestButtonDisabledBackdropTemplate` / `QuestButtonPushedBackdropTemplate` / `ScoreScreenButtonBackdropTemplate` / `EscMenuBackdrop` | 各风格盒状 BACKDROP |
| `QuestCheckBox` / `QuestCheckBox2` / `QuestCheckBox3` | 复选框（尺寸不同，可再 SetSize） |
| `QuestMainListScrollBar` | 垂直滑条底版 |
| `UpperButtonBarButtonTemplate` | 顶部菜单栏风格 SIMPLEBUTTON（`BlzCreateSimpleFrame` 用） |

需加载 TOC 才能用的：`EscMenuButtonTemplate`、`EscMenuSliderTemplate`、`EscMenuLabelTextTemplate`、`EscMenuTextAreaTemplate`、`EscMenuEditBoxTemplate`、`StandardButtonTemplate` 等（§10.3）。

---

## 5. 父子关系与层级

### 5.1 继承效应

子帧在创建时从父帧**复制** scale、alpha、level；改父帧的可见性会门控子帧（`BlzFrameIsVisible` 会向上检查祖先）；换父时 alpha 会被新父覆盖。子帧在鼠标事件上优先于父帧。

### 5.2 松散子帧 vs 功能子帧

- **功能子帧**（functional）：只能在 FDF 里定义（`ControlBackdrop "名字"`、`ButtonText "名字"`、`CheckBoxCheckHighlight "名字"` 等），自动跟随父帧位置/尺寸，复制 enable 状态。按钮的各状态背景、文本、高亮都是功能子帧。
- **松散子帧**（loose）：代码或 FDF 皆可加，位置默认独立于父帧。用于逻辑分组：一组 UI 挂一个隐藏容器 FRAME，一行 `BlzFrameSetVisible(容器, false)` 整组隐藏。
- 用 BUTTON 当"高 Level 载体"：给 BUTTON 设 FrameLevel，再以它为父创建 TEXT 等子帧，可突破类型默认层级。

### 5.3 FrameLevel 规则

**Frame 族**：只在**兄弟之间**比较；Level 高者在上。子帧整体位于父帧之上、但低于父帧的更高 Level 兄弟。例：GAME_UI 下 A(level 2)、B(level 3)，A 的子帧 AA(level 9) 仍然低于 B 及 B 的子帧——孙辈抬不过父辈的兄弟。

**SimpleFrame 族**：同一祖先下全局一层，Level 高者在顶，**父子关系不影响**；但 String/Texture 子帧生活在各自父帧开启的子层里。SIMPLEBUTTON 的 CONTROL_CLICK 优先于更高 Level 的非 Simple 竞争者。

最顶层的 Frame 独占该区域鼠标事件。

### 5.4 SetParent 陷阱

- 非SimpleFrame：`BlzFrameSetParent` **不会**从旧父的子帧列表移除（帧同时挂在两个父下，遍历会重复出现）。
- SimpleFrame：SetParent 行为正确（单父）。但新父当前隐藏时，子帧会保持隐藏，直到新父经历一次 hide→show。
- 把祖先设为其后代的子帧 = 无限循环崩溃。

---

## 6. 事件与同步语义

### 6.1 注册与取值

```lua
local t = CreateTrigger()
BlzTriggerRegisterFrameEvent(t, frame, FRAMEEVENT_CONTROL_CLICK)
TriggerAddAction(t, function()
    local f    = BlzGetTriggerFrame()       -- 事件源
    local ev   = BlzGetTriggerFrameEvent()  -- 事件类型（多事件共用 trigger 时区分）
    local val  = BlzGetTriggerFrameValue()  -- 数值（滑条/滚轮/弹出菜单）
    local txt  = BlzGetTriggerFrameText()   -- 文本（EDITBOX）
    local p    = GetTriggerPlayer()         -- 触发玩家
end)
```

### 6.2 事件常量表

| 常量 | id | 触发时机 |
|---|---|---|
| `FRAMEEVENT_CONTROL_CLICK` | 1 | 左键在帧内按下后松开；或帧持有键盘焦点时按空格/回车。先于 MOUSE_UP |
| `FRAMEEVENT_MOUSE_ENTER` | 2 | 鼠标进入（同步事件） |
| `FRAMEEVENT_MOUSE_LEAVE` | 3 | 鼠标离开（同步事件） |
| `FRAMEEVENT_MOUSE_UP` | 4 | 帧内松开任意鼠标键 |
| `FRAMEEVENT_MOUSE_DOWN` | 5 | 无效（无帧接受） |
| `FRAMEEVENT_MOUSE_WHEEL` | 6 | 指向帧时滚轮；`BlzGetTriggerFrameValue()` +120/-120，判 >0 / <0 |
| `FRAMEEVENT_CHECKBOX_CHECKED` | 7 / `..._UNCHECKED` | 8 | 勾选状态变化 |
| `FRAMEEVENT_EDITBOX_TEXT_CHANGED` | 9 | 文本变化（用户或代码都会触发） |
| `FRAMEEVENT_POPUPMENU_ITEM_CHANGED` | 10 | 选项切换；value = 新索引 |
| `FRAMEEVENT_MOUSE_DOUBLECLICK` | 11 | 无效 |
| `FRAMEEVENT_SPRITE_ANIM_UPDATE` | 12 | SPRITE 动画更新 |
| `FRAMEEVENT_SLIDER_VALUE_CHANGED` | 13 | 滑条值变化（用户或代码；对所有玩家各触发一次） |
| `FRAMEEVENT_DIALOG_CANCEL` | 14 / `..._ACCEPT` | 15 | FDF 定义的 DIALOG 按钮 |
| `FRAMEEVENT_EDITBOX_ENTER` | 16 | EDITBOX 持焦点时按回车 |

### 6.3 各 FrameType 支持的事件矩阵

| 类型 | 支持事件 |
|---|---|
| BACKDROP / HIGHLIGHT / SPRITE / SIMPLEFRAME / SIMPLESTATUSBAR / SIMPLECHECKBOX | 无 |
| BUTTON / GLUEBUTTON / GLUETEXTBUTTON / TEXTBUTTON / TEXT / TIMERTEXT | CLICK, ENTER, LEAVE, UP, WHEEL |
| CHECKBOX / GLUECHECKBOX | 上行 + CHECKED/UNCHECKED |
| EDITBOX / GLUEEDITBOX / SLASHCHATBOX | 上行 + TEXT_CHANGED, EDITBOX_ENTER |
| SLIDER | 上行 + SLIDER_VALUE_CHANGED |
| SCROLLBAR | ENTER, LEAVE, UP, WHEEL, SLIDER_VALUE_CHANGED |
| POPUPMENU / GLUEPOPUPMENU | ENTER, LEAVE, WHEEL, CLICK, POPUPMENU_ITEM_CHANGED |
| CHATDISPLAY / CONTROL / LISTBOX / MENU / TEXTAREA / MODEL | ENTER, LEAVE, UP（MODEL 还有 WHEEL） |
| DIALOG | DIALOG_CANCEL, DIALOG_ACCEPT |
| SIMPLEBUTTON | 仅 CONTROL_CLICK（**每按钮仅一个注册槽，重复注册覆盖前一个**） |

（标注"CLICK with BlzFrameClick"的类型可被代码 `BlzFrameClick` 人为触发 CLICK。）

### 6.4 值同步规则（关键）

- **事件内取值是同步的**：`BlzGetTriggerFrameText` / `BlzGetTriggerFrameValue` 在事件回调里对全体玩家一致，可安全存入共享变量后使用。
- **轮询取值是本地的**：`BlzFrameGetText` / `BlzFrameGetValue` / `BlzFrameIsVisible` 等返回本机状态（各玩家输入互不同步），直接用于同步逻辑会 desync。
- `BlzFrameSetValue` 对 N 个玩家各产生一次 SLIDER_VALUE_CHANGED（在所有玩家机上执行时共 N 次）；事件内记得用 `GetTriggerPlayer()` 区分来源。

---

## 7. Tooltip

- 规则：tooltip 与目标帧**必须同族**（Frame↔Frame；SimpleFrame 组内仅 SIMPLEBUTTON 可挂，且挂 SIMPLEFRAME 型 tooltip）。多数帧都能挂 tooltip，tooltip 本身也是帧（可含子帧、任意复杂度）。
- `BlzFrameSetTooltip(frame, tooltip)`：激活后 tooltip 在鼠标指向 frame 时显示；frame 被隐藏则不显示，禁用不影响。非 SimpleFrame 的 tooltip 会成为 frame 的子帧。
- **同一组合调用两次 BlzFrameSetTooltip = 悬停时崩溃；且无法解除绑定**（换一个空 tooltip 帧顶替是唯一"撤销"）。
- SimpleFrame 的 tooltip 调用后**不会自动隐藏**，需手动 `BlzFrameSetVisible(tooltip, false)`。
- Frame 族 tooltip 自身越出 4:3 会畸形（子帧不受影响）：给真正的 tooltip 外包一层空 FRAME 作 tooltip。
- 一个 tooltip 服务多个帧时文本可能加粗/渲染异常（作为子帧时同样）。
- 自适应高度文本框：TEXT 帧设 `BlzFrameSetSize(text, width, 0)` 高度自动随行数，再让背景 BACKDROP 双锚点反向包住 text（`BOTTOMLEFT←text.BOTTOMLEFT(-0.01,-0.01)`、`TOPRIGHT←text.TOPRIGHT(+0.01,+0.01)`），背景挂为 tooltip。

---

## 8. 键盘焦点

Frame 族按钮/EDITBOX 被点击后会**保持键盘焦点**：此后热键失效、按回车/空格会再次触发该按钮的 CLICK。玩家左键点击游戏世界可归还焦点。代码归还：

```lua
BlzFrameSetEnable(frame, false)
BlzFrameSetEnable(frame, true)
-- 多人下各玩家按钮启用状态不同时，仅对点击玩家执行：
if GetTriggerPlayer() == GetLocalPlayer() then
    BlzFrameSetEnable(frame, false); BlzFrameSetEnable(frame, true)
end
```

已知副作用：点击瞬间若正释放方向键，镜头可能持续平移；可用 `StopCameraForPlayerBJ()` / `StopCamera()` 停止，或等玩家再点一下鼠标。
SIMPLEBUTTON 点击后不保持焦点，无此问题。

---

## 9. 多人与防 Desync 规则

WC3 为锁步同步：仅玩家输入等少量数据走网络，**每台机器各自模拟**。Frame 的存在性与事件注册必须全体一致；显示属性可以本地化。

**硬规则**：

1. 帧的**创建、销毁、事件注册**必须在所有玩家机器上以相同顺序、相同条件执行。
2. 以下操作会**分配 handleId**，首次调用不得放在 `GetLocalPlayer()` 块内：`BlzCreateFrame*`、`BlzGetFrameByName`、`BlzGetOriginFrame`、`BlzFrameGetParent`、`BlzFrameGetChild`。做法：块外先"预热"调用一次（如 `BlzGetFrameByName("ConsoleUI", 0)`），块内再取就是安全的。
3. 本地安全的属性：position / size / visibility / texture / color / text / alpha / scale（只要不影响游戏模拟）。
4. 本地**不安全**（勿用于同步逻辑）：`BlzFrameGetText` `GetTextSizeLimit` `GetEnable` `GetAlpha` `GetValue` `GetHeight` `GetWidth` `GetParent` `IsVisible`。
5. 玩家输入状态（checkbox 勾选、editbox 文本、slider 值）天然本地；需要同步时在**事件回调里**取值存入共享变量（§6.4），或用 `BlzSendSyncData` 手动同步。
6. Alliance 系帧仅多人存在——在回放中引用会导致 handleId 错位 desync。

三种多人 UI 架构（按需选择）：
- **单帧 + 共享数据**：数据全员同步，显示时 `if GetLocalPlayer() == 触发玩家 then SetTexture(...)`。
- **单帧 + 本地数据 + 按需 Sync**：本地存状态，点击时 `BlzSendSyncData` 打包上行。
- **每玩家一帧**：以玩家 id 作 createContext 批量创建，仅本人可见（`BlzFrameSetVisible(f, GetLocalPlayer() == Player(i))`），GetLocalPlayer 只在创建时用一次。

---

## 10. TOC / FDF 参考

### 10.1 TOC

- TOC 是 FDF 的清单文件，每行一个 FDF 路径（与导入进地图的路径一致）。运行时 `BlzLoadTOCFile("war3mapImported\\xxx.toc") -> boolean`，可加载任意多个。
- **文件必须以空行结尾**：CRLF 至少 1 行空行，LF 至少 2 行；否则最后一个 FDF 被忽略（症状：模板创建失败）。
- FDF 内互相 Include 时，被包含者要在 TOC 中排在前面。
- 路径不区分大小写；FDF 内路径只用单个 `\`。

### 10.2 FDF 语法要点

```
// 行注释        /* 块注释 */
IncludeFile "UI\\FrameDef\\UI\\EscMenuTemplates.fdf",   -- 引入可继承模板（写在块外）

Frame "TYPE" "Name" { ... }                             -- MainFrame（可创建/可被继承）
Frame "TYPE" "Name" INHERITS "模板" { }                  -- 复制模板的 FDF 属性
Frame "TYPE" "Name" INHERITS WITHCHILDREN "模板" { }     -- 连子帧一起复制
String "..." { } / Texture "..." { }                    -- SimpleFrame 专用子帧定义
Layer "BACKGROUND"|"ARTWORK"|"ARTWORK_OVERLAY" { }      -- SimpleFrame 层序（BACKGROUND < ARTWORK；子帧 BACKGROUND 在父帧 ARTWORK 之上）
StringList { KEY "value", }                             -- 本地化字符串表（未闭合会崩溃）
```

- 只有 **MainFrame**（块外定义的）能被 `BlzCreateFrame` / `BlzCreateSimpleFrame` 创建或被继承；子帧随主帧创建。
- 同一 FDF 内 MainFrame 名必须唯一；重名时**剩余文件内容被跳过**（解析错误同理：出错帧保留已解析部分，其后全弃）。
- FDF 加载错误会写入 `Documents\Warcraft III\Logs\War3Log.txt`（格式 `Error (path:line): ...`，只报第一个错；TOC 缺空行时不报）。
- 常用动作：`Width/Height`、`SetPoint POINT, "FrameName", POINT, x, y,`（等价 BlzFrameSetPoint，目标固定 createContext 0；加 `UseActiveContext,` 改用当前创建上下文）、`SetAllPoints,`、`Anchor POINT, x, y,`（仅 Texture/String）、`Alpha 0-255,`、`FrameFont "字体", size, "",`、`Font "字体", size,`（String 用）、`FontColor r g b (a),`、`FontFlags "A|B",`、`BackdropBackground "路径",`、`BackdropEdgeFile / CornerFlags / CornerSize / BackgroundInsets`、`Text "初始文本",`、`ToolTip "FrameName",`、`DecorateFileNames,`（路径参数改用 StringList/war3skins.txt 变量名，如 `MasterFont`）、`LayerStyle "IGNORETRACKEVENTS",`（不挡鼠标）、`DoNotRegisterName,`、`ControlStyle "AUTOTRACK|HIGHLIGHTONMOUSEOVER|CLICKONMOUSEDOWN",`。
- `BlzFrameSetTexture` 会丢弃 BACKDROP 的 EdgeFile 边框设置（背景保留 insets/mirrored）。

### 10.3 官方模板包加载

创建 `war3mapImported\Templates.toc`（注意末尾空行）：

```
UI\FrameDef\Glue\standardtemplates.fdf
UI\FrameDef\UI\escmenutemplates.fdf
UI\FrameDef\Glue\battlenettemplates.fdf
```

`BlzLoadTOCFile("war3mapImported\\Templates.toc")` 后即可使用 `EscMenuButtonTemplate`、`EscMenuSliderTemplate`、`EscMenuTextAreaTemplate`、`EscMenuEditBoxTemplate`、`EscMenuCheckBoxTemplate`、`StandardButtonTemplate` 等。

---

## 11. 默认 Frame 名录（精选）

格式：`"名字"` + createContext。完整名录见教程附件（1.31/1.32.10 两版清单）。

| 组 | 名字 (createContext) |
|---|---|
| 控制台 | `ConsoleUI`(0)、`ConsoleUIBackdrop`(0)、`CommandBarFrame`(0)、`CommandButton_0..11`(0)、`InventoryButton_0..5`(0)、`InventoryCoverTexture`(0)、`SimpleInventoryBar/Cover`(0) |
| 资源栏 | `ResourceBarFrame`(0)、`ResourceBarGoldText` / `LumberText` / `SupplyText` / `UpkeepText`(0)。图标帧无名（用 Child API）；Upkeep 的 tooltip 监听是 child[2] |
| 顶栏 | `UpperButtonBarFrame`(0)、`UpperButtonBarQuestsButton` / `MenuButton` / `AlliesButton` / `ChatButton`(0) |
| 小地图 | `MiniMapFrame`(0)、`MinimapButtonBar`(0)、`MiniMapTerrainButton` / `MiniMapAllyButton` / `MiniMapCreepButton` / `MinimapSignalButton` / `FormationButton`(0) |
| 单位信息 | `SimpleInfoPanelUnitDetail`(0)、`SimpleNameValue`(0)、`SimpleClassValue`(0)、`SimpleHeroLevelBar`(0)、`SimpleProgressIndicator`(0)；图标区 `InfoPanelIconBackdrop/Label/Value/Level`(0..5)，其容器 `SimpleInfoPanelIconDamage`(0,1) / `Armor`(2) / `Rank`(3) / `Food`(4) / `Gold`(5)；英雄属性 `SimpleInfoPanelIconHero`(6) 及 `InfoPanelIconHero*`(6)；盟友资源 `SimpleInfoPanelIconAlly`(7) 及 `InfoPanelIconAlly*`(7)；建造 `SimpleInfoPanelBuildingDetail`(1)、运输 `(2)`、地面物品 `(3)`、可破坏物 `(4)` |
| 排行/多面板 | `Leaderboard`(0)+`Backdrop/Title/ListContainer`、`Multiboard`(0)+`MinimizeButton/TitleBackdrop/Title/Backdrop/ListContainer`、`TimerDialog`+`Backdrop/Value/Title`(0..x) |
| 任务 | `QuestDialog`(0) 全家（懒创建，见 §3.4）：`QuestDisplay`、`QuestTitleValue`、`QuestSubtitleValue`、`QuestAcceptButton`、`QuestListItem`(0..5) 等 |
| 聊天/日志 | `ChatDialog`(0) 全家（多人）、`LogDialog`(0) 全家（单机） |
| 菜单 | `EscMenuBackdrop`(0)、`EscMenuMainPanel`(0)、`InsideMainPanel`(0)、`PauseButton` / `SaveGameButton` / `LoadGameButton` / `OptionsButton` / `HelpButton` / `TipsButton` / `EndGameButton` / `ReturnButton`(0)、各 Options 子面板 |
| 过场 | `CinematicPanel`(0)、`CinematicDialogueText`(0)、`CinematicSpeakerText`(0) 等 |
| 结盟 | `AllianceDialog`(0)、`AllianceSlot`(0..23)、`GoldText` / `LumberText` / `PlayerNameLabel` / `ColorBackdrop` / `ColorBorder`(0..23) 等（仅多人） |

**常用默认 Frame 的锚点速查**（移动前是否需要 ClearAllPoints / 特殊前置）：

| Frame | 锚点 | 备注 |
|---|---|---|
| 命令卡/物品栏按钮 | TOPLEFT | 1.32+ 用按名版本移动；移动前先 ClearAllPoints 可修闪烁 |
| 英雄按钮 / 头像 / 小地图按钮 | TOPLEFT / BOTTOMLEFT / TOPLEFT | 需 `BlzHideOriginFrames(true)` 或 `BlzEnableUIAutoPosition(false)` |
| 资源文本 | TOPRIGHT（锚 ResourceBarFrame） | 改文本会被游戏刷新覆盖（本地玩家资源变动时） |
| UBERTOOLTIP | BOTTOMRIGHT | 向上扩展，建议用 BOTTOM 系锚点 |
| InfoPanelIconBackdrop | 逐个 TOPLEFT | 移图标区比移容器可靠（容器会被游戏重排） |
| 单位信息区 | SimpleNameValue TOP | `SimpleClassValue`/`HeroLevelBar`/`ProgressIndicator` 都锚它 |

---

## 12. 3.0.0 新增 UI 相关 API

来源：3.0.0 `common.j` 差异分析（静态比对，运行语义以实测为准）。

### 12.1 像素 ↔ Frame 坐标转换

```lua
BlzPixelToFrameX(pixelX) -> real      -- 像素 → Frame 坐标
BlzPixelToFrameY(pixelY) -> real
BlzFrameToPixelX(frameX) -> integer   -- Frame → 像素（取整规则未文档化）
BlzFrameToPixelY(frameY) -> integer
```

配合 `BlzGetLocalClientWidth/Height` 实现像素级布局，替代旧的手工换算。原点/客户区语义未明，落地前先实测打印校验。

### 12.2 键鼠状态主动查询（无 player 参数 → 读本地客户端，异步语义）

```lua
BlzIsKeyPressed(oskeytype) -> boolean          -- 某键当前是否按下
BlzIsMetaKeyPressed(integer metakey) -> boolean -- 修饰键；METAKEY_NONE=0 SHIFT=1 CTRL=2 ALT=4 WINKEYS=8
BlzIsMouseButtonPressed(mousebuttontype) -> boolean
BlzGetMouseScreenPosX() -> integer             -- 鼠标屏幕坐标（原点/轴向未文档化）
BlzGetMouseScreenPosY() -> integer
```

用于本地轮询（配合 §14.9 的 hover 检测、自定义快捷键等）。**不得用于同步判定**；要同步走 Frame 事件或 SyncData。

### 12.3 其他

```lua
BlzTextAreaFrameSetAutoScroll(frame, true)  -- TEXTAREA 自动滚动（追加文本后跟随到底部；触发规则未文档化）
```

### 12.4 类型层变化

- `framehandle` 由 `extends handle` 改为 `extends agent`（引用计数对象层级）。纯类型层变化，现有调用不受影响。
- 3.0.0 移除了 `RequestExtraIntegerData/BooleanData/StringData/RealData`（旧版调试接口，勿再引用）。

---

## 13. 崩溃与坑清单

写 UI 代码前后过一遍。**会导致崩溃/掉线**：

1. 对 String/Texture 帧调用：`BlzFrameSetVisible` `BlzFrameIsVisible` `BlzFrameSetAlpha` `BlzFrameSetLevel` `BlzFrameSetEnable` `BlzFrameSetScale` `BlzFrameSetParent` `BlzDestroyFrame`。
2. `BlzFrameSetFont` 用于 SimpleFrame（只允许 String）。
3. 同一 (frame, tooltip) 组合调用两次 `BlzFrameSetTooltip`（悬停时崩）；tooltip 无法解绑。
4. TEXTAREA 未设尺寸（或高度 < 0.03）即显示。
5. `BlzFrameGetChild` 越界索引（无检查）。
6. 祖先-后代循环 SetParent（无限循环）。
7. BACKDROP/TEXTAREA/DIALOG/CONTROL/SIMPLEMESSAGEFRAME 定义不当时创建。
8. 移动/缩放 `CHAT_MSG`/`UNIT_MSG`/`TOP_MSG` 传坏值（UNIT_MSG 高度 ≤ 0.25；TOP_MSG 只锚单点）。
9. 对空 handle（handleId 0）调 show/hide 等操作可能崩线程——`BlzGetFrameByName` 结果**必须判 `GetHandleId(f) == 0`**（Lua 中空帧不是 nil）。
10. 全屏帧刷新除以 `BlzGetLocalClientHeight()`（最小化时为 0）——先判 0。
11. StringList 未闭合。
12. 游戏内存档/读档后，之前创建的自定义 Frame 全部失效（隐藏且不可用），继续操作可能崩溃 → 必须用 FrameLoader 模式在 `EVENT_GAME_LOADED` 后重建（§14.13）；TOC 也不会被自动重载。
13. Alliance/Chat/Log 系帧的存在性因单机/多人/回放而异 → 条件引用导致 desync。

**行为坑（不崩但难查）**：

- 混族父子被静默替换成"替身父帧"，继承规则失效（用 GetParent 的 handleId 对比验证）。
- `BlzFrameSetParent`（非SimpleFrame）不摘除旧父列表（双父）。
- 隐藏父帧下给 SimpleFrame 换父 → 保持隐藏，直到新父 hide→show。
- SPRITE 换父会加速动画；HIGHLIGHT 换父会过度发光。
- FRAME 类型会抢占屏幕空间的鼠标事件（作纯容器时加 `LayerStyle "IGNORETRACKEVENTS"`）。
- 创建后立即 `BlzFrameSetScale` 可能破坏自定义字体——把 Scale 设置延后。
- String 帧过早创建（0s 定时器之前）可能错位/不显示，最早在 "0s expired" 事件创建。
- 改默认资源文本会被游戏周期性刷新覆盖。
- FDF 热键按钮（ControlShortcutKey）创建后需 hide→show 一次才生效；运行时代码加的按钮无法用该机制配热键。
- 1.32.6 bug：先经 `BlzFrameGetChild` 拿过的 origin frame，`BlzGetOriginFrame` 返回空帧——统一先走 `BlzGetOriginFrame`。

---

## 14. 常用配方 Recipes

以下均为可直贴 Lua（本项目中写在触发/初始化阶段，native 名不变）。

### 14.1 图片 BACKDROP

```lua
local f = BlzCreateFrameByType("BACKDROP", "MyIcon", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "", 0)
BlzFrameSetSize(f, 0.04, 0.04)
BlzFrameSetAbsPoint(f, FRAMEPOINT_CENTER, 0.4, 0.3)
BlzFrameSetTexture(f, "ReplaceableTextures\\CommandButtons\\BTNHeroBlademaster", 0, false)
-- 支持 BLP/TGA；DDS 仅 1.32+ 且 DXT1/DXT5 实测可用
```

### 14.2 文本

```lua
local t = BlzCreateFrameByType("TEXT", "MyText", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "", 0)
BlzFrameSetText(t, "Text on |cffffcc00Screen|r")   -- 支持 WC3 颜色码
BlzFrameSetAbsPoint(t, FRAMEPOINT_CENTER, 0.4, 0.3)
BlzFrameSetEnable(t, false)                         -- 不挡鼠标
BlzFrameSetScale(t, 2)                              -- TEXT 不能 SetFont，用 Scale 放大；offset 会被 scale 除，需要 offset/scale
```

### 14.3 文字按钮 + 点击

```lua
local b = BlzCreateFrameByType("GLUETEXTBUTTON", "MyButton", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "ScriptDialogButton", 0)
BlzFrameSetAbsPoint(b, FRAMEPOINT_CENTER, 0.4, 0.3)
BlzFrameSetText(b, "My Button Text")
local t = CreateTrigger()
BlzTriggerRegisterFrameEvent(t, b, FRAMEEVENT_CONTROL_CLICK)
TriggerAddAction(t, function()
    print(BlzFrameGetName(BlzGetTriggerFrame()), "clicked")
    BlzFrameSetEnable(b, false); BlzFrameSetEnable(b, true)  -- 归还键盘焦点
end)
```

### 14.4 图标按钮（按下缩小效果，≥1.32.6）

```lua
local b = BlzCreateFrameByType("GLUETEXTBUTTON", "MyIconButton", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "ScriptDialogButton", 0)
BlzFrameSetAbsPoint(b, FRAMEPOINT_CENTER, 0.1, 0.3)
BlzFrameSetSize(b, 0.049, 0.049)
local normal = BlzFrameGetChild(b, 0)   -- 默认态 BACKDROP
local pushed = BlzFrameGetChild(b, 1)   -- 按下态 BACKDROP
BlzFrameSetTexture(normal, BlzGetAbilityIcon(FourCC("Hpal")), 0, false)
BlzFrameSetTexture(pushed, BlzGetAbilityIcon(FourCC("Hpal")), 0, false)
BlzFrameClearAllPoints(pushed)
BlzFrameSetPoint(pushed, FRAMEPOINT_BOTTOMLEFT, b, FRAMEPOINT_BOTTOMLEFT, 0.005, 0.005)
BlzFrameSetPoint(pushed, FRAMEPOINT_TOPRIGHT,   b, FRAMEPOINT_TOPRIGHT,  -0.005, -0.005)
```

### 14.5 进度条（SIMPLESTATUSBAR，免 FDF）

```lua
local bar = BlzCreateFrameByType("SIMPLESTATUSBAR", "", BlzGetFrameByName("ConsoleUI", 0), "", 0)
BlzFrameClearAllPoints(bar)
BlzFrameSetPoint(bar, FRAMEPOINT_CENTER, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), FRAMEPOINT_CENTER, 0, 0)
BlzFrameSetSize(bar, 0.1, 0.012)
BlzFrameSetTexture(bar, "ReplaceableTextures\\TeamColor\\TeamColor00", 0, false)  -- 纯色用 teamcolor 系
BlzFrameSetValue(bar, 40)   -- 默认 0..100，可用 SetMinMaxValue 改
-- 配背景：BACKDROP 挂到 ConsoleUIBackdrop / WORLD_FRAME 之下层，或双锚点贴在 bar 后
```

双层条（前景 value% 从左、背景补右）：两个 SIMPLESTATUSBAR 同位叠放，背景 SetValue(100)。

### 14.6 滑条

```lua
local s = BlzCreateFrameByType("SLIDER", "MySlider", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "QuestMainListScrollBar", 0)
BlzFrameClearAllPoints(s)
BlzFrameSetAbsPoint(s, FRAMEPOINT_TOPLEFT, 0.40, 0.30)
BlzFrameSetSize(s, 0.012, 0.06)
BlzFrameSetMinMaxValue(s, 0, 1000)
BlzFrameSetStepSize(s, 1)
local t = CreateTrigger()
BlzTriggerRegisterFrameEvent(t, s, FRAMEEVENT_SLIDER_VALUE_CHANGED)
TriggerAddAction(t, function() print(BlzGetTriggerFrameValue()) end)
-- 滚轮支持：另注册 FRAMEEVENT_MOUSE_WHEEL，事件内 GetLocalPlayer()==GetTriggerPlayer() 时 ±step
```

### 14.7 复选框

```lua
local c = BlzCreateFrame("QuestCheckBox2", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, 0)
BlzFrameSetAbsPoint(c, FRAMEPOINT_CENTER, 0.4, 0.3)
local t = CreateTrigger()
BlzTriggerRegisterFrameEvent(t, c, FRAMEEVENT_CHECKBOX_CHECKED)
BlzTriggerRegisterFrameEvent(t, c, FRAMEEVENT_CHECKBOX_UNCHECKED)
TriggerAddAction(t, function()
    print(BlzGetTriggerFrameEvent() == FRAMEEVENT_CHECKBOX_CHECKED and "on" or "off")
end)
```

### 14.8 TEXTAREA（滚动文本区）

```lua
BlzLoadTOCFile("war3mapImported\\Templates.toc")
local a = BlzCreateFrameByType("TEXTAREA", "MyLog", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "EscMenuTextAreaTemplate", 0)
BlzFrameSetAbsPoint(a, FRAMEPOINT_TOPLEFT, 0.1, 0.5)
BlzFrameSetSize(a, 0.25, 0.25)          -- 高度 < 0.03 或为 0 会崩溃
for i = 1, 100 do BlzFrameAddText(a, i .. ": line") end   -- AddText 自动加换行
-- 3.0.0：BlzTextAreaFrameSetAutoScroll(a, true) 可自动跟随到底部
-- 不挡鼠标：BlzFrameSetEnable(a, false)（同时禁用滚轮，滚动需指向滚动条）
```

### 14.9 悬停检测（含默认命令卡按钮）

给目标按钮挂一个空 SIMPLEFRAME tooltip，轮询 tooltip 可见性（异步、无网络开销）：

```lua
local tooltips = {}
for i = 0, 11 do
    local btn = BlzGetOriginFrame(ORIGIN_FRAME_COMMAND_BUTTON, i)
    local tip = BlzCreateFrameByType("SIMPLEFRAME", "", btn, "", 0)
    BlzFrameSetTooltip(btn, tip)
    BlzFrameSetVisible(tip, false)
    tooltips[i] = tip
end
local hovered
TimerStart(CreateTimer(), 1/32, true, function()
    for i = 0, 11 do
        if BlzFrameIsVisible(tooltips[i]) and hovered ~= i then
            hovered = i
            -- async：仅本地感知，勿直接做同步逻辑
        end
    end
end)
```

### 14.10 隐藏默认 UI（整屏方案）

```lua
BlzHideOriginFrames(true)   -- 不含：命令按钮、聊天、消息、TimerDialog、Multiboard、Leaderboard

-- 底部黑框：不要隐藏（挡点击有用），压扁即可
BlzFrameSetSize(BlzGetFrameByName("ConsoleUIBackdrop", 0), 0, 0.0001)
-- 命令栏鼠标死区（ConsoleUI child 5）
BlzFrameSetVisible(BlzFrameGetChild(BlzGetFrameByName("ConsoleUI", 0), 5), false)
-- 世界全屏（1.31 需要）
BlzFrameSetAllPoints(BlzGetOriginFrame(ORIGIN_FRAME_WORLD_FRAME, 0), BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0))
-- 挽回要保留的：改父到隐藏容器或直接 SetVisible(true)
BlzFrameSetVisible(BlzGetFrameByName("ResourceBarFrame", 0), true)      -- 资源栏
BlzFrameSetVisible(BlzGetFrameByName("UpperButtonBarFrame", 0), true)   -- 顶栏
BlzFrameSetVisible(BlzFrameGetParent(BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON, 0)), true) -- 英雄栏
```

Buff 条等会被选择事件复活的帧：建隐藏 SIMPLEFRAME 容器 + SetParent 挪进去。移动 origin frame 前先 `BlzEnableUIAutoPosition(false)`。

### 14.11 帧族探测

```lua
-- 返回 0=Frame族 1=SimpleFrame族 2=String/Texture nil=无效
function WhatTypeOfFrame(frame)
    if not string.find(tostring(frame), "framehandle:") then return nil end
    if GetHandleId(frame) == 0 then return nil end
    if GetHandleId(BlzGetFrameByName("WTOF_TestF", 0)) == 0 then
        BlzCreateFrameByType("FRAME", "WTOF_TestF", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "", 0)
        BlzCreateFrameByType("SIMPLEFRAME", "WTOF_TestS", BlzGetFrameByName("ConsoleUI", 0), "", 0)
    end
    BlzFrameSetParent(BlzGetFrameByName("WTOF_TestF", 0), frame)
    if GetHandleId(BlzFrameGetParent(BlzGetFrameByName("WTOF_TestF", 0))) == GetHandleId(frame) then
        BlzFrameSetParent(BlzGetFrameByName("WTOF_TestF", 0), BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0))
        return 0
    end
    BlzFrameSetParent(BlzGetFrameByName("WTOF_TestS", 0), frame)
    if GetHandleId(BlzFrameGetParent(BlzGetFrameByName("WTOF_TestS", 0))) == GetHandleId(frame) then
        BlzFrameSetParent(BlzGetFrameByName("WTOF_TestS", 0), BlzGetFrameByName("ConsoleUI", 0))
        return 1
    end
    return 2
end
```

### 14.12 越出 4:3 的全屏参照帧

```lua
local function GetWideParent()
    local p = BlzGetFrameByName("ConsoleUIBackdrop", 0)      -- 代价：层在 SimpleFrame 之下
    if GetHandleId(p) ~= 0 then return p end
    p = BlzGetFrameByName("Multiboard", 0)                   -- 或 Leaderboard（需先创建）
    if GetHandleId(p) ~= 0 then return p end
    CreateLeaderboardBJ(bj_FORCE_ALL_PLAYERS, "")
    p = BlzGetFrameByName("Leaderboard", 0)
    BlzFrameSetSize(p, 0, 0)
    BlzFrameSetVisible(BlzGetFrameByName("LeaderboardBackdrop", 0), false)
    BlzFrameSetVisible(BlzGetFrameByName("LeaderboardTitle", 0), false)
    return p
end
-- 参照帧：定时按分辨率刷尺寸（最小化时 height==0，必须跳过）
TimerStart(CreateTimer(), 0.5, true, function()
    local h = BlzGetLocalClientHeight()
    if h > 0 then BlzFrameSetSize(ref, BlzGetLocalClientWidth() / h * 0.6, 0.6) end
end)
-- 3.0.0 起像素换算可直接用 BlzPixelToFrameX/Y（§12）
```

### 14.13 存档/读档后重建（FrameLoader）

```lua
-- 自定义 Frame 在游戏读档后全部失效（1.31 起存在），必须重建
FrameLoader = {}
function FrameLoaderAdd(func) table.insert(FrameLoader, func) end
local flTrig, flTimer
flTrig = CreateTrigger()
TriggerRegisterGameEvent(flTrig, EVENT_GAME_LOADED)
TriggerAddAction(flTrig, function()
    flTimer = flTimer or CreateTimer()
    TimerStart(flTimer, 0, false, function()
        for _, v in ipairs(FrameLoader) do v() end
    end)
end)
-- 用法：把帧创建封装成 Init()，启动时调用一次并 FrameLoaderAdd(Init)
```

### 14.14 修改资源文本（示例：改木头显示）

```lua
local f = BlzGetFrameByName("ResourceBarLumberText", 0)
BlzFrameSetText(f, "Lumber")
-- 注意：本地玩家资源变动时游戏会刷新覆盖；同类：ResourceBarGoldText / SupplyText / UpkeepText
```

---

## 附录：信息来源

- Tasyen, *The Big UI-Frame Tutorial*, Hive Workshop（含 1.31/1.32.10 默认 Frame 全名录、GAME_UI 子树 dump）。
- 3.0.0 `common.j` 与旧版差异静态分析（本项目 `C:\Users\yatyr\Downloads\3.0新增函数对比.md`，137 新增 native 中 UI/键鼠/坐标 10 项已并入 §12）。
- 引擎行为标注为"未文档化/需实测"的条目，落地前请在测试图验证。
