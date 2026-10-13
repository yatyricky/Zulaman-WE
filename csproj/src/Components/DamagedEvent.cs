using System;
using StdLib;

public class DamagedEvent : Component
{
    public struct NativeDamageData
    {
        public float damage;
        public unit damageSource;
        public unit damageTarget;
        public bool isAttack;
        public damagetype damageType;
    }

    public static DamagedEvent Instance { get; private set; } = null!;
    private List<Action<NativeDamageData>> _callbacks = new();

    public override void Awake()
    {
        Instance = this;

        var trigger = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_DAMAGING);
        TriggerAddCondition(trigger, Condition(() =>
        {
            var damage = GetEventDamage();
            var damageSource = GetEventDamageSource();
            var damageTarget = BlzGetEventDamageTarget();
            var isAttack = BlzGetEventIsAttack();
            var damageType = BlzGetEventDamageType();

            foreach (var callback in _callbacks)
            {
                callback(new NativeDamageData
                {
                    damage = damage,
                    damageSource = damageSource,
                    damageTarget = damageTarget,
                    isAttack = isAttack,
                    damageType = damageType,
                });
            }
            return false;
        }));
    }

    public void Register(Action<NativeDamageData> callback)
    {
        if (_callbacks.IndexOf(callback) == -1)
        {
            _callbacks.Add(callback);
        }
    }

    public void Unregister(Action<NativeDamageData> callback)
    {
        _callbacks.Remove(callback);
    }
}