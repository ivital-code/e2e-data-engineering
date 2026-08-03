
# gitlab repo: https://gitlab.com/ivital-code/e2e-data-engineering
#https://github.com/ivital-code/e2e-data-engineering

# example programa to connect to snowflake
# setup environment variables in windows
#Alternative PowerShell inline env vars
#$env:SNOWFLAKE_USER = "snf_srvacc"
#$env:SNOWFLAKE_PASSWORD = "Laspalmas25011965$"
#$env:SNOWFLAKE_ACCOUNT = "ohwwdyr-vk51395"
#$env:SNOWFLAKE_WAREHOUSE = "COMPUTE_WH"
#$env:SNOWFLAKE_DATABASE = "AIRBNB"
#$env:SNOWFLAKE_SCHEMA = "DEV"
#$env:SNOWFLAKE_ROLE = "MY_SERVICE_ROLE"

# snowflake connection setup
# create rol MY_SERVICE_ROLE;
#CREATE or replace USER snf_srvacc
#  PASSWORD = 'Laspalmas25011965$'
#  DEFAULT_ROLE = MY_SERVICE_ROLE
#  DEFAULT_WAREHOUSE = COMPUTE_WH
#  DEFAULT_NAMESPACE = my_database.public
#  MUST_CHANGE_PASSWORD = FALSE;

#GRANT ROLE MY_SERVICE_ROLE TO USER snf_srvacc;
#GRANT ALL PRIVILEGES ON DATABASE AIRBNB TO ROLE MY_SERVICE_ROLE;
#GRANT ALL PRIVILEGES ON schema DEV TO ROLE MY_SERVICE_ROLE;
#GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA AIRBNB.DEV TO ROLE MY_SERVICE_ROLE;

#or call direct
#python snowflake_connection.py
# cmd.exe /c "set SNOWFLAKE_USER=snf_srvacc&& set SNOWFLAKE_PASSWORD=Laspalmas25011965$&& set SNOWFLAKE_ACCOUNT=ohwwdyr-vk51395&& set SNOWFLAKE_WAREHOUSE=COMPUTE_WH&& set SNOWFLAKE_DATABASE=AIRBNB&& set SNOWFLAKE_SCHEMA=DEV&& set SNOWFLAKE_ROLE=MY_SERVICE_ROLE&& cd /d C:\Users\52332\e2e-data-engineering&& python snowflake_connection.py"

import os
import snowflake.connector


def get_required_env_var(name: str) -> str:
    value = os.environ.get(name)
    if not value:
        raise EnvironmentError(
            f"Missing required environment variable for Snowflake connection: {name}"
        )
    return value


def get_snowflake_connection():
    """Create and return a Snowflake connection using environment variables."""
    return snowflake.connector.connect(
        user=get_required_env_var("SNOWFLAKE_USER"),
        password=get_required_env_var("SNOWFLAKE_PASSWORD"),
        account=get_required_env_var("SNOWFLAKE_ACCOUNT"),
        warehouse=os.environ.get("SNOWFLAKE_WAREHOUSE"),
        database=os.environ.get("SNOWFLAKE_DATABASE"),
        schema=os.environ.get("SNOWFLAKE_SCHEMA"),
        role=os.environ.get("SNOWFLAKE_ROLE"),
    )


def run_query(query: str):
    """Run a query and return the result rows."""
    with get_snowflake_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(query)
            return cur.fetchall()


def main():
    #sample_query = "SELECT current_version() AS version"
    sample_query = "select REVIEWER_NAME,REVIEW_TEXT from AIRBNB.DEV.FCT_REVIEWS fetch first 3 rows only"; 
    try:
        rows = run_query(sample_query)
        print("Snowflake connection successful.")
        for row in rows:
            print(row)
    except Exception as exc:
        print("Snowflake connection failed:", exc)
        raise

# Run it with: python snowflake_connection.py
if __name__ == "__main__":
    main()
