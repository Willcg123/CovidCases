SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
ORDER BY 3,4

-- Select Data we are using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
ORDER BY 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows percent chance of dying if you contract covid in USA

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%', continent is not null
ORDER BY 1, 2


-- Looking at Total Cases in USA vs USA Population 
-- Percentage of US population with covid 

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentCases 
FROM PortfolioProject..CovidDeaths
WHERE location like '%states' and continent is not null
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population)) * 100 AS 
	PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
GROUP BY location, population 
ORDER BY PercentPopulationInfected DESC

-- Total Deaths by Continent
SELECT location, MAX(CAST(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Showing Countries with Highest Death Count per Population
SELECT location, population, MAX(cast(Total_Deaths AS INT)) AS TotalDeathCount, MAX(cast(Total_Deaths AS INT)/population) AS 
	HighestPercentDeath
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population 
ORDER BY HighestPercentDeath DESC

-- Percent population infected by date
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc

-- Contiental Death Data
SELECT location, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null 
and location not in ('World', 'European Union', 'International', 'Upper middle income', 'High income', 'Lower middle income', 
'low income')
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Percent of population infected
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


-- Global numbers

SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercent
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercent
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations

SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) 
	AS TotalVacToDate
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vac
	ON death.location = vac.location 
	and death.date = vac.date
WHERE death.continent is not null 
ORDER BY 2,3


-- Use CTE

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, TotalVacToDate)
AS (
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) 
	AS TotalVacToDate
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vac
	ON death.location = vac.location 
	and death.date = vac.date
WHERE death.continent is not null 
)
SELECT *, (TotalVacToDate/Population)*100
FROM PopVsVac



-- Temp Table

DROP TABLE IF exists #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_Vaccinations numeric,
TotalVacToDate numeric, 
)

INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) 
	AS TotalVacToDate
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vac
	ON death.location = vac.location 
	and death.date = vac.date
WHERE death.continent is not null 

SELECT *, (TotalVacToDate/Population)*100 AS PercentVaccinated
FROM #PercentPopulationVaccinated



-- Creating Veiw for visualizations

DROP View if exists PercentPopulationVaccinated

CREATE VIEW PercentPopulationVaccinated AS 
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) 
	AS TotalVacToDate
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vac
	ON death.location = vac.location 
	and death.date = vac.date
WHERE death.continent is not null 




