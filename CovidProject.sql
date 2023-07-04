select *
from CovidDeaths
order by 3,4

select *
from CovidVaccinations
order by 3,4

--select data that we are going to be using
select location, date,total_cases,new_cases,total_deaths,population
from CovidDeaths
order by 1,2

--looking at the total cases vs total deaths
--show likelihood if dying if you cntract covide in your country
select location, date,total_cases,total_deaths,(convert(decimal(15,3),total_deaths)/convert(decimal(15,3),total_cases))*100 as DeathPercentage
from CovidDeaths
where location like '%states%'
order by 1,2

--looking at total cases vs population
--shows what percentage of population got covid
select location, date,total_cases,population,(convert(decimal(15,1),total_deaths)/population)*100 as PercentagePopulationInfected
from CovidDeaths
--where location like '%states%'
order by 1,2

--looking at counties with highest inffection rate compated to pupulation
select location, population,Max(total_cases) as HighestIfectionCount,Max((convert(decimal(15,1),total_cases)/population)*100) as PercentagePopulationInfected
from CovidDeaths
group by location,population
--where location like '%states%'
order by PercentagePopulationInfected desc


--show countries with highest death count per population
select location,Max(cast(total_deaths as int)) as totalDeaths
from CovidDeaths
where continent is not null
group by location
order by totalDeaths desc

--let's break things down by continet


--showing contintents with the highest death count per polulation
select location,Max(cast(total_deaths as int)) as totalDeaths
from CovidDeaths
where continent is null
group by location
order by totalDeaths desc

--global numbers
select SUM(new_cases) as total_cases1,SUM(new_deaths) as total_deaths1,SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
--group by location
order by 1,2


--looking at tital population vs vaccunations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 1,2,3


--use cte
with PopVsVac (continent,location,date,population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
	
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

)
select *, (RollingPeopleVaccinated/population)*100
from PopVsVac

--temptable
drop table if exists #percentPopulationVaccinated
create table #percentPopulationVaccinated(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into #percentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
	
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100
from #percentPopulationVaccinated


--creating view to store data for later visualation
create view percentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
	
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

select * 
from percentPopulationVaccinated
