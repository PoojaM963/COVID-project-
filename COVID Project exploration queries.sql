-- 1. Select data to be used
SELECT continent, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- 2. Total Cases vs Total Deaths
-- there is an error, total_cases and total_deaths are nvarchars, so divide operator couldn't be used. 
-- Need to convert these values into float to perform these calculations and produce a percentage
-- using the DESIGN tab, I changed the data type from nvarchar to float, I use CAST 
SELECT continent, date, total_cases, total_deaths, CAST(total_deaths as float)/CAST(total_cases AS float)*100 AS PercentageDeath
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2
-- this shows the likelihood of deaths if you contract COVID in your country

-- 3. Total Cases Vs Population - shows percentage population who got COVID
SELECT continent, date, total_cases, population, CAST(total_cases AS float)/population*100 AS PercentagePopulation
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- 4. Countries with highest infection rates compared to Population
SELECT continent, population, MAX(total_cases) AS HighestInfectionCount, MAX(CAST(total_cases AS float))/population*100 AS PercentagePopulationInfected
FROM CovidDeaths
WHERE continent	IS NOT NULL
GROUP BY continent, population
ORDER BY PercentagePopulationInfected DESC

-- 5. Showing countries with Highest Death Count per Population
-- output for locations include continents which it shouldn't so will add WHERE statement and NOT NULL.
SELECT continent, MAX(CAST(total_deaths AS float)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, population
ORDER BY TotalDeathCount DESC
 
-- 6. Break down by Continent
-- Continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- 7. Global Numbers to calculate global death percentage
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))
/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL	
ORDER BY 1, 2

-- 8. Join CovidDeaths table and CovidVaccination table
-- Total Population vs Vaccinations, how many are vaccinated on a global scale?
SELECT cdea.continent, cdea.location, cdea.date, cdea.population, cvac.new_vaccinations,
SUM(CAST(cvac.new_vaccinations AS float)) OVER (PARTITION BY cdea.location ORDER BY cdea.location, cdea.date) 
AS RollingPeopleVaccinated
FROM CovidDeaths cdea
JOIN CovidVaccinations cvac
	ON cdea.location = cvac.location
	AND cdea.date = cvac.date
	WHERE cdea.continent IS NOT NULL
ORDER BY 2,3

-- 9. Create CTW

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT cdea.continent, cdea.location, cdea.date, cdea.population, cvac.new_vaccinations,
SUM(CAST(cvac.new_vaccinations AS float)) OVER (PARTITION BY cdea.location ORDER BY cdea.location, cdea.date) 
AS RollingPeopleVaccinated
FROM CovidDeaths cdea
JOIN CovidVaccinations cvac
	ON cdea.location = cvac.location
	AND cdea.date = cvac.date
	WHERE cdea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

-- 10. Create a Temp Table
DROP TABLE IF EXISTS #PercentagePopulationVaccinated
 CREATE TABLE #PercentagePopulationVaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

INSERT INTO #PercentagePopulationVaccinated
SELECT cdea.continent, cdea.location, cdea.date, cdea.population, cvac.new_vaccinations,
SUM(CAST(cvac.new_vaccinations AS float)) OVER (PARTITION BY cdea.location ORDER BY cdea.location, cdea.date) 
AS RollingPeopleVaccinated
FROM CovidDeaths cdea
JOIN CovidVaccinations cvac
	ON cdea.location = cvac.location
	AND cdea.date = cvac.date
SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentagePopulationVaccinated

-- 11. Creating view to store data for future visualisations
CREATE VIEW PercentagePopulationVaccinated AS
SELECT cdea.continent, cdea.location, cdea.date, cdea.population, cvac.new_vaccinations,
SUM(CAST(cvac.new_vaccinations AS float)) OVER (PARTITION BY cdea.location ORDER BY cdea.location, cdea.date) 
AS RollingPeopleVaccinated
FROM CovidDeaths cdea
JOIN CovidVaccinations cvac
	ON cdea.location = cvac.location
	AND cdea.date = cvac.date
where cdea.continent IS NOT NULL

SELECT *
FROM PercentagePopulationVaccinated






