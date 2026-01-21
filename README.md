# 🛡️ Automated IT Operations Command Center

![Power BI](https://img.shields.io/badge/Power_BI-Decision_Support-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![SQL](https://img.shields.io/badge/MySQL-Advanced_Analytics-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Python](https://img.shields.io/badge/Python-Data_Engineering-3776AB?style=for-the-badge&logo=python&logoColor=white)

> **A Full-Stack Data Analytics Project designed to reduce Mean Time to Resolve (MTTR) and predict Service Level Agreement (SLA) breaches before they happen.**

---

## 💼 Executive Summary

**The Problem:** IT leadership lacked visibility into operational health, leading to reactive support, high operational costs, and undetected recurring failures in critical systems (e.g., SAP, VPN).

**The Solution:** I built an **Automated IT Incident Analytics Dashboard** using a "Bank 360" storytelling approach. This solution simulates a high-volume ticket environment (50k+ records), warehouses the data in SQL for complex logic processing, and visualizes it in Power BI to provide role-specific insights for **CIOs**, **Risk Managers**, and **Support Agents**.

**The Impact:**
* 📉 **Risk Reduction:** Identifies "Near-Miss" tickets (solved <2 hours before breach).
* 🚀 **Efficiency:** Drills down into root causes (e.g., "Phishing Alerts" driving Security volume).
* ⏱️ **Real-Time Action:** Live "Time Buffer" countdowns for agents to prioritize expiring tickets.

---

## 🏗️ Technical Architecture

This project follows a standard **ETL (Extract, Transform, Load)** pipeline:

1.  **Data Generation (Python):** * Used `Faker` and `Pandas` to generate 50,000 synthetic records.
    * **Logic:** Implemented weighted severity logic (e.g., "Critical" tickets have 4-hour SLAs, while "Low" have 5 days) and "Chaos Engineering" (injected weekend server crashes).
2.  **Data Warehousing (MySQL):** * Performed advanced transformation using **Window Functions** (`DENSE_RANK`) and **CTEs** to calculate efficiency metrics.
3.  **Visualization (Power BI):** * Modeled data using a **Star Schema**.
    * Designed a 3-page "Storytelling" dashboard using DAX measures for dynamic risk assessment.

---

## 📊 Dashboard Overview

The report utilizes a **3-Tier Decision Support System**:

### 1. Executive Health Check (The CIO View)
* **Goal:** High-level status of the backlog and system stability.
* **Key Visuals:** Treemap of System Failures, Volume Trend Analysis, and "Backlog Composition" (Active vs. Vendor Pending).

<img width="1262" height="715" alt="image" src="https://github.com/user-attachments/assets/954eaed7-125c-4768-b33d-3bb147f772bf" />


### 2. Risk & Root Cause Analysis (The Manager View)
* **Goal:** Identify *why* tickets are breaching.
* **Key Visuals:** * **Decomposition Tree (AI):** Drills down from Breach % → Category → specific Issue Type.
    * **Agent Performance Matrix:** Compares "Speed" vs. "Quality" (Breach rate).

![Page 2 Screenshot](https://via.placeholder.com/800x400?text=Insert+Page+2+Root+Cause+Here)

### 3. Live Action Console (The Agent View)
* **Goal:** Tactical list of what to fix *right now*.
* **Key Visuals:** Live "Countdown Timer" table with conditional formatting (Red alert when < 2 hours remain).

![Page 3 Screenshot](https://via.placeholder.com/800x400?text=Insert+Page+3+Action+Console+Here)

---

## 🧠 Advanced SQL Logic

I went beyond simple `GROUP BY` statements to uncover deeper insights.

**Feature: The "Near-Miss" Risk Report**
*Identifies tickets that technically passed SLA but were dangerously close to failing.*

```sql
SELECT 
    Ticket_ID,
    Priority,
    Agent,
    (SLA_Limit_Hours - Resolution_Hours) AS Time_Buffer_Remaining
FROM tickets
WHERE 
    Status = 'Closed' 
    AND SLA_Breached = 0 
    AND (SLA_Limit_Hours - Resolution_Hours) BETWEEN 0 AND 2 -- < 2 Hour Safety Margin
ORDER BY Time_Buffer_Remaining ASC;
```

Feature: Agent Performance Ranking (Window Functions) Ranks agents fairly within specific priority buckets.

```sql 
SELECT 
    Priority,
    Agent,
    DENSE_RANK() OVER (PARTITION BY Priority ORDER BY AVG(Resolution_Hours) ASC) AS Speed_Rank
FROM tickets;
```

📉 Advanced Power BI (DAX)
I utilized DAX to create dynamic, time-sensitive metrics.

1. The Live Countdown Timer:

Code snippet
```
Time Buffer (Hours) = 
VAR HoursGone = DATEDIFF(SELECTEDVALUE(tickets[Open_Time]), NOW(), HOUR)
VAR Limit = SELECTEDVALUE(tickets[SLA_Limit_Hours])
RETURN Limit - HoursGone
```
2. True MTTR (Excluding Open Tickets):

Code snippet
```
MTTR (Hours) = 
CALCULATE(
    AVERAGE(tickets[Resolution_Hours]),
    tickets[Status] = "Closed" -- Prevents skewing data with ongoing issues
)
```
📂 Project Structure
```Bash

├── 📁 Data_Generation
│   └── generate_incidents.py  # Python script for synthetic data
├── 📁 SQL_Analysis
│   └── advanced_queries.sql   # Ranking, Trends, and Risk logic
├── 📁 PowerBI
│   └── IT_Operations_Dashboard.pbix  # The final report file
├── 📁 Data
│   └── Deloitte_IT_Incidents.csv     # Raw dataset
└── README.md
```
🚀 How to Run
Generate Data: Run python generate_incidents.py to create a fresh dataset.

Load Database: Import the CSV into MySQL (or use the provided SQL dump).

Run Queries: Execute advanced_queries.sql to verify metrics.

View Dashboard: Open .pbix file. Note: You may need to repoint the Data Source settings to your local file path.

👤 Author <br>
Vinayak Jain Data Analyst | Business Intelligence Developer

Built as a capstone project to demonstrate Full-Stack Analytics capabilities for Enterprise IT environments.
