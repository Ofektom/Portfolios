select *
From PortfolioProject..CovidDeaths



--Daily percentage of Population that contacted COVID per country --
Select location, date, new_cases, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float)) * 100 as TotalDeathPercentage 
From PortfolioProject..CovidDeaths
where continent is not Null, location like '%nige%'
Order by 1,2

--Rate of infection based on population--
Select location, date, total_cases, population,  (total_cases/population) as InfectionRate
From PortfolioProject..CovidDeaths
where continent is not Null
order by 1,2

--Country with highest infection--
Select location, population, MAX(total_cases) as MaxInfection, (Max(total_cases)/population)*100 as PercentageInfected
From PortfolioProject..CovidDeaths
where continent is not Null
Group by location, population 
order by MaxInfection desc

--Country with highest death count per population--
Select location, MAX(convert(int,total_deaths)) as MaxDeath
From PortfolioProject..CovidDeaths
where continent is not Null 
Group by location
order by MaxDeath desc

--Continent with highest death count per population--
Select location, MAX(convert(int,total_deaths)) as MaxDeath
From PortfolioProject..CovidDeaths
where continent is Null 
Group by location
order by MaxDeath desc

--GLOBAL NUMBERS--
Select date, sum(new_cases) as TotalCases, sum(convert(int,new_deaths)) as TotalDeaths, sum(cast(new_deaths as float))/sum(cast(total_cases as float)) * 100 as TotalDeathPercentage
From PortfolioProject..CovidDeaths
where continent is not Null
Group by date
Order by 1,2

--CTE--
with PopVsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
	SUM(convert(int,vac.new_vaccinations)) Over (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations$ vac
	join PortfolioProject..CovidDeaths dea
	On vac.location = dea.location and vac.date = dea.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 as PercentageVaccinated
from PopVsVac


--TEMP TABLE--
Drop Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(convert(int,vac.new_vaccinations)) Over (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations$ vac
join PortfolioProject..CovidDeaths dea
	On vac.location = dea.location and vac.date = dea.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100 as PercentageVaccinated
from #PercentPopulationVaccinated

--Creating VIEW to store data for later visualization--
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(convert(int,vac.new_vaccinations)) Over (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations$ vac
join PortfolioProject..CovidDeaths dea
	On vac.location = dea.location and vac.date = dea.date
where dea.continent is not null
--order by 2,3

