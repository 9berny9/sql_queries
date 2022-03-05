-- 1.   Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

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
-- 4.  Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
