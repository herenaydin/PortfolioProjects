

select *
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations$
--order by 3,4

-- select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2

--total cases vs total deaths
--Probability of death in turkey
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percent
from PortfolioProject..CovidDeaths$
where location like '%turkey%'
order by 1,2 desc

--Total cases vs Population
--Population percentage of covid

select location, date, total_cases, population, round((total_cases/population)*100, 3) Population_Percent
from PortfolioProject..CovidDeaths$
where location like '%turkey%'
order by 1,2 desc

--Countries with highest infection rate compared to population
select location, population, max(total_cases) HighestInfectionCount, max((total_cases/population)*100) Population_Percent
from PortfolioProject..CovidDeaths$
group by location, population
order by Population_Percent desc

--Countries with highest death count
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc


--CONTINENTS
--Death Count
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is null
group by location
order by TotalDeathCount desc


-- Showing continents with highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

select sum(new_cases) SumOfNewCases, sum(cast(new_deaths as int)) SumOfNewDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 PercentageOfNew--, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
--group by date
order by 3 desc


--Total population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as PeopleVaccinated
--, (PeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, PeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as PeopleVaccinated
--, (PeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (PeopleVaccinated/population)*100
from PopvsVac


--TEMP TABLE

DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as PeopleVaccinated
--, (PeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (PeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- Creating View to Store data for later visualizations

Create View PopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as PeopleVaccinated
--, (PeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PopulationVaccinated