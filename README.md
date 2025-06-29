# portfolioproject
# 🦠 COVID-19 SQL Analysis Project

This project performs a comprehensive SQL-based analysis of global COVID-19 data using real-world datasets. It analyzes infection, death, and vaccination rates using cleaned data and advanced SQL techniques like window functions and CTEs.

---

## 📁 Project Overview

- 📊 Performed in-depth analysis using MySQL on two primary tables:
  - `corona_death`: Contains data on cases, deaths, and population by country
  - `covid_vaccinations`: Contains data on tests and vaccinations by country

- 🧹 Cleaned the data in Excel before import:
  - Set blank cells as `NULL`
  - Reformatted all dates to SQL-compatible format (`YYYY-MM-DD`)

---

## 🧠 Key Metrics Computed

| Metric | Description |
|--------|-------------|
| `death_percentage` | Total deaths as % of total cases |
| `infection_rate` | Total cases as % of population |
| `tests_per_1k` | Total tests per 1,000 people |
| `positivity_rate` | Total cases / total tests × 100 |
| `RollingPeopleVaccinated` | Running total of vaccinated people |
| `PercentPopulationVaccinated` | Cumulative vaccinated % of population |

---

## 🛠️ SQL Features Used

- **Joins** on `location` and `date`
- **CTEs** for structured temporary views
- **Window functions** to track rolling vaccination numbers
- **Data filtering** using `REGEXP` for numeric values
- **View creation** to store reusable analytics

---

## 🔁 Key Queries

### 🦠 Death Rate for India
```sql
SELECT location, date, total_cases, total_deaths,
       (total_deaths / total_cases) * 100 AS death_percentage
FROM covid.corona_death
WHERE location LIKE '%india%'
ORDER BY date;
