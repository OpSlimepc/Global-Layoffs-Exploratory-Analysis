-- EXPLORATORY DATA ANALYSIS

SELECT *
FROM layoffs_staging2;


SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;


SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;


SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;


SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;


SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;


SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;


SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;


-- ROLLING SUM OF LAYOFFS
SELECT *
FROM layoffs_staging2;

SELECT SUBSTRING(`date`, 1 , 7) `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1 , 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;


WITH ROLLING_TOTAL AS
(
SELECT SUBSTRING(`date`, 1 , 7) `MONTH`, SUM(total_laid_off) TOTAL_OFF
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1 , 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, TOTAL_OFF,
SUM(TOTAL_OFF) OVER(ORDER BY `MONTH`) ROLLING
FROM ROLLING_TOTAL;


-- BREAKING OUT THE TOTAL LAID OFF PER YEAR INSTEAD OF JUST THE TOTAL
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY company ASC;


-- RANK COMPANY LAID OFFS BY YEAR USING CTEs
WITH COMPANY_YEAR AS
(
SELECT company, YEAR(`date`) YEARS, SUM(total_laid_off) TOTAL_LAID
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY company ASC
), COMPANY_YEAR_RANK AS
(
SELECT *, DENSE_RANK() OVER(PARTITION BY YEARS ORDER BY TOTAL_LAID DESC) RANKINGS
FROM COMPANY_YEAR
WHERE YEARS IS NOT NULL
)
SELECT *
FROM COMPANY_YEAR_RANK
WHERE RANKINGS <=5;






