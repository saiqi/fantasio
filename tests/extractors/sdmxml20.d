module tests.extractors.sdmxml20;

import std.typecons : nullable, Nullable;
import unit_threaded;
import fantasio.extractors.sdmxml20;

private string getFixture(string name)
{
    import std.file : readText;

    return readText("samples/sdmxml20/" ~ name ~ ".xml");
}

private SDMX20Structure getStructureFixture(string name)
{
    import fantasio.lib.xml : decodeXmlAs;

    return getFixture(name)
        .decodeXmlAs!SDMX20Structure;
}

private SDMX20DataSet getDataFixture(string name)
{
    import fantasio.lib.xml : decodeXmlAs;

    return getFixture(name)
        .decodeXmlAs!SDMX20DataSet;
}

@("decode an SDMX-ML 2.0 dataflow message")
unittest
{
    auto msg = getStructureFixture("dataflow");
    msg.dataflows.get.shouldEqual(SDMX20Dataflows([
            SDMX20Dataflow(
                "DS-BOP_2017M06",
                "1.0",
                "IMF",
                true.nullable,
                SDMX20KeyFamilyRef(
                SDMX20KeyFamilyID("BOP_2017M06")
                .nullable,
                SDMX20KeyFamilyAgencyID("IMF").nullable

            ),
            [SDMX20Name("en", "Balance of Payments (BOP), 2017 M06")]
            ),
            SDMX20Dataflow(
                "DS-BOP_2020M3",
                "1.0",
                "IMF",
                true.nullable,
                SDMX20KeyFamilyRef(
                SDMX20KeyFamilyID("BOP_2020M3")
                .nullable,
                SDMX20KeyFamilyAgencyID("IMF").nullable

            ),
            [SDMX20Name("en", "Balance of Payments (BOP), 2020 M03")]
            ),
        ]));
}

@("decode an SDMX-ML 2.0 codelist, conceptscheme and keyfamily")
unittest
{
    auto msg = getStructureFixture("keyfamily");
    msg.codelists.get.shouldEqual(SDMX20Codelists([
            SDMX20Codelist(
                "CL_UNIT_MULT",
                "IMF",
                "1.0".nullable,
                [SDMX20Name("en", "Scale")],
                [],
                [SDMX20Code("0", [], [SDMX20Description("en", "Units")])]
            ),
            SDMX20Codelist(
                "CL_FREQ",
                "IMF",
                "1.0".nullable,
                [SDMX20Name("en", "Frequency")],
                [SDMX20Description("en", "Frequency")],
                [SDMX20Code("A", [], [SDMX20Description("en", "Annual")])]
            ),
            SDMX20Codelist(
                "CL_AREA_BOP_2017M06",
                "IMF",
                "1.0".nullable,
                [SDMX20Name("en", "Geographical Areas")],
                [],
                [SDMX20Code("AF", [], [SDMX20Description("en", "Afghanistan")])]
            ),
            SDMX20Codelist(
                "CL_INDICATOR_BOP_2017M06",
                "IMF",
                "1.0".nullable,
                [SDMX20Name("en", "Indicator")],
                [],
                [
                    SDMX20Code("IADDF_BP6_EUR", [], [
                        SDMX20Description(
                        "en",
                        "Assets, Direct Investment, Debt Instruments, Between Fellow Enterprises, Euros"
                        )
                    ])
                ]
            ),
            SDMX20Codelist(
                "CL_TIME_FORMAT",
                "IMF",
                "1.0".nullable,
                [SDMX20Name("en", "Time format")],
                [SDMX20Description("en", "Time formats based on ISO 8601.")],
                [SDMX20Code("P1Y", [], [SDMX20Description("en", "Annual")])]
            ),
        ]));

    msg.concepts.get.shouldEqual(SDMX20Concepts(
            [],
            [
                SDMX20ConceptScheme(
                "BOP_2017M06",
                "IMF",
                "1.0",
                [SDMX20Name("en", "Balance of Payments (BOP), 2017 M06")],
                [],
                [
                    SDMX20Concept(
                    "OBS_VALUE",
                    "IMF",
                    "1.0".nullable,
                    [SDMX20Name("en", "Value")],
                    []
                    ),
                    SDMX20Concept(
                    "UNIT_MULT",
                    "IMF",
                    "1.0".nullable,
                    [SDMX20Name("en", "Scale")],
                    []
                    ),
                    SDMX20Concept(
                    "TIME_FORMAT",
                    "IMF",
                    "1.0".nullable,
                    [SDMX20Name("en", "Time format")],
                    [SDMX20Description("en", "Time formats based on ISO 8601.")]
                    ),
                    SDMX20Concept(
                    "FREQ",
                    "IMF",
                    "1.0".nullable,
                    [SDMX20Name("en", "Frequency")],
                    []
                    ),
                    SDMX20Concept(
                    "REF_AREA",
                    "IMF",
                    "1.0".nullable,
                    [SDMX20Name("en", "Reference Area")],
                    []
                    ),
                    SDMX20Concept(
                    "INDICATOR",
                    "IMF",
                    "1.0".nullable,
                    [SDMX20Name("en", "Indicator")],
                    []
                    ),
                    SDMX20Concept(
                    "TIME_PERIOD",
                    "IMF",
                    "1.0".nullable,
                    [SDMX20Name("en", "Date")],
                    []
                    ),
                    SDMX20Concept(
                    "OBS_STATUS",
                    "IMF",
                    "1.0".nullable,
                    [
                        SDMX20Name("en", "Observation Status (incl. Confidentiality)")
                    ],
                    []
                    ),
                    SDMX20Concept(
                    "OFFICIAL_BPM",
                    "IMF",
                    "1.0".nullable,
                    [SDMX20Name("en", "Official BPM6")],
                    []
                    ),
                ]
                )
            ]
    ));

    msg.keyFamilies.get.shouldEqual(SDMX20KeyFamilies(
            [
            SDMX20KeyFamily(
                "BOP_2017M06",
                "IMF",
                "1.0".nullable,
                true.nullable,
                [SDMX20Name("en", "Balance of Payments (BOP), 2017 M06")],
                SDMX20Components(
                [
                    SDMX20Dimension(
                    "CL_FREQ".nullable,
                    "1.0".nullable,
                    "IMF".nullable,
                    "FREQ".nullable,
                    "1.0".nullable,
                    "BOP_2017M06".nullable,
                    "IMF".nullable,
                    true.nullable,
                    (Nullable!bool).init
                    ),
                    SDMX20Dimension(
                    "CL_AREA_BOP_2017M06".nullable,
                    "1.0".nullable,
                    "IMF".nullable,
                    "REF_AREA".nullable,
                    "1.0".nullable,
                    "BOP_2017M06".nullable,
                    "IMF".nullable,
                    (Nullable!bool).init,
                    (Nullable!bool).init
                    ),
                    SDMX20Dimension(
                    "CL_INDICATOR_BOP_2017M06".nullable,
                    "1.0".nullable,
                    "IMF".nullable,
                    "INDICATOR".nullable,
                    "1.0".nullable,
                    "BOP_2017M06".nullable,
                    "IMF".nullable,
                    (Nullable!bool).init,
                    (Nullable!bool).init
                    ),
                ],
                SDMX20TimeDimension(
                (Nullable!string).init,
                (Nullable!string)
                .init,
                (Nullable!string).init,
                "TIME_PERIOD".nullable,
                "1.0".nullable,
                "BOP_2017M06".nullable,
                "IMF".nullable,
            ),
            SDMX20PrimaryMeasure(
                "OBS_VALUE".nullable,
                "1.0".nullable,
                "BOP_2017M06".nullable,
                "IMF".nullable,
                SDMX20TextFormat("Double".nullable).nullable
            ),
            [
                SDMX20Attribute(
                    "CL_UNIT_MULT".nullable,
                    "1.0".nullable,
                    "IMF".nullable,
                    "UNIT_MULT".nullable,
                    "1.0".nullable,
                    "BOP_2017M06".nullable,
                    "IMF".nullable,
                    "Mandatory".nullable,
                    "Series".nullable,
                    (Nullable!SDMX20TextFormat).init
                ),
                SDMX20Attribute(
                    (Nullable!string).init,
                    (Nullable!string)
                    .init,
                    (Nullable!string).init,
                    "OBS_STATUS".nullable,
                    "1.0".nullable,
                    "BOP_2017M06".nullable,
                    "IMF".nullable,
                    "Conditional".nullable,
                    "Observation".nullable,
                    SDMX20TextFormat("String".nullable).nullable
                ),
                SDMX20Attribute(
                    (Nullable!string).init,
                    (Nullable!string)
                    .init,
                    (Nullable!string).init,
                    "OFFICIAL_BPM".nullable,
                    "1.0".nullable,
                    "BOP_2017M06".nullable,
                    "IMF".nullable,
                    "Conditional".nullable,
                    "Observation".nullable,
                    SDMX20TextFormat("String".nullable).nullable
                ),
                SDMX20Attribute(
                    "CL_TIME_FORMAT".nullable,
                    "1.0".nullable,
                    "IMF".nullable,
                    "TIME_FORMAT".nullable,
                    "1.0".nullable,
                    "BOP_2017M06".nullable,
                    "IMF".nullable,
                    "Mandatory".nullable,
                    "Series".nullable,
                    (Nullable!SDMX20TextFormat).init
                ),
            ]
            )
            )
        ]
    ));
}

@("decode an SDMX-ML 2.0 data message")
unittest
{
    auto msg = getDataFixture("data");
    msg.shouldEqual(SDMX20DataSet(
            "https://stats-1.oecd.org/RestSDMX/sdmx.ashx/GetKeyFamily/QNA".nullable,
            SDMX20KeyFamilyRef(
            (Nullable!SDMX20KeyFamilyID)
            .init,
            (Nullable!SDMX20KeyFamilyAgencyID).init,
            "QNA".nullable
        ).nullable,
        [
            SDMX20Series(
                SDMX20SeriesKey([
                    SDMX20Value("LOCATION", "AUS"),
                    SDMX20Value("SUBJECT", "B1_GE"),
                    SDMX20Value("MEASURE", "VOBARSA"),
                    SDMX20Value("FREQUENCY", "Q"),
                ]).nullable,
            SDMX20Attributes([
                SDMX20Value("TIME_FORMAT", "P3M"),
                SDMX20Value("UNIT", "AUD"),
                SDMX20Value("POWERCODE", "6"),
                SDMX20Value("REFERENCEPERIOD", "2015"),
            ]).nullable,
            [
                SDMX20Obs(
                    SDMX20Time("2009-Q2").nullable,
                    SDMX20ObsValue((1_396_893.).nullable)
                    .nullable
                ),
                SDMX20Obs(
                    SDMX20Time("2009-Q3").nullable,
                    SDMX20ObsValue((1_401_636.8).nullable).nullable
                )
            ]
            ),
            SDMX20Series(
                SDMX20SeriesKey([
                    SDMX20Value("LOCATION", "AUT"),
                    SDMX20Value("SUBJECT", "B1_GE"),
                    SDMX20Value("MEASURE", "VOBARSA"),
                    SDMX20Value("FREQUENCY", "Q"),
                ]).nullable,
            SDMX20Attributes([
                SDMX20Value("TIME_FORMAT", "P3M"),
                SDMX20Value("UNIT", "EUR"),
                SDMX20Value("POWERCODE", "6"),
                SDMX20Value("REFERENCEPERIOD", "2015"),
            ]).nullable,
            [
                SDMX20Obs(
                    SDMX20Time("2009-Q2").nullable,
                    SDMX20ObsValue((318_469.1).nullable)
                    .nullable
                ),
                SDMX20Obs(
                    SDMX20Time("2009-Q3").nullable,
                    SDMX20ObsValue((319_685.5).nullable).nullable
                )
            ]
            )
        ]
    ));
}

@("decode an SDMX-ML 2.0 compactdata message")
unittest
{
    auto msg = getDataFixture("compactdata");
    msg.shouldEqual(SDMX20DataSet(
            "https://stats-1.oecd.org/RestSDMX/sdmx.ashx/GetKeyFamily/QNA".nullable,
            (Nullable!SDMX20KeyFamilyRef)
            .init,
            [
                SDMX20Series(
                (Nullable!SDMX20SeriesKey).init,
                (Nullable!SDMX20Attributes)
                .init,
                [
                    SDMX20Obs(
                    (Nullable!SDMX20Time).init,
                    (Nullable!SDMX20ObsValue).init,
                    ["TIME": "2009-Q2", "OBS_VALUE": "1396893"]
                    ),
                    SDMX20Obs(
                    (Nullable!SDMX20Time).init,
                    (Nullable!SDMX20ObsValue)
                    .init,
                    ["TIME": "2009-Q3", "OBS_VALUE": "1401636.8"]
                    )
                ],
                [
                    "LOCATION": "AUS",
                    "SUBJECT": "B1_GE",
                    "MEASURE": "VOBARSA",
                    "FREQUENCY": "Q",
                    "TIME_FORMAT": "P3M",
                    "UNIT": "AUD",
                    "POWERCODE": "6",
                    "REFERENCEPERIOD": "2015",
                ]
                ),
                SDMX20Series(
                (Nullable!SDMX20SeriesKey).init,
                (Nullable!SDMX20Attributes)
                .init,
                [
                    SDMX20Obs(
                    (Nullable!SDMX20Time).init,
                    (Nullable!SDMX20ObsValue).init,
                    ["TIME": "2009-Q2", "OBS_VALUE": "318469.1"]
                    ),
                    SDMX20Obs(
                    (Nullable!SDMX20Time).init,
                    (Nullable!SDMX20ObsValue)
                    .init,
                    ["TIME": "2009-Q3", "OBS_VALUE": "319685.5"]
                    )
                ],
                [
                    "LOCATION": "AUT",
                    "SUBJECT": "B1_GE",
                    "MEASURE": "VOBARSA",
                    "FREQUENCY": "Q",
                    "TIME_FORMAT": "P3M",
                    "UNIT": "EUR",
                    "POWERCODE": "6",
                    "REFERENCEPERIOD": "2015",
                ]
                )
            ]
    ));
}
