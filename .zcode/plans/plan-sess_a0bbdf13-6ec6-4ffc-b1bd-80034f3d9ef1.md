# 实现 UI Components 框架：FrameComponent（布局）+ FrameImage（图片填充）

计划全文见 `docs/plans/ui-framecomponent-plan.md`（已批准存档）。本轮修正一项保守假设：**SharpForge 转译器已验证支持 struct `==`/`!=`**（`IRLowering.cs:5307` `HasUserDefinedEquality` 用用户定义的 `op_Equality`；`5064-5072` 同名 lowering `op_Inequality`），Vector2 按正规 uGUI API 补齐相等运算符。

## 文件清单

1. **`csproj/src/Utils/Vector2.cs`**（新建）— struct：x/y 字段、构造、`zero/one/up/down/left/right`、`+ −(双目/单目) * ×2 /` 运算符、`ToString`；**`==`/`!=`（精确字段比较）+ `Equals`/`GetHashCode`**（C# 配对要求，顺带消除 CS0660/0661 警告）。
2. **`csproj/src/Components/FrameComponent.cs`**（填充空桩）— 布局组件，native 载体 `BlzCreateFrameByType("FRAME", …)`：
   - **存储模型**（uGUI RectTransform 同构）：`anchorMin/anchorMax/anchoredPosition/sizeDelta/pivot`（Vector2）+ `scale`(float) + `visible` + `raycastTarget`(默认 false) + `frameName`（未设置自动 `SFUI_Frame_N`）。默认 anchor(0.5,0.5)、pivot(0.5,0.5)、sizeDelta(0.1,0.1)。
   - **派生属性**（统一用 `sd = sizeDelta × scale`）：`left = anchoredPosition.x − pivot.x·sd`、`right = −(anchoredPosition.x + (1−pivot.x)·sd)`、`bottom/top` 同理；`width/height` ↔ `sizeDelta`。
   - **scale 烘焙**：只乘进 size（sd），不调 `BlzFrameSetScale`，规避偏移被 scale 除的引擎陷阱；`anchoredPosition`/offsets 为原生单位不参与 scale（v1 简化，注释注明与 Unity 差异）。子帧 parentSize 取父的 `appliedSize = (anchorMax−anchorMin)×parentSize + sd`。
   - **dirty/apply**：setter 调 `SetDirty()`；`LateUpdate()` → `ApplyWithAncestors()`（先递归确保祖先 FrameComponent 已应用，覆盖"父组件晚于子添加"的顺序边角）→ `ApplyNow()`（干净则返回）。应用逻辑：
     - **点锚判定 `anchorMin == anchorMax`**（本轮改用 Vector2 运算符）：`BlzFrameSetSize(sd)` + `SetPoint(CENTER, parentNative, CENTER, (anchorMin−0.5)×parentSize + anchoredPosition + (0.5−pivot)×sd)`；
     - 拉伸（不等）：`SetPoint(BOTTOMLEFT, parentNative, CENTER, BL−parentCenter)` + `SetPoint(TOPRIGHT, …, TR−parentCenter)`，`BL = anchorMin×parentSize + anchoredPosition − pivot×sd`，`TR = anchorMax×parentSize + anchoredPosition + (1−pivot)×sd`；不调 SetSize；
     - root 帧（祖先无 FrameComponent）：parentNative = `BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)`，parentSize = (0.8, 0.6)；
     - appliedSize 变化时沿 transform 子树把后代 FrameComponent 标脏。
   - **active 联动（本轮重点）**：`OnEnable()` → `SetDirty()`（激活后下帧 apply 恢复显示）；`OnDisable()` → **同步** `BlzFrameSetVisible(native, false)`（失活后 LateUpdate 不再执行）；apply 只写 `visible`，分支激活态完全由钩子门控。native 创建只在 LateUpdate（激活态才跑），与延迟 Awake 时序天然兼容。
   - **销毁**：`OnDestroy()` 先逐个 `FrameImage.DestroyNative()`（经 `RegisterImage` 登记，任意添加顺序安全），再 `BlzDestroyFrame(native)`；全部判空。
   - `raycastTarget` 置 `_enableDirty`，apply 时 `BlzFrameSetEnable`（FRAME 默认挡鼠标，容器默认 false）。
3. **`csproj/src/Components/FrameImage.cs`**（新建）— 图片填充，native 为 `BlzCreateFrameByType("BACKDROP", …, frameComp.nativeFrame, "", 0)` + `BlzFrameSetAllPoints`（自动跟随父 rect）：
   - `texture`（string?，空 = 隐藏）、`visible`；`Start()` 里 `GetComponent<FrameComponent>()` 并 `RegisterImage`；`LateUpdate()` 中 frame 未建时保持脏下帧重试；同样的 `OnEnable → SetDirty` / `OnDisable → 同步隐藏`；`DestroyNative()` 幂等。
4. **`csproj/src/Utils/Const.cs`** — 加 `public static GameObject UiRoot = null!;`。
5. **`csproj/src/Program.cs`** — `Start()` 中 `Const.UiRoot = new GameObject("UI")`；移除 ActiveProbe 临时验证，替换为 UI 验证场景 `UiTest()`：
   - 居中面板 0.3×0.2 + FrameImage（TeamColor08 灰）；
   - 顶部横条：anchorMin=(0,1)/anchorMax=(1,1)/pivot=(0.5,1)/sizeDelta=(0,0.04)（拉伸轴验证）+ TeamColor00 红图；
   - 右上角图标：anchor=point(1,1)/pivot=(1,1)/anchoredPosition=(−0.005,−0.005)/sizeDelta=(0.049,0.049)（pivot 公式验证，错则悬出角外）+ BTNHeroPaladin；
   - **开关切换**：`async void` + `Task.Delay`（同 RunGameObjects 模式）：2s 后 `root.SetActive(false)` →1s→ `SetActive(true)` →1s→ 仅横条 `SetActive(false)` →1s→ 恢复。

## 关键约束

全程无 `GetLocalPlayer()`（多人同步安全）；不用 `?.` 运算符（转译兼容）；native 调用全部延后到 apply 阶段。

## 验证

- `dotnet build` 通过；更新 `docs/plans/ui-framecomponent-plan.md` 状态为已实现；
- 重新生成 war3map.lua 进图：目测三块元素位置正确，随后自动播放开关切换序列（整组消失/重现 → 仅横条消失/重现）；期间无新 sf-error-N.pld。