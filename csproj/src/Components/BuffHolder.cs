using StdLib;
using System;

public class BuffHolder : Component
{
    private UnitEntity _entity = null!;
    private List<Buff> _buffs = [];
    private Dictionary<int, int> _iconRefs = [];

    public unit owner => _entity.owner;
    public int count => _buffs.Count;
    public bool ownerValid => GetUnitTypeId(owner) != 0;

    public override void Awake()
    {
        _entity = gameObject.GetComponent<UnitEntity>() ?? throw new Exception("BuffHolder requires UnitEntity");
    }

    public override void OnDestroy()
    {
        Clear(BuffRemoveReason.UnitRemoved);
        _iconRefs = [];
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

    internal void Tick(int now, int frame)
    {
        if (_buffs.Count == 0) return;
        var snapshot = new List<Buff>(_buffs);
        foreach (var buff in snapshot)
        {
            if (buff.IsRemoving || buff.IsRemoved) continue;
            if (buff.Holder != this) continue;
            if (buff.LastTickFrame == frame) continue;
            buff.Tick(now, frame);
        }
    }

    internal void AddBuff(Buff buff)
    {
        if (gameObject.isDestroyQueued || gameObject.isDestroyed)
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
        if (abilityId == 0 || !ownerValid) return;
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
            if (ownerValid && GetUnitAbilityLevel(owner, abilityId) > 0)
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
