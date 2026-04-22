# 📊 Analyse de la performance opérationnelle — Groupe EHPAD 2022-2023

> Étude de cas Data Analyst | SQL • PostgreSQL • Power BI • DAX

---

## 🏥 Contexte

Un directeur d'un groupe de 5 établissements EHPAD a sollicité une analyse 
de données suite à des doutes sur le niveau d'absentéisme de son personnel 
et les coûts associés. L'objectif : identifier les établissements en 
difficulté, comprendre les écarts de performance et proposer des actions 
concrètes.

---

## ❓ Problématique

> *"Certains établissements nous coûtent plus cher sans qu'on sache pourquoi. 
> Notre personnel est épuisé et un établissement à Bordeaux nous inquiète 
> particulièrement."*

L'analyse croise 4 sources de données sur la période 2022-2023 :
- Les 5 établissements du groupe (référentiel)
- L'absentéisme du personnel et les coûts d'intérim
- Les incidents qualité déclarés
- Le taux d'occupation et les flux de résidents

---

## 🔍 Ce que ce projet démontre

- Conception et alimentation d'une base de données relationnelle (PostgreSQL)
- Validation de la qualité des données en 4 blocs méthodiques
- Analyse SQL multi-tables avec jointures, agrégations et CTEs
- Création d'un dashboard Power BI avec mesures DAX et mise en forme conditionnelle
- Raisonnement business : traduction de données en recommandations actionnables

---

## 📁 Structure du projet
📁 portfolio-ehpad/
│
├── 📄 README.md
│
├── 📁 sql/
│   ├── 01_create_tables.sql      → Création des 4 tables PostgreSQL
│   ├── 02_validation.sql         → Validation qualité des données (4 blocs)
│   └── 03_analyse.sql            → Analyse business en 3 axes
│
├── 📊 dashboard_ehpad.pbix       → Dashboard Power BI (5 pages)
│
└── 📄 note_synthese_ehpad.docx   → Note de synthèse direction (2 pages)

---

## 📈 Résultats clés

| Indicateur | Résultat |
|---|---|
| Taux d'occupation moyen groupe | 92% |
| Taux d'absentéisme moyen groupe | 8,4% |
| Coût intérim total 2022-2023 | 68 852 € |
| Établissement prioritaire | Saint-Joseph (Bordeaux) |
| Établissements à surveiller | Jardins d'Automne & Résidence du Parc |
| Meilleur élève | Villa Sérénité (96% occupation, 6,7% absentéisme) |

**3 constats majeurs :**
- 🔴 Saint-Joseph cumule 3 signaux d'alerte : absentéisme +2,4 pts 
  au-dessus de la moyenne, 4 incidents/lit vs 3 en moyenne, 
  liste d'attente paradoxalement longue malgré le plus faible taux d'occupation
- ⚠️ Les Jardins d'Automne et la Résidence du Parc montrent 
  des signaux précoces de fragilisation
- ✅ Villa Sérénité constitue un modèle de bonnes pratiques transférables

---

## 🛠️ Outils utilisés

| Outil | Usage |
|---|---|
| PostgreSQL / pgAdmin | Base de données relationnelle |
| SQL | Validation, nettoyage et analyse des données |
| Power BI | Dashboard de visualisation (5 pages) |
| DAX | Mesures et indicateurs calculés |
| Word | Note de synthèse direction |

---

## ⚠️ Note sur les données

Les données utilisées sont synthétiques, construites à partir des 
références sectorielles publiées par la DREES, la HAS et la FEHAP 
(2022-2023), afin de simuler un environnement opérationnel réaliste. 
Elles ne représentent aucun établissement réel.

---

*Projet réalisé dans le cadre d'un portfolio Data Analyst — Avril 2026*
*Laurie | [The Digital By Lau](https://www.ledigitalbylau.fr)*
