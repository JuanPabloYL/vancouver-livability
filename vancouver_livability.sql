-- ============================================================
-- VANCOUVER LIVABILITY ANALYSIS
-- Description: Analysis of crime, green space, businesses and
--              community centres across Vancouver neighbourhoods
-- Data Sources: VPD GeoDASH (crime), City of Vancouver Open Data
-- Years Covered: 2023-2025
-- ============================================================

-- ============================================================
-- SECTION 1: EXPLORATORY QUERIES
-- ============================================================

-- 1.1 Crime count by neighbourhood and year
--     Excludes Stanley Park and Musqueam (special cases with
--     no comparable business or community services data)
WITH filter_dataset AS (
    SELECT * 
    FROM crime
    WHERE NEIGHBOURHOOD NOT IN ('Stanley Park', 'Musqueam')
)
SELECT
    year,
    neighbourhood,
    COUNT(*) AS crime_count
FROM filter_dataset
GROUP BY year, neighbourhood
ORDER BY neighbourhood, year;


-- 1.2 Most common crime type per neighbourhood
--     Uses ROW_NUMBER() with PARTITION BY to return only the
--     top crime type for each neighbourhood
WITH filter_dataset AS (
    SELECT * 
    FROM crime
    WHERE NEIGHBOURHOOD NOT IN ('Stanley Park', 'Musqueam')
)
SELECT
    neighbourhood,
    type,
    crime_count
FROM (
    SELECT 
        neighbourhood,
        type,
        COUNT(*) AS crime_count,
        ROW_NUMBER() OVER (
            PARTITION BY neighbourhood 
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM filter_dataset
    GROUP BY type, neighbourhood
) AS ranked_crimes
WHERE rn = 1
ORDER BY neighbourhood;


-- 1.3 Green space summary by neighbourhood
--     Shows total parks, total hectares and average park size
SELECT 
    NeighbourhoodName,
    COUNT(*) AS number_of_parks,
    ROUND(SUM(Hectare), 2) AS total_hectares,
    ROUND(AVG(Hectare), 2) AS avg_hectares_per_park
FROM parks
GROUP BY NeighbourhoodName
ORDER BY total_hectares DESC;


-- ============================================================
-- SECTION 2: INTERMEDIATE ANALYSIS
-- ============================================================

-- 2.1 Total crimes vs total green space per neighbourhood
--     First JOIN across two tables using CTEs
WITH filter_dataset AS (
    SELECT * 
    FROM crime
    WHERE NEIGHBOURHOOD NOT IN ('Stanley Park', 'Musqueam')
),
overall_crime AS (
    -- Aggregate total crimes per neighbourhood
    SELECT 
        neighbourhood,
        COUNT(*) AS crime_count
    FROM filter_dataset
    GROUP BY neighbourhood
),
total_green_spaces AS (
    -- Aggregate total green space per neighbourhood
    SELECT
        NeighbourhoodName,
        ROUND(SUM(Hectare), 2) AS total_green_space
    FROM parks
    GROUP BY NeighbourhoodName
)
SELECT 
    oc.neighbourhood,
    oc.crime_count,
    tgs.total_green_space
FROM overall_crime oc
LEFT JOIN total_green_spaces tgs
    ON oc.neighbourhood = tgs.NeighbourhoodName
ORDER BY oc.crime_count DESC;


-- ============================================================
-- SECTION 3: FINAL NEIGHBOURHOOD SUMMARY
-- ============================================================

-- 3.1 Complete neighbourhood summary table
--     Combines all 4 datasets into one row per neighbourhood
--     Used as the primary data source for the Power BI dashboard
--
--     Exclusions:
--       - Crime Stanley Park, Musqueam
--         excluded as they lack comparable services data
--       - Businesses: Out of Town and UBC excluded as they are
--                    not Vancouver neighbourhoods
WITH overall_crime AS (
    -- Total crimes and average annual crimes per neighbourhood
    SELECT 
        NEIGHBOURHOOD,
        COUNT(*) AS total_crimes,
        ROUND(COUNT(*) / 3, 0) AS crimes_per_year
    FROM crime
    WHERE NEIGHBOURHOOD NOT IN ('Stanley Park', 'Musqueam')
    GROUP BY NEIGHBOURHOOD
),
green_spaces AS (
    -- Total parks and green space per neighbourhood
    SELECT 
        NeighbourhoodName,
        COUNT(*) AS total_parks,
        ROUND(SUM(Hectare), 2) AS total_hectares
    FROM parks
    WHERE NeighbourhoodName NOT IN ('Stanley Park', 'Musqueam')
    GROUP BY NeighbourhoodName
),
businesses AS (
    -- Active business licence count per neighbourhood
    SELECT
        localarea,
        COUNT(*) AS active_businesses
    FROM business_licences
    WHERE localarea NOT IN ('Out of Town', 'UBC')
    GROUP BY localarea
),
total_community_center AS (
    -- Community centre count per neighbourhood
    SELECT
        `Geo Local Area`,
        COUNT(*) AS total_community_centers
    FROM community_centres
    GROUP BY 1
)
SELECT 
    oc.NEIGHBOURHOOD,
    'Canada' AS country,
    'Vancouver' AS city,
    oc.total_crimes,
    oc.crimes_per_year,
    COALESCE(gs.total_parks, 0) AS total_parks,
    COALESCE(gs.total_hectares, 0) AS total_hectares,
    COALESCE(b.active_businesses, 0) AS active_businesses,
    COALESCE(cc.total_community_centers, 0) AS total_community_centers
FROM overall_crime oc
LEFT JOIN green_spaces gs
    ON oc.NEIGHBOURHOOD = gs.NeighbourhoodName
LEFT JOIN businesses b
    ON oc.NEIGHBOURHOOD = b.localarea
LEFT JOIN total_community_center cc
    ON oc.NEIGHBOURHOOD = cc.`Geo Local Area`
ORDER BY oc.total_crimes DESC;


-- ============================================================
-- SECTION 4: VALIDATION QUERIES
-- ============================================================

-- 4.1 List all unique neighbourhoods in crime data
SELECT DISTINCT NEIGHBOURHOOD 
FROM crime
ORDER BY NEIGHBOURHOOD;

-- 4.2 List neighbourhoods after excluding special cases
SELECT DISTINCT NEIGHBOURHOOD 
FROM crime
WHERE NEIGHBOURHOOD NOT IN ('Stanley Park', 'Musqueam')
ORDER BY NEIGHBOURHOOD;