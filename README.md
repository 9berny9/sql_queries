# Mzdy, potraviny a HDP (Česká Republika)
## Popis projektu
Pro společnost zabývající se životní úrovní občanů v České Republice je potřeba připravit robustní datové podklady, ve kterých bude možné vidět porovnání dostupnosti potravin na základě průměrných příjmů za určité časové období.   
Jako dodatečný materiál připravte i tabulku s HDP, GINI koeficientem a populací dalších evropských států ve stejném období, jako primární přehled pro ČR.
### Výzkumné otázky
1) Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
2) Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
3) Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
4) Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
5) Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?
### Vstupní data
Pro odpovědi na otázky budu používat zálohu databáze, která obsahuje datové sady **primárnách tabulek** jako informace o mzdách, kalkulacích mezd, číselníky mezd, ceny potravin, kategorie potravit a vše za několikaleté období.   
Dále datová sada obsahuje **číselníky sdílených informací o ČR** (číselníky krajů a regionů) a **dodatečné tabulky** (informace o všech zemí světa a jejich ekonomii)

Záloha databáze, kterou budu používat se nachází v repozitáři pod názvem:   
**_czechia_database_02_2022-202203041903.sql_**

## Řešení výzkumných otázek
V první řadě jsem vyfiltroval data, které nebudu potřebovat a spojil je do jedné tabulky, kterou budu používat pro řešení výzkumných otázek. Tabulka obsahuje pouze data podle datumu, které jsou dostupné pro všechny výzkumné otázky. Tabulka se nachází v repozitáři pod názvem   
_**t_michal_bernatik_project_SQL_primary_final.sql**_

### Obsah pracovní tabulky
Tabulka obsahuje data pro jednotlivé roky v daném pracovním odvětví, název potraviny a jeho průměrnou cenu a HDP konkrétního roku.   
Tabulka je očištěná o nulové hodnoty a roky, které nemají záznamy pro všechny sledované veličiny (mzda, cena potraviny a HDP).

### Výsledky výzkmných otázek
Výstupy pro výzkumné otázky vychází z jednotlivých selectů, které jsou uloženy v **__main_answers.sql__** a každá otázka má pouze jeden SELECT. Jednotlivé výstupy a výsledky z těchto selectů jsou zpracováný v následujících odrážkách.
#### 1) Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
V tabulce jsou mzdy seřazené podle odvětví a roku vzestupně. Ve sloupci *diff_by_year* sleduji jaký je procentuální meziroční růst nebo klesání průměrné mzdy za konkrétní rok. 
Ze zjištěných dat lze vidět, že mzdy ve všech odvětví průměrně od roku 2006 do 2018 rostou. V některých rocích došlo k mírnému meziročnímu poklesu, ale za celé období není odvětví, kde by mzdy klesaly.  

Zde ukázka výsledků pro první dvě odvětví:
```
date_year|industry_branch_code|industry_name                                               |average_gross_salary|percent_diff_by_year|result_by_year|
---------+--------------------+------------------------------------------------------------+--------------------+--------------------+--------------+
     2006|A                   |Zemědělství, lesnictví, rybářství                           |          14421.0000|                    |              |
     2007|A                   |Zemědělství, lesnictví, rybářství                           |          15761.2500|                 8.5|Increase      |
     2008|A                   |Zemědělství, lesnictví, rybářství                           |          17292.5000|                 8.9|Increase      |
     2009|A                   |Zemědělství, lesnictví, rybářství                           |          17193.0000|                -0.6|Decrease      |
     2010|A                   |Zemědělství, lesnictví, rybářství                           |          18019.5000|                 4.6|Increase      |
     2011|A                   |Zemědělství, lesnictví, rybářství                           |          18674.0000|                 3.5|Increase      |
     2012|A                   |Zemědělství, lesnictví, rybářství                           |          19537.0000|                 4.4|Increase      |
     2013|A                   |Zemědělství, lesnictví, rybářství                           |          20207.0000|                 3.3|Increase      |
     2014|A                   |Zemědělství, lesnictví, rybářství                           |          20952.0000|                 3.6|Increase      |
     2015|A                   |Zemědělství, lesnictví, rybářství                           |          21232.2500|                 1.3|Increase      |
     2016|A                   |Zemědělství, lesnictví, rybářství                           |          22240.0000|                 4.5|Increase      |
     2017|A                   |Zemědělství, lesnictví, rybářství                           |          23531.2500|                 5.5|Increase      |
     2018|A                   |Zemědělství, lesnictví, rybářství                           |          25115.2500|                 6.3|Increase      |
     2006|B                   |Těžba a dobývání                                            |          24017.5000|                    |              |
     2007|B                   |Těžba a dobývání                                            |          25675.7500|                 6.5|Increase      |
     2008|B                   |Těžba a dobývání                                            |          29236.0000|                12.2|Increase      |
     2009|B                   |Těžba a dobývání                                            |          27960.5000|                -4.6|Decrease      |
     2010|B                   |Těžba a dobývání                                            |          30203.5000|                 7.4|Increase      |
     2011|B                   |Těžba a dobývání                                            |          31445.7500|                 4.0|Increase      |
     2012|B                   |Těžba a dobývání                                            |          32487.0000|                 3.2|Increase      |
     2013|B                   |Těžba a dobývání                                            |          31685.7500|                -2.5|Decrease      |
     2014|B                   |Těžba a dobývání                                            |          31370.2500|                -1.0|Decrease      |
     2015|B                   |Těžba a dobývání                                            |          31539.5000|                 0.5|Increase      |
     2016|B                   |Těžba a dobývání                                            |          31348.0000|                -0.6|Decrease      |
     2017|B                   |Těžba a dobývání                                            |          33462.2500|                 6.3|Increase      |
     2018|B                   |Těžba a dobývání                                            |          35942.7500|                 6.9|Increase      |
```
#### 2) Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
Průměrná mzda je počítaná pro všechny odvětví a výsledky jsou zobrazeny ve sloupci _quantity_from_salary_. Množství a jednotku určují sloupce _food_price_value_ a _food_price_unit_.

```
date_year|food_category_code|food_name                  |food_price_value|food_price_unit|average_gross_salary|average_food_price|quantity_from_salary|
---------+------------------+---------------------------+----------------+---------------+--------------------+------------------+--------------------+
     2006|            111301|Chléb konzumní kmínový     |             1.0|kg             |            20342.38|             16.12|              1262.0|
     2006|            114201|Mléko polotučné pasterované|             1.0|l              |            20342.38|             14.44|              1409.0|
     2018|            114201|Mléko polotučné pasterované|             1.0|l              |            31980.26|             19.82|              1614.0|
     2018|            111301|Chléb konzumní kmínový     |             1.0|kg             |            31980.26|             24.24|              1319.0|
```

#### 3) Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
Nejpomaleji ze všech potravin meziročně roste cena _Rajská jablek červená_, která průměrně za období 2006 až 2018 klesá o _**-3,85%**_.
Nejrychleji roste cena Testovin vaječných o 4,9%.

```
food_category_code|food_name                       |food_price_value|food_price_unit|average_food_price_by_years|average_percent_growth|
------------------+--------------------------------+----------------+---------------+---------------------------+----------------------+
            117101|Rajská jablka červená kulatá    |             1.0|kg             |                      40.75|                  -3.8|
            118101|Cukr krystalový                 |             1.0|kg             |                      20.53|                  -3.5|
            117401|Konzumní brambory               |             1.0|kg             |                      13.43|                  -0.2|
            111303|Pečivo pšeničné bílé            |             1.0|kg             |                      42.16|                  -0.1|
            116103|Banány žluté                    |             1.0|kg             |                      30.17|                   0.4|
            116104|Jablka konzumní                 |             1.0|kg             |                      30.55|                   0.7|
            112201|Vepřová pečeně s kostí          |             1.0|kg             |                     108.96|                   0.8|
            122102|Přírodní minerální voda uhličitá|             1.0|l              |                       8.41|                   0.9|
            114501|Eidamská cihla                  |             1.0|kg             |                     127.61|                   1.2|
            112704|Šunkový salám                   |             1.0|kg             |                     125.11|                   1.8|
            111201|Pšeničná mouka hladká           |             1.0|kg             |                      11.09|                   2.2|
            114201|Mléko polotučné pasterované     |             1.0|l              |                      17.92|                   2.3|
            112101|Hovězí maso zadní bez kosti     |             1.0|kg             |                     193.14|                   2.4|
           2000001|Kapr živý                       |             1.0|kg             |                      84.61|                   2.4|
            117106|Mrkev                           |             1.0|kg             |                      17.18|                   2.4|
            117103|Papriky                         |             1.0|kg             |                      58.85|                   2.5|
            212101|Jakostní víno bílé              |            0.75|l              |                      95.97|                   2.6|
            213201|Pivo výčepní, světlé, lahvové   |             0.5|l              |                      10.11|                   2.7|
            115201|Rostlinný roztíratelný tuk      |             1.0|kg             |                      86.92|                   2.8|
            111301|Chléb konzumní kmínový          |             1.0|kg             |                      21.47|                   2.9|
            112401|Kuřata kuchaná celá             |             1.0|kg             |                      62.69|                   2.9|
            114701|Vejce slepičí čerstvá           |            10.0|ks             |                      29.45|                   2.9|
            116101|Pomeranče                       |             1.0|kg             |                      31.07|                   2.9|
            114401|Jogurt bílý netučný             |           150.0|g              |                       7.29|                   3.6|
            111101|Rýže loupaná dlouhozrnná        |             1.0|kg             |                      33.09|                   3.9|
            115101|Máslo                           |             1.0|kg             |                     142.59|                   4.8|
            111602|Těstoviny vaječné               |             1.0|kg             |                      37.41|                   4.9|
```

