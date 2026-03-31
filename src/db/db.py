from psycopg_pool import AsyncConnectionPool
from urllib.parse import quote
import os

# factory function for creating the connection pool
# environment variables are declared in the function so that they only exist at runtime during the lifespan of the api
def create_pool() -> AsyncConnectionPool:
    # access environment variables
    HOST = os.getenv("HOST")
    DBNAME = os.getenv("DBNAME")
    USER = os.getenv("USER")
    PASSWORD = os.getenv("PASSWORD")

    if not all([HOST, DBNAME, USER, PASSWORD]):
        raise ValueError("Missing required database environment variables")
    else:
        # there is a special character contained in the password
        PASSWORD_ENCODED =  quote(str(PASSWORD), safe="")

    # create connection info DSN(data source name) to pass as argument to connection pool construction
    conninfo_url = f"postgresql://{USER}:{PASSWORD_ENCODED}@{HOST}/{DBNAME}"

    return AsyncConnectionPool(
        conninfo=conninfo_url,
        open=False, 
        min_size=5, 
        max_size=20
    )