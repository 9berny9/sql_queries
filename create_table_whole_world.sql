CREATE OR REPLACE
TABLE t_michal_bernatik_project_SQL_secondary_final
SELECT
    c.country
    , c.continent
    , e.`year`
    , e.GDP
    , e.gini
    , e.population
FROM
    economies e
LEFT JOIN countries c 
ON
    e.country = c.country
WHERE 
    1 = 1
    AND e.`year` BETWEEN 2006 AND 2018
    AND c.country IS NOT NULL
    AND c.continent = 'Europe'
ORDER BY
    country
    , `year`;