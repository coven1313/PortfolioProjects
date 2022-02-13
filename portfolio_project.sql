SELECT *
FROM [PortfolioProject].dbo.CovidVaccinations
ORDER BY 3, 4

SELECT *
FROM [PortfolioProject].dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [PortfolioProject].dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- total cases VS total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS death_percentage
FROM [PortfolioProject].dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--- BELARUS VS SWEDEN

-- total cases VS total deaths in Belarus
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS death_percentage_bel
FROM [PortfolioProject].dbo.CovidDeaths
WHERE location = 'Belarus' 
ORDER BY 1,2


-- total cases VS total deaths in Sweden
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS death_percentage_bel
FROM [PortfolioProject].dbo.CovidDeaths
WHERE location = 'Sweden' 
ORDER BY 1,2

--total cases VS population in Belarus
SELECT location, date, total_cases, population, (total_cases / population)*100 AS infected_percentage_bel
FROM [PortfolioProject].dbo.CovidDeaths
WHERE location = 'Belarus'
ORDER BY 1,2

--total cases VS population in Sweden
SELECT location, date, total_cases, population, (total_cases / population)*100 AS infected_percentage_bel
FROM [PortfolioProject].dbo.CovidDeaths
WHERE location = 'Sweden'
ORDER BY 1,2

--total deaths VS population
SELECT location, date, total_deaths, population, (total_deaths / population)*100 AS death_percentage_pop_bel
FROM [PortfolioProject].dbo.CovidDeaths
WHERE location = 'Belarus'
ORDER BY 1,2

--total deaths VS population
SELECT location, date, total_deaths, population, (total_deaths / population)*100 AS death_percentage_pop_bel
FROM [PortfolioProject].dbo.CovidDeaths
WHERE location = 'Sweden'
ORDER BY 1,2


-- countries with highest infection rates
SELECT location, population, MAX(total_cases) AS highest_inf_count, MAX((total_cases / population))*100 AS infected_percentage
FROM [PortfolioProject].dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY infected_percentage DESC


-- countries with highest death count
SELECT location, MAX(CAST(total_deaths AS int)) AS total_death_count
FROM [PortfolioProject].dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location 
ORDER BY total_death_count DESC


-- breaking down by continent

-- continents with highest deat count
SELECT continent, MAX(CAST(total_deaths AS int)) AS total_death_count
FROM [PortfolioProject].dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY total_death_count DESC


-- global numbers
SELECT date, SUM(new_cases) AS new_cases_global, SUM(CAST(new_deaths AS int)) AS new_deaths_global, SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100 AS death_percentage
FROM [PortfolioProject].dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) AS new_cases_global, SUM(CAST(new_deaths AS int)) AS new_deaths_global, SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100 AS death_percentage
FROM [PortfolioProject].dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- VACCINATIONS

-- number of people vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vacc
FROM [PortfolioProject].dbo.CovidDeaths AS dea
Join [PortfolioProject].dbo.CovidVaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3

-- CTE

WITH pop_vs_vac(continent, location, date, population, new_vaccinations, rolling_people_vacc) AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vacc
FROM [PortfolioProject].dbo.CovidDeaths AS dea
Join [PortfolioProject].dbo.CovidVaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL)
SELECT *, (rolling_people_vacc/population) *100 AS people_vac_perc
FROM pop_vs_vac

-- TempTable

CREATE TABLE #percent_pop_vac
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vacc numeric
)
INSERT INTO #percent_pop_vac
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vacc
FROM [PortfolioProject].dbo.CovidDeaths AS dea
Join [PortfolioProject].dbo.CovidVaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
SELECT *, (rolling_people_vacc/population) *100 AS num_people_vac
FROM #percent_pop_vac


-- creating view to store data for viz

Create View percent_pop_vac AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vacc
FROM [PortfolioProject].dbo.CovidDeaths AS dea
Join [PortfolioProject].dbo.CovidVaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM percent_pop_vac
