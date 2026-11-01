using System;
using StdLib;

public class BuffSystem : Component
{
    public const int MaxTicksPerFrame = 4;

    public static BuffSystem? Instance { get; private set; }
    public int Frame { get; private set; } = 0;
    public bool IsTicking { get; private set; } = false;

    private static readonly List<BuffHolder> _holders = [];
    private static readonly Dictionary<unit, BuffHolder> _byUnit = [];
    private static readonly Dictionary<string, Func<Buff>> _factories = [];

    public override void Awake()
    {
        if (Instance != null && Instance != this)
        {
            throw new Exception("BuffSystem already exists; only one scheduler instance is allowed");
        }

        Instance = this;
        GameTime.Init();
        UnitDeathEvent.Instance.Register(OnUnitDeath);
        UnitRemovedEvent.Instance.Register(OnUnitRemoved);
    }

    public override void Update()
    {
        Frame += 1;
        IsTicking = true;
        var now = GameTime.NowMs();
        var snapshot = new List<BuffHolder>(_holders);
        foreach (var holder in snapshot)
        {
            if (holder.gameObject.isDestroyed || holder.gameObject.isDestroyQueued) continue;
            holder.Tick(now);
        }
        IsTicking = false;
    }

    public static void RegisterFactory(string configId, Func<Buff> factory)
    {
        BuffConfig.FindByID(configId);
        _factories[configId] = factory;
    }

    internal static void Register(BuffHolder holder)
    {
        var old = FindHolderOrNull(holder.owner);
        if (old != null && old != holder)
        {
            old.SetNativeValid(false);
            old.Clear(BuffRemoveReason.UnitRemoved);
            _holders.Remove(old);
        }

        if (!_holders.Contains(holder))
        {
            _holders.Add(holder);
        }
        _byUnit[holder.owner] = holder;
    }

    internal static void Unregister(BuffHolder holder)
    {
        _holders.Remove(holder);
        var current = FindHolderOrNull(holder.owner);
        if (current == holder)
        {
            _byUnit.Remove(holder.owner);
        }
    }

    public static BuffHolder? FindHolderOrNull(unit? u)
    {
        if (u == null) return null;
        return _byUnit.TryGetValue(u, out var holder) ? holder : null;
    }

    public static BuffHolder FindHolder(unit u)
    {
        return FindHolderOrNull(u) ?? throw new Exception($"BuffHolder not found for unit: {Helper.GetUnitNameEx(u)}");
    }

    public static Buff? Find(unit u, string configId)
    {
        var holder = FindHolderOrNull(u);
        return holder?.Find(configId);
    }

    public static Buff? Apply(unit target, string configId, unit? caster, int duration = -1, int stacks = 1)
    {
        if (configId.Length == 0) throw new Exception("buff config id is empty");
        if (duration < -1) throw new Exception($"invalid buff duration: {duration}");
        if (stacks < 1) throw new Exception($"invalid buff stacks: {stacks}");

        var config = BuffConfig.FindByID(configId);

        if (GetUnitTypeId(target) == 0) return null;
        if (Helper.IsUnitDead(target)) return null;
        if (Helper.IsUnitDummy(target)) return null;

        var holder = FindHolder(target);
        if (!holder.nativeValid) return null;

        var existing = holder.Find(configId);
        if (existing != null)
        {
            existing.Merge(caster, duration, stacks);
            return existing.IsRemoved ? null : existing;
        }

        var buff = CreateBuff(configId);
        buff.Init(config, holder, caster, duration, stacks);
        buff.Attach();
        return buff.IsRemoved ? null : buff;
    }

    private static Buff CreateBuff(string configId)
    {
        if (_factories.TryGetValue(configId, out var factory))
        {
            return factory();
        }
        return new Buff();
    }

    public static bool Remove(unit target, string configId, BuffRemoveReason reason = BuffRemoveReason.Manual)
    {
        var holder = FindHolderOrNull(target);
        var buff = holder?.Find(configId);
        if (buff == null) return false;
        buff.Remove(reason);
        return true;
    }

    public static bool Transfer(unit from, string configId, unit to)
    {
        return Transfer(from, configId, to, null, false);
    }

    public static bool Transfer(unit from, string configId, unit to, bool resetDuration)
    {
        return Transfer(from, configId, to, null, resetDuration);
    }

    public static bool Transfer(unit from, string configId, unit to, unit? newCaster)
    {
        return Transfer(from, configId, to, newCaster, false);
    }

    public static bool Transfer(unit from, string configId, unit to, unit? newCaster, bool resetDuration)
    {
        var holder = FindHolderOrNull(from);
        var buff = holder?.Find(configId);
        if (buff == null) return false;
        return Transfer(buff, to, newCaster, resetDuration);
    }

    public static bool Transfer(Buff buff, unit to)
    {
        return Transfer(buff, to, null, false);
    }

    public static bool Transfer(Buff buff, unit to, unit? newCaster)
    {
        return Transfer(buff, to, newCaster, false);
    }

    public static bool Transfer(Buff buff, unit to, unit? newCaster, bool resetDuration)
    {
        if (buff.IsRemoved || buff.IsRemoving || buff.IsTransferring) return false;
        if (GetUnitTypeId(to) == 0 || Helper.IsUnitDead(to)) return false;
        if (Helper.IsUnitDummy(to)) return false;

        var target = FindHolder(to);
        if (!target.nativeValid) return false;

        if (buff.Holder == target)
        {
            if (newCaster != null) buff.SetCaster(newCaster);
            if (resetDuration) buff.Refresh();
            return true;
        }

        var existing = target.Find(buff.Config.ID);
        if (existing != null)
        {
            existing.MergeFrom(buff, newCaster);
            buff.Remove(BuffRemoveReason.Merged);
            return !existing.IsRemoved;
        }

        return buff.TransferToHolder(target, newCaster, resetDuration);
    }

    public static int Dispel(unit target, BuffCategory category, BuffPolarity polarity, int maxCount = 1)
    {
        if (category == 0) throw new Exception("buff category is empty");
        if (polarity == 0) throw new Exception("buff polarity is empty");
        if (maxCount < 0) throw new Exception($"invalid dispel count: {maxCount}");

        var holder = FindHolderOrNull(target);
        if (holder == null) return 0;

        var snapshot = holder.Snapshot();
        var count = 0;
        foreach (var buff in snapshot)
        {
            if (buff.IsRemoving || buff.IsRemoved) continue;
            if (!buff.Config.Dispellable) continue;
            if ((category & buff.Config.Category) == 0) continue;
            if ((polarity & buff.Config.Polarity) == 0) continue;
            buff.Remove(BuffRemoveReason.Dispelled);
            count += 1;
            if (maxCount > 0 && count >= maxCount) break;
        }
        return count;
    }

    public static int Clear(unit target, BuffRemoveReason reason)
    {
        var holder = FindHolderOrNull(target);
        return holder?.Clear(reason) ?? 0;
    }

    private static void OnUnitDeath(UnitDeathEventData data)
    {
        var holder = FindHolderOrNull(data.u);
        if (holder != null)
        {
            holder.OnOwnerDeath();
        }

        ClearCasterBuffs(data.u);
    }

    private static void OnUnitRemoved(UnitRemovedEventData data)
    {
        var holder = FindHolderOrNull(data.u);
        if (holder != null)
        {
            holder.SetNativeValid(false);
            holder.Clear(BuffRemoveReason.UnitRemoved);
            Unregister(holder);
        }

        ClearCasterBuffs(data.u);
    }

    private static void ClearCasterBuffs(unit u)
    {
        var snapshot = new List<BuffHolder>(_holders);
        foreach (var current in snapshot)
        {
            foreach (var buff in current.Snapshot())
            {
                if (buff.IsRemoving || buff.IsRemoved) continue;
                if (buff.Caster != u) continue;
                buff.HandleCasterGone();
            }
        }
    }
}
