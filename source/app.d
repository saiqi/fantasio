import std.array : array;
import std.stdio : writeln;
import fantasio.lib.xml;

@XmlRoot("bar")
struct Bar
{
	@XmlAttr("id")
	string id;
}

@XmlRoot("foo")
struct Foo
{
	@XmlElementList("bar")
	DecodedXml!(Bar, string) bars;
	// Bar[] bars;
}

void main()
{
	immutable xmlText = "<foo><bar id=\"0\"/><bar id=\"1\"/></foo>";
	Foo foo = xmlText.decodeXmlAs!Foo.front;
	writeln(foo.bars);
}
