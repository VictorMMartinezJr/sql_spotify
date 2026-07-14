# Spotify SQL Project and Query Optimization
[Click Here to get Dataset](https://www.kaggle.com/datasets/sanjanchaudhari/spotify-dataset)

![Spotify Logo](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_logo.jpg)

## Overview
This project involves analyzing a Spotify dataset with various attributes about tracks, albums, and artists using **SQL**. It covers an end-to-end process of normalizing a denormalized dataset, performing SQL queries of varying complexity and optimizing query performance.
```sql
-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);
```

## Exploratory Analysis

### 1. COUNT THE TOTAL NUMBER OF ROWS/TRACKS IN THE SPOTIFY TABLE

```sql
SELECT COUNT(*) FROM spotify;
```

### 2. COUNT THE NUMBER OF UNIQUE ALBUMS IN THE DATASET

```sql
SELECT COUNT(DISTINCT album) FROM spotify;
```

### 3. COUNT THE NUMBER OF UNIQUE ARTISTS IN THE DATASET

```sql
SELECT COUNT(DISTINCT artist) FROM spotify;
```

### 4. LIST ALL UNIQUE TYPES OF ALBUMS (E.G., ALBUM, SINGLE, COMPILATION)

```sql
SELECT DISTINCT album_type FROM spotify;
```

### 5. FIND THE LONGEST TRACK DURATION IN MINUTES

```sql
SELECT MAX(duration_min) FROM spotify;
```

### 6. FIND THE SHORTEST TRACK DURATION IN MINUTES

```sql
SELECT MIN(duration_min) FROM spotify;
```

### 7. LIST ALL UNIQUE CHANNELS ASSOCIATED WITH THE TRACKS

```sql
SELECT DISTINCT channel FROM spotify;
```

### 8. LIST ALL UNIQUE PLATFORMS WHERE THE SONGS ARE MOST PLAYED

```sql
SELECT DISTINCT most_played_on FROM spotify;
```

## Cleaning

### 1. DELETE ROWS WITH DURATION OF 0 MINUTES

```sql
DELETE FROM spotify
WHERE duration_min = 0;
```

## Business Problems and Analysis

### 1. Retrieve the names of all tracks that have more than 1 billion streams
```sql
SELECT * FROM spotify 
WHERE stream > 1000000000;
```

### 2. List all albums along with their respective artists
```sql
SELECT DISTINCT album, artist FROM spotify
ORDER BY 1;
```

### 3. Get the total number of comments for tracks where licensed = TRUE
```sql
SELECT SUM(comments) as total_comments 
FROM spotify
WHERE licensed = 'true';
```

### 4. Find all tracks that belong to the album type single
```sql
SELECT * FROM spotify
WHERE album_type = 'single';
```

### 5. Count the total number of tracks by each artist
```sql
SELECT artist, COUNT(*) AS total_tracks
FROM spotify
GROUP BY artist
ORDER BY artist;
```

### 6. Calculate the average danceability of tracks in each album
```sql
SELECT DISTINCT album, AVG(danceability) AS avg_danceability
FROM spotify
GROUP BY album
ORDER BY 2 DESC;
```

### 7. Find the top 5 tracks with the highest energy values
```sql
SELECT artist, track, energy
FROM spotify
ORDER BY energy DESC
LIMIT 5;
```

### 8. List all tracks along with their views and likes where official_video = TRUE
```sql
SELECT 
	track,
	SUM(views) AS total_views,
	SUM(likes) AS total_likes
FROM spotify 
WHERE official_video = 'true'
GROUP BY track
ORDER BY track;
```

### 9. For each album, calculate the total views of all associated tracks
```sql
SELECT album, track, SUM(views) as total_views 
FROM spotify
GROUP BY album, track
ORDER BY total_views DESC;
```

### 10. Retrieve the track names that have been streamed on Spotify more than YouTube
```sql
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
```

### 11. Find the top 3 most-viewed tracks for each artist using window functions
```sql
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
```

### 12. Write a query to find tracks where the liveness score is above the average
```sql
SELECT track, artist, liveness
FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify)
ORDER BY track;
```

### 13. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album
```sql
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
```

## Query Optimization Technique 

To improve query performance, we carried out the following optimization process:

- **Initial Query Performance Analysis Using `EXPLAIN`**
    - We began by analyzing the performance of a query using the `EXPLAIN` function.
    - The query retrieved tracks based on the `artist` column, and the performance metrics were as follows:
        - Execution time (E.T.): **7 ms**
        - Planning time (P.T.): **0.17 ms**
    - Below is the **screenshot** of the `EXPLAIN` result before optimization:
      ![EXPLAIN Before Index](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_explain_before_index.png)

- **Index Creation on the `artist` Column**
    - To optimize the query performance, we created an index on the `artist` column. This ensures faster retrieval of rows where the artist is queried.
    - **SQL command** for creating the index:
      ```sql
      CREATE INDEX artist_index ON spotify(artist);
      ```

- **Performance Analysis After Index Creation**
    - After creating the index, we ran the same query again and observed significant improvements in performance:
        - Execution time (E.T.): **0.153 ms**
        - Planning time (P.T.): **0.152 ms**
    - Below is the **screenshot** of the `EXPLAIN` result after index creation:
      ![EXPLAIN After Index](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_explain_after_index.png)

- **Graphical Performance Comparison**
    - A graph illustrating the comparison between the initial query execution time and the optimized query execution time after index creation.
    - **Graph view** shows the significant drop in both execution and planning times:
      ![Performance Graph](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_graphical%20view%203.png)
      ![Performance Graph](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_graphical%20view%202.png)
      ![Performance Graph](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_graphical%20view%201.png)

This optimization shows how indexing can drastically reduce query time, improving the overall performance of our database operations in the Spotify project.
---

## Technology Stack
- **Database**: PostgreSQL
- **SQL Queries**: DDL, DML, Aggregations, Joins, Subqueries, Window Functions
- **Tools**: pgAdmin 4 (or any SQL editor), PostgreSQL (via Homebrew, Docker, or direct installation)

## How to Run the Project
1. Install PostgreSQL and pgAdmin (if not already installed).
2. Set up the database schema and tables using the provided normalization structure.
3. Insert the sample data into the respective tables.
4. Execute SQL queries to solve the listed problems.
5. Explore query optimization techniques for large datasets.

---

## Next Steps
- **Visualize the Data**: Use a data visualization tool like **Tableau** or **Power BI** to create dashboards based on the query results.
