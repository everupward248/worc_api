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
    "employer" TEXT NOT NULL,
    "location" TEXT NOT NULL, 
    "occupation" TEXT NOT NULL, 
    "sub_industry" TEXT NOT NULL, 
    "industry" TEXT NOT NULL, 
    PRIMARY KEY("id")
);

CREATE TABLE IF NOT EXISTS "statuses" (
    "id" SERIAL, 
    "job_post_id" TEXT UNIQUE NOT NULL, 
    "status" TEXT NOT NULL, 
    "created_date" DATE NOT NULL, 
    "start_date" DATE NOT NULL, 
    "end_date" DATE NOT NULL, 
    PRIMARY KEY("id"), 
    FOREIGN KEY("job_post_id") REFERENCES "jobs"("job_post_id")
);


CREATE TABLE IF NOT EXISTS "experiences" (
    "id" SERIAL, 
    "job_post_id" TEXT UNIQUE NOT NULL, 
    "required_education_level" TEXT NOT NULL, 
    "years_experience" TEXT NOT NULL, 
    PRIMARY KEY("id"), 
    FOREIGN KEY("job_post_id") REFERENCES "jobs"("job_post_id")
);

CREATE TABLE IF NOT EXISTS "renumerations" (
    "id" SERIAL, 
    "job_post_id" TEXT UNIQUE NOT NULL, 
    "work_type" TEXT NOT NULL, 
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
    FOREIGN KEY("job_post_id") REFERENCES "jobs"("job_post_id")
);