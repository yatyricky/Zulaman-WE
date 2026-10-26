using SFLib.Interop;
using System;

public class Math
{
    public static bool FuzzyEquals(float a, float b, float epsilon = 0.0001f)
    {
        return math.abs(a - b) <= epsilon;
    }

    public static float Bezier3(float t, float c1, float c2, float c3)
    {
        var t1 = 1 - t;
        return t1 * t1 * c1 + 2 * t1 * t * c2 + t * t * c3;
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

    public static float Lerp(float a, float b, float t)
    {
        return a + (b - a) * Clamp01(t);
    }

    public static float MoveTowards(float current, float target, float maxDelta)
    {
        if (math.abs(target - current) <= maxDelta)
        {
            return target;
        }
        return current + Sign(target - current) * maxDelta;
    }
}