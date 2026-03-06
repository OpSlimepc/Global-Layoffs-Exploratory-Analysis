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
- Duplicates were then removed by:
	- Creating a new table containing a row_num column
	- Deleting records where row_num is greater than 1
3. Standardized Text Data
- Several fields contained inconsistent formatting.
- Cleaning steps included:
	- Trimming extra spaces from company names
	- Standardizing industry names (e.g., grouping variations of Crypto into a single category)
	- Removing punctuation inconsistencies in country names
4. Standardized Date Format
- The original dataset stored dates as text.
- To improve usability:
	- Dates were converted using STR_TO_DATE()
	- The column data type was updated to DATE
- This allowed accurate time-based analysis.
5. Handled Missing Values
- Missing values were investigated across multiple columns.
- When possible:
	- Missing industry values were populated using data from other rows belonging to the same company and location.
6. Removed Irrelevant Rows
- Rows where both total_laid_off and percentage_laid_off were NULL were removed since they did not provide meaningful information for analysis.
7. Dropped Temporary Columns
- Temporary columns such as row_num used for duplicate detection were removed after the cleaning process.






