/* 
    exploratory queries

    The highest paying industries are {1 : [Financial and Insurance Activities, 93k], 2 : [Professional, Scientific and Technical Activities, 80k], 3 : [Public Administration and Defence; Compulsory Social Security, 80k]}
*/

-- average pay rankings by industry
SELECT i.industry, ROUND(AVG(mean_annual_salary)::NUMERIC, 2) AS average_salary, 
RANK () OVER(ORDER BY ROUND(AVG(mean_annual_salary)::NUMERIC, 2) DESC) AS industry_rank
FROM jobs 
INNER JOIN industries AS i 
    ON jobs.industry_id = i.id
GROUP BY i.industry
ORDER BY average_salary DESC; -- highest average pay by industry is Financial and Insurance activities with an average of $92,707.86

-- highest paying subindustries for the highest paying industries
-- rank the highest paying industires
WITH highest_paying_industries AS (
    SELECT j.industry_id, ROUND(AVG(j.mean_annual_salary)::NUMERIC, 2) AS average_salary, 
        RANK () OVER(ORDER BY ROUND(AVG(mean_annual_salary)::NUMERIC, 2) DESC) AS industry_rank
    FROM jobs AS j 
    GROUP BY j.industry_id 
    ORDER BY average_salary DESC
), 
-- filter out the tope five industries
top_five AS (
    SELECT industry_id, average_salary, industry_rank FROM highest_paying_industries WHERE industry_rank <= 5
), 

-- filter out all jobs for indsutry and subindustry
industries_subindustries AS (
    SELECT 
        i.industry, 
        tf.industry_rank,
        si.subindustry, 
        tf.average_salary AS industry_average, 
        j.job_title,
        j.mean_annual_salary
    FROM jobs AS j 
    INNER JOIN top_five AS tf 
        ON j.industry_id = tf.industry_id
    INNER JOIN industries AS i 
        ON tf.industry_id = i.id
    INNER JOIN subindustries AS si 
        ON j.sub_industry_id = si.id 
    WHERE j.industry_id IN (
        SELECT industry_id FROM top_five
))

-- TODO: finish the subindustry salary ranking to determine the highest paying subindustries
SELECT industry, industry_rank, subindustry,
    ROUND(AVG(mean_annual_salary)::NUMERIC, 2) AS subindustry_average,
    RANK() OVER(PARTITION BY industry ORDER BY ROUND(AVG(mean_annual_salary)::NUMERIC, 2) DESC) AS subindustry_rank, 
    mean_annual_salary, 
    job_title
FROM industries_subindustries
GROUP BY subindustry, industry
ORDER BY industry_rank, mean_annual_salary DESC;


-- 10 highest paying jobs per the dataset
SELECT job_title, mean_annual_salary, id,
    RANK () OVER(ORDER BY mean_annual_salary DESC) AS salary_rank
FROM jobs
ORDER BY mean_annual_salary DESC 
LIMIT 10; -- the data for the number 1 position is skewed due to a calculation for the mason helper salary, the range for hourly rate is 12-504, to update value to lower range as unrealistic to receive 504 for every hour of work

BEGIN TRANSACTION;

UPDATE jobs 
SET mean_annual_salary = (
    SELECT ROUND(AVG(annualized_min_salary)::NUMERIC, 0) FROM jobs WHERE job_title = 'Mason Helper' AND id != 9071
    )
WHERE id = 9071; -- update the mean annual salary for the mason helper to the average for the job title

DO $$ 
BEGIN 

IF (SELECT mean_annual_salary FROM jobs WHERE id = 9071) =  
   (SELECT ROUND(AVG(annualized_min_salary)::NUMERIC, 0) FROM jobs WHERE job_title = 'Mason Helper' AND id != 9071)
THEN   
    RETURN;
ELSE 
    RAISE EXCEPTION 'Salary for mason helper 9071 has not been updated to the average salary for mason helpers';
END IF;
END
$$;

COMMIT;

-- select the top 5 jobs per industry
WITH ranked_jobs AS (
    SELECT 
        j.job_title, 
        i.industry, 
        j.mean_annual_salary, 
        j.id, 
        RANK () OVER(
            PARTITION BY i.industry 
            ORDER BY j.mean_annual_salary DESC
        ) AS salary_rank
    FROM jobs AS j 
    INNER JOIN industries AS i 
        ON j.industry_id = i.id
) -- this CTE provides the salary rankings for each industry

SELECT * 
FROM ranked_jobs
WHERE salary_rank <= 5
ORDER BY industry, salary_rank; -- filters out the top five jobs per industry 

-- now explore the working hours
WITH ranked_jobs AS (
    SELECT 
        j.job_title, 
        i.industry, 
        j.mean_annual_salary, 
        j.hours_per_week,
        j.id, 
        RANK () OVER(
            PARTITION BY i.industry 
            ORDER BY j.mean_annual_salary DESC
        ) AS salary_rank
    FROM jobs AS j 
    INNER JOIN industries AS i 
        ON j.industry_id = i.id
),  -- this CTE provides the salary rankings for each industry

average_hours_tops_jobs AS (                   -- obtain the average working hours of the top 5 jobs per industry 
    SELECT ROUND(AVG(hours_per_week)::NUMERIC, 2) AS average_weekly_hours_top_jobs, industry
    FROM ranked_jobs
    WHERE salary_rank <= 5
    GROUP BY industry
    ORDER BY average_weekly_hours_top_jobs DESC, industry
),  

industry_average_hours AS (-- compare to the indsutry average
    SELECT ROUND(AVG(j.hours_per_week)::NUMERIC, 2) AS average_weekly_hours, i.industry
    FROM jobs AS j 
    INNER JOIN industries AS i 
        ON j.industry_id = i.id
    GROUP BY i.industry
    ORDER BY average_weekly_hours DESC, industry
)

SELECT tj.average_weekly_hours_top_jobs, ia.average_weekly_hours, (tj.average_weekly_hours_top_jobs - ia.average_weekly_hours) AS difference_hours_worked, tj.industry
FROM average_hours_tops_jobs AS tj
INNER JOIN industry_average_hours AS ia 
    ON tj.industry = ia.industry;

/* 
    the top 5 jobs in the financial services have a lower weekly work rate of 2 hours compared to the indsutry average
    the biggest discrepancy between hours worked by industry is in education, the top 5 jobs in the industry work an average of 4 more hours than the industry average
*/

/* 
    education is ranked 7/20 by industry in regards to annual salary
    the top 7 empoyers in the industry all pay > 60k annually
    the top employer pays 80k annually on average 

*/
SELECT ROUND(AVG(j.mean_annual_salary)::NUMERIC, 2) AS average_salary, e.firm, i.industry, 
    RANK() OVER(ORDER BY ROUND(AVG(j.mean_annual_salary)::NUMERIC, 2) DESC) AS school_rank
FROM jobs AS j 
INNER JOIN industries AS i 
    ON j.industry_id = i.id
INNER JOIN employers AS e 
    ON j.employer_id = e.id
WHERE i.industry = 'Education'
GROUP BY e.firm, i.industry
ORDER BY average_salary DESC; 

/* 
    to investigate the public sector 
    top 3 employers in public: utility regulation and competition office, cayman islands stock exchange, cayman islands monetary authority (all > 100k annually on average)
    on average, the public finance sector compensates more than private, public - 97k vs private - 92k
*/

SELECT * FROM industries; -- id 14

SELECT j.job_title, j.mean_annual_salary, j.cig_sagc, i.industry, e.firm
FROM jobs AS j 
INNER JOIN industries AS i 
    ON j.industry_id = i.id
INNER JOIN employers AS e 
    ON j.employer_id = e.id
WHERE j.cig_sagc IS TRUE
ORDER BY e.firm, j.mean_annual_salary DESC;

SELECT ROUND(AVG(j.mean_annual_salary)) AS average_salary, i.industry, e.firm, -- top 3 employers in public: utility regulation and competition office, cayman islands stock exchange, cayman islands monetary authority (all > 100k annually on average)
    RANK() OVER(ORDER BY ROUND(AVG(j.mean_annual_salary)) DESC) AS salary_rank
FROM jobs AS j 
INNER JOIN industries AS i 
    ON j.industry_id = i.id 
INNER JOIN employers AS e 
    ON j.employer_id = e.id
WHERE j.cig_sagc IS TRUE
GROUP BY e.firm, i.industry
ORDER BY salary_rank;

-- compare public and private finance industry
WITH public_finance AS (
    SELECT ROUND(AVG(j.mean_annual_salary)) AS public_average_salary
    FROM jobs AS j 
    INNER JOIN industries AS i 
        ON j.industry_id = i.id
    WHERE cig_sagc IS TRUE 
        AND i.id = (SELECT id FROM industries WHERE industry = 'Financial and Insurance Activities')
), 
private_finance AS (
    SELECT ROUND(AVG(j.mean_annual_salary)) AS private_average_salary
    FROM jobs AS j 
    INNER JOIN industries AS i 
        ON j.industry_id = i.id
    WHERE cig_sagc IS FALSE 
        AND i.id = (SELECT id FROM industries WHERE industry = 'Financial and Insurance Activities')
)

SELECT 
    p.public_average_salary, 
    pr.private_average_salary
FROM public_finance AS p 
CROSS JOIN private_finance AS pr; -- public pays an average of 5k more than the private sector in finance