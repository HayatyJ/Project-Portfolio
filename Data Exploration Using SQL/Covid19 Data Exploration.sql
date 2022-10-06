Select *
From PortfolioProject..CovidDeaths
--Where continent is not null
Order By 3,4

Select *
From PortfolioProject..CovidVaccinations
Order By 3,4

--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at total cases vs total death
--Shows the likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*(100) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like 'Malaysia'
ORDER BY 1,2

--Looking at total cases vs population
--Shows the percentage of population got covid

SELECT location, date, total_cases, population, (total_cases/population)*(100) AS PopulationPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like 'Malaysia'
ORDER BY 1,2

--Looking at Country with Highest Infection rate compare to population 
--Malaysia at 105th place with 1.26% population infected

SELECT location, MAX(total_cases) AS HighestInfectionCount, 
population, MAX((total_cases/population))*(100) AS PopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PopulationInfected DESC

--Showing countries with highest death count per population

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

SELECT location, SUM(CAST(new_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBER

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as INT)) AS total_deaths, 
SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as INT)) AS total_deaths, 
SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2



--JOINING COVID DEATH AND COVID VACCINATION
--Looking at Total Population VS Vaccination

SELECT A.continent, A.location, A.date, A.population, B.new_vaccinations
FROM PortfolioProject..CovidDeaths A
JOIN PortfolioProject..CovidVaccinations B
	ON A.location = B.location
	AND A.date = B.date
WHERE A.continent is not null
ORDER BY 2,3

SELECT A.continent, A.location, A.date, A.population, B.new_vaccinations,
SUM(CONVERT(INT, B.new_vaccinations)) OVER (PARTITION BY A.location ORDER BY A.location, A.date) AS Total_Vaccination
FROM PortfolioProject..CovidDeaths A
JOIN PortfolioProject..CovidVaccinations B
	ON A.location = B.location
	AND A.date = B.date
WHERE A.continent is not null
ORDER BY 2,3

--USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, Total_Vaccination) AS
(
SELECT A.continent, A.location, A.date, A.population, B.new_vaccinations,
SUM(CONVERT(INT, B.new_vaccinations)) OVER (PARTITION BY A.location ORDER BY A.location, A.date) AS Total_Vaccination
FROM PortfolioProject..CovidDeaths A
JOIN PortfolioProject..CovidVaccinations B
	ON A.location = B.location
	AND A.date = B.date
WHERE A.continent is not null
)
SELECT *, (Total_Vaccination/population)*(100) AS VaccinationPercentage
FROM PopvsVac

--TEMP TABLE

--DROP TABLE IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
Total_Vaccination numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT A.continent, A.location, A.date, A.population, B.new_vaccinations,
SUM(CONVERT(INT, B.new_vaccinations)) OVER (PARTITION BY A.location ORDER BY A.location, A.date) AS Total_Vaccination
FROM PortfolioProject..CovidDeaths A
JOIN PortfolioProject..CovidVaccinations B
	ON A.location = B.location
	AND A.date = B.date
WHERE A. continent IS NOT NULL

SELECT *, (Total_Vaccination/population)*(100) AS VaccinationPercentage
FROM #PercentPopulationVaccinated

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated AS
SELECT A.continent, A.location, A.date, A.population, B.new_vaccinations,
SUM(CONVERT(INT, B.new_vaccinations)) OVER (PARTITION BY A.location ORDER BY A.location, A.date) AS Total_Vaccination
FROM PortfolioProject..CovidDeaths A
JOIN PortfolioProject..CovidVaccinations B
	ON A.location = B.location
	AND A.date = B.date
WHERE A. continent IS NOT NULL
--ORDER BY 2,3

--WORKING TABLE
SELECT *
FROM PercentPopulationVaccinated
