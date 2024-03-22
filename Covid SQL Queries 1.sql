select *
from [Portfolio Project].dbo.Coviddeaths
order by 3,4

--select *
--from [Portfolio Project]..Covidvaccinations
--order by 3,4

--select data that we will be using

select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project]..Coviddeaths
order by 1,2

--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid


Select location, date, total_cases, total_deaths, (convert(float,total_deaths)/NULLIF(CONVERT(FLOAT,total_cases), 0))*100 as DeathPercentage
From [Portfolio Project]..Coviddeaths
order by 1,2

--Looking at Total cases vs population
-- Shows the total daily covid cases in relation to population in Europe

Select location, date, population, total_cases, (total_cases/population)*100 as Infectedpopulationpercentage
From [Portfolio Project]..Coviddeaths
where location like '%Europe%'
order by 1,2

--Looking at countries with highest infection rates compared to population

Select location, population, MAX(total_cases) as Hihghestinfectioncount, Max(total_cases/population)*100 as Infectionrate
From [Portfolio Project]..Coviddeaths
--where location like '%Europe%'
Group by location, population
order by Infectionrate desc


--Looking at countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) as Totaldeathcount
From [Portfolio Project]..Coviddeaths
where continent is not null
Group by location, population
order by Totaldeathcount desc

--Breaking things down by continent
--Showing continents with the highest death count

Select continent, MAX(cast(total_deaths as int)) as Totaldeathcount
From [Portfolio Project]..Coviddeaths
where continent is not null
Group by continent
order by Totaldeathcount desc

--Looking at Global numbers

Select date, SUM(new_cases)as Sumnewcases, SUM(cast(new_deaths as int)) as Sumnewdeaths
From [Portfolio Project]..Coviddeaths
where continent is not null
Group by date
order by 1,2

--Looking at Deaths and vaccination table combined

select *
from [Portfolio Project].dbo.Coviddeaths dea
Join [Portfolio Project].dbo.Covidvaccinations vac
  on dea.location = vac.location
  and dea.date= vac.date

--Looking at Population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(float, vac.new_vaccinations, 0)) OVER (Partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
from [Portfolio Project].dbo.Coviddeaths dea
Join [Portfolio Project].dbo.Covidvaccinations vac
  on dea.location = vac.location
  and dea.date= vac.date
 where dea.continent is not null
order by 1,2,3

--Use CTE to calculate total vaccination percentage by date

With popvsvac (Continent, Location, Date, population, new_vaccinations, Rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(float, vac.new_vaccinations, 0)) OVER (Partition by dea.location order by dea.location, vac.date) as Rollingpeoplevaccinated
from [Portfolio Project].dbo.Coviddeaths dea
Join [Portfolio Project].dbo.Covidvaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
 where dea.continent is not null
)
select *, (Rollingpeoplevaccinated/population)*100 as Percentagevaccinated
From popvsvac

--Creating a Temp Table
Drop table if exists #PercentPopulationVaccinated
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
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(float, vac.new_vaccinations, 0)) OVER (Partition by dea.location order by dea.location, vac.date) as Rollingpeoplevaccinated
from [Portfolio Project].dbo.Coviddeaths dea
Join [Portfolio Project].dbo.Covidvaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
 where dea.continent is not null
select *, (Rollingpeoplevaccinated/population)*100 as Percentagevaccinated
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(float, vac.new_vaccinations, 0)) OVER (Partition by dea.location order by dea.location, vac.date) as Rollingpeoplevaccinated
from [Portfolio Project].dbo.Coviddeaths dea
Join [Portfolio Project].dbo.Covidvaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
 where dea.continent is not null

 Create view Sumnewdeaths as
 Select date, SUM(new_cases)as Sumnewcases, SUM(cast(new_deaths as int)) as Sumnewdeaths
From [Portfolio Project]..Coviddeaths
where continent is not null
Group by date



