module fantasio.core.errors;

class LanguageNotFound : Error
{
    this(string msg, string file = __FILE__, size_t line = __LINE__) @safe pure
    {
        super(msg, file, line);
    }
}


class NotIdentifiableSource : Error
{
    this(string msg, string file = __FILE__, size_t line = __LINE__) @safe pure
    {
        super(msg, file, line);
    }
}
