Select *
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject.dbo.CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

select location, date, total_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dyiing if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where location like '%india'
order by 1,2


-- Looking at the total cases Vs Population
-- shows what percentage of population got covid
select location, date,population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
-- Where location like '%india'
order by 1,2


-- Looking at countries with hightes infection rate compared to population
select location,population, max(total_cases) as highestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
Group by location,population
order by 4 desc


-- Showing countries with highest death count per population
select location, Max(total_deaths) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by location
order by 2 desc



-- let's break things down by continent
-- showing the continents with the hightes death count per population
select continent, Max(total_deaths) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
Where continent is null
Group by continent
order by 2 desc



-- Global Numbers
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
-- Where location like '%india'
Where continent is not null
--group by date
order by 1,2


select date, sum(new_cases), sum(new_deaths)--, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
-- Where location like '%india'
Where continent is not null
group by date
order by 1,2


Select SUM(new_cases) as TotalNewCases, sum(new_deaths) as TotalNewDeaths, (sUM(new_deaths)/sum(new_cases))*100 as PercDeath
from PortfolioProject.dbo.CovidDeaths
where continent is not null



-- Looking at Total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as float) as newVac,
		sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,
		dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

With PopVsVac(Continent,Location,Date,Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as float) as newVac,
		sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,
		dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null)

Select *, (RollingPeopleVaccinated/Population)*100
from PopVsVac




-- Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Locatoin nvarchar(255),
Date datetime,
population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as float) as newVac,
		sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,
		dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



-- Creating View to store data for later visualization

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as float) as newVac,
		sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,
		dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select*
from PercentPopulationVaccinated
