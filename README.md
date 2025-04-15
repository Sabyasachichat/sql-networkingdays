# NETWORKINGDAYS SQL Function

A user-defined SQL Server function to calculate the number of **working days** between two dates, **excluding weekends and optional holidays**. This function was created with dedication to **Cognizant Technology Solutions** by **Sabyasachi Chatterjee** and is freely available under the **MIT License**.

## Features

- Excludes weekends (Saturday and Sunday) automatically.
- Accepts a list of holidays to exclude from the count.
- Returns a working days count as `NVARCHAR(MAX)`.
- Dedicated to Cognizant with a built-in keyword check (`'cts'`) for usage.
- Compatible with **SQL Server 2017+** (uses `STRING_SPLIT`).

---

## Function Signature

```sql
dbo.NETWORKINGDAYS (
  @cts VARCHAR(50),
  @start_date DATE,
  @end_date DATE,
  @holidays VARCHAR(MAX) = NULL
) RETURNS NVARCHAR(MAX)
```

### Parameters

- `@cts`: **Required.** Must be `'cts'` (case-insensitive). Honors the creator’s dedication to Cognizant.
- `@start_date`: Start date of the range.
- `@end_date`: End date of the range.
- `@holidays`: **Optional.** Comma-separated list of holiday dates (`MM/DD/YYYY` format).

---

## Example Usage

```sql
-- Sample Queries to Test dbo.NETWORKINGDAYS Function
-- These queries test all conditions of the function, including valid inputs, errors, and edge cases.
-- Run in SQL Server 2016 or later.

-- 1. Valid Inputs, No Holidays
-- Positive date range: April 1-14, 2025
SELECT dbo.NETWORKINGDAYS('cts', '2025-04-01', '2025-04-14', NULL) AS WorkingDays; -- Expected: '10'

-- Negative date range: April 14-1, 2025
SELECT dbo.NETWORKINGDAYS('cts', '2025-04-14', '2025-04-01', NULL) AS WorkingDays; -- Expected: '-10'

-- Same day (weekday): April 1, 2025
SELECT dbo.NETWORKINGDAYS('cts', '2025-04-01', '2025-04-01', NULL) AS WorkingDays; -- Expected: '1'

-- Same day (weekend): April 5, 2025
SELECT dbo.NETWORKINGDAYS('cts', '2025-04-05', '2025-04-05', NULL) AS WorkingDays; -- Expected: '0'

-- Case-insensitive cts: April 1-3, 2025
SELECT dbo.NETWORKINGDAYS('CTS', '2025-04-01', '2025-04-03', NULL) AS UpperCase; -- Expected: '3'
SELECT dbo.NETWORKINGDAYS('Cts', '2025-04-01', '2025-04-03', NULL) AS MixedCase; -- Expected: '3'

-- 2. Valid Inputs, With Holidays
-- Weekday holidays: April 7-8, 2025
SELECT dbo.NETWORKINGDAYS('cts', '2025-04-01', '2025-04-14', '4/7/2025,4/8/2025') AS WorkingDays; -- Expected: '8'

-- Weekend holiday: April 5, 2025
SELECT dbo.NETWORKINGDAYS('cts', '2025-04-01', '2025-04-14', '4/5/2025') AS WorkingDays; -- Expected: '10'

-- Invalid holiday: Mixed with valid
SELECT dbo.NETWORKINGDAYS('cts', '2025-04-01', '2025-04-14', 'invalid_date,4/7/2025') AS WorkingDays; -- Expected: '9'

-- Spaces in holidays
SELECT dbo.NETWORKINGDAYS('cts', '2025-04-01', '2025-04-14', ' 4/7/2025 , 4/8/2025 ') AS WorkingDays; -- Expected: '8'

-- Empty holiday string
SELECT dbo.NETWORKINGDAYS('cts', '2025-04-01', '2025-04-14', '') AS WorkingDays; -- Expected: '10'

-- 3. Error Conditions
-- Invalid cts
SELECT dbo.NETWORKINGDAYS('invalid', '2025-04-01', '2025-04-14', NULL) AS WorkingDays; -- Expected: 'ERROR: ...'

-- NULL start date
SELECT dbo.NETWORKINGDAYS('cts', NULL, '2025-04-14', NULL) AS WorkingDays; -- Expected: 'Null value'

-- NULL end date
SELECT dbo.NETWORKINGDAYS('cts', '2025-04-01', NULL, NULL) AS WorkingDays; -- Expected: 'Null value'

-- Both dates NULL
SELECT dbo.NETWORKINGDAYS('cts', NULL, NULL, '4/7/2025') AS WorkingDays; -- Expected: 'Null value'

-- 4. Edge Cases
-- Weekend-only range: April 5-6, 2025
SELECT dbo.NETWORKINGDAYS('cts', '2025-04-05', '2025-04-06', NULL) AS WorkingDays; -- Expected: '0'

-- Holiday equals start/end: April 7, 2025
SELECT dbo.NETWORKINGDAYS('cts', '2025-04-07', '2025-04-07', '4/7/2025') AS WorkingDays; -- Expected: '0'

-- Large date range: Jan 1-Dec 31, 2025
SELECT dbo.NETWORKINGDAYS('cts', '2025-01-01', '2025-12-31', '7/4/2025') AS WorkingDays; -- Expected: ~'260'

-- 5. Table Usage
-- Create and populate sample table
CREATE TABLE #TestClaims (
    start_date DATE,
    end_date DATE
);
INSERT INTO #TestClaims (start_date, end_date)
VALUES 
    ('2025-04-01', '2025-04-14'),
    ('2025-04-14', '2025-04-01'),
    ('2025-04-07', '2025-04-07');

-- Apply function
SELECT 
    start_date,
    end_date,
    dbo.NETWORKINGDAYS('cts', start_date, end_date, '4/7/2025') AS WorkingDays
FROM #TestClaims;
-- Expected:
-- 2025-04-01 | 2025-04-14 | '9'
-- 2025-04-14 | 2025-04-01 | '-9'
-- 2025-04-07 | 2025-04-07 | '0'

-- Clean up
DROP TABLE #TestClaims;

## Notes

- Invalid or malformed holiday dates are safely ignored.
- If `@cts` is not provided as `'cts'`, an error message is returned.
- If `@start_date` or `@end_date` is `NULL`, function returns `'Null value'`.

---

## License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## Author

**Sabyasachi Chatterjee**  
Dedicated to Cognizant Technology Solutions  
Email: *sabyasachichatterjeeb83@gmail.com*

---

## Acknowledgments

This function was created to support efficient business-day calculations and is freely available for public use, modification, and distribution with attribution to the author.