# Global Layoffs Data Analysis | Data Cleaning & Exploratory Analysis with SQL
SQL Project | Global Layoffs Dataset | From Raw Data to Workforce Insights

---

### Project Overview
This project analyzes global company layoffs to identify trends in workforce reductions across industries, companies, locations, and time periods.
Using SQL, the raw dataset was cleaned, standardized, and transformed before performing exploratory analysis to uncover patterns in layoffs, such as:

- Companies with the highest layoffs
- Industries most affected by workforce reductions
- Geographic distribution of layoffs
- Layoff trends over time
- Companies experiencing complete workforce layoffs

The project demonstrates practical SQL skills including data cleaning, window functions, common table expressions (CTEs), aggregation, and ranking analysis.

---

### Tools & Technologies
1. SQL (MySQL) – Data cleaning, transformation, and analysis
2. Window Functions – Duplicate detection, ranking, rolling totals
3. Common Table Expressions (CTEs) – Structured analysis queries
4. Aggregate Functions – Trend analysis and summarization

---

### Dataset Overview
The dataset contains records of layoffs from companies across multiple industries and countries.

Key columns include:
1. Company
2. Location
3. Industry
4. Total Employees Laid Off
5. Percentage of Workforce Laid Off
6. Date of Layoff
7. Country
8. Funds Raised

The dataset captures layoffs across multiple years, allowing for time-series trend analysis and industry impact evaluation.

---

### Data Cleaning Process
Data cleaning was conducted using SQL to ensure the dataset was accurate, consistent, and ready for analysis.

The following steps were performed:
1. Created a Staging Table
- To preserve the original dataset, a staging table was created to perform all cleaning operations safely without modifying the raw data.
```sql
CREATE TABLE layoffs_staging
LIKE layoffs;

-- INSERT EVERY DATA FROM THE RAW DATASET TO THE STAGING TABLE
INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

```

2. Identified and Removed Duplicate Records
- Duplicate rows were detected using the ROW_NUMBER() window function with PARTITION BY across multiple columns.
```sql
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

```
- Duplicates were then removed by:
	- Creating a new table containing a row_num column
	- Deleting records where row_num is greater than 1
```sql
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

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY 
company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country,
funds_raised_millions ) row_num
FROM layoffs_staging;

```
	
```sql
-- Deleting records where row_num is greater than 1
DELETE
FROM layoffs_staging2
WHERE row_num > 1;
```
 
3. Standardized Text Data
- Several fields contained inconsistent formatting.
- Cleaning steps included:
	- Trimming extra spaces from company names
	- Standardizing industry names (e.g., grouping variations of Crypto into a single category)
	- Removing punctuation inconsistencies in country names
 ```sql
SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);
```
```sql
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
```

```sql
-- TRIM THE PERIOD THAT WAS AT THE END OF A COUNTRY NAME
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

```
4. Standardized Date Format
- The original dataset stored dates as text.
- To improve usability:
	- Dates were converted using STR_TO_DATE()
	- The column data type was updated to DATE
- This allowed accurate time-based analysis.
```sql
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

-- UPDATE DATE FORMAT
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
```

5. Handled Missing Values
- Missing values were investigated across multiple columns.
- When possible:
	- Missing industry values were populated using data from other rows belonging to the same company and location.
```sql
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

-- CHANGE THE MISSING VALUE TO NULL BEFORE UPDATING
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- POPULATE THE MISSING VALUE
UPDATE layoffs_staging2 T1
JOIN layoffs_staging2 T2
	ON T1.company = T2.company
    AND T1.location = T2.location
SET T1.industry = T2.industry
WHERE (T1.industry IS NULL)
AND T2.industry IS NOT NULL;
```
6. Dropped Temporary Columns
- Temporary columns such as row_num used for duplicate detection were removed after the cleaning process.
```sql
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
```






