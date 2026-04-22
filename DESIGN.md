# WORC Job Listings Database

## Overview
This database is used to store job listing data posted by WORC to be served by a REST API. The design is centered around the `jobs` fact table which is the central entity, with the other tables being dimensions of this fact table. A view has been created to serve the jobs data via the API and to isolate the API request from the SQL logic. The data was originally provided in one big table, so redundancy was reduced by normalizing the data to 3NF: each field contains unique and atomic values. all non-key attributes are dependent on the primary key, the dimensions have been moved into their own tables and the fact table only stores the foreign keys. 


## Entity Relationship Diagram
Each row in the jobs table relates to one job posting. The dimension tables are the contextual attributes of that job posting. The relationship between the `jobs` table and the dimensions(e.g. `employers`, `locations`, `industries`) is one-to-many, as a dimension can relate to many job postings whereas each job posting relates to exactly one entry in the dimension tables. 

![WORC Database Entity Relationship Diagram](/src/app/queries/worc_db_erd.jpeg) 

## Indexing 
Indices have been created in the database to optimize query performance. The data is served through the `/jobs` route in the API via `jobsView` which performs all the `JOIN` operations. As this involves 8 joins, indices have been placed on all foreign keys to reduce join complexity.

Specific indices were created to cover the query filter parameters of the `/jobs` route

- `idx_jobs_qparam_employer`
- `idx_jobs_qparam_industry`

## API Data View (`jobsView`)
The REST API does not query the tables directly. Instead, it interacts with this view which abstracts the api logic from the underlying schema. 

<details>
<summary>Click to view SQL definition</summary>

```sql
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
```
</details>

## Potential Improvements
Currently the `industries` and `subindustries` tables have no relations. Although 3NF is currently satisfied, there is a risk where a subindustry might not logically belong to an industry. A junction table could be added to the database which would map the relations between these tables. This would add the benefit of allowing a single subindustry to be mapped to multiple industries. 

## Conclusion
This database provides a 3NF compliant foundation for the WORC job listings to be served via a REST API. By decoupling the API logic and the database schema via `jobsView` and optimizing queries with targeted indices, the database ensures data integrity and high performance. 