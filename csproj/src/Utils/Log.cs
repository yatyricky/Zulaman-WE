using StdLib;

/// <summary>
/// 基于 PreloadGen 的磁盘日志：每次落盘用一次 PreloadGenStart/PreloadGenEnd 会话，
/// 把全部缓冲整体重写进 CustomMapData/sf-log.pld——一行缓冲对应文件里一条
/// `call Preload( "..." )`，便于事后解析，不受屏幕消息遮挡。
/// 测试日志量小，Info 逐条落盘（整文件重写）最简单可靠；量大再改批量 Flush。
/// </summary>
public static class Log
{
    private const int MaxLines = 512;
    private const int MaxLineLength = 960; // 保住 Diagnostics 报告的完整影子调用栈

    private static List<string> _lines = new List<string>();

    /// <summary>写一行日志并立即落盘到 sf-log.pld。超过 MaxLines 后静默丢弃。</summary>
    public static void Info(string message)
    {
        if (_lines.Count >= MaxLines) return;
        _lines.Add(Sanitize(message));
        Flush();
    }

    /// <summary>把全部缓冲重写进 CustomMapData/sf-log.pld（一行一条 call Preload）。
    /// PreloadGenClear 必须先调：preload 队列跨会话累积，不清空会把历史重复写盘。</summary>
    public static void Flush()
    {
        if (_lines.Count == 0) return;
        PreloadGenClear();
        PreloadGenStart();
        for (int i = 0; i < _lines.Count; i++)
        {
            Preload(_lines[i]);
        }
        PreloadGenEnd("sf-log.pld");
    }

    /// <summary>Preload 内容不做转义，引号/换行会破坏 .pld 结构，统一替换；超长行截断。</summary>
    private static string Sanitize(string message)
    {
        var s = message.Replace("\r", " ").Replace("\n", " ").Replace("\"", "'");
        if (s.Length > MaxLineLength)
        {
            s = s.Substring(0, MaxLineLength) + "...";
        }
        return s;
    }
}
