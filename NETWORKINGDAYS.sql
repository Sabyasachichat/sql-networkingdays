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
CREATE FUNCTION dbo.NETWORKINGDAYS
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
    DECLARE @holiday_table TABLE (holiday_date DATE);

    -- Validate @cts
    IF LOWER(@cts) != 'cts'
    BEGIN
        RETURN 'ERROR: The first parameter must be the keyword ''cts'' (e.g., ''cts'', ''CTS'', or ''Cts'').';
    END;

    -- Validate input dates
    IF @start_date IS NULL OR @end_date IS NULL
    BEGIN
        RETURN null;
    END;

    -- Calculate working days
    SET @working_days = 
        CASE
            WHEN @start_date <= @end_date THEN
                (DATEDIFF(dd, @start_date, @end_date) + 1)
                - (DATEDIFF(ww, @start_date, @end_date) * 2)
                - (CASE WHEN DATENAME(dw, @start_date) = 'Sunday' THEN 1 ELSE 0 END)
                - (CASE WHEN DATENAME(dw, @end_date) = 'Saturday' THEN 1 ELSE 0 END)
            ELSE
                -1 * (
                    (DATEDIFF(dd, @end_date, @start_date) + 1)
                    - (DATEDIFF(ww, @end_date, @start_date) * 2)
                    - (CASE WHEN DATENAME(dw, @end_date) = 'Sunday' THEN 1 ELSE 0 END)
                    - (CASE WHEN DATENAME(dw, @start_date) = 'Saturday' THEN 1 ELSE 0 END)
                )
        END;

    -- Handle holidays if provided
    IF @holidays IS NOT NULL AND LEN(@holidays) > 0
    BEGIN
        -- Parse holidays into table, accepting MM/DD/YYYY format
        INSERT INTO @holiday_table (holiday_date)
        SELECT TRY_CONVERT(DATE, LTRIM(RTRIM(value)), 101)
        FROM STRING_SPLIT(@holidays, ',')
        WHERE TRY_CONVERT(DATE, LTRIM(RTRIM(value)), 101) IS NOT NULL;

        -- Subtract holiday count within the date range
        DECLARE @holiday_count INT = (
            SELECT COUNT(*)
            FROM @holiday_table h
            WHERE h.holiday_date BETWEEN 
                  (CASE WHEN @start_date <= @end_date THEN @start_date ELSE @end_date END)
                  AND 
                  (CASE WHEN @start_date <= @end_date THEN @end_date ELSE @start_date END)
                  -- Ensure holiday is not a weekend
                  AND DATENAME(dw, h.holiday_date) NOT IN ('Saturday', 'Sunday')
        );

        -- Adjust working days by subtracting holidays
        SET @working_days = @working_days - (@holiday_count * CASE WHEN @start_date <= @end_date THEN 1 ELSE -1 END);

        -- Return as INT (cast to NVARCHAR(MAX) to match return type)
        RETURN CAST(@working_days AS NVARCHAR(MAX));
    END;

    -- Return base working days as string if no holidays
    RETURN CAST(@working_days AS NVARCHAR(MAX));
END;
GO