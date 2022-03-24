-- Tickluck
-- All rights reserved

-- Check for the tables contents
SELECT *
FROM [Covid-19 2020]..CovidDeathes_2020

SELECT *
FROM [Covid-19 2020]..CovidVaccinations_2020
---------------------------------------------
-- CovidDeathes_2020 Exploration 
BEGIN 
-- Select Data
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Covid-19 2020]..CovidDeathes_2020
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Likelyhood of Dying after Contacting Covid-19
SELECT location, date, total_cases, total_deaths, ( CONVERT(DECIMAL, total_deaths)/CONVERT(DECIMAL, total_cases) )*100 AS DeathPercentage
FROM [Covid-19 2020]..CovidDeathes_2020
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Total Cases over Population
SELECT location, date, population, total_cases, ( CONVERT(DECIMAL, total_cases)/CONVERT(DECIMAL, population) )*100 AS InfectedPercentage
FROM [Covid-19 2020]..CovidDeathes_2020
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Countries with the Highest Rate of Infection spread over Population
SELECT location, population, MAX(total_cases) AS HighestInfectionRate, MAX(( CONVERT(DECIMAL, total_cases)/CONVERT(DECIMAL, population) ))*100 AS InfectedPercentage
FROM [Covid-19 2020]..CovidDeathes_2020
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC

-- Countries with the Highest Death Rate over Population
SELECT location, population, MAX(total_deaths) AS HighestDeathRate, MAX(( CONVERT(DECIMAL, total_deaths)/CONVERT(DECIMAL, population) ))*100 AS DeathPercentage
FROM [Covid-19 2020]..CovidDeathes_2020
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC

-- LETS BREAK THINGS DOWN BY CONTINENT
SELECT location, MAX(CONVERT(DECIMAL,total_deaths)) AS TotalDeathRate
FROM [Covid-19 2020]..CovidDeathes_2020
WHERE continent IS NULL
GROUP BY location
ORDER BY 2 DESC

-- GLOBAL NUMBERS

-- Global death Rates Around the World by Date
SELECT date, SUM(CONVERT(DECIMAL, new_cases)) as Total_cases, 
SUM(CONVERT(DECIMAL, new_deaths)) as Total_deaths,SUM(CONVERT(DECIMAL, new_deaths)) / SUM(CONVERT(DECIMAL, new_cases)) as DeathPercentage
FROM [Covid-19 2020]..CovidDeathes_2020
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Global death Rates Around the World since 2020 till 2022
SELECT SUM(CONVERT(DECIMAL, new_cases)) as Total_cases, 
SUM(CONVERT(DECIMAL, new_deaths)) as Total_deaths,SUM(CONVERT(DECIMAL, new_deaths)) /SUM(CONVERT(DECIMAL, new_cases)) as DeathPercentage
FROM [Covid-19 2020]..CovidDeathes_2020
WHERE continent IS NOT NULL
ORDER BY 1,2
END
---------------------------------------------
-- CovidVaccinations_2020 Exploration 
BEGIN 
-- Total Population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(DECIMAL, vac.new_vaccinations)) 
		OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as Total_vaccinations
FROM [Covid-19 2020]..CovidDeathes_2020 AS dea
	JOIN [Covid-19 2020]..CovidVaccinations_2020 AS vac
		ON dea.date = vac.date AND dea.location = vac.location
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations,Total_vaccinations) AS (
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(DECIMAL, vac.new_vaccinations)) 
		OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
FROM [Covid-19 2020]..CovidDeathes_2020 AS dea
	JOIN [Covid-19 2020]..CovidVaccinations_2020 AS vac
		ON dea.date = vac.date AND dea.location = vac.location
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *, Total_vaccinations/Population * 100 AS VaccinationPercentage
FROM PopvsVac 

-- USE TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	Total_vaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(DECIMAL, vac.new_vaccinations)) 
		OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
FROM [Covid-19 2020]..CovidDeathes_2020 AS dea
	JOIN [Covid-19 2020]..CovidVaccinations_2020 AS vac
		ON dea.date = vac.date AND dea.location = vac.location
WHERE dea.continent IS NOT NULL

SELECT *, Total_vaccinations/Population * 100 AS VaccinationPercentage
FROM #PercentPopulationVaccinated
END
---------------------------------------------
-- Views for future Visualizations 
BEGIN 
CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(DECIMAL, vac.new_vaccinations)) 
		OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Total_Vaccinations
FROM [Covid-19 2020]..CovidDeathes_2020 AS dea
	JOIN [Covid-19 2020]..CovidVaccinations_2020 AS vac
		ON dea.date = vac.date AND dea.location = vac.location
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated
ORDER BY location, date
END
---------------------------------------------