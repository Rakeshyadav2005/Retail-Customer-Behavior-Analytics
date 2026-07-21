# Data Import

Imported the cleaned CSV files into MySQL using a custom Python ETL script built with **Pandas**, **SQLAlchemy**, and **PyMySQL**.

## Import Process

- Imported `events_cleaned.csv` into the `events` table.
- Imported `categories_cleaned.csv` into the `categories` table.
- Imported `properties_cleaned.csv` into the `properties` table using chunked processing (`chunksize=50000`) to efficiently load the large dataset.

## Data Verification

Verified successful imports using SQL queries:

```sql
SELECT COUNT(*) FROM events;
SELECT COUNT(*) FROM categories;
SELECT COUNT(*) FROM properties;
```

| Table | Records |
|--------|---------:|
| events | 2,755,641 |
| categories | 1,669 |
| properties | 20,275,902 |

The imported row counts matched the cleaned CSV files, confirming a successful ETL process.