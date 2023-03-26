module fantasio.extractors.sdmxml20.types;

import std.typecons : Nullable;
import fantasio.lib.xml;

@XmlRoot("KeyFamilyID")
struct SDMX20KeyFamilyID
{
    @XmlText
    string id;
}

@XmlRoot("KeyFamilyAgencyID")
struct SDMX20KeyFamilyAgencyID
{
    @XmlText
    string agencyId;
}

@XmlRoot("KeyFamilyRef")
struct SDMX20KeyFamilyRef
{
    @XmlElement("KeyFamilyID")
    Nullable!SDMX20KeyFamilyID keyFamilyId;

    @XmlElement("KeyFamilyAgencyID")
    Nullable!SDMX20KeyFamilyAgencyID keyFamilyAgencyId;

    @XmlText
    Nullable!string content;
}

@XmlRoot("Name")
struct SDMX20Name
{
    @XmlAttr("lang")
    string lang;

    @XmlText
    string content;
}

@XmlRoot("Dataflow")
struct SDMX20Dataflow
{
    @XmlAttr("id")
    string id;

    @XmlAttr("version")
    string version_;

    @XmlAttr("agencyID")
    string agencyId;

    @XmlAttr("isFinal")
    Nullable!bool isFinal;

    @XmlElement("KeyFamilyRef")
    SDMX20KeyFamilyRef keyFamilyRef;

    @XmlElementList("Name")
    SDMX20Name[] names;
}

@XmlRoot("Dataflows")
struct SDMX20Dataflows
{
    @XmlElementList("Dataflow")
    SDMX20Dataflow[] dataflows;
}

@XmlRoot("Dimension")
struct SDMX20Dimension
{
    @XmlAttr("codelist")
    Nullable!string codelist;

    @XmlAttr("codelistVersion")
    Nullable!string codelistVersion;

    @XmlAttr("codelistAgency")
    Nullable!string codelistAgency;

    @XmlAttr("conceptRef")
    Nullable!string conceptRef;

    @XmlAttr("conceptVersion")
    Nullable!string conceptVersion;

    @XmlAttr("conceptSchemeRef")
    Nullable!string conceptSchemeRef;

    @XmlAttr("conceptSchemeAgency")
    Nullable!string conceptSchemeAgency;

    @XmlAttr("isFrequencyDimension")
    Nullable!bool isFrequencyDimension;

    @XmlAttr("isMeasureDimension")
    Nullable!bool isMeasureDimension;
}

@XmlRoot("TimeDimension")
struct SDMX20TimeDimension
{
    @XmlAttr("codelist")
    Nullable!string codelist;

    @XmlAttr("codelistVersion")
    Nullable!string codelistVersion;

    @XmlAttr("codelistAgency")
    Nullable!string codelistAgency;

    @XmlAttr("conceptRef")
    Nullable!string conceptRef;

    @XmlAttr("conceptVersion")
    Nullable!string conceptVersion;

    @XmlAttr("conceptSchemeRef")
    Nullable!string conceptSchemeRef;

    @XmlAttr("conceptSchemeAgency")
    Nullable!string conceptSchemeAgency;
}

@XmlRoot("TextFormat")
struct SDMX20TextFormat
{
    @XmlAttr("textType")
    Nullable!string textType;
}

@XmlRoot("PrimaryMeasure")
struct SDMX20PrimaryMeasure
{
    @XmlAttr("conceptRef")
    Nullable!string conceptRef;

    @XmlAttr("conceptVersion")
    Nullable!string conceptVersion;

    @XmlAttr("conceptSchemeRef")
    Nullable!string conceptSchemeRef;

    @XmlAttr("conceptSchemeAgency")
    Nullable!string conceptSchemeAgency;

    @XmlElement("TextFormat")
    Nullable!SDMX20TextFormat textFormat;
}

@XmlRoot("Attribute")
struct SDMX20Attribute
{
    @XmlAttr("codelist")
    Nullable!string codelist;

    @XmlAttr("codelistVersion")
    Nullable!string codelistVersion;

    @XmlAttr("codelistAgency")
    Nullable!string codelistAgency;

    @XmlAttr("conceptRef")
    Nullable!string conceptRef;

    @XmlAttr("conceptVersion")
    Nullable!string conceptVersion;

    @XmlAttr("conceptSchemeRef")
    Nullable!string conceptSchemeRef;

    @XmlAttr("conceptSchemeAgency")
    Nullable!string conceptSchemeAgency;

    @XmlAttr("assignmentStatus")
    Nullable!string assignmentStatus;

    @XmlAttr("attachmentLevel")
    Nullable!string attachmentLevel;

    @XmlElement("TextFormat")
    Nullable!SDMX20TextFormat textFormat;
}

@XmlRoot("Components")
struct SDMX20Components
{
    @XmlElementList("Dimension")
    SDMX20Dimension[] dimensions;

    @XmlElement("TimeDimension")
    SDMX20TimeDimension timeDimension;

    @XmlElement("PrimaryMeasure")
    SDMX20PrimaryMeasure primaryMeasure;

    @XmlElementList("Attribute")
    SDMX20Attribute[] attributes;
}

@XmlRoot("KeyFamily")
struct SDMX20KeyFamily
{
    @XmlAttr("id")
    string id;

    @XmlAttr("agencyID")
    string agencyId;

    @XmlAttr("version")
    Nullable!string version_;

    @XmlAttr("isFinal")
    Nullable!bool isFinal;

    @XmlElementList("Name")
    SDMX20Name[] names;

    @XmlElement("Components")
    SDMX20Components components;
}

@XmlRoot("KeyFamilies")
struct SDMX20KeyFamilies
{
    @XmlElementList("KeyFamily")
    SDMX20KeyFamily[] keyFamilies;
}

@XmlRoot("Description")
struct SDMX20Description
{
    @XmlAttr("lang")
    string lang;

    @XmlText
    string content;
}

@XmlRoot("Code")
struct SDMX20Code
{
    @XmlAttr("value")
    string value;

    @XmlElementList("Name")
    SDMX20Name[] names;

    @XmlElementList("Description")
    SDMX20Description[] descriptions;
}

@XmlRoot("CodeList")
struct SDMX20Codelist
{
    @XmlAttr("id")
    string id;

    @XmlAttr("agencyID")
    string agencyId;

    @XmlAttr("version")
    Nullable!string version_;

    @XmlElementList("Name")
    SDMX20Name[] names;

    @XmlElementList("Description")
    SDMX20Description[] descriptions;

    @XmlElementList("Code")
    SDMX20Code[] codes;
}

@XmlRoot("CodeLists")
struct SDMX20Codelists
{
    @XmlElementList("CodeList")
    SDMX20Codelist[] codelists;
}

@XmlRoot("Concept")
struct SDMX20Concept
{
    @XmlAttr("id")
    string id;

    @XmlAttr("agencyID")
    string agencyId;

    @XmlAttr("version")
    Nullable!string version_;

    @XmlElementList("Name")
    SDMX20Name[] names;

    @XmlElementList("Description")
    SDMX20Description[] descriptions;
}

@XmlRoot("ConceptScheme")
struct SDMX20ConceptScheme
{
    @XmlAttr("id")
    string id;

    @XmlAttr("agencyID")
    string agencyId;

    @XmlAttr("version")
    string version_;

    @XmlElementList("Name")
    SDMX20Name[] names;

    @XmlElementList("Description")
    SDMX20Description[] descriptions;

    @XmlElementList("Concept")
    SDMX20Concept[] concepts;
}

@XmlRoot("Concepts")
struct SDMX20Concepts
{
    @XmlElementList("Concept")
    SDMX20Concept[] concepts;

    @XmlElementList("ConceptScheme")
    SDMX20ConceptScheme[] conceptSchemes;
}

@XmlRoot("Structure")
struct SDMX20Structure
{
    @XmlElement("Dataflows")
    Nullable!SDMX20Dataflows dataflows;

    @XmlElement("KeyFamilies")
    Nullable!SDMX20KeyFamilies keyFamilies;

    @XmlElement("CodeLists")
    Nullable!SDMX20Codelists codelists;

    @XmlElement("Concepts")
    Nullable!SDMX20Concepts concepts;
}

@XmlRoot("SDMX20Value")
struct SDMX20Value
{
    @XmlAttr("concept")
    string concept;

    @XmlAttr("value")
    string value;
}

@XmlRoot("SeriesKey")
struct SDMX20SeriesKey
{
    @XmlElementList("Value")
    SDMX20Value[] values;
}

@XmlRoot("Attributes")
struct SDMX20Attributes
{
    @XmlElementList("Value")
    SDMX20Value[] values;
}

@XmlRoot("Time")
struct SDMX20Time
{
    @XmlText
    string content;
}

@XmlRoot("ObsValue")
struct SDMX20ObsValue
{
    @XmlAttr("value")
    Nullable!double value;
}

@XmlRoot("Obs")
struct SDMX20Obs
{
    @XmlElement("Time")
    Nullable!SDMX20Time time;

    @XmlElement("ObsValue")
    Nullable!SDMX20ObsValue obsValue;

    @XmlAllAttrs
    string[string] structureAttributes;

}

@XmlRoot("Series")
struct SDMX20Series
{
    @XmlElement("SeriesKey")
    Nullable!SDMX20SeriesKey seriesKey;

    @XmlElement("Attributes")
    Nullable!SDMX20Attributes attributes;

    @XmlElementList("Obs")
    SDMX20Obs[] obs;

    @XmlAllAttrs
    string[string] structureKeys;
}

@XmlRoot("DataSet")
struct SDMX20DataSet
{
    @XmlAttr("keyFamilyURI")
    Nullable!string keyFamilyUri;

    @XmlElement("KeyFamilyRef")
    Nullable!SDMX20KeyFamilyRef keyFamilyRef;

    @XmlElementList("Series")
    SDMX20Series[] series;
}
