from fastapi import FastAPI, HTTPException, Depends, Request
from contextlib import asynccontextmanager
from src.helper_modules.logger_setup import get_logger
from src.db import db
from dotenv import load_dotenv
from .route_logic import test_logic

# load environment variables from .env file, this loads globally so accessible across all modules, hence no error in the db factory function
# configuration should be initialize at entry point, not inside libraries/modules
load_dotenv()

# initialize the logger
api_logger = get_logger(__name__)

# lifespan is a context function which performs startup and shutdown tasks
@asynccontextmanager 
async def lifespan(app: FastAPI):
     # create instance of the connection pool 
     pool = db.create_pool()
     # load the connection pool 
     await pool.open()
     app.state.pool = pool 
     yield
     await pool.close()

app = FastAPI(lifespan=lifespan)

def get_pool(request: Request):
     return request.app.state.pool

@app.get("/")
async def test_path():
     return {"hello": "world"}

# testing the async calls to db
@app.get("/test")
async def async_test(pool = Depends(get_pool)):
     try:
          return await test_logic(pool)
     except HTTPException as e:
          api_logger.error(e)
          raise HTTPException(status_code=500, detail="Internal server error")
     
# industry data resource




# TODO: create enpoints for:
## jobs - all data 
## employers
## industry
## subindustries
## locations
## post/ delete new entries


if __name__ == "__main__":
     print(api_logger)