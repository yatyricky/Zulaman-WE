using System;
using System.Threading.Tasks;
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
        AddCmd("-buff", CmdBuff);
        AddCmd("-buffst", CmdBuffSt);
        AddCmd("-buffdur", CmdBuffDur);
        AddCmd("-buffint", CmdBuffInt);
        AddCmd("-buffref", CmdBuffRef);
        AddCmd("-buffpause", CmdBuffPause);
        AddCmd("-buffresume", CmdBuffResume);
        AddCmd("-buffclear", CmdBuffClear);
        AddCmd("-buffxfer", CmdBuffXfer);
        AddCmd("-bufftest", CmdBuffTest);
#endif
    }

    private static void AddCmd(string cmd, Action<string> handler)
    {
        var t = CreateTrigger();
        TriggerRegisterPlayerChatEvent(t, Player(0), cmd, false);
        TriggerAddAction(t, () => handler(GetEventPlayerChatString()));
    }

    private static StatsComponent? FindStats(unit u)
    {
        var obj = Const.unitSys.GetUnit(u);
        return obj?.GetComponent<StatsComponent>();
    }

    private static StatsComponent SelComp(string tag)
    {
        if (!Selection.PlayerSelection.TryGetValue(GetPlayerId(GetLocalPlayer()), out var u))
        {
            BJDebugMsg(tag + ": no selection");
            return null!;
        }
        var comp = FindStats(u);
        if (comp == null)
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

    private static BuffHolder? SelHolder(string tag)
    {
        var comp = SelComp(tag);
        if (comp == null) return null;
        var holder = comp.gameObject.GetComponent<BuffHolder>();
        if (holder == null)
        {
            BJDebugMsg(tag + ": unit has no BuffHolder");
            return null;
        }
        return holder;
    }

    private static Buff? FirstBuff(BuffHolder holder)
    {
        var snapshot = holder.Snapshot();
        if (snapshot.Count == 0) return null;
        return snapshot[0];
    }

    private static unit NearestOther(unit from, float range)
    {
        var g = CreateGroup();
        GroupEnumUnitsInRange(g, GetUnitX(from), GetUnitY(from), range, Filter(() => true));
        unit best = null!;
        var bestDist = range * range;
        while (true)
        {
            var u = FirstOfGroup(g);
            if (u == null) break;
            GroupRemoveUnit(g, u);
            if (u == from || IsUnitDeadBJ(u) || Helper.IsUnitDummy(u)) continue;
            var dx = GetUnitX(u) - GetUnitX(from);
            var dy = GetUnitY(u) - GetUnitY(from);
            var dist = dx * dx + dy * dy;
            if (dist < bestDist)
            {
                bestDist = dist;
                best = u;
            }
        }
        DestroyGroup(g);
        return best;
    }

    private static void CmdBuff(string str)
    {
        var len = StringLength(str);
        if (len > 5 && SubString(str, 5, 6) != " ") return;

        var comp = SelComp("-buff");
        if (comp == null) return;

        var id = "001";
        if (len > 6) id = SubString(str, 6, len);
        Const.buffSys.Apply(comp.owner, id, comp.owner);
    }

    private static void CmdBuffSt(string str)
    {
        var holder = SelHolder("-buffst");
        if (holder == null) return;

        BJDebugMsg("buffst count=" + I2S(holder.count));
        foreach (var buff in holder.Snapshot())
        {
            BJDebugMsg("  id=" + buff.Config.ID
                + " name=" + buff.Config.Name
                + " stacks=" + I2S(buff.Stacks)
                + " rem=" + I2S(buff.RemainingMs())
                + " next=" + I2S(buff.NextTickInMs())
                + " paused=" + (buff.Paused ? "1" : "0"));
        }
    }

    private static void CmdBuffDur(string str)
    {
        var holder = SelHolder("-buffdur");
        if (holder == null) return;
        var buff = FirstBuff(holder);
        if (buff == null) return;

        var len = StringLength(str);
        if (len <= 9)
        {
            BJDebugMsg("-buffdur: missing ms");
            return;
        }
        buff.SetDuration(S2I(SubString(str, 9, len)));
    }

    private static void CmdBuffInt(string str)
    {
        var holder = SelHolder("-buffint");
        if (holder == null) return;
        var buff = FirstBuff(holder);
        if (buff == null) return;

        var len = StringLength(str);
        if (len <= 9)
        {
            BJDebugMsg("-buffint: missing ms");
            return;
        }
        var interval = S2I(SubString(str, 9, len));
        if (interval < 0)
        {
            BJDebugMsg("-buffint: invalid ms");
            return;
        }
        buff.SetInterval(interval);
    }

    private static void CmdBuffRef(string str)
    {
        var holder = SelHolder("-buffref");
        if (holder == null) return;
        var buff = FirstBuff(holder);
        if (buff == null) return;
        buff.Refresh(true, true);
    }

    private static void CmdBuffPause(string str)
    {
        var holder = SelHolder("-buffpause");
        if (holder == null) return;
        var buff = FirstBuff(holder);
        if (buff == null) return;
        buff.Pause();
    }

    private static void CmdBuffResume(string str)
    {
        var holder = SelHolder("-buffresume");
        if (holder == null) return;
        var buff = FirstBuff(holder);
        if (buff == null) return;
        buff.Resume();
    }

    private static void CmdBuffClear(string str)
    {
        var comp = SelComp("-buffclear");
        if (comp == null) return;
        BJDebugMsg("-buffclear removed=" + I2S(Const.buffSys.Clear(comp.owner, BuffRemoveReason.Manual)));
    }

    private static void CmdBuffXfer(string str)
    {
        var comp = SelComp("-buffxfer");
        if (comp == null) return;
        var holder = comp.gameObject.GetComponent<BuffHolder>();
        if (holder == null) return;
        var buff = FirstBuff(holder);
        if (buff == null) return;

        var target = NearestOther(comp.owner, 600f);
        if (target == null)
        {
            BJDebugMsg("-buffxfer: no target");
            return;
        }
        BJDebugMsg("-buffxfer ok=" + (Const.buffSys.Transfer(buff, target, comp.owner) ? "1" : "0"));
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
        var comp = FindStats(u);
        if (comp == null)
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
        var comp = FindStats(u);
        if (comp == null)
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

    private static void SafeRemoveUnit(unit u)
    {
        if (u == null || GetUnitTypeId(u) == 0) return;
        UnitRemovedEvent.Remove(u);
    }

    private static void CmdBuffTest(string str)
    {
        _ = RunBuffTest();
    }

    private static async Task RunBuffTest()
    {
        _fail = 0;

        if (!Selection.PlayerSelection.TryGetValue(GetPlayerId(GetLocalPlayer()), out var caster))
        {
            BJDebugMsg("bufftest: no selection");
            return;
        }
        var casterComp = FindStats(caster);
        if (casterComp == null)
        {
            BJDebugMsg("bufftest: selected unit has no StatsComponent");
            return;
        }
        var casterHolder = casterComp.gameObject.GetComponent<BuffHolder>();
        if (casterHolder == null)
        {
            BJDebugMsg("bufftest: selected unit has no BuffHolder");
            return;
        }

        unit target = null!;
        unit other = null!;
        unit victim = null!;
        unit dyingCaster = null!;

        try
        {
            var x = GetUnitX(caster);
            var y = GetUnitY(caster);

            target = CreateUnit(Player(0), FourCC("hfoo"), x, y, 0);

            Buff? sameFrame = null;
            try
            {
                sameFrame = Const.buffSys.Apply(target, "001", caster);
            }
            catch (Exception e)
            {
                BJDebugMsg("bufftest same-frame apply threw: " + e.Message);
            }
            Check("bufftest same-frame apply", sameFrame != null);
            Check("bufftest same-frame registration", FindStats(target) != null);
            sameFrame?.Remove();

            await Task.Delay(100);

            var comp = FindStats(target);
            if (comp == null)
            {
                throw new Exception("bufftest target stats are missing");
            }
            var holder = comp.gameObject.GetComponent<BuffHolder>();
            Check("bufftest target holder", holder != null);
            if (holder == null) throw new Exception("bufftest target holder is missing");

            var first = Const.buffSys.Apply(target, "001", caster);
            Check("bufftest apply 001", first != null && holder.Find("001") != null && holder.count == 1);

            var second = Const.buffSys.Apply(target, "001", caster);
            Check("bufftest add stack", second != null && second.Stacks == 2);

            var i = 0;
            while (i < 4)
            {
                Const.buffSys.Apply(target, "001", caster);
                i += 1;
            }
            Check("bufftest max stacks", holder.Find("001")!.Stacks == 3);

            Check("bufftest clear", Const.buffSys.Clear(target, BuffRemoveReason.Manual) == 1 && holder.count == 0);

            var resBase = comp.GetStat(StatId.AllDamageRes).floatVal;
            var statBuff = Const.buffSys.Apply(target, "001", caster);
            Check("bufftest stat buff applied", statBuff != null && holder.Find("001") != null);
            if (statBuff != null)
            {
                Check("bufftest stat stack 1", Math.FuzzyEquals(comp.GetStat(StatId.AllDamageRes).floatVal, resBase + 0.25f));
                Const.buffSys.Apply(target, "001", caster);
                Check("bufftest stat stack 2", Math.FuzzyEquals(comp.GetStat(StatId.AllDamageRes).floatVal, resBase + 0.5f));

                var statRound = 0;
                while (statRound < 4)
                {
                    Const.buffSys.Apply(target, "001", caster);
                    statRound += 1;
                }
                Check("bufftest stat max stacks", Math.FuzzyEquals(comp.GetStat(StatId.AllDamageRes).floatVal, resBase + 0.75f));

                statBuff.Remove();
                Check("bufftest stat restore", Math.FuzzyEquals(comp.GetStat(StatId.AllDamageRes).floatVal, resBase));
            }

            var refreshBuff = Const.buffSys.Apply(target, "001", caster);
            Check("bufftest refresh buff applied", refreshBuff != null && holder.Find("001") != null);
            if (refreshBuff != null)
            {
                await Task.Delay(100);
                var before = refreshBuff.RemainingMs();
                refreshBuff.Refresh();
                Check("bufftest reset duration refresh", refreshBuff.RemainingMs() > before);
                refreshBuff.Remove();
            }

            var pauseBuff = Const.buffSys.Apply(target, "001", caster);
            Check("bufftest pause buff applied", pauseBuff != null);
            if (pauseBuff != null)
            {
                pauseBuff.Pause();
                var pausedRemaining = pauseBuff.RemainingMs();
                await Task.Delay(150);
                Check("bufftest pause freezes remaining", pauseBuff.RemainingMs() == pausedRemaining);
                pauseBuff.Resume();
                Check("bufftest resume", !pauseBuff.Paused);
                pauseBuff.Remove();
            }

            other = CreateUnit(Player(0), FourCC("hfoo"), x, y, 0);
            await Task.Delay(100);
            var otherComp = FindStats(other);
            if (otherComp == null)
            {
                throw new Exception("bufftest transfer target stats are missing");
            }
            var otherHolder = otherComp.gameObject.GetComponent<BuffHolder>();
            Check("bufftest transfer target holder", otherHolder != null);
            if (otherHolder == null) throw new Exception("bufftest transfer target holder is missing");

            var transferBuff = Const.buffSys.Apply(target, "001", caster);
            Check("bufftest transfer source applied", transferBuff != null);
            if (transferBuff != null)
            {
                Check("bufftest transfer", Const.buffSys.Transfer(transferBuff, other, caster));
                Check("bufftest transfer source empty", holder.count == 0);
                Check("bufftest transfer target has buff", otherHolder.count == 1);
            }

            Const.buffSys.Clear(other, BuffRemoveReason.Manual);
            var mergeA = Const.buffSys.Apply(target, "001", caster);
            var mergeB = Const.buffSys.Apply(other, "001", caster);
            Check("bufftest merge sources", mergeA != null && mergeB != null);
            if (mergeA != null && mergeB != null)
            {
                Check("bufftest merge transfer", Const.buffSys.Transfer(mergeB, target, caster));
                Check("bufftest merge result", holder.count == 1 && holder.Find("001")?.Stacks == 2);
                Check("bufftest merge source consumed", otherHolder.count == 0);
            }
            Const.buffSys.Clear(target, BuffRemoveReason.Manual);

            victim = CreateUnit(Player(0), FourCC("hfoo"), x, y, 0);
            await Task.Delay(100);
            var victimComp = FindStats(victim);
            if (victimComp == null)
            {
                throw new Exception("bufftest victim stats are missing");
            }
            var victimHolder = victimComp.gameObject.GetComponent<BuffHolder>();
            Check("bufftest victim holder", victimHolder != null);
            if (victimHolder == null) throw new Exception("bufftest victim holder is missing");

            Const.buffSys.Apply(victim, "001", caster);
            Check("bufftest victim buff", victimHolder.count == 1);

            KillUnit(victim);
            await Task.Delay(100);
            Check("bufftest death removes RemoveOnDeath", victimHolder.Find("001") == null);

            UnitRemovedEvent.Remove(victim);
            UnitRemovedEvent.Remove(victim);
            Check("bufftest unit removed idempotently", FindStats(victim) == null);
            victim = null!;

            dyingCaster = CreateUnit(Player(0), FourCC("hfoo"), x, y, 0);
            await Task.Delay(100);
            if (FindStats(dyingCaster) == null)
            {
                throw new Exception("bufftest dying caster stats are missing");
            }
            var casterBuff = Const.buffSys.Apply(target, "001", dyingCaster);
            Check("bufftest caster-death buff applied", casterBuff != null && holder.Find("001") != null);
            KillUnit(dyingCaster);
            await Task.Delay(100);
            Check("bufftest caster death clears caster", casterBuff != null && casterBuff.Caster == null && casterBuff.IsRemoved == false);
            casterBuff?.Remove();
            UnitRemovedEvent.Remove(dyingCaster);
            dyingCaster = null!;
        }
        catch (Exception e)
        {
            _fail += 1;
            BJDebugMsg("bufftest exception: " + e.Message);
        }
        finally
        {
            SafeRemoveUnit(other);
            SafeRemoveUnit(victim);
            SafeRemoveUnit(dyingCaster);
            SafeRemoveUnit(target);
        }

        if (_fail == 0)
        {
            BJDebugMsg("bufftest: ALL PASSED");
        }
        else
        {
            BJDebugMsg("bufftest: " + I2S(_fail) + " FAILURES");
        }
    }
}
