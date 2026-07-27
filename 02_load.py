from io import StringIO
from dotenv import load_dotenv
import snowflake.connector 
# Import the necessary module
import os

# Load environment variables from the .env file (if present)
load_dotenv()

ctx = snowflake.connector.connect(
    user=os.getenv('SNOW_USER'),
    password=os.getenv('SNOW_PASSWORD'),
    account=os.getenv('SNOW_ACCOUNT')
)

cs = ctx.cursor()

try:
    cs.execute("SELECT current_version()")
    one_row = cs.fetchone()
    print(one_row[0])

    sql_script = """
    USE ROLE TRANSFORMAGRIBALYSE; 
    USE WAREHOUSE WH_AGRIBALYSE;
    USE DATABASE DATABASE_AGRIBALYSE;
    USE SCHEMA DATABASE_AGRIBALYSE.STAGING;
    TRUNCATE TABLE IF EXISTS  DATABASE_AGRIBALYSE.STAGING.AGRIBALYSE_DETAIL_PAR_INGREDIENT;
    
    -- SELECT CURRENT_ORGANIZATION_NAME() || '-' || CURRENT_ACCOUNT_NAME();
    PUT file:///home/valentin/analytics-engineer-plan/agribalyse/data/agribalyse-31-detail-par-ingredient.csv @agribalyse_stage AUTO_COMPRESS = TRUE;

    LIST @agribalyse_stage;

    -- VALIDATION_MODE = RETURN_10_ROWS utiliser uniquement lors du premier run pour valider que les 10 lignes dans le copy into sont sans erreurs d'accent, nombre etc.
    COPY INTO DATABASE_AGRIBALYSE.STAGING.AGRIBALYSE_DETAIL_PAR_INGREDIENT
            FROM @agribalyse_stage
        FILE_FORMAT = (FORMAT_NAME = 'ff_csv')
        PURGE = TRUE;
    """
    sql_stream = StringIO(sql_script)
    for result_cursor in ctx.execute_stream(sql_stream):
        for result in result_cursor:
            print(f"Result: {result}")

finally:
    cs.close()
ctx.close()