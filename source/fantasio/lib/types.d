module fantasio.lib.types;

import std.typecons : Nullable;
import std.traits : isMutable,  isAssignable;
import std.sumtype : SumType;

struct RResult(T)
{
    SumType!(Error, T) payload;
    alias payload this;

    private bool _isSuccess;

    this(T value) pure
    {
        this.payload = SumType!(Error, T)(value);
        this._isSuccess = true;
    }

    this(Error e) pure
    {
        this.payload = SumType!(Error, T)(e);
        this._isSuccess = false;
    }

    auto ref opAssign(E : Error)(E error) if(isMutable!T)
    {
        (() @trusted {this.payload = error;})();
        this._isSuccess = true;
        return this;
    }

    auto ref opAssign(U : T)(auto ref U value) if(isMutable!T && isAssignable!(T, U))
    {
        (() @trusted {this.payload = value;})();
        this._isSuccess = true;
        return this;
    }

    auto ref opAssign(U : T)(auto ref RResult!U value) if(isMutable!T && isAssignable!(T, U))
    {
        import std.algorithm.mutation : move;
        (() @trusted {this.payload = move(value);})();
        return this;
    }
}

@("foo")
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

/// Return true if `T` is an instance of `std.typecons.Nullable`
enum bool isNullable(T) = is(T: Nullable!Arg, Arg);

unittest
{
    static assert(isNullable!(Nullable!int));
    static assert(!isNullable!int);
}

/// Either `T` or an instance of `Error`
alias Result(T) = SumType!(Error, T);

/// Return true if `T` is an instance of `fantasio.lib.types.Result`
enum bool isResult(T) = is(T: SumType!(Error, Arg), Arg);

unittest
{
    static assert(isResult!(Result!int));
    static assert(isResult!(SumType!(Error, int)));
    static assert(!isResult!int);
}

private alias TypeOfSuccess(T: SumType!(Error, Arg), Arg) = Arg;

unittest
{
    static assert(is(TypeOfSuccess!(Result!int) == int));
}

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

unittest
{
    Result!int inverse(int v) pure nothrow @safe
    {
        if(v == 0) return Result!int(new Error("Division by zero"));
        return Result!int(1/v);
    }

    assert(inverse(1).isSuccess);
    assert(!inverse(1).isFailure);
    assert(!inverse(0).isSuccess);
    assert(inverse(0).isFailure);
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

nothrow @safe unittest
{
    import std.sumtype : match;

    Result!int success = 42;
    {
        Result!int result = success.apply!(a => a + 1);
        assert(result.match!(
            (Error e) => false,
            (int v) => v == 43
        ));
    }

    {
        import std.conv : to;
        Result!string result = success.apply!(a => a.to!string);
        assert(result.match!(
            (Error e) => false,
            (string v) => v == "42"
        ));
    }

    Result!int failure = new Error("");
    {
        Result!int result = failure.apply!(a => a + 1);
        assert(result.isFailure);
    }

    {
        import std.conv : to;
        Result!string result = failure.apply!(a => a.to!string);
        assert(result.isFailure);
    }
}

@safe nothrow unittest
{
    import std.sumtype : match;
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

    assert(success.match!(
        (Error e) => assert(false),
        (double v) => v == 0.
    ));

    auto failure = parse("k")
        .apply!reciprocal
        .apply!floor;
    assert(failure.isFailure);

    auto otherFailure = parse("0")
        .apply!reciprocal
        .apply!floor;
    assert(otherFailure.isFailure);
}

/// Rangify a `Result`
auto rc(T)(auto ref T t)
if(isResult!T)
{
    import std.sumtype : match;

    static struct ResultRange
    {
        import std.traits : CopyConstness;
        alias ST = CopyConstness!(T, TypeOfSuccess!T);

        private ST _value = ST.init;
        private bool validated;

        this(T t) pure
        {
            if(t.isSuccess)
            {
                this._value = t.match!(
                    (ST v) => v,
                    _ => assert(false)
                );
                this.validated = true;
            }
            else
            {
                this.validated = false;
            }
        }

        @property bool empty() inout @safe pure nothrow
        {
            return !this.validated;
        }

        @property ref inout(ST) front() inout @safe pure nothrow
        {
            assert(!empty);
            return this._value;
        }

        alias back = front;

        void popFront()
        {
            assert(!empty);
            this.validated = false;
        }

        @property size_t length() const @safe pure nothrow
        {
            return !empty;
        }

        @property inout(typeof(this)) save() inout
        {
            return this;
        }

        alias popBack = popFront;

        inout(typeof(this)) opIndex() inout
        {
            return this;
        }

        inout(typeof(this)) opIndex(size_t[2] dim) inout
        in (dim[0] <= length && dim[1] <= length && dim[1] >= dim[0])
        {
            return (dim[0] == 0 && dim[1] == 1) ? this : this.init;
        }

        size_t[2] opSlice(size_t dim : 0)(size_t from, size_t to) const
        {
            return [from, to];
        }

        alias opDollar(size_t dim : 0) = length;

        ref inout(ST) opIndex(size_t index) inout @safe pure nothrow
        in (index < length)
        {
            return this._value;
        }

    }

    return ResultRange(t);
}

@safe nothrow unittest
{
    import std.algorithm : equal;

    Result!int success = 42;
    auto range = success.rc;
    assert(!range.empty);
    assert(range.front == 42);
    assert(range.length == 1);
    assert(range[0] == 42);
    assert(range[].equal([42]));
    assert(range[0 .. $].equal([42]));

    auto copy = range.save;
    range.popFront();
    assert(range.empty);
    assert(range.length == 0);
    assert(!copy.empty);
    assert(copy.front == 42);
    assert(copy.length == 1);

    Result!int failure = new Error("");
    assert(failure.rc.empty);
    assert(failure.rc.length == 0);
    assert(failure.rc[].length == 0);
    assert(failure.rc[0 .. $].length == 0);
}

@safe nothrow unittest
{
    import std.algorithm : map, joiner, equal;
    import std.range : iota;

    Result!double inverse(int a)
    {
        if(a == 0) return Result!double(new Error("Division by zero"));
        return Result!double(1./a);
    }

    auto values = iota(3)
        .map!inverse
        .map!rc
        .joiner;

    assert(values.equal([1, 0.5]));
}

@safe nothrow unittest
{
    import std.algorithm : map;

    struct S1
    {
        int value;
    }

    struct S2
    {
        S1[] values;
    }

    const success = Result!S2(S2([S1(0), S1(1)]));
    assert(success.rc.front.values[0] == S1(0));
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

@safe nothrow unittest
{
    {
        Result!int success = 42;
        assert(success.toNullable.get == 42);

        Result!int failure = new Error("");
        assert(failure.toNullable.isNull);
    }

    {
        const success = Result!int(42);
        assert(success.toNullable.get == 42);
    }

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
        assert(!success.toNullable.isNull);
    }
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

@safe nothrow unittest
{
    {
        Result!int success = 42;
        assert(success.get() == 42);
    }

    {
        const success = Result!int(42);
        assert(success.get() == 42);
    }

    {
        import std.algorithm : equal;

        struct S1
        {
            int value;
        }

        struct S2
        {
            S1[] values;
        }

        const success = Result!S2(S2([S1(0), S1(1)]));
        assert(success.get.values.equal([S1(0), S1(1)]));
    }
}

/// Extract the success value of a success `Result` or the provided fallback if the `Result` is a failure
inout(U) get(T, U)(auto ref T t, inout(U) fallback)
if(isResult!T && is(U : TypeOfSuccess!T))
{
    if(t.isFailure) return fallback;
    return get(t);
}

@safe nothrow unittest
{
    Result!int failure = new Error("");
    assert(failure.get(42) == 42);

    Result!int success = 42;
    assert(success.get(43) == 42);
}