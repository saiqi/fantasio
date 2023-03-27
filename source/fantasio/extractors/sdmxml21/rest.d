module fantasio.extractors.sdmxml21.rest;

import std.sumtype : SumType;
import std.typecons : Nullable;
import std.functional : partial;
import vibe.core.concurrency : Future;

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
