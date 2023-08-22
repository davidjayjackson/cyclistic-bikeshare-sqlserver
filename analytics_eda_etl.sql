USE cyclistic
GO

ALTER TABLE analytics
DROP COLUMN ride_id, started_at, ended_at;
ALTER TABLE analytics
ADD ID INT IDENTITY(1,1) PRIMARY KEY;

--- 
-- Begin EDA/ETL
-- Trip duraton by date

SELECT start_date,
	count(*) as ride_count,
	sum(trip_distance) as sum_distance,
	avg(trip_distance) as avg_distance
INTO distance_by_date
	FROM analytics
	WHERE IsOutlier = 0
	GROUP BY start_date
ORDER BY start_date;

SELECT * FROM distance_by_date;

-- Trip duration by date

SELECT start_date,
	count(*) as ride_count,
	sum(trip_duration) as sum_duration,
	avg(trip_duration) as avg_duration
INTO distance_by_date
	FROM analytics
	WHERE IsOutlier = 0
	GROUP BY start_date
ORDER BY start_date;

-- duration and rideable_type

SELECT start_date,rideable_type,
	count(*) as ride_count,
	sum(trip_distance) as sum_distance,
	avg(trip_distance) as avg_distance
INTO rideable_type_distance
	FROM analytics
	WHERE IsOutlier = 0
	GROUP BY start_date,rideable_type
	ORDER BY start_date,rideable_type;

--drop TABLE rideable_type_duration;
SELECT * FROM rideable_type_distance;

-- Trip distance by date

SELECT start_date,rideable_type,
	count(*) as ride_count,rideable_type,
	sum(trip_duration) as sum_duration,
	avg(trip_duration) as avg_duration
INTO rideable_type_duration
	FROM analytics
	WHERE IsOutlier = 0
	GROUP BY start_date,rideable_type
ORDER BY start_date,rideable_type;

-- trip distance by bike type

SELECT start_date,rideable_type,
	count(*) as ride_count,
	sum(trip_distance) as sum_distance,
	avg(trip_distance) as avg_distance
INTO rideable_type_distance
	FROM analytics
	WHERE IsOutlier = 0
	GROUP BY start_date,rideable_type
ORDER BY start_date,rideable_type;

SELECT * FROM rideable_type_distance;

-- Member vs casual riders

-- Trip duration by date

SELECT start_date,member_casual,
	count(*) as ride_count,
	sum(trip_duration) as sum_duration,
	avg(trip_duration) as avg_duration
INTO member_casual_duration
	FROM analytics
	WHERE IsOutlier = 0
	GROUP BY start_date,member_casual
ORDER BY start_date,member_casual;

-- trip distance by bike type

SELECT start_date,member_casual,
	count(*) as ride_count,
	sum(trip_distance) as sum_distance,
	avg(trip_distance) as avg_distance
INTO member_casual_distance
	FROM analytics
	WHERE IsOutlier = 0
	GROUP BY start_date,member_casual
ORDER BY start_date,member_casual;

SELECT * FROM member_casual_distance;

-- start date and start hour

SELECT start_date,start_hour,
	count(*) as ride_count,
	sum(trip_duration) as sum_duration,
	avg(trip_duration) as avg_duration
INTO start_hour_duration
	FROM analytics
	WHERE IsOutlier = 0
	GROUP BY start_date,start_hour
ORDER BY start_date,start_hour;

-- trip distance by bike type

SELECT start_date,start_hour,
	count(*) as ride_count,
	sum(trip_distance) as sum_distance,
	avg(trip_distance) as avg_distance
INTO start_hour_distance
	FROM analytics
	WHERE IsOutlier = 0
	GROUP BY start_date,start_hour
ORDER BY start_date,start_hour;

-- Top 20 start stations

-- Create a temporary table containing the top 20 start stations by row count
WITH Top20Stations AS (
    SELECT TOP 20 start_station_name
    FROM analytics
    GROUP BY start_station_name
    ORDER BY COUNT(*) DESC
)

-- Create the new table containing the rows for the top 20 start stations
SELECT a.*
INTO top_start_stations  -- Replace 'new_table_name' with your desired table name
FROM analytics a
INNER JOIN Top20Stations t
ON a.start_station_name = t.start_station_name;

SELECT * FROM top_start_stations;

-- Rank stations by row count
WITH RankedStations AS (
    SELECT 
        start_station_name,
        COUNT(*) as station_count,
        RANK() OVER (ORDER BY COUNT(*) DESC) AS rank,
        DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS dense_rank
    FROM analytics
    GROUP BY start_station_name
)

-- Calculate the total rows in the analytics table
, TotalRows AS (
    SELECT COUNT(*) as total_count FROM analytics
)

-- Select the desired columns into the new table
SELECT 
    rs.start_station_name,
    rs.station_count,
    rs.rank,
    rs.dense_rank,
    CAST(ROUND((rs.station_count * 100.0 / tr.total_count), 2) AS DECIMAL(10, 2)) AS station_percentage
INTO station_rank
FROM RankedStations rs
CROSS JOIN TotalRows tr
WHERE rs.rank <21;



DROP TABLE station_rank;
SELECT * FROM station_rank;

--- top 10 stations daily summary
-- Identify the top 10 stations from station_rank
WITH Top10Stations AS (
    SELECT TOP 10 start_station_name
    FROM station_rank
    ORDER BY rank
)

-- Join with the analytics table and aggregate the results
SELECT 
    a.start_station_name,
    a.start_date,
    COUNT(*) as row_count,
    SUM(a.trip_duration) as total_trip_duration,
    AVG(a.trip_duration) as avg_trip_duration,
    SUM(a.trip_distance) as total_trip_distance,
    CAST(ROUND(AVG(a.trip_distance), 2) AS DECIMAL(10, 2)) as avg_trip_distance
INTO new_analytics_summary
FROM analytics a
INNER JOIN Top10Stations t ON a.start_station_name = t.start_station_name
GROUP BY a.start_station_name, a.start_date
ORDER BY a.start_station_name, a.start_date;



SELECT *FROM new_analytics_summary;
DROP TABLE new_analytics_summary