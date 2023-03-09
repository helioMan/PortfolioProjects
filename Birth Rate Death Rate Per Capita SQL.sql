

--1. View tables from all three databases
SELECT *
FROM portfolioProject.dbo.death_data
ORDER BY country 

SELECT *
FROM portfolioProject.dbo.birth_data
ORDER BY country 

SELECT *
FROM portfolioProject.dbo.perCapita
ORDER BY [Country Code]

--2. Select the common columns from birth and death dataset
SELECT place, pop2023, growthRate, area, country, cca3, cca2, ccn3, region, subregion, landAreaKm, density, densityMi, Rank
FROM portfolioProject.dbo.birth_data

SELECT place, pop2023, growthRate, area, country, cca3, cca2, ccn3, region, subregion, landAreaKm, density, densityMi, Rank
FROM portfolioProject.dbo.birth_data

--3. Select top 20 countries with the highest growth rate
SELECT TOP 20 country, growthRate
FROM portfolioProject.dbo.birth_data
ORDER BY growthRate DESC;


--4. Select the top 20 countries with the lowest growth rate
SELECT TOP 20 country, growthRate
FROM portfolioProject.dbo.birth_data
ORDER BY growthRate;


--5. Analyze the relationship between a country's growth rate and its birth rate. 
SELECT country, growthRate, birthRate
FROM portfolioProject.dbo.birth_data
ORDER BY growthRate;

--6. Identify countries with declining birth rates and explore the potential 
--causes for the decline.
SELECT country, growthRate
FROM portfolioProject.dbo.birth_data
WHERE growthRate < 0
ORDER BY growthRate ASC;

--7. Combine the birth rate data with other socio-economic indicators, such as GDP 
--per capita, to identify any relationships between these factors.
SELECT d.country, d.growthRate, e.IncomeGroup, d.pop2023
FROM portfolioProject.dbo.birth_data d
INNER JOIN portfolioProject.dbo.perCapita e ON d.cca3 = e.[Country Code];

--8. Compare birth rate data to death rate data to gain insights into a country's population growth or 
--decline. 
SELECT d.country, d.growthRate, d.birthRate, m.rateUN as crude_death_rate
FROM portfolioProject.dbo.birth_data d
INNER JOIN portfolioProject.dbo.death_data m ON d.country = m.country;

--9. Compare the average birth rate in Europe and Asia
SELECT region, ROUND(AVG(birthRate), 2) as average_birth_rate
FROM portfolioProject.dbo.birth_data
WHERE region IN ('Europe', 'Asia')
Group by region

--10. Comparison of birthRate and regions
SELECT region, ROUND(AVG(birthRate), 3) as avgBirthRate
FROM portfolioProject.dbo.birth_data
GROUP BY region

--11. Correlation between birth rate and the per capita values
SELECT
    ROUND((COUNT(*) * SUM(xy) - SUM(x) * SUM(y)) / 
	(SQRT(COUNT(*) * SUM(x2) - SUM(x) * SUM(x)) * SQRT(COUNT(*)
	* SUM(y2) - SUM(y) * SUM(y))),2) AS correlation_coefficient_between_growthRate_crudDeathRate
FROM
    (SELECT
         growthRate AS x,
         rateUN AS y,
         growthRate * rateUN AS xy,
         growthRate * growthRate AS x2,
         rateUN * rateUN AS y2
     FROM portfolioProject.dbo.death_data) dd;

--A correlation coefficient of -0.08 indicates a weak negative 
--correlation between growthRate and rateUN (crude death rate per
--1,000 population according to the United Nations). This means 
--that as the growth rate of a country increases, the crude death 
--rate tends to decrease slightly, but the relationship between the two is not strong.

--12. Display the income levels in perCapita table as ranks using numbers 1, 2, 3, 4, where
--1 is the highest and 4 is the lowest
SELECT pc.[Country Code], pc.Region, pc.TableName as CountryName,
    CASE 
        WHEN IncomeGroup IS NULL THEN 'NA'
        WHEN IncomeGroup = 'High income' THEN '1'
        WHEN IncomeGroup = 'Low income' THEN '2'
        WHEN IncomeGroup = 'Upper middle income' THEN '3'
        WHEN IncomeGroup = 'Lower middle income' THEN '4'
    END AS income_group_code
FROM portfolioProject.dbo.perCapita pc
ORDER BY income_group_code


--13. Analyze the relationship between a country's land area 
--and its population density. Is there a correlation between the two?
SELECT country as countryName, landAreaKm as landArea, density as populationDensity
FROM portfolioProject.dbo.birth_data
ORDER BY landAreaKm;

--Calculate the correlation coefficient between land area and population density
SELECT
    ROUND((COUNT(*) * SUM(xy) - SUM(x) * SUM(y)) / 
	(SQRT(COUNT(*) * SUM(x2) - SUM(x) * SUM(x)) * SQRT(COUNT(*)
	* SUM(y2) - SUM(y) * SUM(y))),2) AS correlation_coefficient_between_landArea_density
FROM
    (SELECT
         landAreaKm AS x,
         density AS y,
         landAreaKm * density AS xy,
         landAreaKm * landAreaKm AS x2,
         density * density AS y2
     FROM portfolioProject.dbo.birth_data) bd;
--A correlation coefficient of -0.06 indicates a weak negative correlation between land
--area and population density. However, it's important to note that correlation does not
--necessarily imply causation, and there may be other factors at play that influence population density.


--14. Identify countries with the highest death rates
SELECT country, deathsGHDE as death2023
FROM portfolioProject.dbo.death_data
ORDER BY deathsGHDE DESC;

--15. Compare the projected population in 2023 to the current population to identify the countries with the 
--highest population growth rates.
SELECT country, pop2023, ROUND(pop2023 - (pop2023 / (1 + (growthRate / 100))),3) as currentPopulation
FROM portfolioProject.dbo.death_data
ORDER BY currentPopulation DESC;

--16. Analyze the relationship between a country's population density and its birth rate. 
SELECT country, density, birthRate
FROM portfolioProject.dbo.birth_data
ORDER BY density;

--17. Calculate the correlation coefficient between population density and birth rate
SELECT
    ROUND((COUNT(*) * SUM(xy) - SUM(x) * SUM(y)) / 
	(SQRT(COUNT(*) * SUM(x2) - SUM(x) * SUM(x)) * SQRT(COUNT(*)
	* SUM(y2) - SUM(y) * SUM(y))),2) AS correlation_coefficient_density_birthRate
FROM
    (SELECT
         density AS x,
         birthRate AS y,
         density * birthRate AS xy,
         density * density AS x2,
         birthRate * birthRate AS y2
     FROM portfolioProject.dbo.birth_data) bd;

--A correlation coefficient of -0.17 suggests a weak negative correlation between 
--density and birth rate in the given dataset. This means that as population density 
--increases, the birth rate tends to decrease slightly. However, the correlation is weak,
--which means that there is a lot of variability in the data and other factors may be 
--affecting the relationship between density and birth rate.

--18. Population densities in different regions
SELECT region, ROUND(AVG(bd.pop2023 / bd.landAreaKm), 3) AS avg_population_density
FROM portfolioProject.dbo.birth_data bd
GROUP BY region;

--19. Analyze the relationship between a country's income level and its birth rate.
SELECT TOP 100 bd.country, pc.IncomeGroup, AVG(bd.birthRate) AS avg_birth_rate
FROM portfolioProject.dbo.birth_data bd
INNER JOIN portfolioProject.dbo.perCapita pc
	ON bd.cca3 = pc.[Country Code]
GROUP BY pc.IncomeGroup, bd.country

--20. Identify the top 10 countries with the highest death rates.
SELECT TOP 20 dd.country, dd.rateUN 
FROM portfolioProject.dbo.death_data dd

--21. Analyze the relationship between a country's land area and its population density.
SELECT bd.country, bd.cca3, ROUND((bd.pop2023 / bd.landAreaKm),2) AS population_density
FROM portfolioProject.dbo.birth_data bd
ORDER BY population_density

