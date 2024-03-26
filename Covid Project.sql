SELECT Location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

select * from CovidDeaths where location LIKE 'United States%' order by 3,4 

-- Total cases vs total deaths
select location, date, total_cases, total_deaths, (CAST(total_deaths AS float)/CAST(total_cases AS float))*100  as death_percentage
from CovidDeaths
where location LIKE 'United States%'
order by 1,2

-- country with highest infection rate compared to the population
select location, population, MAX(total_cases) as HighestInfectionCount, 
MAX((CAST(total_cases AS float)/CAST(population AS float)))*100  as PercentPopulationInfected
FROM CovidDeaths
GROUP BY location, population
order by PercentPopulationInfected DESC

--BY CONTINENT 

SELECT continent, MAX(Total_deaths) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
Group by continent 
order by TotalDeathCount DESC


-- country with highest death COUNT
select location, MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY LOCATION
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS -- cases across the world by date
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths,
SUM(CAST(new_deaths AS FLOAT))/SUM(CAST(new_cases AS FLOAT))*100 as death_percentage
FROM CovidDeaths
where continent is not null
and new_cases >0
GROUP BY date
order by 1,2

--Joining tables
SELECT * FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date


--Total population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.Location, dea.date) 
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
ORDER BY 2,3

--Using CTE
With PopvsVac 
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.Location, dea.date) 
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/CAST(Population as float))*100 from PopvsVac

-- TEMP TABLE
DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated (
Continent nvarchar(255), 
location nvarchar(255),
date datetime,
population numeric, 
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)
INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.Location, dea.date) 
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100 
from #PercentPopulationVaccinated

-- create view to store data for later visualization
Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.Location, dea.date) 
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null

SELECT * from PercentPopulationVaccinated