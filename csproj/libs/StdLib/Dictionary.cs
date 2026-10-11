using System;
using SFLib.Interop;

namespace StdLib;

/// <summary>
/// A basic dictionary backed by a Lua table with direct key access.
/// C# indexer (dict[key]) maps to direct table field access via get_Item/set_Item.
/// </summary>
[Lua(PackStruct = true)]
public class Dictionary<K, V> : IPairs<K, V>
{
    private LuaObject _table;
    private int _version;
    private List<K> _keys;
    public int Count { get; private set; }

    public Dictionary()
    {
        _table = LuaInterop.CreateTable();
        _keys = new List<K>();
        _version = 0;
        Count = 0;
    }

    public V this[K key]
    {
        get
        {
            if (key == null) throw new Exception("Key cannot be null");
            return LuaInterop.Get<V>(_table, key) ?? throw new Exception("Key not found");
        }
        set
        {
            if (key == null) throw new Exception("Key cannot be null");
            var existing = LuaInterop.Get<V>(_table, key);
            LuaInterop.Set(_table, key, value);
            if (existing == null)
            {
                Count++;
                _keys.Add(key);
            }
            _version++;
        }
    }

    public Func<(K, V)> PairsNext()
    {
        var version = _version;
        var index = 0;
        return () =>
        {
            if (version != _version) throw new Exception("Collection was modified");
            index++;
            if (index > _keys.Count) return default;
            var key = _keys[index - 1];
            var value = LuaInterop.Get<V>(_table, key!);
            return (key, value);
        };
    }

    public bool ContainsKey(K key)
    {
        if (key == null) throw new Exception("Key cannot be null");
        return LuaInterop.Get<V>(_table, key) != null;
    }

    public bool TryGetValue(K key, out V value)
    {
        if (key == null) throw new Exception("Key cannot be null");
        var result = LuaInterop.Get<V>(_table, key);
        if (result != null)
        {
            value = result;
            return true;
        }
        value = default!;
        return false;
    }

    public Enumerator GetEnumerator() => default!;

    public class Enumerator
    {
        public (K key, V value) Current => default!;
        public bool MoveNext() => default!;
    }
}
