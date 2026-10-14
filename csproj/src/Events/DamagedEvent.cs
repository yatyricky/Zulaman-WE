public struct DamagedEventData
{
    public float damage;
    public unit damageSource;
    public unit damageTarget;
    public bool isAttack;
    public damagetype damageType;
}

public class DamagedEvent : EventBase<DamagedEventData>
{
    public static DamagedEvent _instance { get; private set; } = null!;

    public static DamagedEvent Instance
    {
        get
        {
            _instance ??= new DamagedEvent();
            return _instance;
        }
    }

    public DamagedEvent()
    {
        var trigger = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_DAMAGING);
        TriggerAddAction(trigger, () =>
        {
            var data = new DamagedEventData
            {
                damage = GetEventDamage(),
                damageSource = GetEventDamageSource(),
                damageTarget = BlzGetEventDamageTarget(),
                isAttack = BlzGetEventIsAttack(),
                damageType = BlzGetEventDamageType(),
            };

            ResponseCall(data);
        });
    }
}
