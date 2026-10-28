using System;
using StdLib;

/// <summary>
/// 仿旧图 Command.j 的调试命令(仅 Player(0),聊天框输入)。
/// -hp n / -exhp n / -pct r:对当前选中单位做属性加减
/// -st:打印选中单位全部属性
/// -stest:属性系统回归测试,覆盖各种加减组合,结束后必须零误差还原
/// </summary>
public class Command
{
    private static int _fail = 0;

    public static void Init()
    {
#if DEBUG
        AddCmd("-hp", CmdHp);
        AddCmd("-exhp", CmdExhp);
        AddCmd("-pct", CmdPct);
        AddCmd("-st", CmdSt);
        AddCmd("-stest", CmdStest);
        AddCmd("-sshow", ShowStats);
        AddCmd("-mathtest", CmdMathTest);
        AddCmd("-time", CmdTime);
#endif
    }

    private static void AddCmd(string cmd, Action<string> handler)
    {
        var t = CreateTrigger();
        TriggerRegisterPlayerChatEvent(t, Player(0), cmd, false);
        TriggerAddAction(t, () => handler(GetEventPlayerChatString()));
    }

    private static StatsComponent SelComp(string tag)
    {
        if (!Selection.PlayerSelection.TryGetValue(GetPlayerId(GetLocalPlayer()), out var u))
        {
            BJDebugMsg(tag + ": no selection");
            return null!;
        }
        if (!StatsComponent.Components.TryGetValue(u, out var comp))
        {
            BJDebugMsg(tag + ": unit has no StatsComponent");
            return null!;
        }
        return comp;
    }

    private static Dictionary<StatId, StatValue> Mod1(StatId a, StatValue va)
    {
        return new Dictionary<StatId, StatValue>() { { a, va } };
    }

    private static Dictionary<StatId, StatValue> Mod2(StatId a, StatValue va, StatId b, StatValue vb)
    {
        return new Dictionary<StatId, StatValue>() { { a, va }, { b, vb } };
    }

    private static Dictionary<StatId, StatValue> Mod3(StatId a, StatValue va, StatId b, StatValue vb, StatId c, StatValue vc)
    {
        return new Dictionary<StatId, StatValue>() { { a, va }, { b, vb }, { c, vc } };
    }

    /// <summary>独立重算期望的 RMaxHp,作为 CalcRMaxHp 的对照公式。</summary>
    private static int ExpectedRMaxHp(StatsComponent comp)
    {
        var b = comp.GetStat(StatId.BaseHp).intVal;
        var e = comp.GetStat(StatId.ExMaxHp).intVal;
        var p = comp.GetStat(StatId.ExMapHpPct).floatVal;
        return Math.RoundToInt((comp.strength * 10 + b + e) * (1f + p));
    }

    private static void Check(string name, bool ok)
    {
        if (ok)
        {
            BJDebugMsg("[PASS] " + name);
        }
        else
        {
            _fail += 1;
            BJDebugMsg("[FAIL] " + name);
        }
    }

    private static void CmdHp(string str)
    {
        var comp = SelComp("-hp");
        if (comp == null) return;
        comp.ModStats(Mod1(StatId.BaseHp, S2I(SubString(str, 4, StringLength(str)))));
    }

    private static void CmdExhp(string str)
    {
        var comp = SelComp("-exhp");
        if (comp == null) return;
        comp.ModStats(Mod1(StatId.ExMaxHp, S2I(SubString(str, 6, StringLength(str)))));
    }

    private static void CmdPct(string str)
    {
        var comp = SelComp("-pct");
        if (comp == null) return;
        comp.ModStats(Mod1(StatId.ExMapHpPct, S2R(SubString(str, 5, StringLength(str)))));
    }

    private static void CmdMathTest(string str)
    {
        _fail = 0;
        var a = 0.2f;
        var b = 0.3f;
        var c = 0.8f;
        var sum03 = a + b;
        var sum08 = a + c;

        Check("math 0.2+0.3 round", Math.RoundToInt(sum03) == 1);
        Check("math 0.2+0.8 round", Math.RoundToInt(sum08) == 1);
        Check("math 0.2+0.8 floor", Math.FloorToInt(sum08) == 1);
        Check("math 0.2+0.8 ceil", Math.CeilToInt(sum08) == 1);
        Check("math 0.2+0.8 trunc", Math.TruncateToInt(sum08) == 1);
        Check("math 0.49999997 round", Math.RoundToInt(0.49999997f) == 1);
        Check("math 0.499 round", Math.RoundToInt(0.499f) == 0);
        Check("math 0.99999997 floor", Math.FloorToInt(0.99999997f) == 1);
        Check("math 1.00000003 ceil", Math.CeilToInt(1.00000003f) == 1);
        Check("math 1.5 round", Math.RoundToInt(1.5f) == 2);
        Check("math -1.5 round", Math.RoundToInt(-1.5f) == -2);
        Check("math -1.5 floor", Math.FloorToInt(-1.5f) == -2);
        Check("math -1.5 ceil", Math.CeilToInt(-1.5f) == -1);
        Check("math -1.5 trunc", Math.TruncateToInt(-1.5f) == -1);
        Check("math abs float", Math.Abs(-0.5f) == 0.5f);
        Check("math abs int", Math.Abs(-3) == 3);
        Check("math powint", Math.PowInt(2, 10) == 1024);
        Check("math random int", Math.RandomInt(1, 1) == 1);
        Check("math fuzzy", Math.FuzzyEquals(sum03, 0.5f));

        if (_fail == 0)
        {
            BJDebugMsg("mathtest: ALL PASSED");
        }
        else
        {
            BJDebugMsg("mathtest: " + I2S(_fail) + " FAILURES");
        }
    }

    private static void CmdTime(string str)
    {
        BJDebugMsg("GameTime.NowMs=" + I2S(GameTime.NowMs()));
    }
    private static void CmdSt(string str)
    {
        var comp = SelComp("-st");
        if (comp == null) return;
        BJDebugMsg("BaseHp=" + I2S(comp.GetStat(StatId.BaseHp).intVal)
            + " ExMaxHp=" + I2S(comp.GetStat(StatId.ExMaxHp).intVal)
            + " ExMapHpPct=" + R2S(comp.GetStat(StatId.ExMapHpPct).floatVal)
            + " RMaxHp=" + I2S(comp.GetStat(StatId.RMaxHp).intVal));
    }

    private static void ShowStats(string str)
    {
        if (!Selection.PlayerSelection.TryGetValue(GetPlayerId(GetLocalPlayer()), out var u))
        {
            BJDebugMsg("stest: no selection");
            return;
        }
        if (!StatsComponent.Components.TryGetValue(u, out var comp))
        {
            BJDebugMsg("stest: unit has no StatsComponent");
            return;
        }
        if (!comp.HasStats())
        {
            BJDebugMsg("stest: stats not initialized");
            return;
        }

        foreach (var entry in StatConfig.Data)
        {
            var id = entry.ID;
            var val = comp.GetStat(id);
            switch (entry.Type)
            {
                case StatType.Float:
                    BJDebugMsg($"[{id}] {entry.Description} = {val.floatVal}");
                    break;
                case StatType.Int:
                    BJDebugMsg($"[{id}] {entry.Description} = {val.intVal}");
                    break;
                default:
                    throw new Exception("xczxcxc");
            }
        }

        BJDebugMsg($"str: {comp.strength}");
        BJDebugMsg($"agi: {comp.agility}");
        BJDebugMsg($"int: {comp.intelligence}");
        BJDebugMsg($"melee: {comp.meleeLow} - {comp.meleeHigh}");
        BJDebugMsg($"armor: {comp.armor} ({comp.phyxDamageTakenPct})");
    }

    private static void CmdStest(string str)
    {
        if (!Selection.PlayerSelection.TryGetValue(GetPlayerId(GetLocalPlayer()), out var u))
        {
            BJDebugMsg("stest: no selection");
            return;
        }
        if (!StatsComponent.Components.TryGetValue(u, out var comp))
        {
            BJDebugMsg("stest: unit has no StatsComponent");
            return;
        }
        if (!comp.HasStats())
        {
            BJDebugMsg("stest: stats not initialized");
            return;
        }

        _fail = 0;
        var ob = comp.GetStat(StatId.BaseHp);
        var oe = comp.GetStat(StatId.ExMaxHp);
        var op = comp.GetStat(StatId.ExMapHpPct);
        var orv = comp.GetStat(StatId.RMaxHp);
        var nativeMax = GetUnitState(u, UNIT_STATE_MAX_LIFE);

        // A: 整数反复加减,净变化为零
        comp.ModStats(Mod1(StatId.BaseHp, 100));
        comp.ModStats(Mod1(StatId.BaseHp, 50));
        comp.ModStats(Mod1(StatId.BaseHp, -30));
        comp.ModStats(Mod1(StatId.BaseHp, -120));
        Check("A basehp +100+50-30-120", comp.GetStat(StatId.BaseHp) == ob);

        // B: 浮点百分比,只用二进制精确值(0.25/0.5),中间值与还原都精确
        comp.ModStats(Mod1(StatId.ExMapHpPct, 0.25f));
        comp.ModStats(Mod1(StatId.ExMapHpPct, 0.25f));
        Check("B pct mid exact 0.5", comp.GetStat(StatId.ExMapHpPct).floatVal == op.floatVal + 0.5f);
        comp.ModStats(Mod1(StatId.ExMapHpPct, -0.5f));
        Check("B pct restore", comp.GetStat(StatId.ExMapHpPct) == op);

        // C: 单次调用批量改三项,逐项核对并对照派生公式,再批量还原
        comp.ModStats(Mod3(StatId.BaseHp, 50, StatId.ExMaxHp, 25, StatId.ExMapHpPct, 0.5f));
        Check("C basehp +50", comp.GetStat(StatId.BaseHp) == ob + 50);
        Check("C exmaxhp +25", comp.GetStat(StatId.ExMaxHp) == oe + 25);
        Check("C pct +0.5", comp.GetStat(StatId.ExMapHpPct) == op + 0.5f);
        Check("C rmaxhp derived", comp.GetStat(StatId.RMaxHp).intVal == ExpectedRMaxHp(comp));
        comp.ModStats(Mod3(StatId.BaseHp, -50, StatId.ExMaxHp, -25, StatId.ExMapHpPct, -0.5f));
        Check("C restore all", comp.GetStat(StatId.BaseHp) == ob && comp.GetStat(StatId.ExMaxHp) == oe && comp.GetStat(StatId.ExMapHpPct) == op && comp.GetStat(StatId.RMaxHp) == orv);

        // D: 零增量不产生任何变化
        comp.ModStats(Mod1(StatId.BaseHp, 0));
        comp.ModStats(Mod1(StatId.ExMapHpPct, 0f));
        Check("D noop keeps all", comp.GetStat(StatId.BaseHp) == ob && comp.GetStat(StatId.ExMaxHp) == oe && comp.GetStat(StatId.ExMapHpPct) == op && comp.GetStat(StatId.RMaxHp) == orv);

        // E: 交错加减三轮,每步之后派生值都要与对照公式一致
        var round = 0;
        while (round < 3)
        {
            comp.ModStats(Mod2(StatId.BaseHp, 10, StatId.ExMapHpPct, 0.125f));
            Check("E rmaxhp after + round " + I2S(round), comp.GetStat(StatId.RMaxHp).intVal == ExpectedRMaxHp(comp));
            comp.ModStats(Mod2(StatId.BaseHp, -10, StatId.ExMapHpPct, -0.125f));
            Check("E rmaxhp after - round " + I2S(round), comp.GetStat(StatId.RMaxHp).intVal == ExpectedRMaxHp(comp));
            round += 1;
        }
        Check("E restore all", comp.GetStat(StatId.BaseHp) == ob && comp.GetStat(StatId.ExMaxHp) == oe && comp.GetStat(StatId.ExMapHpPct) == op && comp.GetStat(StatId.RMaxHp) == orv);

        // F: 压力 — 100 次 +7,再一次 -700,整数路径不允许漂移
        var n = 0;
        while (n < 100)
        {
            comp.ModStats(Mod1(StatId.ExMaxHp, 7));
            n += 1;
        }
        comp.ModStats(Mod1(StatId.ExMaxHp, -700));
        Check("F exmaxhp stress restore", comp.GetStat(StatId.ExMaxHp) == oe);

        // G: 终检 — 属性值与 war3 层最大生命完全还原,不允许任何误差
        Check("G all stats zero drift", comp.GetStat(StatId.BaseHp) == ob && comp.GetStat(StatId.ExMaxHp) == oe && comp.GetStat(StatId.ExMapHpPct) == op && comp.GetStat(StatId.RMaxHp) == orv);
        Check("G native max life restored", GetUnitState(u, UNIT_STATE_MAX_LIFE) == nativeMax);
        if (_fail == 0)
        {
            BJDebugMsg("stest: ALL PASSED, zero drift");
        }
        else
        {
            BJDebugMsg("stest: " + I2S(_fail) + " FAILURES");
        }
    }
}
