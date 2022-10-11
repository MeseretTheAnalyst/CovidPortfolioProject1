--Select*
--From SQLProject..CovidDeath

--Select*
--From SQLProject..CovidVac



--Select *
--From SQLProject..CovidData
--Order by 3,4


--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From SQLProject..CovidDeath
where continent is not null
Order by 3,4


--HERE We looking at Total cases vs Total Death In UNITED STATE
--(we added death% to help us see the likelihood of dying if you contracted Covid in US)

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From SQLProject..CovidDeath
Where Location like '%United states%', and continent is not null
Order by 1,2


--Here we Looking at Total cases vs Population
--This shows us the % of US population who got Covid by timeline
(--maybe use this to visualize this data)

Select Location, date, total_cases, population, (total_cases/population)*100 as InfectedPopulationPercentage
From SQLProject..CovidDeath
Where Location like '%United states%', and continent is not null
Order by 1,2


--Here we are looking at US vs the world infection rate by population
--We ordered it to show countries with the highest cases in desc order

Select Location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PopulationInfectedPercentage
From SQLProject..CovidDeath
--Where Location like '%United states%'
Where continent is not null
Group by Location, Population
Order by PopulationInfectedPercentage desc


--Here we are comparing the total death count in US vs the World per population

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From SQLProject..CovidDeath
--Where Location like '%United states%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc


---Here we going to break things down by Continents to look at the Total death counts

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From SQLProject..CovidDeath
--Where Location like '%United states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc


--Here we are going to look at Global Numbers

Select date, SUM(new_cases) as TotalCases, SUM(Cast(new_deaths as int)) as TotalDealth, SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From SQLProject..CovidDeath
--Where Location like '%United states%'
Where continent is not null
Group by date
Order by 1,2


--Here we are looking at the total cases and total death accross the world

Select SUM(new_cases) as TotalCases, SUM(Cast(new_deaths as int)) as TotalDealth, SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From SQLProject..CovidDeath
--Where Location like '%United states%'
Where continent is not null
--Group by date
Order by 1,2


-- Here we are going to start looking at the vaccination vs population

--Select*
--From SQLProject..CovidDeath dea Join SQLProject..CovidVac vac 
--	On dea.location = vac.location 
--	and dea.date = vac.date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(Cast(Vac.new_vaccinations as bigint)) 
	OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVac, --RollingPeopleVac/population)*100
From SQLProject..CovidDeath dea Join SQLProject..CovidVac vac 
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3



--USE CTE
With PopvsVac (continent, location, Date, Population, New_vaccinations, RollingPeopleVac) as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(Cast(Vac.new_vaccinations as bigint)) 
	OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVac --RollingPeopleVac/population)*100
From SQLProject..CovidDeath dea Join SQLProject..CovidVac vac 
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)

Select*, (RollingPeopleVac/population)*100
From PopvsVac



---TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated 
(
Continent nvarchar(255), 
Location nvarchar(255), 
date datetime,
Population numeric,
New_vaccinations numeric,
RollingpeopleVac numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(cast(Vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVac 
--, RollingPeopleVac/population)*100
From SQLProject..CovidDeath dea Join SQLProject..CovidVac vac 
	On dea.location = vac.location 
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select*, (RollingPeopleVac/population)*100
From #PercentPopulationVaccinated


--For Our Visulization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(cast(Vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVac 
--, RollingPeopleVac/population)*100
From SQLProject..CovidDeath dea Join SQLProject..CovidVac vac 
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
