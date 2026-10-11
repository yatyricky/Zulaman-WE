using System;

namespace SFLib.Interop;

[AttributeUsage(AttributeTargets.All, AllowMultiple = true)]
public sealed class LuaAttribute : Attribute
{
    /// <summary>
    /// The name of the Lua function or variable. If not specified, the C# member name is used.
    /// </summary>
    public string? Name;
    /// <summary>
    /// If set, indicates that this member corresponds to a static method in Lua. The value is the name of the Lua function.
    /// </summary>
    public string? StaticMethod;
    /// <summary>
    /// If set, indicates that this member corresponds to an instance method in Lua. The value is the name of the Lua function.
    /// </summary>
    public string? Method;
    /// <summary>
    /// If set, indicates that this member corresponds to a Lua module. The value is the name of the Lua module.
    /// </summary>
    public string? Module;
    /// <summary>
    /// If set, indicates that this member corresponds to a Lua class. The value is the name of the Lua class.
    /// When lowering, this type will become `local cls = class("{Class}")`.
    /// </summary>
    public string? Class;
    /// <summary>
    /// If set, indicates that this class requires a Lua module. Affects code sorting and ensures the module is loaded before the class is defined. The value is the name of the Lua module.
    /// </summary>
    public string? Require;
    /// <summary>
    /// If true, indicates that this class should be treated as a Lua table literal. When lowering, this type will become `local tbl = { ... }` instead of `local cls = class("...")`.
    /// </summary>
    public bool TableLiteral;
    /// <summary>
    /// If true, struct values crossing this type's boundary are packed into tables on entry
    /// and unpacked from tables on exit. The type acts as a black box for struct values.
    /// </summary>
    public bool PackStruct;

    public LuaAttribute()
    {
    }
}
