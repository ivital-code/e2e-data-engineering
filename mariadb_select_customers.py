"""Query all rows from my_database.customers over verified TLS."""

from getpass import getpass
from pathlib import Path

import pymysql

HOST = "serverless-us-east-2.sysp0000.db1.skysql.com"
PORT = 4007
USER = "dbpwf20433812"
DATABASE = "my_database"
PASSWORD = "Losdelfines250165#"
CA_FILE = Path(__file__).with_name("mariadb-ca-bundle.pem")


def main() -> None:
    if not CA_FILE.is_file():
        raise FileNotFoundError(f"MariaDB CA bundle not found: {CA_FILE}")

   
    connection = pymysql.connect(
        host=HOST,
        port=PORT,
        user=USER,
        password=PASSWORD,
        database=DATABASE,
        ssl_ca=str(CA_FILE),
        ssl_verify_cert=True,
        ssl_verify_identity=True,
        cursorclass=pymysql.cursors.DictCursor,
        connect_timeout=10,
    )

    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT * FROM customers")
            for row in cursor.fetchall():
                print(row)
    finally:
        connection.close()


if __name__ == "__main__":
    main()
