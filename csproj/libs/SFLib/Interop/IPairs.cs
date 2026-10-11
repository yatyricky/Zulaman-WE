using System;

namespace SFLib.Interop;

public interface IPairs<K, T>
{
    Func<(K, T)> PairsNext();
}
