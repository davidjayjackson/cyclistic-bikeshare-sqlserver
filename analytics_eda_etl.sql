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
