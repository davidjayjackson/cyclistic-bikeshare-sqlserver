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

-- Calculate ride distance using: start_lat, start_lng, end_lat,end_lng
-- 1. Add the new column trip_distance
ALTER TABLE rides DROP COLUMN trip_distance;
ALTER TABLE rides ADD trip_distance FLOAT;

-- 2. Compute and update the trip_distance in miles
WITH RideDistances AS (
    SELECT
        rid.ride_id, -- Assuming there's a unique identifier for each ride. Adjust as necessary.
        rid.start_lat,
        rid.start_lng,
        rid.end_lat,
        rid.end_lng,
        RADIANS(rid.end_lat - rid.start_lat) AS dLat,
        RADIANS(rid.end_lng - rid.start_lng) AS dLng
    FROM rides as rid
)
UPDATE rides
SET trip_distance = 3959.0 * 2 * ATN2( 
        SQRT(
            SQUARE(SIN(dLat/2)) + 
            COS(RADIANS(rd.start_lat)) * COS(RADIANS(rd.end_lat)) * 
            SQUARE(SIN(dLng/2))
        ),
        SQRT(1 - (
            SQUARE(SIN(dLat/2)) + 
            COS(RADIANS(rd.start_lat)) * COS(RADIANS(rd.end_lat)) * 
            SQUARE(SIN(dLng/2))
        ))
    )
FROM RideDistances as rd
WHERE rides.ride_id = rd.ride_id; -- Join on the unique identifier. Adjust as necessary.

