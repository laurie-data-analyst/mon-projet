-- ============================================================
-- PROJET PORTFOLIO — EHPAD
-- Script 01 : Création des tables
-- Base de données : ehpad_portfolio
-- ============================================================

-- Suppression des tables si elles existent déjà (pour pouvoir relancer proprement)
DROP TABLE IF EXISTS incidents_qualite;
DROP TABLE IF EXISTS rh_mensuel;
DROP TABLE IF EXISTS occupation_mensuelle;
DROP TABLE IF EXISTS etablissements;


-- ─────────────────────────────────────────────────────────────
-- TABLE 1 : etablissements
-- Référentiel des 5 EHPAD du groupe
-- ─────────────────────────────────────────────────────────────
CREATE TABLE etablissements (
    id_etablissement    VARCHAR(10)     PRIMARY KEY,
    nom                 VARCHAR(60)     NOT NULL,
    ville               VARCHAR(30)     NOT NULL,
    region              VARCHAR(50)     NOT NULL,
    statut              VARCHAR(25)     NOT NULL,
    capacite_lits       SMALLINT        NOT NULL CHECK (capacite_lits > 0),
    annee_ouverture     SMALLINT        NOT NULL,
    directeur           VARCHAR(40),
    gestionnaire        VARCHAR(30)
);


-- ─────────────────────────────────────────────────────────────
-- TABLE 2 : occupation_mensuelle
-- Taux de remplissage et flux résidents — 24 mois
-- ─────────────────────────────────────────────────────────────
CREATE TABLE occupation_mensuelle (
    id                          SERIAL          PRIMARY KEY,
    id_etablissement            VARCHAR(10)     NOT NULL REFERENCES etablissements(id_etablissement),
    annee                       SMALLINT        NOT NULL,
    mois                        SMALLINT        NOT NULL CHECK (mois BETWEEN 1 AND 12),
    mois_label                  VARCHAR(12)     NOT NULL,
    capacite_lits               SMALLINT        NOT NULL,
    lits_occupes                SMALLINT        NOT NULL,
    taux_occupation_pct         NUMERIC(5,4)    NOT NULL,
    nouveaux_entrants           SMALLINT        NOT NULL DEFAULT 0,
    sorties_deces               SMALLINT        NOT NULL DEFAULT 0,
    sorties_autres              SMALLINT        NOT NULL DEFAULT 0,
    duree_attente_jours         SMALLINT
);


-- ─────────────────────────────────────────────────────────────
-- TABLE 3 : rh_mensuel
-- Absentéisme, effectifs et coûts intérim — 24 mois
-- ─────────────────────────────────────────────────────────────
CREATE TABLE rh_mensuel (
    id                          SERIAL          PRIMARY KEY,
    id_etablissement            VARCHAR(10)     NOT NULL REFERENCES etablissements(id_etablissement),
    annee                       SMALLINT        NOT NULL,
    mois                        SMALLINT        NOT NULL CHECK (mois BETWEEN 1 AND 12),
    mois_label                  VARCHAR(12)     NOT NULL,
    categorie                   VARCHAR(20)     NOT NULL,
    effectif_prevu              SMALLINT        NOT NULL,
    jours_ouvres                SMALLINT        NOT NULL,
    jours_absence               SMALLINT        NOT NULL DEFAULT 0,
    taux_absenteisme_pct        NUMERIC(5,4)    NOT NULL,
    motif_maladie               SMALLINT        NOT NULL DEFAULT 0,
    motif_at                    SMALLINT        NOT NULL DEFAULT 0,
    motif_maternite             SMALLINT        NOT NULL DEFAULT 0,
    motif_autre                 SMALLINT        NOT NULL DEFAULT 0,
    heures_interim              SMALLINT        NOT NULL DEFAULT 0,
    cout_interim_euros          NUMERIC(8,2)    NOT NULL DEFAULT 0
);


-- ─────────────────────────────────────────────────────────────
-- TABLE 4 : incidents_qualite
-- Incidents déclarés par type et gravité — 24 mois
-- ─────────────────────────────────────────────────────────────
CREATE TABLE incidents_qualite (
    id                          SERIAL          PRIMARY KEY,
    id_etablissement            VARCHAR(10)     NOT NULL REFERENCES etablissements(id_etablissement),
    annee                       SMALLINT        NOT NULL,
    mois                        SMALLINT        NOT NULL CHECK (mois BETWEEN 1 AND 12),
    mois_label                  VARCHAR(12)     NOT NULL,
    type_incident               VARCHAR(30)     NOT NULL,
    nombre                      SMALLINT        NOT NULL DEFAULT 0,
    gravite_mineure             SMALLINT        NOT NULL DEFAULT 0,
    gravite_moderee             SMALLINT        NOT NULL DEFAULT 0,
    gravite_grave               SMALLINT        NOT NULL DEFAULT 0,
    hospitalisation_generee     SMALLINT        NOT NULL DEFAULT 0,
    declaration_ARS             VARCHAR(3)      NOT NULL CHECK (declaration_ARS IN ('Oui','Non'))
);


-- ─────────────────────────────────────────────────────────────
-- Vérification : affiche les tables créées
-- ─────────────────────────────────────────────────────────────
SELECT
    table_name,
    (SELECT COUNT(*) FROM information_schema.columns
     WHERE table_name = t.table_name
     AND table_schema = 'public') AS nb_colonnes
FROM information_schema.tables t
WHERE table_schema = 'public'
  AND table_name IN ('etablissements','occupation_mensuelle','rh_mensuel','incidents_qualite')
ORDER BY table_name;
