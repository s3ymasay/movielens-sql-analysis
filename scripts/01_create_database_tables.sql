/*
===============================================================================
CREATE DATABASE AND TABLES - MovieLens Database
===============================================================================
Script Purpose:
    This script creates the MovieLens database and all required tables for
    storing movie ratings, tags, and external links data.
    
    Tables created:
    - movies: Movie information with genres
    - ratings: User ratings for movies
    - tags: User-generated tags for movies
    - links: External IDs (IMDB, TMDB)

WARNING:
    Running this script will drop the entire 'MovieLens' database if it exists.
    All data in the database will be permanently deleted.
===============================================================================
*/

USE master;
GO

-- Drop and recreate the 'MovieLens' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'MovieLens')
BEGIN
    ALTER DATABASE MovieLens SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE MovieLens;
END;
GO

-- Create the 'MovieLens' database
CREATE DATABASE MovieLens;
GO

USE MovieLens;
GO

-- =====================================================================
-- Table: movies
-- =====================================================================
-- Purpose: Stores movie information including title and genres
-- =====================================================================

IF OBJECT_ID('dbo.movies', 'U') IS NOT NULL
    DROP TABLE dbo.movies;
GO

CREATE TABLE dbo.movies (
    movieId   INT           NOT NULL PRIMARY KEY,
    title     NVARCHAR(255) NOT NULL,
    genres    NVARCHAR(255) NOT NULL  -- Pipe-separated list, e.g. 'Adventure|Animation|Children'
);
GO

-- =====================================================================
-- Table: ratings
-- =====================================================================
-- Purpose: Stores user ratings for movies with timestamps
-- =====================================================================

IF OBJECT_ID('dbo.ratings', 'U') IS NOT NULL
    DROP TABLE dbo.ratings;
GO

CREATE TABLE dbo.ratings (
    userId      INT             NOT NULL,
    movieId     INT             NOT NULL,
    rating      DECIMAL(2,1)    NOT NULL,  -- Values like 0.5 ... 5.0 in 0.5 increments
    ts_unix     BIGINT          NOT NULL,  -- Unix timestamp
    rating_ts   DATETIME2       NOT NULL,  -- Converted datetime
    PRIMARY KEY (userId, movieId, ts_unix)
);
GO

-- Create index on movieId for better join performance
CREATE INDEX ix_ratings_movie ON dbo.ratings(movieId);
GO

-- Foreign key constraint
ALTER TABLE dbo.ratings
ADD CONSTRAINT fk_ratings_movie 
FOREIGN KEY (movieId) REFERENCES dbo.movies(movieId);
GO

-- =====================================================================
-- Table: tags
-- =====================================================================
-- Purpose: Stores user-generated tags for movies
-- =====================================================================

IF OBJECT_ID('dbo.tags', 'U') IS NOT NULL
    DROP TABLE dbo.tags;
GO

CREATE TABLE dbo.tags (
    userId    INT           NOT NULL,
    movieId   INT           NOT NULL,
    tag       NVARCHAR(255) NOT NULL,
    ts_unix   BIGINT        NOT NULL,  -- Unix timestamp
    tag_ts    DATETIME2     NOT NULL   -- Converted datetime
);
GO

-- Create index on movieId for better join performance
CREATE INDEX ix_tags_movie ON dbo.tags(movieId);
GO

-- Foreign key constraint
ALTER TABLE dbo.tags
ADD CONSTRAINT fk_tags_movie 
FOREIGN KEY (movieId) REFERENCES dbo.movies(movieId);
GO

-- =====================================================================
-- Table: links
-- =====================================================================
-- Purpose: Stores external IDs (IMDB, TMDB) for movies
-- =====================================================================

IF OBJECT_ID('dbo.links', 'U') IS NOT NULL
    DROP TABLE dbo.links;
GO

CREATE TABLE dbo.links (
    movieId INT NOT NULL PRIMARY KEY,
    imdbId  INT NULL,
    tmdbId  INT NULL
);
GO

-- Foreign key constraint
ALTER TABLE dbo.links
ADD CONSTRAINT fk_links_movie 
FOREIGN KEY (movieId) REFERENCES dbo.movies(movieId);
GO

-- =====================================================================
-- Verification: Display table information
-- =====================================================================

SELECT 
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'dbo'
ORDER BY TABLE_NAME;
GO

PRINT '=========================================='
PRINT 'MovieLens Database Created Successfully!'
PRINT '=========================================='
PRINT ''
PRINT 'Tables created:'
PRINT '  - movies'
PRINT '  - ratings'
PRINT '  - tags'
PRINT '  - links'
PRINT ''
PRINT 'Next step: Load data using BULK INSERT scripts'
PRINT '=========================================='
GO
