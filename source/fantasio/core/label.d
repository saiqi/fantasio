module fantasio.core.label;

import std.range : ElementType, isInputRange;
import std.traits : Unqual;
import fantasio.core.model : Language, DefaultLanguage;
import fantasio.core.errors : LanguageNotFound;

/// Find an entity from a range given a `Language`
Unqual!(ElementType!R) extractLanguage(string field, R)(
    auto ref R entities,
    Language lang
) @safe pure
if (isInputRange!R && is(typeof(__traits(getMember, ElementType!R, field))))
{
    import std.algorithm : filter;
    import std.exception : enforce;
    import std.format : format;

    auto filteredEntities = entities.filter!((a) {
        auto entityLang = __traits(getMember, a, field);
        return entityLang == lang;
    });

    enforce!LanguageNotFound(!filteredEntities.empty, format!"%s not found"(lang));

    return filteredEntities.front;
}
