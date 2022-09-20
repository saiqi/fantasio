module fantasio.lib.types;

import std.typecons : Nullable;
import std.traits : isMutable,  isAssignable;
import std.sumtype : SumType;

version(Have_unit_threaded)
{
    import unit_threaded;
}

struct RResult(T)
{
    SumType!(Error, T) payload;
    alias payload this;

    private bool _isSuccess;
    private T _value = T.init;

    this(T value) pure
    {
        this.payload = SumType!(Error, T)(value);
        this._isSuccess = true;
        this._value = this.payload.get;
    }

    this(Error e) pure
    {
        this.payload = SumType!(Error, T)(e);
        this._isSuccess = false;
    }

    auto ref opAssign(E : Error)(E error) if(isMutable!T)
    {
        (() @trusted {this.payload = error;})();
        this._isSuccess = false;
        return this;
    }

    auto ref opAssign(U : T)(auto ref U value) if(isMutable!T && isAssignable!(T, U))
    {
        (() @trusted {this.payload = value;})();
        this._isSuccess = true;
        this._value = this.payload.get;
        return this;
    }

    auto ref opAssign(U : T)(auto ref RResult!U value) if(isMutable!T && isAssignable!(T, U))
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
    static assert(isResult!(RResult!int));
    auto success = RResult!int(42);
    auto failure = RResult!int(new Error(""));

    success = 43;
    success = 42u;
    success = new Error("");
    success = failure;
}

@("results are ranges")
@safe unittest
{
    import std.range : isInputRange;
    static assert(isInputRange!(RResult!int));
    RResult!int r = 42;
    r.front.should == 42;
    r.empty.should.not == true;
    r.popFront();
    r.empty.should == true;
}

/// Return true if `T` is an instance of `std.typecons.Nullable`
enum bool isNullable(T) = is(T: Nullable!Arg, Arg);

/// Either `T` or an instance of `Error`
alias Result(T) = SumType!(Error, T);

/// Return true if `T` is an instance of `fantasio.lib.types.Result`
enum bool isResult(T) = is(T: SumType!(Error, Arg), Arg);

private alias TypeOfSuccess(T: SumType!(Error, Arg), Arg) = Arg;

/// Return true if `Result` `t` is not an error
bool isSuccess(T)(auto ref inout T t)
if(isResult!T)
{
    import std.sumtype : match;

    alias ST = TypeOfSuccess!T;

    return t.match!(
        (inout Error failure) => false,
        (inout ST success) => true
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
    Result!int reciprocal(int v) pure nothrow @safe
    {
        if(v == 0) return Result!int(new Error("Division by zero"));
        return Result!int(1/v);
    }

    reciprocal(1).isSuccess.should == true;
    reciprocal(1).isFailure.should == false;
    reciprocal(0).isSuccess.should == false;
    reciprocal(0).isFailure.should == true;
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
        alias FunType = typeof(unaryFun!fun(SuccessType.init));

        static if(isResult!FunType)
        {
            return t.match!(
                (Error failure) => FunType(failure),
                (SuccessType success) => fun(success)
            );
        }
        else
        {
            return t.match!(
                (Error failure) => Result!FunType(failure),
                (SuccessType success) => Result!FunType(fun(success))
            );
        }
    }
}

@("a function when applying to a success result should return a success result")
@safe unittest
{
    Result!int success = 42;
    Result!int result = success.apply!(a => a + 1);
    result.isSuccess.should == true;
    result.get.should == 43;
}

@("a function that returns a different type when applying to a success result should return a result of this type")
@safe unittest
{
    import std.conv : to;
    Result!int success = 42;
    Result!string result = success.apply!(a => a.to!string);
    result.isSuccess.should == true;
    result.get.should == "42";
}

@("a function when applying to a failure result should return a failure result")
@safe unittest
{
    Result!int failure = new Error("");
    Result!int result = failure.apply!(a => a + 1);
    result.isFailure.should == true;
}

@("apply calls can be chained")
@safe unittest
{
    import std.math : floor;

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

    Result!int parse(string s) nothrow
    {
        import std.conv : to;
        scope(failure) return Result!int(new ParserError(("Parsing of " ~ s ~ " failed")));
        return Result!int(s.to!int);
    }

    Result!double reciprocal(int i) nothrow
    {
        if(i == 0) return Result!double(new ZeroDivisionError("Division by zero"));
        return Result!double(1/i);
    }

    auto success = parse("2")
        .apply!reciprocal
        .apply!floor;
    
    success.isSuccess.should == true;
    success.get.should == 0.;

    auto failure = parse("k")
        .apply!reciprocal
        .apply!floor;
    failure.isFailure.should == true;

    auto otherFailure = parse("0")
        .apply!reciprocal
        .apply!floor;
    otherFailure.isFailure.should == true;
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
        Result!int success = 42;
        success.toNullable.get.should == 42;
}

@("a failure result should be converted to a null nullable")
@safe unittest {
    Result!int failure = new Error("");
    failure.toNullable.isNull.should == true;
}

@("a const success result can be converted to nullable")
@safe unittest
{
    const success = Result!int(42);
    success.toNullable.get.should == 42;
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

    const success = Result!S2(S2([S1(0), S1(1)]));
    success.toNullable.isNull.should.not == true;
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
    Result!int success = 42;
    success.get.should == 42;
}

@("the value of a const success result can be extracted")
@safe unittest
{
    const success = Result!int(42);
    success.get.should == 42;
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

    const success = Result!S2(S2([S1(0), S1(1)]));
    success.get.values.should == [S1(0), S1(1)];
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
    Result!int failure = new Error("");
    failure.get(42).should == 42;
}

@("a success result when extracting its value providing a fallback should return the value of the result")
@safe unittest
{
    Result!int success = 42;
    assert(success.get(43) == 42);
}