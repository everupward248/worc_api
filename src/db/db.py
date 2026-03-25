from psycopg_pool import AsyncConnectionPool
from dotenv import load_dotenv
import os

# load environment variables from .env file
load_dotenv()

# access environment variables
HOST = os.getenv("HOST")
DBNAME = os.getenv("DBNAME")
USER = os.getenv("USER")
PASSWORD = os.getenv("PASSWORD")

# create connection info string to pass as argument to connection pool construction
conninfo_string = f"host={HOST} dbname={DBNAME} user={USER} password={PASSWORD}"

pool = AsyncConnectionPool(
    conninfo=conninfo_string,
    open=False, 
    min_size=5, 
    max_size=20
)