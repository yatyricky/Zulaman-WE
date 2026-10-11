using System;

namespace SFLib.Interop;

public interface IIpairs<T>
{
    Func<(int, T)> IpairsNext();
}
