-- exploratory queries
-- average pay rankings by industry
SELECT i.industry, ROUND(AVG(mean_annual_salary)::NUMERIC, 2) AS average_salary, 
RANK () OVER(ORDER BY ROUND(AVG(mean_annual_salary)::NUMERIC, 2) DESC) AS industry_rank
FROM jobs 
INNER JOIN industries AS i 
    ON jobs.industry_id = i.id
GROUP BY i.industry
ORDER BY average_salary DESC; -- highest average pay by industry is Financial and Insurance activities with an average of $92,707.86


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

-- TODO: add filter for only the top 5-10 industries by average pay

