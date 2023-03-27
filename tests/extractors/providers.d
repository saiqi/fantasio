module tests.extractors.providers;

import fantasio.extractors.providers;
import unit_threaded;

@("fetch catalog from insee")
unittest
{
    import vibe.core.file : readFileUTF8;
    import fantasio.core.model;

    auto mockFetcher(const string url, const string[string] params, const string[string] headers)
    {
        import std.algorithm : canFind;

        if (url.canFind("dataflow"))
            return readFileUTF8("samples/insee/dataflow-categorisation.xml");
        if (url.canFind("categoryscheme"))
            return readFileUTF8("samples/insee/categoryscheme.xml");
        assert(false);
    }

    auto provider = Provider.insee;

    auto catalog = provider.getCatalog!mockFetcher(DefaultLanguage);
}
