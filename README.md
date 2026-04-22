# REST API for WORC Data of the Cayman Islands Q1-3 2025

## Description
This project takes a dataset of Q1-3 2025 job listings, provided by Workforce Opportunities & Residency Cayman in the Cayman Islands, and ingest it into a postgreSQL database to serve via a fastapi REST API. The API is then demoed in a jupyter notebook which requests data from the API via HTTP and then performs data analysis on it. The structure of the project follows the pyproject template and focuses on a clear separation of concerns and dependency injection through a decoupling of creation and usage of the various components. Logging is implemented throughout the program to provide clear visibility into runtime behavior, facilitating debugging and issue diagnosis.

### Dependencies
- Database & API
    - pyscopg
    - fastapi
- Data Analysis
    - jupyter 
    - pandas 
    - matplotlib
    - scikit-learn
    - requests
    - numpy
    - hashlib
- Other
    - pytest
    - logging


### Table of Contents
- [Database and SQL Layer](#database-and-sql-layer)
- [REST API](#rest-api)
- [Data Analysis](#data-analysis)

### Database and SQL Layer
The WORC dataset is ingested into a local PostgreSQL database, with minor data cleansing performed in python in the helper_modules/clean_data.py module; although, majority of data cleansing performed directly in SQL. Ingestion is handled using transactions and is only committed once integrity checks are passed using procedural statements. The original dataset, which was provided as one table, has been normalized into separate tables to reduce redundancy. A view containing the job data was created to be accessed by the API '/jobs' route. Indices were added to optimize performance, with emphasis on query parameters for the API routes. Exploratory data analysis was also performed at the SQL layer using common table expressions and window functions. All sql is accessible in the 'queries/' subdirectory and database documentation in the DESIGN.md file.

### REST API 
The api is written in python using fastapi and is connected to the database using psycopg. The api is asynchronous using async/await syntax and borrows connections from an asynchronous connection pool. By taking advantage of the asynchronous features of `fastapi` and `pycopg`, performance is improved by releasing server threads during I/O bound operations. The connection pool is a cache of reusable connections which reduces latency by avoiding the startup costs associated with creating new connections.

I have decided to included various routes which expose the different tables in the database, as well as the option to pass query parameters for filtered requests. The main route is the '/jobs' route which exposes the view created at the SQL layer to serve the complete jobs data. Query parameters can be passed using integers or strings using `ILIKE` at the SQL layer.

The routes have been integration tested using `pytest` and the fastapi `TestClient` to verify that data is correctly being served from the database and that errors are correctly caught.

 All API code is accessible in the 'api/' subdirectory

### Data Analysis
Data analysis was performed using the API in a jupyter notebook to demonstrate how an end user might utilize the API. The data is obtained via HTTP using `requests`, transformed using `pandas`, sensitive data is hashed using `hashlib`, modeled using `scikit-learn` and visualizations were made using `matplotlib`. I have included 3 sample visuals examining: the highest paying industries, the distribution of data for the 5 highest paying industries, and the effect education level has on expected salary. All data analysis code is accessible in the 'helper_modules/data_analysis.ipynb' module.

## Conclusion
This project creates a database and REST API using WORC data and then demos data analysis using the API in a jupyter notebook. The original data was ingested into a postgreSQL database and then normalized to reduce redundancy. Indices were included for performance optimization and data integrity was enforced through constraints, procedural statements, and transactions at the ingestion stage. Exploratory analysis was also done at the SQL layer using common table expressions and analytic functions. A view was created with the query parameter fields indexed for serving the fact table data to the main route in the api. 

API connections are handled using a connection pool to allow more conncurrent connections and reduce startup costs of connections. By utilizing asynchronous programming, the API is made more performant and scalable by releasing server threads during I/O bound operations. 

Data analyis is performed again at the python layer to demonstrate how an end user might user the API. The end user could examine the dataset further and examine things such as the highest paying industries, distribution of salaries, the effect education level has on salary, etc.. Data privacy has also been enforced by hashing all sensitive data. 

Separation of conerns, testing, logging, documentation, and the directory structure have been emphasised to adhere to a robust framework for scalability, reprodocability, and maintability. 

Thank you for visiting my project and if you have any feedback please leave a comment on the project's youtube video here: insert link once posted. 
