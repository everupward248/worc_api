from fastapi import FastAPI, HTTPException, Depends, Request, Query
from contextlib import asynccontextmanager
from app.helper_modules.logger_setup import get_logger
from app.db import db
from dotenv import load_dotenv
import app.api.route_logic as rl
from psycopg_pool import AsyncConnectionPool
from typing import Annotated
from psycopg import DatabaseError
import uvicorn

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
          api_logger.info("test route has been called")
          return await rl.test_logic(conn_pool)
     except HTTPException as e:
          api_logger.error(e)
          raise HTTPException(status_code=500, detail="Internal server error")
     
# industry route
@app.get("/industries")
# fast api recognizes function parameters as query parameters
async def industries(conn_pool: ConnPool, industry_id: Annotated[int | None, Query(alias="industry-id")] = None):
     try:
          if industry_id is not None:
               api_logger.info(f"Industry route has been called for industry_id:{industry_id}")
               return await rl.industry(conn_pool, industry_id)
          api_logger.info("Industry route has been called")
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
async def subindustries(conn_pool: ConnPool, subindustry_id: Annotated[int | None, Query(alias="subindustry-id")] = None):
     try:
          if subindustry_id is not None:
               api_logger.info(f"Subindustry route has been called for subindustry_id:{subindustry_id}")
               return await rl.subindustry(conn_pool, subindustry_id)
          api_logger.info("Subindustry route has been called")
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
async def occupations(conn_pool: ConnPool, occupation_id: Annotated[int | None, Query(alias="occupation-id")] = None):
     try:
          if occupation_id is not None:
               api_logger.info(f"Occupations route has been called for industry_id:{occupation_id}")
               return await rl.occupations(conn_pool, occupation_id)
          api_logger.info("Occupations route has been called")
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
     
# locations route
@app.get("/locations")
async def locations(conn_pool: ConnPool, location_id: Annotated[int | None, Query(alias="location-id")] = None):
     try:
          if location_id is not None:
               api_logger.info(f"Locations route has been called for location_id:{location_id}")
               return await rl.locations(conn_pool, location_id)
          api_logger.info("Locations route has been called")
          return await rl.locations(conn_pool)
     except HTTPException as e:
          api_logger.info(e)
          raise
     except DatabaseError as e:
          api_logger.error(e)
          raise HTTPException(status_code=500, detail="Database error")
     except Exception as e:
          api_logger.exception("Unexpected error")
          raise HTTPException(status_code=500, detail="Internal server error")

# employers
@app.get("/employers")
async def employers(conn_pool: ConnPool, employer_id: Annotated[int | None, Query(alias="employer-id")] = None):
     try:
          if employer_id is not None:
               api_logger.info(f"Employers route has been called for employer_id:{employer_id}")
               return await rl.employers(conn_pool, employer_id)
          api_logger.info("Employers route has been called")
          return await rl.employers(conn_pool)
     except HTTPException as e:
          api_logger.info(e)
          raise
     except DatabaseError as e:
          api_logger.error(e)
          raise HTTPException(status_code=500, detail="Database error")
     except Exception as e:
          api_logger.exception("Unexpected error")
          raise HTTPException(status_code=500, detail="Internal server error")

# jobs
@app.get("/jobs")
async def jobs(conn_pool: ConnPool, employer: Annotated[int | str | None, Query(alias="employer")] = None, industry: Annotated[int | str | None, Query(alias="industry")] = None):
     """
     returns the jobs data from the db using the jobsView 
     query parameters can be provided as id integers or as strings
     """
     try:
          # must pass the argument as a keyword otherwise it will be interpreted positionally 
          # e.g. ?industry=n is interpreted as employer=n 
          if employer is not None:
               api_logger.info(f"Jobs route has been called with employer query parameter: {employer}")
               return await rl.jobs(conn_pool, employer=employer)
          elif industry is not None:
               api_logger.info(f"Jobs route has been called with industry query parameter: {industry}")
               return await rl.jobs(conn_pool, industry=industry) 
          else:
               api_logger.info(f"Jobs route has been called")
               return await rl.jobs(conn_pool)
     except HTTPException as e:
          api_logger.info(e)
          raise
     except DatabaseError as e:
          api_logger.error(e)
          raise HTTPException(status_code=500, detail="Database error")
     except Exception as e:
          api_logger.exception("Unexpected error")
          raise HTTPException(status_code=500, detail="Internal server error")

if __name__ == "__main__":
     print(api_logger)