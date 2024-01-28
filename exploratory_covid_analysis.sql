-- Data Exploration Project
-- Worldwide Covid Analysis
-- data source:

select *
from test_schema.CovidDeaths
limit 10;

-- shows each country by deaths, cases, population per day
select location, date, total_deaths, total_cases, population
from test_schema.CovidDeaths
order by 2, 1

-- total cases vs total deaths (likelihood of dying if contracting covid)
select location,
       date,
       ifnull(total_deaths, 0) as total_deaths,
       ifnull(total_cases, 0) as total_cases,
       (total_deaths)/(total_cases)*100 as death_pct
from test_schema.CovidDeaths
order by 2,1;

-- total cases vs total population (likelihood of contracting covid)
select location,
       date,
       ifnull(total_cases, 0) as total_cases,
       population,
       (total_cases/population)*100 as contraction_rt
from test_schema.CovidDeaths
order by 2, 1;


-- shows pct of population contracting covid on a single day
select location,
       date,
       new_cases,
       population,
       (new_cases/population)*100 as contraction_rt
from test_schema.CovidDeaths
where total_cases is not null
order by 2, 1;


-- highest rate of contraction by location and date
with
test as (
    select location,
       date,
       new_cases,
       population,
       row_number() OVER (partition by location order by new_cases desc) as maxnewcases
    from test_schema.CovidDeaths)
select location,
  date,
  new_cases,
  population,
  (new_cases/population)*100 as contact_rt
from test
where maxnewcases = 1
order by 1;

-- Covid deaths by continent
select continent,
       sum(total_deaths) as total_deaths
from test_schema.CovidDeaths
where continent is not null
group by 1;

-- top 10 highest days of death related to covid
with
test as (
    select date,
       sum(new_deaths) as totaldeaths,
       sum(new_cases) as totalcases,
       (sum(new_deaths)/sum(new_cases))*100 as deathrate
    from test_schema.CovidDeaths
    where continent is null
    group by 1)
select *
from test
order by deathrate desc
limit 10;

-- looking at vaccination data
select *
from test_schema.CovidVaccinations
limit 10;

-- tests per population
select a.location,
    a.date,
    ifnull(a.new_tests,0),
    ifnull(a.total_tests,0),
    b.population,
    (a.new_tests/a.total_tests)*100 as new_testing_rt,
    (a.total_tests/b.population)*100 as total_testing_rt
from test_schema.CovidVaccinations a
left join test_schema.CovidDeaths b on a.location=b.location and a.date=b.date;

-- countries with highest number of tests per population
select a.location,
    max(a.total_tests) total_tests,
    max(b.population) population,
    round((max(a.total_tests)/max(b.population))*100, 3) rt
from test_schema.CovidVaccinations a
left join test_schema.CovidDeaths b on a.location=b.location and a.date=b.date
where total_tests is not null
group by 1
order by 4 desc;

-- countries with vaccines, cases, population
select a.location,
       a.date,
       ifnull(new_vaccinations, 0) new_vaccines,
       ifnull(total_vaccinations,0) total_vaccinations,
       ifnull(new_cases,0) new_cases,
       ifnull(total_cases,0) total_cases,
       population
from test_schema.CovidVaccinations a
left join test_schema.CovidDeaths b on a.location=b.location and a.date=b.date
where a.continent is not null
order by 2, 1;

-- vaccination rate by country/day
select a.location,
       a.date,
       ifnull(total_vaccinations,0) as total_vaccines,
       population,
       round((total_vaccinations/population)*100,3) as rt
from test_schema.CovidVaccinations a
left join test_schema.CovidDeaths b on a.location=b.location and a.date=b.date
where a.continent is not null and
  total_vaccinations <> 0;

-- people fully vaccinated / population
select a.location,
       a.date,
       people_fully_vaccinated,
       population,
       round((people_fully_vaccinated/population)*100, 3) as fully_vaccinated_rt
from test_schema.CovidVaccinations a
left join test_schema.CovidDeaths b on a.location=b.location and a.date=b.date
where people_fully_vaccinated is not null;

-- highest rate of fully vaccinated by country
with
test as (
    select a.location,
       ifnull(people_fully_vaccinated,0) as fully_vaccinated_ct,
       population,
       round((people_fully_vaccinated/population)*100, 3) as fully_vaccinated_rt,
       row_number() over (partition by a.location order by people_fully_vaccinated desc) as x
    from test_schema.CovidVaccinations a
    left join test_schema.CovidDeaths b on a.location=b.location and a.date=b.date
    where people_fully_vaccinated <> 0)
select location, fully_vaccinated_ct, population, fully_vaccinated_rt
from test
where x = 1
order by 4 desc;

-- countries with highest number of covid tests recorded
select a.location,
       max(a.total_tests) as total_tests,
       (b.population) as population,
       (max(a.total_tests)/(b.population))*100 as rt
from test_schema.CovidVaccinations a
left join test_schema.CovidDeaths b on a.location=b.location and a.date=b.date
group by 1
order by 2 desc;

-- Highest number of vaccination in a singular day, per county
with
test as (
select a.location,
       new_vaccinations,
       population,
       row_number() over (partition by a.location order by new_vaccinations desc) as x
from test_schema.CovidVaccinations a
left join test_schema.CovidDeaths b on a.location=b.location and a.date=b.date
where new_vaccinations is not null)
select location, new_vaccinations, population, (new_vaccinations/population)*100 as rt
from test
where x = 1
order by 4 desc;