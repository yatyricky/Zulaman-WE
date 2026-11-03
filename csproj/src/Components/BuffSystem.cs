using System;
using StdLib;

public class BuffSystem : Component
{
    public const int MaxTicksPerFrame = 4;

    private static bool _initialized;

    public int Frame { get; private set; } = 0;
    public bool IsTicking { get; private set; } = false;

    public override void Awake()
    {
        if (_initialized) throw new InvalidOperationException("BuffSystem already initialized");
        _initialized = true;

        GameTime.Init();
        UnitDeathEvent.Instance.Register(d => OnUnitDeath(d));
        UnitRemovedEvent.Instance.Register(d => OnUnitRemoved(d));
    }

    public override void Update()
    {
        Frame += 1;
        IsTicking = true;

        var now = GameTime.NowMs();
        var units = Const.unitSys.SnapshotUnits();
        foreach (var go in units)
        {
            if (go.isDestroyed || go.isDestroyQueued) continue;

            var holder = go.GetComponent<BuffHolder>();
            if (holder == null) continue;
            holder.Tick(now, Frame);
        }

        IsTicking = false;
    }

    public BuffHolder? FindHolderOrNull(unit? u)
    {
        var obj = Const.unitSys.GetUnit(u);
        return obj?.GetComponent<BuffHolder>();
    }

    public BuffHolder FindHolder(unit u)
    {
        return FindHolderOrNull(u) ?? throw new Exception($"BuffHolder not found for unit: {Helper.GetUnitNameEx(u)}");
    }

    public Buff? Find(unit u, string configId)
    {
        var holder = FindHolderOrNull(u);
        return holder?.Find(configId);
    }

    public Buff? Apply(unit target, string configId, unit? caster, int duration = -1, int stacks = 1)
    {
        if (configId.Length == 0) throw new Exception("buff config id is empty");
        if (duration < -1) throw new Exception($"invalid buff duration: {duration}");
        if (stacks < 1) throw new Exception($"invalid buff stacks: {stacks}");

        var config = BuffConfig.FindByID(configId);

        if (GetUnitTypeId(target) == 0) return null;
        if (Helper.IsUnitDead(target)) return null;
        if (Helper.IsUnitDummy(target)) return null;

        var holder = FindHolder(target);
        if (!holder.ownerValid) return null;

        var existing = holder.Find(configId);
        if (existing != null)
        {
            existing.Merge(caster, duration, stacks);
            return existing.IsRemoved ? null : existing;
        }

        var buff = new Buff();
        buff.Init(config, holder, caster, duration, stacks);
        buff.Attach();
        if (buff.IsRemoved) return null;
        buff.MarkTickFrame(IsTicking ? Frame : -1);
        return buff;
    }

    public bool Remove(unit target, string configId, BuffRemoveReason reason = BuffRemoveReason.Manual)
    {
        var holder = FindHolderOrNull(target);
        var buff = holder?.Find(configId);
        if (buff == null) return false;
        buff.Remove(reason);
        return true;
    }

    public bool Transfer(unit from, string configId, unit to)
    {
        return Transfer(from, configId, to, null, false);
    }

    public bool Transfer(unit from, string configId, unit to, bool resetDuration)
    {
        return Transfer(from, configId, to, null, resetDuration);
    }

    public bool Transfer(unit from, string configId, unit to, unit? newCaster)
    {
        return Transfer(from, configId, to, newCaster, false);
    }

    public bool Transfer(unit from, string configId, unit to, unit? newCaster, bool resetDuration)
    {
        var holder = FindHolderOrNull(from);
        var buff = holder?.Find(configId);
        if (buff == null) return false;
        return Transfer(buff, to, newCaster, resetDuration);
    }

    public bool Transfer(Buff buff, unit to)
    {
        return Transfer(buff, to, null, false);
    }

    public bool Transfer(Buff buff, unit to, unit? newCaster)
    {
        return Transfer(buff, to, newCaster, false);
    }

    public bool Transfer(Buff buff, unit to, unit? newCaster, bool resetDuration)
    {
        if (buff.IsRemoved || buff.IsRemoving || buff.IsTransferring) return false;
        if (GetUnitTypeId(to) == 0 || Helper.IsUnitDead(to)) return false;
        if (Helper.IsUnitDummy(to)) return false;

        var target = FindHolder(to);
        if (!target.ownerValid) return false;

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

        var moved = buff.TransferToHolder(target, newCaster, resetDuration);
        if (moved)
        {
            buff.MarkTickFrame(IsTicking ? Frame : -1);
        }
        return moved;
    }

    public int Dispel(unit target, BuffCategory category, BuffPolarity polarity, int maxCount = 1)
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

    public int Clear(unit target, BuffRemoveReason reason)
    {
        var holder = FindHolderOrNull(target);
        return holder?.Clear(reason) ?? 0;
    }

    private void OnUnitDeath(UnitDeathEventData data)
    {
        var holder = FindHolderOrNull(data.u);
        if (holder != null)
        {
            holder.OnOwnerDeath();
        }

        ClearCasterBuffs(data.u);
    }

    private void OnUnitRemoved(UnitRemovedEventData data)
    {
        ClearCasterBuffs(data.u);
    }

    private void ClearCasterBuffs(unit u)
    {
        var units = Const.unitSys.SnapshotUnits();
        foreach (var go in units)
        {
            if (go.isDestroyed || go.isDestroyQueued) continue;

            var holder = go.GetComponent<BuffHolder>();
            if (holder == null) continue;

            foreach (var buff in holder.Snapshot())
            {
                if (buff.IsRemoving || buff.IsRemoved) continue;
                if (buff.Caster != u) continue;
                buff.HandleCasterGone();
            }
        }
    }
}
