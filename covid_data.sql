create database covid;

select * from covid.corona_death
where continent is not null
order by  3,4;

select * from covid.covid_vaccinations
order by  3,4;

select location ,date , total_cases,new_cases,total_deaths,population
from covid.corona_death
order by 1,2;

#looking at total cases vs total deaths

select location ,date , total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from covid.corona_death
where location like '%india%'
order by 1,2;

#looking at the total cases vs population
select location ,date , total_cases,population,(total_cases/population)*100 as infection_rate
from covid.corona_death
where location like '%india%'
order by 1,2;

#looking at country with highest infection rate
select location ,population, max(total_cases) as highest_infect_count,max((total_cases/population)*100) as percent_population_infection
from covid.corona_death
group by location,population
order by percent_population_infection desc;

#showing countries with highest death count
SELECT 
    SUM(CAST(new_cases AS UNSIGNED)) AS total_cases,
    SUM(CAST(new_deaths AS UNSIGNED)) AS total_deaths,
    ROUND(SUM(CAST(new_deaths AS UNSIGNED)) / SUM(CAST(new_cases AS UNSIGNED)) * 100, 2) AS death_percent
FROM 
    covid.corona_death
WHERE 
    continent IS NOT NULL
    AND new_cases REGEXP '^[0-9]+$'
    AND new_deaths REGEXP '^[0-9]+$';

#total population vs vaccination
select dea.continent,dea.location,dea.date,dea.population,dea.new_vaccinations,
sum(cast(dea.new_vaccinations as signed)) over (partition by dea.location order by dea.location ,dea.date) as RollingPeopleVaccinated
from covid.corona_death dea
join covid.covid_vaccinations vac 
     on dea.location=vac.location
     and dea.date=vac.date
     where dea.continent is not null
     order by 2,3;

#cte

WITH PopvsVac AS (
  SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    dea.new_vaccinations,
    (dea.new_vaccinations / dea.population) * 100 AS RollingPeopleVaccinated
  FROM 
    covid.corona_death dea
  JOIN 
    covid.covid_vaccinations vac 
    ON dea.location = vac.location
    AND dea.date = vac.date
)
SELECT *
FROM PopvsVac;

CREATE TABLE percent_population_vaccinated (
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATE,
    population NUMERIC,
    new_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

INSERT INTO percent_population_vaccinated (
    continent, location, date, population, new_vaccinations, RollingPeopleVaccinated
)
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    dea.new_vaccinations,
    SUM(dea.new_vaccinations) OVER (
        PARTITION BY dea.location 
        ORDER BY dea.date
    ) AS RollingPeopleVaccinated
FROM 
    covid.corona_death dea
JOIN 
    covid.covid_vaccinations vac
    ON dea.location = vac.location AND dea.date = vac.date
WHERE 
    dea.new_vaccinations IS NOT NULL
    AND dea.population IS NOT NULL;

SELECT 
    *,
    ROUND((RollingPeopleVaccinated / population) * 100, 2) AS PercentPopulationVaccinated
FROM 
    percent_population_vaccinated;


#creating view to store data for later visualization

DROP VIEW IF EXISTS PercentPopulationVaccinated;
DROP TABLE IF EXISTS PercentPopulationVaccinated; -- Just in case it's a table

CREATE VIEW PercentPopulationVaccinated AS
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    dea.new_vaccinations,
    SUM(dea.new_vaccinations) OVER (
        PARTITION BY dea.location 
        ORDER BY dea.date
    ) AS RollingPeopleVaccinated
FROM 
    covid.corona_death dea
JOIN 
    covid.covid_vaccinations vac
    ON dea.location = vac.location AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL;

