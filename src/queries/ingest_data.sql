/* ingest data into the jobs table from the staging table
   normalize the data and create relevant tables to link to the jobs table e.g. employer

   1. create employers table
   2. create industry table 
   3. create subindustry table
   4. create location table
   5. create education table
   6. create occupation table
   7. create work type table
   8. create years experience table

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

-- the years experience table is held as strings, values are currently repeated as case sensitive
UPDATE staging_table
SET years_experience = INITCAP(years_experience);

BEGIN TRANSACTION;

WITH years_stage AS (
    SELECT DISTINCT(years_experience)
    FROM staging_table
)
INSERT INTO years_experience (years) (
    SELECT years_experience 
    FROM years_stage
);

DO $$ 
BEGIN 
IF (SELECT COUNT(*) FROM years_experience) = 
(SELECT COUNT(DISTINCT(years_experience)) FROM staging_table)
THEN 
    RETURN;
ELSE
    RAISE EXCEPTION 'Data unsuccessully ingested into the years_experience table';
END IF;
END 
$$;

COMMIT;


-- ingest data into the jobs table
BEGIN TRANSACTION;

INSERT INTO jobs 
("job_post_id", 
    "job_title", 
    "cig_sagc", 
    "employer_id",
    "location_id", 
    "occupation_id", 
    "sub_industry_id", 
    "industry_id", 
    "status", 
    "created_date", 
    "start_date", 
    "end_date",
    "education_id",
    "work_type_id", 
    "years_experience_id",
    "hours_per_week", 
    "currency", 
    "salary_frequency", 
    "salary_description", 
    "min_salary", 
    "max_salary", 
    "annualized_min_salary", 
    "annualized_max_salary", 
    "mean_annual_salary" 
)
(
    SELECT 
        s."job_post_id", 
        s."job_title", 
        s."cig_sagc", 
        e."id",
        l."id", 
        o."id", 
        si."id", 
        i."id", 
        s."status", 
        TO_DATE(s."created_date", 'DD-Mon-YY'), 
        TO_DATE(s."start_date", 'DD-Mon-YY'), 
        TO_DATE(s."end_date", 'DD-Mon-YY'),
        ed."id",
        wt."id", 
        ye."id",
        s."hours_per_week", 
        s."currency", 
        s."salary_frequency", 
        s."salary_description", 
        s."min_salary", 
        s."max_salary", 
        s."annualized_min_salary", 
        s."annualized_max_salary", 
        s."mean_annual_salary" 
        FROM staging_table AS s 
        INNER JOIN employers AS e 
            ON e.firm = s.employer
        INNER JOIN locations AS l 
            ON l.location = s.location
        INNER JOIN occupations AS o 
            ON o.occupation = s.occupation
        INNER JOIN subindustries AS si 
            ON si.subindustry = s.sub_industry 
        INNER JOIN industries AS i 
            ON i.industry = s.industry 
        INNER JOIN education AS ed 
            ON ed.education_level = s.required_education_level 
        INNER JOIN work_type AS wt 
            ON wt.type = s.work_type 
        INNER JOIN years_experience AS ye 
            ON ye.years = s.years_experience
);

DO $$
BEGIN 
IF (SELECT COUNT(*) FROM jobs) = 
(SELECT COUNT(*) FROM staging_table)
THEN 
    RETURN;
ELSE 
    RAISE EXCEPTION 'Data unsuccessfully ingested into the jobs table';
END IF;
END 
$$;

COMMIT;


-- not all rows being ingested, diagnose issue 
SELECT s.job_post_id, 
    CASE WHEN s.employer IS NULL THEN 'Missing employer' END AS employer_issue,
    CASE WHEN l.id IS NULL THEN 'Missing locations' END AS location_issue, 
    CASE WHEN o.id IS NULL THEN 'Missing occupation' END AS occupation_issue,
    CASE WHEN si.id IS NULL THEN 'Missing subindustry' END AS subindustry_issue,
    CASE WHEN i.id IS NULL THEN 'Misssing industry' END AS industry_issue,
    CASE WHEN ed.id IS NULL THEN 'Missing education' END AS education_issue, 
    CASE WHEN wt.id IS NULL THEN 'Missing work type' END AS work_type_issue,
    CASE WHEN ye.id IS NULL THEN 'Missing years experience' END AS experience_issue
FROM staging_table AS s
LEFT JOIN employers AS e 
    ON e.firm = s.employer
LEFT JOIN locations AS l 
    ON l.location = s.location
LEFT JOIN occupations AS o 
    ON o.occupation = s.occupation 
LEFT JOIN subindustries AS si 
    ON si.subindustry = s.sub_industry 
LEFT JOIN industries AS i 
    ON i.industry = s.industry 
LEFT JOIN education AS ed 
    ON ed.education_level = s.required_education_level 
LEFT JOIN work_type AS wt 
    ON wt.type = s.work_type 
LEFT JOIN years_experience AS ye 
    ON ye.years = s.years_experience
WHERE 
    e.id IS NULL 
    OR l.id IS NULL
    OR o.id IS NULL
    OR si.id IS NULL 
    OR i.id IS NULL
    OR ed.id IS NULL
    OR wt.id IS NULL
    OR ye.id IS NULL; 

-- due to the update to the education level, update staging table to match 
UPDATE staging_table 
SET required_education_level = (SELECT education_level FROM education WHERE id = 3)
WHERE required_education_level LIKE 'Bach%';

UPDATE staging_table 
SET required_education_level = (SELECT education_level FROM education WHERE id = 4)
WHERE required_education_level LIKE 'Mast%';

