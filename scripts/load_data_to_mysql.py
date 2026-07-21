"""
Import cleaned retail analytics datasets into MySQL.

Tables:
- events
- categories
"""

import pandas as pd
from sqlalchemy import create_engine

# -----------------------------
# MySQL Connection
# -----------------------------
USERNAME = "root"
PASSWORD = "YOUR_PASSWORD"   # Replace with your MySQL password
HOST = "localhost"
PORT = "3306"
DATABASE = "retail_analytics"

engine = create_engine(
    f"mysql+pymysql://{USERNAME}:{PASSWORD}@{HOST}:{PORT}/{DATABASE}"
)

try:

    # =====================================================
    # Import Events
    # =====================================================
    print("=" * 60)
    print("Importing EVENTS table...")
    print("=" * 60)

    events = pd.read_csv("data/cleaned/events_cleaned.csv")

    # Convert data types
    events["timestamp"] = pd.to_datetime(events["timestamp"])
    events["transactionid"] = events["transactionid"].astype("Int64")

    events.to_sql(
        name="events",
        con=engine,
        if_exists="append",
        index=False,
        chunksize=10000,
        method="multi"
    )

    print(f"✅ Events imported successfully! ({len(events):,} rows)\n")

    # =====================================================
    # Import Categories
    # =====================================================
    print("=" * 60)
    print("Importing CATEGORIES table...")
    print("=" * 60)

    categories = pd.read_csv("data/cleaned/categories_cleaned.csv")

    # Convert nullable integer
    categories["parentid"] = categories["parentid"].astype("Int64")

    categories.to_sql(
        name="categories",
        con=engine,
        if_exists="append",
        index=False,
        chunksize=1000,
        method="multi"
    )

    print(f"✅ Categories imported successfully! ({len(categories):,} rows)\n")

    # =====================================================
    # Summary
    # =====================================================
    print("\n" + "=" * 60)
    print("🎉 EVENTS & CATEGORIES IMPORTED SUCCESSFULLY!")
    print("=" * 60)

    print(f"Events      : {len(events):,}")
    print(f"Categories  : {len(categories):,}")

    print("\nℹ️ Run 'import_properties_only.py' separately to import the Properties table.")

except Exception as e:
    print("\n❌ Import Failed!")
    print(e)