USE cyclistic
GO


--- ChatGPT
SELECT * INTO rides 
FROM (
	SELECT * FROM data1
    UNION 
    SELECT * FROM data2
    UNION 
    SELECT * FROM data3
    UNION
    SELECT * FROM data4
) AS combinedData;

-- ChatGPT Prompt:
-- Add two new columns to the ride table, start_date and end_date. 
-- The extract the start date from the started_at and the end date  from ended_at. 
-- Then delete any rows where start_date != end_date
-- Source: https://github.com/davidjayjackson/cyclistic-bikeshare-sqlserver

-- 1. Add new columns
ALTER TABLE rides ADD start_date DATE;
ALTER TABLE rides ADD end_date DATE;

-- 2. Update the new columns
UPDATE rides
SET start_date = CAST(started_at AS DATE),
    end_date = CAST(ended_at AS DATE);

-- 3. Delete rows where start_date != end_date
DELETE FROM rides
WHERE start_date <> end_date;


 -- Delete rows with missing station names.
SELECT count(*)
FROM rides
WHERE start_station_name IS NULL OR end_station_name IS NULL;

DELETE
FROM rides
WHERE start_station_name IS NULL OR end_station_name IS NULL;

-- Add two new columns to the ride table, start_date and end_date. 
-- The extract the start date from the started_at and the end date  from ended_at. 
-- Then delete any rows where start_date <> end_date



-- Write The SQL SERVER code to add four columns. 
-- (1) start_hour from started_at, (2) day of week (spelled out) from start_date, 
-- (3) start month (spelled out) from start_date. 
-- (4) calulate trip duration in minutes using started_at and ended_at. 
-- Delete rows where trip duration is <=0.

-- 1. Add new columns
ALTER TABLE rides ADD start_hour INT;
ALTER TABLE rides ADD day_of_week NVARCHAR(50);
ALTER TABLE rides ADD start_month NVARCHAR(50);
ALTER TABLE rides ADD trip_duration INT;

-- 2. Update the new columns
UPDATE rides
SET 
    start_hour = DATEPART(HOUR, started_at),
    day_of_week = DATENAME(WEEKDAY, started_at),
    start_month = DATENAME(MONTH, started_at),
    trip_duration = DATEDIFF(MINUTE, started_at, ended_at);

-- 3. Delete rows where trip_duration <= 0
DELETE FROM rides
WHERE trip_duration <= 0;


-- 1. Add the new column trip_distance
ALTER TABLE rides ADD trip_distance FLOAT;

-- 2. Compute and update the trip_distance in miles
-- In this corrected version, I've prefixed all ambiguous column references with the RideDistances 
-- alias to clearly indicate from which source (the CTE) the columns should be used.



WITH RideDistances AS (
    SELECT
        ride_id, 
        start_lat,
        start_lng,
        end_lat,
        end_lng,
        RADIANS(end_lat - start_lat) AS dLat,
        RADIANS(end_lng - start_lng) AS dLng
    FROM rides
)
UPDATE rides
SET trip_distance = ROUND(
    3959.0 * 2 * ATN2( 
        SQRT(
            SQUARE(SIN(RideDistances.dLat/2)) + 
            COS(RADIANS(RideDistances.start_lat)) * COS(RADIANS(RideDistances.end_lat)) * 
            SQUARE(SIN(RideDistances.dLng/2))
        ),
        SQRT(1 - (
            SQUARE(SIN(RideDistances.dLat/2)) + 
            COS(RADIANS(RideDistances.start_lat)) * COS(RADIANS(RideDistances.end_lat)) * 
            SQUARE(SIN(RideDistances.dLng/2))
        ))
    ), 0) -- Rounded to 0 decimals
FROM RideDistances
WHERE rides.ride_id = RideDistances.ride_id;

DELETE FROM rides
WHERE trip_distance <= 0;

SELECT min(trip_distance),max(trip_distance),avg(trip_distance) FROM rides;

-- ChatGPT flag outliers: Write SQL Server sql to flag outliers 

ALTER TABLE rides ADD IsOutlier INT DEFAULT 0;

WITH Quartiles AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY trip_distance) OVER () AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY trip_distance) OVER () AS Q3
    FROM rides
)

, IQR AS (
    SELECT TOP 1
        Q1,
        Q3,
        Q3 - Q1 AS IQR
    FROM Quartiles
)

UPDATE r
SET IsOutlier = CASE 
                   WHEN trip_distance < (Q1 - 1.5*IQR) OR trip_distance > (Q3 + 1.5*IQR) THEN 1
                   ELSE 0
                END
FROM rides r
CROSS JOIN IQR;

WITH OutlierCounts AS (
    SELECT
        SUM(CASE WHEN IsOutlier = 0 THEN 1 ELSE 0 END) AS ZeroCount,
        SUM(CASE WHEN IsOutlier = 1 THEN 1 ELSE 0 END) AS OneCount,
        COUNT(*) AS Total
    FROM rides
)

SELECT
    ZeroCount,
    OneCount,
    CAST(ZeroCount AS FLOAT) / Total * 100 AS ZeroPercentage,
    CAST(OneCount AS FLOAT) / Total * 100 AS OnePercentage
FROM OutlierCounts;

--- Count /pecent rideable_types

WITH MemberCasualCounts AS (
    SELECT
        SUM(CASE WHEN member_casual = 'member' THEN 1 ELSE 0 END) AS MemberCount,
        SUM(CASE WHEN member_casual = 'casual' THEN 1 ELSE 0 END) AS CasualCount,
        COUNT(*) AS Total
    FROM rides
	WHERE IsOutlier = 0
)

SELECT
    MemberCount,
    CasualCount,
    round(CAST(MemberCount AS FLOAT) / Total * 100,2) AS MemberPercentage,
    round(CAST(CasualCount AS FLOAT) / Total * 100,2) AS CasualPercentage
FROM MemberCasualCounts;

-- Count and percents for Bike Type 
WITH RideableTypeCounts AS (
    SELECT
        SUM(CASE WHEN rideable_type = 'docked_bike' THEN 1 ELSE 0 END) AS DockedBikeCount,
        SUM(CASE WHEN rideable_type = 'classic_bike' THEN 1 ELSE 0 END) AS ClassicBikeCount,
        SUM(CASE WHEN rideable_type = 'electric_bike' THEN 1 ELSE 0 END) AS ElectricBikeCount,
        COUNT(*) AS Total
    FROM rides
	WHERE IsOutlier = 0
)

SELECT
    DockedBikeCount,
    ClassicBikeCount,
    ElectricBikeCount,
    CAST(DockedBikeCount AS FLOAT) / Total * 100 AS DockedBikePercentage,
    CAST(ClassicBikeCount AS FLOAT) / Total * 100 AS ClassicBikePercentage,
    CAST(ElectricBikeCount AS FLOAT) / Total * 100 AS ElectricBikePercentage
FROM RideableTypeCounts;

-- Month with most and least rides

-- Counting rides by month for rows where IsOutlier = 0
-- Counting rides by month for rows where IsOutlier = 0
WITH MonthlyRides AS (
    SELECT
        MONTH(start_date) AS MonthNumber,
        DATENAME(MONTH, start_date) AS MonthName,
        COUNT(*) AS RideCount
    FROM rides
    WHERE IsOutlier = 0
    GROUP BY MONTH(start_date), DATENAME(MONTH, start_date)
),

RankedRides AS (
    SELECT 
        MonthName,
        RideCount,
        ROW_NUMBER() OVER (ORDER BY RideCount DESC) AS DescRank,
        ROW_NUMBER() OVER (ORDER BY RideCount ASC) AS AscRank
    FROM MonthlyRides
)

-- Getting months with most and least rides
SELECT 
    MonthName,
    RideCount,
    CASE 
        WHEN DescRank = 1 THEN 'Most Rides'
        WHEN AscRank = 1 THEN 'Least Rides'
        ELSE 'Other'
    END AS Description
FROM RankedRides
WHERE DescRank = 1 OR AscRank = 1
ORDER BY RideCount DESC;

SELECT min(trip_distance),max(trip_distance), avg(trip_distance) 
FROM rides
WHERE IsOutlier = 0;

SELECT min(trip_duration),max(trip_duration), avg(trip_duration) 
FROM rides
WHERE IsOutlier = 0;

SELECT member_casual,start_date,count(*) as row_count
FROM rides
WHERE IsOutlier = 0
GROUP BY member_casual,start_date
ORDER BY member_casual,start_date;