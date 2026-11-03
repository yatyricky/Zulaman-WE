using System;
using StdLib;

public class Buff
{
    public BuffConfigEntry Config { get; private set;} = null!;
    public BuffHolder Holder { get; private set;} = null!;
    public unit Owner => Holder.owner;
    public unit? Caster { get; private set;} = null;
    public int Stacks { get; private set;} = 1;
    public int Duration { get; private set;} = -1;
    public int Interval { get; private set;} = 0;
    public int ExpireAt { get; private set;} = -1;
    public int NextTickAt { get; private set;} = -1;
    public bool Paused { get; private set;} = false;
    public bool IsRemoving { get; private set;} = false;
    public bool IsRemoved { get; private set;} = false;
    public bool IsTransferring { get; private set;} = false;
    internal int LastTickFrame { get; private set;} = -1;

    private bool _appliedOnce;
    private int _pausedRemaining = -1;
    private int _pausedTick = -1;
    private List<effect> _effects = [];
    private Dictionary<StatId, StatValue> _appliedStats = [];

    internal void Init(BuffConfigEntry config, BuffHolder holder, unit? caster, int duration, int stacks)
    {
        if (stacks < 1 || stacks > config.MaxStacks)
        {
            throw new Exception($"buff {config.ID} stacks out of range: {stacks} (max {config.MaxStacks})");
        }

        Config = config;
        Holder = holder;
        Caster = caster ?? holder.owner;
        Stacks = stacks;
        Duration = duration < 0 ? config.Duration : duration;
        Interval = config.Interval;

        var now = GameTime.NowMs();
        ExpireAt = Duration < 0 ? -1 : now + Duration;
        var first = FirstTickDelay();
        NextTickAt = first < 0 ? -1 : now + first;
        LastTickFrame = -1;
    }

    internal void Attach()
    {
        Holder.AddBuff(this);
        ApplyNativeIcon();
        CreateEffects();
        SyncStats();
        OnAttach();
        if (!_appliedOnce && !IsRemoving && !IsRemoved)
        {
            _appliedOnce = true;
            OnApply();
        }
    }

    private void Detach(BuffDetachReason reason)
    {
        OnDetach(reason);
        RemoveAppliedStats();
        DestroyEffects();
        RemoveNativeIcon();
        Holder.RemoveBuff(this);
    }

    public void Remove(BuffRemoveReason reason = BuffRemoveReason.Manual)
    {
        if (IsRemoving || IsRemoved) return;
        IsRemoving = true;
        Detach(BuffDetachReason.Removed);
        IsRemoved = true;
        OnRemove(reason);
        Caster = null;
        IsRemoving = false;
    }

    internal bool TransferToHolder(BuffHolder target, unit? newCaster, bool resetDuration)
    {
        if (IsRemoving || IsRemoved || IsTransferring) return false;
        if (Holder == target)
        {
            if (newCaster != null) Caster = newCaster;
            if (resetDuration) Refresh();
            return true;
        }

        IsTransferring = true;
        var old = Holder;
        OnDetach(BuffDetachReason.Transferred);
        if (IsRemoving || IsRemoved)
        {
            IsTransferring = false;
            return false;
        }

        RemoveAppliedStats();
        DestroyEffects();
        RemoveNativeIcon();
        old.RemoveBuff(this);

        Holder = target;
        if (newCaster != null) Caster = newCaster;
        Holder.AddBuff(this);
        ApplyNativeIcon();
        CreateEffects();
        SyncStats();
        OnAttach();
        if (resetDuration)
        {
            Refresh();
        }
        if (!IsRemoving && !IsRemoved)
        {
            OnTransfer(old);
        }

        IsTransferring = false;
        return !IsRemoved;
    }

    internal void MarkTickFrame(int frame)
    {
        LastTickFrame = frame;
    }

    internal void Tick(int now, int frame)
    {
        if (Paused || IsRemoving || IsRemoved) return;
        if (GetUnitTypeId(Owner) == 0)
        {
            Remove(BuffRemoveReason.UnitRemoved);
            return;
        }

        LastTickFrame = frame;
        var ownerDead = Helper.IsUnitDead(Owner);

        var guard = 0;
        while (Interval > 0 && NextTickAt >= 0 && now >= NextTickAt && guard < BuffSystem.MaxTicksPerFrame)
        {
            guard += 1;
            var intervalAtStart = Interval;
            var holderAtStart = Holder;
            NextTickAt += Interval;
            if (!ownerDead)
            {
                ExecTickEffects();
                if (IsRemoving || IsRemoved) return;
                if (Paused) return;
                OnTick();
                if (IsRemoving || IsRemoved || Paused) return;
            }
            if (Holder != holderAtStart) return;
            if (Interval != intervalAtStart)
            {
                if (Interval <= 0)
                {
                    NextTickAt = -1;
                }
                else
                {
                    NextTickAt = now + Interval;
                }
                break;
            }
        }

        if (guard >= BuffSystem.MaxTicksPerFrame && Interval > 0)
        {
            NextTickAt = now + Interval;
        }

        if (Duration >= 0 && ExpireAt >= 0 && now >= ExpireAt)
        {
            Remove(BuffRemoveReason.Expired);
        }
    }

    private void ExecTickEffects()
    {
        if (Config.TickEffectIds.Count == 0) return;
        if (GetUnitTypeId(Owner) == 0) return;
        if (Helper.IsUnitDead(Owner)) return;
        if (Caster == null || GetUnitTypeId(Caster) == 0) return;
        if (Helper.IsUnitDead(Caster)) return;

        var pipeline = new Pipeline
        {
            SpellCtx = new SpellEventContext
            {
                CastingUnit = Caster,
                TargetUnit = Owner,
                TargetX = GetUnitX(Owner),
                TargetY = GetUnitY(Owner),
            }
        };
        pipeline.SpellCtx.RTTargets.Add(Owner);

        foreach (var effectId in Config.TickEffectIds)
        {
            InvokeEffect.Exec(EffectConfig.FindByID(effectId), pipeline, Owner);
            if (IsRemoving || IsRemoved) return;
        }
    }

    internal void Merge(unit? caster, int duration, int stacks)
    {
        if (duration < -1) throw new Exception($"invalid buff duration override: {duration}");
        if (stacks < 1) throw new Exception($"invalid buff stacks: {stacks}");
        if (caster != null) Caster = caster;

        var hasOverride = duration >= 0;
        if (hasOverride)
        {
            Duration = duration;
            if (Paused)
            {
                _pausedRemaining = duration;
            }
            else
            {
                ExpireAt = GameTime.NowMs() + duration;
            }
        }
        if (Config.StackMode == BuffStackMode.AddStack)
        {
            AddStack(stacks);
        }
        Refresh(!hasOverride, Config.RefreshResetsTickPhase);
    }

    internal void MergeFrom(Buff other, unit? newCaster)
    {
        if (newCaster != null)
        {
            Caster = newCaster;
        }
        else if (other.Caster != null)
        {
            Caster = other.Caster;
        }

        // Detach the source stats before applying the merged stack count so the
        // target never observes both contributions at the same time.
        other.RemoveAppliedStats();
        var combined = Math.Min(Stacks + other.Stacks, Config.MaxStacks);
        SetStacks(combined);
        Refresh(true, Config.RefreshResetsTickPhase);
    }

    public void Refresh(bool resetDuration = true, bool resetTickPhase = false)
    {
        if (IsRemoving || IsRemoved) return;

        if (Paused)
        {
            if (resetDuration)
            {
                if (Config.RefreshMode == BuffRefreshMode.ResetDuration)
                {
                    _pausedRemaining = Duration < 0 ? -1 : Duration;
                }
                else if (Config.RefreshMode == BuffRefreshMode.AddDuration && Duration >= 0 && _pausedRemaining >= 0)
                {
                    _pausedRemaining += Duration;
                }
            }
            if (resetTickPhase)
            {
                var first = FirstTickDelay();
                _pausedTick = first < 0 ? -1 : first;
            }
            OnRefresh();
            return;
        }

        var now = GameTime.NowMs();
        if (resetDuration)
        {
            if (Config.RefreshMode == BuffRefreshMode.ResetDuration)
            {
                ExpireAt = Duration < 0 ? -1 : now + Duration;
            }
            else if (Config.RefreshMode == BuffRefreshMode.AddDuration && Duration >= 0 && ExpireAt >= 0)
            {
                ExpireAt += Duration;
            }
        }
        if (resetTickPhase)
        {
            var first = FirstTickDelay();
            NextTickAt = first < 0 ? -1 : now + first;
        }
        OnRefresh();
    }

    public void SetDuration(int duration)
    {
        if (IsRemoving || IsRemoved) return;
        if (duration < -1) throw new Exception($"invalid buff duration: {duration}");
        Duration = duration;
        if (Paused)
        {
            _pausedRemaining = duration < 0 ? -1 : duration;
            return;
        }
        ExpireAt = duration < 0 ? -1 : GameTime.NowMs() + duration;
    }

    public void SetRemaining(int remaining)
    {
        if (IsRemoving || IsRemoved) return;
        if (remaining < -1) throw new Exception($"invalid buff remaining time: {remaining}");
        if (Paused)
        {
            _pausedRemaining = remaining < 0 ? -1 : remaining;
            return;
        }
        ExpireAt = remaining < 0 ? -1 : GameTime.NowMs() + remaining;
    }

    public void AddDuration(int delta)
    {
        if (IsRemoving || IsRemoved || Duration < 0) return;
        if (Paused)
        {
            if (_pausedRemaining >= 0)
            {
                _pausedRemaining = Math.Max(0, _pausedRemaining + delta);
            }
            return;
        }
        if (ExpireAt < 0) return;
        var now = GameTime.NowMs();
        ExpireAt = Math.Max(now, ExpireAt + delta);
    }

    public void SetInterval(int interval, bool resetPhase = true)
    {
        if (IsRemoving || IsRemoved) return;
        if (interval < 0) throw new Exception("interval must be non-negative");
        Interval = interval;
        var now = GameTime.NowMs();
        if (Paused)
        {
            if (interval <= 0)
            {
                _pausedTick = -1;
            }
            else if (resetPhase || _pausedTick < 0)
            {
                _pausedTick = interval;
            }
            else
            {
                _pausedTick = Math.Min(_pausedTick, interval);
            }
            return;
        }
        if (interval <= 0)
        {
            NextTickAt = -1;
            return;
        }
        if (resetPhase)
        {
            NextTickAt = now + interval;
        }
        else if (NextTickAt < 0 || NextTickAt - now > interval)
        {
            NextTickAt = now + interval;
        }
    }

    public void SetNextTickIn(int delay)
    {
        if (IsRemoving || IsRemoved) return;
        if (delay < -1) throw new Exception($"invalid buff tick delay: {delay}");
        if (Paused)
        {
            _pausedTick = delay < 0 ? -1 : delay;
            return;
        }
        NextTickAt = delay < 0 ? -1 : GameTime.NowMs() + delay;
    }

    public void SetStacks(int stacks)
    {
        if (IsRemoving || IsRemoved) return;
        if (stacks < 1 || stacks > Config.MaxStacks)
        {
            throw new Exception($"buff {Config.ID} stacks out of range: {stacks} (max {Config.MaxStacks})");
        }
        if (stacks == Stacks) return;
        var old = Stacks;
        Stacks = stacks;
        SyncStats();
        OnStackChanged(old, Stacks);
    }

    public void AddStack(int stacks = 1)
    {
        if (IsRemoving || IsRemoved) return;
        if (stacks < 1) throw new Exception($"invalid buff stack amount: {stacks}");
        SetStacks(Math.Min(Stacks + stacks, Config.MaxStacks));
    }

    public void Pause()
    {
        if (Paused || IsRemoving || IsRemoved) return;
        var now = GameTime.NowMs();
        _pausedRemaining = ExpireAt < 0 ? -1 : Math.Max(0, ExpireAt - now);
        _pausedTick = NextTickAt < 0 ? -1 : Math.Max(0, NextTickAt - now);
        Paused = true;
    }

    public void Resume()
    {
        if (!Paused || IsRemoving || IsRemoved) return;
        var now = GameTime.NowMs();
        ExpireAt = _pausedRemaining < 0 ? -1 : now + _pausedRemaining;
        if (Interval <= 0)
        {
            NextTickAt = -1;
        }
        else
        {
            NextTickAt = now + (_pausedTick < 0 ? Interval : _pausedTick);
        }
        Paused = false;
    }

    public void SetCaster(unit? caster)
    {
        if (IsRemoving || IsRemoved) return;
        Caster = caster ?? Owner;
    }

    public int RemainingMs()
    {
        if (IsRemoved || Duration < 0 || ExpireAt < 0) return -1;
        if (Paused) return _pausedRemaining;
        return Math.Max(0, ExpireAt - GameTime.NowMs());
    }

    public int NextTickInMs()
    {
        if (IsRemoved || Interval <= 0 || NextTickAt < 0) return -1;
        if (Paused) return _pausedTick;
        return Math.Max(0, NextTickAt - GameTime.NowMs());
    }

    private int FirstTickDelay()
    {
        if (Interval <= 0) return -1;
        return Config.FirstTickDelay >= 0 ? Config.FirstTickDelay : Interval;
    }

    private Dictionary<StatId, StatValue> CollectStats()
    {
        var mods = new Dictionary<StatId, StatValue>();
        foreach (var (statId, value) in Config.StatModsPerStack)
        {
            mods[statId] = value * Stacks;
        }
        return mods;
    }

    /// <summary>
    /// Applies the difference between the currently configured mods and the
    /// already-applied mods. A single delta avoids temporarily removing a max-HP
    /// buff (which would clamp the owner's current HP) before re-adding it.
    /// </summary>
    private bool HolderGone => !Holder.ownerValid || Holder.gameObject.isDestroyQueued || Holder.gameObject.isDestroyed;

    private void SyncStats()
    {
        var next = CollectStats();
        if (HolderGone)
        {
            _appliedStats = [];
            return;
        }

        var delta = new Dictionary<StatId, StatValue>();
        foreach (var (statId, value) in next)
        {
            if (_appliedStats.TryGetValue(statId, out var old))
            {
                delta[statId] = value - old;
            }
            else
            {
                delta[statId] = value;
            }
        }
        foreach (var (statId, value) in _appliedStats)
        {
            if (!next.ContainsKey(statId))
            {
                delta[statId] = value * -1;
            }
        }

        if (delta.Count > 0)
        {
            var stats = Const.unitSys.GetUnit(Owner)?.GetComponent<StatsComponent>()
                ?? throw new Exception("StatsComponent not found for buff owner");
            stats.ModStats(delta);
        }
        _appliedStats = next;
    }

    internal void RemoveAppliedStats()
    {
        if (_appliedStats.Count == 0) return;
        if (HolderGone)
        {
            _appliedStats = [];
            return;
        }

        var stats = Const.unitSys.GetUnit(Owner)?.GetComponent<StatsComponent>()
            ?? throw new Exception("StatsComponent not found for buff owner");

        var mods = new Dictionary<StatId, StatValue>();
        foreach (var (statId, value) in _appliedStats)
        {
            mods[statId] = value * -1;
        }
        stats.ModStats(mods);
        _appliedStats = [];
    }

    private void ApplyNativeIcon()
    {
        // Icon UI will be rendered with FDF in the future; keep this as a no-op for now.
    }

    private void RemoveNativeIcon()
    {
        // Icon UI will be rendered with FDF in the future; keep this as a no-op for now.
    }

    private void CreateEffects()
    {
        if (!Holder.ownerValid) return;
        foreach (var config in Config.Effects)
        {
            if (config.Path == "") continue;
            var eff = AddSpecialEffectTarget(config.Path, Owner, config.AttachPoint);
            if (eff != null)
            {
                _effects.Add(eff);
            }
        }
    }

    private void DestroyEffects()
    {
        foreach (var eff in _effects)
        {
            if (eff != null) DestroyEffect(eff);
        }
        _effects.Clear();
    }

    public virtual void OnAttach()
    {
    }

    public virtual void OnApply()
    {
    }

    public virtual void OnTick()
    {
    }

    public virtual void OnStackChanged(int oldStacks, int newStacks)
    {
    }

    public virtual void OnRefresh()
    {
    }

    public virtual void OnDetach(BuffDetachReason reason)
    {
    }

    public virtual void OnRemove(BuffRemoveReason reason)
    {
    }

    public virtual void OnTransfer(BuffHolder from)
    {
    }

    internal void HandleCasterGone()
    {
        if (IsRemoving || IsRemoved) return;
        if (Config.RemoveOnCasterDeath)
        {
            Remove(BuffRemoveReason.CasterDeath);
            return;
        }

        Caster = null;
        OnCasterLost();
    }

    public virtual void OnCasterLost()
    {
    }
}
