-- staging table to import the csv then insert into other tables
CREATE TABLE IF NOT EXISTS "staging_table" ( 
    "job_post_id" TEXT UNIQUE NOT NULL, 
    "job_title" TEXT NOT NULL,
    "status" TEXT NOT NULL, 
    "created_date" TEXT NOT NULL, 
    "start_date" TEXT NOT NULL, 
    "end_date" TEXT NOT NULL, 
    "cig_sagc" BOOLEAN NOT NULL, 
    "work_type" TEXT NOT NULL,
    "employer" TEXT NOT NULL,
    "required_education_level" TEXT NOT NULL, 
    "years_experience" TEXT NOT NULL, 
    "location" TEXT NOT NULL, 
    "occupation" TEXT NOT NULL, 
    "hours_per_week" DOUBLE PRECISION NOT NULL, 
    "currency" TEXT NOT NULL, 
    "salary_frequency" TEXT NOT NULL, 
    "salary_description" TEXT NOT NULL, 
    "min_salary" DOUBLE PRECISION NOT NULL, 
    "max_salary" DOUBLE PRECISION NOT NULL, 
    "annualized_min_salary" DOUBLE PRECISION NOT NULL, 
    "annualized_max_salary" DOUBLE PRECISION NOT NULL, 
    "mean_annual_salary" DOUBLE PRECISION NOT NULL, 
    "sub_industry" TEXT NOT NULL, 
    "industry" TEXT NOT NULL 
);



CREATE TABLE IF NOT EXISTS "jobs" (
    "id" SERIAL, 
    "job_post_id" TEXT UNIQUE NOT NULL, 
    "job_title" TEXT NOT NULL, 
    "cig_sagc" BOOLEAN NOT NULL, 
    "employer_id" INT NOT NULL,
    "location_id" INT NOT NULL, 
    "occupation_id" INT NOT NULL, 
    "sub_industry_id" INT NOT NULL, 
    "industry_id" INT NOT NULL, 
    "status" TEXT NOT NULL, 
    "created_date" DATE NOT NULL, 
    "start_date" DATE NOT NULL, 
    "end_date" DATE NOT NULL,
    "education_id" INT NOT NULL,
    "work_type_id" INT NOT NULL, 
    "years_experience_id" INT NOT NULL,
    "hours_per_week" DOUBLE PRECISION NOT NULL, 
    "currency" TEXT NOT NULL, 
    "salary_frequency" TEXT NOT NULL, 
    "salary_description" TEXT NOT NULL, 
    "min_salary" DOUBLE PRECISION NOT NULL, 
    "max_salary" DOUBLE PRECISION NOT NULL, 
    "annualized_min_salary" DOUBLE PRECISION NOT NULL, 
    "annualized_max_salary" DOUBLE PRECISION NOT NULL, 
    "mean_annual_salary" DOUBLE PRECISION NOT NULL, 
    PRIMARY KEY("id"), 
    FOREIGN KEY ("employer_id") REFERENCES employers("id"),
    FOREIGN KEY ("location_id") REFERENCES locations("id"),
    FOREIGN KEY ("occupation_id") REFERENCES occupations("id"),
    FOREIGN KEY ("sub_industry_id") REFERENCES subindustries("id"),
    FOREIGN KEY ("industry_id") REFERENCES industries("id"),
    FOREIGN KEY ("education_id") REFERENCES education("id"),
    FOREIGN KEY ("work_type_id") REFERENCES work_type("id"),
    FOREIGN KEY ("years_experience_id") REFERENCES years_experience("id")
);

-- tables for normalization
CREATE TABLE IF NOT EXISTS employers (
    "id" SERIAL PRIMARY KEY,
    "firm" TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS industries (
    "id" SERIAL PRIMARY KEY, 
    "industry" TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS subindustries (
    "id" SERIAL PRIMARY KEY,
    "subindustry" TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS locations (
    "id" SERIAL PRIMARY KEY,
    "location" VARCHAR (120) NOT NULL
);

CREATE TABLE IF NOT EXISTS education (
    "id" SERIAL PRIMARY KEY,
    "education_level" VARCHAR (100) NOT NULL
);

CREATE TABLE IF NOT EXISTS occupations (
    "id" SERIAL PRIMARY KEY,
    "occupation" VARCHAR (150) NOT NULL
);

CREATE TABLE IF NOT EXISTS work_type (
    "id" SERIAL PRIMARY KEY,
    "type" VARCHAR(30) NOT NULL
);

CREATE TABLE IF NOT EXISTS years_experience (
    "id" SERIAL PRIMARY KEY,
    "years" VARCHAR(30) NOT NULL
);

-- jobs view for the jobs route in API
CREATE VIEW jobsView AS 
SELECT 
    j."id", 
    j."job_post_id", 
    j."job_title", 
    j."cig_sagc", 
    j."employer_id",
    e.firm,
    j."location_id", 
    l.location,
    j."occupation_id", 
    o.occupation,
    j."sub_industry_id", 
    si.subindustry,
    j."industry_id", 
    i.industry,
    j."status", 
    j."created_date", 
    j."start_date", 
    j."end_date",
    j."education_id",
    ed.education_level,
    j."work_type_id", 
    wt.type,
    j."years_experience_id",
    ye.years,
    j."hours_per_week", 
    j."currency", 
    j."salary_frequency", 
    j."salary_description", 
    j."min_salary", 
    j."max_salary", 
    j."annualized_min_salary", 
    j."annualized_max_salary", 
    j."mean_annual_salary"
FROM jobs AS j
INNER JOIN employers AS e 
    ON j.employer_id = e.id
INNER JOIN locations AS l 
    ON j.location_id = l.id 
INNER JOIN occupations AS o 
    ON j.occupation_id = o.id 
INNER JOIN subindustries AS si 
    ON j.sub_industry_id = si.id
INNER JOIN industries AS i 
    ON j.industry_id = i.id 
INNER JOIN education AS ed 
    ON j.education_id = ed.id
INNER JOIN work_type AS wt 
    ON j.work_type_id = wt.id 
INNER JOIN years_experience AS ye 
    ON j.years_experience_id = ye.id;

SELECT * FROM jobsView;


