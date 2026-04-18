from fastapi.testclient import TestClient
from app.api.main import app 
import pytest
import asyncio
import sys


# windows specific issue with the psycopg.AsyncConnectionPool
# this checks the operating system and ensures compatibility with psycopg for testing purposes
if sys.platform == "win32":
    asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())

# this is necessary to trigger the lifespan of the app so that the tests can function
@pytest.fixture
def client():
    with TestClient(app) as c:
        yield c

def test_default(client):
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"hello": "world"}

# test the industry path to ensure returning response and qparams correctly
def test_get_all_industries(client):
    response = client.get("/industries")
    assert response.status_code == 200

def test_industries_query(client):
    response = client.get("/industries?industry-id=5")
    assert response.status_code == 200 
    assert response.json() == [{"id":5, "industry":"Financial and Insurance Activities"}] 