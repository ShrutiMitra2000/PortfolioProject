--accessing the database and tables
use Portfolio_project1;
select * from CovidDeaths;
select * from Covidvaccinations;

--selecting the data we will be using 
select location, date,total_cases, new_cases, total_deaths, population 
from  CovidDeaths
Where continent is not null
order by 1,2;

--Calculating the death percentage for the country we live for each day
select location,date,total_cases, total_deaths,round((total_deaths/total_cases)*100,2) as DeathPercentage
from  CovidDeaths
where location like '%india%' and continent is not null
order by DeathPercentage desc

--Calculating the infected percentage for the country we live for each day
select location,date,total_cases,population, round((total_cases/population)*100,2) as InfectedPercentage
from  CovidDeaths
where location like '%ndia%' and continent is not null
order by InfectedPercentage desc

--Comparing the highest Infected perecentage for each country
select location,population,max(round((total_cases/population)*100,2)) as InfectedPercentage
from  CovidDeaths
--where location like '%dia%'
Where continent is not null
group by location,population
order by InfectedPercentage desc

--Countries with Highest Death Count
select location,population, max(total_deaths) as TotalDeathCount
from CovidDeaths
Where continent is not null
group by location,population
order by TotalDeathCount desc

--Showing contintents with the highest death count
select continent, max(total_deaths) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Death percentage for each continent
select continent, SUM(new_cases) as TotalCases, Sum(cast(new_deaths as int)) as TotalDeaths, ROUND(SUM(cast(new_deaths as int))/SUM(New_Cases)*100 ,2) as TotalDeathPercentage
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathPercentage desc

-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date)  as PeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--group by dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
order by dea.location, dea.date

-- Using CTE to perform Calculation on Partition By in previous query
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations,  PeopleVaccinated)
as(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date)  as PeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null )
Select *,round(( PeopleVaccinated/Population)*100,2) as vaccinatedPeoplePercentage
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
vaccinatedPeople numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as vaccinatedPeople
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (vaccinatedPeople/Population)*100 as VaccinatedPeoplePercentage
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--select * from PercentPopulationVaccinated
