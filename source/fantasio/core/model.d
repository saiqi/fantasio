module fantasio.core.model;

import std.typecons : Nullable;
import std.sumtype : SumType;
import std.datetime : Date;
import std.traits : TemplateOf;

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
    string[int] index;
    string[string] label;
    string[] note;
    Coordinates[string] coordinates;
    Unit[string] unit;
    string[] child;
}

private template isCollectionnable(T)
{
    enum bool isCollectionnable = __traits(isSame, TemplateOf!T, Collection) || is(T == Dimension) || is(
            T == Dataset);
}

struct Item(T) if (isCollectionnable!T)
{
    T obj;
    Nullable!string type;
}

struct Link(T) if (isCollectionnable!T)
{
    Item!T[] items;
}

struct Dimension
{
    Nullable!string label;
    string[] note;
    Category category;
    Nullable!Date updated;
    Nullable!string source;
    Nullable!(Link!Dataset) link;
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
    Nullable!(Link!Dimension) link;
}

struct Collection(T) if (isCollectionnable!T)
{
    Nullable!string label;
    string[] note;
    Link!T link;
    Nullable!Date updated;
    Nullable!string source;
}
