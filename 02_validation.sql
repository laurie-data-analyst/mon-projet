-- ================================================
-- PROJET PORTFOLIO — EHPAD
-- Fichier : 02_validation.sql
-- Objectif : Vérifier la qualité des données
--            avant toute analyse
-- Auteur : Laurie
-- Date : avril 2026
-- Dataset : Données synthétiques EHPAD — 5 établissements, 2022-2023
-- ================================================


-- ------------------------------------------------
-- BLOC 1 — COMPTAGE ET COMPLÉTUDE
-- ------------------------------------------------
-- Vérification du nombre de lignes attendu par table
SELECT 'etablissements'       AS table_name, COUNT(*) AS nb_lignes FROM etablissements
UNION ALL
SELECT 'occupation_mensuelle', COUNT(*) FROM occupation_mensuelle
UNION ALL
SELECT 'rh_mensuel',           COUNT(*) FROM rh_mensuel
UNION ALL
SELECT 'incidents_qualite',    COUNT(*) FROM incidents_qualite;

-- ✅ Résultat Bloc 1 : 4 tables importées, volumes conformes aux attentes
-- etablissements : 5 lignes | occupation_mensuelle : 120 lignes
-- rh_mensuel : 360 lignes  | incidents_qualite : 536 lignes


-- ------------------------------------------------
-- BLOC 2 — VALEURS NULL
-- ------------------------------------------------

-- Vérification des NULL sur les colonnes critiques de etablissements
-- Colonnes critiques : identifiant, capacité et statut qui servent dans les jointures et analyses
SELECT
    COUNT(*) FILTER (WHERE id_etablissement IS NULL)  AS null_id_etablissement,
    COUNT(*) FILTER (WHERE nom IS NULL)               AS null_nom,
    COUNT(*) FILTER (WHERE capacite_lits IS NULL)     AS null_capacite_lits,
    COUNT(*) FILTER (WHERE statut IS NULL)            AS null_statut,
    COUNT(*) FILTER (WHERE annee_ouverture IS NULL)   AS null_annee_ouverture
FROM etablissements;

-- Vérification des NULL sur les colonnes critiques de incidents_qualite
-- Colonnes critiques : clé de jointure, type d'incident, nombre et gravités
-- car la somme des gravités doit toujours égaler le nombre total d'incidents
SELECT
    COUNT(*) FILTER (WHERE id_etablissement IS NULL)        AS null_id_etablissement,
    COUNT(*) FILTER (WHERE type_incident IS NULL)           AS null_type_incident,
    COUNT(*) FILTER (WHERE nombre IS NULL)                  AS null_nombre,
    COUNT(*) FILTER (WHERE gravite_mineure IS NULL)         AS null_gravite_mineure,
    COUNT(*) FILTER (WHERE gravite_moderee IS NULL)         AS null_gravite_moderee,
    COUNT(*) FILTER (WHERE gravite_grave IS NULL)           AS null_gravite_grave,
    COUNT(*) FILTER (WHERE hospitalisation_generee IS NULL) AS null_hospitalisation
FROM incidents_qualite;

-- Vérification des NULL sur les colonnes critiques de rh_mensuel
-- Colonnes critiques : clé de jointure, colonnes sources des calculs (jours, effectifs)
-- et colonnes dérivées (taux, coût) qui dépendent des colonnes sources
SELECT
    COUNT(*) FILTER (WHERE id_etablissement IS NULL)      AS null_id_etablissement,
    COUNT(*) FILTER (WHERE categorie IS NULL)             AS null_categorie,
    COUNT(*) FILTER (WHERE effectif_prevu IS NULL)        AS null_effectif_prevu,
    COUNT(*) FILTER (WHERE jours_ouvres IS NULL)          AS null_jours_ouvres,
    COUNT(*) FILTER (WHERE jours_absence IS NULL)         AS null_jours_absence,
    COUNT(*) FILTER (WHERE taux_absenteisme_pct IS NULL)  AS null_taux_absenteisme,
    COUNT(*) FILTER (WHERE cout_interim_euros IS NULL)    AS null_cout_interim
FROM rh_mensuel;

-- Vérification des NULL sur les colonnes critiques de occupation_mensuelle
SELECT
    COUNT(*)                                                 AS total_lignes,
    COUNT(*) FILTER (WHERE id_etablissement IS NULL)         AS null_id_etab,
    COUNT(*) FILTER (WHERE annee IS NULL)                    AS null_annee,
    COUNT(*) FILTER (WHERE taux_occupation_pct IS NULL)      AS null_taux,
    COUNT(*) FILTER (WHERE lits_occupes IS NULL)             AS null_lits
FROM occupation_mensuelle;

-- ✅ Résultat Bloc 2 : Aucune valeur NULL détectée sur les colonnes critiques


-- ------------------------------------------------
-- BLOC 3 — COHÉRENCE DES VALEURS
-- ------------------------------------------------

-- Vérification des bornes min/max sur etablissements
-- capacite_lits doit être positif
-- annee_ouverture doit être réaliste (pas avant 1950, pas dans le futur)
SELECT
    MIN(capacite_lits)      AS min_capacite_lits,
    MAX(capacite_lits)      AS max_capacite_lits,
    MIN(annee_ouverture)    AS min_annee_ouverture,
    MAX(annee_ouverture)    AS max_annee_ouverture
FROM etablissements;

-- Vérification des bornes min/max sur rh_mensuel
-- taux_absenteisme_pct doit être entre 0 et 1
-- effectif_prevu doit être positif
-- jours_ouvres doit être entre 18 et 23 (réalité calendaire)
-- jours_absence ne peut pas dépasser jours_ouvres x effectif_prevu
-- cout_interim_euros doit être positif ou zéro
SELECT
    MIN(taux_absenteisme_pct)   AS min_taux_abs,
    MAX(taux_absenteisme_pct)   AS max_taux_abs,
    MIN(effectif_prevu)         AS min_effectif,
    MAX(effectif_prevu)         AS max_effectif,
    MIN(jours_ouvres)           AS min_jours_ouvres,
    MAX(jours_ouvres)           AS max_jours_ouvres,
    MIN(jours_absence)          AS min_jours_absence,
    MAX(jours_absence)          AS max_jours_absence,
    MIN(cout_interim_euros)     AS min_cout_interim,
    MAX(cout_interim_euros)     AS max_cout_interim,
    MIN(annee)                  AS min_annee,
    MAX(annee)                  AS max_annee,
    MIN(mois)                   AS min_mois,
    MAX(mois)                   AS max_mois
FROM rh_mensuel;

-- Vérification mathématique : jours_absence ne peut pas dépasser
-- le total de jours possibles (jours_ouvres x effectif_prevu)
-- Si cette requête retourne des lignes, la donnée est corrompue
SELECT *
FROM rh_mensuel
WHERE jours_absence > jours_ouvres * effectif_prevu;

-- Vérification des bornes min/max sur incidents_qualite
-- nombre doit être positif
-- la somme des gravités ne peut pas dépasser le nombre total d'incidents
SELECT
    MIN(annee)                  AS min_annee,
    MAX(annee)                  AS max_annee,
    MIN(mois)                   AS min_mois,
    MAX(mois)                   AS max_mois,
    MIN(nombre)                 AS min_nombre,
    MAX(nombre)                 AS max_nombre,
    MIN(gravite_mineure)        AS min_gravite_mineure,
    MAX(gravite_mineure)        AS max_gravite_mineure,
    MIN(gravite_moderee)        AS min_gravite_moderee,
    MAX(gravite_moderee)        AS max_gravite_moderee,
    MIN(gravite_grave)          AS min_gravite_grave,
    MAX(gravite_grave)          AS max_gravite_grave,
    MIN(hospitalisation_generee) AS min_hospitalisation,
    MAX(hospitalisation_generee) AS max_hospitalisation
FROM incidents_qualite;

-- Vérification mathématique : la somme des gravités doit toujours
-- égaler le nombre total d'incidents
-- Une incohérence ici signalerait une erreur de saisie dans le système source
SELECT *
FROM incidents_qualite
WHERE (gravite_mineure + gravite_moderee + gravite_grave) != nombre;

-- Vérification des bornes min/max sur occupation_mensuelle
-- taux_occupation_pct doit être entre 0 et 1
-- sorties_deces doit être positif et inférieur à la moitié des lits occupés
SELECT
    MIN(taux_occupation_pct)    AS min_taux_occupation,
    MAX(taux_occupation_pct)    AS max_taux_occupation,
    MIN(sorties_deces)          AS min_sorties_deces,
    MAX(sorties_deces)          AS max_sorties_deces,
    MIN(annee)                  AS min_annee,
    MAX(annee)                  AS max_annee,
    MIN(mois)                   AS min_mois,
    MAX(mois)                   AS max_mois
FROM occupation_mensuelle;

-- ✅ Résultat Bloc 3 : Toutes les valeurs dans les bornes acceptables


-- ------------------------------------------------
-- BLOC 4 — INTÉGRITÉ DES JOINTURES
-- ------------------------------------------------
-- Vérification que toutes les clés étrangères des tables filles
-- pointent vers un établissement existant dans la table mère
-- Si une requête retourne des lignes, l'intégrité référentielle est compromise

SELECT DISTINCT id_etablissement
FROM occupation_mensuelle
WHERE id_etablissement NOT IN (
    SELECT id_etablissement
    FROM etablissements
);

SELECT DISTINCT id_etablissement
FROM incidents_qualite
WHERE id_etablissement NOT IN (
    SELECT id_etablissement
    FROM etablissements
);

SELECT DISTINCT id_etablissement
FROM rh_mensuel
WHERE id_etablissement NOT IN (
    SELECT id_etablissement
    FROM etablissements
);

-- ✅ Intégrité référentielle confirmée sur les 3 tables filles