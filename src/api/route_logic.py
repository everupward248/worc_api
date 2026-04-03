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
            # this ensures that the log occurs 100% of the time even if the connection fails
            try:
                yield conn
            finally:
                db_logger.info("connection released")
    except DatabaseError as e:
        db_logger.error(e)
        raise 

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
                db_logger.info("Test data successfully fetched from database")
            return data
        except DatabaseError as query_error:
            db_logger.error({
                "error": str(query_error),
                "context": "query execution",
                "query": query
            })
            raise

# function to return the industries from the db
async def industry(pool: AsyncConnectionPool, industry_id: int | None = None):
    """
    returns the industries from the db
    """
    async with get_connection(pool) as conn:
        try:
            async with conn.cursor(row_factory=dict_row) as cur:
                if industry_id is not None:
                    query = """
                    SELECT * FROM industries WHERE id = (%s)
                    """
                    await cur.execute(query, (industry_id,))
                else:    
                    query = """
                    SELECT * FROM industries
                    """
                    await cur.execute(query)
                data = await cur.fetchall()
                db_logger.info("Industry data successfully fetched from database")
            return data
        except DatabaseError as query_error:
            db_logger.error({
                "error": str(query_error),
                "context": "query execution",
                "query": query
            })
            raise

# function to return the subindustries from the db
async def subindustry(pool: AsyncConnectionPool, subindustry_id: int | None = None):
    """
    returns the subindustries from the db
    """
    async with get_connection(pool) as conn:  
        try:
            async with conn.cursor(row_factory=dict_row) as cur:
                if subindustry_id is not None:
                    query = """
                    SELECT * FROM subindustries WHERE id = (%s)
                    """
                    await cur.execute(query, (subindustry_id,))
                else:
                    query = """
                    SELECT * FROM subindustries
                    """
                    await cur.execute(query)
                data = await cur.fetchall()
                db_logger.info("Subindustry data successfully fetched from database")
            return data
        except DatabaseError as query_error:
            db_logger.error({
                "error": str(query_error),
                "context": "query execution",
                "query": query
            })
            raise

# function to return the occupation data from the db
async def occupations(pool: AsyncConnectionPool, occupation_id: int | None = None):
    """
    returns the occupations from the db
    """
    async with get_connection(pool) as conn:
        try:
            async with conn.cursor(row_factory=dict_row) as cur:
                if occupation_id is not None:
                    query = """
                    SELECT * FROM occupations WHERE id = (%s)
                    """
                    await cur.execute(query, (occupation_id,))
                else:
                    query = """
                    SELECT * FROM occupations
                    """
                    await cur.execute(query)
                data = await cur.fetchall()
                db_logger.info("Occupation data successfully fetched from database")
            return data
        except DatabaseError as query_error:
            db_logger.error({
                "error": str(query_error),
                "context": "query execution",
                "query": query
            })
            raise

# function to return the location data from the db
async def locations(pool: AsyncConnectionPool, location_id: int | None = None):
    """
    returns the locations from the db
    """
    async with get_connection(pool) as conn:
        try:
            async with conn.cursor(row_factory=dict_row) as cur:
                if location_id is not None:
                    query = """
                    SELECT * FROM locations WHERE id = (%s)
                    """
                    await cur.execute(query, (location_id,))
                else:
                    query = """
                    SELECT * FROM locations
                    """
                    await cur.execute(query)
                data = await cur.fetchall()
                db_logger.info("Location data successfully fetched from database")
            return data
        except DatabaseError as query_error:
            db_logger.error({
                "error": str(query_error),
                "context": "query execution",
                "query": query
            })

# function to return the employer data from the db
async def employers(pool: AsyncConnectionPool, employer_id: int | None = None):
    """
    returns the employers from the db
    """
    async with get_connection(pool) as conn:
        try:
            async with conn.cursor(row_factory=dict_row) as cur:
                if employer_id is not None:
                    query = """
                    SELECT * FROM employers WHERE id = (%s)
                    """
                    await cur.execute(query, (employer_id,))
                else:
                    query = """
                    SELECT * FROM employers
                    """
                    await cur.execute(query)
                data = await cur.fetchall()
                db_logger.info("Employer data successfully fetched from database")
            return data
        except DatabaseError as query_error:
            db_logger.error({
                "error": str(query_error),
                "context": "query execution",
                "query": query
            })

# function to return the job data from the db using views and stored procedures
async def jobs(pool: AsyncConnectionPool, employer: int | str | None = None, industry: int | str |  None = None):
    """
    returns the job data from the jobs view in the db, 
    stored procedure for filtering based on query paramets
    """

    async with get_connection(pool) as conn:
        try:
            async with conn.cursor(row_factory=dict_row) as cur:
                if employer is not None:
                    if str(employer).isdigit():
                        query = """
                        SELECT * FROM jobsView
                        WHERE employer_id = (%s)
                        """ 
                        await cur.execute(query, (employer, ))
                    else:
                        # ILIKE is psql specific making the string case insensitive
                        # pass the ILIKE condition as an argument in the execute method instead of in the query string directly 
                        # or will trigger an error, as it will be interpreted as the ILIKE condition
                        query = """
                        SELECT * FROM jobsView 
                        WHERE firm ILIKE (%s)
                        """
                        await cur.execute(query, (f"%{employer}%", ))
                elif industry is not None:
                    pass
                else:
                    query = """
                    SELECT * FROM jobsView
                    """
                    await cur.execute(query)
                data = await cur.fetchall()
                db_logger.info("Job data successfully fetched from database")
            return data
        except DatabaseError as query_error:
            db_logger.error({
                "error": str(query_error),
                "context": "query execution",
                "query": query
            })

    
