SELECT *
FROM [Portfolio Project]..CovidDeaths
WHERE Continent is not NULL

SELECT *
FROM [Portfolio Project]..CovidVaccinations
WHERE Continent is not NULL

--Select Useful Data

SELECT Location,  Date, Total_Cases, Total_Deaths, Population
FROM [Portfolio Project]..CovidDeaths
WHERE Continent is not NULL
ORDER BY 1,2


--Showing Total Cases vs Total Deaths
--Death Percentage if suffered from COVID-19 in Malaysia from time to time

SELECT Location,  Date, Total_Cases, Total_Deaths, (Total_Deaths/Total_Cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE Location like '%malay%' AND Continent is not NULL
ORDER BY 1,2


--Showing Total Cases vs Polulation
--Infection rate of COVID-19 in Malaysia from time to time

SELECT Location,  Date, Total_Cases, Population, (Total_Cases/Population)*100 as InfectionRate
FROM [Portfolio Project]..CovidDeaths
WHERE Location like '%malay%' AND Continent is not NULL
ORDER BY 1,2


--Ranking Countries with Highest Infection Rate 
	
SELECT Location, MAX(Total_Cases) as MaxCases, Population, MAX((Total_Cases/Population))*100 as InfectionRate
FROM [Portfolio Project]..CovidDeaths
WHERE Continent is not NULL
GROUP BY Population, Location
ORDER BY 4 DESC


--Ranking Countries with Total Death

SELECT Location, MAX(CAST(Total_Deaths as int)) as TotalDeaths
FROM [Portfolio Project]..CovidDeaths
WHERE Continent is not NULL
GROUP BY Location
ORDER BY 2 DESC


--Ranking Continent with Total Death

SELECT Continent, MAX(CAST(Total_Deaths as int)) as TotalDeaths
FROM [Portfolio Project]..CovidDeaths
WHERE Continent is not NULL
GROUP BY Continent
ORDER BY 2 DESC


--Global Total Cases vs Total Deaths from each day
--Showing Death Percentage from day to day

SELECT Date, SUM(New_Cases) as Total_Cases, SUM(CAST(New_Deaths as int)) as Total_Deaths, SUM(CAST(New_Deaths as int))/SUM(New_Cases)* 100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE Continent is not NULL
GROUP BY Date
ORDER BY Date


--Showing Vaccinated Rate of the Population for each country


SELECT dea.Continent, dea.Location, dea.Date,  dea.Population , vac.New_Vaccinations
, SUM(CAST(vac.New_Vaccinations as int)) OVER (Partition By dea.Location ORDER BY dea.Location, dea.Date) as Accumulated_Vaccination
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
ON dea.Location = vac.Location AND dea.Date = vac.date
WHERE dea.Continent is not NULL
ORDER BY 2,3


--USE CTE

WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, Accumulated_Vaccination)
as
(
SELECT dea.Continent, dea.Location, dea.Date,  dea.Population , vac.New_Vaccinations
, SUM(CAST(vac.New_Vaccinations as int)) OVER (Partition By dea.Location ORDER BY dea.Location, dea.Date) as Accumulated_Vaccination
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
ON dea.Location = vac.Location AND dea.Date = vac.date
WHERE dea.Continent is not NULL
)

SELECT *, (Accumulated_Vaccination/Population)*100
FROM PopVsVac


--USE TEMP TABLE
DROP TABLE IF EXISTS #temp
CREATE TABLE #temp
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Accumulated_Vaccination numeric
)

INSERT INTO #temp 

SELECT dea.Continent, dea.Location, dea.Date,  dea.Population , vac.New_Vaccinations
, SUM(CAST(vac.New_Vaccinations as int)) OVER (Partition By dea.Location ORDER BY dea.Location, dea.Date) as Accumulated_Vaccination
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
ON dea.Location = vac.Location AND dea.Date = vac.date
WHERE dea.Continent is not NULL


SELECT *, (Accumulated_Vaccination/Population)*100
FROM #temp


--CREATING VIEW FOR VISUALISATION

CREATE VIEW temp as 
SELECT dea.Continent, dea.Location, dea.Date,  dea.Population , vac.New_Vaccinations
, SUM(CAST(vac.New_Vaccinations as int)) OVER (Partition By dea.Location ORDER BY dea.Location, dea.Date) as Accumulated_Vaccination
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
ON dea.Location = vac.Location AND dea.Date = vac.date
WHERE dea.Continent is not NULL