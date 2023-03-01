module tests.lib.xml;

import std.typecons : Nullable;
import unit_threaded;
import fantasio.lib.xml;

@("decode a namespaced XML text")
@system unittest
{
    @XmlRoot("root")
    static struct Root {
        @XmlAttr("id")
        string id;
    }

    {
        auto r = "<ns:root id=\"0000\"></ns:root>".decodeXmlAsRangeOf!Root;
        r.empty.shouldBeFalse;
        r.front.shouldEqual(Root("0000"));
        auto c = r.save;
        r.popFront();
        r.empty.shouldBeTrue;
        c.empty.shouldBeFalse;
    }

    {
        import std.algorithm : joiner;

        auto r = ["<ns:root id=\"0000\"", "></ns:root>"].joiner.decodeXmlAsRangeOf!Root;
        r.empty.shouldBeFalse;
        r.front.shouldEqual(Root("0000"));
        r.popFront();
        r.empty.shouldBeTrue;
    }
}

@("decode a fragment of an XML text")
@system unittest
{
    @XmlRoot("foo")
    static struct Foo
    {
        @XmlAttr("id")
        uint id;
    }

    auto r = "<root><foo id=\"1\"/><foo id=\"2\"/></root>"
        .decodeXmlAsRangeOf!Foo;
    r.shouldNotBeEmpty;
    r.shouldEqual([Foo(1u), Foo(2u)]);
}

@("decode to a struct having primitive typed fields from attributes or text")
@system unittest
{
    @XmlRoot("foo")
    static struct Foo
    {
        @XmlAttr("id")
        uint id;

        @XmlText
        double value;
    }

    auto r = "<foo id=\"42\">52.6</foo>".decodeXmlAsRangeOf!Foo;
    r.shouldNotBeEmpty;
    r.front.id.shouldEqual(42u);
    r.front.value.shouldEqual(52.6);
}

@("decode a not provided non nullable field")
@system unittest
{
    @XmlRoot("foo")
    static struct Foo
    {
        @XmlAttr("id")
        uint id;

        @XmlAttr("value")
        double value;
    }

    "<foo id=\"42\"/>".decodeXmlAsRangeOf!Foo.front.shouldThrow;
    "<foo>52.6</foo>".decodeXmlAsRangeOf!Foo.front.shouldThrow;
}

@("decode to a struct having nullable-primitive fields")
@system unittest
{
    @XmlRoot("foo")
    static struct Foo
    {
        @XmlAttr("id")
        Nullable!uint id;

        @XmlText
        Nullable!double value;
    }

    Foo foo = "<foo id=\"42\"/>".decodeXmlAsRangeOf!Foo.front;
    foo.value.isNull.shouldBeTrue;
    foo.id.isNull.shouldBeFalse;
    foo.id.get.shouldEqual(42u);

    Foo other = "<foo>52.6</foo>".decodeXmlAsRangeOf!Foo.front;
    other.value.isNull.shouldBeFalse;
    other.value.get.shouldEqual(52.6);
    other.id.isNull.shouldBeTrue;
}

@("decode to a struct having a nested struct field")
@system unittest
{
    @XmlRoot("bar")
    static struct Bar
    {
        @XmlAttr("id")
        string id;
    }

    @XmlRoot("foo")
    static struct Foo
    {
        @XmlElement("bar")
        Bar bar;
    }

    Foo foo = "<foo><bar id=\"42\"/></foo>".decodeXmlAsRangeOf!Foo.front;
    foo.shouldEqual(Foo(Bar("42")));
}

@("a single element cannot be decoded to a dynamic array")
@system unittest
{
    @XmlRoot("bar")
    static struct Bar
    {
        @XmlAttr("id")
        string id;
    }

    @XmlRoot("foo")
    static struct BadFoo
    {
        @XmlElement("bar")
        Bar[] bar;
    }

    static assert(!__traits(compiles, {
        "<foo><bar id=\"42\"/></foo>".decodeXmlAsRangeOf!BadFoo.front;
    }));
}

@("decode a struct having a nested nullbale struct field")
@system unittest
{
    @XmlRoot("bar")
    static struct Bar
    {
        @XmlAttr("id")
        string id;
    }

    @XmlRoot("foo")
    static struct Foo
    {
        @XmlElement("bar")
        Nullable!Bar bar;
    }

    {
        Foo foo = "<foo><bar id=\"42\"/></foo>".decodeXmlAsRangeOf!Foo.front;
        foo.bar.isNull.shouldBeFalse;
        foo.bar.get.id.shouldEqual("42");
    }

    {
        Foo foo = "<foo></foo>".decodeXmlAsRangeOf!Foo.front;
        foo.bar.isNull.shouldBeTrue;
    }
}

@("decode a struct having deeply nested nullbale struct fields")
@system unittest
{
    @XmlRoot("baz")
    static struct Baz
    {
        @XmlAttr("id")
        Nullable!string id;
    }

    @XmlRoot("bar")
    static struct Bar
    {
        @XmlElement("baz")
        Nullable!Baz baz;
    }

    @XmlRoot("foo")
    static struct Foo
    {
        @XmlElement("bar")
        Nullable!Bar bar;
    }

    {
        Foo foo = "<foo><bar><baz id=\"42\"/></bar></foo>".decodeXmlAsRangeOf!Foo.front;
        foo.bar.isNull.shouldBeFalse;
        foo.bar.get.baz.isNull.shouldBeFalse;
        foo.bar.get.baz.get.id.isNull.shouldBeFalse;
        foo.bar.get.baz.get.id.get.shouldEqual("42");
    }

    {
        Foo foo = "<foo><bar><baz/></bar></foo>".decodeXmlAsRangeOf!Foo.front;
        foo.bar.isNull.shouldBeFalse;
        foo.bar.get.baz.isNull.shouldBeFalse;
        foo.bar.get.baz.get.id.isNull.shouldBeTrue;
    }

    {
        Foo foo = "<foo><bar></bar></foo>".decodeXmlAsRangeOf!Foo.front;
        foo.bar.isNull.shouldBeFalse;
        foo.bar.get.baz.isNull.shouldBeTrue;
    }

    {
        Foo foo = "<foo></foo>".decodeXmlAsRangeOf!Foo.front;
        foo.bar.isNull.shouldBeTrue;
    }
}

@("decode a struct having a dynamic array field")
@system unittest
{
    @XmlRoot("bar")
    static struct Bar
    {
        @XmlAttr("id")
        string id;
    }

    @XmlRoot("foo")
    static struct Foo
    {
        @XmlElementList("bar")
        Bar[] bars;
    }

    Foo foo = "<foo><bar id=\"42\"/><bar id=\"43\"/></foo>".decodeXmlAsRangeOf!Foo.front;
    foo.shouldEqual(Foo([Bar("42"), Bar("43")]));
}

@("decode a struct having a nested dynamic array")
@system unittest
{
    @XmlRoot("baz")
    static struct Baz
    {
        @XmlAttr("id")
        string id;
    }

    @XmlRoot("bar")
    static struct Bar
    {
        @XmlElementList("baz")
        Baz[] bazs;
    }

    @XmlRoot("foo")
    static struct Foo
    {
        @XmlElement("bar")
        Bar bar;
    }

    Foo foo = q{
        <foo>
            <bar>
                <baz id="42"/>
                <baz id="43"/>
            </bar>
        </foo>
    }.decodeXmlAsRangeOf!Foo.front;
    foo.shouldEqual(Foo(Bar([Baz("42"), Baz("43")])));
}

@("decode a struct having a dynamic array in a deep nullable field")
@system unittest
{
    @XmlRoot("baz")
    static struct Baz
    {
        @XmlAttr("id")
        string id;
    }

    @XmlRoot("bar")
    static struct Bar
    {
        @XmlElementList("baz")
        Baz[] bazs;
    }

    @XmlRoot("foo")
    static struct Foo
    {
        @XmlElement("bar")
        Nullable!Bar bar;
    }

    Foo foo = q{
        <foo>
            <bar>
                <baz id="42"/>
                <baz id="43"/>
            </bar>
        </foo>
    }.decodeXmlAsRangeOf!Foo.front;

    foo.bar.get.bazs.shouldEqual([Baz("42"), Baz("43")]);
}

@("decode a struct having nested dynamic arrays")
@system unittest
{
    @XmlRoot("baz")
    static struct Baz
    {
        @XmlAttr("id")
        string id;
    }

    @XmlRoot("bar")
    static struct Bar
    {
        @XmlElementList("baz")
        Baz[] bazs;
    }

    @XmlRoot("foobar")
    static struct FooBar
    {
        @XmlElementList("baz")
        Baz[] bazs;
    }

    @XmlRoot("foo")
    static struct Foo
    {

        @XmlElement("foobar")
        FooBar foobar;

        @XmlElementList("bar")
        Bar[] bar;
    }

    Foo foo = q{
        <foo>
            <foobar>
                <baz id="12"/>
            </foobar>
            <bar>
                <baz id="42"/>
                <baz id="43"/>
            </bar>
            <bar>
                <baz id="44"/>
                <baz id="45"/>
            </bar>
        </foo>
    }.decodeXmlAsRangeOf!Foo.front;

    foo.shouldEqual(Foo(FooBar([Baz("12")]), [Bar([Baz("42"), Baz("43")]), Bar([Baz("44"), Baz("45")])]));
}

@("decode all attributes to an associative array")
@system unittest
{
    @XmlRoot("foo")
    static struct Foo
    {
        @XmlAllAttrs
        string[string] attrs;
    }

    auto foo = "<foo id=\"0001\" value=\"bar\"/>".decodeXmlAsRangeOf!Foo.front;
    foo.attrs["id"].shouldEqual("0001");
    foo.attrs["value"].shouldEqual("bar");
}

@("decode all attributes to an associative array from a fragmented XML text")
@system unittest
{
    import std.algorithm : joiner;

    @XmlRoot("foo")
    static struct Foo
    {
        @XmlAllAttrs
        string[string] attrs;
    }

    auto foo = ["<foo id=\"0001\" va", "lue=\"bar\"/>"].joiner.decodeXmlAsRangeOf!Foo.front;
    foo.attrs["id"].shouldEqual("0001");
    foo.attrs["value"].shouldEqual("bar");
}

@("decode a hierarchical data structure")
@system unittest
{
    @XmlRoot("foo")
    static struct Foo
    {
        @XmlAttr("id")
        uint id;

        @XmlElementList("foo")
        Foo[] children;
    }

    auto foo = q{
        <foo id="1">
            <foo id="11"/>
            <foo id="12">
                <foo id="121"/>
            </foo>
        </foo>
    }.decodeXmlAsRangeOf!Foo.front;

    foo.children[0].id.shouldEqual(11u);
    foo.children[1].id.shouldEqual(12u);
    foo.children[1].children[0].id.shouldEqual(121u);
}

@("decode to an inappropriate struct")
@system unittest
{
    @XmlRoot("foo")
    static struct Foo
    {
        @XmlAttr("id")
        uint id;
    }

    auto foos = "<bar><baz/></bar>".decodeXmlAsRangeOf!Foo;
    foos.empty.shouldBeTrue;
}

@("decode an XML text to a single struct")
@system unittest
{
    @XmlRoot("baz")
    static struct Baz
    {
        @XmlAttr("id")
        string id;
    }

    @XmlRoot("bar")
    static struct Bar
    {
        @XmlElementList("baz")
        Baz[] bazs;
    }

    @XmlRoot("foo")
    static struct Foo
    {
        @XmlElementList("bar")
        Bar[] bar;
    }

    @XmlRoot("foobar")
    static struct FooBar
    {
        @XmlAttr("id")
        string id;
    }

    const xmlText = q{
        <foo>
            <bar>
                <baz id="42"/>
                <baz id="43"/>
            </bar>
        </foo>
    };

    xmlText.decodeXmlAs!Foo.shouldEqual(Foo([Bar([Baz("42"), Baz("43")])]));
    xmlText.decodeXmlAs!FooBar.shouldThrow;
}

@("decode a deeply nested nullable struct")
@system unittest
{
    import std.typecons : nullable;

    @XmlRoot("quz")
    static struct Quz
    {
        @XmlAttr("id")
        string id;
    }

    @XmlRoot("Baz")
    static struct Baz
    {
        @XmlElement("quz")
        Nullable!Quz quz;
    }

    @XmlRoot("Bar")
    static struct Bar
    {
        @XmlElementList("baz")
        Baz[] baz;
    }

    @XmlRoot("foo")
    static struct Foo
    {
        @XmlElement("bar")
        Nullable!Bar bar;
    }

    const xmlText = q{
        <foo>
            <bar>
                <baz>
                    <quz id="hello">
                    </quz>
                </baz>
            </bar>
        </foo>
    };

    auto foo = xmlText.decodeXmlAs!Foo;
    foo.shouldEqual(
        Foo(
            Bar(
                [
                    Baz(
                        Quz("hello").nullable
                    )
                ]
            ).nullable
        )
    );
}