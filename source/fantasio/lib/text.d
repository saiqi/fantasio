module fantasio.lib.text;

import std.traits : isSomeString;

version(Have_unit_threaded) { import unit_threaded; }
else                        { enum ShouldFail; }

private dchar[] clean(T)(T input)
if(isSomeString!T)
{
    import std.uni : toLower, isPunctuation;
    import std.array : array;
    import std.algorithm : filter, map;

    return input
        .map!(a => toLower(a))
        .filter!(a => !isPunctuation(a))
        .array;
}

@("clean should convert to lower case and remove punctuation characters")
@safe pure unittest
{
    import std.conv : to;
    "Kylian M'Bappé".clean.to!string.shouldEqual("kylian mbappé");
}
