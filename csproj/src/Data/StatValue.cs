public class StatValue
{
    private StatType _type;
    private bool _isNumber => _type == StatType.Float || _type == StatType.Int;
    public int intVal = 0;
    public float floatVal = 0f;

    public StatValue(StatType type)
    {
        _type = type;
    }

    public static StatValue operator +(StatValue left, StatValue right)
    {
        if (!left._isNumber || !right._isNumber) throw new System.Exception("left/right must be number");

        var t = left._type == StatType.Int && right._type == StatType.Int ? StatType.Int : StatType.Float;
        return new StatValue(t)
        {
            intVal = left.intVal + right.intVal,
            floatVal = left.floatVal + right.floatVal,
        };
    }

    public static bool operator ==(StatValue left, StatValue right)
    {
        if (left._isNumber && right._isNumber)
        {
            return left.intVal == right.intVal && Math.FuzzyEquals(left.floatVal, right.floatVal);
        }
        throw new System.Exception("Not implemented");
    }

    public static bool operator !=(StatValue left, StatValue right)
    {
        return !(left == right);
    }

    public static implicit operator StatValue(int v)
    {
        return new StatValue(StatType.Int) { intVal = v };
    }

    public static implicit operator StatValue(float v)
    {
        return new StatValue(StatType.Float) { floatVal = v };
    }

    public static implicit operator float(StatValue v)
    {
        return v._type switch
        {
            StatType.Float => v.floatVal,
            StatType.Int => v.intVal,
            _ => throw new System.Exception("cant cast non float/int to float"),
        };
    }

    public static implicit operator int(StatValue v)
    {
        return v._type switch
        {
            StatType.Int => v.intVal,
            StatType.Float => throw new System.Exception("cant implicitly cast float to int"),
            _ => throw new System.Exception("cant cast non float/int to float"),
        };
    }
}
