module fantasio.lib.traits;

import std.typecons : Nullable;
import std.range : isInputRange, ElementType;
import std.traits : Unqual, isDynamicArray;

/// Return `true` if `T` is an instance of `std.typecons.Nullable`
enum bool isNullable(T) = is(T : Nullable!Arg, Arg);
alias NullableOf(T : Nullable!Arg, Arg) = Arg;

/**
  * Apply a compile-time predicate with arguments `Args` to a type `T`.
  * If `T` is a `std.typecons.Nullable` the predicate will be applied to the corresponding underlying type
  * (i.e. `ST` from `Nullable!ST`).
  * Otherwise, the predicate will be applied on `T`
  */
template unpack(T, alias pred, Args...)
{
    static if (isNullable!T)
        enum unpack = pred!(NullableOf!T, Args);
    else
        enum unpack = pred!(T, Args);
}

/// Return `true` if a type `R` is a range or dynamic array of `T`
enum bool isIterableOf(R, T) = (isInputRange!R || isDynamicArray!R) && is(
        Unqual!(ElementType!R) == T);
