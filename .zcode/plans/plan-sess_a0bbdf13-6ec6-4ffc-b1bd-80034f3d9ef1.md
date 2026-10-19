# 实现 Component.enabled（Unity Behaviour 语义）+ FrameImage 可见性对齐 + 全量生命周期日志测试

## 一、语义设计

- 组件**有效状态** = `enabled && gameObject.activeInHierarchy`；翻转触发 `OnEnable()` / `OnDisable()`，去重（已生效不再 OnEnable，已失效不再 OnDisable）。
- `Update`/`LateUpdate` 只跑 enabled 组件；`Start` 只在 enabled 时消费 `_started`（禁用推迟到启用后首帧前）——这是 FrameImage 可见性对齐 enabled 的前提（禁用期间 LateUpdate 不跑，不会覆盖 OnDisable 的隐藏）。
- Awake 全生命周期一次，首次生效时触发（v1：disabled-at-add 的 Awake 推迟到首次启用；现有组件默认 enabled=true，行为不变）。

## 二、代码修改

1. **`Component.cs`**：`private bool _enabled = true` + `internal bool _on`（有效态标记）；`public bool enabled` 属性（setter 去重后收敛）；`internal void UpdateOnState()` 供 setter 与 GameObject 分支迁移共用：`should = _enabled && activeInHierarchy`，与 `_on` 不一致时——变真：补 Awake（未 awake 过）→ `_on=true` → `OnEnable()`；变假：`_on=false` → `OnDisable()`。
2. **`GameObject.cs`**：`ActivateBranch`/`DeactivateBranch` 组件循环体改为 `UpdateOnState()`（失活子树仍整棵跳过）；`AddComponent` 改 `if (activeInHierarchy) comp.UpdateOnState();`；`StartPendingComponents` 条件加 `&& comp.enabled`；`Update`/`LateUpdate` 循环加 `if (!comp.enabled) continue;`。
3. **`FrameImage.cs`**：**删除 `visible` 属性与字段**；注释注明可见性 = enabled（有效状态）∧ activeInHierarchy ∧ texture != null；`LateUpdate` 在 texture 非空时 `SetTexture` + `BlzFrameSetVisible(native, true)`（能执行到即生效中），null 时隐藏；`OnDisable` 同步隐藏钩子不变。
4. **`Program.cs`**：视觉场景保留（含末尾 `iconImg.enabled` 切换），**新增 `EnableLogTest()` 临时打印测试**（见下）。

## 三、日志测试（关键基础设施验证核心）

新增 `EnableProbe : Component`：七个回调全打日志——`Awake/OnEnable/OnDisable/Start/OnDestroy` 直接 `BJDebugMsg`；`Update/LateUpdate` 各带每实例计数器、只打印前 2 次（防刷屏），格式如 `probe2: Update#1`。`EnableLogTest()` 按 5 个阶段脚本化推进，每步前打 `[E?]` 标记与预期注释：

- **A. enabled 去重（同步）**：active GO 上 AddComponent → 期望 `Awake, OnEnable`；`enabled=false` → `OnDisable`；再置 false → 无输出；置 true → `OnEnable`；再置 true → 无输出。
- **B. enabled × SetActive 组合（同步）**：`SetActive(false)` → `OnDisable`；再 false → 无；`SetActive(true)` → `OnEnable`；`enabled=false` → `OnDisable`；此后 `SetActive(false)` → 无（已失效）、`SetActive(true)` → 无（仍禁用）、`enabled=true` → `OnEnable`（激活链已通）。
- **C. Start/Update 门控（异步，Task.Delay 推帧）**：新建 GO2+probe2 随手 `enabled=false` → `Awake, OnEnable, OnDisable`；等 3 帧无 `Start/Update`；`enabled=true` → `OnEnable`，等 3 帧 → `Start, Update#1, Update#2`；`enabled=false` → `OnDisable`，等 2 帧 → 无 Update。
- **D. 子分支传播（同步）**：parent+child+probe：`parent.SetActive(false)` → 子 probe `OnDisable`；true → `OnEnable`；`child probe.enabled=false` → `OnDisable`；parent false → 无（子已失效）；parent true → 无（子禁用）；`enabled=true` → `OnEnable`。
- **E. 销毁路径（异步）**：对 probe2 所在 GO `Destroy()`（销毁时处于 enabled）→ 下帧 Flush 阶段期望 `OnDisable, OnDestroy`。

每阶段打印的完整期望序列写在代码注释块里，进图后逐行核对屏幕输出。

## 四、验证

- `dotnet build` 通过（无新警告）；
- 进图核对 `EnableLogTest` 五阶段日志与期望序列逐条一致（状态机全分支覆盖：去重、组合、门控、分支传播、销毁）；
- 目测 UI 场景前三段（root/bar SetActive）+ 末段 `iconImg.enabled` 切换显隐；
- 无新 `sf-error-N.pld`。

## 五、文档/记忆同步

`docs/plans/ui-framecomponent-plan.md` FrameImage 行改为"可见性由 enabled × active 决定，不暴露 visible"；记忆 zam-transpiler-gotchas 补 Component.enabled 实现条目。