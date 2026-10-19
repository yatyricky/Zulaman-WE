# UI Components 框架实现计划（已实现于 2026-10-19，含 Vector2 ==/!= 支持）

> 状态：**已实现**。FrameComponent / FrameImage / Vector2 / Const.UiRoot / Program 验证场景均已落地，验证场景含 GameObject.SetActive 开关切换演示。
> 前置：GameObject.active 已实现（GameObject._activeSelf / activeSelf / activeInHierarchy / SetActive，分支迁移钩子 ActivateBranch/DeactivateBranch，SetParent 重挂迁移）。
> 另：Component 基类新增了 `transform` 便捷属性（Unity 对齐）。

## 目标

参照 uGUI RectTransform 语义，把 GameObject 节点树上的 `FrameComponent` 层级映射到 war3 native frame 层级：

```
GameObject 树                    FrameComponent 树              war3 native frames
GameObject("UI")          →      FrameComponent (root)      →   BlzGetOriginFrame(GAME_UI) 为父
 └ GameObject("Panel")    →       └ FrameComponent          →    └ FRAME (BlzCreateFrameByType)
     └ GameObject("Icon") →           └ FrameComponent      →        └ FRAME
                                 └ FrameImage            →            └ BACKDROP (SetAllPoints)
```

先实现 frame（布局），然后实现 frame 的图片填充（FrameImage）。

## 选型依据（docs/war3-ui-frame-guide.md）

- **Frame 族**（FRAME/BACKDROP，`BlzCreateFrameByType` 直建，免 FDF/TOC）：后续按钮/文本/事件都在这一族；SimpleFrame 仅留作未来越出 4:3 的逃生门。
- 定位全部通过 `BlzFrameSetPoint(frame, point, parentNative, FRAMEPOINT_CENTER, dx, dy)` 实现（dx/dy 为相对父帧中心的偏移），单锚点/拉伸锚点统一公式，无需绝对坐标。
- **不用 `BlzFrameSetScale`**：scale 直接烘进 size（`applied = sizeDelta * scale`），规避 guide §2.2/§13 的"偏移量被 scale 除"陷阱；子帧布局使用父帧 applied size，行为与 Unity 层级缩放一致。
- **rotation 不实现**：war3 frame 无旋转能力，API 不提供该属性（避免死 API），在类注释中说明。
- 坐标单位为 war3 frame 单位（全屏 = 0.8×0.6），类注释写明；像素换算留待后续用 `BlzPixelToFrameX/Y`（3.0.0）。

## uGUI 属性映射

内部存储完全照搬 uGUI RectTransform 模型：`anchorMin` / `anchorMax` / `anchoredPosition` / `sizeDelta` / `pivot`（Vector2）。派生属性带 setter（改写底层字段 + SetDirty）：

| API | 底层字段 | 说明 |
|---|---|---|
| `left` / `bottom` | offsetMin = (left, bottom) | 点锚时由 anchoredPosition−pivot×size 派生；拉伸时直接生效 |
| `right` / `top` | offsetMax = (−right, −top) | 同上 |
| `width` / `height` | sizeDelta | 点锚 = 实际尺寸；拉伸 = 尺寸修正量（与 Unity 同规则） |
| `anchorMin` / `anchorMax` | 直接存储 | 相对父矩形的 0..1 分数；相等 = 点锚，不等 = 拉伸 |
| `pivot` | 直接存储 | 0..1 |
| `anchoredPosition` | 直接存储 | pivot 相对锚点的位置 |
| `visible` | 直接存储 | 见下方"active 依赖约束" |
| `raycastTarget` | 默认 false | 应用为 BlzFrameSetEnable；FRAME 默认挡鼠标，容器必须默认 false |

应用算法（LateUpdate 中，父先子后）：
- 点锚（anchorMin==anchorMax）：`SetSize(w,h)` 后 `SetPoint(CENTER, parent, CENTER, dx, dy)`，其中 `dx = (anchorMin.x−0.5)×parentW + anchoredPosition.x + (0.5−pivot.x)×w`，y 同理。
- 拉伸（任一轴不等）：`SetPoint(BOTTOMLEFT, parent, CENTER, …)` + `SetPoint(TOPRIGHT, parent, CENTER, …)`，BL 偏移 = `(anchorMin−0.5)×parentSize + (left,bottom)`，TR 偏移 = `(anchorMax−0.5)×parentSize − (right,top)`；不调 SetSize（双锚点定尺寸）。
- root 帧（祖先无 FrameComponent）：父 native = `BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)`，parentSize = (0.8, 0.6)。

## 文件清单

1. **`csproj/src/Utils/Vector2.cs`**（新建）— struct，仿 Vector3：x/y 字段、构造、`zero`/`one`、`+`/`−`/`*`/`/` 运算符。全局命名空间。
2. **`csproj/src/Components/FrameComponent.cs`**（填充现有空桩）— 布局组件：
   - 上述 uGUI 属性 + `visible` + `raycastTarget` + `name`（native frame 名）；
   - `LateUpdate()`：`_dirty` 时 `EnsureFrame()`（递归保证父帧已建）+ 应用定位/尺寸/可见性；
   - parent 解析：沿 `transform.parent` 向上找最近祖先 GO 的 FrameComponent（约定每 GO 至多一个，文档注明）；
   - 尺寸变化时沿 transform 树把后代 FrameComponent 全部标脏（拉伸子帧依赖父尺寸）；
   - `OnDestroy()`：先销毁登记的 FrameImage 的 BACKDROP，再 `BlzDestroyFrame(native)`（规避孤儿帧销毁顺序问题）；
   - 所有属性 setter 调 `SetDirty()`。
3. **`csproj/src/Components/FrameImage.cs`**（新建）— 图片填充：
   - `texture` 属性（string 路径，空 = 隐藏）；
   - Start 时 `GetComponent<FrameComponent>()`，`BlzCreateFrameByType("BACKDROP", …, frameComp.nativeFrame, "", 0)` + `BlzFrameSetAllPoints`（自动跟随父 rect，guide §2.2）；
   - LateUpdate 应用 `BlzFrameSetTexture(tex, 0, false)` 与可见性；向所属 FrameComponent 登记，销毁由 FrameComponent 统一处理。
4. **`csproj/src/Utils/Const.cs`** — 增加 `public static GameObject UiRoot = null!;`（镜像 UnitsRoot 模式）。
5. **`csproj/src/Program.cs`** — `Start()` 中创建 `Const.UiRoot = new GameObject("UI")`；`Test()` 里搭验证场景：
   - 居中面板：root FrameComponent，anchorMin=anchorMax=(0.5,0.5)，sizeDelta=(0.3,0.2)，挂 FrameImage 贴一张官方贴图（如 `ReplaceableTextures\CommandButtons\BTNHeroPaladin`）；
   - 底部横条子节点：anchorMin=(0,0)、anchorMax=(1,0)、height=0.05 的拉伸锚点，验证双锚点路径；
   - 一个 pivot≠0.5 的子帧，验证 pivot 偏移公式。

## GameObject.active 依赖约束（本次新增，实现时必须遵守）

- **有效可见性 = `visible && gameObject.activeInHierarchy`**：父 GO 隐藏时整棵子树的 native frame 都要隐藏。
- **隐藏必须走 OnDisable 钩子同步推送**：GameObject 失活后其组件的 LateUpdate 不再执行（active 守卫），不能依赖下一帧 apply 来隐藏——`FrameComponent.OnDisable()` 里直接 `BlzFrameSetVisible(native, false)`；`OnEnable()` 里 `SetDirty()` 让下帧 apply 恢复。FrameImage 同理（或仅跟随父 native frame 的层级门控，实现时取更简单者）。
- 挂在失活 GO 上的 FrameComponent：Awake 已推迟到激活时（GameObject.active 机制），native frame 创建在 apply 阶段（LateUpdate），天然只在激活后发生，无冲突。
- SetParent 重挂迁移已实现（Transform.SetParent 触发分支迁移），FrameComponent 随分支重挂自动显隐。
- 组件级 enable（comp.enabled）明确不做，`raycastTarget` 只映射 BlzFrameSetEnable。

## 关键约束（多人/时序）

- 创建/销毁/事件注册不含任何 `GetLocalPlayer()` → 多人同步安全（guide §9）；
- native 调用全部延后到帧循环的 apply 阶段，避开加载期创建时序坑；
- Frame 族 4:3 限制：布局值应在 0..0.8 / 0..0.6 内，越界畸形是引擎行为；
- 每帧仅 dirty 帧才调 native，无逐帧全量重排。

## 验证

1. `dotnet build` 通过；
2. 重新跑 sf-builder 生成 war3map.lua 后进图，目测三块验证元素（居中带图面板、底部拉伸条、pivot 偏移子帧）位置正确；
3. 另测：对根节点 SetActive(false) → 面板消失；SetActive(true) → 恢复。

## 明确不做（后续迭代）

rotation（引擎不支持）、文本组件、事件（CLICK/ENTER 等转发到 C# 回调）、FrameLevel 排序 API、像素辅助换算、存档/读档 FrameLoader 重建（guide §14.13，暂无读档需求，仅记录）。
