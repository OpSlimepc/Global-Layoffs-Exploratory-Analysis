-- DATA CLEANING

SELECT *
FROM layoffs;

-- This creates a new table called layoffs_staging that copies the structure of the existing table layoffs.
-- TO CREATE STAGING DATASET SO WE DONT HAVE TO USE THE ORIGINAL RAW DATASET IN CASE OF MISTAKE
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

-- INSERT EVERY DATA FROM THE RAW DATASET TO THE STAGING TABLE
INSERT layoffs_staging
SELECT *
FROM layoffs;


-- REVEALS DUPLICATES USING PARTITION BY
SELECT *,
ROW_NUMBER() OVER(PARTITION BY 
company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country,
funds_raised_millions ) row_num
FROM layoffs_staging;

-- CHECK THE DUPLICATES
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY 
company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country,
funds_raised_millions ) row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- CHECK IF THEY ARE REALLY DUPLICATES
SELECT *
FROM layoffs_staging
WHERE COMPANY = 'Casper';



-- DELETING BASED ON ROW_NUM (CTE) DOES NOT WORK IN MYSQL

-- DELETE DUPLICATES

-- CREATE NEW TABLE WITH NEW COLUMN FOR ROW_NUM
-- THEN DELETE WHERE ROW_NUM > 1

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY 
company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country,
funds_raised_millions ) row_num
FROM layoffs_staging;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2;

-- STANDARDIZING DATA

SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- CHECK EVERY INDUSTRY IF THERE IS SOMETHING WRONG OR DIFFERENT WHEN THEY SHOULD BE THE SAME
-- USE THIS FOR EVERY COLUMN
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

-- UPDATE ALL THE CRYPTO VARIANT TO JUST CRYPTO
-- DO THE SAME FOR EVERY COLUMN WHEN THERE ARE MULTIPLE VARIANTS
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE country LIKE 'United States%';

-- TRIM THE PERIOD THAT WAS AT THE END OF A COUNTRY NAME
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT *
FROM layoffs_staging2;

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

-- UPDATE DATE FORMAT
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT `date`
FROM layoffs_staging2;

-- CHANGE TO DATE COLUMN INSTEAD OF TEXT
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- LOOK AT NULL VALUES OR BLANK VALUES TO POPULATE IF WE CAN (DEPENDS ON THE SITUATION IF YOU SHOULD OR SHOULD NOT POPULATE)
-- NULL VALUES OR BLANK VALUES

-- CHECK EVERY COLUMN FOR MISSING OR NULL VALUES
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

-- CHECK IF ONE OF THE MISSING VALUES CAN BE POPULATED BY CHECKING THE SAME COMPANY FOR EACH INDUSTRY
SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';


-- POPULATE THE MISSING VALUE
SELECT T1.company, T1.industry, T2.industry
FROM layoffs_staging2 T1
JOIN layoffs_staging2 T2
	ON T1.company = T2.company
	AND T1.location = T2.location
WHERE (T1.industry IS NULL OR T1.industry = '')
AND T2.industry IS NOT NULL;


-- CHANGE THE MISSING VALUE TO NULL BEFORE UPDATING
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

UPDATE layoffs_staging2 T1
JOIN layoffs_staging2 T2
	ON T1.company = T2.company
    AND T1.location = T2.location
SET T1.industry = T2.industry
WHERE (T1.industry IS NULL)
AND T2.industry IS NOT NULL;


-- DELETE COLUMNS OR ROWS THAT WE DONT AND WILL NOT NEED
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;