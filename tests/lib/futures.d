module tests.lib.futures;

import fantasio.lib.futures : getOrThrows;
import unit_threaded;

@("forward exception type")
unittest
{
    import vibe.core.concurrency : async;

    static class CustomException : Exception
    {
        this(string msg, string file = __FILE__, size_t line = __LINE__) @safe pure
        {
            super(msg, file, line);
        }
    }

    int func(int p)
    {
        if (p < 0)
            throw new CustomException("oups");
        return 42;
    }

    {
        auto f = async(&func, 1);
        f.getOrThrows!CustomException.shouldEqual(42);
    }

    {
        auto f = async(&func, -1);
        f.getOrThrows!CustomException
            .shouldThrow!CustomException;
    }
}
