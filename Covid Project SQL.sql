
select * from PortfolioProject..CovidDeath 
where continent is not null
order by 3,4 ;


-- Select Data that we are going to be using

select location,date,total_cases, new_cases,total_deaths,population from 
PortfolioProject.dbo.CovidDeath 
where continent is not null
order by 1,2;

--Looking at Total cases vs total Deaths

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..covidDeath where location like '%states%' and 
continent is not null
order by 1,2;

--Looking at Total cases vs population
--shows what percentage of population got Covid

select location,date,total_cases,population,
(convert(float,total_cases)/convert(float,population))*100 as 
Deathpercentage from portfolioproject..CovidDeath
where continent is not null
order by 1,2;

-- Looking at Countries with Highest Infection Rate compared to Population

select location,population,max(cast(total_cases as int)) as HigestInfectionRate,
max((total_cases/population))*100 as PercentPopulationInfected
from portfolioproject..CovidDeath
where continent is not null
group by location,population
order by PercentPopulationInfected desc;

--Showing Countries with Highest Death Count per population

select location,max(cast(total_deaths as int) )as HighestDeathCount
from PortfolioProject..CovidDeath
where continent is not null
group by location order by HighestDeathCount desc;


--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing Continents with the highest death count per population

select Continent,max(cast(total_deaths as int) ) as TotalDeathCount
from PortfolioProject..CovidDeath
where continent is not null
group by continent
order by TotalDeathCOunt desc


--Global Numbers

Select  sum(new_cases) as Total_cases,sum(cast(new_deaths as int)) as Total_deaths,
(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..covidDeath 
--where location like '%states%' and 
where continent is not null
--group by date
order by 1,2;


--Looking at Total Populaltion vs Vaccinations

select d.continent,d.Location,d.Date,d.Population,v.New_vaccinations,
sum(convert(bigint,v.new_vaccinations)) over(partition by d.location order by d.location) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeath D
join PortfolioProject..CovidVacchinations V
	on d.location=v.location and d.date=v.date
where d.continent is not null
order by 2,3


--With CTE

with PopvsVac(Continent,Location,Date,Population,New_vaccination,
RollingPeopleVaccinated)
as
(
select d.continent,d.Location,d.Date,d.Population,v.New_vaccinations,
sum(convert(bigint,v.new_vaccinations)) over(partition by d.location order by d.location) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeath D
join PortfolioProject..CovidVacchinations V
	on d.location=v.location and d.date=v.date
where d.continent is not null
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


--Temp Table

Drop table  if exists #percentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(125),
Location nvarchar(125),
Date date,
Population bigint,
New_vaccination bigint,
RollingPeopleVaccinated bigint
)

insert into #percentPopulationVaccinated
select d.continent,d.Location,d.Date,d.Population,v.New_vaccinations,
sum(convert(bigint,v.new_vaccinations)) over(partition by d.location order by d.location) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeath D
join PortfolioProject..CovidVacchinations V
	on d.location=v.location and d.date=v.date
where d.continent is not null
order by 2,3

select * from #percentPopulationVaccinated

--Creating View to store data for later visualizations

create view PercentPopulationVaccinated 
as
select d.continent,d.Location,d.Date,d.Population,v.New_vaccinations,
sum(convert(bigint,v.new_vaccinations)) over(partition by d.location order by d.location) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeath D
join PortfolioProject..CovidVacchinations V
	on d.location=v.location and d.date=v.date
where d.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated



