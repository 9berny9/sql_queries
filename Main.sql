-- PROJECT 1
CREATE TABLE t_michal_bernatik_project_SQL_primary_final
SELECT
    cp.payroll_year
    , cp.industry_branch_code
    , cpib.name
    , avg(value) AS average_gross_salary
FROM
    czechia_payroll cp
LEFT JOIN czechia_payroll_industry_branch cpib 
    ON
    cp.industry_branch_code = cpib.code
WHERE
    1 = 1
    AND value IS NOT NULL
    AND industry_branch_code IS NOT NULL
    AND value_type_code LIKE '5958'
    AND calculation_code LIKE '100'
GROUP BY
    payroll_year
    , industry_branch_code
ORDER BY
    industry_branch_code
    , payroll_year;

-- 1.   Rostou v pr?b?hu let mzdy ve v�ech odv?tv�ch, nebo v n?kter�ch klesaj�?
WITH salary_difference_by_year AS (
    SELECT
        payroll_year
        , industry_branch_code
        , name
        , average_gross_salary
        , 
            average_gross_salary - lag(average_gross_salary) OVER 
            (
            PARTITION BY industry_branch_code
        ORDER BY
            industry_branch_code ASC
            , payroll_year ASC
        ) 
                    AS salary_diff_by_year
    FROM
        t_michal_bernatik_project_SQL_primary_final
)
SELECT
    payroll_year
    , industry_branch_code
    , name
    , average_gross_salary
    , round( ((100 * salary_diff_by_year) / average_gross_salary), 1) AS percent_diff_by_year
    , 
        CASE
            WHEN salary_diff_by_year  > 0 THEN 'Increase'
            WHEN salary_diff_by_year IS NULL THEN NULL
            ELSE 'Decrease'
        END AS result_by_year
FROM
    salary_difference_by_year ;

-- 2.  Kolik je mo�n� si koupit litr? ml�ka a kilogram? chleba za prvn� a posledn� srovnateln� obdob� v dostupn�ch datech cen a mezd?
WITH milk_bread_prices AS (
    SELECT
        cp.date_from
        , cpc.code
        , cpc.name
        , round(avg(value), 2) AS average_price
        , cpc.price_value
        , cpc.price_unit
    FROM
        czechia_price cp
    LEFT JOIN czechia_price_category cpc 
        ON
        cp.category_code = cpc.code
    WHERE
        1 = 1
        AND category_code LIKE '111301'
        OR category_code LIKE '114201'
    GROUP BY
        category_code
        , date_from
    ORDER BY
        date_from ASC
)
,
first_and_last_date AS (
    (
        SELECT
            *
        FROM
            milk_bread_prices
        ORDER BY
            date_from ASC
        LIMIT 2
    )
UNION
    (
    SELECT
            *
    FROM
            milk_bread_prices
    ORDER BY
            date_from DESC
    LIMIT 2
    )
)
,
average_gross_salary AS (
    SELECT
        payroll_year
        , round(avg(average_gross_salary), 0) AS average_gross_salary
    FROM
        t_michal_bernatik_project_SQL_primary_final
    GROUP BY
        payroll_year
)
,
prices_and_salary AS (
    SELECT
        *
    FROM
        first_and_last_date fld
    LEFT JOIN average_gross_salary ags
        ON
        YEAR(fld.date_from) = ags.payroll_year
)
SELECT
    payroll_year AS date_year
    , code
    , name 
    , average_price
    , price_value
    , price_unit 
    , average_gross_salary
    , round((average_gross_salary / average_price), 0) AS quantity_from_salary
FROM
    prices_and_salary 
;

-- 3.  KterÃ¡ kategorie potravin zdraÅ¾uje nejpomaleji (je u nÃ­ nejniÅ¾Å¡Ã­ percentuÃ¡lnÃ­ meziroÄ�nÃ­ nÃ¡rÅ¯st)?
WITH food_prices_by_year AS(
    SELECT
        category_code
        , YEAR (date_from) AS date_year
        , round(avg(value), 2) AS average_price
    FROM
        czechia_price cp
    GROUP BY
        YEAR(date_from)
        , category_code
    ORDER BY
        category_code ASC
        , date_from ASC
)
,
price_difference_by_year AS (
    SELECT
        *
        ,
        average_price - lag(average_price) OVER 
            (
            PARTITION BY category_code
        ORDER BY
            category_code ASC
            , date_year ASC
        )
                    AS price_growth_by_year
    FROM
        food_prices_by_year
)
,
food_percent_growth AS (
    SELECT
        *
        ,
        round( ((100 * price_growth_by_year) / average_price), 1) AS percent_growth
    FROM
        price_difference_by_year
)
SELECT
    fpq.category_code
    , cpc.name
    , avg(fpq.percent_growth) AS average_percent_growth
FROM
    food_percent_growth fpq
LEFT JOIN czechia_price_category cpc
    ON
    fpq.category_code = cpc.code
GROUP BY
    category_code
ORDER BY
    average_percent_growth ASC
;

-- 4.Existuje rok, ve kterÃ©m byl meziroÄ�nÃ­ nÃ¡rÅ¯st cen potravin vÃ½raznÄ› vyÅ¡Å¡Ã­ neÅ¾ rÅ¯st mezd (vÄ›tÅ¡Ã­ neÅ¾ 10 %)?

WITH growth_year_salary AS (
    SELECT
        payroll_year
        , round(avg(average_gross_salary), 0) AS average_gross_salary
    FROM
        t_michal_bernatik_project_SQL_primary_final
    GROUP BY
        payroll_year
)
,
salary_difference_by_year AS (
    SELECT
        payroll_year
        , average_gross_salary
        , average_gross_salary - lag(average_gross_salary) OVER 
            (ORDER BY payroll_year ASC
                ) AS salary_growth_by_year
    FROM
        growth_year_salary
)
,
salary_percent AS (
    SELECT
        *
        , round( ((100 * salary_growth_by_year) / average_gross_salary), 1) AS salary_percent_growth
    FROM
        salary_difference_by_year
)
,
food_year_growth AS (
    SELECT
        YEAR(date_from) AS date_year
        , avg(value) AS average_food_price
    FROM
        czechia_price cp
    GROUP BY
        date_year
)
,
food_difference_by_year AS (
    SELECT
        *
        ,
        average_food_price - lag(average_food_price) OVER 
            (
        ORDER BY
            date_year ASC
        ) 
                    AS food_price_growth_by_year
    FROM
        food_year_growth
)
,
food_percent AS (
    SELECT
        *
        , round( ((100 * food_price_growth_by_year) / average_food_price), 1) AS food_percent_growth
    FROM
        food_difference_by_year
),
food_and_prices_table AS (
    SELECT
        fp.date_year
        , sp.salary_percent_growth
        , fp.food_percent_growth
        ,
        CASE
            WHEN food_percent_growth - salary_percent_growth > 10  THEN 'significant'
            ELSE 'normal'
        END AS significant_increase_in_food
    FROM
        salary_percent sp
    LEFT JOIN food_percent fp
        ON
        sp.payroll_year = fp.date_year
    WHERE
        date_year IS NOT NULL
        AND food_percent_growth IS NOT NULL
    ORDER BY
        payroll_year 
),
GDP_year_growth AS (
        SELECT
            `year` 
            , GDP
        FROM
            economies e
        WHERE
            country LIKE 'Czech%'
            AND GDP IS NOT NULL
        ORDER BY
            `year`
)
,
GDP_difference_by_year AS (
    SELECT
        `year` 
        , GDP 
        , GDP - lag(GDP) OVER 
            (
        ORDER BY
            `year`  ASC
            ) AS GDP_growth_by_year
    FROM
        GDP_year_growth
),
GDP_table AS (
        SELECT
            *
            , round( ((100 * GDP_growth_by_year) / GDP), 1) AS GDP_percent_growth
        FROM
            GDP_difference_by_year
    )
SELECT fap.*, gt.GDP_percent_growth 
FROM food_and_prices_table fap
LEFT JOIN GDP_table gt 
    ON fap.date_year = gt.year
;



