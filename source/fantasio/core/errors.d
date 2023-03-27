module fantasio.core.errors;

class LanguageNotFound : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__) @safe pure
    {
        super(msg, file, line);
    }
}

class NotIdentifiableSource : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__) @safe pure
    {
        super(msg, file, line);
    }
}

class InconsitantSource : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__) @safe pure
    {
        super(msg, file, line);
    }
}

class RemoteError : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__) @safe pure
    {
        super(msg, file, line);
    }
}

class NotSupported : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__) @safe pure
    {
        super(msg, file, line);
    }
}
