# run snowflake_connection_sqlalchemy.py
#"""Snowflake Python examples.
#This file shows two open-source connection patterns:
#1. Raw driver: snowflake-connector-python
#2. SQLAlchemy dialect: snowflake-sqlalchemy

#Requirements:
#  pip install snowflake-connecto

#Environment variables:
#  SNOWFLAKE_USER
#  SNOWFLAKE_PASSWORD
#  SNOWFLAKE_ACCOUNT
#  SNOWFLAKE_WAREHOUSE
#  SNOWFLAKE_DATABASE
##  SNOWFLAKE_SCHEMA
#  SNOWFLAKE_ROLE
#"""

#gitlab repo: 
# https://github.com/ivital-code/e2e-data-engineering

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
# cmd.exe /c "set SNOWFLAKE_USER=snf_srvacc&& set SNOWFLAKE_PASSWORD=Laspalmas25011965$&& set SNOWFLAKE_ACCOUNT=ohwwdyr-vk51395&& set SNOWFLAKE_WAREHOUSE=COMPUTE_WH&& set SNOWFLAKE_DATABASE=AIRBNB&& set SNOWFLAKE_SCHEMA=DEV&& set SNOWFLAKE_ROLE=MY_SERVICE_ROLE&& cd /d C:\Users\52332\e2e-data-engineering&& python snowflake_connection_sqlalchemy.py"

import os
from typing import List, Optional

import snowflake.connector

from sqlalchemy import create_engine, text
from snowflake.sqlalchemy import URL


def get_required_env_var(name: str) -> str:
    value = os.environ.get(name)
    if not value:
        raise EnvironmentError(f"Missing required environment variable: {name}")
    return value


def get_snowflake_connection() -> snowflake.connector.SnowflakeConnection:
    return snowflake.connector.connect(
        user=get_required_env_var("SNOWFLAKE_USER"),
        password=get_required_env_var("SNOWFLAKE_PASSWORD"),
        account=get_required_env_var("SNOWFLAKE_ACCOUNT"),
        warehouse=os.environ.get("SNOWFLAKE_WAREHOUSE"),
        database=os.environ.get("SNOWFLAKE_DATABASE"),
        schema=os.environ.get("SNOWFLAKE_SCHEMA"),
        role=os.environ.get("SNOWFLAKE_ROLE"),
    )


def get_sqlalchemy_engine():
    url = URL(
        user=get_required_env_var("SNOWFLAKE_USER"),
        password=get_required_env_var("SNOWFLAKE_PASSWORD"),
        account=get_required_env_var("SNOWFLAKE_ACCOUNT"),
        warehouse=os.environ.get("SNOWFLAKE_WAREHOUSE"),
        database=os.environ.get("SNOWFLAKE_DATABASE"),
        schema=os.environ.get("SNOWFLAKE_SCHEMA"),
        role=os.environ.get("SNOWFLAKE_ROLE"),
    )
    return create_engine(url)

def run_raw_query(query: str) -> List[tuple]:
    with get_snowflake_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(query)
            return cur.fetchall()



def run_sqlalchemy_query(query: str) -> List[tuple]:
    engine = get_sqlalchemy_engine()
    with engine.connect() as conn:
        result = conn.execute(text(query))
        return result.fetchall()


def main():
    # query = "SELECT current_version() AS version"
    query = "select REVIEWER_NAME,REVIEW_TEXT from AIRBNB.DEV.FCT_REVIEWS fetch first 5 rows only"; 
   
    print("Running raw Snowflake connector example...")
    raw_rows = run_raw_query(query)
    print(raw_rows)

    print("\nRunning SQLAlchemy Snowflake example...")
    sa_rows = run_sqlalchemy_query(query)
    print(sa_rows)


if __name__ == "__main__":
    main()
