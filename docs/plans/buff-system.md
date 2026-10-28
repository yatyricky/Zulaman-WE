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
- `OnTick`：周期 tick；`BuffDef.TickEffectIds` 先执行。
- `OnStackChanged` / `OnRefresh`：叠加、刷新。
- `OnDetach`：移除或转移前。
- `OnRemove`：仅最终移除，转移不调用。
- `OnTransfer` / `OnCasterDied`：转移和施法者失效。

## 时间

- `BuffDef.Duration`、`Interval`、`FirstTickDelay` 和 `Buff` 的 `Duration`、`Interval`、`ExpireAt`、`NextTickAt` 均为 int ms。
- `Buff` 使用绝对 deadline，不创建 per-buff timer/coroutine。
- 动态改时长/间隔只改整数 deadline；`Pause` 保存剩余毫秒。
- 单帧最多补 4 次 tick；`LastTickFrame` 防止转移后同帧二次 tick。

## API

- `BuffSystem.Apply(target, defId, caster, duration, stacks)`
- `BuffSystem.Remove(target, defId, reason)`
- `BuffSystem.Transfer(...)`
- `BuffSystem.Dispel(target, category, polarity, maxCount)`
- `BuffSystem.Clear(target, reason)`
- `Buff.SetDuration / SetRemaining / AddDuration / SetInterval / SetNextTickIn / Refresh / SetStacks / AddStack / Pause / Resume / SetCaster / Remove / TransferTo`

## 表现

- 原生 ability 仅作为图标；`IconAbilityId` 为 0 时不加图标。
- 通用视觉特效由 `BuffDef.Effects` 定义，转移时销毁并重建。
- 属性修改由 `BuffDef.StatModsPerStack` 按层数缩放，移除时精确抵消。

## 清理

- `UnitDeathEvent`：死亡当帧清理 `RemoveOnDeath` 的 buff。
- `UnitRemovedEvent`：延迟移除/清理 holder；`NativeValid=false` 时跳过原生调用。
- `UnitRemovedEvent.Cancel` + `StatsComponent.NewUnit`：单位 handle 复用前取消旧 pending，清理旧 stats/holder。
- caster 死亡/移除：按 `RemoveOnCasterDeath` 移除，否则清空 `Caster`，避免 handle 复用。
