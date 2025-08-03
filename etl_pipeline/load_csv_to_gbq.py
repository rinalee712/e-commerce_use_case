"""
This script loads multiple local CSV files into Google BigQuery using the BigQuery Python client.

It is designed for flexible usage:
- You can run it manually (e.g., via terminal or Jupyter)
- You can schedule it in an automated pipeline using Airflow, Cloud Composer, or any orchestration tool

To schedule this script in Airflow:
- Convert the main block into a PythonOperator task
- Set schedule_interval and dependencies in a DAG
"""

from google.cloud import bigquery
import pandas as pd

# Set your GCP project ID and BigQuery dataset
PROJECT_ID = "your-gcp-project-id"
DATASET_ID = "ecommerce_dataset"

# Create BigQuery client
client = bigquery.Client(project=PROJECT_ID)

def load_csv_to_bq(csv_path, table_name):
    df = pd.read_csv(csv_path)
    job_config = bigquery.LoadJobConfig(
        autodetect=True,
        source_format=bigquery.SourceFormat.CSV,
        skip_leading_rows=1,
        write_disposition="WRITE_TRUNCATE",
    )
    table_id = f"{PROJECT_ID}.{DATASET_ID}.{table_name}"
    with open(csv_path, "rb") as source_file:
        load_job = client.load_table_from_file(
            source_file, table_id, job_config=job_config
        )
    load_job.result()
    print(f"✅ Loaded {csv_path} to {table_id}")

if __name__ == "__main__":
    load_csv_to_bq("datasets/customers.csv", "customers")
    load_csv_to_bq("datasets/products.csv", "products")
    load_csv_to_bq("datasets/orders.csv", "orders")
    load_csv_to_bq("datasets/order_items.csv", "order_items")
