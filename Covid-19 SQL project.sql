select location,date,population from CovidDeaths$


select * from CovidDeaths$
select * from CovidVaccinations$
select location,continent from CovidDeaths$

--Covid-19 Mortality Rate in Singapore

select location,population,date,total_cases,total_deaths,total_deaths/total_cases*100 as DeathPercentage from CovidDeaths$
where location like '%Singapore%' 
order by total_deaths/total_cases*100 DESC 

--Highest Rate of Infections
select location,population,date,total_cases,max(total_cases) as highest_infections,max(total_cases)/population*100 as InfectionRate_InPopulation from CovidDeaths$
group by location,population,date,total_cases
order by InfectionRate_InPopulation DESC

--Showing countries with highest death count across population
select location,population,total_cases,max(cast(total_deaths as int)) as TotalDeaths,max(cast(total_deaths as int)/population) as TotalDeathInpopulation from CovidDeaths$
where continent is not null
group by location,population,date,total_cases
order by TotalDeathInpopulation desc

--Global Numbers Rate of new cases in population
select date,sum(new_cases) as Newcases, sum(total_cases) as TotalCases, sum(new_cases)/sum(population)*100 as NewCasesInpopulation from CovidDeaths$
where continent is not null
group by date
order by date desc 

--Joining 2 tables.
select dea.continent,dea.location,dea.population,vac.new_vaccinations,dea.date as Date,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as NewVacPartition
from CovidVaccinations$ vac
join CovidDeaths$ dea
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3 

--Creating Partitions
With PopsVac as 
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select continent, new_vaccinations from PopsVac 


--Creating temporary tables
create table #populationvaccination
(continent nvarchar(250),
location nvarchar(250),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

--Inserting values into temporary table. 
insert into #populationvaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
Select * From #populationvaccination

Create view NewVaccinations as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
