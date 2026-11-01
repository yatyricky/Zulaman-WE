using StdLib;
using System;

public class BuffHolder : Component
{
    private StatsComponent? _statsComp;
    private List<Buff> _buffs = [];
    private Dictionary<int, int> _iconRefs = [];
    private bool _destroyed;

    public unit owner { get; private set; } = null!;
    public bool nativeValid { get; private set; } = true;

    internal StatsComponent stats => _statsComp ?? throw new InvalidOperationException("StatsComponent is not bound");
    public int count => _buffs.Count;
    public bool ownerValid => GetUnitTypeId(owner) != 0;

    public override void Awake()
    {
        _statsComp = gameObject.GetComponent<StatsComponent>() ?? throw new System.Exception("unable to find StatsComponent in object");
        owner = _statsComp.owner;
        BuffSystem.Register(this);
    }

    public override void OnDestroy()
    {
        if (_destroyed) return;
        _destroyed = true;
        SetNativeValid(false);
        Clear(BuffRemoveReason.UnitRemoved);
        BuffSystem.Unregister(this);
        _iconRefs = [];
    }

    internal void SetNativeValid(bool valid)
    {
        nativeValid = valid;
    }

    public Buff? Find(string configId)
    {
        foreach (var buff in _buffs)
        {
            if (buff.IsRemoving || buff.IsRemoved) continue;
            if (buff.Config.ID == configId) return buff;
        }
        return null;
    }

    public Buff? FindFirst(BuffCategory category, BuffPolarity polarity)
    {
        foreach (var buff in _buffs)
        {
            if (buff.IsRemoving || buff.IsRemoved) continue;
            if ((category & buff.Config.Category) == 0) continue;
            if ((polarity & buff.Config.Polarity) == 0) continue;
            return buff;
        }
        return null;
    }

    public List<Buff> Snapshot()
    {
        return new List<Buff>(_buffs);
    }

    internal void Tick(int now)
    {
        if (_destroyed || _buffs.Count == 0) return;
        var snapshot = new List<Buff>(_buffs);
        var bs = BuffSystem.Instance ?? throw new Exception("BuffSystem not found in scene");
        foreach (var buff in snapshot)
        {
            if (buff.IsRemoving || buff.IsRemoved) continue;
            if (buff.Holder != this) continue;

            if (buff.LastTickFrame == bs.Frame) continue;

            buff.Tick(now);
        }
    }

    internal void AddBuff(Buff buff)
    {
        if (_destroyed)
        {
            throw new InvalidOperationException("cannot add buff to a destroying BuffHolder");
        }
        _buffs.Add(buff);
    }

    internal void RemoveBuff(Buff buff)
    {
        _buffs.Remove(buff);
    }

    public int Clear(BuffRemoveReason reason)
    {
        var snapshot = new List<Buff>(_buffs);
        var count = 0;
        foreach (var buff in snapshot)
        {
            if (buff.IsRemoved || buff.IsRemoving) continue;
            buff.Remove(reason);
            count += 1;
        }
        return count;
    }

    public int OnOwnerDeath()
    {
        var snapshot = new List<Buff>(_buffs);
        var count = 0;
        foreach (var buff in snapshot)
        {
            if (buff.IsRemoved || buff.IsRemoving) continue;
            if (!buff.Config.RemoveOnDeath) continue;
            buff.Remove(BuffRemoveReason.Death);
            count += 1;
        }
        return count;
    }

    public void AddIcon(int abilityId)
    {
        if (abilityId == 0 || !nativeValid || !ownerValid) return;
        if (!_iconRefs.TryGetValue(abilityId, out var count))
        {
            count = 0;
        }
        _iconRefs[abilityId] = count + 1;
        if (count == 0 && GetUnitAbilityLevel(owner, abilityId) == 0)
        {
            UnitAddAbility(owner, abilityId);
            UnitMakeAbilityPermanent(owner, true, abilityId);
        }
    }

    public void RemoveIcon(int abilityId)
    {
        if (abilityId == 0) return;
        if (!_iconRefs.TryGetValue(abilityId, out var count)) return;
        if (count <= 1)
        {
            _iconRefs.Remove(abilityId);
            if (nativeValid && ownerValid && GetUnitAbilityLevel(owner, abilityId) > 0)
            {
                UnitRemoveAbility(owner, abilityId);
            }
        }
        else
        {
            _iconRefs[abilityId] = count - 1;
        }
    }
}
