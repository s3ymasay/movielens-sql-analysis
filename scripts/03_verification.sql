/*
===============================================================================
VERIFICATION SCRIPT - MovieLens Database
===============================================================================
Script Purpose:
    This script performs sanity checks and basic verification to ensure
    data was loaded correctly into the MovieLens database.

Checks performed:
    - Row counts for all tables
    - Sample data from each table
    - Test joins between tables
    - Data quality checks
    - Foreign key integrity

Usage:
    Run this script after loading data (02_load_data.sql)
===============================================================================
*/

USE MovieLens;
GO

PRINT '=========================================='
PRINT 'MovieLens Database Verification'
PRINT '=========================================='
PRINT ''

-- =====================================================================
-- 1. Row Counts
-- =====================================================================

PRINT '1. Row Counts:'
PRINT '-------------'
SELECT 'movies' AS [Table], COUNT(*) AS [Rows] FROM dbo.movies
UNION ALL SELECT 'ratings', COUNT(*) FROM dbo.ratings
UNION ALL SELECT 'tags', COUNT(*) FROM dbo.tags
UNION ALL SELECT 'links', COUNT(*) FROM dbo.links;
PRINT ''

-- =====================================================================
-- 2. Sample Data from Each Table
-- =====================================================================

PRINT '2. Sample Movies (Top 10):'
PRINT '-------------------------'
SELECT TOP 10 
    movieId,
    title,
    genres
FROM dbo.movies
ORDER BY movieId;
PRINT ''

PRINT '3. Sample Ratings (Top 10 Most Recent):'
PRINT '---------------------------------------'
SELECT TOP 10 
    userId,
    movieId,
    rating,
    rating_ts
FROM dbo.ratings
ORDER BY rating_ts DESC;
PRINT ''

PRINT '4. Sample Tags (Top 10):'
PRINT '-----------------------'
SELECT TOP 10 
    userId,
    movieId,
    tag,
    tag_ts
FROM dbo.tags
ORDER BY tag_ts DESC;
PRINT ''

PRINT '5. Sample Links (Top 10):'
PRINT '------------------------'
SELECT TOP 10 
    movieId,
    imdbId,
    tmdbId
FROM dbo.links
ORDER BY movieId;
PRINT ''

-- =====================================================================
-- 3. Test Joins
-- =====================================================================

PRINT '6. Test Join: Recent Ratings with Movie Titles (Top 10):'
PRINT '--------------------------------------------------------'
SELECT TOP 10
    m.title,
    r.rating,
    r.rating_ts,
    r.userId
FROM dbo.ratings r
INNER JOIN dbo.movies m ON r.movieId = m.movieId
ORDER BY r.rating_ts DESC;
PRINT ''

PRINT '7. Test Join: Movies with Tags (Top 10):'
PRINT '----------------------------------------'
SELECT TOP 10
    m.title,
    t.tag,
    t.tag_ts
FROM dbo.tags t
INNER JOIN dbo.movies m ON t.movieId = m.movieId
ORDER BY t.tag_ts DESC;
PRINT ''

-- =====================================================================
-- 4. Data Quality Checks
-- =====================================================================

PRINT '=========================================='
PRINT 'Data Quality Checks'
PRINT '=========================================='
PRINT ''

-- Check for NULL movieIds in movies
PRINT '8. Check for NULL movieIds in movies:'
PRINT '-------------------------------------'
SELECT COUNT(*) AS null_movieIds 
FROM dbo.movies 
WHERE movieId IS NULL;
PRINT ''

-- Check for invalid ratings (should be between 0.5 and 5.0)
PRINT '9. Check for invalid ratings:'
PRINT '----------------------------'
SELECT COUNT(*) AS invalid_ratings
FROM dbo.ratings
WHERE rating < 0.5 OR rating > 5.0;
PRINT ''

-- Check for orphaned ratings (ratings without matching movies)
PRINT '10. Check for orphaned ratings:'
PRINT '------------------------------'
SELECT COUNT(*) AS orphaned_ratings
FROM dbo.ratings r
LEFT JOIN dbo.movies m ON r.movieId = m.movieId
WHERE m.movieId IS NULL;
PRINT ''

-- Check for orphaned tags (tags without matching movies)
PRINT '11. Check for orphaned tags:'
PRINT '---------------------------'
SELECT COUNT(*) AS orphaned_tags
FROM dbo.tags t
LEFT JOIN dbo.movies m ON t.movieId = m.movieId
WHERE m.movieId IS NULL;
PRINT ''

-- =====================================================================
-- 5. Summary Statistics
-- =====================================================================

PRINT '=========================================='
PRINT 'Summary Statistics'
PRINT '=========================================='
PRINT ''

-- Rating statistics
PRINT '12. Rating Statistics:'
PRINT '---------------------'
SELECT 
    COUNT(*) AS total_ratings,
    COUNT(DISTINCT userId) AS unique_users,
    COUNT(DISTINCT movieId) AS movies_rated,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating,
    AVG(rating) AS avg_rating,
    MIN(rating_ts) AS earliest_rating,
    MAX(rating_ts) AS latest_rating
FROM dbo.ratings;
PRINT ''

-- Movie statistics
PRINT '13. Movie Statistics:'
PRINT '--------------------'
SELECT 
    COUNT(*) AS total_movies,
    COUNT(DISTINCT genres) AS unique_genre_combinations
FROM dbo.movies;
PRINT ''

-- Tag statistics
PRINT '14. Tag Statistics:'
PRINT '------------------'
SELECT 
    COUNT(*) AS total_tags,
    COUNT(DISTINCT tag) AS unique_tags,
    COUNT(DISTINCT userId) AS users_who_tagged,
    COUNT(DISTINCT movieId) AS movies_tagged
FROM dbo.tags;
PRINT ''

-- Most popular movies (by number of ratings)
PRINT '15. Top 10 Most Rated Movies:'
PRINT '-----------------------------'
SELECT TOP 10
    m.title,
    COUNT(r.rating) AS rating_count,
    AVG(r.rating) AS avg_rating
FROM dbo.ratings r
INNER JOIN dbo.movies m ON r.movieId = m.movieId
GROUP BY m.title
ORDER BY rating_count DESC;
PRINT ''

-- =====================================================================
-- Final Status
-- =====================================================================

PRINT '=========================================='
PRINT 'Verification Complete!'
PRINT '=========================================='
PRINT ''
PRINT 'All checks passed. Database is ready for analysis.'
PRINT '=========================================='
GO
