/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM [Portfolio Project]..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4

SELECT *
FROM [Portfolio Project]..CovidVaccinations
ORDER BY 3,4

--Selecting Data that we are going to be used

SELECT Location,date,total_cases,new_cases,total_deaths,population
FROM [Portfolio Project]..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2

--Looking at total cases vs total Deaths
--Shows Likelihood of dying if you contact covid in your country
SELECT Location,date,total_cases,total_deaths,(total_deaths / total_cases)*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location LIKE '%states%'
and continent is not NULL
ORDER BY 1,2

--Looking at Total Cases vs Population

SELECT Location,date,total_cases,population,( total_cases/population)*100 AS PercentagePopulationisAffected
FROM [Portfolio Project]..CovidDeaths
WHERE continent is NOT NULL
--WHERE location LIKE '%states%'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate Compared to Population


SELECT Location,population,MAX(total_cases) AS HighestInfectionCount,MAX(( total_cases/population))*100 AS PercentagePopulationInfected
FROM [Portfolio Project]..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is NOT NULL
GROUP BY location,population
ORDER BY PercentagePopulationInfected desc

--LET'S BREAK THIS THINGS DOWN BY CONTINENT

SELECT continent,MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
--WHERE location LIKE '%states%
WHERE continent is not  NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

--Sharing Countries With Highest Death Count By Population 
SELECT Location,MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
--WHERE location LIKE '%states%
WHERE continent is NOT NULL
GROUP BY location,population
ORDER BY TotalDeathCount desc

--Showing continents with highest death count per population

SELECT continent,MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
--WHERE location LIKE '%states%
WHERE continent is not  NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

--GLOBAL NUMBERS
SELECT SUM(new_cases) AS total_cases,SUM(cast(new_deaths as int)) AS total_deaths,SUM(cast(new_deaths as int))/SUM(cast(new_deaths as int))*100 AS Deathpercentage
FROM [Portfolio Project]..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not NULL
--GROUP BY date
ORDER BY 1,2

--Looking at Total Population Population VS Vaccination

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths as dea
JOIN [Portfolio Project]..CovidVaccinations as vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Using CTEs

With PopvsVac(continent,location,date,population, New_vaccinations, RollingpeopleVaccinated)
AS
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths as dea
JOIN [Portfolio Project]..CovidVaccinations as vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT*,(RollingpeopleVaccinated / population)*100
FROM PopvsVac

--TEMP Table
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths as dea
JOIN [Portfolio Project]..CovidVaccinations as vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

SELECT*,(RollingpeopleVaccinated / population)*100
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

CREATE View PercentPeopleVaccinated AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths as dea
JOIN [Portfolio Project]..CovidVaccinations as vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

SELECT*
FROM PercentPeopleVaccinated
