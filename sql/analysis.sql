-- 1. Retrieve the names of all tracks that have more than 1 billion streams
SELECT * FROM spotify 
WHERE stream > 1000000000;

-- 2. List all albums along with their respective artists
SELECT DISTINCT album, artist FROM spotify
ORDER BY 1;

-- 3. Get the total number of comments for tracks where licensed = TRUE
SELECT SUM(comments) as total_comments 
FROM spotify
WHERE licensed = 'true';

-- 4. Find all tracks that belong to the album type single
SELECT * FROM spotify
WHERE album_type = 'single';

-- 5. Count the total number of tracks by each artist
SELECT artist, COUNT(*) AS total_tracks
FROM spotify
GROUP BY artist
ORDER BY artist;

-- 6. Calculate the average danceability of tracks in each album
SELECT DISTINCT album, AVG(danceability) AS avg_danceability
FROM spotify
GROUP BY album
ORDER BY 2 DESC;

-- 7. Find the top 5 tracks with the highest energy values
SELECT artist, track, energy
FROM spotify
ORDER BY energy DESC
LIMIT 5;

-- 8. List all tracks along with their views and likes where official_video = TRUE
SELECT 
	track,
	SUM(views) AS total_views,
	SUM(likes) AS total_likes
FROM spotify 
WHERE official_video = 'true'
GROUP BY track
ORDER BY track;

-- 9. For each album, calculate the total views of all associated tracks
SELECT album, track, SUM(views) as total_views 
FROM spotify
GROUP BY album, track
ORDER BY total_views DESC;

-- 10. Retrieve the track names that have been streamed on Spotify more than YouTube
SELECT *
FROM (
	SELECT 
		track,
		COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END), 0) AS streams_on_youtube,
		COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END), 0) AS streams_on_spotify
	FROM spotify
	GROUP BY track
	ORDER BY track
	)
WHERE streams_on_spotify > streams_on_youtube AND streams_on_youtube <> 0;

-- 11. Find the top 3 most-viewed tracks for each artist using window functions
SELECT * 
FROM (
	SELECT 
		artist, 
		track, 
		SUM(views) as total_views,
		DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) AS rank
	FROM spotify
	GROUP BY 1, 2
	ORDER BY 1, 3 DESC
)
WHERE rank <= 3 

-- 12. Write a query to find tracks where the liveness score is above the average
SELECT track, artist, liveness
FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify)
ORDER BY track;

-- 13. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album
WITH cte AS (
	SELECT 
		album,
		MAX(energy) AS max_energy_value,
		MIN(energy) AS min_energy_value
	FROM spotify
	GROUP BY 1
	)
SELECT album, (max_energy_value - min_energy_value) AS energy_difference
FROM cte
ORDER BY energy_difference DESC;