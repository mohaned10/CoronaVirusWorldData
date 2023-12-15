SELECT *
FROM [dbo].[owid-covid-data(edited)]
-- select data fails due to space

-- SELECT DATA THAT WE ARE GOING TOO BE USING 
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [dbo].[owid-covid-data(edited)]
order by 1,2

-- looking at total cases vs total deaths (percentage)

-- SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage  -- to find  the percentage
-- FROM [dbo].[owid-covid-data(edited)]
-- WHERE Location LIKE '%states%'
-- order by 1,2

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage  -- to find  the percentage
FROM [dbo].[owid-covid-data(edited)]
-- WHERE Location LIKE '%states%'
WHERE total_cases IS NOT NULL AND total_deaths is not NULL
order by 1,2
-- the above query is for exploration purposes


-- Looking at the total cases vs population
-- show us the InfectedPercentage
SELECT Location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage  -- to find  the percentage
FROM [dbo].[owid-covid-data(edited)]
WHERE Location LIKE '%states%' OR total_cases IS NOT NULL AND total_deaths is not NULL -- ADDED THIS SYNTAX SINCE WE SAW A LOT OF NULL VALUES
order by 1,2


-- what countries  have the highest infection rates?
SELECT Location, population, MAX(total_cases) as HighestInfectionRate, MAX(total_cases/population)*100 as InfectionPercentage  -- to find  the percentage
FROM [dbo].[owid-covid-data(edited)]
-- WHERE Location LIKE '%states%'
GROUP BY Location, population
order by InfectionPercentage DESC -- shoow us the highest infection percentage

-- showing the countries with the highest death count per population
SELECT Location, population, MAX(total_deaths) as TotalDeath, MAX(total_deaths/population)*100 as DeathPercentage  -- to find  the percentage
FROM [dbo].[owid-covid-data(edited)]
GROUP BY Location, population
order by DeathPercentage DESC

-- showing the highest death count per country
SELECT Location, MAX(total_deaths) as TotalDeath
FROM [dbo].[owid-covid-data(edited)]
-- just a pop quiz --  WHERE total_deaths > '1000000'
GROUP BY Location, population
order by TotalDeath DESC


-- 
SELECT *
FROM [dbo].[owid-covid-data(edited)]
WHERE continent is not NULL -- to remove asia, europe and so on and so forth
order by 3,4

SELECT Location, MAX(total_deaths) as TotalDeath
FROM [dbo].[owid-covid-data(edited)]
-- just a pop quiz --  WHERE total_deaths > '1000000'
WHERE continent is not NULL -- to remove asia, europe and so on and so forth
GROUP BY Location
order by TotalDeath DESC



-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(total_deaths) as TotalDeath
FROM [dbo].[owid-covid-data(edited)]
-- just a pop quiz --  WHERE total_deaths > '1000000'
WHERE continent is not NULL -- to remove asia, europe and so on and so forth
GROUP BY continent
order by TotalDeath DESC


-- SHOWING DEATH COUNT AND AND CASE COUNT BY  DATE
SELECT date, SUM(new_cases), SUM(new_deaths) as DeathPercentage --total_deaths, total_cases, (total_deaths/total_cases)*100 as DeathPercentage
FROM [dbo].[owid-covid-data(edited)]
-- just a pop quiz --  WHERE total_deaths > '1000000'
WHERE continent is not NULL -- to remove asia, europe and so on and so forth
GROUP BY date
order by 1,2 







SELECT new_cases
FROM [dbo].[owid-covid-data(edited)]
ORDER BY new_cases ASC

SELECT new_deaths, date
FROM [dbo].[owid-covid-data(edited)]
WHERE new_deaths > 0
ORDER BY new_deaths ASC 


-- EXAMPLE OF THE TROUBLE WE  PUT  OURSELVES INTO BY DIRECTLY DEVIDING AND NOT ACOUNTING FOR THE ZERO DIVISION ERROR
SELECT date, SUM(new_cases), SUM(cast(new_deaths as int)), (SUM(cast(new_deaths as int))/SUM(New_cases))*100 as DeathPercentage --total_deaths, total_cases, (total_deaths/total_cases)*100 as DeathPercentage
FROM [dbo].[owid-covid-data(edited)]
-- just a pop quiz --  WHERE total_deaths > '1000000'
WHERE continent is not NULL OR new_deaths > '0' OR new_cases is not NULL -- to remove asia, europe and so on and so forth
GROUP BY date
order by 1,2 



-- SHOWING DEATH PERCENTAGFE WITH DEATH COUNT AND AND CASE COUNT BY  DATE (HAD TO USE BARD FOR SUMMING  A CASE INSTEAD OF DIRECTING SUMMING A COLUMN BECAUSE  IT RETURNED  AN ERROR WHEN DEVIDING BY ZERO)
SELECT date, SUM(CASE WHEN new_cases > 0 THEN new_cases END) AS TotalCases,
SUM(CASE WHEN new_deaths > 0 AND new_cases > 0 THEN new_deaths END) AS TotalDeaths,
(SUM(CASE WHEN new_deaths > 0 AND new_cases > 0 THEN new_deaths END)/SUM(CASE WHEN new_cases > 0 THEN new_cases END))*100 as DeathPercentage
FROM [dbo].[owid-covid-data(edited)]
WHERE continent is not NULL AND (new_deaths > '0' AND new_cases > '0')
GROUP BY date
order by 1,2 


SELECT continent, location, date, population
FROM [dbo].[owid-covid-data(edited)]


-- SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
-- FROM [dbo].[owid-covid-data(edited)] dea
-- JOIN [dbo].[owid-covid-data] vac 
--     ON dea.location = vac location
--     and dea.date = vac.date
-- WHERE  dea.continent is not null
-- ORDER BY 2,3


-- https://www.youtube.com/watch?v=qfyynHBFOsM&list=PLUaB-1hjhk8FE_XZ87vPPSfHqb6OcM0cF&index=22
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,
--  (RollingPeopleVaccinated/population)*100
FROM [dbo].[owid-covid-data(edited)] dea
JOIN [dbo].[owid-covid-data] vac 
    ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- using a cte TO GET A ROLLING VACCIINATION COUNT
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--  (RollingPeopleVaccinated/population)*100
FROM [dbo].[owid-covid-data(edited)] dea
JOIN [dbo].[owid-covid-data] vac 
    ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac




-- TEMP TABLE 

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
    Continent nvarchar(255)
    Location nvarchar(255)
    date DATETIME
    population NUMERIC
    New_Vaccination NUMERIC
    RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--  (RollingPeopleVaccinated/population)*100
FROM [dbo].[owid-covid-data(edited)] dea
JOIN [dbo].[owid-covid-data] vac 
    ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated



-- CREATING VIEW FOR STORING DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--  (RollingPeopleVaccinated/population)*100
FROM [dbo].[owid-covid-data(edited)] dea
JOIN [dbo].[owid-covid-data] vac 
    ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated








-- ALTER TABLE [dbo].[owid-covid-data(edited)] DROP COLUMN
-- [excess_mortality_cumulative_per_million],
-- [excess_mortality],
-- [excess_mortality_cumulative],
-- [excess_mortality_cumulative_absolute],
-- [human_development_index],
-- [life_expectancy],
-- [hospital_beds_per_thousand],
-- [handwashing_facilities],
-- [male_smokers],
-- [female_smokers],
-- [diabetes_prevalence],
-- [cardiovasc_death_rate],
-- [extreme_poverty],
-- [gdp_per_capita],
-- [aged_70_older],
-- [aged_65_older],
-- [median_age],
-- [population_density],
-- [stringency_index],
-- [new_people_vaccinated_smoothed_per_hundred],
-- [new_people_vaccinated_smoothed],
-- [new_vaccinations_smoothed_per_million],
-- [total_boosters_per_hundred],
-- [people_fully_vaccinated_per_hundred],
-- [people_vaccinated_per_hundred],
-- [total_vaccinations_per_hundred],
-- [new_vaccinations_smoothed],
-- [new_vaccinations],
-- [total_boosters],
-- [people_fully_vaccinated],
-- [people_vaccinated],
-- [total_vaccinations],
-- [tests_units],
-- [tests_per_case],
-- [positive_rate],
-- [new_tests_smoothed_per_thousand],
-- [new_tests_smoothed],
-- [new_tests_per_thousand],
-- [total_tests_per_thousand],
-- [new_tests]
-- 