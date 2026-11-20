-- ==============================================================================
-- NETFLIX CONTENT ANALYTICS DATABASE QUERIES
-- Database Dialect: ANSI SQL / PostgreSQL / MySQL / BigQuery
-- Data Model: Star Schema (Fact: Titles | Bridges: Genre, Country)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. TABLE DEFINITION & SCHEMA SETUP
-- ------------------------------------------------------------------------------

-- Fact Table: Content Titles
CREATE TABLE titles (
    show_id VARCHAR(20) PRIMARY KEY,
    type VARCHAR(20),                      -- 'Movie' or 'TV Show'
    title VARCHAR(500),
    director VARCHAR(500),
    cast TEXT,
    country VARCHAR(255),
    date_added DATE,
    release_year INT,
    rating VARCHAR(50),                    -- 'TV-MA', 'TV-14', 'R', 'PG-13', etc.
    duration VARCHAR(50),
    duration_value INT,                    -- Minutes for Movies, Season count for TV Shows
    year_added INT,
    description TEXT
);

-- Bridge Table: Genres (Normalized 1-to-Many)
CREATE TABLE genre (
    show_id VARCHAR(20),
    genre VARCHAR(100),
    PRIMARY KEY (show_id, genre),
    FOREIGN KEY (show_id) REFERENCES titles(show_id)
);

-- Bridge Table: Countries (Normalized 1-to-Many)
CREATE TABLE country (
    show_id VARCHAR(20),
    country VARCHAR(100),
    PRIMARY KEY (show_id, country),
    FOREIGN KEY (show_id) REFERENCES titles(show_id)
);

-- ------------------------------------------------------------------------------
-- 2. LIBRARY METRICS & CATALOG OVERVIEW
-- ------------------------------------------------------------------------------

-- Total Catalog Size and Format Split (Movies vs TV Shows)
SELECT 
    COUNT(*) AS total_titles,
    SUM(CASE WHEN type = 'Movie' THEN 1 ELSE 0 END) AS total_movies,
    SUM(CASE WHEN type = 'TV Show' THEN 1 ELSE 0 END) AS total_tv_shows,
    ROUND(SUM(CASE WHEN type = 'Movie' THEN 1.0 ELSE 0.0 END) * 100.0 / COUNT(*), 2) AS movie_pct,
    ROUND(SUM(CASE WHEN type = 'TV Show' THEN 1.0 ELSE 0.0 END) * 100.0 / COUNT(*), 2) AS tv_show_pct
FROM titles;

-- Average Movie Runtime & TV Show Season Distribution
SELECT 
    type,
    ROUND(AVG(duration_value), 2) AS avg_duration_metric,
    MIN(duration_value) AS min_duration,
    MAX(duration_value) AS max_duration
FROM titles
GROUP BY type;

-- ------------------------------------------------------------------------------
-- 3. CONTENT GROWTH & TEMPORAL RELEASE ANALYSIS
-- ------------------------------------------------------------------------------

-- Year-over-Year Catalog Additions (YoY Growth Rate)
WITH yearly_additions AS (
    SELECT 
        year_added,
        COUNT(*) AS titles_added,
        SUM(CASE WHEN type = 'Movie' THEN 1 ELSE 0 END) AS movies_added,
        SUM(CASE WHEN type = 'TV Show' THEN 1 ELSE 0 END) AS tv_shows_added
    FROM titles
    WHERE year_added IS NOT NULL
    GROUP BY year_added
)
SELECT 
    year_added,
    titles_added,
    movies_added,
    tv_shows_added,
    LAG(titles_added, 1) OVER (ORDER BY year_added) AS prev_year_titles,
    ROUND(
        (titles_added - LAG(titles_added, 1) OVER (ORDER BY year_added)) * 100.0 / 
        NULLIF(LAG(titles_added, 1) OVER (ORDER BY year_added), 0), 2
    ) AS yoy_growth_pct
FROM yearly_additions
ORDER BY year_added DESC;

-- Release Month Seasonality (When does Netflix release content?)
SELECT 
    EXTRACT(MONTH FROM date_added) AS release_month,
    TO_CHAR(date_added, 'Mon') AS month_name,
    COUNT(*) AS content_released_count
FROM titles
WHERE date_added IS NOT NULL
GROUP BY EXTRACT(MONTH FROM date_added), TO_CHAR(date_added, 'Mon')
ORDER BY content_released_count DESC;

-- ------------------------------------------------------------------------------
-- 4. GEOGRAPHIC & COUNTRY PRODUCTION ANALYSIS
-- ------------------------------------------------------------------------------

-- Top 15 Content-Producing Countries
SELECT 
    c.country,
    COUNT(DISTINCT t.show_id) AS total_titles,
    COUNT(DISTINCT CASE WHEN t.type = 'Movie' THEN t.show_id END) AS movies_produced,
    COUNT(DISTINCT CASE WHEN t.type = 'TV Show' THEN t.show_id END) AS tv_shows_produced
FROM country c
JOIN titles t ON c.show_id = t.show_id
WHERE c.country <> 'Unknown'
GROUP BY c.country
ORDER BY total_titles DESC
LIMIT 15;

-- ------------------------------------------------------------------------------
-- 5. GENRE POPULARITY & AUDIENCE MATURITY RATINGS
-- ------------------------------------------------------------------------------

-- Top 20 Content Genres Across Library
SELECT 
    g.genre,
    COUNT(DISTINCT t.show_id) AS total_titles_in_genre,
    ROUND(COUNT(DISTINCT t.show_id) * 100.0 / (SELECT COUNT(*) FROM titles), 2) AS genre_penetration_pct
FROM genre g
JOIN titles t ON g.show_id = t.show_id
GROUP BY g.genre
ORDER BY total_titles_in_genre DESC
LIMIT 20;

-- Content Rating Distribution by Content Type (Maturity Breakdown)
SELECT 
    rating,
    COUNT(*) AS total_count,
    SUM(CASE WHEN type = 'Movie' THEN 1 ELSE 0 END) AS movie_count,
    SUM(CASE WHEN type = 'TV Show' THEN 1 ELSE 0 END) AS tv_show_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM titles), 2) AS rating_share_pct
FROM titles
GROUP BY rating
ORDER BY total_count DESC;

-- Multi-Season vs Single-Season TV Shows
SELECT 
    CASE 
        WHEN duration_value = 1 THEN '1 Season (Limited Series/Debut)'
        WHEN duration_value <= 3 THEN '2-3 Seasons (Renewed)'
        ELSE '4+ Seasons (Flagship Franchise)'
    END AS series_longevity,
    COUNT(*) AS show_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM titles WHERE type = 'TV Show'), 2) AS pct_of_tv_catalog
FROM titles
WHERE type = 'TV Show'
GROUP BY 
    CASE 
        WHEN duration_value = 1 THEN '1 Season (Limited Series/Debut)'
        WHEN duration_value <= 3 THEN '2-3 Seasons (Renewed)'
        ELSE '4+ Seasons (Flagship Franchise)'
    END
ORDER BY show_count DESC;
