
select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject2..coviddeaths
order by 1,2


-- Looking at the Total cases versus total deaths
-- shows likelihood if you contract covid
select Location, date, total_cases,  total_deaths, (total_deaths / total_cases) * 100 as DeathPercentage
from PortfolioProject2..coviddeaths
--where location like '%states%'
order by 1,2

-- Total cases versus population
-- What percentage of percentage got covid
select Location, date, population, total_cases,   ( total_cases / population) * 100 as Poppercentage
from PortfolioProject2..coviddeaths
-- where location like '%china%'
order by 1,2

-- What country has the highest infection rate compared to population
select Location, population, max(total_cases) as HighestInfectionCount,   max(( total_cases / population)) * 100 as MaxPoppercentageInfected
from PortfolioProject2..coviddeaths
-- where location like '%china%'
group by location, population
order by MaxPoppercentageInfected desc

-- Highest Death count per location
select Location, max(total_cases) as totalDeathCount
from PortfolioProject2..coviddeaths
-- where location like '%china%'
where continent is not null
group by Location
order by totalDeathCount desc

-- let breaks things by continent

select continent, max(total_cases) as totalDeathCount
from PortfolioProject2..coviddeaths
-- where location like '%china%'
where continent is not null
group by continent
order by totalDeathCount desc


-- Highest Death count per location
-- continents with the highest death count
select Location, max(total_cases) as totalDeathCount
from PortfolioProject2..coviddeaths
-- where location like '%china%'
where continent is null
group by Location
order by totalDeathCount desc

-- What countint has the highest infection rate compared to population
select continent, population, max(total_cases) as HighestInfectionCount,   max(( total_cases / population)) * 100 as MaxPoppercentageInfected
from PortfolioProject2..coviddeaths
-- where location like '%china%'
group by continent, population
order by MaxPoppercentageInfected desc

select date, Sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int)) /
Sum(new_cases) * 100 as DeathPercentage
from PortfolioProject2..coviddeaths
where continent is not null
group by date
order by DeathPercentage desc

select * from 
PortfolioProject2..coviddeaths cd
join
PortfolioProject2..vaccinations vac
on cd.location = vac.location
and cd.date = vac.date

select cd.continent, cd.location, cd.date, cd.population, vac.new_vaccinations
from PortfolioProject2..coviddeaths cd
join
PortfolioProject2..vaccinations vac
on cd.location = vac.location
and cd.date = vac.date
where cd.continent is not null
order by 2, 3

select cd.continent, cd.location, cd.date, cd.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date)
as Rollingpeoplevaccinated

from PortfolioProject2..coviddeaths cd
join
PortfolioProject2..vaccinations vac
on cd.location = vac.location
and cd.date = vac.date
where cd.continent is not null
order by 2, 3


-- use CTE
with popvsVac(continent, location, date,population,new_vaccinations, Rollingpeoplevaccinated)
as
(
select cd.continent, cd.location, cd.date, cd.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date)
as Rollingpeoplevaccinated

from PortfolioProject2..coviddeaths cd
join
PortfolioProject2..vaccinations vac
on cd.location = vac.location
and cd.date = vac.date
where cd.continent is not null
--  order by 2, 3
)
Select * from popvsVac

-- Temp table
drop table if exists #percentPopulationvaccinated
create table #percentPopulationvaccinated
(
contintent  nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)


insert into #percentPopulationvaccinated
select cd.continent, cd.location, cd.date, cd.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date)
as Rollingpeoplevaccinated

from PortfolioProject2..coviddeaths cd
join
PortfolioProject2..vaccinations vac
on cd.location = vac.location
and cd.date = vac.date
where cd.continent is not null
--  order by 2, 3

select * from #percentPopulationvaccinated

-- Creating view to store data
-- Create the view
CREATE VIEW percentPopulationvaccinated AS
SELECT 
    cd.continent, 
    cd.location, 
    cd.date, 
    cd.population, 
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS INT)) OVER (
        PARTITION BY cd.location 
        ORDER BY cd.date
    ) AS Rollingpeoplevaccinated
FROM 
    PortfolioProject2..coviddeaths cd
JOIN 
    PortfolioProject2..vaccinations vac
    ON cd.location = vac.location
    AND cd.date = vac.date
WHERE 
    cd.continent IS NOT NULL;
GO

-- Query the view
SELECT * FROM percentPopulationvaccinated;


