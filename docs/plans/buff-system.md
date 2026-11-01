# Buff 系统

## 结构

- `Buff`：普通对象，自管状态、毫秒 deadline 和生命周期 hook；不继承 `GameObject`/`Component`。
- `BuffHolder : Component`：每单位一个挂点，存 `List<Buff>`，负责 stats、图标引用计数和 holder 生命周期。
- `BuffSystem : Component`：全局单调度器，`Update` 中按 `GameTime.NowMs()` tick 所有 holder。

## 生命周期

```
Apply -> Attach -> Active -> Detach -> Removed
Active --Transfer--> Detach(Transferred) -> Attach(new holder) -> OnTransfer
```

- `OnAttach`：每次挂载（含转移）。
- `OnApply`：仅首次挂载。
- `OnTick`：周期 tick；`BuffConfigEntry.TickEffectIds` 先执行。
- `OnStackChanged` / `OnRefresh`：叠加、刷新。
- `OnDetach`：移除或转移前。
- `OnRemove`：仅最终移除，转移不调用；`Caster` 是 `unit?`，`Holder`/`Owner` 在 Buff 生命周期内保持非空。
- `OnTransfer`：转移完成；`HandleCasterGone` 内部执行 `RemoveOnCasterDeath` 策略，再调用可重写的 `OnCasterLost`。
- 目标已存在同一 buff 时，`Transfer` 走 `MergeFrom`：source 先 detach stats，target 叠层后按 target 的 `Duration`/`RefreshMode` 刷新，source 以 `Merged` 移除；source 的剩余时间不会单独保留。
- 生命周期按顺序执行，不再用嵌套 `try/finally` 或 catch/rollback 掩盖半完成状态；hook/生命周期异常直接向上抛出，先修触发点。
- `BuffHolder.Tick`/`Clear`/`OnOwnerDeath` 不捕获单 buff 异常；一个 buff 的错误不会被自动摘除后继续运行。

## 错误与 nullable 契约

- 非 nullable 类型（`BuffHolder`、`unit Owner` 等）按不变量使用，不再写 `== null`/`??` 兜底。
- 合法缺失使用 nullable：`Buff.Caster` 是 `unit?`，`BuffSystem.Instance` 是 `BuffSystem?`，`FindHolderOrNull` 返回 `BuffHolder?`；调用点必须判空。
- `GameObject.GetComponent<T>()` 返回 `T?`，必须判空；需要组件时 `?? throw`。
- 生命周期/hook 出错直接向上抛出，不做 catch-and-remove/report/rollback；先修触发点。只有 `StatsComponent.RegisterUnit` 的构造失败会 cleanup 后 rethrow。
- hook 不得在 `Clear`/`OnOwnerDeath`/`OnDestroy` 期间向同一个 holder 添加 buff；这是非法重入，不再用 `_clearing` 静默兜底。

## 时间

- `BuffConfigEntry.Duration`、`Interval`、`FirstTickDelay` 和 `Buff` 的 `Duration`、`Interval`、`ExpireAt`、`NextTickAt` 均为 int ms。
- `Buff` 使用绝对 deadline，不创建 per-buff timer/coroutine。
- 动态改时长/间隔只改整数 deadline；`Pause` 保存剩余毫秒。暂停状态下 `SetDuration`/`SetRemaining` 都按“剩余毫秒”写入 `_pausedRemaining`，`Resume` 后从该值继续；`AddDuration` 在暂停态累加剩余值。
- 单帧最多补 4 次 tick；`LastTickFrame` 防止转移后同帧二次 tick。
- Owner 已死亡时不再执行 `TickEffectIds`/`OnTick`，但仍推进 deadline 和到期移除。
- Owner handle 已无效时按 `UnitRemoved` 移除。

## 属性

- `BuffConfigEntry.StatModsPerStack` 按层数缩放。
- `Buff.SyncStats` 只对“新旧值之差”调用一次 `StatsComponent.ModStats`，避免叠层减少时先降低最大生命、夹低当前 HP、再恢复最大生命造成的永久损失。
- 移除时用保存的 `_appliedStats` 精确反向抵消；浮点属性仍建议只使用二进制精确值（0.25/0.5 等）。
- 配置由外部导出，运行期不做严格校验；stat 类型/派生属性等问题由导出侧保证。

## API

- `BuffSystem.Apply(target, configId, caster, duration, stacks)`
- `BuffSystem.Remove(target, configId, reason)`
- `BuffSystem.Transfer(...)`
- `BuffSystem.Dispel(target, category, polarity, maxCount)`：`0` 表示全部。
- `BuffSystem.Clear(target, reason)`
- `BuffSystem.FindHolderOrNull(unit)` / `Find(unit, configId)`
- `BuffSystem.RegisterFactory(configId, Func<Buff>)`：`Apply` 优先使用工厂；DEBUG 下 "001" 注册为 `TestBuff`。
- `Buff.SetDuration / SetRemaining / AddDuration / SetInterval / SetNextTickIn / Refresh / SetStacks / AddStack / Pause / Resume / SetCaster / Remove / TransferToHolder`
- `Buff.Tick`、`Buff.Merge`、`Buff.MergeFrom` 是调度器内部 API（internal）。
- 返回/抛错约定：
  - 参数、未知 ID、越界、非法时长/层数：抛异常。
  - `Apply` 对 dead/dummy/removed 目标返回 null；对存活但未注册 holder 的目标直接抛异常（不再惰性补登记）。
  - `Remove/Clear/Dispel/Find/Transfer(from, id)` 对缺失 holder/buff 返回 false/0/null，不抛。
  - `SetStacks` 越界抛异常；`AddStack` 在 MaxStacks 处显式 clamp。
  - `Caster` 是 `unit?`；`BuffSystem.Instance` 是 `BuffSystem?`；非 nullable 参数不再做 null 兜底。

## 单位生命周期与 holder

- `CreateUnitEvent`（region enter）+ `StatsComponent.Init` 的启动扫描共同登记已配置单位；Buff 层不再惰性补登记 holder，未注册目标直接抛异常，暴露创建/注册链问题。
- `StatsComponent.EnsureInitialized` 在 `NewUnit` `Bind(owner)` 后立即执行，保证同帧 `Apply` 时 stats 已就绪。
- `StatsComponent.owner` 通过 `Bind(unit)` 设置，属性类型为非 nullable；未 Bind 时访问直接抛异常。
- `UnitRemovedEvent.Remove` 是统一移除入口，且幂等：已移除/无效 handle 不会再次派发。
- 单位移除必须走 `UnitRemovedEvent.Remove`；直接 `RemoveUnit` 不会触发事件，不支持的旁路移除会导致 holder 泄漏/句柄复用风险。
- dummy 单位不作为 buff 目标；预置且已配置单位在 Init 时补建 Stats/BuffHolder。
- `UnitRemovedEvent` 在死亡 90 秒后派发；`UnitDeathEvent` 当帧清理 `RemoveOnDeath` buff。
- `StatsComponent.NewUnit` 的 handle 复用路径会取消旧 pending、清理旧 Components/GameObject；非 pending 的重复 live handle 直接 throw，不再日志后静默返回。

## 表现

- Icon/图标 UI 计划未来用 FDF 绘制；当前 `BuffConfigEntry.IconPath` 仅保留导出字段，`ApplyNativeIcon/RemoveNativeIcon` 是空实现，不接入原生 ability 图标。
- `AttachEffectIds`/`DetachEffectIds` 也是导出字段，当前没有执行点；实际视觉表现由 `Effects` 列表定义，转移时销毁并重建。
- `TickEffectIds` 在 owner 存活、caster 有效时执行；pipeline 填充 `CastingUnit`、`TargetUnit`、`TargetX/Y` 和 `RTTargets`。
- `PlaySFXData.duration` 为 ms；`PlaySFX` 本身只负责临时特效的创建/销毁。

## 配置

`BuffConfig`/`EffectConfig` 是导出产物，运行期不做严格校验，也不改变字段格式。`FindByID` 保持简单查找；配置内容由导出器/配置表负责保证正确性。

## 测试

- DEBUG 下聊天框执行 `-bufftest`（选中一个单位）覆盖 Apply/叠层、Refresh、Pause/Resume、Transfer/Merge、Clear、死亡清理、二次 Remove、同帧 Apply、stat delta 等。
- 预期日志：`bufftest: ALL PASSED`；测试失败计为失败，不依赖自动摘除坏 buff。生产 hook/生命周期异常直接向上抛出。

## 已知限制

- 未注册单位（区域外创建、dummy）不是 buff 目标；`Apply` 会抛异常或返回 null，需在调用侧保证目标已登记。
- native `RemoveUnit` 绕过 `UnitRemovedEvent`，不支持；由此产生的 handle 复用风险无法在 Buff 层完全消除。
- `BuffConfig`/`EffectConfig` 是导出配置，字段格式保持导出的 public 字段形式；运行期不做严格校验，也不在 Buff 层改写配置内容。
- 旧 JASS `assets/scripts/core/BuffSystem.j` 不属于本 C# Buff 系统。
