# DECISIONS — Agribalyse

Document utilisé pour la traçabilité des décisions techniques et de modélisation qui vont être prises dans le cadre de ce projet. 

## 1. Contexte et scope

- **Source** : AGRIBALYSE v3.2, Mis à jour le 27 février 2025
- **Volume** : 
  - 6 161 enregistrements

---

## 2. Questions métier (Q1 à Q5)

## 3. Décisions de modélisation

### 3.1 Grain
**Déclaration**
Une ligne représente un ingrédient que contient un produit. Chaque ligne permet de voir la part de l'ingrédient qui compose ce produit, afin de comprendre l'impact environnemental que l'ingrédient a. 
**Clé résultante**
`ciqual_agb`, `ingredients` sont composite, car `ciqual_agb` seul ne suffit pas mais couplé aux ingredients ils sont uniques. 
**Vérification**
```sql
select count(*) from database_agribalyse.staging.agribalyse_detail_par_ingredient;
```
Nous donne 6161 lignes.

```sql
select count(DISTINCT ciqual_agb) from database_agribalyse.staging.agribalyse_detail_par_ingredient;
```
Nous donne 1099 enregistrements. Pas une bonne clé car il y a une agrégation qui se fait. 

```sql
select count(DISTINCT ingredients) from database_agribalyse.staging.agribalyse_detail_par_ingredient;
```
Nous donne 287 enregistrements, donc pas assez atomique. 

```sql
select count(*) from database_agribalyse.staging.agribalyse_detail_par_ingredient
where ciqual_agb is null;
```
0 null, donc bon candidat.

```sql
select count(*) from database_agribalyse.staging.agribalyse_detail_par_ingredient
where ingredients is null;
```
0 null aussi, donc bon candidat.

```sql
select count(distinct ciqual_agb, ingredients) from database_agribalyse.staging.agribalyse_detail_par_ingredient;
```
Nous donne 6161 enregistrements soit autant que le CSV. La clé composite est donc parfaite ici puisqu'il y a une égalité entre COUNT(*) et count(DISTINCT ciqual_agb, ingredients).

 
**Non applicable par le SGBD**
Snowflake ne tient pas compte des `PRIMARY KEY` → l'unicité est garantie par `dbt_utils.unique_combination_of_columns`, pas par le DDL.
En revanche, le DDL a bien `NOT NULL` sur les deux clés (ciqual_agb et ingredients).

**Grain alternatif écarté**
- Une ligne par `ciqual_agb` écartée car cela va nous faire perdre les ingrédients, on ne pourra donc pas répondre à des questions d'analyse comme « les ingrédients ont-ils le même impact environnemental selon le produit».
- Une ligne par `ingredients` écartée car on se retrouve avec les ingrédients mais pas pour chaque produit, on ne pourra pas répondre à la question « quel produit est le plus polluant ».

## 4. Décisions techniques

### 4.1 Choix du Trial Snowflake

**Choix** : Utilisation du Trial Enterprise pour Snowflake
- **Justification** : Enterprise possède plusieurs éléments qui le rend plus attractif dans mon cas à moi :
- Enterprise possède des fonctionnalités qui vont être utiles pour l'examen de snowPro
- Les entreprises que je vise utilisent souvent SnowPro avec Enterprise (Agence de l'eau, SCP, BRGM...)
- Le surcoût d'Enterprise ne m,atteint pas, mon Warehouse XS auto-suspend ne consomme que très peu

### 4.2 Le schéma staging charge les données (CSV) 

**Choix** : Dans snowflake, pour l'attribution des droits, il y a CREATE STAGE et CREATE FILE FORMAT uniquement pour le schéma de staging
- **Justification** : J'ai choisi d'ajouter CREATE STAGE et CREATE FILE FORMAT pour charger manuellement mes données contenues dans mon CSV.  
J'ai choisi de ne pas partager cela aux autres schémas (intermediate et marts) car j'applique le principe de moindre privilège. Ainsi, chaque schéma n'a accès qu'à ce dont il a besoin et la reproductibilité est respectée. La restriction de privilège garantit donc que dbt est le seul producteur des couches en aval dont le marts.

### 4.3 Matérialisation : vue en staging, table en intermediate et marts

**Choix** : Staging va être matérialisé en vue et intermediate et marts vont être matérialisés en table.
- **Justification** : 
- Staging matérialisé en vue puisque le coût pour le réexécuter est faible, de plus la fréquence d'appel est faible.
- Marts et Intermediate matérialisés en table puisque ceux-ci ont des coûts de rejeu élevés. Intermediate va certes être moins appelé mais le coût de rejeu de ce dernier justifie une matérialisation en table.

### 4.4 Type de stage : User stage vs Table stage vs Named stage

**Choix** : Utilisation de Named stage comme stage interne
- **Justification** : 
- Nommable simplement.
- Il est grantable, ajout de droit possible.
- Facile à documenter.

### 4.5 Création du stage

**Choix** : Lors de la création du stage, je n'ajoute pas de OR REPLACE dans le SQL.
- **Justification** : Ajouter le OR REPLACE dans le SQL Snowflake viendrait à supprimer le fichier si jamais je rejoues le setup après avoir chargé une première fois.

### 4.6 Emplacement du projet dbt

**Choix** : dbt sera placé ici : `agribalyse/dbt_project/` Sous-dossier, `.github/` à la racine, comme le Projet 1.
- **Justification** : 
- L'alignement avec le projet 1 simplifie la compréhension et l'application des mêmes principes.
- Le placer dans le dossier `dbt_project` délimite bien ce qu'il est et permet une meilleure compréhension visuelle rapide. Cela ne va pas mélanger car j'ai des fichiers de documentation, de python etc. Ainsi, le découpage est plus clair.

### 4.7 Emplacement de profiles.yml

**Choix** : Le fichier sera placé dans le repo `agribalyse/dbt_project/`, à côté de `dbt_project.yml`. Configuration en clair mais secrets avec `env_var()`.
- **Justification** : 
- un seul fichier au lieu de deux, donc aucun risque de désynchronisation entre mon poste et la CI

### 4.8 Le rôle dbt

**Choix** : dbt a un rôle `TRANSFORMAGRIBALYSE` qui détient plusieurs privilèges : 
USAGE	DATABASE	DATABASE_AGRIBALYSE
OWNERSHIP	FILE_FORMAT	DATABASE_AGRIBALYSE.STAGING.FF_CSV
CREATE FILE FORMAT	SCHEMA	DATABASE_AGRIBALYSE.STAGING
CREATE STAGE	SCHEMA	DATABASE_AGRIBALYSE.STAGING
CREATE TABLE	SCHEMA	DATABASE_AGRIBALYSE.INTERMEDIATE
CREATE TABLE	SCHEMA	DATABASE_AGRIBALYSE.MARTS
CREATE TABLE	SCHEMA	DATABASE_AGRIBALYSE.STAGING
CREATE VIEW	SCHEMA	DATABASE_AGRIBALYSE.STAGING
USAGE	SCHEMA	DATABASE_AGRIBALYSE.INTERMEDIATE
USAGE	SCHEMA	DATABASE_AGRIBALYSE.MARTS
USAGE	SCHEMA	DATABASE_AGRIBALYSE.STAGING
OWNERSHIP	STAGE	DATABASE_AGRIBALYSE.STAGING.AGRIBALYSE_STAGE
OWNERSHIP	TABLE	DATABASE_AGRIBALYSE.STAGING.AGRIBALYSE_DETAIL_PAR_INGREDIENT
USAGE	WAREHOUSE	WH_AGRIBALYSE
- **Justification** : 
- J'ai préféré ne pas laisser `ACCOUNTADMIN` car cela permet de savoir qui a fait quoi plus facilement. De plus, on ne donne pas le rôle account admin afin d'éviter d'avoir tous les rôles et de faire des choses qu'on ne devrait pas avec tous les privilèges.

### 4.9 Freshness

**Choix** : Pas d'utilisation de freshness
- **Justification** : Je n'ai pas besoin de valider via le capteur (freshness) que le fichier est assez récent puisque mes données sont figées dans le temps. Sauf en cas de chargement aux deux ans (leur mise à jour), dans ce cas j'ajouterais freshness. 

### 4.10 Conventions des couches

**Choix** : Voici le choix pour les conventions :
- Préfixes de couche : staging stg, intermediate int, marts dim ou fct
- Casse des colonnes : écriture en minuscule (lower)
- Nommage des clés : _key pour les clés techniques
- Mesures d'impact : <indicateur>_<unité>_<dénominateur>. Voir section `Description des champs` présent ici - https://data.ademe.fr/datasets/agribalyse-31-detail-par-ingredient
- Booléen : Aucun actuellement, sinon bool_
- Unité dans le nom : oui
- Matérialisation : view pour staging, table pour intermediate et marts

### 4.11 Utilisation macro 

**Choix** : Utilisation de la macro `generate_schema_name.sql` et du bloc `+schema:` (dbt_project.yml) pour gérer le défaut délibéré de nommage de dbt. dbt offre la concaténation par défaut mais moi je ne veux appliquer celle par défaut car il nommerait STAGING_MARTS au lieu de juste MARTS pour mon projet.
- **Justification** : J'ai choisi la macro puisque je suis seul sinon j'aurais pu accorder `CREATE SCHEMA`et avoir `STAGING_MARTS`, `STAGING_INTERMEDIATE`. Mais étant seul, faire la macro me semble plus rapide et plus simple d'utilisation.

### 4.12 Placement de la clé de substitution 

**Choix** : Choix de placer la clé de substitution dans le staging.
- **Justification** : Placer la clé ici est plus simple en même temps que le renommage. 

### 4.13 FLOAT ou NUMBER

**Choix** : utilisation de FLOAT dans le cadre de ce projet.
- **Justification** : Choix d'utiliser FLOAT dans ce projet au lieu de NUMBER car cela simplifie. J'ai pas besoin d'une précision maximale dans mon projet personnel. 

### 4.14 Test not_null sur staging

**Choix** : tester not_null sur staging 
- **Justification** : En cas de changement de DDL je ne saurais pas si not_null est bien appliqué sur `ciqual_agb` ainsi que sur `ingredients`. J'ai choisi donc d'ajouter un test not_null sur ces deux là, en plus de celui de ma clé technique, afin d'attraper les erreurs étant donnés que ma clé technique ce base sur eux. 

### 4.15 Preuve des dépendances fonctionnelles

**Contexte** : J'ai effectué une analyse, via requête, pour vérifier si les dimensions choisies étaient valide.

**Méthode** : une dépendance fonctionnelle se réfute, elle ne se confirme pas.
Motif générique :

    select <clé>
    from <table>
    group by <clé>
    having count(distinct <attribut>) > 1

Zéro ligne = aucun contre-exemple, la dépendance tient.
N lignes = N contre-exemples, et ces lignes indiquent où regarder.

Exemple exécuté :

    select ciqual_agb
    from database_agribalyse.staging.agribalyse_detail_par_ingredient
    group by ciqual_agb
    having count(distinct nom_francais) > 1;

**Résultats** (12 mesures, table brute, 6161 lignes, AGRIBALYSE v3.2) :

| Clé                  | Attribut             | Lignes | Verdict          |
| -------------------- | -------------------- | -----: | ---------------- |
| ciqual_agb           | nom_francais         |      0 | tient            |
| ciqual_agb           | lci_name             |      0 | tient            |
| ciqual_agb           | sous_groupe_daliment |      0 | tient            |
| ciqual_agb           | groupe_daliment      |      0 | tient            |
| ciqual_agb           | ingredients          |   1094 | rompue           |
| sous_groupe_daliment | groupe_daliment      |      0 | tient            |
| lci_name             | groupe_daliment      |      0 | tient            |
| groupe_daliment      | sous_groupe_daliment |     11 | rompue           |
| groupe_daliment      | ingredients          |     11 | rompue           |
| ingredients          | groupe_daliment      |    128 | rompue           |
| lci_name             | nom_francais         |      2 | anomalie isolée  |
| nom_francais         | lci_name             |      1 | anomalie isolée  |

**Ce que ces mesures établissent** :
On constate que la clé `ciqual_agb` attire les attributs nom_francais, lci_name, sous_groupe_daliment, groupe_daliment. Tandis qu'ingredients échappe à cette clé, ce qui signifie que ces deux-là forment mon grain. 
sous_groupe_daliment et lci_name attire l'attribut groupe_daliment. 

**Anomalies relevées, non traitées** :
- 1 nom_francais portent plusieurs lci_name, non expliqué actuellement
- 2 lci_name portent plusieurs nom_francais, non expliqué à ce stade
- `Autres étapes` dans ingredients
- 27 différences dans le minus suivant : 
select ciqual_agb
from database_agribalyse.staging.agribalyse_detail_par_ingredient
minus 
select ciqual_code
from database_agribalyse.staging.agribalyse_detail_par_ingredient

## 5. AI in development

**Outils** : assistants IA (clarification de concepts, décodage d'erreurs, relecture).

**Ce que je laisse à l'IA**
- expliquer un concept Snowflake/dbt que je ne connais pas encore
- m'orienter vers la bonne page de documentation
- relire mon code et signaler bugs/incohérences
- utilisation pour setup/config de .venv et connexion snowflake via dbt

**Ce que je ne laisse JAMAIS à l'IA**
- l'écriture de mon SQL, YAML, Python, workflows CI
- le choix du grain, des métriques, de la modélisation dims/faits
- le clustering/partitioning

**Mon check** : 
- je réécris tout fichier que je ne peux pas réexpliquer le lendemain matin pour valider la rétention d'information.

**Si je franchis la ligne**
Déclencheur : je colle une commande ou un bloc de code que je ne peux pas expliquer ligne par ligne.
Geste : je supprime ce que j'ai collé et je le réécris à la main, sans IA.
Trace : j'ouvre une entrée ÉCART dans le journal ci-dessous, le jour même.

**LOGS**
J141 — 27/07 — setup .venv + connexion dbt/Snowflake
- délégué : diagnostic d'un conflit venv/apt lié à la configuration de mon poste
- gardé : exécution des commandes et validation avant lancement
- écart : un rm -rf proposé, enlevé à la lecture
- check : réécriture prévue J142 — non bouclé à ce jour

J143 - 29-01 - Dépendances fonctionnelles
- délégué : explication sur cette nouveauté
- gardé : squelette effectué par l'IA pour la décision 4.15 avec complétion par moi