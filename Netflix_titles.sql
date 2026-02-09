-- 1. The Catalog: Select the title, type, and release_year of the first 10 rows.
SELECT title, type, release_year FROM  netflix_titles
LIMIT 10;

-- 2. TV Only: List all TV Shows that were released in the year 2020.
SELECT * FROM netflix_titles
WHERE type = 'TV SHOW' AND release_year = 2020;

-- 3. The Search: Find the title and description of any movie that has the word "Secret" in the title.
SELECT title, description FROM netflix_titles
WHERE title LIKE('%Secret%');

-- 4. Recent Additions: Find all movies added to Netflix (date_added) in the year 2021.
SELECT * FROM netflix_titles
WHERE date_added LIKE('%2021');

-- 5. Director's Cut: List all unique directors who have directed a movie on Netflix, excluding any null/empty values.
SELECT DISTINCT director FROM netflix_titles
WHERE director IS NOT NULL;

-- 6. Country Count: How many movies or shows are available from India?
SELECT COUNT(title) FROM netflix_titles
WHERE country = 'India';

-- 7. Content Balance: Count how many Movies vs. TV Shows are in the dataset using a GROUP BY.
SELECT COUNT(title), type FROM netflix_titles
GROUP BY type;

-- 8. The Longest Movie: Find the movie with the longest duration (Note: You may need to handle the " min" string in that column).
SELECT MAX(LEFT(duration, 3) + 0) FROM netflix_titles
WHERE type = 'Movie';

-- 9. Cast Check: List the titles of all shows where 'David Attenborough' is in the cast.
SELECT title FROM netflix_titles
WHERE cast LIKE '%David Attenborough%'


-- 10. The Final Boss: Which director has the most titles on Netflix? (Show the director's name and the count).
SELECT director, COUNT(title) FROM netflix_titles
GROUP BY director
ORDER BY COUNT(title) DESC
LIMIT 1
-- 6. Country Count: How many movies or shows are available from India?
SELECT COUNT(title) FROM netflix_titles
WHERE country = 'India';