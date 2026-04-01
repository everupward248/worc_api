from fastapi import FastAPI, HTTPException, Depends, Request
from contextlib import asynccontextmanager
from src.helper_modules.logger_setup import get_logger
from src.db import db
from dotenv import load_dotenv
import src.api.route_logic as rl
from psycopg_pool import AsyncConnectionPool
from typing import Annotated
from psycopg import DatabaseError

# load environment variables from .env file, this loads globally so accessible across all modules, hence no error in the db factory function
# configuration should be initialized at entry point, not inside libraries/modules
load_dotenv()

# initialize the logger
api_logger = get_logger(__name__)

# lifespan is a context function which performs startup and shutdown tasks
@asynccontextmanager 
async def lifespan(app: FastAPI):
     # create instance of the connection pool once at startup
     pool = db.create_pool()
     # load the connection pool 
     await pool.open()
     # creates a globally shared object from the pool created at startup so that it can be shared across requests during runtime
     app.state.pool = pool 
     yield
     await pool.close()

app = FastAPI(lifespan=lifespan)

# this function is used to pass the connection pool as a dependency in the routes of the API
def get_pool(request: Request) -> AsyncConnectionPool:
     return request.app.state.pool

# using Annotated, create a variable for the dependency to pass the pool connections to the routes
ConnPool = Annotated[AsyncConnectionPool, Depends(get_pool)]

@app.get("/")
async def test_path():
     return {"hello": "world"}

# testing the async calls to db
@app.get("/test")
async def async_test(conn_pool: ConnPool):
     try:
          return await rl.test_logic(conn_pool)
     except HTTPException as e:
          api_logger.error(e)
          raise HTTPException(status_code=500, detail="Internal server error")
     
# industry route
@app.get("/industries")
# fast api recognizes function parameters as query parameters
async def industries(conn_pool: ConnPool, industry_id: int | None = None):
     try:
          if industry_id is not None:
               return await rl.industry(conn_pool, industry_id)
          return await rl.industry(conn_pool)
     except HTTPException as e:
          api_logger.info(e)
          raise
     except DatabaseError as e:
          api_logger.error(e)
          raise HTTPException(status_code=500, detail="Database error")
     except Exception as e:
          api_logger.exception("Unexpected error")
          raise HTTPException(status_code=500, detail="Internal server error")

     
# subindustry route
@app.get("/subindustries")
async def subindustries(conn_pool: ConnPool, subindustry_id: int | None = None):
     try:
          if subindustry_id is not None:
               return await rl.subindustry(conn_pool, subindustry_id)
          return await rl.subindustry(conn_pool)
     except HTTPException as e:
          api_logger.info(e)
          raise
     except DatabaseError as e:
          api_logger.error(e)
          raise HTTPException(status_code=500, detail="Database error")
     except Exception as e:
          api_logger.exception("Unexpected error")
          raise HTTPException(status_code=500, detail="Internal server error")

# occupations route
@app.get("/occupations")
async def occupations(conn_pool: ConnPool, occupation_id: int | None = None):
     try:
          if occupation_id is not None:
               return await rl.occupations(conn_pool, occupation_id)
          return await rl.occupations(conn_pool)
     except HTTPException as e:
          api_logger.info(e)
          raise
     except DatabaseError as e:
          api_logger.error(e)
          raise HTTPException(status_code=500, detail="Database error")
     except Exception as e:
          api_logger.exception("Unexpected error")
          raise HTTPException(status_code=500, detail="Internal server error")


# TODO: create enpoints for:
## jobs - all data 
## employers
## locations
## post/ delete new entries


if __name__ == "__main__":
     print(api_logger)