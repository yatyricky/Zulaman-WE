public static class GameTime
{
    private const int ClockPeriodMs = 60000;
    private static timer _clock = null!;
    private static int _baseMs;

    public static void Init()
    {
        if (_clock != null) return;
        _clock = CreateTimer();
        TimerStart(_clock, ClockPeriodMs / 1000f, true, () => { _baseMs += ClockPeriodMs; });
    }

    public static int NowMs()
    {
        if (_clock == null) Init();
        return _baseMs + Math.RoundToInt(TimerGetElapsed(_clock!) * 1000f);
    }
}
