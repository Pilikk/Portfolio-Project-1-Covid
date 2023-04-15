
Select *
From PortfolioProject1..CovidDeaths
Where continent is not NULL
Order By 3,4

--Select *
--From PortfolioProject1..CovidVaccinations
--Order By 3,4

--Select Data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population	
From PortfolioProject1..CovidDeaths
Where continent is not NULL
Order by 1,2


--Looking at Total Cases VS Covid Deaths
--Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
From PortfolioProject1..CovidDeaths
Where location Like '%sia%'
And continent is not NULL
Order by 1,2 



--Looking at Total Cases VS Population
--Shows what percentage of population got Covid
Select location, date, population, total_cases, (total_cases/population)*100 As PercentPopulationInfected
From PortfolioProject1..CovidDeaths
Where location Like '%malay%'
and continent is not NULL
Order by 1,2 


--Looking at Countries that have Highest Infection Rate Compared to Population
Select location, population, MAX(total_cases) As HighestInfectionRate, MAX((total_cases/population))*100 As PercentPopulationInfected
From PortfolioProject1..CovidDeaths
--Where location Like '%malay%'
Group by location, population
Order by PercentPopulationInfected Desc



--Showing Countries with Higest Death Count Per Population
Select location, MAX(cast(total_deaths as int)) As TotalDeaths
From PortfolioProject1..CovidDeaths
--Where location Like '%malay%'
Where continent is not NULL
Group by location
Order by TotalDeaths Desc


--LET"S BREAK THINGS DOWN BY CONTINENT

--Showing Continents with Highest Deaths Count Per Population
Select continent, MAX(cast(total_deaths as int)) As TotalDeaths
From PortfolioProject1..CovidDeaths
--Where location Like '%malay%'
Where continent is not NULL
Group by continent
Order by TotalDeaths Desc


--Global Numbers
Select date, SUM(new_cases) As NewCase, SUM(Cast(new_deaths as int)) As NewDeaths, SUM(Cast(new_deaths as int))/SUM(new_cases) As DeathPercentage
From PortfolioProject1..CovidDeaths
--Where location Like '%sia%'
where continent is not NULL
Group by date
Order by 1,2 

Select SUM(new_cases) As NewCase, SUM(Cast(new_deaths as int)) As NewDeaths, SUM(Cast(new_deaths as int))/SUM(new_cases)*100 As DeathPercentage
From PortfolioProject1..CovidDeaths
--Where location Like '%sia%'
where continent is not NULL
--Group by date
Order by 1,2 



--Looking at Total Population Vs Vaccinations
Select dead.continent, dead.location, dead.date, dead.population, vacc.new_vaccinations,
SUM(cast(vacc.new_vaccinations as int)) OVER (Partition by dead.location Order by dead.location, dead.date) as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dead
Join PortfolioProject1..CovidVaccinations vacc
	On dead.location = vacc.location
	And dead.date = vacc.date
Where dead.continent is not null
Order by 2, 3

--USE CTE
With PopVsVacc (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dead.continent, dead.location, dead.date, dead.population, vacc.new_vaccinations,
SUM(cast(vacc.new_vaccinations as int)) OVER (Partition by dead.location Order by dead.location, dead.date) as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dead
Join PortfolioProject1..CovidVaccinations vacc
	On dead.location = vacc.location
	And dead.date = vacc.date
Where dead.continent is not null
--Order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVacc


--Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dead.continent, dead.location, dead.date, dead.population, vacc.new_vaccinations,
SUM(cast(vacc.new_vaccinations as int)) OVER (Partition by dead.location Order by dead.location, dead.date) as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dead
Join PortfolioProject1..CovidVaccinations vacc
	On dead.location = vacc.location
	And dead.date = vacc.date
--Where dead.continent is not null
--Order by 2, 3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dead.continent, dead.location, dead.date, dead.population, vacc.new_vaccinations,
SUM(cast(vacc.new_vaccinations as int)) OVER (Partition by dead.location Order by dead.location, dead.date) as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dead
Join PortfolioProject1..CovidVaccinations vacc
	On dead.location = vacc.location
	And dead.date = vacc.date
Where dead.continent is not null
--Order by 2, 3

Select *
From PercentPopulationVaccinated