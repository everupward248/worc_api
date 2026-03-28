from psycopg import DatabaseError
from contextlib import asynccontextmanager
from psycopg_pool import AsyncConnectionPool
from psycopg.rows import dict_row
from src.helper_modules.logger_setup import get_logger


# initialize the logger
db_logger = get_logger(__name__)

# using a wrapper to handle the pool connections does not reduce repeated code but centralizes the error handling
@asynccontextmanager
async def get_connection(pool: AsyncConnectionPool):
    """
    fetches a connection from the connection pool and separates connection level errors from query logic
    """
    try:
        async with pool.connection() as conn:
            db_logger.info("connection acquired")
            yield conn
            db_logger.info("connection released")
    except DatabaseError as e:
        db_logger.warning(e)
        raise e

# test function to verify that api is connecting and returning from the database properly
async def test_logic(pool: AsyncConnectionPool):
    """
    Fetch the first 5 jobs from the database as a test
    """
    async with get_connection(pool) as conn:
        try:
            # dict row converts the response from the database into python dictionary at the driver level to avoid manual conversion
            async with conn.cursor(row_factory=dict_row) as cur:
                query = """
                    SELECT * FROM jobs LIMIT 5
                """

                await cur.execute(query)

                data = await cur.fetchall()
                db_logger.info(data)
            return data
        except DatabaseError as query_error:
            db_logger.warning({
                "error": str(query_error),
                "context": "query execution",
                "query": query
            })