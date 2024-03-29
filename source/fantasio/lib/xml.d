module fantasio.lib.xml;

import std.typecons : Nullable;
import std.range : isForwardRange, ElementType;
import std.traits : isSomeChar, hasUDA;

private:
enum bool isDecodable(T) = isForwardRange!T && isSomeChar!(ElementType!T);

template rootName(T) if (hasUDA!(T, XmlRoot))
{
    import std.traits : isArray, getUDAs;
    import std.range : ElementType;

    static if (isArray!T)
        enum rootName = getUDAs!(ElementType!T, XmlRoot)[0].tagName;
    else
        enum rootName = getUDAs!(T, XmlRoot)[0].tagName;
}

template elementName(T, string name)
{
    import std.traits : getUDAs;

    alias member = __traits(getMember, T, name);

    static if (hasUDA!(member, XmlElement))
        enum elementName = getUDAs!(member, XmlElement)[0].tagName;
    else static if (hasUDA!(member, XmlElementList))
        enum elementName = getUDAs!(member, XmlElementList)[0].tagName;
    else
        static assert(false);
}

template checkElementType(T, string name)
{
    import std.traits : isArray;

    alias member = __traits(getMember, T, name);
    enum bool isList = isArray!(typeof(member));

    static if (hasUDA!(member, XmlElement))
        enum bool checkElementType = !isList;
    else static if (hasUDA!(member, XmlElementList))
        enum bool checkElementType = isList;
    else
        static assert(false);
}

string cleanNs(R)(R tagName) if (isDecodable!R)
{
    import std.algorithm : splitter, fold;
    import std.traits : isArray;
    import std.array : array;
    import std.conv : to;

    static if (isArray!R)
        return tagName.splitter(":").fold!((a, b) => b);
    else
        return tagName
            .array
            .splitter(":")
            .fold!((a, b) => b)
            .to!string;
}

template allChildren(T)
{
    import std.meta : Filter;

    enum bool isChild(string name) = hasUDA!(__traits(getMember, T, name), XmlElement)
        || hasUDA!(__traits(getMember, T, name), XmlElementList);
    enum allChildren = Filter!(isChild, __traits(allMembers, T));
}

class MemoryManager
{
    import std.array : Appender, appender;
    import std.range;

    Appender!(Appender!(string[])[]) appenders;

    Appender!(string[]) getAppender()
    {
        if (this.appenders.data.empty)
            return appender!(string[]);

        auto appender = this.appenders.data.back;

        this.appenders.shrinkTo(this.appenders.data.length - 1u);

        return appender;
    }

    void releaseAppender(Appender!(string[]) appender)
    {
        appender.clear;
        this.appenders.put(appender);
    }
}

public:

/// UDA to define root node tag's name
struct XmlRoot
{
    string tagName;
}

/// UDA to define a single child node tag's name
struct XmlElement
{
    string tagName;
}

/// UDA to define a multiple children nodes tag's name
struct XmlElementList
{
    string tagName;
}

/// UDA to define attribute node where the data should be decoded
struct XmlAttr
{
    string name;
}

/// UDA to define that the data should be decoded from the node's text
enum XmlText;

/// UDA to define that all the current attributes should be decoded as an associative array
enum XmlAllAttrs;

///
class XMLDecodingException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__) @safe pure
    {
        super(msg, file, line);
    }
}

/**
 * A forward range that iterates over a `dxml.parser.EntityRange`
 * to build element of given type `S`.
 * Constructor is private, use `decodeXmlAs` instead
 * Throws: XMLDecodingException when a non optional field (not defined as `Nullable`) is missing
 */
struct DecodedXml(S, T = string) if (isDecodable!T && hasUDA!(S, XmlRoot))
{
    import dxml.parser : EntityType, EntityRange, simpleXML;

    alias Entities = EntityRange!(simpleXML, T);

private:

    Entities _entities;
    S _current;
    bool _endOfFragment;
    bool _primed;
    MemoryManager _memoryManager;

    this(Entities entities, MemoryManager memoryManager)
    {
        this._entities = entities;
        this._memoryManager = memoryManager;
    }

    void prime()
    {
        if (this._primed)
            return;
        while (!isNextEntityReached)
            this._entities.popFront();
        this._primed = true;
        if (!this._entities.empty)
            buildCurrent();
    }

    bool isNextEntityReached()
    {
        if (this._entities.empty)
            return true;
        auto entity = this._entities.front;
        return this._endOfFragment
            || (entity.type == EntityType.elementStart && entity.name.cleanNs == rootName!S);
    }

    void setLeafValue(ST)(ref ST source)
    {
        import std.algorithm : find, map;
        import std.traits : getUDAs, isAssociativeArray, KeyType, ValueType;
        import std.array : assocArray, array;
        import std.conv : to;
        import std.exception : enforce;
        import std.format : format;
        import std.typecons : tuple;
        import fantasio.lib.traits : NullableOf, isNullable;

        static foreach (m; __traits(allMembers, ST))
        {
            {
                alias Member = __traits(getMember, ST, m);
                alias MemberT = typeof(Member);

                static if (hasUDA!(Member, XmlAttr))
                {
                    auto attrs = this._entities.front.attributes
                        .find!(a => a.name.cleanNs == getUDAs!(Member, XmlAttr)[0].name);

                    static if (isNullable!MemberT)
                    {
                        alias NT = NullableOf!MemberT;
                        if (!attrs.empty)
                            __traits(getMember, source, m) = attrs.front.value.to!NT;
                    }
                    else
                    {
                        enforce!XMLDecodingException(!attrs.empty,
                            format!"Not nullable field %s not provided"(m));
                        __traits(getMember, source, m) = attrs.front.value.to!MemberT;
                    }
                }
                else static if (hasUDA!(Member, XmlText))
                {
                    auto copy = this._entities.save;
                    copy.popFront();

                    static if (isNullable!MemberT)
                    {
                        alias NT = NullableOf!MemberT;
                        if (copy.front.type == EntityType.text)
                            __traits(getMember, source, m) = copy.front.text.to!NT;
                    }
                    else
                    {
                        enforce!XMLDecodingException(copy.front.type == EntityType.text,
                            format!"Not nullable field %s not provided"(m));
                        __traits(getMember, source, m) = copy.front.text.to!MemberT;
                    }
                }
                else static if (hasUDA!(Member, XmlAllAttrs))
                {
                    static assert(isAssociativeArray!MemberT
                            && is(KeyType!MemberT : string)
                            && isDecodable!(ValueType!MemberT), "all attributes can only be decoded in an AA");

                    static if (is(ValueType : string))
                        __traits(getMember, source, m) = this._entities.front.attributes
                            .map!(a => tuple(a.name.cleanNs, a.value))
                            .assocArray;
                    else
                        __traits(getMember, source, m) = this._entities.front.attributes
                            .map!(a => tuple(a.name.cleanNs, a.value.array.to!string))
                            .assocArray;
                }
            }
        }
    }

    void setValue(ST)(ref ST source, string[] path)
    {
        import std.traits : isArray;
        import fantasio.lib.traits : isNullable, NullableOf, unpack;

        assert(path.length > 0);

        bool isLeaf = path.length == 1;

        if (!isLeaf)
            path = path[1 .. $];

        static if (isArray!ST)
        {
            alias ET = ElementType!ST;

            static assert(!isNullable!ET, "arrays of nullable are not supported");

            if (isLeaf)
            {
                auto item = ET.init;
                setValue(item, path);
                source ~= item;
            }
            else
            {
                static foreach (m; allChildren!ET)
                {
                    {
                        if (elementName!(ET, m) == path[0])
                        {
                            static assert(checkElementType!(ET, m),
                                m ~ " is not a range but is defined to be decoded as an array");

                            alias CT = typeof(__traits(getMember, source[$ - 1], m));
                            static if (isNullable!CT)
                            {
                                if (__traits(getMember, source[$ - 1], m).isNull)
                                    __traits(getMember, source[$ - 1], m) = NullableOf!CT();
                            }
                            setValue(__traits(getMember, source[$ - 1], m), path);
                        }
                    }
                }
            }
        }
        else
        {
            if (isLeaf)
            {
                static if (isNullable!ST)
                {
                    if (!source.isNull)
                        setLeafValue(source.get);
                }
                else
                    setLeafValue(source);
            }
            else
            {
                static foreach (m; unpack!(ST, allChildren))
                {
                    {
                        if (unpack!(ST, elementName, m) == path[0])
                        {
                            static assert(unpack!(ST, checkElementType, m),
                                m ~ " is a range but is defined to be decoded as a single element");

                            static if (isNullable!ST)
                                alias CT = typeof(__traits(getMember, NullableOf!ST, m));
                            else
                                alias CT = typeof(__traits(getMember, ST, m));

                            static if (isNullable!CT)
                            {
                                static if (isNullable!ST)
                                {
                                    if (__traits(getMember, source.get, m).isNull)
                                        __traits(getMember, source.get, m) = NullableOf!CT();
                                }
                                else
                                {
                                    if (__traits(getMember, source, m).isNull)
                                        __traits(getMember, source, m) = NullableOf!CT();
                                }
                            }

                            static if (isNullable!ST)
                                setValue(__traits(getMember, source.get, m), path);
                            else
                                setValue(__traits(getMember, source, m), path);
                        }
                    }
                }
            }
        }
    }

    void buildCurrent()
    {
        assert(isNextEntityReached(), "Seek entities to the right location!");

        auto path = this._memoryManager.getAppender();

        scope (exit)
            this._memoryManager.releaseAppender(path);

        _current = S();

        while (!empty)
        {
            auto entity = this._entities.front;

            if (entity.type == EntityType.elementStart)
            {
                path.put(entity.name.cleanNs);
                setValue(_current, path.data);
            }

            if (entity.type == EntityType.elementEnd)
            {
                if (path.data.length == 1)
                    break;
                path.shrinkTo(path.data.length - 1u);
            }

            this._entities.popFront();
        }
    }

public:

    /// ditto
    bool empty()
    {
        prime();
        return this._entities.empty || this._endOfFragment;
    }

    /// ditto
    ref S front()
    {
        prime();
        assert(!empty, "Fetch the front from an empty range");
        return this._current;
    }

    /// ditto
    void popFront()
    {
        prime();
        assert(!empty, "Pop the front from an empty range");

        do
        {
            this._entities.popFront();

            if (!this._entities.empty)
            {
                auto entity = this._entities.front;
                this._endOfFragment = entity.type == EntityType.elementEnd
                    && rootName!S != entity.name.cleanNs;
            }
        }
        while (!isNextEntityReached());
        buildCurrent();
    }

    /// ditto
    auto save()
    {
        auto retval = this;
        retval._entities = this._entities.save();
        return retval;
    }
}

/// Functions that build `DecodedXml` from a range of characters
DecodedXml!(S, T) decodeXmlAsRangeOf(S, T)(T xmlText) if (isDecodable!T)
{
    import dxml.parser : parseXML, simpleXML;

    auto mm = new MemoryManager;
    auto entities = parseXML!(simpleXML, T)(xmlText);
    return DecodedXml!(S, T)(entities, mm);
}

S decodeXmlAs(S, T)(T xmlText) if (isDecodable!T)
{
    import std.exception : enforce;

    auto r = decodeXmlAsRangeOf!(S, T)(xmlText);
    enforce!XMLDecodingException(!r.empty, "Could not decode XML as " ~ S.stringof);
    return r.front;
}
