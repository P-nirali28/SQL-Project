select * from coviddeath

update coviddeath set total_deaths = NUll where date = '2020-02-24' and location = 'Afghanistan';
update coviddeath set new_deaths = NUll where date = '2020-02-24' and location = 'Afghanistan';

SELECT*FROM coviddeath
ORDER BY 3,4;

SELECT * FROM covidvaccination
ORDER BY 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..coviddeath
order by 1,2;

-----percentage od death due to covid------

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
FROM PortfolioProject..coviddeath
WHERE location LIKE 'india%'
order by 1,2;

-----percentage of population got covid----

SELECT location, date, population,total_cases, (total_cases/population)*100 as covidcasespercentage
FROM PortfolioProject..coviddeath
WHERE location LIKE 'india%'
order by 1,2;

------countries with highest covid rate compared to population-----
SELECT location, population, max(total_cases) as highestcaseNo, 
max((total_cases/population))*100 as covidcasespercentage
FROM PortfolioProject..coviddeath
group by population, location
order by covidcasespercentage desc;

-------countries with highest death count per population-----

SELECT location, population, max(total_deaths) as highestdeath, 
max((total_deaths/population))*100 as coviddeathpercentage
FROM PortfolioProject..coviddeath
group by population, location
order by highestdeath desc;

----check by continent-----

SELECT location, max(total_deaths) as highestdeath 
FROM PortfolioProject..coviddeath
where continent is NULL
group by location
order by highestdeath desc;

SELECT continent, max(total_deaths) as highestdeath 
FROM PortfolioProject..coviddeath
where continent is not NULL
group by continent
order by highestdeath desc;

---new deathratio---

SELECT sum(new_cases) as totalcase, sum(new_deaths) as totaldeath,
(sum(new_deaths)/sum(new_cases))*100 as deathratio
FROM PortfolioProject..coviddeath


select sum(cast(new_tests as int)) from covidvaccination;

----join coviddeath and covidvaccination table -----

SELECT dea.continent, dea.population, dea.location, dea.date, 
vac.new_vaccinations, vac.total_vaccinations
FROM PortfolioProject..coviddeath dea join PortfolioProject..covidvaccination vac
on dea.location = vac.location and dea.date = vac.date;

 SELECT dea.continent, dea.population, dea.location, dea.date, 
vac.new_vaccinations, vac.total_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location)
FROM PortfolioProject..coviddeath dea join PortfolioProject..covidvaccination vac
on dea.location = vac.location and dea.date = vac.date;

-----imp----- 
SELECT dea.continent, dea.population, dea.location, dea.date, 
vac.new_vaccinations, vac.total_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as rollingpeoplevaccinated
FROM PortfolioProject..coviddeath dea join PortfolioProject..covidvaccination vac
on dea.location = vac.location and dea.date = vac.date
where dea.location is not null
order by 2,3;


---use CTE---
----population vs vaccination - vaccination ratio----


with popvsvac (continent, population, location, date, new_vaccinations, total_vaccinations,
rollingpeoplevaccinated)
as
(
SELECT dea.continent, dea.population, dea.location, dea.date, 
vac.new_vaccinations, vac.total_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as rollingpeoplevaccinated
FROM PortfolioProject..coviddeath dea join PortfolioProject..covidvaccination vac
on dea.location = vac.location and dea.date = vac.date
where dea.location is not null
)
select *, (rollingpeoplevaccinated/population)*100
from popvsvac;

----TEMP TABLE ----

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population FLOAT,
new_vaccinations nvarchar(255),
total_vaccinations nvarchar(255),
rollingpeoplevaccinated NUMERIC
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.population, dea.location, dea.date, 
vac.new_vaccinations, vac.total_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as rollingpeoplevaccinated
FROM PortfolioProject..coviddeath dea join PortfolioProject..covidvaccination vac
on dea.location = vac.location and dea.date = vac.date

select *, (rollingpeoplevaccinated/population)*100
from #PercentPopulationVaccinated;

--creating view to store data for later visualizations----

create view percentPopulationvaccinated as
SELECT dea.continent, dea.population, dea.location, dea.date, 
vac.new_vaccinations, vac.total_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as rollingpeoplevaccinated
FROM PortfolioProject..coviddeath dea join PortfolioProject..covidvaccination vac
on dea.location = vac.location and dea.date = vac.date

select * from percentPopulationvaccinated