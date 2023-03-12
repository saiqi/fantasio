module tests.extractors.sdmxml21;

import std.typecons : nullable, Nullable;
import unit_threaded;
import fantasio.extractors.sdmxml21;

private string getFixture(string name)
{
    import std.file : readText;

    return readText("samples/sdmxml21/" ~ name ~ ".xml");
}

@trusted private SDMX21Structures getStructureFixture(string name)
{
    import fantasio.lib.xml : decodeXmlAs;

    return getFixture(name)
        .decodeXmlAs!SDMX21Structures;
}

private SDMX21DataSet getDataFixture(string name)
{
    import fantasio.lib.xml : decodeXmlAs;

    return getFixture(name)
        .decodeXmlAs!SDMX21DataSet;
}

private SDMX21Error_ getErrorFixture()
{
    import fantasio.lib.xml : decodeXmlAs;

    return getFixture("error")
        .decodeXmlAs!SDMX21Error_;
}

@("decode an SDMX-ML 2.1 dataflow message")
unittest
{
    auto msg = getStructureFixture("dataflow");
    msg.dataflows.get.shouldEqual(SDMX21Dataflows([
            SDMX21Dataflow(
                "BALANCE-PAIEMENTS".nullable,
                "urn:sdmx:org.sdmx.infomodel.datastructure.Dataflow=FR1:BALANCE-PAIEMENTS(1.0)".nullable,
                "FR1".nullable,
                "1.0".nullable,
                (Nullable!bool).init,
                [
                    SDMX21Name("fr", "Balance des paiements"),
                    SDMX21Name("en", "Balance of payments")
                ],
                [],
                SDMX21Structure(
                SDMX21Ref(
                "BALANCE-PAIEMENTS",
                "1.0".nullable,
                (Nullable!string).init,
                (Nullable!string).init,
                "FR1".nullable,
                "datastructure".nullable,
                "DataStructure".nullable
                )
            ).nullable,
            (Nullable!SDMX21Ref).init
            )
        ]));
}

@("decode an SDMX-ML 2.1 agencyscheme message")
unittest
{
    auto msg = getStructureFixture("agencyscheme");
    msg.organisationSchemes.get.shouldEqual(
        SDMX21OrganisationSchemes([
            SDMX21AgencyScheme(
                "AGENCIES",
                "urn:sdmx:org.sdmx.infomodel.base.AgencyScheme=SDMX:AGENCIES(1.0)",
                "SDMX",
                "1.0",
                false.nullable,
                [SDMX21Name("en", "SDMX Agency Scheme")],
                [
                    SDMX21Agency(
                    "SDMX",
                    "urn:sdmx:org.sdmx.infomodel.base.Agency=SDMX",
                    [SDMX21Name("en", "SDMX")],
                    [
                        SDMX21Description(
                        "en",
                        "SDMX is an initiative to foster standards for the exchange of statistical information."
                        )
                    ]
                    ),
                    SDMX21Agency(
                    "IMF",
                    "urn:sdmx:org.sdmx.infomodel.base.Agency=IMF",
                    [SDMX21Name("en", "International Monetary Fund (IMF)")],
                    [
                        SDMX21Description("en", "The IMF works to foster global growth and economic stability.")
                    ]
                    )
                ]
            )
        ])
    );
}

@("decode an SDMX-ML 2.1 categoryscheme message")
unittest
{
    auto msg = getStructureFixture("categoryscheme");
    msg.categorySchemes.get.shouldEqual(SDMX21CategorySchemes([
            SDMX21CategoryScheme(
                "CLASSEMENT_DATAFLOWS",
                "urn:sdmx:org.sdmx.infomodel.categoryscheme.CategoryScheme=FR1:CLASSEMENT_DATAFLOWS(1.0)".nullable,
                "FR1",
                "1.0",
                [
                    SDMX21Name("fr", "Classement des dataflows"),
                    SDMX21Name("en", "Dataflows categorisation")
                ],
                [],
                [
                    SDMX21Category(
                    "ECO",
                    "urn:sdmx:org.sdmx.infomodel.categoryscheme.Category=FR1:CLASSEMENT_DATAFLOWS(1.0).ECO"
                    .nullable,
                    [
                        SDMX21Name("fr", "Économie – Conjoncture – Comptes nationaux"),
                        SDMX21Name("en", "Economy – Economic outlook – National accounts")
                    ],
                    [],
                    [
                        SDMX21Category(
                        "COMMERCE_EXT",
                        "urn:sdmx:org.sdmx.infomodel.categoryscheme.Category=FR1:CLASSEMENT_DATAFLOWS(1.0).ECO.COMMERCE_EXT"
                        .nullable,
                        [
                            SDMX21Name("fr", "Commerce extérieur"),
                            SDMX21Name("en", "Foreign trade")
                        ],
                        [],
                        []
                        )
                    ]
                    )
                ]
            )
        ]));
}

@("decode an SDMX-ML 2.1 categorisation")
unittest
{
    auto msg = getStructureFixture("categorisation");
    msg.categorisations.get.shouldEqual(SDMX21Categorisations(
            [
            SDMX21Categorisation(
                "COMMERCE_EXT_BALANCE-PAIEMENTS",
                "urn:sdmx:org.sdmx.infomodel.categoryscheme.Categorisation=FR1:COMMERCE_EXT_BALANCE-PAIEMENTS(1.0)"
                .nullable,
                "FR1",
                "1.0",
                [
                    SDMX21Name("fr", "Association entre la catégorie COMMERCE_EXT et le dataflows BALANCE-PAIEMENTS"),
                    SDMX21Name("en", "Association between category COMMERCE_EXT and dataflows BALANCE-PAIEMENTS")
                ],
                [],
                SDMX21Source(
                SDMX21Ref(
                "BALANCE-PAIEMENTS",
                "1.0".nullable,
                (Nullable!string).init,
                (Nullable!string).init,
                "FR1".nullable,
                "datastructure".nullable,
                "Dataflow".nullable
                )
            ),
            SDMX21Target(
                SDMX21Ref(
                "COMMERCE_EXT",
                (Nullable!string).init,
                "CLASSEMENT_DATAFLOWS".nullable,
                "1.0".nullable,
                "FR1".nullable,
                "categoryscheme".nullable,
                "Category".nullable

            )
            )
            )
        ]));
}

@("decode an SDMX-ML 2.1 conceptscheme message")
unittest
{
    auto msg = getStructureFixture("conceptscheme");
    msg.concepts.get.shouldEqual(SDMX21Concepts([
            SDMX21ConceptScheme(
                "CONCEPTS_INSEE",
                "urn:sdmx:org.sdmx.infomodel.conceptscheme.ConceptScheme=FR1:CONCEPTS_INSEE(1.0)".nullable,
                "FR1",
                "1.0",
                [
                    SDMX21Name("fr", "Concepts Insee"),
                    SDMX21Name("en", "Insee concepts")
                ],
                [],
                [
                    SDMX21Concept(
                    "FREQ",
                    "urn:sdmx:org.sdmx.infomodel.conceptscheme.Concept=FR1:CONCEPTS_INSEE(1.0).FREQ".nullable,
                    [
                        SDMX21Name("fr", "Périodicité"),
                        SDMX21Name("en", "Frequency")
                    ],
                    []
                    ),
                    SDMX21Concept(
                    "INDICATEUR",
                    "urn:sdmx:org.sdmx.infomodel.conceptscheme.Concept=FR1:CONCEPTS_INSEE(1.0).INDICATEUR"
                    .nullable,
                    [
                        SDMX21Name("fr", "Indicateurs"),
                        SDMX21Name("en", "Indicators")
                    ],
                    []
                    ),
                    SDMX21Concept(
                    "COMPTE",
                    "urn:sdmx:org.sdmx.infomodel.conceptscheme.Concept=FR1:CONCEPTS_INSEE(1.0).COMPTE".nullable,
                    [
                        SDMX21Name("fr", "Nature"),
                        SDMX21Name("en", "Nature")
                    ],
                    []
                    ),
                    SDMX21Concept(
                    "INSTRUMENT",
                    "urn:sdmx:org.sdmx.infomodel.conceptscheme.Concept=FR1:CONCEPTS_INSEE(1.0).INSTRUMENT"
                    .nullable,
                    [
                        SDMX21Name("fr", "Rubriques ou postes"),
                        SDMX21Name("en", "Headings or items")
                    ],
                    []
                    ),
                    SDMX21Concept(
                    "NATURE",
                    "urn:sdmx:org.sdmx.infomodel.conceptscheme.Concept=FR1:CONCEPTS_INSEE(1.0).NATURE".nullable,
                    [
                        SDMX21Name("fr", "Nature"),
                        SDMX21Name("en", "Nature")
                    ],
                    []
                    ),
                    SDMX21Concept(
                    "GEOGRAPHIE",
                    "urn:sdmx:org.sdmx.infomodel.conceptscheme.Concept=FR1:CONCEPTS_INSEE(1.0).GEOGRAPHIE"
                    .nullable,
                    [
                        SDMX21Name("fr", "Zones géographiques"),
                        SDMX21Name("en", "Geographic areas")
                    ],
                    []
                    ),
                    SDMX21Concept(
                    "UNITE",
                    "urn:sdmx:org.sdmx.infomodel.conceptscheme.Concept=FR1:CONCEPTS_INSEE(1.0).UNITE".nullable,
                    [
                        SDMX21Name("fr", "Unité"),
                        SDMX21Name("en", "Unit")
                    ],
                    []
                    ),
                    SDMX21Concept(
                    "CORRECTION",
                    "urn:sdmx:org.sdmx.infomodel.conceptscheme.Concept=FR1:CONCEPTS_INSEE(1.0).CORRECTION"
                    .nullable,
                    [
                        SDMX21Name("fr", "Correction saisonnière"),
                        SDMX21Name("en", "Seasonal adjustment")
                    ],
                    []
                    ),
                    SDMX21Concept(
                    "UNIT_MULT",
                    "urn:sdmx:org.sdmx.infomodel.conceptscheme.Concept=FR1:CONCEPTS_INSEE(1.0).UNIT_MULT".nullable,
                    [
                        SDMX21Name("fr", "Puissance"),
                        SDMX21Name("en", "Unit multiplier")
                    ],
                    []
                    ),
                    SDMX21Concept(
                    "BASE_PER",
                    "urn:sdmx:org.sdmx.infomodel.conceptscheme.Concept=FR1:CONCEPTS_INSEE(1.0).BASE_PER".nullable,
                    [
                        SDMX21Name("fr", "Base de l'indice"),
                        SDMX21Name("en", "Base period")
                    ],
                    []
                    )
                ]
            )
        ]));
}

@("decode an SDMX-ML 2.1 codelist message")
unittest
{
    auto msg = getStructureFixture("codelist");
    msg.codelists.get.shouldEqual(SDMX21Codelists([
            SDMX21Codelist(
                "CL_PERIODICITE",
                "urn:sdmx:org.sdmx.infomodel.codelist.Codelist=FR1:CL_PERIODICITE(1.0)".nullable,
                "FR1",
                "1.0",
                [
                    SDMX21Name("fr", "Périodicité"),
                    SDMX21Name("en", "Frequency")
                ],
                [],
                [
                    SDMX21Code(
                    "M",
                    "urn:sdmx:org.sdmx.infomodel.codelist.Code=FR1:CL_PERIODICITE(1.0).M".nullable,
                    [
                        SDMX21Name("fr", "Mensuelle"),
                        SDMX21Name("en", "Monthly")
                    ],
                    []

                    )
                ]
            ),
            SDMX21Codelist(
                "CL_BASIND",
                "urn:sdmx:org.sdmx.infomodel.codelist.Codelist=FR1:CL_BASIND(1.0)".nullable,
                "FR1",
                "1.0",
                [
                    SDMX21Name("fr", "Base de l'indice"),
                    SDMX21Name("en", "Base period")
                ],
                [],
                [
                    SDMX21Code(
                    "SO",
                    "urn:sdmx:org.sdmx.infomodel.codelist.Code=FR1:CL_BASIND(1.0).SO".nullable,
                    [
                        SDMX21Name("fr", "Sans objet"),
                        SDMX21Name("en", "Not applicable")
                    ],
                    []

                    )
                ]
            ),
            SDMX21Codelist(
                "CL_COMPTE",
                "urn:sdmx:org.sdmx.infomodel.codelist.Codelist=FR1:CL_COMPTE(1.0)".nullable,
                "FR1",
                "1.0",
                [
                    SDMX21Name("fr", "Position de compte"),
                    SDMX21Name("en", "Account position")
                ],
                [],
                [
                    SDMX21Code(
                    "CREDITS",
                    "urn:sdmx:org.sdmx.infomodel.codelist.Code=FR1:CL_COMPTE(1.0).CREDITS".nullable,
                    [
                        SDMX21Name("fr", "Crédits"),
                        SDMX21Name("en", "Credits")
                    ],
                    []

                    )
                ]
            ),
            SDMX21Codelist(
                "CL_CORRECTION",
                "urn:sdmx:org.sdmx.infomodel.codelist.Codelist=FR1:CL_CORRECTION(1.0)".nullable,
                "FR1",
                "1.0",
                [
                    SDMX21Name("fr", "Correction"),
                    SDMX21Name("en", "Correction")
                ],
                [],
                [
                    SDMX21Code(
                    "BRUT",
                    "urn:sdmx:org.sdmx.infomodel.codelist.Code=FR1:CL_CORRECTION(1.0).BRUT".nullable,
                    [
                        SDMX21Name("fr", "Non corrigé"),
                        SDMX21Name("en", "Uncorrected")
                    ],
                    []
                    ),
                    SDMX21Code(
                    "CVS",
                    "urn:sdmx:org.sdmx.infomodel.codelist.Code=FR1:CL_CORRECTION(1.0).CVS".nullable,
                    [
                        SDMX21Name("fr", "Corrigé des variations saisonnières"),
                        SDMX21Name("en", "Seasonal adjusted")
                    ],
                    []
                    )
                ]
            ),
            SDMX21Codelist(
                "CL_INDICATEUR",
                "urn:sdmx:org.sdmx.infomodel.codelist.Codelist=FR1:CL_INDICATEUR(1.0)".nullable,
                "FR1",
                "1.0",
                [
                    SDMX21Name("fr", "Indicateur"),
                    SDMX21Name("en", "Indicator")
                ],
                [],
                [
                    SDMX21Code(
                    "BALANCE_DES_PAIEMENTS",
                    "urn:sdmx:org.sdmx.infomodel.codelist.Code=FR1:CL_INDICATEUR(1.0).BALANCE_DES_PAIEMENTS"
                    .nullable,
                    [
                        SDMX21Name("fr", "Balance des paiements"),
                        SDMX21Name("en", "Balance of Payments")
                    ],
                    []

                    )
                ]
            ),
            SDMX21Codelist(
                "CL_INSTRUMENTS_BALANCE_PAIEMENTS",
                "urn:sdmx:org.sdmx.infomodel.codelist.Codelist=FR1:CL_INSTRUMENTS_BALANCE_PAIEMENTS(1.0)".nullable,
                "FR1",
                "1.0",
                [
                    SDMX21Name("fr", "Type de compte"),
                    SDMX21Name("en", "Account type")
                ],
                [],
                [
                    SDMX21Code(
                    "181",
                    "urn:sdmx:org.sdmx.infomodel.codelist.Code=FR1:CL_INSTRUMENTS_BALANCE_PAIEMENTS(1.0).181".nullable,
                    [
                        SDMX21Name(
                        "fr",
                        "Compte de transactions courantes - Revenus primaires - Revenus des investissements - Revenus des avoirs de réserve"
                        ),
                        SDMX21Name("en", "Current account - Primary income - Investment income - Reserve assets")
                    ],
                    []

                    )
                ]
            ),
            SDMX21Codelist(
                "CL_NATURE",
                "urn:sdmx:org.sdmx.infomodel.codelist.Codelist=FR1:CL_NATURE(1.0)".nullable,
                "FR1",
                "1.0",
                [
                    SDMX21Name("fr", "Nature"),
                    SDMX21Name("en", "Nature")
                ],
                [],
                [
                    SDMX21Code(
                    "VALEUR_ABSOLUE",
                    "urn:sdmx:org.sdmx.infomodel.codelist.Code=FR1:CL_NATURE(1.0).VALEUR_ABSOLUE".nullable,
                    [
                        SDMX21Name("fr", "Valeur absolue"),
                        SDMX21Name("en", "Absolute value")
                    ],
                    []

                    )
                ]
            ),
            SDMX21Codelist(
                "CL_ZONE_GEO",
                "urn:sdmx:org.sdmx.infomodel.codelist.Codelist=FR1:CL_ZONE_GEO(1.0)".nullable,
                "FR1",
                "1.0",
                [
                    SDMX21Name("fr", "Zone géographique"),
                    SDMX21Name("en", "Reference area")
                ],
                [],
                [
                    SDMX21Code(
                    "FE",
                    "urn:sdmx:org.sdmx.infomodel.codelist.Code=FR1:CL_ZONE_GEO(1.0).FE".nullable,
                    [
                        SDMX21Name("fr", "France"),
                        SDMX21Name("en", "France")
                    ],
                    []

                    )
                ]
            ),
            SDMX21Codelist(
                "CL_UNITE",
                "urn:sdmx:org.sdmx.infomodel.codelist.Codelist=FR1:CL_UNITE(1.0)".nullable,
                "FR1",
                "1.0",
                [
                    SDMX21Name("fr", "Unité"),
                    SDMX21Name("en", "Unit")
                ],
                [],
                [
                    SDMX21Code(
                    "EUROS",
                    "urn:sdmx:org.sdmx.infomodel.codelist.Code=FR1:CL_UNITE(1.0).EUROS".nullable,
                    [
                        SDMX21Name("fr", "euros"),
                        SDMX21Name("en", "euros")
                    ],
                    []

                    )
                ]
            ),
            SDMX21Codelist(
                "CL_OBS_STATUS",
                "urn:sdmx:org.sdmx.infomodel.codelist.Codelist=FR1:CL_OBS_STATUS(1.0)".nullable,
                "FR1",
                "1.0",
                [
                    SDMX21Name("fr", "Statut des observations"),
                    SDMX21Name("en", "Observation status")
                ],
                [],
                [
                    SDMX21Code(
                    "A",
                    "urn:sdmx:org.sdmx.infomodel.codelist.Code=FR1:CL_OBS_STATUS(1.0).A".nullable,
                    [
                        SDMX21Name("fr", "Valeur normale"),
                        SDMX21Name("en", "Normal value")
                    ],
                    []

                    )
                ]
            ),
            SDMX21Codelist(
                "CL_OBS_QUAL",
                "urn:sdmx:org.sdmx.infomodel.codelist.Codelist=FR1:CL_OBS_QUAL(1.0)".nullable,
                "FR1",
                "1.0",
                [
                    SDMX21Name("fr", "Qualité de l'observation"),
                    SDMX21Name("en", "Observation quality")
                ],
                [],
                [
                    SDMX21Code(
                    "DEF",
                    "urn:sdmx:org.sdmx.infomodel.codelist.Code=FR1:CL_OBS_QUAL(1.0).DEF".nullable,
                    [
                        SDMX21Name("fr", "Valeur définitive"),
                        SDMX21Name("en", "Final value")
                    ],
                    []

                    )
                ]
            ),
            SDMX21Codelist(
                "CL_OBS_REV",
                "urn:sdmx:org.sdmx.infomodel.codelist.Codelist=FR1:CL_OBS_REV(1.0)".nullable,
                "FR1",
                "1.0",
                [
                    SDMX21Name("fr", "Caractère de révision"),
                    SDMX21Name("en", "Observation revised")
                ],
                [],
                [
                    SDMX21Code(
                    "1",
                    "urn:sdmx:org.sdmx.infomodel.codelist.Code=FR1:CL_OBS_REV(1.0).1".nullable,
                    [
                        SDMX21Name("fr", "Révision"),
                        SDMX21Name("en", "Revised value")
                    ],
                    []

                    )
                ]
            ),
            SDMX21Codelist(
                "CL_OBS_CONF",
                "urn:sdmx:org.sdmx.infomodel.codelist.Codelist=FR1:CL_OBS_CONF(1.0)".nullable,
                "FR1",
                "1.0",
                [
                    SDMX21Name("fr", "Confidentialité de l'observation"),
                    SDMX21Name("en", "Observation confidentiality")
                ],
                [],
                [
                    SDMX21Code(
                    "F",
                    "urn:sdmx:org.sdmx.infomodel.codelist.Code=FR1:CL_OBS_CONF(1.0).F".nullable,
                    [
                        SDMX21Name("fr", "Valeur publique"),
                        SDMX21Name("en", "Free")
                    ],
                    []

                    )
                ]
            ),
            SDMX21Codelist(
                "CL_OBS_TYPE",
                "urn:sdmx:org.sdmx.infomodel.codelist.Codelist=FR1:CL_OBS_TYPE(1.0)".nullable,
                "FR1",
                "1.0",
                [
                    SDMX21Name("fr", "Type d'observation"),
                    SDMX21Name("en", "Observation type")
                ],
                [],
                [
                    SDMX21Code(
                    "A",
                    "urn:sdmx:org.sdmx.infomodel.codelist.Code=FR1:CL_OBS_TYPE(1.0).A".nullable,
                    [
                        SDMX21Name("fr", "Valeur normale"),
                        SDMX21Name("en", "Normal value")
                    ],
                    []

                    )
                ]
            ),
        ]));
}

@("decode an SDMX-ML 2.1 datastructure message")
unittest
{
    auto msg = getStructureFixture("datastructure");
    msg.dataStructures.get.dataStructures.length.shouldEqual(1);

    auto dsd = msg.dataStructures.get.dataStructures[0];
    dsd.dataStructureComponents.dimensionList.dimensions.length.shouldEqual(9);
    dsd.dataStructureComponents.attributeList.get.attributes.length.shouldEqual(12);

    dsd.dataStructureComponents.dimensionList.timeDimension.shouldEqual(SDMX21TimeDimension(
            "TIME_PERIOD".nullable,
            "urn:sdmx:org.sdmx.infomodel.datastructure.TimeDimension=FR1:BALANCE-PAIEMENTS(1.0).TIME_PERIOD".nullable,
            1.nullable,
            SDMX21ConceptIdentity(
            SDMX21Ref(
            "TIME_PERIOD",
            (Nullable!string).init,
            "CONCEPTS_INSEE".nullable,
            "1.0".nullable,
            "FR1".nullable,
            "conceptscheme".nullable,
            "Concept".nullable
            )
    ).nullable,
    SDMX21LocalRepresentation(
        SDMX21TextFormat(
            "ObservationalTimePeriod".nullable,
            (Nullable!string).init,
            (Nullable!string).init,
            (Nullable!string).init
    ).nullable,
    (Nullable!SDMX21Enumeration).init
    ).nullable
    ));

    dsd.dataStructureComponents.dimensionList.dimensions[0].shouldEqual(SDMX21Dimension(
            "FREQ".nullable,
            "urn:sdmx:org.sdmx.infomodel.datastructure.Dimension=FR1:BALANCE-PAIEMENTS(1.0).FREQ".nullable,
            2.nullable,
            SDMX21ConceptIdentity(
            SDMX21Ref(
            "FREQ",
            (Nullable!string).init,
            "CONCEPTS_INSEE".nullable,
            "1.0".nullable,
            "FR1".nullable,
            "conceptscheme".nullable,
            "Concept".nullable
            )
    ).nullable,
    SDMX21LocalRepresentation(
        (Nullable!SDMX21TextFormat).init,
        SDMX21Enumeration(
            SDMX21Ref(
            "CL_PERIODICITE",
            "1.0".nullable,
            (Nullable!string)
            .init,
            (Nullable!string).init,
            "FR1".nullable,
            "codelist".nullable,
            "Codelist".nullable
        )
    ).nullable
    ).nullable
    ));

    dsd.dataStructureComponents.attributeList.get.attributes[0].shouldEqual(
        SDMX21Attribute(
            "UNIT_MULT".nullable,
            "urn:sdmx:org.sdmx.infomodel.datastructure.DataAttribute=FR1:BALANCE-PAIEMENTS(1.0).UNIT_MULT".nullable,
            "Mandatory".nullable,
            SDMX21ConceptIdentity(
            SDMX21Ref(
            "UNIT_MULT",
            (Nullable!string).init,
            "CONCEPTS_INSEE".nullable,
            "1.0".nullable,
            "FR1".nullable,
            "conceptscheme".nullable,
            "Concept".nullable
            )
    ).nullable,
    SDMX21LocalRepresentation(
        SDMX21TextFormat(
            "Integer".nullable,
            (Nullable!string).init,
            (Nullable!string).init,
            (Nullable!string)
            .init,
            "0".nullable,
            "9".nullable
    ).nullable,
    (Nullable!SDMX21Enumeration).init
    ).nullable,
    SDMX21AttributeRelationship(
        [
        SDMX21Dimension(
            (Nullable!string).init,
            (Nullable!string).init,
            (Nullable!int).init,
            (Nullable!SDMX21ConceptIdentity).init,
            (Nullable!SDMX21LocalRepresentation).init,
            SDMX21Ref("FREQ").nullable
        ),
        SDMX21Dimension(
            (Nullable!string).init,
            (Nullable!string).init,
            (Nullable!int).init,
            (Nullable!SDMX21ConceptIdentity).init,
            (Nullable!SDMX21LocalRepresentation).init,
            SDMX21Ref("INDICATEUR").nullable
        ),
        SDMX21Dimension(
            (Nullable!string).init,
            (Nullable!string).init,
            (Nullable!int).init,
            (Nullable!SDMX21ConceptIdentity).init,
            (Nullable!SDMX21LocalRepresentation).init,
            SDMX21Ref("COMPTE").nullable
        ),
        SDMX21Dimension(
            (Nullable!string).init,
            (Nullable!string).init,
            (Nullable!int).init,
            (Nullable!SDMX21ConceptIdentity).init,
            (Nullable!SDMX21LocalRepresentation)
                .init,
                SDMX21Ref("INSTRUMENTS_BALANCE_PAIEMENTS").nullable
        ),
        SDMX21Dimension(
            (Nullable!string).init,
            (Nullable!string).init,
            (Nullable!int).init,
            (Nullable!SDMX21ConceptIdentity).init,
            (Nullable!SDMX21LocalRepresentation).init,
            SDMX21Ref("NATURE").nullable
        ),
        SDMX21Dimension(
            (Nullable!string).init,
            (Nullable!string).init,
            (Nullable!int).init,
            (Nullable!SDMX21ConceptIdentity).init,
            (Nullable!SDMX21LocalRepresentation).init,
            SDMX21Ref("REF_AREA").nullable
        ),
        SDMX21Dimension(
            (Nullable!string).init,
            (Nullable!string).init,
            (Nullable!int).init,
            (Nullable!SDMX21ConceptIdentity).init,
            (Nullable!SDMX21LocalRepresentation).init,
            SDMX21Ref("UNIT_MEASURE").nullable
        ),
        SDMX21Dimension(
            (Nullable!string).init,
            (Nullable!string).init,
            (Nullable!int).init,
            (Nullable!SDMX21ConceptIdentity).init,
            (Nullable!SDMX21LocalRepresentation).init,
            SDMX21Ref("CORRECTION").nullable
        ),
        SDMX21Dimension(
            (Nullable!string).init,
            (Nullable!string).init,
            (Nullable!int).init,
            (Nullable!SDMX21ConceptIdentity).init,
            (Nullable!SDMX21LocalRepresentation).init,
            SDMX21Ref("BASIND").nullable
        )
    ]
    ).nullable
    )
    );

    dsd.dataStructureComponents.measureList.get.primaryMeasure.shouldEqual(
        SDMX21PrimaryMeasure(
            "OBS_VALUE".nullable,
            "urn:sdmx:org.sdmx.infomodel.datastructure.PrimaryMeasure=FR1:BALANCE-PAIEMENTS(1.0).OBS_VALUE".nullable,
            SDMX21ConceptIdentity(
            SDMX21Ref(
            "OBS_VALUE",
            (Nullable!string).init,
            "CONCEPTS_INSEE".nullable,
            "1.0".nullable,
            "FR1".nullable,
            "conceptscheme".nullable,
            "Concept".nullable
            )
    ).nullable
    )
    );
}

@("decode an SDMX-ML 2.1 contentconstraint message")
unittest
{
    auto msg = getStructureFixture("contentconstraint");
    msg.constraints.get.shouldEqual(SDMX21Constraints([
            SDMX21ContentConstraint(
                "AME_CONSTRAINTS".nullable,
                "urn:sdmx:org.sdmx.infomodel.registry.ContentConstraint=ECB:AME_CONSTRAINTS(1.0)".nullable,
                false.nullable,
                "ECB".nullable,
                "1.0".nullable,
                false.nullable,
                "Allowed".nullable,
                [SDMX21Name("en", "Constraints for the AME dataflow.")],
                [],
                SDMX21ConstraintAttachment(
                [
                    SDMX21Dataflow(
                    (Nullable!string).init,
                    (Nullable!string)
                    .init,
                    (Nullable!string).init,
                    (Nullable!string).init,
                    (Nullable!bool).init,
                    [],
                    [],
                    (Nullable!SDMX21Structure).init,
                    SDMX21Ref(
                    "AME",
                    "1.0".nullable,
                    (Nullable!string).init,
                    (Nullable!string)
                    .init,
                    "ECB".nullable,
                    "datastructure".nullable,
                    "Dataflow".nullable
                    ).nullable
                    )
                ]
            ).nullable,
            SDMX21CubeRegion(
                true.nullable,
                [
                    SDMX21KeyValue(
                    "AME_ITEM",
                    [
                        SDMX21Value(
                        (Nullable!string).init,
                        (Nullable!string)
                        .init,
                        "UDGGL".nullable
                        )
                    ]
                    ),
                    SDMX21KeyValue(
                    "AME_REFERENCE",
                    [
                        SDMX21Value(
                        (Nullable!string).init,
                        (Nullable!string).init,
                        "0".nullable
                        )
                    ]
                    ),
                    SDMX21KeyValue(
                    "AME_REF_AREA",
                    [
                        SDMX21Value(
                        (Nullable!string).init,
                        (Nullable!string).init,
                        "DNK".nullable
                        ),
                        SDMX21Value(
                        (Nullable!string).init,
                        (Nullable!string).init,
                        "IRL".nullable
                        )
                    ]
                    ),
                    SDMX21KeyValue(
                    "AME_TRANSFORMATION",
                    [
                        SDMX21Value(
                        (Nullable!string).init,
                        (Nullable!string).init,
                        "1".nullable
                        )
                    ]
                    ),
                    SDMX21KeyValue(
                    "AME_UNIT",
                    [
                        SDMX21Value(
                        (Nullable!string).init,
                        (Nullable!string)
                        .init,
                        "0".nullable
                        ),
                        SDMX21Value(
                        (Nullable!string).init,
                        (Nullable!string).init,
                        "319".nullable
                        )
                    ]
                    ),
                    SDMX21KeyValue(
                    "AME_AGG_METHOD",
                    [
                        SDMX21Value(
                        (Nullable!string).init,
                        (Nullable!string).init,
                        "0".nullable
                        )
                    ]
                    ),
                    SDMX21KeyValue(
                    "FREQ",
                    [
                        SDMX21Value(
                        (Nullable!string).init,
                        (Nullable!string).init,
                        "A".nullable
                        )
                    ]
                    )
                ]
            ).nullable
            )
        ]));
}

@("decode an SDMX-ML 2.1 structure specific data message")
unittest
{
    auto msg = getDataFixture("structurespecificdata");
    msg.shouldEqual(SDMX21DataSet(
            "FR1_BALANCE-PAIEMENTS_1_0".nullable,
            [
                SDMX21Series(
                (Nullable!SDMX21SeriesKey).init,
                (Nullable!SDMX21Attributes)
                .init,
                [
                    SDMX21Obs(
                    (Nullable!SDMX21ObsDimension).init,
                    (Nullable!SDMX21ObsValue).init,
                    (Nullable!SDMX21Attributes).init,
                    [
                        "TIME_PERIOD": "2022-11",
                        "OBS_VALUE": "203",
                        "OBS_STATUS": "A",
                        "OBS_QUAL": "DEF",
                        "OBS_TYPE": "A",
                    ]
                    ),
                    SDMX21Obs(
                    (Nullable!SDMX21ObsDimension).init,
                    (Nullable!SDMX21ObsValue).init,
                    (Nullable!SDMX21Attributes).init,
                    [
                        "TIME_PERIOD": "2022-10",
                        "OBS_VALUE": "183",
                        "OBS_STATUS": "A",
                        "OBS_QUAL": "DEF",
                        "OBS_TYPE": "A",
                    ]
                    )
                ],
                [
                    "BASIND": "SO",
                    "CORRECTION": "BRUT",
                    "COMPTE": "CREDITS",
                    "FREQ": "M",
                    "UNIT_MULT": "6",
                    "INDICATEUR": "BALANCE_DES_PAIEMENTS",
                    "UNIT_MEASURE": "EUROS",
                    "NATURE": "VALEUR_ABSOLUE",
                    "REF_AREA": "FE",
                    "INSTRUMENTS_BALANCE_PAIEMENTS": "181",
                    "IDBANK": "001694087",
                    "TITLE_FR": "Balance des paiements - Crédit - Transactions courantes - Revenus primaires - Revenus des investissements - Revenus des avoirs de réserve - Données brutes",
                    "TITLE_EN": "Balance of payments - Credit - Current transactions - Primary income - Investment income - Reserve assets - Raw data",
                    "LAST_UPDATE": "2023-01-09",
                    "DECIMALS": "0",
                ]
                ),
                SDMX21Series(
                (Nullable!SDMX21SeriesKey).init,
                (Nullable!SDMX21Attributes)
                .init,
                [
                    SDMX21Obs(
                    (Nullable!SDMX21ObsDimension).init,
                    (Nullable!SDMX21ObsValue).init,
                    (Nullable!SDMX21Attributes).init,
                    [
                        "TIME_PERIOD": "2022-11",
                        "OBS_VALUE": "215",
                        "OBS_STATUS": "A",
                        "OBS_QUAL": "DEF",
                        "OBS_TYPE": "A",
                    ]
                    ),
                    SDMX21Obs(
                    (Nullable!SDMX21ObsDimension).init,
                    (Nullable!SDMX21ObsValue).init,
                    (Nullable!SDMX21Attributes).init,
                    [
                        "TIME_PERIOD": "2022-10",
                        "OBS_VALUE": "188",
                        "OBS_STATUS": "A",
                        "OBS_REV": "1",
                        "OBS_QUAL": "DEF",
                        "OBS_TYPE": "A",
                    ]
                    )
                ],
                [
                    "BASIND": "SO",
                    "CORRECTION": "CVS",
                    "COMPTE": "CREDITS",
                    "FREQ": "M",
                    "UNIT_MULT": "6",
                    "INDICATEUR": "BALANCE_DES_PAIEMENTS",
                    "UNIT_MEASURE": "EUROS",
                    "NATURE": "VALEUR_ABSOLUE",
                    "REF_AREA": "FE",
                    "INSTRUMENTS_BALANCE_PAIEMENTS": "181",
                    "IDBANK": "001694088",
                    "TITLE_FR": "Balance des paiements - Crédit - Transactions courantes - Revenus primaires - Revenus des investissements - Revenus des avoirs de réserve - Données CVS",
                    "TITLE_EN": "Balance of payments - Credit - Current transactions - Primary income - Investment income - Reserve assets - SA data",
                    "LAST_UPDATE": "2023-01-09",
                    "DECIMALS": "0",
                ]
                )
            ]
    ));
}

@("decode an SDMX-ML 2.1 generic data message")
unittest
{
    auto msg = getDataFixture("genericdata");
    msg.shouldEqual(SDMX21DataSet(
            "FR1_BALANCE-PAIEMENTS_1_0".nullable,
            [
                SDMX21Series(
                SDMX21SeriesKey([
                    SDMX21Value("BASIND".nullable, "SO".nullable),
                    SDMX21Value("CORRECTION".nullable, "BRUT".nullable),
                    SDMX21Value("COMPTE".nullable, "CREDITS".nullable),
                    SDMX21Value("FREQ".nullable, "M".nullable),
                    SDMX21Value("UNIT_MULT".nullable, "6".nullable),
                    SDMX21Value("INDICATEUR".nullable, "BALANCE_DES_PAIEMENTS".nullable),
                    SDMX21Value("UNIT_MEASURE".nullable, "EUROS".nullable),
                    SDMX21Value("NATURE".nullable, "VALEUR_ABSOLUE".nullable),
                    SDMX21Value("REF_AREA".nullable, "FE".nullable),
                    SDMX21Value("INSTRUMENTS_BALANCE_PAIEMENTS".nullable, "181".nullable),
                ]).nullable,
                SDMX21Attributes([
                    SDMX21Value("IDBANK".nullable, "001694087".nullable),
                    SDMX21Value(
                    "TITLE_FR".nullable,
                    "Balance des paiements - Crédit - Transactions courantes - Revenus primaires - Revenus des investissements - Revenus des avoirs de réserve - Données brutes"
                    .nullable
                    ),
                    SDMX21Value(
                    "TITLE_EN".nullable,
                    "Balance of payments - Credit - Current transactions - Primary income - Investment income - Reserve assets - Raw data"
                    .nullable
                    ),
                    SDMX21Value("LAST_UPDATE".nullable, "2023-01-09".nullable),
                    SDMX21Value("DECIMALS".nullable, "0".nullable),
                ]).nullable,
                [
                    SDMX21Obs(
                    SDMX21ObsDimension("2022-11").nullable,
                    SDMX21ObsValue((203.).nullable).nullable,
                    SDMX21Attributes([
                        SDMX21Value("OBS_STATUS".nullable, "A".nullable),
                        SDMX21Value("OBS_QUAL".nullable, "DEF".nullable),
                        SDMX21Value("OBS_TYPE".nullable, "A".nullable),
                    ]).nullable
                    ),
                    SDMX21Obs(
                    SDMX21ObsDimension("2022-10").nullable,
                    SDMX21ObsValue((183.).nullable).nullable,
                    SDMX21Attributes([
                        SDMX21Value("OBS_STATUS".nullable, "A".nullable),
                        SDMX21Value("OBS_QUAL".nullable, "DEF".nullable),
                        SDMX21Value("OBS_TYPE".nullable, "A".nullable),
                    ]).nullable
                    )
                ]
                ),
                SDMX21Series(
                SDMX21SeriesKey([
                    SDMX21Value("BASIND".nullable, "SO".nullable),
                    SDMX21Value("CORRECTION".nullable, "CVS".nullable),
                    SDMX21Value("COMPTE".nullable, "CREDITS".nullable),
                    SDMX21Value("FREQ".nullable, "M".nullable),
                    SDMX21Value("UNIT_MULT".nullable, "6".nullable),
                    SDMX21Value("INDICATEUR".nullable, "BALANCE_DES_PAIEMENTS".nullable),
                    SDMX21Value("UNIT_MEASURE".nullable, "EUROS".nullable),
                    SDMX21Value("NATURE".nullable, "VALEUR_ABSOLUE".nullable),
                    SDMX21Value("REF_AREA".nullable, "FE".nullable),
                    SDMX21Value("INSTRUMENTS_BALANCE_PAIEMENTS".nullable, "181".nullable),
                ]).nullable,
                SDMX21Attributes([
                    SDMX21Value("IDBANK".nullable, "001694088".nullable),
                    SDMX21Value(
                    "TITLE_FR".nullable,
                    "Balance des paiements - Crédit - Transactions courantes - Revenus primaires - Revenus des investissements - Revenus des avoirs de réserve - Données CVS"
                    .nullable
                    ),
                    SDMX21Value(
                    "TITLE_EN".nullable,
                    "Balance of payments - Credit - Current transactions - Primary income - Investment income - Reserve assets - SA data"
                    .nullable
                    ),
                    SDMX21Value("LAST_UPDATE".nullable, "2023-01-09".nullable),
                    SDMX21Value("DECIMALS".nullable, "0".nullable),
                ]).nullable,
                [
                    SDMX21Obs(
                    SDMX21ObsDimension("2022-11").nullable,
                    SDMX21ObsValue((215.).nullable).nullable,
                    SDMX21Attributes([
                        SDMX21Value("OBS_STATUS".nullable, "A".nullable),
                        SDMX21Value("OBS_QUAL".nullable, "DEF".nullable),
                        SDMX21Value("OBS_TYPE".nullable, "A".nullable),
                    ]).nullable
                    ),
                    SDMX21Obs(
                    SDMX21ObsDimension("2022-10").nullable,
                    SDMX21ObsValue((188.).nullable).nullable,
                    SDMX21Attributes([
                        SDMX21Value("OBS_STATUS".nullable, "A".nullable),
                        SDMX21Value("OBS_REV".nullable, "1".nullable),
                        SDMX21Value("OBS_QUAL".nullable, "DEF".nullable),
                        SDMX21Value("OBS_TYPE".nullable, "A".nullable),
                    ]).nullable
                    )
                ]
                )
            ]
    ));
}

@("decode an SDMX-ML 2.1 error message")
unittest
{
    auto msg = getErrorFixture();
    msg.shouldEqual(SDMX21Error_(
            SDMX21ErrorMessage(
            "140".nullable,
            SDMX21Text("La syntaxe de la requete est invalide.".nullable).nullable
        ).nullable
    ));
}

@("convert dataflows to collection")
@safe unittest
{
    import fantasio.core.model;
    import fantasio.core.errors;

    auto dataflows = [
        SDMX21Dataflow(
            "foo".nullable,
            (Nullable!string).init,
            "acme".nullable,
            "1.0".nullable,
            (Nullable!bool).init,
            [SDMX21Name("en", "Foo"), SDMX21Name("fr", "Foo")]
        ),
        SDMX21Dataflow(
            "bar".nullable,
            (Nullable!string).init,
            "acme".nullable,
            "1.0".nullable,
            (Nullable!bool).init,
            [SDMX21Name("en", "Bar"), SDMX21Name("fr", "Barre")]
        ),
        SDMX21Dataflow()
    ];

    auto result = dataflows.toCollection(Language.en);

    auto expected = Collection(
        (Nullable!string).init,
        [],
        Link([
            Item(ItemT(Dataset("foo", "Foo".nullable))),
            Item(ItemT(Dataset("bar", "Bar".nullable)))
        ])
    );
    () @trusted { result.shouldEqual(expected); }();

    dataflows.toCollection(Language.es).shouldThrow!LanguageNotFound;
}

@("convert dataflows, categorisations and categoryschemes to collection")
@safe unittest
{
    import std.typecons : Yes;
    import fantasio.core.model;

    auto dataflows = [
        SDMX21Dataflow(
            "gdp".nullable,
            (Nullable!string).init,
            "acme".nullable,
            "1.0".nullable,
            (Nullable!bool).init,
            [SDMX21Name("en", "GDP"), SDMX21Name("fr", "PIB")]
        ),
        SDMX21Dataflow(
            "birth".nullable,
            (Nullable!string).init,
            "acme".nullable,
            "1.0".nullable,
            (Nullable!bool).init,
            [SDMX21Name("en", "Birth"), SDMX21Name("fr", "Naissance")]
        ),
    ];

    // dfmt off
    auto categorisations = [
        SDMX21Categorisation(
            "0",
            (Nullable!string).init,
            "acme",
            "1.0",
            [],
            [],
            SDMX21Source(SDMX21Ref(
                "gdp",
                "1.0".nullable,
                (Nullable!string)
                .init,
                (Nullable!string).init,
                "acme".nullable,
                "datastructure".nullable,
                "Dataflow".nullable
            )),
            SDMX21Target(SDMX21Ref(
                    "eco-agg",
                    "1.0".nullable,
                    "scheme".nullable,
                    "1.0".nullable,
                    "acme".nullable,
                    "categoryscheme".nullable,
                    "Category".nullable
            ))
        ),
        SDMX21Categorisation(
            "0",
            (Nullable!string).init,
            "acme",
            "1.0",
            [],
            [],
            SDMX21Source(SDMX21Ref(
                "gdp",
                "1.0".nullable,
                (Nullable!string).init,
                (Nullable!string).init,
                "acme".nullable,
                "datastructure".nullable,
                "Dataflow".nullable
            )),
            SDMX21Target(SDMX21Ref(
                    "shortlist",
                    "1.0".nullable,
                    "scheme".nullable,
                    "1.0".nullable,
                    "acme".nullable,
                    "categoryscheme".nullable,
                    "Category".nullable
            ))
        )
    ];
    // dfmt on

    auto categoryschemes = [
        SDMX21CategoryScheme(
            "scheme",
            (Nullable!string).init,
            "acme",
            "1.0",
            [
                SDMX21Name("en", "All categories"),
                SDMX21Name("fr", "Toutes les catégories")
            ],
            [],
            [
                SDMX21Category(
                    "eco",
                    "urn:sdmx:org.sdmx.infomodel.categoryscheme.Category=acme:scheme:(1.0).eco".nullable,
                    [SDMX21Name("en", "Economy"), SDMX21Name("fr", "Economie")],
                    [],
                    [
                        SDMX21Category(
                        "eco-agg",
                        "urn:sdmx:org.sdmx.infomodel.categoryscheme.Category=acme:scheme:(1.0).eco-agg".nullable,
                        [
                            SDMX21Name("en", "Economy - Aggregates"),
                            SDMX21Name("fr", "Economie - Aggrégats")
                        ],
                        []
                        )
                    ]
                ),
                SDMX21Category(
                    "shortlist",
                    "urn:sdmx:org.sdmx.infomodel.categoryscheme.Category=acme:scheme:(1.0).shortlist".nullable,
                    [
                        SDMX21Name("en", "Shortlist"),
                        SDMX21Name("fr", "Préselection")
                    ],
                    []
                )
            ]
        )
    ];

    auto collectionById = toCollection(dataflows, categoryschemes, categorisations);
    auto collectionByUrn = toCollection(
        dataflows,
        categoryschemes,
        categorisations,
        Language.en, Yes.joinWithUrn);

    // dfmt off
    auto expected = Collection(
        (Nullable!string).init,
        [],
        Link([
            Item(ItemT(Collection("All categories".nullable, [], Link([
                Item(ItemT(Collection("Economy".nullable, [], Link([
                    Item(ItemT(Collection((Nullable!string).init, [], Link([])))),
                    Item(ItemT(Collection("Economy - Aggregates".nullable, [], Link([
                        Item(ItemT(Collection((Nullable!string).init, [], Link([
                            Item(ItemT(Dataset("gdp", "GDP".nullable)))
                        ]))))
                    ]))))
                ])))),
                Item(ItemT(Collection("Shortlist".nullable, [], Link([
                    Item(ItemT(Collection((Nullable!string).init, [], Link([
                        Item(ItemT(Dataset("gdp", "GDP".nullable)))
                    ]))))
                ]))))
            ]))))
        ])
    );
    // dfmt on

    () @trusted { collectionById.shouldEqual(expected); }();
    () @trusted { collectionByUrn.shouldEqual(expected); }();
}

@("convert dsd, codelists and conceptschemes to collection")
@safe unittest
{
    import fantasio.core.model;

    // dfmt off
    auto dsd = SDMX21DataStructure(
        "0",
        (Nullable!string).init,
        "acme",
        "1.0",
        [],
        [],
        SDMX21DataStructureComponents(
            SDMX21DimensionList(
                "list",
                (Nullable!string).init,
                SDMX21TimeDimension(
                    "TIME_PERIOD".nullable,
                    (Nullable!string).init,
                    2.nullable,
                    SDMX21ConceptIdentity(SDMX21Ref(
                        "TIME_PERIOD",
                        "1.0".nullable,
                        "scheme".nullable,
                        "1.0".nullable,
                        "acme".nullable,
                        "conceptscheme".nullable,
                        "Concept".nullable
                    )).nullable
                ),
                [SDMX21Dimension(
                    "FREQ".nullable,
                    (Nullable!string).init,
                    1.nullable,
                    SDMX21ConceptIdentity(SDMX21Ref(
                        "FREQ",
                        "1.0".nullable,
                        "scheme".nullable,
                        "1.0".nullable,
                        "acme".nullable,
                        "conceptscheme".nullable,
                        "Concept".nullable
                    )).nullable,
                    SDMX21LocalRepresentation(
                        (Nullable!SDMX21TextFormat).init,
                        SDMX21Enumeration(SDMX21Ref(
                            "CL_FREQ",
                            "1.0".nullable,
                            (Nullable!string).init,
                            (Nullable!string).init,
                            "acme".nullable,
                            "codelist".nullable,
                            "Codelist".nullable
                        )).nullable
                    ).nullable
                )]
            )
        )
    );
    // dfmt on

    auto conceptschemes = [
        SDMX21ConceptScheme(
            "scheme",
            (Nullable!string).init,
            "acme",
            "1.0",
            [],
            [],
            [
                SDMX21Concept(
                    "TIME_PERIOD",
                    (Nullable!string).init,
                    [SDMX21Name("en", "Time Period")],
                    []
                ),
                SDMX21Concept(
                    "FREQ",
                    (Nullable!string).init,
                    [SDMX21Name("en", "Frequency")],
                    []
                )
            ]
        )
    ];

    auto codelists = [
        SDMX21Codelist(
            "CL_FREQ",
            (Nullable!string).init,
            "acme",
            "1.0",
            [SDMX21Name("en", "Frequency")],
            [],
            [
                SDMX21Code(
                    "A",
                    (Nullable!string).init,
                    [SDMX21Name("en", "Annual")],
                    []
                )
            ]
        )
    ];

    auto result = dsd.toCollection(conceptschemes, codelists);

    // dfmt off
    auto expected = Collection(
        (Nullable!string).init,
        [],
        Link([
            Item(ItemT(Dimension(
                "Frequency".nullable,
                [],
                Category(
                    ["A"],
                    ["A": "Annual"]
                )
            ))),
            Item(ItemT(Dimension(
                "Time Period".nullable,
            )))
        ])
    );
    // dfmt on

    () @trusted { result.shouldEqual(expected); }();
}
