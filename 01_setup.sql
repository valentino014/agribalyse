-- contexte
USE ROLE ACCOUNTADMIN;

-- rôle du projet
CREATE ROLE IF NOT EXISTS TRANSFORMAGRIBALYSE;

-- database 
CREATE DATABASE IF NOT EXISTS DATABASE_AGRIBALYSE;

-- schema 
CREATE SCHEMA IF NOT EXISTS DATABASE_AGRIBALYSE.STAGING;
CREATE SCHEMA IF NOT EXISTS DATABASE_AGRIBALYSE.INTERMEDIATE;
CREATE SCHEMA IF NOT EXISTS DATABASE_AGRIBALYSE.MARTS;

-- warehouse 
CREATE WAREHOUSE IF NOT EXISTS WH_AGRIBALYSE
WAREHOUSE_SIZE = 'XSMALL'
AUTO_SUSPEND = 60 
AUTO_RESUME = TRUE 
INITIALLY_SUSPENDED = TRUE;


CREATE OR REPLACE RESOURCE MONITOR RM_AGRIBALYSE WITH
  CREDIT_QUOTA = 10
  FREQUENCY = MONTHLY
  START_TIMESTAMP = IMMEDIATELY
  NOTIFY_USERS = ('ONIZUKA01')
  TRIGGERS
    ON 50 PERCENT DO NOTIFY
    ON 80 PERCENT DO NOTIFY
    ON 100 PERCENT DO SUSPEND;

ALTER WAREHOUSE IF EXISTS WH_AGRIBALYSE SET RESOURCE_MONITOR = RM_AGRIBALYSE;

GRANT USAGE ON DATABASE DATABASE_AGRIBALYSE TO ROLE TRANSFORMAGRIBALYSE;
GRANT USAGE ON WAREHOUSE WH_AGRIBALYSE TO ROLE TRANSFORMAGRIBALYSE;
GRANT USAGE, CREATE TABLE, CREATE VIEW, CREATE STAGE, CREATE FILE FORMAT ON SCHEMA DATABASE_AGRIBALYSE.STAGING TO ROLE TRANSFORMAGRIBALYSE;
GRANT USAGE, CREATE TABLE, CREATE VIEW ON SCHEMA DATABASE_AGRIBALYSE.INTERMEDIATE TO ROLE TRANSFORMAGRIBALYSE;
GRANT USAGE, CREATE TABLE, CREATE VIEW ON SCHEMA DATABASE_AGRIBALYSE.MARTS        TO ROLE TRANSFORMAGRIBALYSE;
GRANT ROLE TRANSFORMAGRIBALYSE TO USER ONIZUKA01; 

USE ROLE TRANSFORMAGRIBALYSE; 
USE SCHEMA DATABASE_AGRIBALYSE.STAGING; 

CREATE OR ALTER STAGE agribalyse_stage
  ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE');

CREATE OR ALTER FILE FORMAT ff_csv
  TYPE = CSV
  SKIP_HEADER = 1
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
--  ENCODING = 'ISO88591'
  ;
  
CREATE TABLE IF NOT EXISTS DATABASE_AGRIBALYSE.STAGING.AGRIBALYSE_DETAIL_PAR_INGREDIENT (
   ciqual_agb                                  VARCHAR NOT NULL,
   ciqual_code                                 VARCHAR,
   nom_francais                                VARCHAR,
   groupe_daliment                             VARCHAR,
   sous_groupe_daliment                        VARCHAR,
   lci_name                                    VARCHAR,
   ingredients                                 VARCHAR NOT NULL,
   score_unique_ef                             FLOAT,
   changement_climatique                       FLOAT,
   appauvrissement_couche_dozone               FLOAT,
   rayonnements_ionisants                      FLOAT,
   formation_photochimique_dozone              FLOAT,
   particules_fines                            FLOAT,
   effets_toxico_sante_humaine_non_cancerogene FLOAT,
   effets_toxico_sante_humaine_cancerogene     FLOAT,
   acidification_terrestre_eaux_douces         FLOAT,
   eutrophisation_eaux_douces                  FLOAT,
   eutrophisation_marine                       FLOAT,
   eutrophisation_terrestre                    FLOAT,
   ecotoxicite_ecosystemes_aquatiques_eau_douce FLOAT,
   utilisation_du_sol                          FLOAT,
   epuisement_ressources_eau                   FLOAT,
   epuisement_ressources_energetiques          FLOAT,
   epuisement_ressources_mineraux              FLOAT
);