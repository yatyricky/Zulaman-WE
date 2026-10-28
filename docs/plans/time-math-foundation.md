# 时间与 Math 基础设施

## 时间

- `csproj/src` 的游戏时间统一使用 `int` 毫秒。
- 已有 identifier 不改名、不改注释；新增时间字段沿用项目现有命名。
- `GameTime.NowMs()` 是唯一游戏时间源：60 秒周期 timer + `TimerGetElapsed` 累加。
- JASS timer 的秒单位只出现在 `GameTime` 内部；`Task.Delay` 参数全部为 ms。
- `PlaySFXData.duration` 名称不变，语义改为 ms；`ApplyBuffData.duration`、`BuffDef.Duration`、`BuffDef.Interval` 等均为 ms。

## Math

- `csproj/src` 业务代码只调用 `Math`；`math.*` 和 JASS 数学函数只允许出现在 `Utils/Math.cs`。
- `Math` 内部优先使用 Lua `math` 库；RNG 例外使用 JASS `GetRandomInt`/`GetRandomReal`，保证多人同步。
- `Math.FloorToInt/CeilToInt/RoundToInt/TruncateToInt` 先按 1e-6 精度 snap，再取整，规避 `0.99999994`、`0.49999997` 等边界误差。
- `Math.PowInt` 用整数循环，替代 `(int)math.pow`。
- 业务代码禁止裸 `(int)` 转换 float；禁止 JASS `MathRound`/`R2I`。
- 浮点比较使用 `Math.FuzzyEquals`。
