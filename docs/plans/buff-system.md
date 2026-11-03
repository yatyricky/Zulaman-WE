# Buff 系统

## 实体结构

```text
Const.SystemRoot
 ├─ BuffSystem
 └─ UnitSystem

Const.UnitsRoot
 └─ Unit GameObject
     ├─ UnitEntity       // 唯一 owner 来源
     ├─ StatsComponent
     └─ BuffHolder
```

- `UnitEntity` 是单位 handle 的唯一 owner 来源；`StatsComponent.owner`/`BuffHolder.owner` 都从它派生。
- `UnitSystem` 内部维护 `Dictionary<unit, GameObject>`，是单位反查的唯一入口；`UnitsRoot` 仍负责 GameObject 父子层级。
- `UnitSystem` 是唯一创建/销毁单位 GameObject 的系统。
- 组件不再互相 Register/Unregister，也不遍历 `UnitsRoot` 查找单位。
- `BuffHolder` 不持有 `StatsComponent`。

## 初始化

`Program.Start`：

```csharp
Const.SystemRoot = new GameObject("Systems");
Const.UnitsRoot = new GameObject("Units");
Const.UiRoot = new GameObject("UI");

Const.buffSys = Const.SystemRoot.AddComponent<BuffSystem>();
Const.unitSys = Const.SystemRoot.AddComponent<UnitSystem>();
```

- `BuffSystem` 先添加：`UnitRemovedEvent` 中先做 caster 清理。
- `UnitSystem` 后添加：构建属性依赖图、订阅 CreateUnit/UnitRemoved、扫描预置单位。
- 不再有 `StatsComponent.Init`、`StatsComponent.EnsureInitialized`。
- `BuffSystem`/`UnitSystem` 内部用 static bool 保证只初始化一次，不再使用 static `Instance`。

## 单位生命周期

- `UnitSystem` 收到 `CreateUnitEvent` 后：
  - 跳过 dummy、无效 handle、无 `UnitConfig` 单位；
  - `UnitRemovedEvent.Cancel(u)` 处理 handle 复用；
  - 旧实体存在且 pending：从字典移除并 `old.Destroy()`；非 pending 的重复 live handle 直接 throw；
  - 创建 GameObject，依次挂 `UnitEntity`（Bind owner）、`StatsComponent`、`BuffHolder`；
  - 在 `UnitEntity.Bind` 后、`StatsComponent` 前写字典，保证 Stats 初始化事件可反查单位；
  - `StatsComponent.Awake` 直接初始化基础属性，不再调用 `EnsureInitialized`。
- `UnitSystem` 收到 `UnitRemovedEvent` 后：从字典移除并销毁 GameObject。
- `BuffHolder.OnDestroy` 清理 buff；Stats 随 GameObject 销毁。
- `UnitSystem.GetUnit` 只查字典；`SnapshotUnits` 供 BuffSystem 枚举。
- dummy、区域外/未配置单位不会自动补建；Buff 层直接抛异常，暴露创建/注册链问题。

## Buff 调度

- `BuffSystem` 是普通实例组件，通过 `Const.buffSys` 调用：
  `Apply / Remove / Transfer / Dispel / Clear / Find / FindHolder / FindHolderOrNull / RegisterFactory`。
- `BuffSystem.Update` 遍历 `Const.unitSys.SnapshotUnits()`，取 `BuffHolder` 并 `Tick(now, Frame)`。
- 不维护 holders/byUnit 的静态注册表；`_factories` 为实例字段。
- `BuffHolder.Tick(now, frame)` 直接调用 `Buff.Tick(now, frame)`；`LastTickFrame` 由 BuffSystem 在 Attach/Transfer 成功后通过 `MarkTickFrame` 设置。
- `BuffSystem` 内部 static bool `_initialized` 防止第二个实例初始化。
- `Buff.Owner => Holder.owner`，不再保存独立 Owner 字段。
- `Buff.Caster` 是 `unit?`。

## 属性

- `BuffConfigEntry.StatModsPerStack` 按层数缩放。
- `Buff.SyncStats` 只对“新旧值之差”调用一次 `StatsComponent.ModStats`，避免叠层减少时先降低最大生命、夹低当前 HP、再恢复最大生命造成的永久损失。
- `Buff` 通过 `Const.unitSys.GetUnit(Owner)?.GetComponent<StatsComponent>()` 获取属性组件，不再经过 `BuffHolder.stats`。
- holder/GameObject 已销毁或 owner 无效时，Buff 清理 `_appliedStats`，不向复用后的新单位扣属性。
- 配置由外部导出，运行期不做严格校验；stat 类型/派生属性等问题由导出侧保证。

## 时间

- `Duration`、`Interval`、`FirstTickDelay`、`ExpireAt`、`NextTickAt` 均为 int ms。
- 使用绝对 deadline，不创建 per-buff timer/coroutine。
- 单帧最多补 4 次 tick；`LastTickFrame` 防止转移后同帧二次 tick。
- Owner 已死亡时跳过 `TickEffectIds`/`OnTick`，仍推进 deadline 和到期移除。
- `Pause` 保存剩余毫秒；`SetDuration`/`SetRemaining` 在暂停态都按剩余值写入。

## 生命周期与错误策略

- 生命周期顺序执行；不再用嵌套 `try/finally`、catch-and-remove、catch-and-report 或 rollback 掩盖半完成状态。
- hook/生命周期异常直接向上抛出，先修触发点。
- `BuffHolder` 不捕获单 buff 异常；`BuffSystem.Update` 不吞 holder 异常。
- `StatsComponent.Awake` 内初始化基础属性；没有 `EnsureInitialized`/`_initialized`/`_initializing` 状态。
- hook 不得在 `Clear`/`OnOwnerDeath`/`OnDestroy` 期间向同一个 holder 添加 buff。

## Nullable 契约

- `BuffSystem.Instance` 已删除；系统通过非空 `Const.buffSys` 获取。
- `BuffSystem`/`UnitSystem`/`BuffHolder`/`StatsComponent` 中合法缺失用 `T?`：`Buff.Caster`、`FindHolderOrNull`、`UnitSystem.GetUnit`。
- 非 nullable 类型不再写 `== null`/`??` 兜底。
- `GameObject.GetComponent<T>()` 返回 `T?`，必须判空；需要组件时 `?? throw`。

## 表现

- Icon/图标 UI 计划未来用 FDF 绘制；`IconPath` 仅保留导出字段，`ApplyNativeIcon/RemoveNativeIcon` 为空实现。
- `AttachEffectIds`/`DetachEffectIds` 是导出字段，当前无执行点；视觉表现由 `Effects` 定义，转移时销毁重建。
- `TickEffectIds` 在 owner 存活、caster 有效时执行；pipeline 填充 `CastingUnit`、`TargetUnit`、`TargetX/Y`、`RTTargets`。

## 配置

`BuffConfig`/`EffectConfig` 是导出产物，运行期不做严格校验，字段格式保持不变。`FindByID` 保持简单查找，内容正确性由导出器负责。

## 测试与验收

验收命令：

```powershell
C:\Users\nef\Apps\SharpForge\sf-transpile.exe C:\Users\nef\workspace\Zulaman-WE\csproj -o C:\Users\nef\workspace\Zulaman-WE\bundle.lua --root-table SF__ --jass-version 3.0.1 --define DEBUG --ignore-class JASS --ignore-namespace SFLib.Interop --trace-calls
```

- 退出码 0，生成/更新 `bundle.lua`。
- `-bufftest` 覆盖 Apply/叠层/Refresh/Pause/Transfer/Merge/Clear/死亡/二次 Remove/同帧 Apply/stat delta。
- 测试失败计为失败；生产 hook/生命周期异常直接抛出。

## 已知限制

- `UnitSystem.GetUnit`/写入是字典 O(1)；`BuffSystem.Update`、`ClearCasterBuffs` 通过 `SnapshotUnits` 做 O(n) 枚举。
- native `RemoveUnit` 绕过 `UnitRemovedEvent`，字典会残留，不支持。
- 字典在 `StatsComponent` 之前写入；若构造抛异常，按 fail-fast 保留异常，不回滚字典。
- `BuffConfig`/`EffectConfig` 是导出配置，字段格式保持导出的 public 字段形式；不做严格校验。
- 旧 JASS `assets/scripts/core/BuffSystem.j` 不属于本 C# Buff 系统。
