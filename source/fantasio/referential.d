module fantasio.referential;

import std.traits : isSomeString, isIntegral;
import std.regex : ctRegex;
import fantasio.lib.types : Result;

version(Have_unit_threaded) { import unit_threaded; }
else                        { enum ShouldFail; }

private enum allowedPattern = ctRegex!"[A-Za-z0-9_\\-]+";
private enum idPattern = ctRegex!"ref:([A-Za-z0-9_\\-]+):([A-Za-z0-9_\\-]+):([A-Za-z0-9_\\-]+)";

/// Error representing referential ids formatting issues
class IdFormatError : Error
{
    pure nothrow @nogc @safe this(string msg, Throwable nextInChain = null)
    {
        super(msg, nextInChain);
    }
}

/**
 * Id datatype built with a providerId, a type and a provided id.
 * Cannot be instantiated with the contructor, use $(LREF makeId) instead
 */
struct Id
{
    private string[3] data;
    private string id;
    alias id this;

    @disable this();

    private this(string providerId, string type, string id) pure @safe nothrow
    {
        this.data[0] = providerId;
        this.data[1] = type;
        this.data[2] = id;

        import std.array : appender;

        auto app = appender!string;
        app.reserve(6);
        app.put("ref:");
        app.put(this.data[0]);
        app.put(":");
        app.put(this.data[1]);
        app.put(":");
        app.put(this.data[2]);

        this.id = app.data;
    }

    string toString() const @safe pure nothrow
    {
        return this.id;
    }
}

/// Contruct an id
Result!(Id, IdFormatError) makeId(T)(const string providerId, const string type, const T id) @safe pure
if(isSomeString!T || isIntegral!T)
{
    import std.conv : to;
    import std.regex : matchFirst;

    if(providerId.matchFirst(allowedPattern).empty)
        return Result!(Id, IdFormatError)(
            new IdFormatError("providerId does not match allowed pattern"));

    if(type.matchFirst(allowedPattern).empty)
        return Result!(Id, IdFormatError)(
            new IdFormatError("type does not match allowed pattern"));

    static if(isSomeString!T)
        auto resourceId = id;
    else
        auto resourceId = id.to!string;

    if(resourceId.matchFirst(allowedPattern).empty)
        return Result!(Id, IdFormatError)(
            new IdFormatError("id does not match allowed pattern"));

    return Result!(Id, IdFormatError)(Id(providerId, type, resourceId));
}

@("An id can be constructed from any supported type of provided id")
@safe pure unittest
{
    import fantasio.lib.types : get, isFailure;

    auto anId = makeId("foo", "bar", "42");
    anId.get.toString.shouldEqual("ref:foo:bar:42");
    (anId.get == "ref:foo:bar:42").shouldBeTrue;
    makeId("foo", "bar", 42).get.toString.shouldEqual("ref:foo:bar:42");

    makeId("//", "bar", "42").isFailure.shouldBeTrue;
    makeId("foo", "??", "42").isFailure.shouldBeTrue;
    makeId("foo", "bar", "!!").isFailure.shouldBeTrue;
}

/// Ditto
Result!(Id, IdFormatError) makeId(T)(const T id) @safe pure
if(isSomeString!T)
{
    import std.regex : matchFirst;
    import std.string : split;

    if(id.matchFirst(idPattern).empty)
        return Result!(Id, IdFormatError)(
            new IdFormatError("id does not match the specified pattern"));

    auto data = id.split(":")[1 .. $];
    return makeId(data[0], data[1], data[2]);
}

@("An id can be constructed from its string representation")
@safe pure unittest
{
    import fantasio.lib.types : get, isFailure;

    makeId("ref:foo:bar:42").get.toString.shouldEqual("ref:foo:bar:42");
    makeId("foo:bar:42").isFailure.shouldBeTrue;
}