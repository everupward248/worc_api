-- insert data from csv into the tables using the staging table
SET client_encoding = 'UTF8';

cat data/job_posting_data.csv | psql -U postgres worc_job -c "\copy staging_table FROM STDIN CSV HEADER"
\copy staging_table FROM 'data/clean_job_data.csv' WITH (FORMAT csv, HEADER true);

COPY staging_table
FROM 'data/clean_job_data.csv'
WITH (FORMAT csv, HEADER true, Encoding 'UTF8');

-- Check count of cols and rows 
SELECT COUNT(*) FROM staging_table; -- should be 14,036
SELECT COUNT(*) FROM information_schema.columns WHERE table_name = 'staging_table'; -- should be 24




DROP TABLE staging_table;