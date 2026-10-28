using StdLib;

public class BuffHolder : Component
{
    private StatsComponent _statsComp = null!;
    private List<Buff> _buffs = new List<Buff>();
    private Dictionary<int, int> _iconRefs = new Dictionary<int, int>();
    private bool _destroyed;

    public unit Owner = null!;
    public bool NativeValid = true;

    public StatsComponent Stats => _statsComp;
    public int Count => _buffs.Count;
    public bool OwnerValid => Owner != null && GetUnitTypeId(Owner) != 0;

    public override void Awake()
    {
        _statsComp = gameObject.GetComponent<StatsComponent>() ?? throw new System.Exception("unable to find StatsComponent in object");
        Owner = _statsComp.owner;
        BuffSystem.Register(this);
    }

    public override void OnDestroy()
    {
        _destroyed = true;
        NativeValid = false;
        BuffSystem.Unregister(this);
        Clear(BuffRemoveReason.UnitRemoved);
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
            if (category != BuffCategory.Any && buff.Config.Category != category) continue;
            if (polarity != BuffPolarity.Any && buff.Config.Polarity != polarity) continue;
            return buff;
        }
        return null;
    }

    public List<Buff> Snapshot()
    {
        return new List<Buff>(_buffs);
    }

    public void Tick(int now)
    {
        if (_destroyed || _buffs.Count == 0) return;
        var snapshot = new List<Buff>(_buffs);
        foreach (var buff in snapshot)
        {
            if (buff.IsRemoving || buff.IsRemoved) continue;
            if (buff.Holder != this) continue;
            if (buff.LastTickFrame == BuffSystem.Frame) continue;
            buff.Tick(now);
        }
    }

    internal void AddBuff(Buff buff)
    {
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
        if (abilityId == 0 || !NativeValid || !OwnerValid) return;
        if (!_iconRefs.TryGetValue(abilityId, out var count))
        {
            count = 0;
        }
        _iconRefs[abilityId] = count + 1;
        if (count == 0 && GetUnitAbilityLevel(Owner, abilityId) == 0)
        {
            UnitAddAbility(Owner, abilityId);
            UnitMakeAbilityPermanent(Owner, true, abilityId);
        }
    }

    public void RemoveIcon(int abilityId)
    {
        if (abilityId == 0) return;
        if (!_iconRefs.TryGetValue(abilityId, out var count)) return;
        if (count <= 1)
        {
            _iconRefs.Remove(abilityId);
            if (NativeValid && OwnerValid && GetUnitAbilityLevel(Owner, abilityId) > 0)
            {
                UnitRemoveAbility(Owner, abilityId);
            }
        }
        else
        {
            _iconRefs[abilityId] = count - 1;
        }
    }
}
