/*
UK Inbound Tourism Analysis
01 - Data Preparation

Purpose:
Create raw staging tables and transform imported tourism data into
analysis-ready tables for Tableau and exploratory SQL analysis.

Workflow:
1. Export relevant Excel worksheets to CSV.
2. Copy each CSV into the SQL Server Docker container.
3. Import each CSV into its corresponding *_raw table using bcp.
4. Run the cleaning and transformation sections below.

Notes:
- Raw measure fields are stored as NVARCHAR so irregular source values can
  be imported without failing.
- TRY_CAST converts valid numeric values to INT and converts non-standard
  source markers to NULL.
- CROSS APPLY reshapes wide source tables into long analysis tables.
*/

USE UKTourism;
GO

/* ============================================================
   1. PURPOSE OF VISIT
   ============================================================ */

DROP TABLE IF EXISTS dbo.tourism_purpose_raw;
GO

CREATE TABLE dbo.tourism_purpose_raw (
    region_of_residence NVARCHAR(100),
    country_of_residence NVARCHAR(100),
    holiday_visits NVARCHAR(50),
    holiday_spending NVARCHAR(50),
    holiday_nights NVARCHAR(50),
    inclusive_tour_visits NVARCHAR(50),
    inclusive_tour_spending NVARCHAR(50),
    inclusive_tour_nights NVARCHAR(50),
    business_visits NVARCHAR(50),
    business_spending NVARCHAR(50),
    business_nights NVARCHAR(50),
    vfr_visits NVARCHAR(50),
    vfr_spending NVARCHAR(50),
    vfr_nights NVARCHAR(50),
    miscellaneous_visits NVARCHAR(50),
    miscellaneous_spending NVARCHAR(50),
    miscellaneous_nights NVARCHAR(50),
    all_purpose_visits NVARCHAR(50),
    all_purpose_spending NVARCHAR(50),
    all_purpose_nights NVARCHAR(50)
);
GO

/* Import CSV into dbo.tourism_purpose_raw with bcp before continuing. */

DROP TABLE IF EXISTS dbo.tourism_purpose_clean;
GO

SELECT
    region_of_residence,
    country_of_residence,
    TRY_CAST(holiday_visits AS INT) AS holiday_visits,
    TRY_CAST(holiday_spending AS INT) AS holiday_spending,
    TRY_CAST(holiday_nights AS INT) AS holiday_nights,
    TRY_CAST(inclusive_tour_visits AS INT) AS inclusive_tour_visits,
    TRY_CAST(inclusive_tour_spending AS INT) AS inclusive_tour_spending,
    TRY_CAST(inclusive_tour_nights AS INT) AS inclusive_tour_nights,
    TRY_CAST(business_visits AS INT) AS business_visits,
    TRY_CAST(business_spending AS INT) AS business_spending,
    TRY_CAST(business_nights AS INT) AS business_nights,
    TRY_CAST(vfr_visits AS INT) AS vfr_visits,
    TRY_CAST(vfr_spending AS INT) AS vfr_spending,
    TRY_CAST(vfr_nights AS INT) AS vfr_nights,
    TRY_CAST(miscellaneous_visits AS INT) AS miscellaneous_visits,
    TRY_CAST(miscellaneous_spending AS INT) AS miscellaneous_spending,
    TRY_CAST(miscellaneous_nights AS INT) AS miscellaneous_nights,
    TRY_CAST(all_purpose_visits AS INT) AS all_purpose_visits,
    TRY_CAST(all_purpose_spending AS INT) AS all_purpose_spending,
    TRY_CAST(all_purpose_nights AS INT) AS all_purpose_nights
INTO dbo.tourism_purpose_clean
FROM dbo.tourism_purpose_raw;
GO

DROP TABLE IF EXISTS dbo.tourism_country;
GO

SELECT *
INTO dbo.tourism_country
FROM dbo.tourism_purpose_clean
WHERE country_of_residence NOT IN (
    'EU',
    'EU Other',
    'EU15',
    'Europe',
    'Rest of Europe',
    'Rest of the World',
    'North America',
    'Total World'
);
GO

DROP TABLE IF EXISTS dbo.tourism_purpose_analysis;
GO

SELECT
    region_of_residence,
    country_of_residence,
    purpose,
    visits,
    spending,
    nights
INTO dbo.tourism_purpose_analysis
FROM dbo.tourism_country
CROSS APPLY (
    VALUES
        ('Business', business_visits, business_spending, business_nights),
        ('Holiday', holiday_visits, holiday_spending, holiday_nights),
        ('Visiting Friends and Relatives', vfr_visits, vfr_spending, vfr_nights),
        ('Miscellaneous', miscellaneous_visits, miscellaneous_spending, miscellaneous_nights)
) AS p(purpose, visits, spending, nights);
GO


/* ============================================================
   2. AGE DEMOGRAPHICS
   ============================================================ */

DROP TABLE IF EXISTS dbo.tourism_age_raw;
GO

CREATE TABLE dbo.tourism_age_raw (
    region_of_residence NVARCHAR(100),
    country_of_residence NVARCHAR(100),
    age_0_15_visits NVARCHAR(50),
    age_0_15_spending NVARCHAR(50),
    age_16_24_visits NVARCHAR(50),
    age_16_24_spending NVARCHAR(50),
    age_25_34_visits NVARCHAR(50),
    age_25_34_spending NVARCHAR(50),
    age_35_44_visits NVARCHAR(50),
    age_35_44_spending NVARCHAR(50),
    age_45_54_visits NVARCHAR(50),
    age_45_54_spending NVARCHAR(50),
    age_55_64_visits NVARCHAR(50),
    age_55_64_spending NVARCHAR(50),
    age_65_plus_visits NVARCHAR(50),
    age_65_plus_spending NVARCHAR(50),
    all_age_visits NVARCHAR(50),
    all_age_spending NVARCHAR(50)
);
GO

/* Import CSV into dbo.tourism_age_raw with bcp before continuing. */

DROP TABLE IF EXISTS dbo.tourism_age_clean;
GO

SELECT
    region_of_residence,
    country_of_residence,
    TRY_CAST(age_0_15_visits AS INT) AS age_0_15_visits,
    TRY_CAST(age_0_15_spending AS INT) AS age_0_15_spending,
    TRY_CAST(age_16_24_visits AS INT) AS age_16_24_visits,
    TRY_CAST(age_16_24_spending AS INT) AS age_16_24_spending,
    TRY_CAST(age_25_34_visits AS INT) AS age_25_34_visits,
    TRY_CAST(age_25_34_spending AS INT) AS age_25_34_spending,
    TRY_CAST(age_35_44_visits AS INT) AS age_35_44_visits,
    TRY_CAST(age_35_44_spending AS INT) AS age_35_44_spending,
    TRY_CAST(age_45_54_visits AS INT) AS age_45_54_visits,
    TRY_CAST(age_45_54_spending AS INT) AS age_45_54_spending,
    TRY_CAST(age_55_64_visits AS INT) AS age_55_64_visits,
    TRY_CAST(age_55_64_spending AS INT) AS age_55_64_spending,
    TRY_CAST(age_65_plus_visits AS INT) AS age_65_plus_visits,
    TRY_CAST(age_65_plus_spending AS INT) AS age_65_plus_spending,
    TRY_CAST(all_age_visits AS INT) AS all_age_visits,
    TRY_CAST(all_age_spending AS INT) AS all_age_spending
INTO dbo.tourism_age_clean
FROM dbo.tourism_age_raw;
GO

DROP TABLE IF EXISTS dbo.tourism_age_analysis;
GO

SELECT
    region_of_residence,
    country_of_residence,
    age_band,
    visits,
    spending
INTO dbo.tourism_age_analysis
FROM dbo.tourism_age_clean
CROSS APPLY (
    VALUES
        ('0-15', age_0_15_visits, age_0_15_spending),
        ('16-24', age_16_24_visits, age_16_24_spending),
        ('25-34', age_25_34_visits, age_25_34_spending),
        ('35-44', age_35_44_visits, age_35_44_spending),
        ('45-54', age_45_54_visits, age_45_54_spending),
        ('55-64', age_55_64_visits, age_55_64_spending),
        ('65+', age_65_plus_visits, age_65_plus_spending)
) AS a(age_band, visits, spending)
WHERE country_of_residence NOT IN (
    'EU',
    'EU15',
    'EU Other',
    'Europe',
    'North America',
    'Rest of Europe',
    'Rest of the World',
    'Total World'
);
GO


/* ============================================================
   3. CITY ANALYSIS
   ============================================================ */

DROP TABLE IF EXISTS dbo.tourism_city_raw;
GO

CREATE TABLE dbo.tourism_city_raw (
    city_and_town NVARCHAR(100),
    holiday_all_visits NVARCHAR(50),
    holiday_all_spending NVARCHAR(50),
    holiday_all_nights NVARCHAR(50),
    holiday_tour_visits NVARCHAR(50),
    holiday_tour_spending NVARCHAR(50),
    holiday_tour_nights NVARCHAR(50),
    business_visits NVARCHAR(50),
    business_spending NVARCHAR(50),
    business_nights NVARCHAR(50),
    vfr_visits NVARCHAR(50),
    vfr_spending NVARCHAR(50),
    vfr_nights NVARCHAR(50),
    miscellaneous_visits NVARCHAR(50),
    miscellaneous_spending NVARCHAR(50),
    miscellaneous_nights NVARCHAR(50),
    total_visits NVARCHAR(50),
    total_spending NVARCHAR(50),
    total_nights NVARCHAR(50)
);
GO

/* Import CSV into dbo.tourism_city_raw with bcp before continuing. */

DROP TABLE IF EXISTS dbo.tourism_city_clean;
GO

SELECT
    city_and_town,
    TRY_CAST(holiday_all_visits AS INT) AS holiday_all_visits,
    TRY_CAST(holiday_all_spending AS INT) AS holiday_all_spending,
    TRY_CAST(holiday_all_nights AS INT) AS holiday_all_nights,
    TRY_CAST(holiday_tour_visits AS INT) AS holiday_tour_visits,
    TRY_CAST(holiday_tour_spending AS INT) AS holiday_tour_spending,
    TRY_CAST(holiday_tour_nights AS INT) AS holiday_tour_nights,
    TRY_CAST(business_visits AS INT) AS business_visits,
    TRY_CAST(business_spending AS INT) AS business_spending,
    TRY_CAST(business_nights AS INT) AS business_nights,
    TRY_CAST(vfr_visits AS INT) AS vfr_visits,
    TRY_CAST(vfr_spending AS INT) AS vfr_spending,
    TRY_CAST(vfr_nights AS INT) AS vfr_nights,
    TRY_CAST(miscellaneous_visits AS INT) AS miscellaneous_visits,
    TRY_CAST(miscellaneous_spending AS INT) AS miscellaneous_spending,
    TRY_CAST(miscellaneous_nights AS INT) AS miscellaneous_nights,
    TRY_CAST(total_visits AS INT) AS total_visits,
    TRY_CAST(total_spending AS INT) AS total_spending,
    TRY_CAST(total_nights AS INT) AS total_nights
INTO dbo.tourism_city_clean
FROM dbo.tourism_city_raw;
GO

DROP TABLE IF EXISTS dbo.tourism_city_analysis;
GO

SELECT
    city_and_town,
    purpose,
    visits,
    spending,
    nights
INTO dbo.tourism_city_analysis
FROM dbo.tourism_city_clean
CROSS APPLY (
    VALUES
        ('Holiday', holiday_all_visits, holiday_all_spending, holiday_all_nights),
        ('Business', business_visits, business_spending, business_nights),
        ('Visiting Friends and Relatives', vfr_visits, vfr_spending, vfr_nights),
        ('Miscellaneous', miscellaneous_visits, miscellaneous_spending, miscellaneous_nights)
) AS purpose_data(purpose, visits, spending, nights);
GO


/* ============================================================
   4. GENDER DEMOGRAPHICS
   ============================================================ */

DROP TABLE IF EXISTS dbo.tourism_gender_raw;
GO

CREATE TABLE dbo.tourism_gender_raw (
    region_of_residence NVARCHAR(100),
    country_of_residence NVARCHAR(100),
    male_leisure_visits NVARCHAR(50),
    male_leisure_spending NVARCHAR(50),
    male_business_visits NVARCHAR(50),
    male_business_spending NVARCHAR(50),
    female_leisure_visits NVARCHAR(50),
    female_leisure_spending NVARCHAR(50),
    female_business_visits NVARCHAR(50),
    female_business_spending NVARCHAR(50)
);
GO

/* Import CSV into dbo.tourism_gender_raw with bcp before continuing. */

DROP TABLE IF EXISTS dbo.tourism_gender_clean;
GO

SELECT
    region_of_residence,
    country_of_residence,
    TRY_CAST(male_leisure_visits AS INT) AS male_leisure_visits,
    TRY_CAST(male_leisure_spending AS INT) AS male_leisure_spending,
    TRY_CAST(male_business_visits AS INT) AS male_business_visits,
    TRY_CAST(male_business_spending AS INT) AS male_business_spending,
    TRY_CAST(female_leisure_visits AS INT) AS female_leisure_visits,
    TRY_CAST(female_leisure_spending AS INT) AS female_leisure_spending,
    TRY_CAST(female_business_visits AS INT) AS female_business_visits,
    TRY_CAST(female_business_spending AS INT) AS female_business_spending
INTO dbo.tourism_gender_clean
FROM dbo.tourism_gender_raw;
GO

DROP TABLE IF EXISTS dbo.tourism_gender_analysis;
GO

SELECT
    region_of_residence,
    country_of_residence,
    gender,
    purpose,
    visits,
    spending
INTO dbo.tourism_gender_analysis
FROM dbo.tourism_gender_clean
CROSS APPLY (
    VALUES
        ('Male', 'Leisure', male_leisure_visits, male_leisure_spending),
        ('Male', 'Business', male_business_visits, male_business_spending),
        ('Female', 'Leisure', female_leisure_visits, female_leisure_spending),
        ('Female', 'Business', female_business_visits, female_business_spending)
) AS gender_data(gender, purpose, visits, spending);
GO


/* ============================================================
   FINAL DATA QUALITY CHECKS
   ============================================================ */

SELECT 'Purpose Analysis' AS dataset, COUNT(*) AS row_count FROM dbo.tourism_purpose_analysis
UNION ALL
SELECT 'Age Analysis', COUNT(*) FROM dbo.tourism_age_analysis
UNION ALL
SELECT 'City Analysis', COUNT(*) FROM dbo.tourism_city_analysis
UNION ALL
SELECT 'Gender Analysis', COUNT(*) FROM dbo.tourism_gender_analysis;
GO
