# Olist E-Commerce Data Analysis

End-to-end e-commerce data analysis using Python, MySQL, and Power BI on the Olist Brazilian E-Commerce dataset.

## Project Overview

An end-to-end data analytics project using the Olist Brazilian E-Commerce Public Dataset (2016–2018).

The objective is to analyze order performance, customer behavior, product sales, payment methods, delivery performance, and customer reviews to identify meaningful business insights.

## Tools & Technologies

- **Python:** Data inspection, cleaning, and exploratory data analysis
- **Pandas:** Data manipulation and transformation
- **MySQL:** Relational database design, data validation, and SQL analysis
- **Power BI:** Interactive dashboards and business reporting

## Project Workflow

### 1. Python – Data Cleaning & EDA

- Inspected all 9 CSV datasets.
- Checked missing values, duplicate records, and data types.
- Converted timestamp columns into datetime format.
- Removed exact duplicate records from the geolocation dataset.
- Preserved meaningful missing values rather than blindly deleting records.
- Exported prepared datasets for database loading.

### 2. MySQL – Database & SQL Analysis

- Created the `olist_ecommerce` database.
- Imported and validated all 9 datasets.
- Defined primary keys and foreign key relationships.
- Completed 30 business-focused SQL analysis queries using:
  - JOINs and aggregations
  - GROUP BY and HAVING
  - CTEs and window functions
  - Date-based analysis
  - Customer, product, seller, and delivery analysis

### 3. Power BI – Interactive Dashboard

**Page 1: Executive Overview**

- Total Orders
- Total Customers
- Total Payment Value
- Average Order Value
- Late Delivery Rate
- Average Delivery Days
- Monthly Orders Trend
- Order Status Distribution
- Sales Value by Product Category

**Page 2: Customer & Product Analysis**

- Top 10 Product Categories by Quantity Sold
- Top 10 Best-Selling Products
- Customer Distribution by State
- Payment Value by Payment Method

**Page 3: Delivery & Customer Experience**

- Monthly Late Delivery Rate Trend
- Average Delivery Days by Month
- Review Score Distribution
- Late Delivery Rate by State

Year slicers provide interactive filtering across the report pages.

## Key Findings

- The dataset contains 99,441 orders.
- There are 96,096 unique customers.
- Total payment value is approximately 16.01 million in the dataset's currency.
- Approximately 8.11% of delivered orders with both actual and estimated delivery timestamps were delivered late.
- Average delivery time is approximately 12.50 calendar days.
- Credit card accounts for the largest share of total payment value.
- Review score 5 is the most common review rating.

## Dataset

**Source:** Olist Brazilian E-Commerce Public Dataset

The project uses 9 datasets:

1. Customers
2. Geolocation
3. Orders
4. Order Items
5. Order Payments
6. Order Reviews
7. Products
8. Sellers
9. Product Category Translation

## Important Analytical Limitations

- Payment value is not the same as net revenue or profit.
- Product sales value is calculated using item price and excludes freight.
- Review scores are associated with orders, not individual products.
- Delivery analysis excludes records where required timestamps are missing.
- Best-selling products are identified using product IDs because product names are not available in the current dashboard.

## Power BI Dashboard Preview

[View the Olist Power BI Dashboard (PDF)](Olist_Ecommerce_Analysis.pdf)

## Project Status

Python data preparation, MySQL database setup and SQL analysis, and the three-page Power BI dashboard have been completed. Documentation and portfolio presentation are being finalized.
