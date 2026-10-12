using SFLib.Interop;

public enum UnitVec3Mode
{
    ForceFlying,
    ForceGround,
    /// <summary>
    /// Flying units fly, ground units grounded.
    /// </summary>
    Auto,
}

public struct Vector3
{
    private static location _loc = Location(0, 0);

#region Static Properties

    public static Vector3 zero => new(0, 0, 0);
    public static Vector3 up => new(0, 0, 1);
    public static Vector3 down => new(0, 0, -1);
    public static Vector3 right => new(1, 0, 0);
    public static Vector3 left => new(-1, 0, 0);
    public static Vector3 forward => new(0, 1, 0);
    public static Vector3 back => new(0, -1, 0);
    public static Vector3 one => new(1, 1, 1);

#endregion

#region Operators

    public static Vector3 operator +(Vector3 a, Vector3 b)
    {
        return new Vector3(a.x + b.x, a.y + b.y, a.z + b.z);
    }

    public static Vector3 operator -(Vector3 a)
    {
        return new Vector3(-a.x, -a.y, -a.z);
    }

    public static Vector3 operator -(Vector3 a, Vector3 b)
    {
        return new Vector3(a.x - b.x, a.y - b.y, a.z - b.z);
    }

    public static Vector3 operator *(Vector3 v, float f)
    {
        return new Vector3(v.x * f, v.y * f, v.z * f);
    }

    public static Vector3 operator *(float f, Vector3 v)
    {
        return new Vector3(v.x * f, v.y * f, v.z * f);
    }

    public static Vector3 operator /(Vector3 v, float f)
    {
        return new Vector3(v.x / f, v.y / f, v.z / f);
    }

#endregion

    /// <summary>
    /// Warcraft III world space here is right-handed: +x points right, +y points away, +z points up.
    /// That means Cross((1,0,0), (0,1,0)) == (0,0,1).
    /// </summary>
    public static Vector3 Cross(Vector3 a, Vector3 b)
    {
        return new Vector3(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x);
    }

    public static float Distance(Vector3 a, Vector3 b)
    {
        return (a - b).magnitude;
    }

    public static float Dot(Vector3 a, Vector3 b)
    {
        return a.x * b.x + a.y * b.y + a.z * b.z;
    }

    public static Vector3 Lerp(Vector3 a, Vector3 b, float t)
    {
        t = Math.Clamp01(t);
        return a + (b - a) * t;
    }

    public static Vector3 MoveTowards(Vector3 current, Vector3 target, float maxDistanceDelta)
    {
        var toVector = target - current;
        var dist = toVector.magnitude;
        if (dist <= maxDistanceDelta || dist == 0f)
        {
            return target;
        }
        return current + toVector / (dist / maxDistanceDelta);
    }

    public static Vector3 Project(Vector3 v, Vector3 onNormal)
    {
        var sqrMag = Dot(onNormal, onNormal);
        if (sqrMag < 0.0001f)
        {
            return zero;
        }
        var dot = Dot(v, onNormal);
        return onNormal * (dot / sqrMag);
    }

    public static Vector3 ProjectOnPlane(Vector3 v, Vector3 planeNormal)
    {
        return v - Project(v, planeNormal);
    }

    public static Vector3 Reflect(Vector3 inDirection, Vector3 inNormal)
    {
        return inDirection - 2 * Dot(inDirection, inNormal) * inNormal;
    }

    public static Vector3 RotateTowards(Vector3 current, Vector3 target, float maxRadiansDelta, float maxMagnitudeDelta)
    {
        var currentMag = current.magnitude;
        var targetMag = target.magnitude;

        if (currentMag == 0f || targetMag == 0f)
        {
            return MoveTowards(current, target, maxMagnitudeDelta);
        }

        var currentNorm = current / currentMag;
        var targetNorm = target / targetMag;

        var dot = Math.Clamp(Dot(currentNorm, targetNorm), -1f, 1f);
        var angle = math.acos(dot);

        if (angle == 0f)
        {
            return MoveTowards(current, target, maxMagnitudeDelta);
        }

        var t = math.min(1f, maxRadiansDelta / angle);
        var newDir = Slerp(currentNorm, targetNorm, t);
        var newMag = Math.MoveTowards(currentMag, targetMag, maxMagnitudeDelta);
        return newDir * newMag;
    }

    public static Vector3 Scale(Vector3 a, Vector3 b)
    {
        return new Vector3(a.x * b.x, a.y * b.y, a.z * b.z);
    }

    public static Vector3 Slerp(Vector3 a, Vector3 b, float t)
    {
        var magA = a.magnitude;
        var magB = b.magnitude;

        if (magA == 0f || magB == 0f)
        {
            return MoveTowards(a, b, math.huge);
        }

        var normA = a / magA;
        var normB = b / magB;

        var dot = Math.Clamp(Dot(normA, normB), -1f, 1f);
        var angle = math.acos(dot);
        var sinAngle = math.sin(angle);

        if (sinAngle < 0.0001f)
        {
            return MoveTowards(a, b, math.huge);
        }

        var tAngle = angle * t;
        var sinTA = math.sin(tAngle);
        var sinTOneMinusA = math.sin(angle - tAngle);

        var newDir = (normA * sinTOneMinusA + normB * sinTA) / sinAngle;
        var newMag = Math.Lerp(magA, magB, t);
        return newDir * newMag;
    }

    private static float _getTerrainZ(float x, float y)
    {
        MoveLocation(_loc, x, y);
        return GetLocationZ(_loc);
    }

    public static Vector3 FromUnit(unit u)
    {
        var x = GetUnitX(u);
        var y = GetUnitY(u);
        return new Vector3(x, y, _getTerrainZ(x, y) + GetUnitFlyHeight(u));
    }

    public float x;
    public float y;
    public float z;

    public float sqrMagnitude => x * x + y * y + z * z;
    public float magnitude => math.sqrt(sqrMagnitude);

    public Vector3 normalized
    {
        get
        {
            var mag = magnitude;
            if (mag < 0.0001f)
            {
                return zero;
            }
            return this / mag;
        }
    }

    public Vector3(float x, float y, float z)
    {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    public Vector3 ClampMagnitude(float mag)
    {
        return normalized * mag;
    }

    public override string ToString()
    {
        return $"({x}, {y}, {z})";
    }

    public void UnitMoveTo(unit u, UnitVec3Mode mode = UnitVec3Mode.Auto)
    {
        var tz = _getTerrainZ(x, y);
        var defaultFlyHeight = GetUnitDefaultFlyHeight(u);
        var minZ = tz + defaultFlyHeight;
        SetUnitPosition(u, x, y);
        switch (mode)
        {
            case UnitVec3Mode.ForceFlying:
                Helper.SetUnitFlyable(u);
                SetUnitFlyHeight(u, math.max(minZ, z) - minZ, 0f);
                break;
            case UnitVec3Mode.ForceGround:
                SetUnitFlyHeight(u, defaultFlyHeight, 0f);
                break;
            case UnitVec3Mode.Auto:
                if (IsUnitType(u, UNIT_TYPE_FLYING))
                {
                    SetUnitFlyHeight(u, math.max(minZ, z) - minZ, 0f);
                }
                else
                {
                    SetUnitFlyHeight(u, defaultFlyHeight, 0f);
                }
                break;
        }
    }

    public float GetTerrainZ()
    {
        return _getTerrainZ(x, y);
    }
}
