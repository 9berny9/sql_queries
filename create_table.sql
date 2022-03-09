CREATE OR REPLACE
TABLE t_michal_bernatik_project_SQL_primary_final
WITH czechia_payroll_by_year AS
(
    SELECT
        cp.payroll_year AS date_year
        , cp.industry_branch_code
        , cpib.name AS industry_name
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
)
,
food_prices_by_year AS
(
    SELECT
        YEAR (date_from) AS date_year
        , cp.category_code AS food_category_code
        , cpc.name AS food_name
        , cpc.price_value
        , cpc.price_unit
        , round(avg(value), 2) AS average_food_price
    FROM
        czechia_price cp
    LEFT JOIN czechia_price_category cpc
        ON
        cp.category_code = cpc.code
    GROUP BY
        YEAR(date_from)
        , category_code
)
,
GDP_by_year AS
(
    SELECT
        `year` AS date_year
        , GDP
    FROM
        economies e
    WHERE
        country LIKE 'Czech%'
        AND GDP IS NOT NULL
    ORDER BY
        `year`
)
SELECT
    cpy.date_year
    , cpy.industry_branch_code
    , cpy.industry_name
    , fpy.food_category_code
    , fpy.food_name
    , fpy.price_value AS food_price_value
    , fpy.price_unit AS food_price_unit
    , cpy.average_gross_salary
    , fpy.average_food_price
    , gby.GDP
FROM
    czechia_payroll_by_year cpy
LEFT JOIN food_prices_by_year fpy
    ON
    cpy.date_year = fpy.date_year
LEFT JOIN GDP_by_year gby
    ON cpy.date_year = gby.date_year 
ORDER BY
    cpy.date_year
    , cpy.industry_branch_code
    , fpy.food_category_code 
;



