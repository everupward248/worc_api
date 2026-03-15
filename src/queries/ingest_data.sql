/* ingest data into the jobs table from the staging table
   normalize the data and create relevant tables to link to the jobs table e.g. employer

   1. create employers table
   2. create industry table 
   3. create subindustry table
   4. create location table
   5. create education table
   6. create occupation table
   7. create work type table

*/

-- normalize employer data
BEGIN TRANSACTION;

WITH employer_stage AS (
    SELECT DISTINCT(employer)
    FROM staging_table
)
INSERT INTO employers (firm)
SELECT employer 
FROM employer_stage;

DO $$
BEGIN
IF (SELECT COUNT(*) FROM employers) = 
(SELECT COUNT(DISTINCT(employer)) FROM staging_table) 
THEN 
    RETURN;
ELSE 
    RAISE EXCEPTION 'Data not successfuly ingested into the employers table';
END IF;
END
$$;

COMMIT;

-- normalize industry table
BEGIN TRANSACTION;

WITH industry_stage AS (
    SELECT DISTINCT(industry)
    FROM staging_table
)
INSERT INTO industries (industry) (
    SELECT industry 
    FROM industry_stage
);

DO $$ 
BEGIN
IF (SELECT COUNT(*) FROM industries) = 
(SELECT (COUNT(DISTINCT(industry))) FROM staging_table)
THEN 
    RETURN;
ELSE
    RAISE EXCEPTION 'Data not successfully ingested into the indsutries table';
END IF;
END
$$;

COMMIT;

-- normalize subindustry table
BEGIN TRANSACTION;

WITH subindustry_stage AS (
    SELECT DISTINCT(sub_industry) 
    FROM staging_table
)

INSERT INTO subindustries(subindustry) ( 
SELECT sub_industry 
FROM subindustry_stage
);

DO $$
BEGIN 
IF (SELECT COUNT(*) FROM subindustries) = 
(SELECT COUNT(DISTINCT(sub_industry)) FROM staging_table)
THEN 
    RETURN;
ELSE 
    RAISE EXCEPTION 'Data unsuccessfully ingested into the subindustries table';
END IF;
END 
$$;

COMMIT;

-- normalize location table
BEGIN TRANSACTION;

WITH location_stage AS (
    SELECT DISTINCT(location)
    FROM staging_table
)

INSERT INTO locations(location) (
    SELECT location
    FROM location_stage
);

DO $$
BEGIN 
IF (SELECT COUNT(*) FROM locations) = 
(SELECT COUNT(DISTINCT(location)) FROM staging_table)
THEN 
    RETURN;
ELSE
    RAISE EXCEPTION 'Data unseccfully ingested into the locations table';
END IF;
END 
$$;

COMMIT;

-- normalize education table
BEGIN TRANSACTION;

WITH education_stage AS (
    SELECT DISTINCT(required_education_level) AS el
    FROM staging_table
)

INSERT INTO education (education_level) (
    SELECT el 
    FROM education_stage
);

DO $$
BEGIN 
IF (SELECT COUNT(*) FROM education) = 
(SELECT COUNT(DISTINCT(required_education_level)) FROM staging_table)
THEN 
    RETURN;
ELSE
    RAISE EXCEPTION 'Data unsuccessfully ingested into the education table';
END IF;
END 
$$;

COMMIT;

-- normalize occupation table 
BEGIN TRANSACTION;

WITH occupation_stage AS (
    SELECT DISTINCT(occupation)
    FROM staging_table
)

INSERT INTO occupations (occupation) (
    SELECT occupation
    FROM occupation_stage
);

DO $$
BEGIN
IF (SELECT COUNT(*) FROM occupations) = 
(SELECT COUNT(DISTINCT(occupation)) FROM staging_table)
THEN 
    RETURN;
ELSE 
    RAISE EXCEPTION 'Data unsuccessfully ingested into the occupation table';
END IF;
END 
$$;

COMMIT;

BEGIN TRANSACTION;

WITH work_type_staging AS 
(SELECT DISTINCT(work_type)
FROM staging_table)

INSERT INTO work_type (type) (
    SELECT work_type 
    FROM work_type_staging
);

DO $$
BEGIN 
IF (SELECT COUNT(*) FROM work_type) = 
(SELECT COUNT(DISTINCT(work_type)) FROM staging_table)
THEN 
    RETURN;
ELSE 
    RAISE EXCEPTION 'Data unsuccessfully ingested into the work_type table';
END IF;
END 
$$;

COMMIT;



INSERT INTO jobs 
("job_post_id", "job_title", "cig_sagc", "employer", "location", "occupation", "sub_industry", "industry")
FROM staging_table;