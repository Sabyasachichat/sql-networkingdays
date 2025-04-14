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
-- Basic usage without holidays
SELECT dbo.NETWORKINGDAYS('cts', '2025-01-01', '2025-01-15');

-- Usage with holidays
SELECT dbo.NETWORKINGDAYS('CTS', '2025-01-01', '2025-01-15', '01/01/2025,01/14/2025');
```

---

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