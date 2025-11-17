/*
===============================================================================
ANALYSIS QUERIES - MovieLens Database
===============================================================================
Script Purpose:
    This script contains various analytical queries for exploring the MovieLens
    dataset, including:
    - Most rated movies
    - Most active users
    - Rating trends over time
    - Popular tags
    - Top-rated movies (quality with threshold)

Usage:
    Execute individual queries or sections as needed for analysis
===============================================================================
*/

USE MovieLens;
GO

-- =====================================================================
-- Query 1: Most Rated Movies (Top 10)
-- =====================================================================
-- Purpose: Identify which movies have received the most ratings
-- Business Value: Understand which movies are most popular/watched

SELECT TOP 10
    r.movieId,
    m.title,
    COUNT(*) AS ratings_count
FROM dbo.ratings AS r
INNER JOIN dbo.movies AS m ON m.movieId = r.movieId
GROUP BY r.movieId, m.title
ORDER BY ratings_count DESC, m.title;
GO

-- =====================================================================
-- Query 2: Most Active Users (Top 10)
-- =====================================================================
-- Purpose: Identify users who rate the most movies
-- Business Value: Understand user engagement and power users

SELECT TOP 10
    r.userId,
    COUNT(*) AS ratings_count
FROM dbo.ratings AS r
GROUP BY r.userId
ORDER BY ratings_count DESC, r.userId;
GO

-- =====================================================================
-- Query 3: Ratings Per Year
-- =====================================================================
-- Purpose: Analyze rating activity trends over time
-- Business Value: Understand platform growth and user engagement trends

SELECT 
    YEAR(r.rating_ts) AS yr,
    COUNT(*) AS ratings_count
FROM dbo.ratings AS r
GROUP BY YEAR(r.rating_ts)
ORDER BY yr;
GO

-- =====================================================================
-- Query 4: Top 15 Tags by Frequency
-- =====================================================================
-- Purpose: Identify most commonly used tags
-- Business Value: Understand how users categorize and describe movies

SELECT TOP 15
    LOWER(LTRIM(RTRIM(t.tag))) AS tag_norm,
    COUNT(*) AS uses
FROM dbo.tags AS t
GROUP BY LOWER(LTRIM(RTRIM(t.tag)))
ORDER BY uses DESC, tag_norm;
GO

-- =====================================================================
-- Query 5: Top Rated Movies (Quality) with Minimum Rating Threshold
-- =====================================================================
-- Purpose: Find highest quality movies with sufficient number of ratings
-- Business Value: Identify critically acclaimed movies for recommendations
-- Note: Requires minimum 50 ratings to avoid bias from few ratings

WITH agg AS (
    SELECT 
        r.movieId,
        COUNT(*) AS n,
        ROUND(AVG(r.rating), 2) AS avg_rating
    FROM dbo.ratings AS r
    GROUP BY r.movieId
)
SELECT TOP 10
    a.movieId,
    m.title,
    a.n AS ratings_count,
    a.avg_rating
FROM agg AS a
INNER JOIN dbo.movies AS m ON m.movieId = a.movieId
WHERE a.n >= 50  -- Minimum rating threshold
ORDER BY a.avg_rating DESC, a.n DESC, m.title;
GO

-- =====================================================================
-- Additional Analysis: Rating Distribution
-- =====================================================================
-- Purpose: Understand how ratings are distributed across the scale
-- Business Value: Identify rating patterns and user behavior

SELECT 
    rating,
    COUNT(*) AS count,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) AS percentage
FROM dbo.ratings
GROUP BY rating
ORDER BY rating DESC;
GO

-- =====================================================================
-- Additional Analysis: Movies by Genre Popularity
-- =====================================================================
-- Purpose: Identify which genres receive the most ratings
-- Business Value: Content strategy and acquisition decisions

SELECT TOP 10
    -- Extract first genre from pipe-separated list
    CASE 
        WHEN CHARINDEX('|', m.genres) > 0 
        THEN LEFT(m.genres, CHARINDEX('|', m.genres) - 1)
        ELSE m.genres
    END AS primary_genre,
    COUNT(DISTINCT r.movieId) AS movies_count,
    COUNT(r.rating) AS ratings_count,
    ROUND(AVG(r.rating), 2) AS avg_rating
FROM dbo.movies AS m
INNER JOIN dbo.ratings AS r ON m.movieId = r.movieId
GROUP BY 
    CASE 
        WHEN CHARINDEX('|', m.genres) > 0 
        THEN LEFT(m.genres, CHARINDEX('|', m.genres) - 1)
        ELSE m.genres
    END
ORDER BY ratings_count DESC;
GO

-- =====================================================================
-- Additional Analysis: User Engagement Over Time
-- =====================================================================
-- Purpose: Track monthly active users and rating activity
-- Business Value: Platform health and growth metrics

SELECT 
    YEAR(rating_ts) AS year,
    MONTH(rating_ts) AS month,
    COUNT(DISTINCT userId) AS active_users,
    COUNT(*) AS ratings_count,
    ROUND(AVG(rating), 2) AS avg_rating
FROM dbo.ratings
GROUP BY YEAR(rating_ts), MONTH(rating_ts)
ORDER BY year, month;
GO

-- =====================================================================
-- Additional Analysis: Movies with Most Tags
-- =====================================================================
-- Purpose: Identify movies that users describe the most
-- Business Value: Understand which movies generate most discussion

SELECT TOP 10
    m.title,
    COUNT(DISTINCT t.tag) AS unique_tags,
    COUNT(*) AS total_tag_applications
FROM dbo.tags AS t
INNER JOIN dbo.movies AS m ON t.movieId = m.movieId
GROUP BY m.title
ORDER BY unique_tags DESC, total_tag_applications DESC;
GO
