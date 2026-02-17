-- Task 1: The "US Content" Filter
-- * Goal: Create a CTE that only contains shows from the 'United States'. In your main query, select the title and type from that CTE.
-- * Focus: Basic syntax and naming.
WITH
	US_Content AS (
		SELECT
			*
		FROM
			netflix_titles
		WHERE
			country = 'United States'
	)
SELECT
	*
FROM
	US_Content;

-- Task 2: Standardizing Dates
-- * Goal: Create a CTE that converts the text date_added into a real SQL date format. In the main query, filter for content added after 2020.
-- * Focus: Using functions inside a CTE.
WITH
	AFTER_2020 AS (
		SELECT
			*
		FROM
			netflix_titles
		WHERE
			CONVERT(RIGHT(date_added, 4), UNSIGNED) > 2020
	)
SELECT
	*
FROM
	AFTER_2020;

-- Task 3: Genre Breakdown
-- * Goal: Create a CTE that counts the number of titles per listed_in category. In the main query, select only categories that have more than 100 titles.
-- * Focus: Using GROUP BY inside a CTE.
WITH
	Genres AS (
		SELECT
			COUNT(title) AS totalCount,
			listed_in
		FROM
			netflix_titles
		GROUP BY
			listed_in
	)
SELECT
	*
FROM
	Genres
WHERE
	totalCount > 100;

-- Task 4: Director Productivity
-- * Goal: Create a CTE that lists directors and their total number of shows. In the main query, join this back to the original table to see the title of every movie directed by the "Top 5" most productive directors.
-- * Focus: Joining a CTE back to the main table.
WITH
	Director_num AS (
		SELECT
			COUNT(title),
			director
		FROM
			netflix_titles
		WHERE
			director <> ''
			AND director IS NOT NULL
		GROUP BY
			Director
		ORDER BY
			COUNT(title) DESC
		LIMIT
			5
	)
SELECT
	title
FROM
	netflix_titles
WHERE
	director IN (
		SELECT
			director
		FROM
			Director_num
	);

-- Task 5: The "Movie vs TV" Split
-- * Goal: Define two CTEs: one for 'Movies' and one for 'TV Shows'. In your final query, use a UNION to combine them, adding a custom column that says "Lengthy" if a movie is >120 min or a TV show has >3 seasons.
-- * Focus: Defining multiple CTEs in one query (WITH Table1 AS (...), Table2 AS (...)).
WITH Movies AS (
SELECT title, CONVERT(SUBSTRING(duration, 1, 3), UNSIGNED) AS duration_mins FROM netflix_titles
WHERE type = 'Movie'),

Shows AS (SELECT
		title,
		CONVERT(SUBSTRING(duration, 1, 2), UNSIGNED) AS number_of_seasons
		FROM
			netflix_titles
		WHERE
			type = 'TV Show'
	)
	
	SELECT title, CASE WHEN duration_mins > 120 THEN 'Lengthy' ELSE 'Standard' END FROM Movies
UNION 
	SELECT title, CASE WHEN number_of_seasons > 3 THEN 'Lengthy' ELSE 'Standard' END FROM Shows;

-- Task 6: Country Comparison
-- * Goal: Create one CTE for content from 'India' and another for 'United Kingdom'. In the main query, find the difference in the number of releases between the two for the year 2021.
-- * Focus: Comparing data between two CTEs.
WITH India AS(
SELECT COUNT(title) AS total FROM netflix_titles WHERE country = 'India' AND release_year = '2021'),

UK AS (
SELECT COUNT(title) AS total FROM netflix_titles WHERE country = 'United Kingdom' AND release_year = '2021')

SELECT India.total - UK.total FROM India, UK;

-- Task 7: Recent Additions Ranking
-- * Goal: Create a CTE that uses ROW_NUMBER() to rank shows by date_added within each country. In the main query, select only the 3 most recently added shows for every country.
-- * Focus: Combining Window Functions with CTEs.
WITH countries AS(SELECT title, country, ROW_NUMBER() OVER (PARTITION BY country ORDER BY STR_TO_DATE(date_added, "%M %d, %Y") DESC) AS ranking FROM netflix_titles WHERE date_added IS NOT NULL AND country <> '')

SELECT title, country, ranking FROM countries
WHERE ranking <= 3;

-- Task 8: Year-over-Year Growth
-- * Goal: Create a CTE that counts releases per release_year. Use a second CTE to use LAG() to get the previous year's count. In the final query, calculate the percentage growth in content production per year.
-- * Focus: Sequencing logic across multiple CTEs.
WITH rel_yr AS (
SELECT release_year, COUNT(title) AS titles_num FROM netflix_titles GROUP BY release_year ORDER BY release_year ASC)

SELECT release_year, titles_num, LAG(titles_num) OVER (ORDER BY release_year ASC) AS prev_year, ROUND((titles_num - LAG(titles_num) OVER (ORDER BY release_year ASC)) / LAG(titles_num) OVER (ORDER BY release_year ASC) * 100) AS percentage_growth FROM rel_yr;

-- Task 9: The "Cast" Exploder (Logic Simulation)
-- * Goal: Create a CTE that filters out rows where cast is NULL. In the main query, use string functions to find titles where the cast list contains more than 5 commas (indicating a large cast).
-- * Focus: Data validation and string manipulation.
WITH null_remover AS (
SELECT * FROM netflix_titles WHERE TRIM(cast) <> '' AND cast IS NOT NULL)

SELECT * FROM null_remover
WHERE (CHAR_LENGTH(cast) - CHAR_LENGTH(REPLACE(cast, ",", ""))) > 5;

-- Task 10: The "Rating" Consistency Audit
-- * Goal: Create a CTE that calculates the average release_year for each rating. In the main query, find all individual titles that were released before the average year of their specific rating group.
-- * Focus: Using CTEs for benchmarking individual rows against group averages.
WITH ratings AS (SELECT ROUND(AVG(release_year)) AS avg_yr, rating FROM netflix_titles
GROUP BY rating)

SELECT title, release_year, avg_yr, netflix_titles.rating FROM netflix_titles JOIN ratings ON netflix_titles.rating = ratings.rating
WHERE netflix_titles.release_year < ratings.avg_yr;
