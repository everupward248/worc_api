from fastapi import FastAPI, HTTPException
from contextlib import asynccontextmanager
from psycopg import DatabaseError
from psycopg.rows import dict_row
from src.helper_modules.logger_setup import get_logger
from src.db import db



# initialize the logger
api_logger = get_logger(__name__)

# lifespan is a context function which performs startup and shutdown tasks
@asynccontextmanager 
async def lifespan(app: FastAPI):
     # load the connection pool 
     await db.pool.open()
     yield
     await db.pool.close()

app = FastAPI(lifespan=lifespan)

@app.get("/")
async def test_path():
     return {"hello": "world"}

# testing the async calls to db
@app.get("/test")
async def async_test():
     try:
          async with db.pool.connection() as conn:
               # dict row converts the response from the database into python dictionary at the driver level to avoid manual conversion
               async with conn.cursor(row_factory=dict_row) as cur:
                    await cur.execute("""
                                        SELECT * FROM jobs LIMIT 5
                                   """)
                    data = await cur.fetchall()
          if api_logger:
               api_logger.info(data)
          return data
     except DatabaseError as e:
          if api_logger:
               api_logger.warning(f"Database error: {e}")
          raise HTTPException(status_code=500, detail="Database error")
     
# industry data resource
@app.get("/industries/{id}")
async def industry_path(id: int | None = None):
     try:
          async with db.pool.connection() as conn:
               async with conn.cursor(row_factory=dict_row) as cur:
                    await cur.execute("""
                                        SELECT * FROM industries
                                      """)
                    data = await cur.fetchall()
          if api_logger:
               api_logger.info(data)
     except DatabaseError as e:
          if api_logger:
               api_logger.warning(f"Database error: {e}")
          raise HTTPException(status_code=500, detail="Database error")




# TODO: create enpoints for:
## jobs - all data 
## employers
## industry
## subindustries
## locations
## post/ delete new entries


if __name__ == "__main__":
     print(api_logger)