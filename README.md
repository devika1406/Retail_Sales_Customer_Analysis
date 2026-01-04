#  Retail Sales & Customer Performance Analysis  

---

##  Project Overview

This project analyzes real-world retail transaction data to evaluate **sales performance, return impact, customer behavior, and product-level risk**.  
The objective was to build a **complete business intelligence solution** — starting from raw transactional data to an **executive-ready Power BI dashboard deployed to Power BI Service**.

The project simulates how a **Business Analyst / BI Analyst** works on a real retail or finance analytics problem.

---

##  Business Objectives

- Measure **true revenue performance** by accounting for product returns  
- Identify **high-value and repeat customers**  
- Analyze **customer retention vs one-time purchases**  
- Detect **products with high return risk**  
- Track **time-based sales and net revenue trends**  
- Deliver insights through an **interactive executive dashboard**

---

##  Dataset

- **Source:** Online Retail Transactions Dataset  
- **Records:** ~541,000 rows  
- **Grain:** One row per *product per invoice*  

### Key Columns
- InvoiceNo  
- StockCode  
- Description  
- Quantity  
- UnitPrice  
- InvoiceDate  
- CustomerID  
- Country  

This dataset closely resembles real transactional systems used in retail and e-commerce businesses.

---

##  Analytical Approach

###  Data Preparation (SQL)
- Loaded raw CSV data into SQL tables  
- Cleaned and validated transactional data:
  - handled missing Customer IDs  
  - converted invoice dates to proper datetime format  
  - separated **sales vs returns** using quantity logic  
  - validated line-level revenue calculations  

---

###  Data Modeling (Power BI)
- Designed a **star schema**:
  - Fact table: Retail Transactions  
  - Dimension tables: Customers, Products, Date  
- Created one-to-many relationships  
- Enabled time intelligence using a dedicated date table  

---

###  Business Metrics & DAX
Developed core KPIs using DAX:
- Sales Revenue  
- Returns Revenue  
- Net Revenue  
- Return Rate (%)  
- Total Orders  
- Total Customers  
- Customer segmentation (One-time vs Repeat)

Advanced logic included:
- revenue impact of returns  
- ranking top customers and products  
- monthly and yearly trend analysis  

---

###  Dashboard Design (Power BI)

Built a **3-page executive dashboard**:

**Executive Overview**
- Overall sales vs returns performance  
- Net revenue trends  
- High-level KPIs for leadership  

**Customer Analysis**
- Top customers by net revenue  
- Repeat vs one-time customer distribution  
- Revenue concentration insights  
- Drill-through to customer-level detail  

**Product Performance**
- Top products by net revenue  
- Products driving high return values  
- Sales vs returns risk analysis using scatter plots  

UI followed a **finance-style executive design** with clean KPI cards, minimal colors, and high readability.

---

##  Advanced Power BI Features
- Tooltips for contextual insights  
- Drill-through for customer-level deep dives  
- Performance Analyzer to evaluate visual efficiency  
- Optimized data model and DAX  

---

##  Deployment
- Published report to **Power BI Service**  
- Verified report behavior online  
- Configured dataset credentials  
- Enabled **scheduled refresh**  
- Simulated real-world BI deployment lifecycle  

---

##  Key Insights

- Product returns reduced gross sales by approximately **8–9%**  
- **Repeat customers contributed over 95% of net revenue**, highlighting retention dependency  
- Revenue was highly concentrated among a small group of customers  
- Several high-selling products also showed **high return risk**  
- Seasonal patterns indicated peak sales in November  

---

##  Tools & Technologies

- SQL (data ingestion, cleaning, analysis)  
- Power BI Desktop (modeling, DAX, visualization)  
- Power BI Service (publishing, refresh scheduling)  
- CSV / Excel (raw data source)  

---

##  Business Value

This solution demonstrates how transactional data can be transformed into **actionable insights** to support:
- financial decision-making  
- customer retention strategies  
- product quality and inventory planning  

---

##  Author

**Devika Kadam**  
Master’s in Business Analytics  
Skills: SQL | Power BI | Data Analysis | Business Intelligence
