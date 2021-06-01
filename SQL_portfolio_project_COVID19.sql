SELECT * FROM 
PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4 

SELECT * FROM 
PortfolioProject..CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4 

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- TOTAL CASES VS TOTAL DEATHS
SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%Vietnam%'
AND continent IS NOT NULL
ORDER BY 1,2 

-- TOTAL CASES VS Total population
-- Shows what percentage of people got covid
SELECT Location, Date, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE Location like '%Vietnam%'
AND continent IS NOT NULL
ORDER BY 1,2 

--Coutries with the highest infection rate compared to population 
SELECT Location, population, MAX(total_cases), MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%Vietnam%' 
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC

--Showing Countries with highest death count per population
SELECT Location, MAX(CAST(Total_deaths AS int)) AS TotalDeathCounts
from PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCounts DESC

-- Breaking Things down by continent
-- Showing Continents with the highest death count per population
SELECT continent, MAX(CAST(Total_deaths AS int)) AS TotalDeathCounts
from PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCounts DESC

--Global Numbers

SELECT  SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths , (SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

--Total population vs vaccinations
SELECT deaths.location, deaths.continent, deaths.date, deaths.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS int)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.Date) AS RollingPeopleVaccinated
FROM 
PortfolioProject..CovidDeaths deaths
JOIN PortfolioProject..CovidVaccinations vacc
	ON	deaths.location = vacc.location
	AND deaths.date =vacc.date
WHERE deaths.continent IS NOT NULL
ORDER BY 1,3

--Use CTE

WITH PopvsVacc (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated) AS
(
SELECT deaths.location, deaths.continent, deaths.date, deaths.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS int)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.Date) AS RollingPeopleVaccinated
FROM 
PortfolioProject..CovidDeaths deaths
JOIN PortfolioProject..CovidVaccinations vacc
	ON	deaths.location = vacc.location
	and deaths.date =vacc.date
WHERE deaths.continent IS NOT NULL
--ORDER BY 1,3
)

SELECT *, (RollingPeopleVaccinated/Population) *100
FROM PopvsVacc

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated --I added this to be able to make changes in the table over and over angain 
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),	
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
NewVaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT deaths.location, deaths.continent, deaths.date, deaths.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS int)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.Date) AS RollingPeopleVaccinated
FROM 
PortfolioProject..CovidDeaths deaths
JOIN PortfolioProject..CovidVaccinations vacc
	ON	deaths.location = vacc.location
	and deaths.date =vacc.date
WHERE deaths.continent IS NOT NULL
--ORDER BY 1,3

SELECT *, (RollingPeopleVaccinated/Population) *100
FROM #PercentPopulationVaccinated

-- VIEWS

create view PercentPopulationVaccinated AS
SELECT deaths.location, deaths.continent, deaths.date, deaths.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS int)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.Date) AS RollingPeopleVaccinated
FROM 
PortfolioProject..CovidDeaths deaths
JOIN PortfolioProject..CovidVaccinations vacc
	ON	deaths.location = vacc.location
	and deaths.date =vacc.date
WHERE deaths.continent IS NOT NULL
--GO 
--ORDER BY 1,3 --The ORDER BY claus is invalid in views
-- Now I am able to query the data using this view
SELECT * FROM PercentPopulationVaccinated

