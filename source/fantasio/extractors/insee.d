module fantasio.extractors.insee;

import fantasio.extractors.sdmxml21;
import fantasio.core.model;

private enum rootUrl = "https://www.bdm.insee.fr/series/sdmx";
private enum agencyId = "FR1";

package:

Collection getCatalog(alias fetcher)(Language lang)
{
    import std.typecons : nullable, Nullable;
    import std.exception : enforce;
    import fantasio.lib.xml : decodeXmlAs, decodeXmlAsRangeOf;
    import fantasio.lib.futures : getOrThrows;
    import fantasio.core.errors : RemoteError, InconsitantSource;

    auto fDataflowsAndCategorisations = fetchAllDataflows!fetcher(
        rootUrl,
        agencyId.nullable,
        ReferencesType(StructureType.categorisation).nullable,
    );

    auto fCategoryschemes = fetchAllCategoryschemes!fetcher(
        rootUrl,
        agencyId.nullable,
        (Nullable!ReferencesType).init,
    );

    auto structures = fDataflowsAndCategorisations
        .getOrThrows!RemoteError
        .decodeXmlAs!SDMX21Structures;

    auto categoryschemes = fCategoryschemes
        .getOrThrows!RemoteError
        .decodeXmlAsRangeOf!SDMX21CategoryScheme;

    enforce!InconsitantSource(
        !structures.dataflows.isNull,
        "Returned artefact has no dataflows"
    );
    enforce!InconsitantSource(
        !structures.categorisations.isNull,
        "Returned artefact has no categorisations"
    );

    return toCollection(
        structures.dataflows.get.dataflows,
        categoryschemes,
        structures.categorisations.get.categorisations,
        lang
    );
}
