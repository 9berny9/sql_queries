-- 1.   Klesani nebo rust mezd za rok v procentech pro jednotlive odvetvi a vyhodnoceni vyraznych zmen
WITH salary_difference_by_year AS (
    SELECT
        date_year
        , industry_branch_code
        , industry_name
        , average_gross_salary
        , 
            average_gross_salary - lag(average_gross_salary) OVER 
            (
            PARTITION BY industry_branch_code
        ORDER BY
            industry_branch_code ASC
            , date_year ASC
        ) 
                    AS salary_diff_by_year
    FROM
        t_michal_bernatik_project_SQL_primary_final
    GROUP BY
        date_year
        , industry_branch_code
    ORDER BY
        industry_branch_code
        , date_year
)
SELECT
    date_year
    , industry_branch_code
    , industry_name
    , average_gross_salary
    , round( ((100 * salary_diff_by_year) / average_gross_salary), 1) AS percent_diff_by_year
    , 
        CASE
            WHEN salary_diff_by_year  > 0 THEN 'Increase'
            WHEN salary_diff_by_year IS NULL THEN NULL
            ELSE 'Decrease'
        END AS result_by_year
FROM
    salary_difference_by_year 
;
