-- Level 1: Window Functions (The "Power of OVER")
-- Task 1: Continental Rankings (RANK) Rank every song by its Points (Total) but reset the ranking for each Continent.
-- * Concept: RANK() OVER (PARTITION BY Continent ORDER BY "Points (Total)" DESC)
SELECT
	Title,
	`Points (total)`,
	Continent,
	RANK() OVER (
		PARTITION BY
			Continent
		ORDER BY
			`Points (Total)` DESC
	)
FROM
	Spotify_Dataset_V3;

-- Task 2: Artist vs. Global Average (AVG OVER) Show each song's Danceability alongside the average Danceability for its specific Artist (Ind.).
-- * Concept: AVG(Danceability) OVER (PARTITION BY "Artist (Ind.)")
SELECT
	Artists,
	Title,
	Danceability,
	AVG(Danceability) OVER (
		PARTITION BY
			`Artists`
	)
FROM
	Spotify_Dataset_V3;

-- Task 3: Daily Rank Change (LAG) For a specific song (by id), show its Rank on the current Date and its Rank from the previous recorded date.
-- * Concept: LAG(Rank) OVER (PARTITION BY id ORDER BY Date)
SELECT
	id,
	RANK,
	LAG(RANK) OVER (
		PARTITION BY
			id
		ORDER BY
			CAST(`Date` AS DATE)
	) AS prev_rank;

-- Task 4: The "Elite Artists" Club (Scalar Subquery) Find all songs whose Energy is higher than the average Energy of all songs from the 'Europe' Continent.
SELECT title, Energy FROM Spotify_Dataset_V3
WHERE Energy > (SELECT AVG(Energy) FROM Spotify_Dataset_V3 WHERE Continent = 'Europe');

-- Task 5: Dominant Nationalities (IN) Select all songs from nationalities that have contributed at least one "Rank 1" hit.
SELECT title, Nationality FROM Spotify_Dataset_V3 WHERE Nationality IN(SELECT Nationality FROM Spotify_Dataset_V3
WHERE `Rank` = 1);

-- Task 6: Multi-Artist "Loudness" Audit Find songs where # of Artist is greater than 1, but only if their Loudness is above the average loudness of all solo artist songs.
SELECT Title, Loudness FROM Spotify_Dataset_V3
WHERE CONVERT(SUBSTRING(`# of Artist`, 8 ), UNSIGNED) > 1 AND Loudness >
(SELECT AVG(Loudness) FROM Spotify_Dataset_V3 
WHERE CONVERT(SUBSTRING(`# of Artist`, 8 ), UNSIGNED)) = 1;

-- Task 7: Point Accumulation (SUM OVER) Calculate a running total of Points (Total) for each Artist (Ind.) ordered by Date.
SELECT 
`Artist (Ind.)`,
`Date`,
`Points (Total)`,
SUM(`Points (Total)`) OVER (PARTITION BY `Artist (Ind.)` ORDER BY STR_TO_DATE(`Date`, "%d/%m/%Y")) AS artist_running_total
FROM Spotify_Dataset_V3
ORDER BY `Artist (Ind.)`, STR_TO_DATE(`Date`, "°%d %m %Y") ;

-- Task 8: Identifying One-Hit Wonders (COUNT OVER) Show a list of songs, but add a column that counts how many unique id entries exist for that Artist (Ind.).
SELECT DISTINCT Title, `Artist (Ind.)`, COUNT(id) OVER (PARTITION BY `Artist (Ind.)`) FROM Spotify_Dataset_V3
ORDER BY `Artist (Ind.)`;

-- Task 9: Decile Mood Mapping (NTILE) Divide the songs into 10 groups (deciles) based on Valence (positivity) and show only the top 10% (the "most joyful" group).;

-- Task 10: Percentage of Total Continent Points For each song, calculate what percentage of its Continent's total Points (Total) it represents.
-- * Math: Points (Total) / SUM(Points (Total)) OVER (PARTITION BY Continent) * 100
SELECT DISTINCT
    Title,
    Artists,
    Continent,
    /* Multiply by 100.0 first to force the math into decimal mode */
    (`Points (Total)` * 100.0) / SUM(`Points (Total)`) OVER (
        PARTITION BY Continent
    ) AS percent_share
FROM
    Spotify_Dataset_V3
ORDER BY 
    Continent, 
    percent_share DESC;