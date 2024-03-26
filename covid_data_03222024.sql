-- create table for covid deaths and import csv

CREATE TABLE coviddeaths (
	iso_code VARCHAR(25), 
	continent VARCHAR(50), 
	location VARCHAR(50),
	date DATE, 
	population BIGINT, 
	total_cases FLOAT, 
	new_cases FLOAT, 
	new_cases_smoothed FLOAT,                    
	total_deaths FLOAT, 
	new_deaths FLOAT, 
	total_cases_per_million FLOAT,
	new_cases_per_million FLOAT, 
	new_cases_smoothed_per_million FLOAT,
	total_deaths_per_million FLOAT, 
	new_deaths_per_million FLOAT, 
	new_deaths_smoothed_per_million FLOAT, 
	reproduction_rate FLOAT,
	icu_patients FLOAT, 
	icu_patients_per_million FLOAT, 
	hosp_patients INT, 
	hosp_patients_per_million FLOAT, 
	weekly_icu_admissions FLOAT,
	weekly_icu_admissions_per_million FLOAT, 
	weekly_hosp_admissions FLOAT, 
	weekly_hosp_admissions_per_million FLOAT)
	
-- create table for covid vaccinations and import csv 

CREATE TABLE covidvaccinations (
	iso_code VARCHAR(25), 
	continent VARCHAR(50), 
	location VARCHAR(50), 
	date DATE, 
	total_tests FLOAT, 
	new_tests FLOAT, 
	new_tests_per_thousand FLOAT, 
	new_tests_smoothed FLOAT, 
	new_tests_smoothed_per_thousand FLOAT, 
	positive_rate FLOAT, 
	tests_per_case FLOAT, 
	tests_units VARCHAR(50), 
	total_vaccinations FLOAT, 
	people_vaccinated FLOAT, 
	people_fully_vaccinated FLOAT, 
	total_boosters FLOAT, 
	new_vaccinations FLOAT, 
	new_vaccinations_smoothed FLOAT, 
	total_vaccinations_per_hundred FLOAT, 
	people_vaccinated_per_hundred FLOAT, 
	people_fully_vaccinated_per_hundred FLOAT, 
	total_boosters_per_hundred FLOAT, 
	new_vaccinations_smoothed_per_million FLOAT, 
	new_people_vaccinated_smoothed FLOAT, 
	new_people_vaccinated_smoothed_per_hundred FLOAT, 
	stringency_index FLOAT, 
	population_density FLOAT, 
	median_age FLOAT, 
	aged_65_older FLOAT, 
	aged_70_older FLOAT, 
	gdp_per_capita FLOAT, 
	extreme_poverty FLOAT, 
	cardiovasc_death_rate FLOAT, 
	diabetes_prevalence FLOAT, 
	female_smokers FLOAT, 
	male_smokers FLOAT, 
	handwashing_facilities FLOAT, 
	hospital_beds_per_thousand FLOAT, 
	life_expectancy FLOAT, 
	human_development_index FLOAT, 
	excess_mortality_cumulative FLOAT, 
	excess_mortality FLOAT, 
	excess_mortality_cumulative_per_million FLOAT)


-- check tables for covid deaths and covid vaccinations

SELECT *
FROM coviddeaths
ORDER BY location, date;

SELECT *
FROM covidvaccinations
ORDER BY location, date;


-- some rows don't contain a continent, and instead the continent is in the "location" column which creates duplicate rows
-- these rows aren't NULL and instead are empty strings, so use " WHERE continent <> '' " to filter out


-- look at total cases vs total deaths to show death rate for people who contracted covid

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM coviddeaths
WHERE continent <> ''
ORDER BY location, date;


-- look at total cases vs population to show infection rate

SELECT location, date, population, total_cases, (total_cases/population) *100  AS DeathPercentage
FROM coviddeaths
WHERE continent <> ''
ORDER BY DeathPercentage;


-- look at countries with highest contraction count vs population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount ,MAX((total_cases/population)) * 100 AS PercentPopInfected
FROM coviddeaths
WHERE continent <> ''
GROUP BY location, population
ORDER BY PercentPopInfected DESC;


-- look at countries with the highest death count

SELECT location, COALESCE(MAX(total_deaths), 0) AS HighestDeathCount -- use COASLESCE for total_deaths, as some counties have NULL data
FROM coviddeaths
WHERE continent <> ''
GROUP BY location
ORDER BY HighestDeathCount DESC;


-- look at continent with the highest death count

SELECT continent, COALESCE(MAX(total_deaths), 0) AS HighestDeathCount -- use COASLESCE for total_deaths, as some counties have NULL data
FROM coviddeaths
WHERE continent <> ''
GROUP BY continent
ORDER BY HighestDeathCount DESC;


-- the above query isn't factoring in some countries to continents (i.e. Canada isn't included in North America), so use the previous
-- continent column that we initially excluded to filter (will need to additionally filter out continents that are called "income")

SELECT location, COALESCE(MAX(total_deaths), 0) AS HighestDeathCount -- use COASLESCE for total_deaths, as some counties have NULL data
FROM coviddeaths
WHERE continent = '' AND location NOT ILIKE '%income%'
GROUP BY location
ORDER BY HighestDeathCount DESC;


-- look at global numbers

SELECT date, SUM(new_cases) AS NewCases, SUM(new_deaths) AS NewDeaths, SUM(new_deaths)/NULLIF(SUM(new_cases), 0) *100 AS NewDeathPercent
FROM coviddeaths
WHERE continent = '' AND location NOT ILIKE '%income%'
GROUP BY date
ORDER BY date;

-- it appears that data is only being recorded for new cases and new deaths once per week now, as cases and deaths ony appear
-- every seven days, so since rows are grouped by date, filter for every seven days to get weekly figures

SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/NULLIF(SUM(new_cases), 0) *100 AS NewDeathPercent
FROM coviddeaths
WHERE continent = '' AND location NOT ILIKE '%income%' AND continent <> 'World'AND MOD(date - date '2020-01-05', 7) = 0
GROUP BY date
ORDER BY date;


-- look at total cases and death rate in aggregate and not grouped by date

SELECT SUM(new_cases) AS NewCases, SUM(new_deaths) AS NewDeaths, SUM(new_deaths)/NULLIF(SUM(new_cases), 0) *100 AS NewDeathPercent
FROM coviddeaths
WHERE continent = '' AND location NOT ILIKE '%income%' AND continent <> 'World'AND MOD(date - date '2020-01-05', 7) = 0





-- join covidvaccinations table with coviddeaths table

SELECT *
FROM covidvaccinations AS vaccs
INNER JOIN coviddeaths AS deaths
ON deaths.date = vaccs.date AND deaths.location = vaccs.location;


-- look at new vaccine accrual over time vs population

SELECT deaths.continent, deaths.location, deaths.population, deaths.date, vaccs.new_vaccinations, 
SUM(vaccs.new_vaccinations) OVER (Partition by deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated -- partition by helps restart count of new_vaccinations by location so SUM(vaccs.new_vaccinations) doesn't continue count after summing up all new vaccs by country; ORDER BY so numbers from new_vaccinations column accumulates
FROM covidvaccinations AS vaccs
INNER JOIN coviddeaths AS deaths
ON deaths.date = vaccs.date AND deaths.location = vaccs.location
WHERE deaths.continent <> ''
ORDER BY deaths.location, deaths.date;


-- need rolling percentage of people vaccinated vs population --> use CTE (Common Table Expression, or "temp table") and include in 
-- original query above

WITH PopvsVacc (continent, location, population, date, new_vaccinations, RollingPeopleVaccinated) -- needs to be in same order as SELECT statement columns below
AS (
	SELECT deaths.continent, deaths.location, deaths.population, deaths.date, vaccs.new_vaccinations, 
	SUM(vaccs.new_vaccinations) OVER (Partition by deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated -- partition by helps restart count of new_vaccinations by location so SUM(vaccs.new_vaccinations) doesn't continue count after summing up all new vaccs by country; ORDER BY so numbers from new_vaccinations column accumulates
	FROM covidvaccinations AS vaccs
	INNER JOIN coviddeaths AS deaths
	ON deaths.date = vaccs.date AND deaths.location = vaccs.location
	WHERE deaths.continent <> ''
	ORDER BY deaths.location, deaths.date)
SELECT *, (RollingPeopleVaccinated/population) * 100 AS PercentageVaccinated
FROM PopvsVacc;


-- temp table

CREATE TABLE PercentPopulationVaccinated
(
continent VARCHAR(255),
location VARCHAR (255),
date DATE,
population FLOAT,
new_vaccinations FLOAT,
RollingPeopleVaccinated FLOAT
)

INSERT INTO PercentPopulationVaccinated
(SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.new_vaccinations, -- SELECT columns need to be in same order as table created in query above
	SUM(vaccs.new_vaccinations) OVER (Partition by deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated -- partition by helps restart count of new_vaccinations by location so SUM(vaccs.new_vaccinations) doesn't continue count after summing up all new vaccs by country; ORDER BY so numbers from new_vaccinations column accumulates
	FROM covidvaccinations AS vaccs
	INNER JOIN coviddeaths AS deaths
	ON deaths.date = vaccs.date AND deaths.location = vaccs.location
	WHERE deaths.continent <> ''
	ORDER BY deaths.location, deaths.date)
	
SELECT *, (RollingPeopleVaccinated/population) * 100 AS PercentageVaccinated
FROM PercentPopulationVaccinated


-- drop table

DROP TABLE IF EXISTS PercentPopulationVaccinated


-- create view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
(SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.new_vaccinations, -- SELECT columns need to be in same order as table created in query above
	SUM(vaccs.new_vaccinations) OVER (Partition by deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated -- partition by helps restart count of new_vaccinations by location so SUM(vaccs.new_vaccinations) doesn't continue count after summing up all new vaccs by country; ORDER BY so numbers from new_vaccinations column accumulates
	FROM covidvaccinations AS vaccs
	INNER JOIN coviddeaths AS deaths
	ON deaths.date = vaccs.date AND deaths.location = vaccs.location
	WHERE deaths.continent <> ''
	ORDER BY deaths.location, deaths.date)
	

-- pull up view

SELECT *
FROM PercentPopulationVaccinated;