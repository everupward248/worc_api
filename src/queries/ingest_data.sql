/* ingest data into the jobs table from the staging table
   normalize the data and create relevant tables to link to the jobs table e.g. employer

   1. create employers table
   2. create industry table 
   3. create subindustry table

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



INSERT INTO jobs 
("job_post_id", "job_title", "cig_sagc", "employer", "location", "occupation", "sub_industry", "industry")
FROM staging_table;