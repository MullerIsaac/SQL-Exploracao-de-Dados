use CovidProject

SELECT * FROM CovidDeaths WHERE continent IS NOT NULL ORDER BY iso_code, continent

SELECT Location, date, total_cases, new_cases, total_deaths, population FROM CovidDeaths
WHERE continent IS NOT NULL ORDER BY iso_code, continent

SELECT Location, date, total_cases, new_cases, total_deaths, population FROM CovidDeaths
WHERE continent IS NOT NULL ORDER BY population desc


-- Casos x Mortes

SELECT Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as Porcentagem_Morte 
FROM CovidDeaths ORDER BY iso_code, continent

-- Casos x Mortes no Brasil
SELECT Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as Porcentagem_Morte 
FROM CovidDeaths WHERE location = 'Brazil' AND continent is not null ORDER BY date 

-- Casos x População no Brasil
SELECT Location, date, total_cases, population, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as Porcentagem_Infeccao
FROM CovidDeaths WHERE location = 'Brazil' AND continent is not null ORDER BY iso_code, continent

-- Maiores taxas de infecção 
SELECT location, MAX(CONVERT(float, total_cases)) as MaiorInfecção, population, MAX((CONVERT(float, total_cases) / CONVERT(float, population)))*100 as Porcentagem_Infeccao 
FROM CovidDeaths GROUP BY location, population ORDER BY Porcentagem_Infeccao desc


-- Maiores taxas de morte
SELECT location, MAX(convert(float, total_deaths)) as MaiorCountMortes
FROM CovidDeaths WHERE continent is not null GROUP BY location ORDER BY MaiorCountMortes desc


-- Maior numero de morte em um país por continente
SELECT continent, MAX(convert(float, total_deaths)) as MaiorCountMortes
FROM CovidDeaths WHERE continent is not null GROUP BY continent ORDER BY MaiorCountMortes desc

-- Números Globais por continente (Correto)
SELECT location, MAX(convert(float, total_deaths)) as MaiorCountMortes
FROM CovidDeaths WHERE continent is null GROUP BY location ORDER BY MaiorCountMortes desc


-- Letalidade Global
SELECT SUM(CONVERT(float, new_cases)) as total_cases, SUM(CONVERT(float, new_deaths)) as total_deaths, SUM(CONVERT(float, new_deaths))/SUM(CONVERT(float, new_cases))*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null 


-- Populacao x Vacinacao
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations, 
SUM(CONVERT(float, vacc.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as Pessoas_Vacinadas
FROM CovidDeaths death JOIN CovidVaccination vacc ON death.location = vacc.location and death.date = vacc.date
WHERE death.continent is not null and death.location = 'Brazil'



-- Utilizando CTE para não precisar fazer subqueries
-- Resultados a partir de 100% significa que as pessoas estão tomando a segunda ou terceira dose
WITH PopXVac (Continente, País, Data, Populacao, Novas_Vacinacoes, Evolucao_Vacinacao) AS
(
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations, 
SUM(CONVERT(float, vacc.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as Pessoas_Vacinadas
FROM CovidDeaths death JOIN CovidVaccination vacc ON death.location = vacc.location and death.date = vacc.date
WHERE death.continent is not null and death.location = 'Brazil'
)
SELECT *, (Evolucao_vacinacao/Populacao)*100 as Porcentagem_Vacinacao from PopXVac


-- Criando uma view pra acesso rapido
CREATE VIEW vacinacao_overtime as
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations, 
SUM(CONVERT(float, vacc.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as Pessoas_Vacinadas
FROM CovidDeaths death JOIN CovidVaccination vacc ON death.location = vacc.location and death.date = vacc.date
WHERE death.continent is not null

