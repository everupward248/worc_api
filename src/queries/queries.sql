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
SELECT column_name FROM information_schema.columns WHERE table_name = 'staging_table';

DROP TABLE staging_table;

-- exploratory queries
SELECT i.industry, ROUND(AVG(mean_annual_salary)::NUMERIC, 2) AS average_salary
FROM jobs 
INNER JOIN industries AS i 
    ON jobs.industry_id = i.id
GROUP BY i.industry
ORDER BY average_salary DESC; -- highest average pay by industry is Financial and Insurance activities with an average of $92,707.86

SELECT job_title, mean_annual_salary
FROM jobs
ORDER BY mean_annual_salary DESC 
LIMIT 10; -- the data for the number 1 position is skewed due to a calculation for the mason helper salary, the range for hourly rate is 12-504, to update value to lower range as unrealistic to receive 504 for every hour of work