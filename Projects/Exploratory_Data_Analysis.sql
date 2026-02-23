-- EXPLORATORY DATA ANALYSIS PROJECT
-- As before, this project is guided by Alex the Analyst on Youtube. I am not merely copying his code. I always pause the video before he shows the solutions and try to do it on my own. 
-- Let's see how many people were laid off on the day with the most layoffs. 
SELECT
	MAX(total_laid_off)
FROM
	layoffs_staging2;

-- Now, let's see a percentage. 
SELECT
	MAX(percentage_laid_off)
FROM
	layoffs_staging2;

-- Let's see which companies had to lay off everyone.
SELECT
	*
FROM
	layoffs_staging2
WHERE
	percentage_laid_off = 1;

-- In what company did these 100% represent the biggest number?
SELECT
	*
FROM
	layoffs_staging2
WHERE
	percentage_laid_off = 1
ORDER BY
	total_laid_off DESC
LIMIT
	1;

-- What was the total number of laid off people for each company?
SELECT
	company,
	SUM(total_laid_off)
FROM
	layoffs_staging2
GROUP BY
	company
ORDER BY
	2 DESC;

-- How much time has passed between the first layoffs and the last ones? 
SELECT
	MIN(`date`),
	MAX(`date`)
FROM
	layoffs_staging2;

-- I would be curious which countries laid off the most people.
SELECT
	country,
	SUM(total_laid_off)
FROM
	layoffs_staging2
GROUP BY
	country
ORDER BY
	2 DESC;

-- How many people were laid off each year?
SELECT
	YEAR(`date`),
	SUM(total_laid_off)
FROM
	layoffs_staging2
GROUP BY
	YEAR(`date`)
ORDER BY
	YEAR(`date`) DESC;

-- I want to see the rolling total of layoffs.
WITH
	Rolling_Total AS (
		SELECT
			SUBSTRING(`date`, 1, 7) AS `MONTH`,
			SUM(total_laid_off) AS total_off
		FROM
			layoffs_staging2
		WHERE
			SUBSTRING(`date`, 1, 7) IS NOT NULL
		GROUP BY
			SUBSTRING(`date`, 1, 7)
		ORDER BY
			1 ASC
	)
SELECT
	`Month`,
	total_off,
	SUM(total_off) OVER (
		ORDER BY
			`Month`
	)
FROM
	Rolling_Total;

-- Let's see the top 5 layoff leaders per year. 
WITH
	Company_Year (company, years, total_laid_off) AS (
		SELECT
			company,
			YEAR(`date`),
			SUM(total_laid_off)
		FROM
			layoffs_staging2
		GROUP BY
			company,
			YEAR(`date`)
	),
	Company_Year_Rank AS (
		SELECT
			*,
			DENSE_RANK() OVER (
				PARTITION BY
					years
				ORDER BY
					total_laid_off DESC
			) AS Ranking
		FROM
			Company_Year
		WHERE
			years IS NOT NULL
	)
SELECT
	*
FROM
	Company_Year_Rank
WHERE
	Ranking <= 5;