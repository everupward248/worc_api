-- ensure all join keys in the jobs table are indexed
CREATE INDEX ON jobs (location_id);
CREATE INDEX ON jobs (occupation_id);
CREATE INDEX ON jobs (sub_industry_id);
CREATE INDEX ON jobs (education_id);
CREATE INDEX ON jobs (work_type_id);
CREATE INDEX ON jobs (years_experience_id);

-- indices for the query parameters of the '/jobs' route
CREATE INDEX idx_jobs_qparam_employer ON jobs (employer_id);
CREATE INDEX idx_jobs_qparam_industry ON jobs (industry_id);

-- verify index running correctly
EXPLAIN ANALYZE 
SELECT * FROM jobsView
WHERE employer_id = 359;

EXPLAIN ANALYZE 
SELECT * FROM jobsView 
WHERE industry_id = 7;
