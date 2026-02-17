-- *DATA CLEANING PROJECT*
-- Dataset: https://github.com/AlexTheAnalyst/MySQL-YouTube-Series/blob/main/layoffs.csv.
-- This is a project by AlexTheAnalyst. I am not merely typing his code however, I always pause the video and try to think about the problem on my own, so I can really learn, not just copy. 

-- STEPS
	-- 1. Remove Duplicates
	-- 2. Standardize the Data
	-- 3. Null Values or Blank Values
	-- 4. Remove any Columns
	
-- First, I'll create a staging database, so that the raw data stays unaffected. 

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT * 
FROM layoffs;

-- REMOVING THE DUPLICATES
-- First, I'll create a CTE that gives every row a number (in this case 1). If the row shows up more than once, we'll see the row_num growing. We need to put all the columns into the PARTITION BY, otherwise we may aget some false positives.
 
WITH duplicate_CTE AS (
SELECT *, ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)

--  Now I'll select everything from the CTE where the row_num is greater than 1. 

SELECT * FROM duplicate_CTE WHERE row_num > 1;

-- We can see that there's 5 rows where row_num is 2. That means they are duplicates. Let's do away with them.

-- First, we'll create another table.
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` float DEFAULT NULL,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Then we'll insert the data from the CTE.

INSERT INTO layoffs_staging2
SELECT *, ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- We now have a copy of the initial table, but with one difference, and that is the row numbers. We can now look at all the entries where row_num is greater than 1.

SELECT * FROM layoffs_staging2 WHERE row_num > 1;

-- Now, we'll delete them. 

DELETE FROM layoffs_staging2 WHERE row_num > 1;

-- DUPLICATES REMOVED!!! 

-- STANDARDIZING DATA
	
	-- First, we'll see if any of the company names have any trailing spaces. 

	SELECT company, TRIM(company) FROM layoffs_staging2;

	-- We'll see that they do, so we need to remove that.
	
	UPDATE layoffs_staging2
	SET company = TRIM(company);

	-- Let's take a look at industries.
	
	SELECT DISTINCT industry FROM layoffs_staging2;

	-- There's plenty of things that are the same, such as Crypto, Crypto Currency and Cryptocurrency. 
	
		SELECT * FROM layoffs_staging2
		WHERE industry LIKE '%crypto%';

	-- Let's standardize it.
	
		UPDATE layoffs_staging2
		SET industry = 'Crypto'
		WHERE industry LIKE '%crypto%';

	-- Let's look at locations. 
		
		SELECT DISTINCT location FROM layoffs_staging2;

	-- Looks alright, no fixes needed. Let's look at countries.
		
		SELECT DISTINCT country FROM layoffs_staging2 ORDER BY country;
		
	-- PROBLEM! There's United States with a period. Fixin' time! 
	
		UPDATE layoffs_staging2
		SET country = 'United States'
		WHERE country LIKE 'United States%';

	-- Another trouble. Our date column has the TEXT data type, that is no good 	for doing any sort of time series analysis. 
	
		SELECT `date`, STR_TO_DATE(`date`, '%m/%d/%Y') FROM layoffs_staging2; 
	
	-- We will update it.
		
		UPDATE layoffs_staging2
		SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

	-- We'll also need to update the data type. 
	
		ALTER TABLE layoffs_staging2
		MODIFY COLUMN `date` DATE;

-- NULL VALUES AND BLANK VALUES

	-- Let's look at our blank values.

	SELECT * FROM layoffs_staging2
	WHERE total_laid_off IS NULL
	AND percentage_laid_off IS NULL;

	-- We cannot populate these columns on our own. Let's look at blank values 	in the industries. 

	SELECT *
	FROM layoffs_staging2
	WHERE industry IS NULL
	OR industry = '';

	-- We can see that there are four rows, with null industry values. 			However, other entries for that same company, i. e. AirBnB, have "travel" 	industry. We need to remedy this. 
	
	SELECT t1.industry, t2.industry FROM layoffs_staging2 AS t1
	JOIN layoffs_staging2 AS t2
		ON t1.company = t2.company
		AND t1.location = t2.location
	WHERE t1.industry IS NULL OR t1.industry = ''
	AND t2.industry IS NOT NULL;

	UPDATE layoffs_staging2 t1
	JOIN layoffs_staging2 t2
		ON t1.company = t2.company
		AND t1.location = t2.location
	SET t1.industry = t2.industry
	WHERE t1.industry IS NULL
	AND t2.industry IS NOT NULL;

	-- This did not work! Maybe we need to see if they are really NULL and not 	just blank...
	
	UPDATE layoffs_staging2
	SET industry = NULL
	WHERE industry = '';
	
	-- VOILÁ! It now works as intended. The blanks in the industries were 		removed. Except for one... 
	
	SELECT * FROM layoffs_staging2 WHERE industry IS NULL OR industry = '';

-- DELETING COLUMNS
	
	ALTER TABLE layoffs_staging2
	DROP COLUMN row_num; 
	

-- FINISHED! 

	