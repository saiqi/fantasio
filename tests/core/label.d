module tests.core.label;

import fantasio.core.label;
import unit_threaded;

@("extract a labelized entity in a particular language from a list of entities")
@safe pure unittest
{
    import fantasio.core.model : Language;

    static struct Label
    {
        string lang;
        string name;
    }

    auto labels = [Label("en", "Hello"), Label("fr", "Bonjour")];
    labels
        .extractLanguage!"lang"(Language.en)
        .get
        .shouldEqual(Label("en", "Hello"));

    labels
        .extractLanguage!"lang"(Language.es)
        .isNull
        .shouldBeTrue;
}