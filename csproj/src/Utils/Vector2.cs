public struct Vector2
{
    public float x;
    public float y;

    public Vector2(float x, float y)
    {
        this.x = x;
        this.y = y;
    }

    public static Vector2 zero => new Vector2(0f, 0f);
    public static Vector2 one => new Vector2(1f, 1f);
    public static Vector2 up => new Vector2(0f, 1f);
    public static Vector2 down => new Vector2(0f, -1f);
    public static Vector2 left => new Vector2(-1f, 0f);
    public static Vector2 right => new Vector2(1f, 0f);

    public static Vector2 operator +(Vector2 a, Vector2 b)
    {
        return new Vector2(a.x + b.x, a.y + b.y);
    }

    public static Vector2 operator -(Vector2 a, Vector2 b)
    {
        return new Vector2(a.x - b.x, a.y - b.y);
    }

    public static Vector2 operator -(Vector2 a)
    {
        return new Vector2(-a.x, -a.y);
    }

    public static Vector2 operator *(Vector2 a, float d)
    {
        return new Vector2(a.x * d, a.y * d);
    }

    public static Vector2 operator *(float d, Vector2 a)
    {
        return new Vector2(a.x * d, a.y * d);
    }

    public static Vector2 operator /(Vector2 a, float d)
    {
        return new Vector2(a.x / d, a.y / d);
    }

    public static bool operator ==(Vector2 a, Vector2 b)
    {
        return a.x == b.x && a.y == b.y;
    }

    public static bool operator !=(Vector2 a, Vector2 b)
    {
        return a.x != b.x || a.y != b.y;
    }

    public override string ToString()
    {
        return "(" + x + ", " + y + ")";
    }
}
