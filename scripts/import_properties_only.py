import math
import pandas as pd
from sqlalchemy import create_engine

# ===========================
# MySQL Connection
# ===========================
USERNAME = "root"
PASSWORD = "2329"
HOST = "localhost"
PORT = "3306"
DATABASE = "retail_analytics"

engine = create_engine(
    f"mysql+pymysql://{USERNAME}:{PASSWORD}@{HOST}:{PORT}/{DATABASE}"
)

# ===========================
# CSV Path
# ===========================
properties_file = r"E:\MY PROJECTS\Retail-Analytics-Project\data\cleaned\properties_cleaned.csv"

# ===========================
# Count total rows
# ===========================
print("Counting rows...")

total_rows = sum(1 for _ in open(properties_file, encoding="utf-8")) - 1

chunk_size = 50000
total_chunks = math.ceil(total_rows / chunk_size)

print(f"Total Rows   : {total_rows:,}")
print(f"Chunk Size   : {chunk_size:,}")
print(f"Total Chunks : {total_chunks}")

print("=" * 60)

# ===========================
# Import
# ===========================
rows_imported = 0

for chunk_no, chunk in enumerate(
    pd.read_csv(
        properties_file,
        chunksize=chunk_size,
        low_memory=False
    ),
    start=1
):

    # -----------------------
    # Convert datatypes
    # -----------------------
    chunk["timestamp"] = pd.to_datetime(
        chunk["timestamp"],
        unit="ms",
        errors="coerce"
    )

    chunk["itemid"] = pd.to_numeric(
        chunk["itemid"],
        errors="coerce"
    ).astype("Int64")

    chunk["property"] = (
        chunk["property"]
        .astype(str)
        .str[:100]
    )

    chunk["value"] = (
        chunk["value"]
        .astype(str)
        .str[:255]
    )

    # Remove invalid rows
    chunk.dropna(
        subset=["timestamp", "itemid"],
        inplace=True
    )

    chunk["itemid"] = chunk["itemid"].astype("int64")

    # -----------------------
    # Import
    # -----------------------
    chunk.to_sql(
        "properties",
        engine,
        if_exists="append",
        index=False,
        method="multi",
        chunksize=5000
    )

    rows_imported += len(chunk)

    print(
        f"Chunk {chunk_no}/{total_chunks} "
        f"| Imported: {rows_imported:,}/{total_rows:,} rows "
        f"| Remaining Chunks: {total_chunks-chunk_no}"
    )

print("\nImport Completed Successfully!")