using StdLib;
using System;

public class SpellEventData
{
    public bool effectDone = false;
    public int AbilityId;
    public unit CastingUnit = null!;
    public unit TargetUnit = null!;
    public item TargetItem = null!;
    public destructable TargetDestructable = null!;
    public float TargetX = 0f;
    public float TargetY = 0f;
    public bool CastFinished = false;

    public SpellEventData interrupt = null!;
}

public class SpellEventBase : EventBase<SpellEventData>
{
    private Dictionary<int, Action<SpellEventData>> _spellCalls = new();

    protected void ResponseCall(int abilityId, SpellEventData data)
    {
        _spellCalls.TryGetValue(abilityId, out var call);
        call?.Invoke(data);
    }

    public void Register(int abilityId, Action<SpellEventData> callback)
    {
        _spellCalls[abilityId] = callback;
    }

    public void Unregister(int abilityId)
    {
        _spellCalls.Remove(abilityId);
    }
}

public class SpellChannelEvent : SpellEventBase
{
    public static SpellChannelEvent _instance { get; private set; } = null!;

    public static SpellChannelEvent Instance
    {
        get
        {
            _instance ??= new SpellChannelEvent();
            return _instance;
        }
    }

    public Dictionary<unit, SpellEventData> casterTable = new();

    private SpellChannelEvent()
    {
        var t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_CHANNEL);
        TriggerAddAction(t, () =>
        {
            // init
            var s = new SpellEventData
            {
                AbilityId = GetSpellAbilityId(),
                CastingUnit = GetTriggerUnit(),
                TargetUnit = GetSpellTargetUnit(),
            };
            if (s.TargetUnit != null)
            {
                s.TargetX = GetUnitX(s.TargetUnit);
                s.TargetY = GetUnitY(s.TargetUnit);
            }
            else
            {
                s.TargetDestructable = GetSpellTargetDestructable();
                if (s.TargetDestructable != null)
                {
                    s.TargetX = GetDestructableX(s.TargetDestructable);
                    s.TargetY = GetDestructableY(s.TargetDestructable);
                }
                else
                {
                    s.TargetItem = GetSpellTargetItem();
                    if (s.TargetItem != null)
                    {
                        s.TargetX = GetItemX(s.TargetItem);
                        s.TargetY = GetItemY(s.TargetItem);
                    }
                    else
                    {
                        s.TargetX = GetSpellTargetX();
                        s.TargetY = GetSpellTargetY();
                    }
                }
            }
            casterTable.TryGetValue(s.CastingUnit, out var val);
            s.interrupt = val;
            casterTable[s.CastingUnit] = s;

            // invoke
            ResponseCall(s);
            ResponseCall(s.AbilityId, s);
        });
    }
}

public class SpellCastEvent : SpellEventBase
{
    public static SpellCastEvent _instance { get; private set; } = null!;

    public static SpellCastEvent Instance
    {
        get
        {
            _instance ??= new SpellCastEvent();
            return _instance;
        }
    }

    private SpellCastEvent()
    {
        var t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_CAST);
        TriggerAddAction(t, () =>
        {
            // retrieve
            var s = SpellChannelEvent.Instance.casterTable[GetTriggerUnit()];

            // invoke
            ResponseCall(s);
            ResponseCall(s.AbilityId, s);
        });
    }
}

public class SpellEffectEvent : SpellEventBase
{
    public static SpellEffectEvent _instance { get; private set; } = null!;

    public static SpellEffectEvent Instance
    {
        get
        {
            _instance ??= new SpellEffectEvent();
            return _instance;
        }
    }

    private SpellEffectEvent()
    {
        var t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT);
        TriggerAddAction(t, () =>
        {
            // retrieve
            var s = SpellChannelEvent.Instance.casterTable[GetTriggerUnit()];
            if (!s.effectDone)
            {
                s.effectDone = true;
                // invoke
                ResponseCall(s);
                ResponseCall(s.AbilityId, s);
            }
        });
    }
}

public class SpellFinishEvent : SpellEventBase
{
    public static SpellFinishEvent _instance { get; private set; } = null!;

    public static SpellFinishEvent Instance
    {
        get
        {
            _instance ??= new SpellFinishEvent();
            return _instance;
        }
    }

    private SpellFinishEvent()
    {
        var t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_FINISH);
        TriggerAddAction(t, () =>
        {
            // retrieve
            var s = SpellChannelEvent.Instance.casterTable[GetTriggerUnit()];
            s.CastFinished = true;

            // invoke
            ResponseCall(s);
            ResponseCall(s.AbilityId, s);
        });
    }
}

public class SpellEndCastEvent : SpellEventBase
{
    public static SpellEndCastEvent _instance { get; private set; } = null!;

    public static SpellEndCastEvent Instance
    {
        get
        {
            _instance ??= new SpellEndCastEvent();
            return _instance;
        }
    }

    private SpellEndCastEvent()
    {
        var t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_ENDCAST);
        TriggerAddAction(t, () =>
        {
            // retrieve
            var s = SpellChannelEvent.Instance.casterTable[GetTriggerUnit()];

            // invoke
            ResponseCall(s);
            ResponseCall(s.AbilityId, s);

            // destroy
            if (s.interrupt == null)
            {
                SpellChannelEvent.Instance.casterTable.Remove(s.CastingUnit);
            }
            else
            {
                SpellChannelEvent.Instance.casterTable[s.CastingUnit] = s.interrupt;
            }
            s.CastingUnit = null!;
        });
    }
}
