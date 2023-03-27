module fantasio.lib.futures;

import vibe.core.concurrency : Future;

@safe T getOrThrows(alias E, T)(Future!T fut)
{
    import std.exception : enforce;

    try
    {
        return fut.getResult;
    }
    catch (Exception e)
    {
        enforce!E(false, e.msg);
    }
    assert(false);
}
