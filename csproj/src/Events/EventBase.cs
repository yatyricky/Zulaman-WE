using System;
using StdLib;

public class EventBase<T>
{
    private List<Action<T>> _callbacks = new();

    public void ResponseCall(T data)
    {
        foreach (var callback in _callbacks)
        {
            callback(data);
        }
    }

    public void Register(Action<T> callback)
    {
        if (!_callbacks.Contains(callback))
        {
            _callbacks.Add(callback);
        }
    }

    public void Unregister(Action<T> callback)
    {
        _callbacks.Remove(callback);
    }
}
