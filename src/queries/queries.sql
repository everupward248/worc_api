-- insert data from csv into the tables using the staging table
SET client_encoding = 'UTF8';

cat data/job_posting_data.csv | psql -U postgres worc_job -c "\copy staging_table FROM STDIN CSV HEADER"
\copy staging_table FROM 'data/clean_job_data.csv' WITH (FORMAT csv, HEADER true);

COPY staging_table
FROM 'data/clean_job_data.csv'
WITH (FORMAT csv, HEADER true, Encoding 'UTF8');

INSERT INTO "jobs" ("job_post_id", "job_title", "cig_sagc", "employer", "location", "occupation", "sub_industry", "industry")
SELECT "job_post_id", "job_title", "cig_sagc", "employer", "location", "occupation", "sub_industry", "industry"
FROM "staging_table";


DROP TABLE staging_table;