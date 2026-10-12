using SFLib.Interop;

public struct Quaternion
{
    public static Quaternion identity => new(0, 0, 0, 1);

    public static Quaternion operator *(Quaternion a, Quaternion b)
    {
        return new Quaternion
        {
            w = a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z,
            x = a.w * b.x + a.x * b.w + a.y * b.z - a.z * b.y,
            y = a.w * b.y - a.x * b.z + a.y * b.w + a.z * b.x,
            z = a.w * b.z + a.x * b.y - a.y * b.x + a.z * b.w
        };
    }

    public static Vector3 operator *(Quaternion q, Vector3 v)
    {
        // https://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation#Using_quaternion_as_rotations
        var u = new Vector3(q.x, q.y, q.z);
        var s = q.w;

        return 2.0f * Vector3.Dot(u, v) * u
             + (s * s - Vector3.Dot(u, u)) * v
             + 2.0f * s * Vector3.Cross(u, v);
    }

    public static Quaternion Euler(float pitch, float yaw, float roll)
    {
        pitch *= bj_DEGTORAD;
        yaw *= bj_DEGTORAD;
        roll *= bj_DEGTORAD;

        // https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles#Source_Code_2
        var cy = math.cos(yaw * 0.5f);
        var sy = math.sin(yaw * 0.5f);
        var cp = math.cos(pitch * 0.5f);
        var sp = math.sin(pitch * 0.5f);
        var cr = math.cos(roll * 0.5f);
        var sr = math.sin(roll * 0.5f);

        return new Quaternion
        {
            w = cr * cp * cy + sr * sp * sy,
            x = sr * cp * cy - cr * sp * sy,
            y = cr * sp * cy + sr * cp * sy,
            z = cr * cp * sy - sr * sp * cy
        };
    }

    public static Quaternion LookRotation(Vector3 forward, Vector3 upwards)
    {
        var worldForward = forward.normalized;
        if (worldForward.sqrMagnitude < 0.0001f)
        {
            return identity;
        }

        var worldUp = Vector3.ProjectOnPlane(upwards, worldForward).normalized;
        if (worldUp.sqrMagnitude < 0.0001f)
        {
            var fallbackUp = math.abs(worldForward.z) < 0.999f ? Vector3.up : Vector3.right;
            worldUp = Vector3.ProjectOnPlane(fallbackUp, worldForward).normalized;
        }

        var worldRight = Vector3.Cross(worldForward, worldUp).normalized;
        worldUp = Vector3.Cross(worldRight, worldForward);

        var m00 = worldRight.x;
        var m01 = worldForward.x;
        var m02 = worldUp.x;
        var m10 = worldRight.y;
        var m11 = worldForward.y;
        var m12 = worldUp.y;
        var m20 = worldRight.z;
        var m21 = worldForward.z;
        var m22 = worldUp.z;

        float x;
        float y;
        float z;
        float w;
        var trace = m00 + m11 + m22;
        if (trace > 0f)
        {
            var s = math.sqrt(trace + 1f) * 2f;
            w = 0.25f * s;
            x = (m21 - m12) / s;
            y = (m02 - m20) / s;
            z = (m10 - m01) / s;
        }
        else if (m00 > m11 && m00 > m22)
        {
            var s = math.sqrt(1f + m00 - m11 - m22) * 2f;
            w = (m21 - m12) / s;
            x = 0.25f * s;
            y = (m01 + m10) / s;
            z = (m02 + m20) / s;
        }
        else if (m11 > m22)
        {
            var s = math.sqrt(1f + m11 - m00 - m22) * 2f;
            w = (m02 - m20) / s;
            x = (m01 + m10) / s;
            y = 0.25f * s;
            z = (m12 + m21) / s;
        }
        else
        {
            var s = math.sqrt(1f + m22 - m00 - m11) * 2f;
            w = (m10 - m01) / s;
            x = (m02 + m20) / s;
            y = (m12 + m21) / s;
            z = 0.25f * s;
        }

        return Normalize(new Quaternion(x, y, z, w));
    }

    public static Quaternion LookRotation(Vector3 forward)
    {
        return LookRotation(forward, Vector3.up);
    }

    private static Quaternion Normalize(Quaternion q)
    {
        var magnitude = math.sqrt(q.x * q.x + q.y * q.y + q.z * q.z + q.w * q.w);
        if (magnitude < 0.0001f)
        {
            return identity;
        }

        return new Quaternion(q.x / magnitude, q.y / magnitude, q.z / magnitude, q.w / magnitude);
    }

    public float x;
    public float y;
    public float z;
    public float w;

    public Vector3 eulerAngles
    {
        get
        {
            // https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles#Source_Code_2
            var sinr_cosp = 2 * (w * x + y * z);
            var cosr_cosp = 1 - 2 * (x * x + y * y);
            var roll = math.atan(sinr_cosp, cosr_cosp);

            var sinp = 2 * (w * y - z * x);
            float pitch;
            if (math.abs(sinp) >= 1)
                pitch = Math.Sign(sinp) * math.pi / 2; // use 90 degrees if out of range
            else
                pitch = math.asin(sinp);

            var siny_cosp = 2 * (w * z + x * y);
            var cosy_cosp = 1 - 2 * (y * y + z * z);
            var yaw = math.atan(siny_cosp, cosy_cosp);

            return new Vector3(pitch * bj_RADTODEG, yaw * bj_RADTODEG, roll * bj_RADTODEG);
        }
    }

    public Quaternion normalized => Normalize(this);

    public static Quaternion Inverse(Quaternion rotation)
    {
        return new Quaternion(-rotation.x, -rotation.y, -rotation.z, rotation.w);
    }

    public Quaternion(float x, float y, float z, float w)
    {
        this.x = x;
        this.y = y;
        this.z = z;
        this.w = w;
    }

    public override string ToString()
    {
        return $"({x}, {y}, {z}, {w})";
    }

    public void ApplyToEffect(effect e)
    {
        var angles = eulerAngles;
        BlzSetSpecialEffectOrientation(e, angles.y * bj_DEGTORAD, angles.x * bj_DEGTORAD, angles.z * bj_DEGTORAD);
    }
}