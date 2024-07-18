/*
Covid 19 Data Exploration 
*/

SELECT *
FROM coviddeaths;

SELECT *
FROM covidvaccinations;

SELECT location, `date`, population, total_cases, new_cases, total_deaths, new_deaths
FROM coviddeaths;

UPDATE coviddeaths
SET total_deaths = NULL
WHERE total_deaths = '';

SELECT location, `date`, population, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM coviddeaths;

SELECT location, `date`, population, total_cases, (total_cases/population)*100 AS PercentOfPopulationInfected
FROM coviddeaths
WHERE location LIKE "Greece";

SELECT location, `date`, population, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE location LIKE "Greece";

WITH GreeceMaxDeathRateMonth AS
(
SELECT location, `date`, population, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE location LIKE "Greece"
)
SELECT SUBSTRING(`date`,3,8) AS `month`, total_cases, total_deaths, DeathPercentage
FROM GreeceMaxDeathRateMonth
ORDER BY DeathPercentage DESC;

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, (MAX(total_cases)/population)*100 AS TotalPercentOfInfectionPerPop,
SUM(new_deaths) AS HighestNumberOfDeaths,  (SUM(new_deaths)/MAX(total_cases))*100 AS TotalDeathPercentPerCases
FROM coviddeaths
GROUP BY location, population
ORDER BY TotalPercentOfInfectionPerPop DESC;

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, (MAX(total_cases)/population)*100 AS TotalPercentOfInfectionPerPop,
SUM(new_deaths) AS HighestNumberOfDeaths,  (SUM(new_deaths)/MAX(total_cases))*100 AS TotalDeathPercentPerCases
FROM coviddeaths
WHERE location LIKE "Greece"
GROUP BY location, population
ORDER BY TotalDeathPercentPerCases DESC;

UPDATE coviddeaths
SET continent = NULL
WHERE continent = '';

SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM coviddeaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY TotalDeathCount DESC;

SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM coviddeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

SELECT continent, location, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM coviddeaths
WHERE continent = 'Europe'
GROUP BY continent, location
ORDER BY TotalDeathCount DESC;

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL;

UPDATE covidvaccinations
SET new_vaccinations = NULL
WHERE new_vaccinations = '';

SELECT `date`, STR_TO_DATE(`date`, '%d/%m/%Y')
FROM coviddeaths;

UPDATE coviddeaths
SET `date` = STR_TO_DATE(`date`, '%d/%m/%Y');

UPDATE covidvaccinations
SET `date` = STR_TO_DATE(`date`, '%d/%m/%Y');

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationsPerLocation
FROM coviddeaths AS dea
JOIN covidvaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;

WITH VaccinationsPerPop_cte AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationsPerLocation
FROM coviddeaths AS dea
JOIN covidvaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date
)
SELECT*, (RollingVaccinationsPerLocation/population)*100 AS VacsPerPop
FROM VaccinationsPerPop_cte
GROUP BY continent, location, date, population, new_vaccinations;

WITH VaccinationsPerPop_cte AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationsPerLocation
FROM coviddeaths AS dea
JOIN covidvaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date
), RollingVaccinationsPerLocation_cte AS
(
SELECT *, (RollingVaccinationsPerLocation/population)*100 AS VacsPerPop
FROM VaccinationsPerPop_cte
GROUP BY continent, location, date, population, new_vaccinations
)
SELECT continent, location, population, MAX(VacsPerPop)
FROM RollingVaccinationsPerLocation_cte
GROUP BY continent, location, population
ORDER BY continent;

DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
);

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationsPerLocation
FROM coviddeaths AS dea
JOIN covidvaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT*
FROM PercentPopulationVaccinated;

SELECT *, (RollingPeopleVaccinated/population)*100 AS VacsPerPop
FROM PercentPopulationVaccinated
GROUP BY continent, location, date, population, new_vaccinations, RollingPeopleVaccinated;

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationsPerLocation
FROM coviddeaths AS dea
JOIN covidvaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL; 


