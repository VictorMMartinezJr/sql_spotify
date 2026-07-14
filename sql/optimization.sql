
--  CREATE ARTIST BASED INDEX TO IMPROVE QUERY PERFORMANCE ON ARTIST COLUMN
CREATE INDEX artist_index ON spotify(artist);

EXPLAIN ANALYZE
SELECT artist, track, views
FROM spotify
WHERE artist = 'Gorillaz' AND most_played_on = 'Youtube'
ORDER BY stream DESC
LIMIT 25;