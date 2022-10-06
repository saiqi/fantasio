module tests.lib.types;

import unit_threaded;
import fantasio.lib.types;

@("a result can be assigned")
@safe unittest
{
    import std.algorithm : map;
    auto success = Result!(int, Error)(42);
    success.get.shouldEqual(42);

    auto failure = Result!(int, Error)(new Error(""));
    failure.isFailure.shouldBeTrue;

    success = 43;
    success.get.shouldEqual(43);

    success = 42u;
    success.get.shouldEqual(42u);

    success = new Error("");
    success.isFailure.shouldBeTrue;

    success = failure;
    success.isFailure.shouldBeTrue;

    auto new_ = Result!(int, Error)(42);
    success = new_;
    success.get.shouldEqual(42);
}

@("a result can match on user defined error")
@safe pure unittest
{
    import std.sumtype : match;

    class MyError : Error
    {
        pure nothrow @nogc @safe this(string msg, Throwable nextInChain = null)
        {
            super(msg, nextInChain);
        }
    }

    auto failure = Result!(int, MyError)(new MyError(""));
    failure.match!(
        (MyError e) => "MyError",
        _ => "NoError"
    ).shouldEqual("MyError");
}

@("results are ranges")
unittest
{
    import std.range : isInputRange;
    static assert(isInputRange!(Result!(int, Error)));
    Result!(int, Error) r = 42;
    r.front.shouldEqual(42);
    r.shouldNotBeEmpty;
    r.popFront();
    r.shouldBeEmpty;
}

@("range algorithms can be applied to result")
@safe pure unittest
{
    import std.range : iota;
    import std.algorithm : map, filter;

    Result!(int, Error) reciprocal(const int v) pure nothrow @safe
    {
        if(v == 0) return Result!(int, Error)(new Error(""));
        return Result!(int, Error)(1/v);
    }

    iota(2)
        .map!reciprocal
        .filter!isSuccess
        .map!get
        .shouldEqual([1]);
}

@("a result that is a success or a failure can be qualified")
@safe pure unittest
{
    Result!(int, Error) reciprocal(int v) pure nothrow @safe
    {
        if(v == 0) return Result!(int, Error)(new Error("Division by zero"));
        return Result!(int, Error)(1/v);
    }

    reciprocal(1).isSuccess.shouldBeTrue;
    reciprocal(1).isFailure.shouldBeFalse;
    reciprocal(0).isSuccess.shouldBeFalse;
    reciprocal(0).isFailure.shouldBeTrue;
}

@("a function when applying to a success result should return a success result")
@safe pure unittest
{
    Result!(int, Error) success = 42;
    Result!(int, Error) result = success.apply!(a => a + 1);
    result.isSuccess.shouldBeTrue;
    result.get.shouldEqual(43);
}

@("a function that returns a different type when applying to a success result should return a result of this type")
@safe pure unittest
{
    import std.conv : to;
    Result!(int, Error) success = 42;
    Result!(string, Error) result = success.apply!(a => a.to!string);
    result.isSuccess.shouldBeTrue;
    result.get.shouldEqual("42");
}

@("a function when applying to a failure result should return a failure result")
@safe pure unittest
{
    Result!(int, Error) failure = new Error("");
    Result!(int, Error) result = failure.apply!(a => a + 1);
    result.isFailure.shouldBeTrue;
}

@("apply calls can be chained")
@safe pure unittest
{
    import std.math : floor;
    import std.sumtype : match;

    class ParserError : Error
    {
        pure nothrow @nogc @safe this(string msg, Throwable nextInChain = null)
        {
            super(msg, nextInChain);
        }
    }

    class ZeroDivisionError : Error
    {
        pure nothrow @nogc @safe this(string msg, Throwable nextInChain = null)
        {
            super(msg, nextInChain);
        }
    }

    Result!(int, ParserError) parse(string s) nothrow
    {
        import std.conv : to;
        scope(failure) return Result!(int, ParserError)(new ParserError(("Parsing of " ~ s ~ " failed")));
        return Result!(int, ParserError)(s.to!int);
    }

    Result!(double, ZeroDivisionError) reciprocal(int i) nothrow
    {
        if(i == 0) return Result!(double, ZeroDivisionError)(new ZeroDivisionError("Division by zero"));
        return Result!(double, ZeroDivisionError)(1/i);
    }

    auto success = parse("2")
        .apply!reciprocal
        .apply!floor;

    success.isSuccess.shouldBeTrue;
    success.get.shouldEqual(0.);
    success.match!(
        (ParserError e) => "ParserError",
        (ZeroDivisionError e) => "ZeroDivisionError",
        (double v) => "NoError").shouldEqual("NoError");

    auto failure = parse("k")
        .apply!reciprocal
        .apply!floor;

    failure.isFailure.shouldBeTrue;
    failure.match!(
        (ParserError e) => "ParserError",
        (ZeroDivisionError e) => "ZeroDivisionError",
        (double v) => "NoError").shouldEqual("ParserError");

    auto otherFailure = parse("0")
        .apply!reciprocal
        .apply!floor;

    otherFailure.isFailure.shouldBeTrue;
    otherFailure.match!(
        (ParserError e) => "ParserError",
        (ZeroDivisionError e) => "ZeroDivisionError",
        (double v) => "NoError").shouldEqual("ZeroDivisionError");
}

@("a success result should be converted to a non-null nullable")
@safe pure unittest
{
        Result!(int, Error) success = 42;
        success.toNullable.get.shouldEqual(42);
}

@("a failure result should be converted to a null nullable")
@safe pure unittest {
    Result!(int, Error) failure = new Error("");
    failure.toNullable.isNull.should == true;
}

@("a const success result can be converted to nullable")
@safe pure unittest
{
    const success = Result!(int, Error)(42);
    success.toNullable.get.shouldEqual(42);
}

@("a const success result of nested struct can be converted to nullable")
@safe pure unittest
{
    struct S1
    {
        int value;
    }

    struct S2
    {
        S1[] values;
    }

    const success = Result!(S2, Error)(S2([S1(0), S1(1)]));
    success.toNullable.isNull.shouldBeFalse;
}

@("the value of a success result can be extracted")
@safe pure unittest
{
    Result!(int, Error) success = 42;
    success.get.shouldEqual(42);
}

@("the value of a const success result can be extracted")
@safe pure unittest
{
    const success = Result!(int, Error)(42);
    success.get.shouldEqual(42);
}

@("the value of a const success result of nested struct can be extracted")
@safe pure unittest
{
    struct S1
    {
        int value;
    }

    struct S2
    {
        S1[] values;
    }

    const success = Result!(S2, Error)(S2([S1(0), S1(1)]));
    success.get.values.shouldEqual([S1(0), S1(1)]);
}

@("a failure result when extracting its value providing a fallback should return the fallback")
@safe pure unittest
{
    Result!(int, Error) failure = new Error("");
    failure.get(42).shouldEqual(42);
}

@("a success result when extracting its value providing a fallback should return the value of the result")
@safe pure unittest
{
    Result!(int, Error) success = 42;
    success.get(43).shouldEqual(42);
}
