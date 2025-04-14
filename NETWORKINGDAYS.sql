/*
   Function Name: dbo.NETWORKINGDAYS

   Description:
   This function calculates the number of working (business) days between two dates.
   It skips weekends (Saturday and Sunday) and can optionally skip specific holiday dates you provide.
   
   Special Requirement:
   The first parameter must be the string 'cts' (case-insensitive). 
   It's a symbolic nod to Cognizant, for whom this function was originally written.
   If this parameter is missing or incorrect, the function will return an error.

   Parameters:
   - @cts VARCHAR(50): Required. Must be the keyword 'cts' (case-insensitive).
   - @start_date DATE: The start of your date range.
   - @end_date DATE: The end of your date range.
   - @holidays VARCHAR(MAX): (Optional) Comma-separated list of holiday dates in MM/DD/YYYY format.
                             Example: '12/25/2025,01/01/2026'. Holidays falling on weekdays will be excluded from the working days count.

   Return:
   - If valid inputs are given and no holidays, returns a string representing the number of business days.
   - If holidays are provided, removes those that fall on weekdays and returns the adjusted count.
   - Returns helpful error messages for missing/invalid inputs.

   Notes:
   - Weekends are defined as Saturday and Sunday.
   - Invalid holiday dates (like typo or wrong format) are skipped without error.
   - Built for SQL Server 2017+ due to use of STRING_SPLIT and TRY_CONVERT.

   Author: Sabyasachi Chatterjee
   Dedicated to: Cognizant Technology Solutions
   License: MIT – Free to use, modify, and share.
*/
CREATE OR ALTER FUNCTION dbo.NETWORKINGDAYS
(
   @cts VARCHAR(50),
   @start_date DATE,
   @end_date DATE,
   @holidays VARCHAR(MAX) = NULL
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
   DECLARE @working_days INT;

   -- Table to hold parsed holiday dates
   DECLARE @holiday_table TABLE (holiday_date DATE);

   -- Step 1: Validate the first parameter (must be 'cts', case-insensitive)
   IF LOWER(@cts) != 'cts'
   BEGIN
       RETURN 'ERROR: The first parameter must be ''cts''. This function is dedicated to Cognizant and requires this keyword to proceed.';
   END;

   -- Step 2: Make sure both dates are provided
   IF @start_date IS NULL OR @end_date IS NULL
   BEGIN
       RETURN 'Null value';
   END;

   -- Step 3: Calculate working days (excluding weekends)
   SET @working_days =
       CASE
           WHEN @start_date <= @end_date THEN
               (DATEDIFF(DAY, @start_date, @end_date) + 1) -- Total days including both ends
               - (DATEDIFF(WEEK, @start_date, @end_date) * 2) -- Subtract full weekend pairs
               - (CASE WHEN DATENAME(WEEKDAY, @start_date) = 'Sunday' THEN 1 ELSE 0 END) -- Adjust if start is Sunday
               - (CASE WHEN DATENAME(WEEKDAY, @end_date) = 'Saturday' THEN 1 ELSE 0 END) -- Adjust if end is Saturday
           ELSE
               -- If dates are in reverse, just flip the calculation and make it negative
               -1 * (
                   (DATEDIFF(DAY, @end_date, @start_date) + 1)
                   - (DATEDIFF(WEEK, @end_date, @start_date) * 2)
                   - (CASE WHEN DATENAME(WEEKDAY, @end_date) = 'Sunday' THEN 1 ELSE 0 END)
                   - (CASE WHEN DATENAME(WEEKDAY, @start_date) = 'Saturday' THEN 1 ELSE 0 END)
               )
       END;

   -- Step 4: If holidays are given, parse and subtract valid ones that fall on weekdays
   IF @holidays IS NOT NULL AND LEN(@holidays) > 0
   BEGIN
       -- Try to parse the holiday list (skip any invalid entries silently)
       INSERT INTO @holiday_table (holiday_date)
       SELECT TRY_CONVERT(DATE, TRIM(value), 101)
       FROM STRING_SPLIT(@holidays, ',')
       WHERE TRY_CONVERT(DATE, TRIM(value), 101) IS NOT NULL;

       -- Count how many of these holidays are within the range and NOT on a weekend
       DECLARE @holiday_count INT = (
           SELECT COUNT(*)
           FROM @holiday_table h
           WHERE h.holiday_date BETWEEN
                 (CASE WHEN @start_date <= @end_date THEN @start_date ELSE @end_date END)
                 AND
                 (CASE WHEN @start_date <= @end_date THEN @end_date ELSE @start_date END)
             AND DATENAME(WEEKDAY, h.holiday_date) NOT IN ('Saturday', 'Sunday')
       );

       -- Subtract weekday holidays from working days (sign-sensitive)
       SET @working_days = @working_days - (@holiday_count * CASE WHEN @start_date <= @end_date THEN 1 ELSE -1 END);

       -- Return the final count as a string
       RETURN CAST(@working_days AS NVARCHAR(MAX));
   END;

   -- Step 5: If no holidays were passed, just return the base working days
   RETURN CAST(@working_days AS NVARCHAR(MAX));
END;
GO
