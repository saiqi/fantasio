module fantasio.core.model;

import std.typecons : Nullable;
import std.sumtype : SumType;
import std.datetime : Date;

enum Language : string
{
    en = "en",
    fr = "fr",
    de = "de",
    es = "es"
}

enum DefaultLanguage = Language.en;

enum version_ = "2.0";

enum PositionType : string
{
    start = "start",
    end = "end"
}

struct Role
{
    string[] time;
    string[] geo;
    string[] metric;
}

struct Coordinates
{
    double longitude;
    double latitude;
}

struct Unit
{
    Nullable!string label;
    int decimals;
    PositionType position;
}

struct Category
{
    string[] index;
    string[string] label;
    string[] note;
    Coordinates[string] coordinates;
    Unit[string] unit;
    string[] child;

    this(this) @safe pure
    {
        index = index.dup;
        label = label.dup;
        note = note.dup;
        coordinates = coordinates.dup;
        unit = unit.dup;
        child = child.dup;
    }
}

alias ItemT = SumType!(Collection, Dataset, Dimension);

struct Item
{
    ItemT obj;
    Nullable!string type;

    this(this) @safe pure
    {
    }
}

struct Link
{
    Item[] items;

    this(this) @safe pure
    {
        items = items.dup;
    }
}

struct Dimension
{
    Nullable!string label;
    string[] note;
    Category category;
    Nullable!Date updated;
    Nullable!string source;
    Nullable!Link link;

    this(this) @safe pure
    {
        note = note.dup;
    }
}

struct Dataset
{
    string id;
    Nullable!string label;
    string[] note;
    Nullable!Date updated;
    Nullable!string source;
    SumType!(Nullable!double, Nullable!string)[] value;
    int[] size;
    Nullable!Role role;
    Dimension[string] dimension;
    Nullable!Link link;

    this(this) @safe pure
    {
        note = note.dup;
        value = value.dup;
        size = size.dup;
        dimension = dimension.dup;
    }
}

struct Collection
{
    Nullable!string label;
    string[] note;
    Link link;
    Nullable!Date updated;
    Nullable!string source;

    this(this) @safe pure
    {
        note = note.dup;
    }
}
