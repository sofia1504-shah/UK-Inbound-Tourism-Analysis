/*
UK Inbound Tourism Analysis
03 - Tableau Outputs

Purpose:
Provide the final analysis-ready datasets exported to CSV and used to
build the three Tableau dashboards:
1. UK Inbound Tourism - Overview
2. UK Inbound Tourism - City Analysis
3. UK Inbound Tourism - Visitor Demographics
*/

USE UKTourism;
GO

/* ============================================================
   DASHBOARD 1 - OVERVIEW
   ============================================================ */

-- Purpose-level dataset for visits, spending and average stay visuals.
SELECT
    region_of_residence,
    country_of_residence,
    purpose,
    visits,
    spending,
    nights
FROM dbo.tourism_purpose_analysis;

-- Visitor-market dataset for Top 10 market analysis and overview KPI.
SELECT
    country_of_residence,
    SUM(visits) AS total_visits,
    SUM(spending) AS total_spending_m,
    CAST(SUM(nights) * 1.0 / NULLIF(SUM(visits), 0) AS DECIMAL(10,1)) AS average_stay_days
FROM dbo.tourism_purpose_analysis
WHERE country_of_residence <> 'Other Countries'
GROUP BY country_of_residence;
GO


/* ============================================================
   DASHBOARD 2 - CITY ANALYSIS
   ============================================================ */

SELECT
    city_and_town,
    purpose,
    visits,
    spending,
    nights
FROM dbo.tourism_city_analysis;

-- City-level metrics used for ranked charts.
SELECT
    city_and_town,
    SUM(visits) AS total_visits,
    SUM(spending) AS total_spending_m,
    (SUM(spending) * 1000000.0) / NULLIF(SUM(visits), 0) AS spend_per_visit_gbp,
    CAST(SUM(nights) * 1.0 / NULLIF(SUM(visits), 0) AS DECIMAL(10,1)) AS average_stay_days
FROM dbo.tourism_city_analysis
GROUP BY city_and_town;
GO


/* ============================================================
   DASHBOARD 3 - VISITOR DEMOGRAPHICS
   ============================================================ */

-- Age dataset.
SELECT
    region_of_residence,
    country_of_residence,
    age_band,
    visits,
    spending
FROM dbo.tourism_age_analysis;

-- Gender dataset.
SELECT
    region_of_residence,
    country_of_residence,
    gender,
    purpose,
    visits,
    spending
FROM dbo.tourism_gender_analysis;
GO
