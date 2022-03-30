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

-- 4. Mezirocni procentualni narust nebo klesani prumerne vyplaty vsech odvetvi a ceny konkretni potraviny serazenych podle roku.
--    Pokud je procentualni narust jedne z velicin vetsi nebo mensi jak 10, tak upozoroni na vyraznou zmenu
WITH food_and_salary_average AS (
    SELECT 
        date_year
        ,food_category_code 
        ,food_name
        ,round(avg(average_gross_salary),0) AS average_gross_salary  
        ,round(avg(average_food_price),2) AS average_food_price
    FROM t_michal_bernatik_project_SQL_primary_final tmbpspf
    WHERE food_category_code IS NOT NULL
    GROUP BY date_year, food_category_code 
    ORDER BY food_category_code, date_year
)
,
difference_by_year AS (
    SELECT
        *
        ,average_gross_salary - lag(average_gross_salary) OVER 
            (
            PARTITION BY food_category_code 
                ORDER BY food_category_code , date_year ASC
                    ) AS salary_growth_by_year 
        ,average_food_price - lag(average_food_price) OVER 
            (
            PARTITION BY food_category_code
                ORDER BY food_category_code, date_year ASC
                    ) AS food_price_growth_by_year
    FROM
        food_and_salary_average
)
,
difference_percent AS (
    SELECT
        *
        , round( ((100 * salary_growth_by_year) / average_gross_salary), 1) AS salary_percent_growth
        , round( ((100 * food_price_growth_by_year) / average_food_price), 1) AS food_percent_growth
    FROM
        difference_by_year
)
SELECT *
    ,
    CASE
        WHEN abs(food_percent_growth) - abs(salary_percent_growth) > 10  THEN 'significant'
        WHEN food_percent_growth IS NULL THEN NULL
        ELSE 'normal'
    END AS significant_change_in_food
FROM difference_percent
;

-- 5.  Mezirocni procentualni rust nebo klesani prumerne vyplaty vsech odvetvi, prumerne ceny vsech potravin a vysky HDP serazenych podle roku.
WITH food_and_salary_average AS (
    SELECT 
        date_year
        ,round(avg(average_gross_salary),0) AS average_gross_salary  
        ,round(avg(average_food_price),2) AS average_food_price
        ,GDP
    FROM t_michal_bernatik_project_SQL_primary_final tmbpspf
    WHERE food_category_code IS NOT NULL
    GROUP BY date_year
    ORDER BY food_category_code, date_year
)
,
difference_by_year AS (
    SELECT
        *
        ,average_gross_salary - lag(average_gross_salary) OVER 
            (
                ORDER BY date_year ASC
                    ) AS salary_growth_by_year 
        ,average_food_price - lag(average_food_price) OVER 
            (
                ORDER BY date_year ASC
                    ) AS food_price_growth_by_year
        ,GDP - lag(GDP) OVER 
            (
                ORDER BY date_year ASC
                    ) AS GDP_growth_by_year
    FROM
        food_and_salary_average
)
,
difference_percent AS (
    SELECT
        *
        , round( ((100 * salary_growth_by_year) / average_gross_salary), 1) AS salary_percent_growth
        , round( ((100 * food_price_growth_by_year) / average_food_price), 1) AS food_percent_growth
        , round( ((100 * GDP_growth_by_year) / GDP), 1) AS GDP_percent_growth
    FROM
        difference_by_year
)
SELECT date_year 
    ,salary_percent_growth
    ,food_percent_growth
    ,GDP_percent_growth 
FROM difference_percent ;

