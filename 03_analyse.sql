-- ================================================
-- PROJET PORTFOLIO — EHPAD
-- Fichier : 03_analyse.sql
-- Objectif : Répondre aux questions business
--            du directeur du groupe
-- Auteur : Laurie
-- Date : avril 2026
-- ================================================

-- Contexte mission : le directeur signale un absentéisme
-- élevé, un établissement à Bordeaux préoccupant, et des
-- écarts de coûts inexpliqués entre les 5 établissements.
-- Plan d'analyse : 3 axes — absentéisme, Bordeaux, benchmark

-- ================================================
-- AXE 1 — ABSENTÉISME ET IMPACT FINANCIER
-- ================================================

-- Question 1 & 2 : taux d'absentéisme par établissement et catégorie + référence benchmark groupe

-- Vue détaillée : taux mensuel — pour investigation
SELECT e.id_etablissement, e.nom, 
       ROUND(rm.taux_absenteisme_pct * 100, 2) AS taux_abs_pct, 
       rm.categorie, rm.mois, rm.annee
FROM etablissements e 
JOIN rh_mensuel rm ON e.id_etablissement = rm.id_etablissement
ORDER BY e.id_etablissement, rm.annee, rm.mois;

-- Vue agrégée : taux moyen annuel — pour comparaison
SELECT e.nom, e.ville, rm.categorie, rm.annee,
       ROUND(AVG(rm.taux_absenteisme_pct) * 100, 2) AS taux_abs_moyen_pct
FROM etablissements e
JOIN rh_mensuel rm ON e.id_etablissement = rm.id_etablissement
GROUP BY e.nom, e.ville, rm.categorie, rm.annee
ORDER BY taux_abs_moyen_pct DESC, rm.categorie;

-- Benchmark groupe : moyenne par catégorie toutes établissements
SELECT categorie, annee,
       ROUND(AVG(taux_absenteisme_pct) * 100, 2) AS taux_abs_moyen_pct
FROM rh_mensuel
GROUP BY categorie, annee
ORDER BY taux_abs_moyen_pct DESC, categorie;

-- Conclusions :
-- Saint-Joseph (Bordeaux) affiche un absentéisme structurel
-- supérieur à la moyenne groupe sur toutes les catégories :
-- Soignants  : 12.15% (2022) / 12.55% (2023) vs 10.07% / 10.06% groupe → écart qui se creuse
-- Service    : 11.23% (2022) / 11.04% (2023) vs 8.79% groupe
-- Administratif : 8.75% (2022) / 8.78% (2023) vs 6.50% / 6.47% groupe
-- Constat clé : absentéisme structurel ancré depuis 2 ans, toutes catégories touchées

-- Question 3 : Coût financier intérim 
-- Calcul des coûts de l'interim par an et par établissements
SELECT SUM(rh.cout_interim_euros) AS cout_interim_total, rh.annee, e.nom 
FROM rh_mensuel rh
JOIN etablissements e 
ON rh.id_etablissement = e.id_etablissement
GROUP BY rh.id_etablissement, rh.annee, e.nom
ORDER BY cout_interim_total DESC;

-- Calcul des coûts de l'interim par an 
SELECT SUM(cout_interim_euros) AS cout_interim_total,annee
FROM rh_mensuel 
GROUP BY annee
ORDER BY annee;

-- Conclusions Axe 1 — Impact financier
-- Coût intérim groupe : 34 440€ (2022) / 34 441€ (2023) — stable
-- 
-- Attention : le coût le plus élevé n'est pas l'établissement avec le plus fort taux d'absentéisme.
-- Saint-Joseph (68 lits) a le taux le plus élevé mais un coût intérim inférieur à la Résidence du Parc (95 lits) et 
-- Villa Sérénité (115 lits) en raison de sa plus petite taille.
-- Constat clé : pour comparer les établissements équitablement il faut raisonner en TAUX et non en valeur absolue.
-- Le taux d'absentéisme reste l'indicateur le plus fiable pour identifier un problème structurel.
-- Constat clé : absentéisme structurel ancré depuis 2 ans, toutes catégories touchées
-- La stabilité des taux entre 2022 et 2023 confirme que le problème n'est pas traité et risque de s'aggraver sans intervention ciblée sur Saint-Joseph

-- ================================================
-- AXE 2 — ETABLISSEMENT ST JOSEPH BORDEAUX
-- ================================================

-- Question 1 : Saint-Joseph a-t-il plus d'incidents que les autres ?
-- Comparaison du volume et de la gravité des incidents entre établissements
-- Indicateur clé : incidents par lit pour neutraliser l'effet taille

-- Question 2 : L'absentéisme impacte-t-il le taux d'occupation ?
-- Analyse du taux d'occupation et de la durée d'attente par établissement
SELECT 
    e.nom,
    SUM(iq.nombre)                  AS total_incidents,
    SUM(iq.gravite_grave)           AS total_graves,
    SUM(iq.hospitalisation_generee) AS total_hospitalisations,
	SUM(iq.nombre) / e.capacite_lits AS taux_incident_par_lit
FROM incidents_qualite iq
JOIN etablissements e ON iq.id_etablissement = e.id_etablissement
GROUP BY e.nom, e.capacite_lits
ORDER BY total_incidents DESC;


-- Conclusions Axe 2 — Incidents qualité
-- En valeur absolue Saint-Joseph n'est pas le plus élevé (291 incidents vs 305 pour Villa Sérénité)
-- Mais ramené à la capacité en lits :
-- Saint-Joseph    : 4 incidents/lit (68 lits)
-- Villa Sérénité  : 2 incidents/lit (115 lits)
-- Autres centres  : 3 incidents/lit
--
-- Constat clé : Saint-Joseph concentre le plus de risques qualité par résident. 
-- Combiné à son absentéisme structurel élevé, le lien entre manque de personnel et qualité de soin est fortement suggéré par les données.

SELECT e.nom, om.annee,
ROUND(AVG(om.taux_occupation_pct) * 100, 2) AS taux_occupation_moyen_pct,
ROUND(AVG(om.duree_attente_jours), 1) AS duree_attente_moyenne_jours
FROM occupation_mensuelle om
JOIN etablissements e ON om.id_etablissement = e.id_etablissement
GROUP BY e.nom, om.annee
ORDER BY e.nom;

-- Conclusions Axe 2 — Occupation Saint-Joseph
-- Taux d'occupation le plus bas du groupe : 89.12% (2022) / 89.33% (2023)
-- Durée d'attente paradoxalement élevée : 23.3j (2022) / 23j (2023)
--
-- Anomalie détectée : un établissement peu rempli devrait avoir
-- une liste d'attente courte — c'est l'inverse ici.
-- Hypothèse : l'absentéisme structurel freine les admissions,
-- l'établissement ne peut pas accueillir de nouveaux résidents
-- faute de personnel suffisant.
--
-- Constat clé Axe 2 complet :
-- Saint-Joseph cumule 3 signaux d'alerte interdépendants —
-- absentéisme le plus élevé du groupe, taux d'incidents/lit
-- le plus haut (4 vs 2-3 ailleurs), et taux d'occupation
-- le plus bas malgré une liste d'attente longue.
-- Ces 3 éléments forment un cercle vicieux qui nécessite
-- une intervention prioritaire.


-- ================================================
-- AXE 3 — BENCHMARK DES 5 ÉTABLISSEMENTS
-- ================================================

-- Objectif : créer une vue synthétique de tous les indicateurs
-- clés par établissement et par année pour permettre au directeur
-- de comparer et prioriser ses actions en un seul tableau

-- ------------------------------------------------
-- Benchmark synthétique — une ligne par établissement par année
-- Agrégation séparée de chaque table via CTE pour éviter
-- la multiplication des lignes lors des jointures multiples
-- ------------------------------------------------

WITH occupation AS (
    SELECT id_etablissement, annee,
        ROUND(AVG(taux_occupation_pct) * 100, 2) AS taux_occupation_moyen,
        ROUND(AVG(duree_attente_jours), 1)        AS duree_attente_moyenne
    FROM occupation_mensuelle
    GROUP BY id_etablissement, annee
),
incidents AS (
    SELECT id_etablissement, annee,
        SUM(nombre)                   AS total_incidents,
        SUM(gravite_grave)            AS total_graves,
        SUM(hospitalisation_generee)  AS total_hospitalisations
    FROM incidents_qualite
    GROUP BY id_etablissement, annee
),
rh AS (
    SELECT id_etablissement, annee,
        ROUND(AVG(taux_absenteisme_pct) * 100, 2) AS taux_abs_moyen,
        SUM(cout_interim_euros)                    AS cout_interim_total
    FROM rh_mensuel
    GROUP BY id_etablissement, annee
)
SELECT
    e.nom,
    e.capacite_lits,
    o.annee,
    o.taux_occupation_moyen,
    o.duree_attente_moyenne,
    i.total_incidents,
    i.total_graves,
    i.total_hospitalisations,
    ROUND(i.total_incidents::numeric / e.capacite_lits, 2) AS incidents_par_lit,
    r.taux_abs_moyen,
    r.cout_interim_total
FROM etablissements e
JOIN occupation o  ON e.id_etablissement = o.id_etablissement
JOIN incidents i   ON e.id_etablissement = i.id_etablissement AND o.annee = i.annee
JOIN rh r          ON e.id_etablissement = r.id_etablissement AND o.annee = r.annee
ORDER BY e.nom, o.annee;

-- ------------------------------------------------
-- Conclusions Axe 3 — Benchmark des 5 établissements
-- ------------------------------------------------
-- MEILLEUR ÉLÈVE : Villa Sérénité (Nantes — 115 lits)
-- Meilleur taux d'occupation du groupe : 95.14% (2022) → 96.14% (2023)
-- Taux d'absentéisme le plus bas : 6.61% (2022) → 6.83% (2023)
-- Incidents par lit parmi les plus bas : 1.37 (2022) → 1.28 (2023) en baisse
-- Seul bémol : durée d'attente en forte hausse en 2023 (+7j) — à surveiller
--
-- ÉTABLISSEMENT PRIORITAIRE : Saint-Joseph (Bordeaux — 68 lits)
-- Absentéisme le plus élevé du groupe toutes catégories confondues
-- Taux d'occupation le plus bas : 89.12% (2022) / 89.33% (2023)
-- Incidents par lit les plus élevés : 4/lit vs 2-3 ailleurs
-- Durée d'attente paradoxalement élevée malgré un faible remplissage
-- → Cercle vicieux confirmé : absentéisme → admissions freinées
--    → revenus réduits → incapacité à résoudre le problème RH
--
-- ÉTABLISSEMENTS À SURVEILLER : Jardins d'Automne et Résidence du Parc
-- Les deux présentent une combinaison préoccupante :
-- Taux d'occupation en légère baisse + durée d'attente en hausse (+4j)
-- Ce signal contradictoire est le même que celui observé à Saint-Joseph avant aggravation. Une vigilance s'impose pour éviter la même trajectoire.
--
-- Jardins d'Automne : incidents en baisse (131→118) — signal positif
-- Résidence du Parc : incidents en hausse (149→155) — signal négatif
-- Les deux ont des variations d'absentéisme légères mais à ne pas ignorer
--
-- CONSTAT CLÉ GLOBAL :
-- Les données 2022-2023 révèlent un groupe globalement stable
-- mais avec des fragilités structurelles concentrées sur 1 établissement
-- critique (Saint-Joseph) et 2 établissements en vigilance.
-- L'absentéisme est le fil conducteur de toutes les difficultés observées :
-- il impacte la qualité de soin, freine les admissions et génère
-- des coûts intérim qui pèsent sur la rentabilité du groupe.
-- ------------------------------------------------

-- Résultat Axe 3 : benchmark complet sur 10 indicateurs par établissement et par année — prêt pour Power BI

-- Note technique : utilisation de CTEs (Common Table Expressions) pour agréger chaque table séparément avant de les joindre.
-- Sans cette précaution, les jointures multiples entre tables de détail multiplieraient les lignes et fausseraient tous les calculs.