SELECT *
FROM [Portfolio Project]..CovidDeaths$
ORDER BY 3,4

-- Select Data that we are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths$
ORDER BY 1,2


-- Looking at the Total Cases vs Total Deaths
-- Shows the likelhood of dying if you contract Covid in your country 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)  AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths$
WHERE location LIKE '%states%'
ORDER BY 1,2

-- Looking at the Total Cases vs Population 
-- Shows what percentage of popualtion got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths$
WHERE location like '%Pakistan%'
ORDER BY 1,2

-- Shows what percentage of continent got covid 


SELECT continent, (SUM(total_cases) / SUM(population))*100 AS PercentContinentInfected
FROM [Portfolio Project]..CovidDeaths$
GROUP BY continent
ORDER BY PercentContinentInfected DESC;

-- Looking at countires with highest infection rates compared to population 

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths$
Group By location, population
ORDER BY PercentPopulationInfected desc

-- Looking at continents with highest infection rates compared to population 


SELECT continent, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths$
GROUP BY continent
ORDER BY PercentPopulationInfected DESC;

-- GLOBAL NUMBERS 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)  AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths$
WHERE location LIKE '%states%'
ORDER BY 1,2

-- Looking at total population vs vaccinations 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac 
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
