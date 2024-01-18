
select * from CovidDeaths$ order by 3,4
-- select * from CovidVaccinations order by 3,4

-- Select the data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths$
Order by 1, 2

-- Looking at total cases vs total deaths
-- Shows the likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From CovidDeaths$
Where location = 'India'
Order by 1, 2

-- Looking at total cases vs total deaths
-- Shows what percentage of population got covid
select location, date, population, total_cases, (total_cases/population)*100 AS PercenteOfPopulationInfected
From CovidDeaths$
Where location = 'India'
Order by 1, 2

-- Looking at countries with highest infection rates compared to Pupulation
-- Shows what countries have highest infection rates
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS 
	PercenteOfPopulationInfected 
From CovidDeaths$
group by location, population
Order by PercenteOfPopulationInfected desc

-- Let's break down things by continent

--  Showing countries with highest death count per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount DESC

-- Global numbers
select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/sum(new_cases) * 100 AS DeathPercentage
from CovidDeaths$
where continent is not null
group by date
order by 1, 2


-- Joining two tables
-- Looking at Total population vs Vaccinations

-- Use CTE
with PopVSVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
select * from PopVSVac


-- TEMP Table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime, 
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- Creating VIEW to store data for later visualization
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

select * 
from PercentPopulationVaccinated