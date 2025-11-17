/*
===============================================================================
BULK INSERT SCRIPT - Load MovieLens Data
===============================================================================
Script Purpose:
    This script loads data from CSV files into the MovieLens database tables.
    
IMPORTANT - Path Configuration:
    The data files are expected to be in: C:\MovieLens\datasets\
    
    If your files are in a different location, update the file paths below
    using Find & Replace:
        Find:    'C:\MovieLens\datasets\'
        Replace: 'YOUR_PATH_HERE\'
    
    Expected folder structure:
        C:\MovieLens\datasets\
        ├── movies.csv
        ├── ratings.csv
        ├── tags.csv
        └── links.csv

Prerequisites:
    - Database 'MovieLens' must exist (run 01_create_database_tables.sql first)
    - CSV files must be accessible at the specified paths
    - SQL Server service account must have read permissions on the folder

Usage:
    Execute this script in SQL Server Management Studio (SSMS)
===============================================================================
*/

USE MovieLens;
GO

DECLARE @start_time DATETIME, @end_time DATETIME;

PRINT '=========================================='
PRINT 'Loading MovieLens Data'
PRINT '=========================================='
PRINT ''

-- =====================================================================
-- Load: movies.csv
-- =====================================================================

SET @start_time = GETDATE();
PRINT 'Loading movies.csv...'

BULK INSERT dbo.movies
FROM 'C:\MovieLens\datasets\movies.csv'
WITH (
    FIRSTROW = 2,                    -- Skip header row
    FIELDTERMINATOR = ',',           -- Comma-separated
    ROWTERMINATOR = '\n',            -- Line break
    TABLOCK,
    CODEPAGE = '65001'               -- UTF-8 encoding
);

SET @end_time = GETDATE();

DECLARE @movies_count INT = (SELECT COUNT(*) FROM dbo.movies);
PRINT '  ✓ Movies loaded: ' + CAST(@movies_count AS NVARCHAR) + ' rows';
PRINT '  ✓ Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
PRINT ''

-- =====================================================================
-- Load: ratings.csv
-- =====================================================================

SET @start_time = GETDATE();
PRINT 'Loading ratings.csv...'

-- Create temp table for initial load
IF OBJECT_ID('tempdb..#temp_ratings') IS NOT NULL
    DROP TABLE #temp_ratings;

CREATE TABLE #temp_ratings (
    userId    INT,
    movieId   INT,
    rating    DECIMAL(2,1),
    ts_unix   BIGINT
);

BULK INSERT #temp_ratings
FROM 'C:\MovieLens\datasets\ratings.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- Insert into final table with timestamp conversion
INSERT INTO dbo.ratings (userId, movieId, rating, ts_unix, rating_ts)
SELECT 
    userId,
    movieId,
    rating,
    ts_unix,
    DATEADD(SECOND, ts_unix, '1970-01-01') AS rating_ts  -- Convert Unix timestamp to datetime
FROM #temp_ratings;

DROP TABLE #temp_ratings;

SET @end_time = GETDATE();

DECLARE @ratings_count INT = (SELECT COUNT(*) FROM dbo.ratings);
PRINT '  ✓ Ratings loaded: ' + CAST(@ratings_count AS NVARCHAR) + ' rows';
PRINT '  ✓ Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
PRINT ''

-- =====================================================================
-- Load: tags.csv
-- =====================================================================

SET @start_time = GETDATE();
PRINT 'Loading tags.csv...'

-- Create temp table for initial load
IF OBJECT_ID('tempdb..#temp_tags') IS NOT NULL
    DROP TABLE #temp_tags;

CREATE TABLE #temp_tags (
    userId    INT,
    movieId   INT,
    tag       NVARCHAR(255),
    ts_unix   BIGINT
);

BULK INSERT #temp_tags
FROM 'C:\MovieLens\datasets\tags.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = '65001'  -- UTF-8 for special characters in tags
);

-- Insert into final table with timestamp conversion
INSERT INTO dbo.tags (userId, movieId, tag, ts_unix, tag_ts)
SELECT 
    userId,
    movieId,
    tag,
    ts_unix,
    DATEADD(SECOND, ts_unix, '1970-01-01') AS tag_ts  -- Convert Unix timestamp to datetime
FROM #temp_tags;

DROP TABLE #temp_tags;

SET @end_time = GETDATE();

DECLARE @tags_count INT = (SELECT COUNT(*) FROM dbo.tags);
PRINT '  ✓ Tags loaded: ' + CAST(@tags_count AS NVARCHAR) + ' rows';
PRINT '  ✓ Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
PRINT ''

-- =====================================================================
-- Load: links.csv
-- =====================================================================

SET @start_time = GETDATE();
PRINT 'Loading links.csv...'

-- Create temp table for initial load
IF OBJECT_ID('tempdb..#temp_links') IS NOT NULL
    DROP TABLE #temp_links;

CREATE TABLE #temp_links (
    movieId INT,
    imdbId  NVARCHAR(50),  -- Load as string first to handle empty/null values
    tmdbId  NVARCHAR(50)
);

BULK INSERT #temp_links
FROM 'C:\MovieLens\datasets\links.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- Insert into final table with NULL handling
INSERT INTO dbo.links (movieId, imdbId, tmdbId)
SELECT 
    movieId,
    CASE 
        WHEN TRIM(imdbId) = '' OR imdbId IS NULL THEN NULL
        ELSE TRY_CAST(imdbId AS INT)
    END AS imdbId,
    CASE 
        WHEN TRIM(tmdbId) = '' OR tmdbId IS NULL OR tmdbId = '\N' THEN NULL
        ELSE TRY_CAST(tmdbId AS INT)
    END AS tmdbId
FROM #temp_links;

DROP TABLE #temp_links;

SET @end_time = GETDATE();

DECLARE @links_count INT = (SELECT COUNT(*) FROM dbo.links);
PRINT '  ✓ Links loaded: ' + CAST(@links_count AS NVARCHAR) + ' rows';
PRINT '  ✓ Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
PRINT ''

-- =====================================================================
-- Summary
-- =====================================================================

PRINT '=========================================='
PRINT 'Data Load Complete!'
PRINT '=========================================='
PRINT ''
PRINT 'Row counts:'
SELECT 'movies' AS [Table], COUNT(*) AS [Rows] FROM dbo.movies
UNION ALL SELECT 'ratings', COUNT(*) FROM dbo.ratings
UNION ALL SELECT 'tags', COUNT(*) FROM dbo.tags
UNION ALL SELECT 'links', COUNT(*) FROM dbo.links;

PRINT ''
PRINT 'Database ready for analysis!'
PRINT '=========================================='
GO
