using System;
using StdLib;

public class BuffSystem : Component
{
    public const int MaxTicksPerFrame = 4;

    public static BuffSystem Instance = null!;
    public static int Frame = 0;
    public static bool IsTicking = false;

    private static readonly List<BuffHolder> _holders = new List<BuffHolder>();
    private static readonly Dictionary<unit, BuffHolder> _byUnit = new Dictionary<unit, BuffHolder>();

    public override void Awake()
    {
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
            if (holder == null) continue;
            if (holder.gameObject.isDestroyed || holder.gameObject.isDestroyQueued) continue;
            holder.Tick(now);
        }
        IsTicking = false;
    }

    public static void Register(BuffHolder holder)
    {
        if (holder == null || holder.Owner == null) return;

        if (_byUnit.TryGetValue(holder.Owner, out var old) && old != holder)
        {
            old.NativeValid = false;
            old.Clear(BuffRemoveReason.UnitRemoved);
            _holders.Remove(old);
        }

        if (!_holders.Contains(holder))
        {
            _holders.Add(holder);
        }
        _byUnit[holder.Owner] = holder;
    }

    public static void Unregister(BuffHolder holder)
    {
        if (holder == null) return;
        _holders.Remove(holder);
        if (holder.Owner != null && _byUnit.TryGetValue(holder.Owner, out var current) && current == holder)
        {
            _byUnit.Remove(holder.Owner);
        }
    }

    public static BuffHolder? FindHolder(unit u)
    {
        if (u == null) return null;
        if (_byUnit.TryGetValue(u, out var holder)) return holder;
        return null;
    }

    public static Buff? Find(unit u, int defId)
    {
        var holder = FindHolder(u);
        return holder == null ? null : holder.Find(defId);
    }

    public static Buff? Apply(unit target, int defId, unit caster, int duration = -1, int stacks = 1)
    {
        if (target == null || GetUnitTypeId(target) == 0) return null;
        if (!IsUnitAliveBJ(target)) return null;

        var holder = FindHolder(target);
        if (holder == null || !holder.NativeValid || !holder.Stats.HasStats()) return null;

        var def = BuffConfig.FindByID(defId);
        var existing = holder.Find(defId);
        if (existing != null)
        {
            existing.Merge(caster, duration, stacks);
            return existing;
        }

        var buff = def.Create();
        if (buff == null) return null;
        buff.Init(def, holder, caster, duration, stacks);
        buff.Attach();
        return buff;
    }

    public static bool Remove(unit target, int defId, BuffRemoveReason reason = BuffRemoveReason.Manual)
    {
        var holder = FindHolder(target);
        if (holder == null) return false;
        var buff = holder.Find(defId);
        if (buff == null) return false;
        buff.Remove(reason);
        return true;
    }

    public static bool Transfer(unit from, int defId, unit to)
    {
        return Transfer(from, defId, to, null!, false);
    }

    public static bool Transfer(unit from, int defId, unit to, bool resetDuration)
    {
        return Transfer(from, defId, to, null!, resetDuration);
    }

    public static bool Transfer(unit from, int defId, unit to, unit newCaster)
    {
        return Transfer(from, defId, to, newCaster, false);
    }

    public static bool Transfer(unit from, int defId, unit to, unit newCaster, bool resetDuration)
    {
        var holder = FindHolder(from);
        if (holder == null) return false;
        var buff = holder.Find(defId);
        if (buff == null) return false;
        return Transfer(buff, to, newCaster, resetDuration);
    }

    public static bool Transfer(Buff buff, unit to)
    {
        return Transfer(buff, to, null!, false);
    }

    public static bool Transfer(Buff buff, unit to, unit newCaster)
    {
        return Transfer(buff, to, newCaster, false);
    }

    public static bool Transfer(Buff buff, unit to, unit newCaster, bool resetDuration)
    {
        if (buff == null || buff.IsRemoved || buff.IsRemoving || buff.IsTransferring) return false;
        if (to == null || GetUnitTypeId(to) == 0 || !IsUnitAliveBJ(to)) return false;

        var target = FindHolder(to);
        if (target == null || !target.NativeValid || !target.Stats.HasStats()) return false;

        if (buff.Holder == target)
        {
            if (newCaster != null) buff.Caster = newCaster;
            if (resetDuration) buff.Refresh();
            return true;
        }

        var existing = target.Find(buff.Config.ID);
        if (existing != null)
        {
            existing.MergeFrom(buff, newCaster);
            buff.Remove(BuffRemoveReason.Merged);
            return true;
        }

        return buff.TransferToHolder(target, newCaster, resetDuration);
    }

    public static int Dispel(unit target, BuffCategory category, BuffPolarity polarity, int maxCount = 1)
    {
        var holder = FindHolder(target);
        if (holder == null) return 0;

        var snapshot = holder.Snapshot();
        var count = 0;
        foreach (var buff in snapshot)
        {
            if (buff.IsRemoving || buff.IsRemoved) continue;
            if (!buff.Config.Dispellable) continue;
            if (category != BuffCategory.Any && buff.Config.Category != category) continue;
            if (polarity != BuffPolarity.Any && buff.Config.Polarity != polarity) continue;
            buff.Remove(BuffRemoveReason.Dispelled);
            count += 1;
            if (maxCount > 0 && count >= maxCount) break;
        }
        return count;
    }

    public static int Clear(unit target, BuffRemoveReason reason)
    {
        var holder = FindHolder(target);
        if (holder == null) return 0;
        return holder.Clear(reason);
    }

    private static void OnUnitDeath(UnitDeathEventData data)
    {
        var holder = FindHolder(data.u);
        if (holder != null)
        {
            holder.OnOwnerDeath();
        }

        var snapshot = new List<BuffHolder>(_holders);
        foreach (var current in snapshot)
        {
            if (current == null) continue;
            foreach (var buff in current.Snapshot())
            {
                if (buff.IsRemoving || buff.IsRemoved) continue;
                if (buff.Caster == data.u) buff.OnCasterDied();
            }
        }
    }

    private static void OnUnitRemoved(UnitRemovedEventData data)
    {
        var holder = FindHolder(data.u);
        if (holder != null)
        {
            holder.NativeValid = false;
            holder.Clear(BuffRemoveReason.UnitRemoved);
            Unregister(holder);
        }

        var snapshot = new List<BuffHolder>(_holders);
        foreach (var current in snapshot)
        {
            if (current == null) continue;
            foreach (var buff in current.Snapshot())
            {
                if (buff.IsRemoving || buff.IsRemoved) continue;
                if (buff.Caster == data.u) buff.OnCasterDied();
            }
        }
    }
}
