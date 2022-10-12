import std.array : array;
import std.stdio : writeln;
import fantasio.lib.xml;

@XmlRoot("bar")
static struct Bar
{
    @XmlAttr("id")
    uint id;
}

@XmlRoot("foo")
static struct Foo
{
    @XmlAttr("id")
    uint id;

    @XmlElementList("bar")
    LazyList!(Bar, string) bars;
}

void main()
{
    auto foos = q{
        <root>
            <foo id="1">
                <bar id="42"/>
                <bar id="43"/>
                <bar id="44"/>
                <bar id="45"/>
            </foo>
            <foo id="2">
                <bar id="46"/>
                <bar id="47"/>
                <bar id="48"/>
                <bar id="49"/>
            </foo>
        </root>
    }.decodeXmlAs!Foo;
    writeln(foos);
}
