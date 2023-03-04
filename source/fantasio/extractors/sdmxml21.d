module fantasio.extractors.sdmxml21;

import std.typecons : Nullable;
import std.range : isInputRange, ElementType;
import std.traits : Unqual, hasMember, hasUDA, isArray;
import fantasio.lib.xml;
import fantasio.core.model;
import fantasio.core.errors;

struct Class
{
    string name;
}

struct Package
{
    string name;
}

enum ItemScheme;

@XmlRoot("Text")
struct SDMX21Text
{
    @XmlText
    Nullable!string content;
}

@XmlRoot("ErrorMessage")
struct SDMX21ErrorMessage
{
    @XmlAttr("code")
    Nullable!string code;

    @XmlElement("Text")
    Nullable!SDMX21Text text_;
}

@XmlRoot("Error")
struct SDMX21Error_
{
    @XmlElement("ErrorMessage")
    Nullable!SDMX21ErrorMessage errorMessage;
}

@XmlRoot("Dataflow")
@Class("Dataflow")
@Package("datastructure")
struct SDMX21Dataflow
{
    @XmlAttr("id")
    Nullable!string id;

    @XmlAttr("urn")
    Nullable!string urn;

    @XmlAttr("agencyID")
    Nullable!string agencyId;

    @XmlAttr("version")
    Nullable!string version_;

    @XmlAttr("isFinal")
    Nullable!bool isFinal;

    @XmlElementList("Name")
    SDMX21Name[] names;

    @XmlElementList("Description")
    SDMX21Description[] descriptions;

    @XmlElement("Structure")
    Nullable!SDMX21Structure structure;

    @XmlElement("Ref")
    Nullable!SDMX21Ref ref_;
}

@XmlRoot("Name")
struct SDMX21Name
{
    @XmlAttr("lang")
    string lang;

    @XmlText
    string content;
}

@XmlRoot("Description")
struct SDMX21Description
{
    @XmlAttr("lang")
    string lang;

    @XmlText
    string content;
}

@XmlRoot("Structure")
struct SDMX21Structure
{
    @XmlElement("Ref")
    SDMX21Ref ref_;
}

@XmlRoot("Ref")
struct SDMX21Ref
{
    @XmlAttr("id")
    string id;

    @XmlAttr("version")
    Nullable!string version_;

    @XmlAttr("maintainableParentID")
    Nullable!string maintainableParentId;

    @XmlAttr("maintainableParentVersion")
    Nullable!string maintainableParentVersion;

    @XmlAttr("agencyID")
    Nullable!string agencyId;

    @XmlAttr("package")
    Nullable!string package_;

    @XmlAttr("class")
    Nullable!string class_;
}

@XmlRoot("ConceptIdentity")
struct SDMX21ConceptIdentity
{
    @XmlElement("Ref")
    SDMX21Ref ref_;
}

@XmlRoot("TextFormat")
struct SDMX21TextFormat
{
    @XmlAttr("textType")
    Nullable!string textType;

    @XmlAttr("minLength")
    Nullable!string minLength;

    @XmlAttr("maxLength")
    Nullable!string maxLength;

    @XmlAttr("pattern")
    Nullable!string pattern;

    @XmlAttr("minValue")
    Nullable!string minValue;

    @XmlAttr("maxValue")
    Nullable!string maxValue;
}

@XmlRoot("Enumeration")
struct SDMX21Enumeration
{
    @XmlElement("Ref")
    SDMX21Ref ref_;
}

@XmlRoot("LocalRepresentation")
struct SDMX21LocalRepresentation
{
    @XmlElement("TextFormat")
    Nullable!SDMX21TextFormat textFormat;

    @XmlElement("Enumeration")
    Nullable!SDMX21Enumeration enumeration;
}

@XmlRoot("TimeDimension")
@Class("TimeDimension")
@Package("datastructure")
@ItemScheme
struct SDMX21TimeDimension
{
    @XmlAttr("id")
    Nullable!string id;

    @XmlAttr("urn")
    Nullable!string urn;

    @XmlAttr("position")
    Nullable!int position;

    @XmlElement("ConceptIdentity")
    Nullable!SDMX21ConceptIdentity conceptIdentity;

    @XmlElement("LocalRepresentation")
    Nullable!SDMX21LocalRepresentation localRepresentation;
}

@XmlRoot("Dimension")
@Class("Dimension")
@Package("datastructure")
@ItemScheme
struct SDMX21Dimension
{
    @XmlAttr("id")
    Nullable!string id;

    @XmlAttr("urn")
    Nullable!string urn;

    @XmlAttr("position")
    Nullable!int position;

    @XmlElement("ConceptIdentity")
    Nullable!SDMX21ConceptIdentity conceptIdentity;

    @XmlElement("LocalRepresentation")
    Nullable!SDMX21LocalRepresentation localRepresentation;

    @XmlElement("Ref")
    Nullable!SDMX21Ref ref_;
}

@XmlRoot("DimensionList")
struct SDMX21DimensionList
{
    @XmlAttr("id")
    string id;

    @XmlAttr("urn")
    Nullable!string urn;

    @XmlElement("TimeDimension")
    SDMX21TimeDimension timeDimension;

    @XmlElementList("Dimension")
    SDMX21Dimension[] dimensions;
}

@XmlRoot("AttributeRelationship")
struct SDMX21AttributeRelationship
{
    @XmlElementList("Dimension")
    SDMX21Dimension[] dimensions;

    @XmlElement("PrimaryMeasure")
    Nullable!SDMX21PrimaryMeasure primaryMeasure;
}

@XmlRoot("Attribute")
@Class("DataAttribute")
@Package("datastructure")
@ItemScheme
struct SDMX21Attribute
{
    @XmlAttr("id")
    Nullable!string id;

    @XmlAttr("urn")
    Nullable!string urn;

    @XmlAttr("assignmentStatus")
    Nullable!string assignmentStatus;

    @XmlElement("ConceptIdentity")
    Nullable!SDMX21ConceptIdentity conceptIdentity;

    @XmlElement("LocalRepresentation")
    Nullable!SDMX21LocalRepresentation localRepresentation;

    @XmlElement("AttributeRelationship")
    Nullable!SDMX21AttributeRelationship attributeRelationship;

}

@XmlRoot("AttributeList")
struct SDMX21AttributeList
{
    @XmlAttr("id")
    string id;

    @XmlAttr("urn")
    Nullable!string urn;

    @XmlElementList("Attribute")
    SDMX21Attribute[] attributes;
}

@XmlRoot("DimensionReference")
struct SDMX21DimensionReference
{
    @XmlElement("Ref")
    SDMX21Ref ref_;
}

@XmlRoot("GroupDimension")
struct SDMX21GroupDimension
{
    @XmlElement("DimensionReference")
    SDMX21DimensionReference dimensionReference;
}

@XmlRoot("Group")
struct SDMX21Group
{
    @XmlAttr("urn")
    Nullable!string urn;

    @XmlAttr("id")
    string id;

    @XmlElementList("GroupDimension")
    SDMX21GroupDimension[] groupDimesions;
}

@XmlRoot("PrimaryMeasure")
@Class("PrimaryMeasure")
@Package("datastructure")
@ItemScheme
struct SDMX21PrimaryMeasure
{
    @XmlAttr("id")
    Nullable!string id;

    @XmlAttr("urn")
    Nullable!string urn;

    @XmlElement("ConceptIdentity")
    Nullable!SDMX21ConceptIdentity conceptIdentity;

    @XmlElement("LocalRepresentation")
    Nullable!SDMX21LocalRepresentation localRepresentation;

    @XmlElement("Ref")
    Nullable!SDMX21Ref ref_;
}

@XmlRoot("MeasureList")
struct SDMX21MeasureList
{
    @XmlAttr("id")
    string id;

    @XmlAttr("urn")
    Nullable!string urn;

    @XmlElement("PrimaryMeasure")
    SDMX21PrimaryMeasure primaryMeasure;
}

@XmlRoot("DataStructureComponents")
struct SDMX21DataStructureComponents
{
    @XmlElement("DimensionList")
    SDMX21DimensionList dimensionList;

    @XmlElement("AttributeList")
    Nullable!SDMX21AttributeList attributeList;

    @XmlElement("MeasureList")
    Nullable!SDMX21MeasureList measureList;

    @XmlElementList("Group")
    SDMX21Group[] groups;
}

@XmlRoot("DataStructure")
@Class("DataStructure")
@Package("datastructure")
struct SDMX21DataStructure
{
    @XmlAttr("id")
    string id;

    @XmlAttr("urn")
    Nullable!string urn;

    @XmlAttr("agencyID")
    string agencyId;

    @XmlAttr("version")
    string version_;

    @XmlElementList("Name")
    SDMX21Name[] names;

    @XmlElementList("Description")
    SDMX21Description[] descriptions;

    @XmlElement("DataStructureComponents")
    SDMX21DataStructureComponents dataStructureComponents;
}

@XmlRoot("Code")
@Class("Code")
@Package("codelist")
@ItemScheme
struct SDMX21Code
{
    @XmlAttr("id")
    string id;

    @XmlAttr("urn")
    Nullable!string urn;

    @XmlElementList("Name")
    SDMX21Name[] names;

    @XmlElementList("Description")
    SDMX21Description[] descriptions;
}

@XmlRoot("Codelist")
@Class("Codelist")
@Package("codelist")
struct SDMX21Codelist
{
    @XmlAttr("id")
    string id;

    @XmlAttr("urn")
    Nullable!string urn;

    @XmlAttr("agencyID")
    string agencyId;

    @XmlAttr("version")
    string version_;

    @XmlElementList("Name")
    SDMX21Name[] names;

    @XmlElementList("Description")
    SDMX21Description[] descriptions;

    @XmlElementList("Code")
    SDMX21Code[] codes;
}

@XmlRoot("Concept")
@Class("Concept")
@Package("conceptscheme")
@ItemScheme
struct SDMX21Concept
{
    @XmlAttr("id")
    string id;

    @XmlAttr("urn")
    Nullable!string urn;

    @XmlElementList("Name")
    SDMX21Name[] names;

    @XmlElementList("Description")
    SDMX21Description[] descriptions;
}

@XmlRoot("ConceptScheme")
@Class("ConceptScheme")
@Package("conceptscheme")
struct SDMX21ConceptScheme
{
    @XmlAttr("id")
    string id;

    @XmlAttr("urn")
    Nullable!string urn;

    @XmlAttr("agencyID")
    string agencyId;

    @XmlAttr("version")
    string version_;

    @XmlElementList("Name")
    SDMX21Name[] names;

    @XmlElementList("Description")
    SDMX21Description[] descriptions;

    @XmlElementList("Concept")
    SDMX21Concept[] concepts;
}

@XmlRoot("Category")
@Class("Category")
@Package("categoryscheme")
@ItemScheme
struct SDMX21Category
{
    @XmlAttr("id")
    string id;

    @XmlAttr("urn")
    Nullable!string urn;

    @XmlElementList("Name")
    SDMX21Name[] names;

    @XmlElementList("Description")
    SDMX21Description[] descriptions;

    @XmlElementList("Category")
    SDMX21Category[] children;
}

@XmlRoot("CategoryScheme")
@Class("CategoryScheme")
@Package("categoryscheme")
struct SDMX21CategoryScheme
{
    @XmlAttr("id")
    string id;

    @XmlAttr("urn")
    Nullable!string urn;

    @XmlAttr("agencyID")
    string agencyId;

    @XmlAttr("version")
    string version_;

    @XmlElementList("Name")
    SDMX21Name[] names;

    @XmlElementList("Description")
    SDMX21Description[] descriptions;

    @XmlElementList("Category")
    SDMX21Category[] categories;
}

@XmlRoot("Source")
struct SDMX21Source
{
    @XmlElement("Ref")
    SDMX21Ref ref_;
}

@XmlRoot("Target")
struct SDMX21Target
{
    @XmlElement("Ref")
    SDMX21Ref ref_;
}

@XmlRoot("Categorisation")
@Class("Categorisation")
@Package("categoryscheme")
struct SDMX21Categorisation
{
    @XmlAttr("id")
    string id;

    @XmlAttr("urn")
    Nullable!string urn;

    @XmlAttr("agencyID")
    string agencyId;

    @XmlAttr("version")
    string version_;

    @XmlElementList("Name")
    SDMX21Name[] names;

    @XmlElementList("Description")
    SDMX21Description[] descriptions;

    @XmlElement("Source")
    SDMX21Source source;

    @XmlElement("Target")
    SDMX21Target target;
}

@XmlRoot("Categorisations")
struct SDMX21Categorisations
{
    @XmlElementList("Categorisation")
    SDMX21Categorisation[] categorisations;
}

@XmlRoot("Codelists")
struct SDMX21Codelists
{
    @XmlElementList("Codelist")
    SDMX21Codelist[] codelists;
}

@XmlRoot("Concepts")
struct SDMX21Concepts
{
    @XmlElementList("ConceptScheme")
    SDMX21ConceptScheme[] conceptSchemes;
}

@XmlRoot("DataStructures")
struct SDMX21DataStructures
{
    @XmlElementList("DataStructure")
    SDMX21DataStructure[] dataStructures;
}

@XmlRoot("Dataflows")
struct SDMX21Dataflows
{
    @XmlElementList("Dataflow")
    SDMX21Dataflow[] dataflows;
}

@XmlRoot("CategorySchemes")
struct SDMX21CategorySchemes
{
    @XmlElementList("CategoryScheme")
    SDMX21CategoryScheme[] categorySchemes;
}

@XmlRoot("KeyValue")
struct SDMX21KeyValue
{
    @XmlAttr("id")
    string id;

    @XmlElementList("Value")
    SDMX21Value[] values;
}

@XmlRoot("ConstraintAttachment")
struct SDMX21ConstraintAttachment
{
    @XmlElementList("Dataflow")
    SDMX21Dataflow[] dataflows;
}

@XmlRoot("CubeRegion")
struct SDMX21CubeRegion
{
    @XmlAttr("include")
    Nullable!bool include;

    @XmlElementList("KeyValue")
    SDMX21KeyValue[] keyValues;
}

@XmlRoot("ContentConstraint")
struct SDMX21ContentConstraint
{
    @XmlAttr("id")
    Nullable!string id;

    @XmlAttr("urn")
    Nullable!string urn;

    @XmlAttr("isExternalReference")
    Nullable!bool isExternalReference;

    @XmlAttr("agencyID")
    Nullable!string agencyId;

    @XmlAttr("version")
    Nullable!string version_;

    @XmlAttr("isFinal")
    Nullable!bool isFinal;

    @XmlAttr("type")
    Nullable!string type;

    @XmlElementList("Name")
    SDMX21Name[] names;

    @XmlElementList("Description")
    SDMX21Description[] descriptions;

    @XmlElement("ConstraintAttachment")
    Nullable!SDMX21ConstraintAttachment constraintAttachment;

    @XmlElement("CubeRegion")
    Nullable!SDMX21CubeRegion cubeRegion;
}

@XmlRoot("Constraints")
struct SDMX21Constraints
{
    @XmlElementList("ContentConstraint")
    SDMX21ContentConstraint[] constraints;
}

@XmlRoot("Agency")
@Class("Agency")
@Package("base")
@ItemScheme
struct SDMX21Agency
{
    @XmlAttr("id")
    string id;

    @XmlAttr("urn")
    string urn;

    @XmlElementList("Name")
    SDMX21Name[] names;

    @XmlElementList("Description")
    SDMX21Description[] descriptions;
}

@XmlRoot("AgencyScheme")
@Class("AgencyScheme")
@Package("base")
struct SDMX21AgencyScheme
{
    @XmlAttr("id")
    string id;

    @XmlAttr("urn")
    string urn;

    @XmlAttr("agencyID")
    string agencyId;

    @XmlAttr("version")
    string version_;

    @XmlAttr("isFinal")
    Nullable!bool isFinal;

    @XmlElementList("Name")
    SDMX21Name[] names;

    @XmlElementList("Agency")
    SDMX21Agency[] agencies;
}

@XmlRoot("OrganisationSchemes")
struct SDMX21OrganisationSchemes
{
    @XmlElementList("AgencyScheme")
    SDMX21AgencyScheme[] agencySchemes;
}

@XmlRoot("Structures")
struct SDMX21Structures
{
    @XmlElement("Codelists")
    Nullable!SDMX21Codelists codelists;

    @XmlElement("Concepts")
    Nullable!SDMX21Concepts concepts;

    @XmlElement("DataStructures")
    Nullable!SDMX21DataStructures dataStructures;

    @XmlElement("Dataflows")
    Nullable!SDMX21Dataflows dataflows;

    @XmlElement("CategorySchemes")
    Nullable!SDMX21CategorySchemes categorySchemes;

    @XmlElement("Constraints")
    Nullable!SDMX21Constraints constraints;

    @XmlElement("Categorisations")
    Nullable!SDMX21Categorisations categorisations;

    @XmlElement("OrganisationSchemes")
    Nullable!SDMX21OrganisationSchemes organisationSchemes;
}

@XmlRoot("Value")
struct SDMX21Value
{
    @XmlAttr("id")
    Nullable!string id;

    @XmlAttr("value")
    Nullable!string value;

    @XmlText
    Nullable!string content;
}

@XmlRoot("SeriesKey")
struct SDMX21SeriesKey
{
    @XmlElementList("Value")
    SDMX21Value[] values;
}

@XmlRoot("Attributes")
struct SDMX21Attributes
{
    @XmlElementList("Value")
    SDMX21Value[] values;
}

@XmlRoot("ObsDimension")
struct SDMX21ObsDimension
{
    @XmlAttr("value")
    string value;
}

@XmlRoot("ObsValue")
struct SDMX21ObsValue
{
    @XmlAttr("value")
    Nullable!double value;
}

@XmlRoot("Obs")
struct SDMX21Obs
{
    @XmlElement("ObsDimension")
    Nullable!SDMX21ObsDimension obsDimension;

    @XmlElement("ObsValue")
    Nullable!SDMX21ObsValue obsValue;

    @XmlElement("Attributes")
    Nullable!SDMX21Attributes attributes;

    @XmlAllAttrs
    string[string] structureAttributes;
}

@XmlRoot("Series")
struct SDMX21Series
{
    @XmlElement("SeriesKey")
    Nullable!SDMX21SeriesKey seriesKey;

    @XmlElement("Attributes")
    Nullable!SDMX21Attributes attributes;

    @XmlElementList("Obs")
    SDMX21Obs[] observations;

    @XmlAllAttrs
    string[string] structureKeys;
}

@XmlRoot("DataSet")
struct SDMX21DataSet
{
    @XmlAttr("structureRef")
    Nullable!string structureRef;

    @XmlElementList("Series")
    SDMX21Series[] series;
}

Item!Dataset toItem(const ref SDMX21Dataflow dataflow, Language lang) pure @safe
{
    import std.typecons : nullable;
    import std.exception : enforce;
    import fantasio.core.label : extractLanguage;

    enforce!NotIdentifiableSource(!dataflow.id.isNull, "");

    auto name = dataflow.names.dup.extractLanguage!"lang"(lang);
    enforce!LanguageNotFound(!name.isNull, lang);

    return Item!Dataset(Dataset(dataflow.id.get, name.get.content.nullable));
}

/// Convert a range of dataflows to a collection of datasets
Collection!Dataset toCollection(R)(auto ref R dataflows, Language lang = DefaultLanguage)
        if ((isInputRange!R || isArray!R) && is(Unqual!(ElementType!R) == SDMX21Dataflow))
{
    import std.algorithm : map;
    import std.array : array;

    return Collection!Dataset(
        (Nullable!string).init,
        [],
        Link!Dataset(dataflows.array.map!(df => df.toItem(lang)).array)
    );
}
