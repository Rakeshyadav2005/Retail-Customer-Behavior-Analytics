# Data Import

Imported the cleaned CSV files into MySQL using a custom Python ETL script with **Pandas**, **SQLAlchemy**, and **PyMySQL**.

## Import Process
- Connected Python to MySQL using SQLAlchemy.
- Imported `events_cleaned.csv` into the `events` table.
- Imported `categories_cleaned.csv` into the `categories` table.
- Imported `properties_cleaned.csv` into the `properties` table using **chunked processing** (`chunksize`) to efficiently handle the large dataset and reduce memory usage.

## Data Verification

Verified successful imports using SQL queries:

```sql
SELECT COUNT(*) FROM events;
SELECT COUNT(*) FROM categories;
SELECT COUNT(*) FROM properties;
```

### Imported Records

| Table | Records |
|--------|---------:|
| events | 2,755,641 |
| categories | 1,669 |
| properties | 6,005,000 |

Performed additional validation using sample `SELECT` queries to ensure the imported data matched the cleaned CSV files.