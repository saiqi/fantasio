module tests.lib.operations;

import fantasio.lib.operations : join;
import unit_threaded;

@("join two ranges of structs")
@safe pure unittest
{
    import std.range : iota, walkLength;
    import std.algorithm : map, filter, all;

    static struct Foo
    {
        int id;
    }

    static struct Bar
    {
        int key;
    }

    {
        auto r = iota(3).map!(i => Foo(i))
            .join!(f => f.id, b => b.key)(
                iota(3).filter!(i => i % 2 == 0)
                    .map!(i => Bar(i)));
        assert(!r.empty);
        assert(r.front[0] == Foo(0) && r.front[1].get == Bar(0));
        r.popFront();
        assert(r.front[0] == Foo(1) && r.front[1].isNull);
        r.popFront();
        assert(r.front[0] == Foo(2) && r.front[1].get == Bar(2));
        r.popFront();
        assert(r.empty);
    }

    {
        auto r = iota(3).map!(i => Foo(i))
            .join!(f => f.id, b => b.key)(
                iota(4).filter!(i => i >= 3)
                    .map!(i => Bar(i)));
        assert(r.walkLength == 3);
        assert(r.all!"a[1].isNull");
    }

    {
        auto r = iota(3).filter!(i => i % 2 == 0)
            .map!(i => Foo(i))
            .join!(f => f.id, b => b.key)(
                iota(3).map!(i => Bar(i)));
        assert(!r.empty);
        assert(r.front[0] == Foo(0) && r.front[1].get == Bar(0));
        r.popFront();
        assert(r.front[0] == Foo(2) && r.front[1].get == Bar(2));
        r.popFront();
        assert(r.empty);
    }
}

@("join two lists of strings")
@safe pure unittest
{
    import std.algorithm : sort;

    auto left = ["FREQ"];
    auto right = [
        "FREQ", "INDICATEUR", "ACTIVITE", "SECT-INST", "FINANCEMENT", "OPERATION",
        "COMPTE", "NATURE-FLUX",
        "FORME-VENTE", "MARCHANDISE", "QUESTION", "INSTRUMENT", "PRODUIT",
        "NATURE", "METIER", "TYPE-ENT", "CAUSE-DECES",
        "CAT-DE", "TYPE-ETAB", "FONCTION", "FACTEUR-INV", "DEST-INV",
        "ETAT-CONSTRUCTION", "DEMOGRAPHIE", "TOURISME-INDIC",
        "TYPE-EMP", "TYPE-SAL", "CLIENTELE", "LOCAL", "LOGEMENT", "TYPE-MENAGE",
        "CARBURANT", "FORMATION", "EFFOPE",
        "SPECIALITE-SANTE", "ACCUEIL-PERS-AGEES", "DIPLOME", "ETAB-SCOL",
        "GEOGRAPHIE", "ZONE-GEO", "RESIDENCE",
        "LOCALISATION", "TYPE-EVO", "SEXE", "TYPE-FLUX", "CAT-FP", "PERIODE",
        "AGE", "TAILLE-ENT", "ANCIENNETE",
        "QUOTITE-TRAV", "PRIX", "UNITE", "CORRECTION", "TYPE-SURF-ALIM", "MONNAIE",
        "DEVISE", "REVENU", "MIN-FPE",
        "EXPAGRI", "CHEPTEL", "FEDERATION", "MARCHE", "UNIT_MULT", "BASE_PER",
        "CONSOMMATION_ALCOOL_RISQUE",
        "MODE_CONTAMINATION_VIH", "RENONCEMENT_SOINS", "STATUT_ACTIVITE",
        "TYPE_ROUTE", "GRANDS_USAGES_EAU", "QUALITE_EAU",
        "PRODUIT_PHYTOSANITAIRE", "RACE_LOCALE_CLASSEE", "MASSE_CORPORELLE",
        "NIVEAU-VIE-MEDIAN", "UNITE-CONSOMMATION",
        "CONNECTION_INTERNET", "CREDITS_PUBLICS_RD", "EMISSION_GES", "SESC",
        "DISCIPLINE", "NIV_COMP_NUM", "PROJ_EDUC_DD",
        "ENCADREMENT", "EMPREINTE-CARBONE", "EVENEMENTS-RISQUES-NATURELS",
        "CONFIANCE-INSTITUTIONS", "JUSTICE", "SECTEURS",
        "TYPE_MAT_PREM", "SOLS_ART", "TYPE_TRAITEMENT_DECH_MEN",
        "DECHETS-CONSO-MENAGES", "OCEANS-MERS-COURS-EAU",
        "REGIONS_ECO", "ETAT_CONSERV_HAB_NAT", "HAB_NAT", "REGION_BIOGEO",
        "POSTES_CORINE",
        "ETAT_TYPE-POLLUTION_IMPACTS_SITE", "AIRES_TERRESTRES_PROTEGEES",
        "ESPECES_EXOTIQUES", "POP_OISEAUX_COMMUNS",
        "AIDES-DEVELOPPEMENT", "REDRESSEMENT_TOUR", "SECTEUR_LOCATIF", "CMA_PM10",
        "STATIONS_MESURE", "EAU", "ASSAINISSEMENT",
        "ENERGIE_PRIMAIRE", "SUPPRESSION"
    ];

    auto r = left.join!(x => x, x => x)(right.sort);
    assert(!r.empty);
    assert(!r.front.right.isNull);
}
