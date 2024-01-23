-- Identify movie ratings, movie popularity and genres

-- popularity rating of original titles
SELECT tmdbid, original_title, AVG(popularity) AS avg_popularity
FROM tmdb_movie_dataset
GROUP BY tmdbid, original_title
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
SELECT tmdbid, original_title, AVG(rating) AS avg_rating
FROM tmdb_movie_dataset AS dataset 
JOIN tmdb_movie_ratings AS rate
    ON dataset.ratingid = rate.ratingid
GROUP BY tmdbid, original_title
ORDER BY avg_rating DESC, 1

-- comparison of rating and popularity per movie title
SELECT tmdbid, original_title,
       AVG(rating) AS avg_rating,
       AVG(popularity) AS avg_popularity
FROM tmdb_movie_dataset AS dataset 
FULL OUTER JOIN tmdb_movie_ratings AS rate
    ON dataset.ratingid = rate.ratingid
GROUP BY tmdbid, original_title 
ORDER BY avg_popularity DESC, 1

-- creation of a new table that will join key data into one

