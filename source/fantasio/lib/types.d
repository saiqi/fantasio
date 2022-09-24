module fantasio.lib.types;

import core.attribute : mustuse;
import std.typecons : Nullable;
import std.traits : isMutable,  isAssignable;
import std.meta : AliasSeq, allSatisfy;
import std.sumtype : SumType;

version(Have_unit_threaded) { import unit_threaded; }
else                        { enum ShouldFail; }

private enum bool isError(E) = is(E : Error);

/// A struct that can be either a success of type `T` or a failure of type `Error`
@mustuse struct Result(T, E ...)
if(allSatisfy!(isError, AliasSeq!E))
{
    SumType!(T, E) payload;
    alias payload this;

    private bool _isSuccess;
    private T _value = T.init;

    this(T value) pure
    {
        this.payload = SumType!(T, E)(value);
        this._isSuccess = true;
        this._value = this.payload.get;
    }

    static foreach(ET; AliasSeq!E)
    {
        this(ET e) pure
        {
            this.payload = SumType!(T, E)(e);
            this._isSuccess = false;
        }

        auto ref opAssign()(ET error) if(isMutable!T)
        {
            (() @trusted {this.payload = error;})();
            this._isSuccess = false;
            return this;
        }
    }

    auto ref opAssign(U : T)(auto ref U value) if(isMutable!T && isAssignable!(T, U))
    {
        (() @trusted {this.payload = value;})();
        this._isSuccess = true;
        this._value = this.payload.get;
        return this;
    }

    auto ref opAssign(U : T, E ...)(auto ref Result!(U, E) value)
    if(isMutable!T && isAssignable!(T, U) && allSatisfy!(isError, AliasSeq!E))
    {
        import std.algorithm.mutation : move;
        (() @trusted {this.payload = move(value);})();
        if(this.payload.isSuccess)
            this._value = this.payload.get;
        else
            this._value = T.init;
        return this;
    }

    @property bool empty() nothrow const @safe
    {
        return !this._isSuccess || this.payload.isFailure;
    }

    @property ref inout(T) front() inout return nothrow @safe
    {
        assert(!empty, "Attempting to fetch front value of an empty result");
        return this._value;
    }

    void popFront()
    {
        this._isSuccess = false;
    }
}

@("a result can be assigned")
@safe nothrow unittest
{
    auto success = Result!(int, Error)(42);
    auto failure = Result!(int, Error)(new Error(""));

    success = 43;
    success = 42u;
    success = new Error("");
    success = failure;
}

@("a result can match on user defined error")
@safe unittest
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
@safe unittest
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

/// Return true if `T` is an instance of `std.typecons.Nullable`
enum bool isNullable(T) = is(T: Nullable!Arg, Arg);

private alias TypeOfSuccess(T: SumType!(Arg, E), Arg, E...) = Arg;
private alias TypeOfFailure(T: SumType!(Arg, E), Arg, E...) = E;

/// Return true if `T` is an instance of `fantasio.lib.types.Result`
template isResult(T)
{
    static if(is(T: SumType!(Arg, E), Arg, E...))
    {
        static if(is(TypeOfFailure!T))
            enum bool isResult = allSatisfy!(isError, AliasSeq!(TypeOfFailure!T));
        else
            enum bool isResult = false;
    }
    else
        enum bool isResult = false;
}

@("a result has an interface and the type of success and failures can be extracted")
unittest
{
    class MyError : Error
    {
        pure nothrow @nogc @safe this(string msg, Throwable nextInChain = null)
        {
            super(msg, nextInChain);
        }
    }

    class MyOtherError : Error
    {
        pure nothrow @nogc @safe this(string msg, Throwable nextInChain = null)
        {
            super(msg, nextInChain);
        }
    }

    alias MyResult = Result!(int, MyError, MyOtherError);

    static assert(isResult!MyResult);
    static assert(is(TypeOfSuccess!MyResult == int));
    alias Expected = AliasSeq!(MyError, MyOtherError);
    static assert(is(TypeOfFailure!MyResult == Expected));
    static assert(allSatisfy!(isError, TypeOfFailure!MyResult));

    static assert(!isResult!(SumType!(int, double)));
}

/// Return true if `Result` `t` is not an error
bool isSuccess(T)(auto ref inout T t)
if(isResult!T)
{
    import std.sumtype : match;

    alias ST = TypeOfSuccess!T;

    return t.match!(
        (inout ST success) => true,
        _ => false
    );
}

/// Return true if `Result` `t` is an error
bool isFailure(T)(auto ref inout T t)
if(isResult!T)
{
    return !isSuccess(t);
}

@("a result that is a success or a failure can be qualified")
unittest
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

/**
The counterpart of `std.typecons.apply` for `fantasio.lib.types.Result`.
Unpack the content of a `Result`, perform an operation and packs it again.

Params:
    t = a `Result`
    fun = a function operating on the valid content of the result

Returns:
    `Result!(typeof(fun((TypeOfSuccess!T).init)))`
*/
template apply(alias fun)
{
    import std.functional : unaryFun;
    import std.sumtype : match;

    auto apply(T)(auto ref T t)
    if(isResult!T)
    {
        alias SuccessType = TypeOfSuccess!T;
        alias FailureTypes = TypeOfFailure!T;
        alias FunType = typeof(unaryFun!fun(SuccessType.init));

        static if(isResult!FunType)
        {
            alias ResultType = Result!(
                TypeOfSuccess!FunType,
                AliasSeq!(FailureTypes, TypeOfFailure!FunType));

            return t.match!(
                (SuccessType success) {
                    return fun(success)
                        .match!(
                            (TypeOfSuccess!FunType s) => ResultType(s),
                            (TypeOfFailure!FunType e) => ResultType(e)
                        );
                },
                failure => ResultType(failure));
        }
        else
        {
            alias ResultType = Result!(FunType, FailureTypes);
            return t.match!(
                (SuccessType success) => ResultType(fun(success)),
                failure => ResultType(failure));
        }
    }
}

@("a function when applying to a success result should return a success result")
@safe unittest
{
    Result!(int, Error) success = 42;
    Result!(int, Error) result = success.apply!(a => a + 1);
    result.isSuccess.shouldBeTrue;
    result.get.shouldEqual(43);
}

@("a function that returns a different type when applying to a success result should return a result of this type")
@safe unittest
{
    import std.conv : to;
    Result!(int, Error) success = 42;
    Result!(string, Error) result = success.apply!(a => a.to!string);
    result.isSuccess.shouldBeTrue;
    result.get.shouldEqual("42");
}

@("a function when applying to a failure result should return a failure result")
@safe unittest
{
    Result!(int, Error) failure = new Error("");
    Result!(int, Error) result = failure.apply!(a => a + 1);
    result.isFailure.shouldBeTrue;
}

@("apply calls can be chained")
@safe unittest
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

/**
Convert a `Result` to `Nullable`
Params:
    t = a `Result`
Returns:
    a `(Nullable!TypeOfSuccess)`
*/
auto toNullable(T)(auto ref T t)
if(isResult!T)
{
    import std.traits : CopyConstness;
    import std.sumtype : match;

    alias ST = CopyConstness!(T, TypeOfSuccess!T);

    return t.match!(
        (inout Error e) => (Nullable!ST).init,
        (inout TypeOfSuccess!T v) => Nullable!ST(v)
    );
}

@("a success result should be converted to a non-null nullable")
@safe unittest
{
        Result!(int, Error) success = 42;
        success.toNullable.get.shouldEqual(42);
}

@("a failure result should be converted to a null nullable")
@safe unittest {
    Result!(int, Error) failure = new Error("");
    failure.toNullable.isNull.should == true;
}

@("a const success result can be converted to nullable")
@safe unittest
{
    const success = Result!(int, Error)(42);
    success.toNullable.get.shouldEqual(42);
}

@("a const success result of nested struct can be converted to nullable")
@safe unittest
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

/// Extract the success value of a success `Result`
auto get(T)(auto ref T t)
{
    import std.sumtype : match;

    assert(t.isSuccess, "Trying to unpack value of a failure Result");
    return t.match!(
        (inout Error e) => assert(false),
        (inout TypeOfSuccess!T v) => v
    );
}

@("the value of a success result can be extracted")
@safe unittest
{
    Result!(int, Error) success = 42;
    success.get.shouldEqual(42);
}

@("the value of a const success result can be extracted")
@safe unittest
{
    const success = Result!(int, Error)(42);
    success.get.shouldEqual(42);
}

@("the value of a const success result of nested struct can be extracted")
@safe unittest
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

/// Extract the success value of a success `Result` or the provided fallback if the `Result` is a failure
inout(U) get(T, U)(auto ref T t, inout(U) fallback)
if(isResult!T && is(U : TypeOfSuccess!T))
{
    if(t.isFailure) return fallback;
    return get(t);
}

@("a failure result when extracting its value providing a fallback should return the fallback")
@safe unittest
{
    Result!(int, Error) failure = new Error("");
    failure.get(42).shouldEqual(42);
}

@("a success result when extracting its value providing a fallback should return the value of the result")
@safe unittest
{
    Result!(int, Error) success = 42;
    success.get(43).shouldEqual(42);
}