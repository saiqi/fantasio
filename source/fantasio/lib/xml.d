module fantasio.lib.xml;

import std.typecons : Nullable;
import std.range : isForwardRange, ElementType;
import std.traits : isSomeChar, hasUDA;
import dxml.parser : simpleXML, parseXML, EntityRange;

private:
enum bool isDecodable(T) = isForwardRange!T && isSomeChar!(ElementType!T);

enum bool isDecodedRange(R) = is(R : DecodedXml!(S, T), S, T);

template rootName(T) if(hasUDA!(T, XmlRoot))
{
    import std.traits : isArray, getUDAs;
    import std.range : ElementType;
    static if(isArray!T || isDecodedRange!T)
        enum rootName = getUDAs!(ElementType!T, XmlRoot)[0].tagName;
    else
        enum rootName = getUDAs!(T, XmlRoot)[0].tagName;
}

template elementName(T, string name)
{
    import std.traits : getUDAs;

    alias member = __traits(getMember, T, name);

    static if(hasUDA!(member, XmlElement))
        enum elementName = getUDAs!(member, XmlElement)[0].tagName;
    else static if(hasUDA!(member, XmlElementList))
        enum elementName = getUDAs!(member, XmlElementList)[0].tagName;
    else
        static assert(false);
}

template checkElementType(T, string name)
{
    import std.traits : isArray;

    alias member = __traits(getMember, T, name);
    enum bool isList = isArray!(typeof(member)) || isDecodedRange!(typeof(member));

    static if(hasUDA!(member, XmlElement))
        enum bool checkElementType = !isList;
    else static if(hasUDA!(member, XmlElementList))
        enum bool checkElementType = isList;
    else
        static assert(false);
}

auto cleanNs(R)(R tagName) if(isDecodable!R)
{
    import std.algorithm : splitter, fold;
    import std.range : hasSlicing;
    import std.array : array;

    static if(hasSlicing!R)
        return tagName.splitter(":").fold!((a, b) => b);
    else
        return tagName.array.splitter(":").fold!((a, b) => b);
}

template allChildren(T)
{
    import std.meta : Filter;

    enum bool isChild(string name) = hasUDA!(__traits(getMember, T, name), XmlElement)
        || hasUDA!(__traits(getMember, T, name), XmlElementList);
    enum allChildren = Filter!(isChild, __traits(allMembers, T));
}

public:
struct XmlRoot
{
    string tagName;
}

struct XmlElement
{
    string tagName;
}

struct XmlElementList
{
    string tagName;
}

struct XmlAttr
{
    string name;
}

enum XmlText;

enum XmlAllAttrs;

class XMLDecodingException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__) @safe pure
    {
        super(msg, file, line);
    }
}

struct DecodedXml(S, T) if(isDecodable!T && hasUDA!(S, XmlRoot))
{
    import dxml.parser : EntityType;

    alias Entities = EntityRange!(simpleXML, T);

private:

    Entities _entities;
    S _current;

    this(Entities entities)
    {
        this._entities = entities;
        prime();
    }

    void prime()
    {
        while(!isNextEntityReached)
            this._entities.popFront();

        buildCurrent();
    }

    bool isNextEntityReached()
    {
        return this._entities.empty
        || (this._entities.front.type == EntityType.elementStart && this._entities.front.name.cleanNs == rootName!S);
    }

    void setLeafValue(ST)(ref ST source)
    {
        import std.algorithm : find, equal;
        import std.traits : getUDAs;
        import std.conv : to;
        import std.exception : enforce;
        import std.format : format;
        import fantasio.lib.types : NullableOf, isNullable;

        static foreach (m; __traits(allMembers, ST))
        {{
            alias Member = __traits(getMember, ST, m);
            alias MemberT = typeof(Member);

            static if(hasUDA!(Member, XmlAttr))
            {
                auto attrs = this._entities.front.attributes
                    .find!(a => a.name.cleanNs.equal(getUDAs!(Member, XmlAttr)[0].name));

                static if(isNullable!MemberT)
                {
                    alias NT = NullableOf!MemberT;
                    if(!attrs.empty)
                        __traits(getMember, source, m) = attrs.front.value.to!NT;
                }
                else
                {
                    enforce!XMLDecodingException(!attrs.empty,
                        format!"Not nullable field %s not provided"(m));
                    __traits(getMember, source, m) = attrs.front.value.to!MemberT;
                }
            }
            else static if(hasUDA!(Member, XmlText))
            {
                auto copy = this._entities.save;
                copy.popFront();

                static if(isNullable!MemberT)
                {
                    alias NT = NullableOf!MemberT;
                    if(copy.front.type == EntityType.text)
                        __traits(getMember, source, m) = copy.front.text.to!NT;
                }
                else
                {
                    enforce!XMLDecodingException(copy.front.type == EntityType.text,
                        format!"Not nullable field %s not provided"(m));
                    __traits(getMember, source, m) = copy.front.text.to!MemberT;
                }
            }
        }}
    }

    void setValue(ST, Path)(ref ST source, Path path)
    {
        import std.traits : isArray;
        import fantasio.lib.types : isNullable, NullableOf, unpack;

        assert(path.length > 0);

        bool isLeaf = path.length == 1;

        static if(isDecodedRange!ST)
        {

        }
        else static if(isArray!ST)
        {
            alias ET = ElementType!ST;

            if(isLeaf)
            {
                auto item = ET();
                setValue(item, path);
                source ~= item;
            }
            else
            {
                path = path[1 .. $];

                static foreach (m; allChildren!ET)
                {{
                    if(elementName!(ET, m) == path[0])
                    {
                        static assert(checkElementType!(ET, m),
                            m ~ " is not a range but is defined to be decoded as an array");

                        alias CT = typeof(__traits(getMember, source[$ - 1], m));
                        static if(isNullable!CT)
                        {
                            if(__traits(getMember, source[$ - 1], m).isNull)
                                __traits(getMember, source[$ - 1], m) = NullableOf!CT();
                        }
                        setValue(__traits(getMember, source[$ - 1], m), path);
                    }
                }}
            }
        }
        else
        {
            if(isLeaf)
                setLeafValue(source);
            else
            {
                path = path[1 .. $];

                static foreach (m; unpack!(ST, allChildren))
                {{
                    if(unpack!(ST, elementName, m) == path[0])
                    {
                        static assert(unpack!(ST, checkElementType, m),
                            m ~ " is a range but is defined to be decoded as a single element");

                        alias CT = typeof(__traits(getMember, ST, m));

                        static if(isNullable!CT)
                        {
                            if(__traits(getMember, source, m).isNull)
                                __traits(getMember, source, m) = NullableOf!CT();
                            setValue(__traits(getMember, source, m).get, path);
                        }
                        else
                            setValue(__traits(getMember, source, m), path);
                    }
                }}
            }
        }
    }

    void buildCurrent()
    {
        import std.array : Appender;

        assert(isNextEntityReached(), "Seek entities to the right location!");

        alias PathT = typeof(this._entities.front.name.cleanNs);
        Appender!(PathT[]) path;
        path.reserve(42);

        _current = S();

        while(!empty)
        {
            auto entity = this._entities.front;

            if(entity.type == EntityType.elementStart)
            {
                path.put(entity.name.cleanNs);
                setValue(_current, path.data);
            }

            if(entity.type == EntityType.elementEnd)
            {
                path.shrinkTo(path.data.length - 1u);
                if(entity.name.cleanNs == rootName!S) break;
            }

            this._entities.popFront();
        }
    }

public:

    bool empty() inout
    {
        return this._entities.empty;
    }

    ref S front()
    {
        assert(!empty, "Fetch the front from an empty range");
        return this._current;
    }

    void popFront()
    {
        assert(!empty, "Pop the front from an empty range");

        do
            this._entities.popFront();
        while(!isNextEntityReached());
        buildCurrent();
    }

    auto save()
    {
        auto retval = this;
        retval._entities = this._entities.save();
        return retval;
    }
}

DecodedXml!(S, T) decodeXmlAs(S, T)(T xmlText)
if(isDecodable!T && hasUDA!(S, XmlRoot))
{
    auto entities = parseXML!(simpleXML, T)(xmlText);
    return DecodedXml!(S, T)(entities);
}
