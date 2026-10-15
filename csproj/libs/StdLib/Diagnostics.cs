using SFLib.Interop;

namespace StdLib;

/// <summary>
/// Debug helpers shared by StdLib assertions. Fail enriches an assertion message with the
/// transpiler's shadow call stack (--trace-calls builds) and writes the report to disk via
/// the PreloadGen natives, so WC3's single on-screen error line never has to be retyped.
/// Reports are capped (see Report); after the cap the screen message is unchanged but no
/// further files are written.
/// </summary>
public static class Diagnostics
{
    private const int MaxReports = 50;

    private static int _reportIndex = 0;

    public static string Fail(string message)
    {
        var enriched = message + TraceSuffix();
        Report(enriched);
        return enriched;
    }

    public static void Report(string message)
    {
        if (_reportIndex >= MaxReports)
        {
            return;
        }

        _reportIndex++;
        var path = "sf-error-" + _reportIndex + ".pld";
        PreloadGenClear();
        PreloadGenStart();
        Preload(message);
        PreloadGenEnd(path);
    }

    public static string TraceSuffix()
    {
        var trace = LuaInterop.GetGlobal<LuaObject>("SF__TRACE__");
        if (trace == null) return "";
        return " | at " + table.concat(trace, " -> ");
    }
}
