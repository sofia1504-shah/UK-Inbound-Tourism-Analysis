/*
UK Inbound Tourism Analysis
02 - Exploratory Analysis

Purpose:
Answer business-focused questions across visitor purpose, age, city,
and gender datasets after cleaning and transformation.

Source note:
Spending values in the source data are stored in £ millions.
*/

USE UKTourism;
GO

/* ============================================================
   1. PURPOSE AND VISITOR MARKETS
   ============================================================ */

-- Q1. Which visitor markets generate the most spending in the UK?
SELECT TOP 10
    country_of_residence,
    SUM(spending) AS total_spending_m
FROM dbo.tourism_purpose_analysis
WHERE country_of_residence <> 'Other Countries'
GROUP BY country_of_residence
ORDER BY total_spending_m DESC;

-- Q2. Which countries send the most visitors to the UK?
SELECT TOP 10
    country_of_residence,
    SUM(visits) AS total_visits
FROM dbo.tourism_purpose_analysis
WHERE country_of_residence <> 'Other Countries'
GROUP BY country_of_residence
ORDER BY total_visits DESC;

-- Q3. Which travel purposes generate the most spending?
SELECT
    purpose,
    SUM(spending) AS total_spending_m
FROM dbo.tourism_purpose_analysis
GROUP BY purpose
ORDER BY total_spending_m DESC;

-- Q4. Which countries have the highest spend per visit?
SELECT TOP 10
    country_of_residence,
    (SUM(spending) * 1000000.0) / NULLIF(SUM(visits), 0) AS spend_per_visit_gbp
FROM dbo.tourism_purpose_analysis
WHERE country_of_residence NOT IN (
    'Other Countries',
    'Other Middle East',
    'Other North Africa',
    'Other China',
    'Other Africa',
    'Other Asia',
    'Other Caribbean'
)
GROUP BY country_of_residence
ORDER BY spend_per_visit_gbp DESC;

-- Q5. Which countries have the longest average stay?
SELECT TOP 10
    country_of_residence,
    CAST(SUM(nights) * 1.0 / NULLIF(SUM(visits), 0) AS DECIMAL(10,1)) AS average_stay_days
FROM dbo.tourism_purpose_analysis
WHERE country_of_residence NOT IN (
    'Other Countries',
    'Other Middle East',
    'Other North Africa',
    'Other China',
    'Other Africa',
    'Other Asia',
    'Other Caribbean'
)
GROUP BY country_of_residence
ORDER BY average_stay_days DESC;

-- Q6. Which countries are high-spending despite relatively low visitor numbers?
SELECT
    country_of_residence,
    SUM(spending) AS total_spending_m,
    SUM(visits) AS total_visits
FROM dbo.tourism_purpose_analysis
GROUP BY country_of_residence
ORDER BY total_spending_m DESC, total_visits ASC;

-- Q7. What is each country's highest-spending travel purpose?
WITH ranked_purposes AS (
    SELECT
        country_of_residence,
        purpose,
        SUM(spending) AS total_spending_m,
        ROW_NUMBER() OVER (
            PARTITION BY country_of_residence
            ORDER BY SUM(spending) DESC
        ) AS purpose_rank
    FROM dbo.tourism_purpose_analysis
    WHERE country_of_residence NOT IN (
        'Other Countries',
        'Other Middle East',
        'Other North Africa',
        'Other China',
        'Other Africa',
        'Other Asia',
        'Other Caribbean'
    )
    GROUP BY country_of_residence, purpose
)
SELECT
    country_of_residence,
    purpose,
    total_spending_m
FROM ranked_purposes
WHERE purpose_rank = 1
ORDER BY total_spending_m DESC;
GO


/* ============================================================
   2. AGE DEMOGRAPHICS
   ============================================================ */

-- Q8. Which age groups account for the most visits?
SELECT
    age_band,
    SUM(visits) AS total_visits
FROM dbo.tourism_age_analysis
GROUP BY age_band
ORDER BY total_visits DESC;

-- Q9. Which age groups generate the most spending?
SELECT
    age_band,
    SUM(spending) AS total_spending_m
FROM dbo.tourism_age_analysis
GROUP BY age_band
ORDER BY total_spending_m DESC;

-- Q10. Which age groups generate the highest spend per visit?
SELECT
    age_band,
    (SUM(spending) * 1000000.0) / NULLIF(SUM(visits), 0) AS spend_per_visit_gbp
FROM dbo.tourism_age_analysis
GROUP BY age_band
ORDER BY spend_per_visit_gbp DESC;

-- Q11. What is the most-visited age group for each visitor market?
WITH ranked_age_groups AS (
    SELECT
        country_of_residence,
        age_band,
        visits,
        ROW_NUMBER() OVER (
            PARTITION BY country_of_residence
            ORDER BY visits DESC
        ) AS age_rank
    FROM dbo.tourism_age_analysis
    WHERE country_of_residence NOT IN (
        'Other Countries',
        'Other Middle East',
        'Other North Africa',
        'Other China',
        'Other Africa',
        'Other Asia',
        'Other Caribbean'
    )
)
SELECT
    country_of_residence,
    age_band,
    visits
FROM ranked_age_groups
WHERE age_rank = 1
ORDER BY visits DESC;
GO


/* ============================================================
   3. CITY ANALYSIS
   ============================================================ */

-- Q12. Which 10 UK cities receive the most international visits?
SELECT TOP 10
    city_and_town,
    SUM(visits) AS total_visits
FROM dbo.tourism_city_analysis
GROUP BY city_and_town
ORDER BY total_visits DESC;

-- Q13. Which 10 UK cities generate the most visitor spending?
SELECT TOP 10
    city_and_town,
    SUM(spending) AS total_spending_m
FROM dbo.tourism_city_analysis
GROUP BY city_and_town
ORDER BY total_spending_m DESC;

-- Q14. Which cities generate the highest spend per visit?
SELECT
    city_and_town,
    (SUM(spending) * 1000000.0) / NULLIF(SUM(visits), 0) AS spend_per_visit_gbp
FROM dbo.tourism_city_analysis
GROUP BY city_and_town
ORDER BY spend_per_visit_gbp DESC;

-- Q15. Which cities have the longest average stay?
SELECT
    city_and_town,
    CAST(SUM(nights) * 1.0 / NULLIF(SUM(visits), 0) AS DECIMAL(10,1)) AS average_stay_days
FROM dbo.tourism_city_analysis
GROUP BY city_and_town
ORDER BY average_stay_days DESC;
GO


/* ============================================================
   4. GENDER DEMOGRAPHICS
   ============================================================ */

-- Q16. Which gender accounts for the most visits?
SELECT
    gender,
    SUM(visits) AS total_visits
FROM dbo.tourism_gender_analysis
GROUP BY gender
ORDER BY total_visits DESC;

-- Q17. Which gender accounts for the most spending?
SELECT
    gender,
    SUM(spending) AS total_spending_m
FROM dbo.tourism_gender_analysis
GROUP BY gender
ORDER BY total_spending_m DESC;

-- Q18. Which gender spends more per visit?
SELECT
    gender,
    (SUM(spending) * 1000000.0) / NULLIF(SUM(visits), 0) AS spend_per_visit_gbp
FROM dbo.tourism_gender_analysis
GROUP BY gender
ORDER BY spend_per_visit_gbp DESC;

-- Q19. Does the gender pattern change between leisure and business travel?
SELECT
    purpose,
    gender,
    SUM(visits) AS total_visits
FROM dbo.tourism_gender_analysis
GROUP BY purpose, gender
ORDER BY purpose, total_visits DESC;

-- Q20. Which countries contribute the most male vs female visitors?
SELECT
    country_of_residence,
    gender,
    SUM(visits) AS total_visits
FROM dbo.tourism_gender_analysis
WHERE country_of_residence NOT IN (
    'Total World',
    'Europe',
    'EU',
    'EU Other',
    'EU15',
    'Other Countries',
    'Rest of World',
    'North America'
)
GROUP BY country_of_residence, gender
ORDER BY total_visits DESC;
GO
