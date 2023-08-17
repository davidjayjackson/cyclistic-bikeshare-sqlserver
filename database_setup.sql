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
