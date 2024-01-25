-- Identify movie ratings, movie popularity and genres

-- popularity rating of original titles
SELECT tmdbid, title, popularity
FROM tmdb_movie_dataset
GROUP BY tmdbid, title, popularity
ORDER BY 3 DESC

-- popularity of original titles with genres
SELECT tmdbid, 
       original_title, 
       popularity, 
       jsonb_array_elements(genres::jsonb)->>'name' AS genre
FROM tmdb_movie_dataset
GROUP BY tmdbid, original_title, genre, popularity
ORDER BY popularity DESC

-- check average user rating of each movie title
SELECT tmdbid, title, AVG(rating) AS avg_rating
FROM tmdb_movie_dataset AS dataset 
JOIN tmdb_movie_ratings AS rate
    ON dataset.ratingid = rate.ratingid
GROUP BY tmdbid, title
ORDER BY avg_rating DESC, 1

-- comparison of rating and popularity per movie title
SELECT tmdbid,
       title,
       AVG(rating) AS avg_rating,
       popularity
FROM tmdb_movie_dataset AS dataset 
FULL OUTER JOIN tmdb_movie_ratings AS rate
    ON dataset.ratingid = rate.ratingid
GROUP BY tmdbid, title, popularity 
ORDER BY popularity DESC, 1

-- creation of a new table that will join key data into one
SELECT 
    tmdbid,
    title,
    AVG(rating) AS avg_rating,
    popularity,
    original_language,
    revenue,
    budget,
    revenue - budget AS profit,
    release_date,
    runtime
FROM tmdb_movie_dataset AS dataset 
FULL OUTER JOIN tmdb_movie_ratings AS rate
    ON dataset.ratingid = rate.ratingid
GROUP BY
    tmdbid,
    title,
    popularity,
    original_language,
    revenue,
    budget,
    release_date,
    runtime
ORDER BY popularity DESC, 1

-- top grossing movie
WITH movie_data_cte AS (
    SELECT 
        tmdbid,
        title,
        AVG(rating) AS avg_rating,
        popularity,
        original_language,
        revenue,
        budget,
        revenue - budget AS profit,
        release_date,
        runtime
    FROM tmdb_movie_dataset AS dataset 
    FULL OUTER JOIN tmdb_movie_ratings AS rate
        ON dataset.ratingid = rate.ratingid
    GROUP BY
        tmdbid,
        title,
        popularity,
        original_language,
        revenue,
        budget,
        release_date,
        runtime
)
SELECT title, revenue, budget, profit
FROM movie_data_cte
WHERE revenue IS NOT NULL AND budget IS NOT NULL
ORDER BY profit DESC

-- measuring what genres does the user wants
SELECT 
    jsonb_array_elements(genres::jsonb)->>'name' AS genre,
    AVG(popularity) AS avg_popularity,
    AVG(rating) AS avg_rating
FROM tmdb_movie_dataset AS data
JOIN tmdb_movie_ratings AS rate
    ON data.ratingid = rate.ratingid
GROUP BY genre
ORDER BY avg_rating DESC

-- optimizing budget allocation for movie production to maximize revenue
SELECT
    jsonb_array_elements(genres::jsonb)->>'name' AS genre,
    AVG(popularity) AS avg_popularity,
    AVG(rating) AS avg_rating,
    AVG(revenue) AS avg_revenue,
    AVG(budget) AS avg_budget,
    AVG(revenue) - AVG(budget) AS avg_profit
FROM tmdb_movie_dataset AS data
JOIN tmdb_movie_ratings AS rate
    ON data.ratingid = rate.ratingid
GROUP BY genre
ORDER BY avg_revenue DESC

-- identifying which genres do the users like more
 
WITH genres_cte AS (
    SELECT
        tmdbid,
        title,
        jsonb_array_elements(genres::jsonb)->>'name' AS genre
    FROM tmdb_movie_dataset
)
SELECT
    rate.userid,
    genres_cte.genre,
    AVG(rate.rating) AS avg_rate,
    AVG(popularity) AS avg_popularity
FROM tmdb_movie_dataset AS data
JOIN tmdb_movie_ratings AS rate
    ON rate.ratingid = data.ratingid
JOIN genres_cte
    ON data.tmdbid = genres_cte.tmdbid
GROUP BY rate.userid, genres_cte.genre 
    HAVING rate.userid = 2
ORDER BY 1 ASC, 3 DESC
LIMIT 200


-- lists of movie titles suggestion per user based on their genre preference

WITH user_preference_cte AS (
    WITH genres_cte AS (
        SELECT
            tmdbid,
            title,
            jsonb_array_elements(genres::jsonb)->>'name' AS genre
        FROM tmdb_movie_dataset
    )
    SELECT
        rate.userid,
        genres_cte.genre,
        AVG(rate.rating) AS avg_rate,
        AVG(popularity) AS avg_popularity
    FROM tmdb_movie_dataset AS data
    JOIN tmdb_movie_ratings AS rate
        ON rate.ratingid = data.ratingid
    JOIN genres_cte
        ON data.tmdbid = genres_cte.tmdbid
    GROUP BY rate.userid, genres_cte.genre 
)
SELECT title, avg_rating, titles_per_genre.genre
FROM (
    SELECT
        tmdbid,
        title,
        AVG(rating) AS avg_rating,
        jsonb_array_elements(genres::jsonb)->>'name' AS genre
    FROM tmdb_movie_dataset AS data
    JOIN tmdb_movie_ratings AS rate
        ON data.ratingid = rate.ratingid
    GROUP BY tmdbid, title, genre
) AS titles_per_genre
JOIN user_preference_cte
    ON titles_per_genre.genre = user_preference_cte.genre
WHERE userid = 9000 AND avg_rate >= 4 AND avg_rating >= 4
ORDER BY 2 DESC
LIMIT 10


-- analyze on what month tends to have higher revenue

SELECT
    DISTINCT(release_month),
    COUNT(release_month) OVER (PARTITION BY release_month) AS movie_count
FROM (
    SELECT
        tmdbid,
        title,
        EXTRACT(MONTH FROM release_date::DATE) AS release_month
    FROM tmdb_movie_dataset
    ) AS movie_per_month
ORDER BY movie_count DESC


SELECT
    DISTINCT(release_month),
    AVG(revenue) OVER (PARTITION BY release_month) AS avg_revenue
FROM (
    SELECT
        tmdbid,
        title,
        revenue,
        EXTRACT(MONTH FROM release_date::DATE) AS release_month
    FROM tmdb_movie_dataset
    WHERE revenue > 0
    ) AS movie_per_month
ORDER BY avg_revenue DESC

