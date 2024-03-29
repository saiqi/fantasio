module fantasio.extractors.sdmxml21;

import std.sumtype : SumType;
import std.functional : partial;
import std.typecons : Nullable, Flag, No, Tuple;
import std.traits : Unqual;
import vibe.core.concurrency : Future;
import fantasio.lib.traits : isIterableOf;
import fantasio.core.model;
import fantasio.core.errors;
import fantasio.lib.xml;

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

@safe pure private bool isValidForLookup(const ref SDMX21Ref ref_)
{
    return !ref_.agencyId.isNull
        && !ref_.class_.isNull
        && !ref_.package_.isNull
        && !ref_.version_.isNull;
}

@safe pure private bool isValidForSchemeLookup(const ref SDMX21Ref ref_)
{
    return ref_.isValidForLookup
        && !ref_.maintainableParentId.isNull
        && !ref_.maintainableParentVersion.isNull;
}

@safe pure private string getUrn(const ref SDMX21Ref ref_)
{
    import std.format : format;
    import std.exception : enforce;

    enforce!NotIdentifiableSource(
        ref_.isValidForLookup, "Missing mandatory fields to determine Ref URN");

    switch (ref_.class_.get)
    {
    case "Dataflow":
        return format!"urn:sdmx:org.sdmx.infomodel.%s.%s=%s:%s:(%s)"(
            ref_.package_.get,
            ref_.class_.get,
            ref_.agencyId.get,
            ref_.id,
            ref_.version_.get
        );

    case "Category":
        enforce!NotIdentifiableSource(
            ref_.isValidForSchemeLookup, "Missing mandatory scheme related fields to determine Ref URN");
        return format!"urn:sdmx:org.sdmx.infomodel.%s.%s=%s:%s:(%s).%s"(
            ref_.package_.get,
            ref_.class_.get,
            ref_.agencyId.get,
            ref_.maintainableParentId.get,
            ref_.maintainableParentVersion.get,
            ref_.id
        );
    default:
        enforce!NotIdentifiableSource(false, format!"%s URN from Ref is not implemented"(
                ref_.class_.get));
    }
    assert(false);
}

@safe pure private Tuple!(string, string, string) categorisationKey(
    const ref SDMX21Categorisation c)
in (c.source.ref_.isValidForLookup, "source reference nullable fields have not been checked")
{
    return typeof(return)(c.source.ref_.id, c.source.ref_.agencyId.get, c.source.ref_.version_.get);
}

@safe pure private Tuple!(string, string, string) dataflowKey(const ref SDMX21Dataflow df)
in (!df.id.isNull && !df.agencyId.isNull && !df.version_.isNull, "dataflow nullable fields have not been checked")
{
    return typeof(return)(df.id.get, df.agencyId.get, df.version_.get);
}

private auto getDataflowsByCategoryId(RDF, RC)(
    auto ref RDF dataflows,
    auto ref RC categorisations,
    const ref SDMX21Category category,
    const ref SDMX21CategoryScheme scheme,
) if (isIterableOf!(RDF, SDMX21Dataflow)
    && isIterableOf!(RC, SDMX21Categorisation))
{
    import std.algorithm : sort, filter, map, uniq;
    import std.array : array;
    import fantasio.lib.operations : leftouterjoin;

    return categorisations
        .filter!(c =>
                c.target.ref_.isValidForSchemeLookup
                && c.source.ref_.isValidForLookup
                && c.target.ref_.id == category.id
                && c.target.ref_.agencyId.get == scheme.agencyId
                && c.target.ref_.maintainableParentId.get == scheme.id
                && c.target.ref_.maintainableParentVersion.get == scheme.version_
                && c.target.ref_.package_.get == "categoryscheme"
                && c.target.ref_.class_.get == "Category"
                && c.source.ref_.package_.get == "datastructure"
                && c.source.ref_.class_.get == "Dataflow")
        .array
        .sort!((a, b) => categorisationKey(a) < categorisationKey(b))
        .leftouterjoin!(categorisationKey, dataflowKey)(
            dataflows
                .filter!(df => !df.id.isNull && !df.agencyId.isNull && !df.version_.isNull)
                .array
                .sort!((a, b) => dataflowKey(a) < dataflowKey(b)))
        .filter!(t => !t.right.isNull)
        .map!(t => t.right.get)
        .uniq;
}

private auto getDataflowsByCategoryUrn(RDF, RC)(
    auto ref RDF dataflows,
    auto ref RC categorisations,
    const ref SDMX21Category category,
    const ref SDMX21CategoryScheme scheme,
) if (isIterableOf!(RDF, SDMX21Dataflow)
    && isIterableOf!(RC, SDMX21Categorisation))
{
    import std.algorithm : sort, filter, map, uniq;
    import std.exception : enforce;
    import std.format : format;
    import std.array : array;
    import fantasio.lib.operations : leftouterjoin;

    enforce!NotIdentifiableSource(
        !category.urn.isNull,
        format!"Caterory %s URN is null"(category.id)
    );

    return categorisations
        .filter!(c =>
                c.source.ref_.isValidForLookup
                && c.target.ref_.getUrn == category.urn.get
                && c.source.ref_.package_.get == "datastructure"
                && c.source.ref_.class_.get == "Dataflow")
        .array
        .sort!((a, b) => categorisationKey(a) < categorisationKey(b))
        .leftouterjoin!(categorisationKey, dataflowKey)(
            dataflows
                .filter!(df => !df.id.isNull && !df.agencyId.isNull && !df.version_.isNull)
                .array
                .sort!((a, b) => dataflowKey(a) < dataflowKey(b)))
        .filter!(t => !t.right.isNull)
        .map!(t => t.right.get)
        .uniq;
}

@safe pure private Item getItemFromDataflow(const ref SDMX21Dataflow dataflow, Language lang)
{
    import std.typecons : nullable;
    import std.exception : enforce;
    import fantasio.core.label : extractLanguage;

    enforce!NotIdentifiableSource(!dataflow.id.isNull, "Dataflow id is null");

    auto name = dataflow.names.dup.extractLanguage!"lang"(lang);

    return Item(ItemT(Dataset(dataflow.id.get, name.content.nullable)));
}

@safe pure private Collection getCollectionFromCategory(RDF, RC)(
    auto ref RDF dataflows,
    auto ref RC categorisations,
    const ref SDMX21Category category,
    const ref SDMX21CategoryScheme scheme,
    Language lang = DefaultLanguage,
    Flag!"joinWithUrn" joinWithUrn = No.joinWithUrn
) if (isIterableOf!(RDF, SDMX21Dataflow)
    && isIterableOf!(RC, SDMX21Categorisation))
{
    import std.exception : enforce;
    import std.typecons : nullable;
    import std.range : chain;
    import std.algorithm : map;
    import std.array : array;
    import fantasio.core.label : extractLanguage;

    auto name = category.names.dup.extractLanguage!"lang"(lang);

    auto datasets =
        joinWithUrn ? ItemT(
            getDataflowsByCategoryUrn(
                dataflows,
                categorisations,
                category,
                scheme
        ).toCollection) : ItemT(
        getDataflowsByCategoryId(
            dataflows,
            categorisations,
            category,
            scheme).toCollection);

    auto collections = category.children.map!(
        c => ItemT(getCollectionFromCategory(dataflows, categorisations, c, scheme, lang, joinWithUrn))
    );

    Item[] items = [datasets]
        .chain(collections)
        .map!(a => Item(a))
        .array;

    return Collection(name.content.nullable, [], Link(items));
}

private Collection getCollectionFromCategoryScheme(RDF, RC)(
    auto ref RDF dataflows,
    auto ref RC categorisations,
    const ref SDMX21CategoryScheme scheme,
    Language lang,
    Flag!"joinWithUrn" joinWithUrn
) if (isIterableOf!(RDF, SDMX21Dataflow)
    && isIterableOf!(RC, SDMX21Categorisation))
{
    import std.exception : enforce;
    import std.algorithm : map;
    import std.array : array;
    import std.typecons : nullable;
    import fantasio.core.label : extractLanguage;

    auto name = scheme.names.dup.extractLanguage!"lang"(lang);

    Item[] items = scheme.categories
        .map!(
            c => Item(ItemT(getCollectionFromCategory(dataflows, categorisations, c, scheme, lang, joinWithUrn)))
        )
        .array;

    return Collection(name.content.nullable, [], Link(items));
}

private SDMX21Concept findConcept(RCS)(const ref SDMX21Ref ref_, auto ref RCS conceptschemes)
        if (isIterableOf!(RCS, SDMX21ConceptScheme))
{
    import std.exception : enforce;
    import std.format : format;
    import std.algorithm : filter, map, joiner;

    enforce!NotIdentifiableSource(ref_.isValidForSchemeLookup, "Invalid Ref");

    auto concepts = conceptschemes
        .filter!(
            cs => cs.id == ref_.maintainableParentId.get
                && cs.agencyId == ref_.agencyId.get
                && cs.version_ == ref_.maintainableParentVersion.get
        )
        .map!(cs => cs.concepts)
        .joiner
        .filter!(c => c.id == ref_.id);

    enforce!InconsitantSource(
        !concepts.empty,
        format!"Could not find concept %s from conceptschemes"(ref_.id));

    return concepts.front;
}

private Category getDimensionCategory(RCL, T)(
    auto ref T dimension,
    auto ref RCL codelists,
    Language lang
)
        if (
            (is(Unqual!T == SDMX21Dimension) || is(Unqual!T == SDMX21TimeDimension))
        && isIterableOf!(RCL, SDMX21Codelist))
{
    import std.exception : enforce;
    import std.format : format;
    import std.algorithm : filter, map, joiner;
    import std.typecons : Tuple, tuple;
    import std.array : array, Appender, assocArray;
    import fantasio.core.label : extractLanguage;

    if (dimension.localRepresentation.isNull
        || dimension.localRepresentation.get.enumeration.isNull)
    {
        return Category();
    }

    auto ref_ = dimension.localRepresentation.get.enumeration.get.ref_;

    enforce!InconsitantSource(
        ref_.isValidForLookup,
        format!"Codelist of dimension %s could not be found"(dimension.id.get)
    );

    Appender!(string[]) indexApp;
    Appender!(Tuple!(string, string)[]) labelApp;

    auto codes = codelists
        .filter!(
            cl => cl.id == ref_.id
                && cl.agencyId == ref_.agencyId.get
                && cl.version_ == ref_.version_.get
        )
        .map!(cl => cl.codes)
        .joiner;

    foreach (c; codes)
    {
        auto name = c.names.dup.extractLanguage!"lang"(lang);

        indexApp.put(c.id);
        labelApp.put(tuple(c.id, name.content));
    }

    return Category(indexApp.data, labelApp.data.assocArray);
}

private Dimension getDimension(RCS, RCL, T)(
    auto ref T dimension,
    auto ref RCS conceptschemes,
    auto ref RCL codelists,
    Language lang
)
        if (
            (is(Unqual!T == SDMX21Dimension) || is(Unqual!T == SDMX21TimeDimension))
        && isIterableOf!(RCS, SDMX21ConceptScheme)
        && isIterableOf!(RCL, SDMX21Codelist))
{
    import std.exception : enforce;
    import std.format : format;
    import std.typecons : nullable;
    import fantasio.core.label : extractLanguage;

    enforce!NotIdentifiableSource(!dimension.id.isNull, "Dimension id is null");

    enforce!InconsitantSource(
        !dimension.conceptIdentity.isNull,
        format!"Concept id of dimension %s is null"(dimension.id.get));

    auto concept = findConcept(dimension.conceptIdentity.get.ref_, conceptschemes);
    auto label = concept.names.dup.extractLanguage!"lang"(lang);

    auto category = dimension.getDimensionCategory(codelists, lang);

    return Dimension(
        label.content.nullable,
        [],
        category
    );
}

@safe pure private bool isGenericData(const ref SDMX21DataSet ds)
in (ds.series.length > 0, "Cannot determine whether dataset is generic or specific when empty")
{
    auto firstSerie = ds.series[0];
    return firstSerie.structureKeys !is null;
}

/// Convert a range of dataflows to a collection of datasets
Collection toCollection(R)(auto ref R dataflows, Language lang = DefaultLanguage)
        if (isIterableOf!(R, SDMX21Dataflow))
{
    import std.algorithm : map, filter;
    import std.array : array;

    return Collection(
        (Nullable!string).init, // TODO populate label
        [],
        Link(dataflows
            .filter!(df => !df.id.isNull && !df.agencyId.isNull && !df.version_.isNull)
            .map!(df => df.getItemFromDataflow(lang))
            .array
        )
    );
}

/// Convert a range of dataflows to a collection of collection of datasets
Collection toCollection(RDF, RCS, RC)(
    auto ref RDF dataflows,
    auto ref RCS categoryschemes,
    auto ref RC categorisations,
    Language lang = DefaultLanguage,
    Flag!"joinWithUrn" joinWithUrn = No.joinWithUrn
)

        if (isIterableOf!(RDF, SDMX21Dataflow)
        && isIterableOf!(RCS, SDMX21CategoryScheme)
        && isIterableOf!(RC, SDMX21Categorisation))
{
    import std.algorithm : map;
    import std.array : array;

    Item[] collections = categoryschemes
        .map!(
            s => Item(ItemT(getCollectionFromCategoryScheme(dataflows, categorisations, s, lang, joinWithUrn)))
        )
        .array;
    return Collection((Nullable!string).init, [], Link(collections));
}

/// Convert a datastructure to a collection of dimensions
Collection toCollection(RCS, RCL)(
    const ref SDMX21DataStructure dsd,
    auto ref RCS conceptschemes,
    auto ref RCL codelists,
    Language lang = DefaultLanguage
) if (isIterableOf!(RCS, SDMX21ConceptScheme) && isIterableOf!(RCL, SDMX21Codelist))
{
    import std.algorithm : sort, map, fold;
    import std.range : chain;
    import std.array : array;
    import std.exception : enforce;

    auto sdmxDims = dsd.dataStructureComponents.dimensionList.dimensions;
    auto sdmxTimeDim = dsd.dataStructureComponents.dimensionList.timeDimension;

    int minPosition = sdmxDims.fold!((acc, cur) {
        enforce!InconsitantSource(
            !cur.position.isNull,
            "At least one dimension has a null position"
        );
        return cur.position.get < acc ? cur.position.get : acc;
    })(int.max);

    enforce!InconsitantSource(!sdmxTimeDim.position.isNull, "Time dimension has a null position");

    auto otherDims = sdmxDims
        .dup
        .sort!((a, b) => a.position.get < b.position.get)
        .map!(d => Item(ItemT(getDimension(d, conceptschemes, codelists, lang))));

    auto timeDim = Item(ItemT(getDimension(sdmxTimeDim, conceptschemes, codelists, lang)));

    auto dimensions = minPosition < sdmxTimeDim.position.get ?
        otherDims.chain([timeDim]).array : [timeDim].chain(otherDims).array;

    return Collection(
        (Nullable!string).init,
        [],
        Link(dimensions)
    );
}

private:
struct StructureRequest
{
    StructureType type;
    Nullable!string agencyId;
    Nullable!string resourceId;
    Nullable!string version_;
    Nullable!DetailsType details;
    Nullable!ReferencesType references;
}

Future!string fetchStructures(alias fetcher)(
    const string rootUrl, const StructureRequest req)
{
    import std.sumtype : match;
    import std.conv : to;
    import vibe.core.concurrency : async;

    auto headers = [
        "Accept": "application/vnd.sdmx.structure+xml;version=2.1"
    ];

    string[string] params;
    if (!req.details.isNull)
        params["details"] = req.details.get;
    if (!req.references.isNull)
        params["references"] = req.references.get.match!(
            (GenericReferencesType t) => t.to!string,
            (StructureType t) => t.to!string,
        );

    string path = "/" ~ req.type;
    if (!req.agencyId.isNull)
        path ~= "/" ~ req.agencyId.get;
    if (!req.resourceId.isNull)
        path ~= "/" ~ req.resourceId.get;
    if (!req.version_.isNull)
        path ~= "/" ~ req.version_.get;

    auto url = rootUrl ~ path;

    auto fut = async({ return fetcher(url, params, headers); });

    return fut;
}

Future!string fetchAll(alias fetcher)(
    const StructureType type,
    const string rootUrl,
    const Nullable!string agencyId,
    const Nullable!ReferencesType references,
)
{
    return fetchStructures!fetcher(rootUrl, StructureRequest(
            type,
            agencyId,
            (Nullable!string).init,
            (Nullable!string).init,
            (Nullable!DetailsType).init,
            references));
}

Future!string fetchById(alias fetcher)(
    const StructureType type,
    const string rootUrl,
    const string agencyId,
    const string resourceId,
    const Nullable!ReferencesType references,
    const Nullable!string version_,
)
{
    import std.typecons : nullable;

    return fetchStructures!fetcher(rootUrl, StructureRequest(
            type,
            agencyId.nullable,
            resourceId.nullable,
            version_,
            (Nullable!DetailsType).init,
            references));
}

public:
enum StructureType : string
{
    dataflow = "dataflow",
    datastructure = "datastructure",
    categoryscheme = "categoryscheme",
    conceptscheme = "conceptscheme",
    codelist = "codelist",
    agencyscheme = "agencyscheme",
    contentconstraint = "contentconstraint",
    categorisation = "categorisation",
}

enum DetailsType : string
{
    allstubs = "allstubs",
    referencestubs = "referencestubs",
    allcompletestubs = "allcompletestubs",
    referencecompletestubs = "referencecompletestubs",
    referencepartial = "referencepartial",
    full = "full",
}

enum GenericReferencesType : string
{
    none = "none",
    parents = "parents",
    parentsandsiblings = "parentsandsiblings",
    children = "children",
    descendants = "descendants",
    all = "all",
}

alias ReferencesType = SumType!(GenericReferencesType, StructureType);

alias fetchAllDataflows(alias fetcher) = partial!(
    fetchAll!fetcher, StructureType.dataflow
);
alias fetchAllCategoryschemes(alias fetcher) = partial!(
    fetchAll!fetcher, StructureType.categoryscheme
);
alias fetchAllCategorisations(alias fetcher) = partial!(
    fetchAll!fetcher, StructureType.categorisation
);
alias fetchDsd(alias fetcher) = partial!(
    fetchById!fetcher, StructureType.datastructure
);
alias fetchCodelist(alias fetcher) = partial!(
    fetchById!fetcher, StructureType.codelist
);
alias fetchConceptscheme(alias fetcher) = partial!(
    fetchById!fetchById, StructureType.conceptscheme
);
alias fetchAgencyschemes(alias fetcher) = partial!(
    fetchAll!fetcher, StructureType.agencyscheme
);
