module fantasio.core.label;

import std.range : ElementType, isInputRange;
import std.traits : Unqual;
import std.typecons : Nullable;
import fantasio.core.model : Language, DefaultLanguage;

/// Find an entity from a range given a `Language`
Nullable!(Unqual!(ElementType!R)) extractLanguage(string field, R)(
    auto ref R entities,
    Language lang
) @safe pure nothrow
if (isInputRange!R && is(typeof(__traits(getMember, ElementType!R, field))))
{
    import std.algorithm : filter;

    auto filteredEntities = entities.filter!((a) {
        auto entityLang = __traits(getMember, a, field);
        return entityLang == lang;
    });

    if (filteredEntities.empty)
        return typeof(return).init;

    return typeof(return)(filteredEntities.front);
}
