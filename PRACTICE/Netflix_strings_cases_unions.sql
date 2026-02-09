-- Level 1: String Functions (The Data Cleaners)
-- Task 1: The Character Count Audit. Netflix titles can be long. Find all titles that have more than 50 characters in their name. Use LENGTH() (or LEN()).
SELECT
	title
FROM
	netflix_titles
WHERE
	LENGTH(title) > 50;

-- Task 2: The Actor Split (Partial Match). Find all content where 'Leonardo DiCaprio' is listed in the cast column. Since the cast is a single string, you'll need to use LIKE '%Leonardo DiCaprio%'.
SELECT
	*
FROM
	netflix_titles
WHERE
	CAST LIKE '%Leonardo DiCaprio%';

-- Task 3: Clean the Duration. The duration column often looks like "90 min" or "3 Seasons". Use REPLACE() to remove the word "min" from the movie durations and convert the result to an integer.
SELECT
	title,
	CAST(
		REPLACE
			(duration, 'min', '') AS SIGNED
	)
FROM
	netflix_titles
WHERE
	type = 'Movie';

-- Task 4: The Country Initials. Create a new column that shows only the first 3 characters of the country column in uppercase (e.g., "India" becomes "IND"). Use UPPER() and SUBSTR() (or LEFT()).
SELECT
	title,
	CASE
		WHEN Country IS NOT NULL
		AND Country <> '' THEN UPPER(SUBSTR(country, 1, 3))
		ELSE 'Multi-national Production'
	END AS Country_of_Origin
FROM
	netflix_titles;

-- Level 2: Case Statements (The Classifiers)
-- Task 5: Content Era Labeling. Classify content into three eras: 'Classic' (released before 2000), 'Modern' (2000–2015), and 'Contemporary' (after 2015).
SELECT
	title,
	release_year,
	CASE
		WHEN release_year <= 2000 THEN 'Classic'
		WHEN release_year >= 2000
		AND release_year <= 2015 THEN 'Modern'
		ELSE 'Contemporary'
	END AS Classification
FROM
	netflix_titles;

-- Task 6: The "Short vs. Long" Movie Tag. For Movies only, create a label: if duration is less than 90 min, call it 'Short Film'; if it's 90–150 min, call it 'Feature'; if it's over 150 min, call it 'Epic'.
SELECT
	title,
	duration,
	CASE
		WHEN CAST(
			REPLACE
				(duration, ' min', '') AS SIGNED
		) <= 90 THEN 'Short Film'
		WHEN CAST(
			REPLACE
				(duration, ' min', '') AS SIGNED
		) <= 150 THEN 'Feature'
		ELSE 'Epic'
	END AS Classification
FROM
	netflix_titles
WHERE
	type = 'Movie';

-- Task 7: The Director Presence Check. Many rows have a NULL or empty director. Use a CASE statement to create a column is_directed that returns 'Yes' if a director is listed and 'Independent' if the column is empty.
SELECT
	title,
	CASE
		WHEN director IS NOT NULL
		AND director <> '' THEN 'Yes'
		ELSE 'Independent'
	END AS is_directed
FROM
	netflix_titles;

-- Level 3: Unions (The Data Stackers)
-- Task 8: The Master "People" List Create a single list of all unique names that appear in either the director column or the cast column. Use UNION (not UNION ALL) to ensure no duplicates.
SELECT
	CAST
FROM
	netflix_titles
UNION
SELECT
	director
FROM
	netflix_titles;

-- Task 9: Top vs. Bottom Years Write a query that finds the 5 years with the most content releases, and UNION it with the 5 years with the least content releases (where count > 0).
(
	SELECT
		release_year,
		COUNT(title)
	FROM
		netflix_titles
	GROUP BY
		release_year
	ORDER BY
		COUNT(title) DESC
	LIMIT
		5
)
UNION
(
	SELECT
		release_year,
		COUNT(title)
	FROM
		netflix_titles
	GROUP BY
		release_year
	ORDER BY
		COUNT(title) ASC,
		release_year DESC
	LIMIT
		5
);

-- Task 10: The Multi-Category Search Search for all 'Horror Movies' in one query and all 'Comedies' in another, then use UNION ALL to see them in a single results list. (This is useful when the filtering logic for two groups is very different)
SELECT
	title,
	listed_in
FROM
	netflix_titles
WHERE
	listed_in LIKE '%Comedies%'
UNION ALL
SELECT
	title,
	listed_in
FROM
	netflix_titles
WHERE
	listed_in LIKE '%Horror Movies%';