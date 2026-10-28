using SFLib.Interop;
using System;

public class Math
{
    public const float Epsilon = 1e-6f;

    private const float SnapScale = 1000000f;

    public static float PI => math.pi;
    public static float Huge => math.huge;

    private static float Snap(float value)
    {
        return math.floor(value * SnapScale + 0.5f) / SnapScale;
    }

    public static int Abs(int value)
    {
        return value < 0 ? -value : value;
    }

    public static float Abs(float value)
    {
        return math.abs(value);
    }

    public static int Min(int a, int b)
    {
        return math.min(a, b);
    }

    public static float Min(float a, float b)
    {
        return math.min(a, b);
    }

    public static int Max(int a, int b)
    {
        return math.max(a, b);
    }

    public static float Max(float a, float b)
    {
        return math.max(a, b);
    }

    public static float Clamp(float value, float min, float max)
    {
        if (value < min)
        {
            return min;
        }
        else if (value > max)
        {
            return max;
        }
        else
        {
            return value;
        }
    }

    public static int Clamp(int value, int min, int max)
    {
        if (value < min)
        {
            return min;
        }
        else if (value > max)
        {
            return max;
        }
        else
        {
            return value;
        }
    }

    public static float Clamp01(float value)
    {
        return Clamp(value, 0, 1);
    }

    public static int Sign(float value)
    {
        if (value >= 0)
        {
            return 1;
        }
        else
        {
            return -1;
        }
    }

    public static float Floor(float value)
    {
        return math.floor(Snap(value));
    }

    public static float Ceil(float value)
    {
        return math.ceil(Snap(value));
    }

    public static float Round(float value)
    {
        if (value >= 0)
        {
            return math.floor(Snap(value) + 0.5f);
        }
        else
        {
            return math.ceil(Snap(value) - 0.5f);
        }
    }

    public static float Truncate(float value)
    {
        if (value >= 0)
        {
            return math.floor(Snap(value));
        }
        else
        {
            return math.ceil(Snap(value));
        }
    }

    public static int FloorToInt(float value)
    {
        return (int)math.floor(Snap(value));
    }

    public static int CeilToInt(float value)
    {
        return (int)math.ceil(Snap(value));
    }

    public static int RoundToInt(float value)
    {
        if (value >= 0)
        {
            return (int)math.floor(Snap(value) + 0.5f);
        }
        else
        {
            return (int)math.ceil(Snap(value) - 0.5f);
        }
    }

    public static int TruncateToInt(float value)
    {
        if (value >= 0)
        {
            return FloorToInt(value);
        }
        else
        {
            return CeilToInt(value);
        }
    }

    public static float Sqrt(float value)
    {
        return math.sqrt(value);
    }

    public static float Pow(float value, float power)
    {
        return math.pow(value, power);
    }

    public static int PowInt(int value, int power)
    {
        if (power < 0)
        {
            throw new Exception("power must be non-negative");
        }

        var result = 1;
        var i = 0;
        while (i < power)
        {
            result *= value;
            i += 1;
        }
        return result;
    }

    public static float Sin(float value)
    {
        return math.sin(value);
    }

    public static float Cos(float value)
    {
        return math.cos(value);
    }

    public static float Tan(float value)
    {
        return math.tan(value);
    }

    public static float Asin(float value)
    {
        return math.asin(value);
    }

    public static float Acos(float value)
    {
        return math.acos(value);
    }

    public static float Atan(float value)
    {
        return math.atan(value);
    }

    public static float Atan2(float y, float x)
    {
        return math.atan(y, x);
    }

    public static float Log(float value)
    {
        return math.log(value);
    }

    public static float Log(float value, float logBase)
    {
        return math.log(value, logBase);
    }

    public static float Exp(float value)
    {
        return math.exp(value);
    }

    public static float FMod(float x, float y)
    {
        return math.fmod(x, y);
    }

    public static int ModInt(int a, int b)
    {
        if (b == 0)
        {
            throw new Exception("division by zero");
        }
        return a - TruncateToInt((float)a / b) * b;
    }

    public static float DegToRad(float degrees)
    {
        return math.rad(degrees);
    }

    public static float RadToDeg(float radians)
    {
        return math.deg(radians);
    }

    public static int RandomInt(int min, int max)
    {
        return GetRandomInt(min, max);
    }

    public static float RandomReal(float min, float max)
    {
        return GetRandomReal(min, max);
    }

    public static bool FuzzyEquals(float a, float b, float epsilon = 0.0001f)
    {
        return Abs(a - b) <= epsilon;
    }

    public static float Bezier3(float t, float c1, float c2, float c3)
    {
        var t1 = 1 - t;
        return t1 * t1 * c1 + 2 * t1 * t * c2 + t * t * c3;
    }

    public static float Lerp(float a, float b, float t)
    {
        return a + (b - a) * Clamp01(t);
    }

    public static float MoveTowards(float current, float target, float maxDelta)
    {
        if (Abs(target - current) <= maxDelta)
        {
            return target;
        }
        return current + Sign(target - current) * maxDelta;
    }
}
