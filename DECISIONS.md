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
- Nommable simplement
- il est grantable, ajout de droit possible
- Facile à documenter

### 4.5 Création du stage

**Choix** : Lors de la création du stage, je n'ajoute pas de OR REPLACE dans le SQL.
- **Justification** : Ajouter le OR REPLACE dans le SQL Snowflake viendrait à supprimer le fichier si jamais je rejoues le setup après avoir chargé une première fois.

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
Déclencheur — je colle une commande ou un bloc de code que je ne peux pas expliquer ligne par ligne.

Geste — je supprime ce que j'ai collé et je le réécris à la main, sans IA.

Trace — j'ouvre une entrée ÉCART dans le journal ci-dessous, le jour même.

**LOGS**
J141 — 27/07 — setup .venv + connexion dbt/Snowflake
- délégué : diagnostic d'un conflit venv/apt lié à la configuration de mon poste
- gardé : exécution des commandes et validation avant lancement
- écart : un rm -rf proposé, enlevé à la lecture
- check : réécriture prévue J142 — non bouclé à ce jour