module tests.lib.xml;

import std.typecons : Nullable;
import unit_threaded;
import fantasio.lib.xml;

@("a decoded XML range can be constructed from a range of characters and be namespace agnostic")
@system unittest
{
    @XmlRoot("root")
    static struct Root {
        @XmlAttr("id")
        string id;
    }

    {
        auto r = "<ns:root id=\"0000\"></ns:root>".decodeXmlAs!Root;
        r.shouldNotBeEmpty;
        r.front.shouldEqual(Root("0000"));
        auto c = r.save;
        r.popFront();
        r.shouldBeEmpty;
        c.shouldNotBeEmpty;
    }

    {
        import std.algorithm : joiner;

        auto r = ["<ns:root id=\"0000\"", "></ns:root>"].joiner.decodeXmlAs!Root;
        r.shouldNotBeEmpty;
        r.front.shouldEqual(Root("0000"));
        r.popFront();
        r.shouldBeEmpty;
    }
}

@("a fragment of an xml text can be decoded")
@system unittest
{
    @XmlRoot("foo")
    static struct Foo
    {
        @XmlAttr("id")
        uint id;
    }

    auto r = "<root><foo id=\"1\"/><foo id=\"2\"/></root>"
        .decodeXmlAs!Foo;
    r.shouldNotBeEmpty;
    r.shouldEqual([Foo(1u), Foo(2u)]);
}

@("a decoded struct can have primitive typed field from either attributes or text")
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

    auto r = "<foo id=\"42\">52.6</foo>".decodeXmlAs!Foo;
    r.shouldNotBeEmpty;
    r.front.id.shouldEqual(42u);
    r.front.value.shouldEqual(52.6);
}

@("a decoding operation must fail when a non nullable field is not provided")
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

    "<foo id=\"42\"/>".decodeXmlAs!Foo.front.shouldThrow;
    "<foo>52.6</foo>".decodeXmlAs!Foo.front.shouldThrow;
}

@("a decoded struct can have a nullable-primitive field")
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

    Foo foo = "<foo id=\"42\"/>".decodeXmlAs!Foo.front;
    foo.value.isNull.shouldBeTrue;
    foo.id.isNull.shouldBeFalse;
    foo.id.get.shouldEqual(42u);

    Foo other = "<foo>52.6</foo>".decodeXmlAs!Foo.front;
    other.value.isNull.shouldBeFalse;
    other.value.get.shouldEqual(52.6);
    other.id.isNull.shouldBeTrue;
}

@("a decoded struct can have a nested struct field")
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

    Foo foo = "<foo><bar id=\"42\"/></foo>".decodeXmlAs!Foo.front;
    foo.shouldEqual(Foo(Bar("42")));
}

@("the program must not compile if a single element is defined to be decoded as a range")
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
        "<foo><bar id=\"42\"/></foo>".decodeXmlAs!BadFoo.front;
    }));
}

@("a decoded struct can have a nested nullbale struct field")
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
        Foo foo = "<foo><bar id=\"42\"/></foo>".decodeXmlAs!Foo.front;
        foo.bar.isNull.shouldBeFalse;
        foo.bar.get.id.shouldEqual("42");
    }

    {
        Foo foo = "<foo></foo>".decodeXmlAs!Foo.front;
        foo.bar.isNull.shouldBeTrue;
    }
}

@("a decoded struct can have a nested nullbale struct fields on multiple level")
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
        Foo foo = "<foo><bar><baz id=\"42\"/></bar></foo>".decodeXmlAs!Foo.front;
        foo.bar.isNull.shouldBeFalse;
        foo.bar.get.baz.isNull.shouldBeFalse;
        foo.bar.get.baz.get.id.isNull.shouldBeFalse;
        foo.bar.get.baz.get.id.get.shouldEqual("42");
    }

    {
        Foo foo = "<foo><bar><baz/></bar></foo>".decodeXmlAs!Foo.front;
        foo.bar.isNull.shouldBeFalse;
        foo.bar.get.baz.isNull.shouldBeFalse;
        foo.bar.get.baz.get.id.isNull.shouldBeTrue;
    }

    {
        Foo foo = "<foo><bar></bar></foo>".decodeXmlAs!Foo.front;
        foo.bar.isNull.shouldBeFalse;
        foo.bar.get.baz.isNull.shouldBeTrue;
    }

    {
        Foo foo = "<foo></foo>".decodeXmlAs!Foo.front;
        foo.bar.isNull.shouldBeTrue;
    }
}

@("a decoded struct can have a dynamic array field")
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

    Foo foo = "<foo><bar id=\"42\"/><bar id=\"43\"/></foo>".decodeXmlAs!Foo.front;
    foo.shouldEqual(Foo([Bar("42"), Bar("43")]));
}

@("a decoded struct can have a dynamic array in a nested field")
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
    }.decodeXmlAs!Foo.front;
    foo.shouldEqual(Foo(Bar([Baz("42"), Baz("43")])));
}

@("a decoded struct can have a dynamic array in a nullable nested field")
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
    }.decodeXmlAs!Foo.front;

    foo.bar.get.bazs.shouldEqual([Baz("42"), Baz("43")]);
}

@("a decoded struct can have nested dynamic arrays")
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

    Foo foo = q{
        <foo>
            <bar>
                <baz id="42"/>
                <baz id="43"/>
            </bar>
            <bar>
                <baz id="44"/>
                <baz id="45"/>
            </bar>
        </foo>
    }.decodeXmlAs!Foo.front;

    foo.shouldEqual(Foo([Bar([Baz("42"), Baz("43")]), Bar([Baz("44"), Baz("45")])]));
}

@("a decoded struct can have a lazy range field")
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
        LazyList!(Bar, string) bars;
    }

    Foo foo = "<foo><bar id=\"42\"/><bar id=\"43\"/></foo>".decodeXmlAs!Foo.front;
    foo.bars.shouldEqual([Bar("42"), Bar("43")]);
}

@("a decoded struct can have nested lazy ranges")
@system unittest
{
    @XmlRoot("baz")
    static struct Baz
    {
        @XmlAttr("id")
        uint id;
    }

    @XmlRoot("bar")
    static struct Bar
    {
        @XmlElementList("baz")
        LazyList!(Baz, string) bazs;
    }

    @XmlRoot("foo")
    static struct Foo
    {
        @XmlElementList("bar")
        LazyList!(Bar, string) bars;
    }

    Foo foo = q{
        <foo>
            <bar>
                <baz id="42"/>
                <baz id="43"/>
            </bar>
            <bar>
                <baz id="44"/>
                <baz id="45"/>
            </bar>
        </foo>
    }.decodeXmlAs!Foo.front;

    foo.bars.front.bazs.shouldEqual([Baz(42u), Baz(43u)]);
    foo.bars.popFront();
    foo.bars.front.bazs.shouldEqual([Baz(44u), Baz(45u)]);
}

@("a decoded struct can have many lazy range fields")
@system unittest
{
    @XmlRoot("baz")
    static struct Baz
    {
        @XmlAttr("id")
        uint id;
    }

    @XmlRoot("bar")
    static struct Bar
    {
        @XmlAttr("id")
        uint id;
    }

    @XmlRoot("foo")
    static struct Foo
    {
        @XmlElementList("bar")
        LazyList!(Bar, string) bars;

        @XmlElementList("baz")
        LazyList!(Baz, string) bazs;
    }

    Foo foo = q{
        <foo>
            <bar id="42"/>
            <bar id="43"/>
            <baz id="44"/>
            <baz id="45"/>
        </foo>
    }.decodeXmlAs!Foo.front;

    foo.bars.shouldEqual([Bar(42u), Bar(43u)]);
    foo.bazs.shouldEqual([Baz(44u), Baz(45u)]);
}

@("a range of decoded struct can have a nested lazy range field")
@system unittest
{
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

    foos.front.id.shouldEqual(1u);
    foos.front.bars.shouldEqual([Bar(42u), Bar(43u), Bar(44u), Bar(45u)]);
    foos.popFront();
    foos.front.id.shouldEqual(2u);
    foos.front.bars.shouldEqual([Bar(46u), Bar(47u), Bar(48u), Bar(49u)]);
}

@("A decoded struct having lazy ranges can be decoded from a range of characters")
@system unittest
{
    import std.algorithm : joiner;

    @XmlRoot("bar")
    static struct Bar
    {
        @XmlAttr("id")
        uint id;
    }

    @XmlRoot("foo")
    static struct Foo(R)
    {
        @XmlAttr("id")
        uint id;

        @XmlElementList("bar")
        LazyList!(Bar, R) bars;
    }

    auto foos = ["<foo id=\"1\"><bar id=\"42\"", "/><bar id=\"43\"/></foo>"]
        .joiner
        .decodeXmlAs!Foo;
    foos.front.id.shouldEqual(1u);
    foos.front.bars.shouldEqual([Bar(42u), Bar(43u)]);
}