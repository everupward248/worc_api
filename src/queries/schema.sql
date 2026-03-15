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