-- 1.   Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

-- ZAKLADNI SPOJENE TABULKY PRO UKOL
SELECT avg(value) AS average_gross_salary, cp.payroll_year, cp.industry_branch_code, cpib.name 
FROM czechia_payroll cp
LEFT JOIN czechia_payroll_industry_branch cpib 
    ON cp.industry_branch_code = cpib.code 
WHERE 1=1
    AND value IS NOT NULL
    AND industry_branch_code IS NOT NULL
    AND value_type_code  LIKE '5958'
    AND calculation_code LIKE '200'
GROUP BY payroll_year, industry_branch_code
ORDER BY industry_branch_code, payroll_year;
-- -----------------------------------------------------
-- RUST OD NOMINALU PRVNIHO ROKU
WITH industry_year_salary AS (
    SELECT avg(value) AS average_gross_salary, cp.payroll_year, cp.industry_branch_code, cpib.name 
    FROM czechia_payroll cp
    LEFT JOIN czechia_payroll_industry_branch cpib 
        ON cp.industry_branch_code = cpib.code 
    WHERE 1=1
        AND value IS NOT NULL
        AND industry_branch_code IS NOT NULL
        AND value_type_code  LIKE '5958'
        AND calculation_code LIKE '200'
    GROUP BY payroll_year, industry_branch_code
    ORDER BY industry_branch_code, payroll_year
),
industry_avg_salary_first_year AS (
    SELECT industry_branch_code, min(payroll_year) AS first_year, average_gross_salary AS first_year_salary 
    FROM industry_year_salary 
    GROUP BY industry_branch_code 
)
SELECT iys.industry_branch_code, iys.name, iys.payroll_year, iys.average_gross_salary, 
        round((iys.average_gross_salary - iasfy.first_year_salary)/100,0) AS percent_grow_from_first_year
FROM industry_year_salary iys
LEFT JOIN industry_avg_salary_first_year iasfy 
    ON iys.industry_branch_code = iasfy.industry_branch_code;
-- -----------------------------------------------------
-- MEZIROCNI RUST
WITH industry_year_salary AS (
    SELECT cp.payroll_year, cp.industry_branch_code, cpib.name, avg(value) AS average_gross_salary
    FROM czechia_payroll cp
    LEFT JOIN czechia_payroll_industry_branch cpib 
        ON cp.industry_branch_code = cpib.code 
    WHERE 1=1
        AND value IS NOT NULL
        AND industry_branch_code IS NOT NULL
        AND value_type_code  LIKE '5958'
        AND calculation_code LIKE '200'
    GROUP BY payroll_year, industry_branch_code
    ORDER BY industry_branch_code, payroll_year
),
salary_difference_by_year AS (
    SELECT payroll_year, industry_branch_code, name, average_gross_salary, 
            average_gross_salary - lag(average_gross_salary) OVER 
            (PARTITION BY industry_branch_code  
                ORDER BY industry_branch_code ASC, payroll_year ASC) 
                    AS salary_growth_by_year
    FROM industry_year_salary
)
SELECT *, round( ((100 * salary_growth_by_year) / average_gross_salary),1)  AS percent_growth
FROM salary_difference_by_year ;


-- 2.  Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

-- chleba, mleko prvni zaznam
WITH first_date AS (
    SELECT cp.date_from, cpc.code, cpc.name, round(avg(value),2) as average_price, cpc.price_value, cpc.price_unit
    FROM czechia_price cp
    LEFT JOIN czechia_price_category cpc 
        ON cp.category_code = cpc.code 
    WHERE 1=1
        AND category_code LIKE '111301' 
        OR category_code LIKE '114201'
    GROUP BY category_code , date_from
    ORDER BY date_from ASC
    LIMIT 2
),
-- chleba, mleko posledni zaznam
last_date AS (
    SELECT cp.date_from, cpc.code, cpc.name, round(avg(value),2) as average_price, cpc.price_value, cpc.price_unit
    FROM czechia_price cp
    LEFT JOIN czechia_price_category cpc 
        ON cp.category_code = cpc.code 
    WHERE 1=1
        AND category_code LIKE '111301' 
        OR category_code LIKE '114201'
    GROUP BY category_code , date_from
    ORDER BY date_from DESC, code 
    LIMIT 2
),
first_payroll_year AS (
    SELECT round(avg(value),2) AS average_gross_salary, cp.payroll_year 
    FROM czechia_payroll cp
    WHERE 1=1
        AND value IS NOT NULL
        AND value_type_code  LIKE '5958'
        AND calculation_code LIKE '200'
    GROUP BY payroll_year
    ORDER BY payroll_year
),
first_and_last_date AS (
    SELECT *
    FROM first_date
    UNION
    SELECT *
    FROM last_date
    ORDER BY code, date_from
)
SELECT fld.*, fpy.average_gross_salary, round((average_gross_salary /average_price),0) AS quantity_from_salary
FROM first_and_last_date fld
LEFT JOIN first_payroll_year fpy 
    ON year(fld.date_from) =  fpy.payroll_year;


-- 3.  Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
WITH food_prices_by_year AS(
    SELECT category_code, year (date_from) as date_year, round(avg(value),2) as average_price
    FROM czechia_price cp
    GROUP BY year(date_from), category_code
    ORDER BY category_code ASC, date_from ASC
),
price_difference_by_year AS (
    SELECT *,
        average_price - lag(average_price) OVER 
            (PARTITION BY category_code  
                ORDER BY category_code ASC, date_year ASC)
                    AS price_growth_by_year
    FROM food_prices_by_year
)
SELECT *,
    round( ((100 * price_growth_by_year) / average_price),1)  AS percent_growth
FROM price_difference_by_year
;



-- 4.  Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
