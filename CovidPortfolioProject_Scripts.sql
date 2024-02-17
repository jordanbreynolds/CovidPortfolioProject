Select *
From CovidPortfolioProject..CovidDeaths
Where continent is not null
Order By 3,4

--Select *
--From CovidPortfolioProject..CovidVaccinations
--Order By 3,4

-- Selecting the data we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From CovidPortfolioProject..CovidDeaths
Order By 1,2

-- Comparing Total Cases to Total Deaths in US
-- showing likelihood of dying if you contract covid in United States

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
From CovidPortfolioProject..CovidDeaths
Where location like '%states%'
Order By 1,2

-- Comparing Total Cases vs Population in US
-- showing what percentage of the population got Covid

Select location, date, population, total_cases,(total_cases/population)*100 AS percent_population_infected
From CovidPortfolioProject..CovidDeaths
Where location = 'United States'
Order By 1,2

-- Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) AS highest_infection_count, MAX(total_cases/population)*100 AS percent_population_infected
From CovidPortfolioProject..CovidDeaths
Group By Location, Population
Order By percent_population_infected DESC

-- Showing countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) AS total_death_count
From CovidPortfolioProject..CovidDeaths
Where continent is not null
Group By Location
Order By total_death_count DESC

-- DATA BY CONTINENT
-- Showing continents with highest death count per population

Select continent, MAX(cast(total_deaths as int)) AS total_death_count
From CovidPortfolioProject..CovidDeaths
Where continent is null
Group By continent
Order By total_death_count DESC

-- GLOBAL DATA
-- Looking at total cases, deaths, and death percentage per day

Select date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS death_percentage
From CovidPortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order By 1,2

-- Overall cases, deaths, and death
Select SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS death_percentage
From CovidPortfolioProject..CovidDeaths
Where continent is not null
Order By 1,2

-- Population vs Vaccinations



-- Use CTE to compare rolling total vaccinations to total population

With PopVsVac (continent, location, date, population, new_vaccinations, rolling_total_vaccinations)
as
(
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by death.location Order by death.location,death.date) AS rolling_total_vaccinations
From CovidPortfolioProject..CovidDeaths AS death
Join CovidPortfolioProject..CovidVaccinations AS vac
	On death.location = vac.location
	and death.date = vac.date
Where death.continent is not null
)

Select *, (rolling_total_vaccinations/population)*100 AS percentage_vaccinated
From PopVsVac

-- Use TEMP TABLE to compare rolling total vaccinations to total population

Drop Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
rolling_total_vaccinations numeric
)

Insert into #PercentagePopulationVaccinated
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by death.location Order by death.location,death.date) AS rolling_total_vaccinations
From CovidPortfolioProject..CovidDeaths AS death
Join CovidPortfolioProject..CovidVaccinations AS vac
	On death.location = vac.location
	and death.date = vac.date
--Where death.continent is not null

Select *, (rolling_total_vaccinations/population)*100 AS percentage_vaccinated
From #PercentagePopulationVaccinated

-- CREATING VIEWS TO STORE DATA FOR LATER VISUALIZATIONS

-- View for Percentage of the Population Vaccinated
Create View PercentPopulationVaccinated AS
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by death.location Order by death.location,death.date) AS rolling_total_vaccinations
From CovidPortfolioProject..CovidDeaths AS death
Join CovidPortfolioProject..CovidVaccinations AS vac
	On death.location = vac.location
	and death.date = vac.date
Where death.continent is not null

Select *
From PercentPopulationVaccinated

-- View for Percentage of Total Deaths Per Total Cases
Create View PercentageDeathsPerCases AS
Select date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS death_percentage
From CovidPortfolioProject..CovidDeaths
Where continent is not null
Group by date

Select *
From PercentageDeathsPerCases