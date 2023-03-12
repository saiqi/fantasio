module fantasio.lib.result;

import core.attribute : mustuse;
import std.typecons : Nullable;
import std.traits : isMutable, isAssignable;
import std.meta : AliasSeq, allSatisfy;
import std.sumtype : SumType;
import std.range;

private enum bool isError(E) = is(E : Error);

/// A struct that can be either a success of type `T` or a failure of type `Error`
@mustuse struct Result(T, E...) if (allSatisfy!(isError, AliasSeq!E))
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

    static foreach (ET; AliasSeq!E)
    {
        this(ET e) pure
        {
            this.payload = SumType!(T, E)(e);
            this._isSuccess = false;
        }

        auto ref opAssign()(ET error) if (isMutable!T)
        {
            (() @trusted { this.payload = error; })();
            this._isSuccess = false;
            return this;
        }
    }

    auto ref opAssign(U : T)(auto ref U value)
            if (isMutable!T && isAssignable!(T, U))
    {
        (() @trusted { this.payload = value; })();
        this._isSuccess = true;
        this._value = this.payload.get;
        return this;
    }

    auto ref opAssign(U : T, E...)(auto ref Result!(U, E) value)
            if (isMutable!T && isAssignable!(T, U) && allSatisfy!(isError, AliasSeq!E))
    {
        import std.algorithm.mutation : move;

        (() @trusted { this.payload = move(value); })();
        if (this.payload.isSuccess)
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

private alias TypeOfSuccess(T : SumType!(Arg, E), Arg, E...) = Arg;
private alias TypeOfFailure(T : SumType!(Arg, E), Arg, E...) = E;

/// Return true if `T` is an instance of `fantasio.lib.types.Result`
template isResult(T)
{
    static if (is(T : SumType!(Arg, E), Arg, E...))
    {
        static if (is(TypeOfFailure!T))
            enum bool isResult = allSatisfy!(isError, AliasSeq!(TypeOfFailure!T));
        else
            enum bool isResult = false;
    }
    else
        enum bool isResult = false;
}

/// Return true if a `Result` `t` is not an error
bool isSuccess(T)(auto ref inout T t) if (isResult!T)
{
    import std.sumtype : match;

    alias ST = TypeOfSuccess!T;

    return t.match!(
        (inout ST success) => true,
        _ => false
    );
}

/// Return true if a `Result` `t` is an error
bool isFailure(T)(auto ref inout T t) if (isResult!T)
{
    return !isSuccess(t);
}

/**
 * The counterpart of `std.typecons.apply` for `fantasio.lib.types.Result`.
 * Unpack the content of a `Result`, perform an operation and packs it again.
 * If `fun` returns a `Result` of an error type,
 * the returned `Result` accumulates this error type with the parameter's error type
 * Params:
 *   t = a `Result`
 *   fun = a function operating on the valid content of the result
 *
 * Returns:
 *   `Result!(typeof(fun(T.init)), Error ...)`
 */
template apply(alias fun)
{
    import std.functional : unaryFun;
    import std.sumtype : match;
    import std.meta : NoDuplicates;

    auto apply(T)(auto ref T t) if (isResult!T)
    {
        alias SuccessType = TypeOfSuccess!T;
        alias FailureTypes = TypeOfFailure!T;
        alias FunType = typeof(unaryFun!fun(SuccessType.init));

        static if (isResult!FunType)
        {
            alias ResultType = Result!(
                TypeOfSuccess!FunType,
                NoDuplicates!(AliasSeq!(FailureTypes, TypeOfFailure!FunType))
            );

            return t.match!(
                (SuccessType success) {
                return fun(success)
                    .match!(
                        (TypeOfSuccess!FunType s) => ResultType(s),
                        failure => ResultType(failure)
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

/**
Convert a `Result` to `Nullable`
Params:
    t = a `Result`
Returns:
    a `(Nullable!TypeOfSuccess)`
*/
auto toNullable(T)(auto ref T t) if (isResult!T)
{
    import std.traits : CopyConstness;
    import std.sumtype : match;

    alias ST = CopyConstness!(T, TypeOfSuccess!T);

    return t.match!(
        (inout Error e) => (Nullable!ST).init,
        (inout TypeOfSuccess!T v) => Nullable!ST(v)
    );
}

/// Extract the success value from a success `Result`
auto get(T)(auto ref T t) if (isResult!T)
{
    import std.sumtype : match;

    assert(t.isSuccess, "Trying to unpack value of a failure Result");
    return t.match!(
        (inout TypeOfSuccess!T v) => v,
        _ => assert(false),
    );
}

/// Extract the success value of a success `Result` or the provided fallback if the `Result` is a failure
inout(U) get(T, U)(auto ref T t, inout(U) fallback)
        if (isResult!T && is(U : TypeOfSuccess!T))
{
    if (t.isFailure)
        return fallback;
    return get(t);
}

/// Convert an input range of `Result` to a `Result` of a dynamic array
Result!(
    TypeOfSuccess!(ElementType!R)[],
    TypeOfFailure!(ElementType!R)
) traverse(R)(R rangeOfResults) if (isInputRange!R && isResult!(ElementType!R))
{
    import std.sumtype : match;
    import std.array : Appender;

    alias RT = typeof(return);

    Appender!(TypeOfSuccess!(ElementType!R)[]) acc;

    foreach (ref el; rangeOfResults)
    {
        if (el.isFailure)
        {
            return RT(
                el.match!(
                    (inout TypeOfSuccess!(typeof(el)) s) => assert(false),
                    failure => failure
            )
            );
        }
        acc.put(el.get);
    }
    return RT(acc.data);
}
