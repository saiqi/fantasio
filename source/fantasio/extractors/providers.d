module fantasio.extractors.providers;

import fantasio.core.model;
import fantasio.core.errors;
import insee_extractor = fantasio.extractors.insee;

enum Provider : string
{
    insee = "insee",
    eurostat = "eurostat",
    ecb = "ecb",
    ilo = "ilo",
    oecd = "oecd",
    imf = "imf",
    worldbank = "worldbank",
    unicef = "unicef",
    who = "who",
    bis = "bis",
    un = "un",
}

Collection getCatalog(alias fetcher)(const Provider provider, Language lang)
{
    import std.exception : enforce;
    import std.format : format;

    final switch (provider) with (Provider)
    {
    case insee:
        return insee_extractor.getCatalog!fetcher(lang);
    case eurostat, ecb, ilo, oecd, imf, worldbank, unicef, who, bis, un:
        enforce!NotSupported(false, format!"%s provider is not supported yet"(provider));
    }
    assert(false);
}
