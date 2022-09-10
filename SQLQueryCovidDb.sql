select *
from [dbo].[covidDeaths3]
order by 3,4

select *
from [dbo].[covidVaccinations1]
order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from [dbo].[covidDeaths3]
order by 3,4

--Total cases vs total deaths
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from [dbo].[covidDeaths3]
where location like '%states%'

--total cases vs population
select location,date,population,total_cases,(total_cases/population)*100 as deathpercentage
from [dbo].[covidDeaths3]
where location like 'India'

--countries with highest infection rate compared with country's population
select location, population, max(total_cases) as highestInfected,max((total_cases)/population)*100 as percentageAffected
from [dbo].[covidDeaths3]
group by location, population
order by percentageAffected Desc

--countries with highest death rates
select Location, max(cast(total_deaths as int)) as DeathRate
from [dbo].[covidDeaths3]
where continent is not null
group by location
order by DeathRate Desc

--countries with highest death rates compared to their population
select location, population, max(cast(total_deaths as int)) as DeathRate, (max(cast(total_deaths as int))/population)*100 as deathpercentage
from [dbo].[covidDeaths3]
where continent is not null
group by location, population
order by DeathRate Desc

--continent with highest death rates
select continent, max(cast(total_deaths as int)) as DeathRate
from [dbo].[covidDeaths3]
where continent is not null
group by continent
order by DeathRate Desc

--global cases, deaths, death percentage
select sum(new_cases) as totCovidCases ,sum(cast(new_deaths as int)) as totDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as totDeathPercentage
from [dbo].[covidDeaths3]

select date,sum(new_cases) as totCovidCases ,sum(cast(new_deaths as int)) as totDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as totDeathPercentage
from [dbo].[covidDeaths3]
where continent is not null
group by date
order by 1,2

select * from [dbo].[covidVaccinations3]
order by 3,4

select * 
from [dbo].[covidDeaths3] as dea
join[dbo].[covidVaccinations3] vac
on dea.location = vac.location
and dea.date= vac. date


--new vaccinations done
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from coviddb..[covidDeaths3] as dea
join coviddb..covidVaccinations3 as vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
order by 2,3

-- total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over
( partition by dea.location order by dea.location, dea.date) as rollingSumVac
from coviddb..[covidDeaths3] as dea
join coviddb..covidVaccinations3 as vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
order by 2,3

-- to get rolling sum using CTE
 with popVac (continent,location,date,population,new_vaccinations,rollingSumVac)
 as
 (
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over
(partition by dea.location order by dea.location, dea.date) as rollingSumVac
from coviddb..[covidDeaths3] as dea
join coviddb..covidVaccinations3 as vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
)
select * from popVac

--create a temp table
drop table if exists #totPercentageVaccinated
create table #totPercentageVaccinated
(
continent nvarchar(255), location nvarchar(255), date datetime,
population numeric,
new_vaccinations numeric,rollingSumVac numeric
)

insert into #totPercentageVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
avg(convert(float,vac.new_vaccinations)) over
(partition by dea.location order by dea.location, dea.date) as rollingSumVac
from coviddb..[covidDeaths3] as dea
join coviddb..covidVaccinations3 as vac
on dea.location = vac.location
and dea.date= vac.date
--where dea.continent is not null

select *, (rollingSumVac/population)*100 
from #totPercentageVaccinated

--create a view

create view percentagePopulationVacc as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
avg(convert(float,vac.new_vaccinations)) over
(partition by dea.location order by dea.location, dea.date) as rollingSumVac
from coviddb..[covidDeaths3] as dea
join coviddb..covidVaccinations3 as vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null

select * from percentagePopulationVacc