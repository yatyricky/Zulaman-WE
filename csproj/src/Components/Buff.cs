using System;
using StdLib;

public class Buff
{
    public BuffConfigEntry Config { get; private set;} = null!;
    public BuffHolder Holder { get; private set;} = null!;
    public unit Owner { get; private set;} = null!;
    public unit Caster { get; private set;} = null!;
    public int Stacks { get; private set;} = 1;
    public int Duration { get; private set;} = -1;
    public int Interval { get; private set;} = 0;
    public int ExpireAt { get; private set;} = -1;
    public int NextTickAt { get; private set;} = -1;
    public bool Paused { get; private set;} = false;
    public bool IsRemoving { get; private set;} = false;
    public bool IsRemoved { get; private set;} = false;
    public bool IsTransferring { get; private set;} = false;
    public int LastTickFrame { get; private set;} = -1;

    private bool _appliedOnce;
    private int _pausedRemaining = -1;
    private int _pausedTick = -1;
    private List<effect> _effects = new List<effect>();
    private Dictionary<StatId, StatValue> _appliedStats = new Dictionary<StatId, StatValue>();

    internal void Init(BuffConfigEntry config, BuffHolder holder, unit caster, int duration, int stacks)
    {
        Config = config;
        Holder = holder;
        Owner = holder.Owner;
        Caster = caster == null ? Owner : caster;
        Stacks = Math.Clamp(stacks, 1, config.MaxStacks);
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
        ApplyStats();
        OnAttach();
        if (!_appliedOnce && !IsRemoving && !IsRemoved)
        {
            _appliedOnce = true;
            OnApply();
        }
        LastTickFrame = BuffSystem.IsTicking ? BuffSystem.Frame : -1;
    }

    private void Detach(BuffDetachReason reason)
    {
        OnDetach(reason);
        RemoveStats();
        DestroyEffects();
        RemoveNativeIcon();
        Holder.RemoveBuff(this);
    }

    public void Remove(BuffRemoveReason reason = BuffRemoveReason.Manual)
    {
        if (IsRemoving || IsRemoved) return;
        IsRemoving = true;
        var holder = Holder;
        if (holder != null)
        {
            Detach(BuffDetachReason.Removed);
        }
        IsRemoved = true;
        OnRemove(reason);
        Holder = null!;
        IsRemoving = false;
    }

    internal bool TransferToHolder(BuffHolder target, unit newCaster, bool resetDuration)
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

        RemoveStats();
        DestroyEffects();
        RemoveNativeIcon();
        old.RemoveBuff(this);

        Holder = target;
        Owner = target.Owner;
        if (newCaster != null) Caster = newCaster;
        Holder.AddBuff(this);
        ApplyNativeIcon();
        CreateEffects();
        ApplyStats();
        OnAttach();
        if (resetDuration)
        {
            Refresh();
        }
        if (!IsRemoving && !IsRemoved)
        {
            OnTransfer(old);
        }
        LastTickFrame = BuffSystem.IsTicking ? BuffSystem.Frame : -1;
        IsTransferring = false;
        return !IsRemoved;
    }

    public void Tick(int now)
    {
        if (Paused || IsRemoving || IsRemoved) return;
        LastTickFrame = BuffSystem.Frame;

        var guard = 0;
        while (Interval > 0 && NextTickAt >= 0 && now >= NextTickAt && guard < BuffSystem.MaxTicksPerFrame)
        {
            guard += 1;
            var intervalAtStart = Interval;
            var holderAtStart = Holder;
            NextTickAt += Interval;
            ExecTickEffects();
            if (IsRemoving || IsRemoved) return;
            OnTick();
            if (IsRemoving || IsRemoved || Paused) return;
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
        if (Owner == null || GetUnitTypeId(Owner) == 0) return;
        if (Caster == null || GetUnitTypeId(Caster) == 0) return;

        var pipeline = new Pipeline
        {
            SpellCtx = new SpellEventContext
            {
                CastingUnit = Caster,
                TargetUnit = Owner,
            }
        };
        pipeline.SpellCtx.RTTargets.Add(Owner);

        foreach (var effectId in Config.TickEffectIds)
        {
            InvokeEffect.Exec(EffectConfig.FindByID(effectId), pipeline, Owner);
            if (IsRemoving || IsRemoved) return;
        }
    }

    public void Merge(unit caster, int duration, int stacks)
    {
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
            SetStacks(Stacks + Math.Max(1, stacks));
        }
        Refresh(!hasOverride, Config.RefreshResetsTickPhase);
    }

    public void MergeFrom(Buff other, unit newCaster)
    {
        if (newCaster != null)
        {
            Caster = newCaster;
        }
        else if (other.Caster != null)
        {
            Caster = other.Caster;
        }
        SetStacks(Stacks + other.Stacks);
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
        var clamped = Math.Clamp(stacks, 1, Config.MaxStacks);
        if (clamped == Stacks) return;
        var old = Stacks;
        Stacks = clamped;
        RemoveStats();
        ApplyStats();
        OnStackChanged(old, Stacks);
    }

    public void AddStack(int stacks = 1)
    {
        SetStacks(Stacks + stacks);
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

    public void SetCaster(unit caster)
    {
        Caster = caster == null ? Owner : caster;
    }

    public int RemainingMs()
    {
        if (Duration < 0 || ExpireAt < 0) return -1;
        if (Paused) return _pausedRemaining;
        return Math.Max(0, ExpireAt - GameTime.NowMs());
    }

    public int NextTickInMs()
    {
        if (Interval <= 0 || NextTickAt < 0) return -1;
        if (Paused) return _pausedTick;
        return Math.Max(0, NextTickAt - GameTime.NowMs());
    }

    private int FirstTickDelay()
    {
        if (Interval <= 0) return -1;
        return Config.FirstTickDelay >= 0 ? Config.FirstTickDelay : Interval;
    }

    private void ApplyStats()
    {
        if (Config.StatModsPerStack.Count == 0) return;
        if (!Holder.NativeValid || !Holder.Stats.HasStats()) return;

        var mods = new Dictionary<StatId, StatValue>();
        foreach (var (statId, value) in Config.StatModsPerStack)
        {
            mods[statId] = value.Scale(Stacks);
        }
        Holder.Stats.ModStats(mods);
        _appliedStats = mods;
    }

    private void RemoveStats()
    {
        if (_appliedStats.Count == 0) return;
        if (!Holder.NativeValid || !Holder.Stats.HasStats())
        {
            _appliedStats = new Dictionary<StatId, StatValue>();
            return;
        }

        var mods = new Dictionary<StatId, StatValue>();
        foreach (var (statId, value) in _appliedStats)
        {
            mods[statId] = value.Scale(-1);
        }
        Holder.Stats.ModStats(mods);
        _appliedStats = new Dictionary<StatId, StatValue>();
    }

    private void ApplyNativeIcon()
    {
        // todo
    }

    private void RemoveNativeIcon()
    {
        // todo
    }

    private void CreateEffects()
    {
        if (!Holder.OwnerValid) return;
        foreach (var effectDef in Config.Effects)
        {
            if (effectDef.Path == "") continue;
            _effects.Add(AddSpecialEffectTarget(effectDef.Path, Owner, effectDef.AttachPoint));
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

    public virtual void OnCasterDied()
    {
        if (Config.RemoveOnCasterDeath)
        {
            Remove(BuffRemoveReason.CasterDeath);
        }
        else
        {
            Caster = null!;
        }
    }
}
