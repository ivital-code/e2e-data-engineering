# example programa to connect to snowflake
# setup environment variables in windows
#cmd.exe /c "set SNOWFLAKE_USER=snf_srvacc&& set SNOWFLAKE_PASSWORD=Laspalmas25011965$&& set SNOWFLAKE_ACCOUNT=ohwwdyr-vk51395&& set SNOWFLAKE_WAREHOUSE=COMPUTE_WH&& set SNOWFLAKE_DATABASE=AIRBNB&& set SNOWFLAKE_SCHEMA=DEV&& set SNOWFLAKE_ROLE=MY_SERVICE_ROLE&& cd /d C:\Users\52332\e2e-data-engineering&& .venv\Scripts\python.exe snowflake_connection.py"
import os
import snowflake.connector


def get_snowflake_connection():
    """Create and return a Snowflake connection using environment variables."""
    return snowflake.connector.connect(
        user=os.environ.get("SNOWFLAKE_USER"),
        password=os.environ.get("SNOWFLAKE_PASSWORD"),
        account=os.environ.get("SNOWFLAKE_ACCOUNT"),
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
    sample_query = "SELECT current_version() AS version"
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
