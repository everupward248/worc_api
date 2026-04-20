from fastapi.testclient import TestClient
from app.api.main import app 
import pytest
import asyncio
import sys


# windows specific issue with the psycopg.AsyncConnectionPool
# this checks the operating system and ensures compatibility with psycopg for testing purposes
if sys.platform == "win32":
    asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())

# fixtures provide a context for tests, such as an evironment e.g. a database: https://docs.pytest.org/en/stable/explanation/fixtures.html
# this is necessary to trigger the lifespan of the app so that the tests can function
@pytest.fixture
def client():
    with TestClient(app) as c:
        yield c

def test_default(client):
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"hello": "world"}

def test_testPath(client):
    response = client.get("/test")
    assert response.status_code == 200
    assert len(response.json()) == 5

# test the industry path to ensure returning response and qparams correctly
def test_get_all_industries(client):
    response = client.get("/industries")
    assert response.status_code == 200
    assert len(response.json()) == 20

def test_industries_query(client):
    response = client.get("/industries?industry-id=5")
    assert response.status_code == 200 
    assert response.json() == [{"id":5, "industry":"Financial and Insurance Activities"}] 
    assert len(response.json()) == 1

def test_invalid_indsutry(client):
    response = client.get("/industries?industry-id=not-a-real-one")
    assert response.status_code in (400,404, 422)

# subindustries
def test_get_all_subindustries(client):
    response = client.get("/subindustries")
    assert response.status_code == 200
    assert len(response.json()) == 50

def test_subindustries_query(client):
    response = client.get("/subindustries?subindustry-id=3")
    assert response.status_code == 200 
    assert response.json() == [{"id":3, "subindustry":"Repair of Consumer Electronics & Household Appliances"}]
    assert len(response.json()) == 1

def test_invalid_subindsutry(client):
    response = client.get("/subindustries?subindustry-id=not-a-real-one")
    assert response.status_code in (400,404, 422)

 # occupations
def test_get_all_occupations(client):
    response = client.get("/occupations")
    assert response.status_code == 200
    assert len(response.json()) == 380

def test_occupations_query(client):
    response = client.get("/occupations?occupation-id=93")
    assert response.status_code == 200 
    assert response.json() == [{"id":93, "occupation":"Computer network professionals"}]
    assert len(response.json()) == 1

def test_invalid_occupation(client):
    response = client.get("/occupations?occupation-id=not-a-real-one")
    assert response.status_code in (400,404, 422)

# locations
def test_get_all_locations(client):
    response = client.get("/locations")
    assert response.status_code == 200
    assert len(response.json()) == 14

def test_locations_query(client):
    response = client.get("/locations?location-id=11")
    assert response.status_code == 200 
    assert response.json() == [{"id":11, "location":"Seven Mile Beach"}]
    assert len(response.json()) == 1

def test_invalid_location(client):
    response = client.get("/locations?location-id=not-a-real-one")
    assert response.status_code in (400,404, 422)

# employers
def test_get_all_employers(client):
    response = client.get("/employers")
    assert response.status_code == 200 
    assert len(response.json()) == 3063

def test_employers_query(client):
    response = client.get("/employers?employer-id=91")
    assert response.status_code == 200
    assert response.json() == [{"id":91, "firm":"Cayman Rugby Football Club"}]
    assert len(response.json()) == 1

def test_invalid_employer(client):
    response = client.get("/employers?employer-id=not-a-real-one")
    assert response.status_code in (400,404, 422)

# jobs
def test_get_all_jobs(client):
    response = client.get("/jobs")
    assert response.status_code == 200 
    assert len(response.json()) == 14036

def test_jobs_int_industry_query(client):
    response = client.get("/jobs?industry=13")
    data = response.json()
    assert response.status_code == 200 
    assert {job["industry_id"] for job in data} == {13} 

def test_jobs_str_industry_query(client):
    response = client.get("/jobs?industry=Mining and Quarrying")
    data = response.json()
    assert response.status_code == 200 
    assert {job["industry"] for job in data} == {"Mining and Quarrying"} 

def test_jobs_int_employer_query(client):
    response = client.get("/jobs?employer=91")
    data = response.json()
    assert response.status_code == 200 
    assert {job["employer_id"] for job in data} == {91} 

def test_jobs_str_employer_query(client):
    response = client.get("/jobs?employer=Cayman Rugby Football Club")
    data = response.json()
    assert response.status_code == 200 
    assert {job["firm"] for job in data} == {"Cayman Rugby Football Club"} 



