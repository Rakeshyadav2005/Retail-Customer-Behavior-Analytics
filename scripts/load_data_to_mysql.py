import pandas as pd
from sqlalchemy import create_engine

# -----------------------------
# MySQL Connection
# -----------------------------
USERNAME = "root"
PASSWORD = "YOUR_PASSWORD"      # <-- Replace with your password
HOST = "localhost"
PORT = "3306"
DATABASE = "retail_analytics"

engine = create_engine(
    f"mysql+pymysql://{USERNAME}:{PASSWORD}@{HOST}:{PORT}/{DATABASE}"
)

# -----------------------------
# Import Events
# -----------------------------
print("Importing events...")

events = pd.read_csv("data/cleaned/events_cleaned.csv")

events.to_sql(
    name="events",
    con=engine,
    if_exists="append",
    index=False,
    chunksize=10000,
    method="multi"
)

print("✅ Events imported successfully!")

# -----------------------------
# Import Categories
# -----------------------------
print("Importing categories...")

categories = pd.read_csv("data/cleaned/categories_cleaned.csv")

categories.to_sql(
    name="categories",
    con=engine,
    if_exists="append",
    index=False,
    chunksize=1000,
    method="multi"
)

print("✅ Categories imported successfully!")

# -----------------------------
# Import Properties (Chunk by Chunk)
# -----------------------------
print("Importing properties...")

for chunk in pd.read_csv(
    "data/cleaned/properties_cleaned.csv",
    chunksize=50000
):
    chunk.to_sql(
        name="properties",
        con=engine,
        if_exists="append",
        index=False,
        chunksize=5000,
        method="multi"
    )
    print(f"Imported {len(chunk)} rows...")

print("🎉 All data imported successfully!")