module fantasio.extractors.sdmxml21.conv;

import std.typecons : Nullable, Flag, No, Tuple;
import std.traits : Unqual;
import fantasio.lib.traits : isIterableOf;
import fantasio.extractors.sdmxml21.types;
import fantasio.core.model;
import fantasio.core.errors;

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

    enforce!NotIdentifiableSource(!dataflow.id.isNull, "");

    auto name = dataflow.names.dup.extractLanguage!"lang"(lang);
    enforce!LanguageNotFound(!name.isNull, lang);

    return Item(ItemT(Dataset(dataflow.id.get, name.get.content.nullable)));
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
    enforce!LanguageNotFound(!name.isNull);

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

    return Collection(name.get.content.nullable, [], Link(items));
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
    enforce!LanguageNotFound(!name.isNull, lang);

    Item[] items = scheme.categories
        .map!(
            c => Item(ItemT(getCollectionFromCategory(dataflows, categorisations, c, scheme, lang, joinWithUrn)))
        )
        .array;

    return Collection(name.get.content.nullable, [], Link(items));
}

private SDMX21Concept findConcept(RCS)(const ref SDMX21Ref ref_, auto ref RCS conceptschemes)
        if (isIterableOf!(RCS, SDMX21ConceptScheme))
{
    import std.exception : enforce;
    import std.format : format;
    import std.algorithm : filter, map, joiner;

    enforce!NotIdentifiableSource(ref_.isValidForSchemeLookup, "");

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
        enforce!LanguageNotFound(!name.isNull, lang);

        indexApp.put(c.id);
        labelApp.put(tuple(c.id, name.get.content));
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
    import std.typecons : apply;
    import fantasio.core.label : extractLanguage;

    enforce!NotIdentifiableSource(!dimension.id.isNull, "");

    enforce!InconsitantSource(
        !dimension.conceptIdentity.isNull,
        format!"Concept id of dimension %s is null"(dimension.id.get));

    auto concept = findConcept(dimension.conceptIdentity.get.ref_, conceptschemes);
    auto label = concept.names.dup.extractLanguage!"lang"(lang);

    auto category = dimension.getDimensionCategory(codelists, lang);

    return Dimension(
        label.apply!"a.content",
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

@safe pure Dataset toDataset(const ref SDMX21DataSet ds, const ref SDMX21DataStructure dsd)
{
    return Dataset();
}
