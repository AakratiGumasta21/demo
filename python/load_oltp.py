"""
load_oltp.py
-------------
Purpose: Load raw CSV data (generated in Step 2) into the MySQL OLTP database
         (flipkart_oltp). This simulates how a company's application would
         write transactional data into its production database.

This is Part A of the project (Python side) — proving that data engineering
skills (connecting to DB, reading files, bulk inserting, handling NULLs)
are being used before any SQL analysis happens.
"""

import csv
import mysql.connector
from mysql.connector import Error

# ------------------------------------------------------------------
# DB CONFIG
# ------------------------------------------------------------------
DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "12345",
    "database": "flipkart_oltp",
}

RAW_DATA_DIR = "C:/Users/Dell/Desktop/flipkart/raw_data"




def get_connection():
    return mysql.connector.connect(**DB_CONFIG)


def nullify(value):
    """Convert empty string to None so MySQL stores proper NULL."""
    return None if value == "" else value


def load_user_info(cursor):
    with open(f"{RAW_DATA_DIR}/user_info.csv", newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        rows = [
            (r["user_id"], r["name"], r["email"], r["phone"], r["gender"],
             r["dob"], r["city"], r["state"], r["pincode"], r["signup_date"])
            for r in reader
        ]
    query = """INSERT INTO user_info
        (user_id, name, email, phone, gender, dob, city, state, pincode, signup_date)
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"""
    cursor.executemany(query, rows)
    return len(rows)


def load_order_info(cursor):
    with open(f"{RAW_DATA_DIR}/order_info.csv", newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        rows = [
            (r["order_id"], r["user_id"], r["product_id"], r["product_name"],
             r["category"], r["brand"], r["price"], r["quantity"],
             r["order_date"], r["order_status"])
            for r in reader
        ]
    query = """INSERT INTO order_info
        (order_id, user_id, product_id, product_name, category, brand, price, quantity, order_date, order_status)
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"""
    cursor.executemany(query, rows)
    return len(rows)


def load_payment_info(cursor):
    with open(f"{RAW_DATA_DIR}/payment_info.csv", newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        rows = [
            (r["payment_id"], r["order_id"], r["payment_mode"], r["payment_status"],
             r["amount_paid"], r["transaction_date"], r["discount_applied"],
             nullify(r["coupon_code"]))
            for r in reader
        ]
    query = """INSERT INTO payment_info
        (payment_id, order_id, payment_mode, payment_status, amount_paid, transaction_date, discount_applied, coupon_code)
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s)"""
    cursor.executemany(query, rows)
    return len(rows)


def load_logistic_info(cursor):
    with open(f"{RAW_DATA_DIR}/logistic_info.csv", newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        rows = [
            (r["shipment_id"], r["order_id"], r["courier_partner"], r["warehouse_location"],
             nullify(r["dispatch_date"]), nullify(r["delivery_date"]),
             r["delivery_status"], r["estimated_days"])
            for r in reader
        ]
    query = """INSERT INTO logistic_info
        (shipment_id, order_id, courier_partner, warehouse_location, dispatch_date, delivery_date, delivery_status, estimated_days)
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s)"""
    cursor.executemany(query, rows)
    return len(rows)


def load_rating_review(cursor):
    with open(f"{RAW_DATA_DIR}/rating_review.csv", newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        rows = [
            (r["review_id"], r["order_id"], r["user_id"], r["product_id"],
             r["rating"], r["review_text"], r["review_date"])
            for r in reader
        ]
    query = """INSERT INTO rating_review
        (review_id, order_id, user_id, product_id, rating, review_text, review_date)
        VALUES (%s,%s,%s,%s,%s,%s,%s)"""
    cursor.executemany(query, rows)
    return len(rows)


def main():
    try:
        conn = get_connection()
        cursor = conn.cursor()
        print("Connected to MySQL database: flipkart_oltp\n")

        print("Loading user_info ...")
        n1 = load_user_info(cursor)
        conn.commit()
        print(f"  -> {n1} rows loaded")

        print("Loading order_info ...")
        n2 = load_order_info(cursor)
        conn.commit()
        print(f"  -> {n2} rows loaded")

        print("Loading payment_info ...")
        n3 = load_payment_info(cursor)
        conn.commit()
        print(f"  -> {n3} rows loaded")

        print("Loading logistic_info ...")
        n4 = load_logistic_info(cursor)
        conn.commit()
        print(f"  -> {n4} rows loaded")

        print("Loading rating_review ...")
        n5 = load_rating_review(cursor)
        conn.commit()
        print(f"  -> {n5} rows loaded")

        total = n1 + n2 + n3 + n4 + n5
        print(f"\nAll data loaded successfully into flipkart_oltp. Total rows: {total}")

    except Error as e:
        print("MySQL Error:", e)
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()
            print("MySQL connection closed.")


if __name__ == "__main__":
    main()
