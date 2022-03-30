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

-- 2.  Pocet mnozstvi litru mleka a kilogramu chleba z prumerne vyplaty pro prvni a posledni zaznam
WITH milk_bread_prices AS (
    SELECT
        date_year
        , food_category_code
        , food_name
        , food_price_value
        , food_price_unit
        , round(avg(average_gross_salary),2) AS average_gross_salary
        , average_food_price
    FROM
        t_michal_bernatik_project_SQL_primary_final tmb
    WHERE
        1 = 1
        AND food_category_code LIKE '111301'
        OR food_category_code LIKE '114201'
    GROUP BY
        food_category_code
        , date_year
    ORDER BY
        date_year ASC
)
,
first_and_last_date AS (
    (
    SELECT
        *
    FROM
        milk_bread_prices
    ORDER BY
        date_year ASC
    LIMIT 2
    )
UNION
    (
    SELECT
            *
    FROM
            milk_bread_prices
    ORDER BY
            date_year DESC
    LIMIT 2
    )
)
SELECT
    *
    , round((average_gross_salary / average_food_price), 0) AS quantity_from_salary
FROM
    first_and_last_date 
;

-- 3. Mezirocni prumerny narust nebo klesani cen potravin v procentech a serazeny podle nejpomalejsiho rustu
WITH     price_difference_by_year AS (
    SELECT
        date_year 
        , food_category_code
        , food_name
        , food_price_value
        , food_price_unit
        , average_food_price
        ,
        average_food_price - lag(average_food_price) OVER 
            (
            PARTITION BY food_category_code
                ORDER BY
                    food_category_code ASC
                    , date_year ASC
                    )   AS price_growth_by_year
    FROM
        t_michal_bernatik_project_SQL_primary_final tmb
    WHERE food_category_code IS NOT NULL
    GROUP BY date_year, food_category_code
    ORDER BY food_category_code, date_year
)
,
food_percent_growth AS (
    SELECT
        *
        ,
        round( ((100 * price_growth_by_year) / average_food_price), 1) AS percent_growth
    FROM
        price_difference_by_year
)
SELECT
    food_category_code
    , food_name
    , food_price_value
    , food_price_unit
    , round(avg(average_food_price),2) AS average_food_price_by_years 
    , round(avg(fpq.percent_growth),1) AS average_percent_growth
FROM
    food_percent_growth fpq
GROUP BY
    food_category_code
ORDER BY
    average_percent_growth ASC
;
