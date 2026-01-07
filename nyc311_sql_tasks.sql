CREATE TABLE IF NOT EXISTS nyc311_raw (
    "Unique Key" INTEGER PRIMARY KEY,
    "Created Date" TEXT,
    "Closed Date" TEXT,
    "Complaint Type" TEXT,
    "Descriptor" TEXT,
    "Status" TEXT,
    "Resolution Description" TEXT,
    "Borough" TEXT,
    "Incident Zip" TEXT,
    "Latitude" REAL,
    "Longitude" REAL,
    "Agency Name" TEXT
);


SELECT name FROM sqlite_master WHERE type='table';
SELECT COUNT(*) AS total_rows FROM nyc311_raw;



CREATE TABLE IF NOT EXISTS nyc311_sourced AS
SELECT 
    "Unique Key",
    DATE("Created Date") AS created_date,
    DATE("Closed Date") AS closed_date,
    "Complaint Type",
    "Descriptor",
    "Status",
    "Resolution Description",
    "Borough",
    "Incident Zip",
    "Latitude",
    "Longitude",
    "Agency Name"
FROM nyc311_raw
WHERE "Unique Key" IS NOT NULL
  AND "Created Date" IS NOT NULL;



CREATE TABLE IF NOT EXISTS nyc311_cleaned AS
SELECT *
FROM nyc311_sourced
WHERE rowid IN (
    SELECT MIN(rowid)
    FROM nyc311_sourced
    GROUP BY "Unique Key"
);



SELECT "Complaint Type", COUNT(*) AS count
FROM nyc311_cleaned
GROUP BY "Complaint Type"
ORDER BY count DESC;

SELECT Borough, COUNT(*) AS count
FROM nyc311_cleaned
GROUP BY Borough
ORDER BY count DESC;


SELECT Status, COUNT(*) AS count
FROM nyc311_cleaned
GROUP BY Status
ORDER BY count DESC;


SELECT "Complaint Type", COUNT(*) AS count
FROM nyc311_cleaned
GROUP BY "Complaint Type"
ORDER BY count DESC
LIMIT 10;

SELECT *
FROM nyc311_cleaned
WHERE Borough = 'BROOKLYN'
LIMIT 100;


SELECT *
FROM nyc311_cleaned
WHERE Latitude IS NULL
   OR Longitude IS NULL
   OR Latitude NOT BETWEEN -90 AND 90
   OR Longitude NOT BETWEEN -180 AND 180;

SELECT *
FROM nyc311_cleaned
WHERE Borough IS NULL OR Borough = '';

SELECT COUNT(*) AS raw_count FROM nyc311_raw;

SELECT COUNT(*) AS cleaned_count FROM nyc311_cleaned;

SELECT COUNT(*) AS invalid_coordinates
FROM nyc311_cleaned
WHERE latitude NOT BETWEEN -90 AND 90
   OR longitude NOT BETWEEN -180 AND 180;
-- Records with invalid coordinates were excluded to ensure geospatial accuracy

SELECT unique_key, COUNT(*)
FROM nyc311_cleaned
GROUP BY unique_key
HAVING COUNT(*) > 1;
