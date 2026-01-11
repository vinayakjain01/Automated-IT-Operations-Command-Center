create database SLA;
use sla;

CREATE TABLE Deloitte_IT_Incidents (
    Ticket_ID VARCHAR(12) PRIMARY KEY,
    Open_Time DATETIME NOT NULL,
    Close_Time DATETIME NULL,
    Category VARCHAR(50),
    Issue_Type VARCHAR(100),
    Priority VARCHAR(20),
    SLA_Limit_Hours INT,
    Resolution_Hours INT,
    SLA_Breached TINYINT(1),
    Agent VARCHAR(50),
    Status VARCHAR(30)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Deloitte_IT_Incidents - Deloitte_IT_Incidents.csv'
INTO TABLE Deloitte_IT_Incidents
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
 Ticket_ID,
 Open_Time,
 @Close_Time,
 Category,
 Issue_Type,
 Priority,
 SLA_Limit_Hours,
 Resolution_Hours,
 SLA_Breached,
 Agent,
 Status
)
SET Close_Time = NULLIF(@Close_Time, '');

SELECT 
    COUNT(*) AS total_rows,
    SUM(Close_Time IS NULL) AS open_tickets
FROM Deloitte_IT_Incidents;

SELECT *
FROM Deloitte_IT_Incidents
WHERE Close_Time IS NULL
LIMIT 5;

-- Query 1 
SELECT Priority, Status, COUNT(*) AS cnt
FROM Deloitte_IT_Incidents
GROUP BY Priority, Status
ORDER BY Priority, Status;

SELECT 
    Priority,
    ROUND(AVG(Resolution_Hours), 2) AS Avg_Resolution_Time_Hours,
    COUNT(*) AS Total_Tickets
FROM Deloitte_IT_Incidents
GROUP BY Priority
ORDER BY 
    CASE Priority
        WHEN 'Critical' THEN 1
        WHEN 'High' THEN 2
        WHEN 'Medium' THEN 3
        WHEN 'Low' THEN 4
    END;

-- Query 2 
SELECT Agent, Status, COUNT(*) AS cnt
FROM Deloitte_IT_Incidents
GROUP BY Agent, Status
ORDER BY Agent, Status;

SELECT 
    Agent,
    COUNT(*) AS Total_Tickets_Handled,
    SUM(SLA_Breached) AS Total_Breaches,
    ROUND(SUM(SLA_Breached) * 100.0 / COUNT(*), 2) AS Breach_Percentage
FROM Deloitte_IT_Incidents
WHERE Close_Time IS NOT NULL
GROUP BY Agent
ORDER BY Breach_Percentage DESC;

-- Query 3
SELECT 
    Category,
    Issue_Type,
    COUNT(*) AS Issue_Frequency,
    SUM(SLA_Breached) AS Total_Breaches
FROM Deloitte_IT_Incidents
GROUP BY Category, Issue_Type
ORDER BY Issue_Frequency DESC
LIMIT 5;

/* Query 4: Resolution Efficiency by Category
   Concept: Conditional Aggregation (Dashboard-safe)
*/
SELECT 
    Category,
    COUNT(*) AS Total_Received,
    COUNT(CASE WHEN Close_Time IS NOT NULL THEN 1 END) AS Total_Closed,
    ROUND(
        COUNT(CASE WHEN Close_Time IS NOT NULL THEN 1 END) * 100.0 
        / COUNT(*),
    2) AS Resolution_Rate_Percent
FROM Deloitte_IT_Incidents
GROUP BY Category
ORDER BY Resolution_Rate_Percent ASC;

-- Quey 5
SELECT 
    Priority,
    Agent,
    ROUND(AVG(Resolution_Hours), 1) AS Avg_Speed_Hours,
    DENSE_RANK() OVER (
        PARTITION BY Priority
        ORDER BY AVG(Resolution_Hours) ASC
    ) AS Speed_Rank
FROM Deloitte_IT_Incidents
WHERE Close_Time IS NOT NULL  
GROUP BY Priority, Agent
ORDER BY 
    priority,
    Speed_Rank;

/* Query 6: Month-over-Month Growth Analysis
Concept: CTEs + LAG() Window Function
*/
with monthlystats as (
SELECT 
        DATE_FORMAT(Open_Time, '%Y-%m') AS Month_Year,
        COUNT(*) AS Monthly_Volume
    FROM Deloitte_IT_Incidents
    GROUP BY DATE_FORMAT(Open_Time, '%Y-%m')
)
SELECT 
    Month_Year,
    Monthly_Volume,
    -- Look at the row 'Lagging' 1 step behind current row
    LAG(Monthly_Volume, 1) OVER (ORDER BY Month_Year) AS Previous_Month_Volume,
    -- Calculate % Change
    ROUND(
        (Monthly_Volume - LAG(Monthly_Volume, 1) OVER (ORDER BY Month_Year)) 
        / LAG(Monthly_Volume, 1) OVER (ORDER BY Month_Year) * 100
    , 2) AS Growth_Rate_Pct
FROM MonthlyStats;

/* Query 7: The "Near-Miss" Risk Report
Concept: Complex Filtering & Business Logic
*/
SELECT 
    Ticket_ID,
    Priority,
    Agent,
    SLA_Limit_Hours,
    Resolution_Hours,
    (SLA_Limit_Hours - Resolution_Hours) AS Time_Buffer_Remaining
FROM Deloitte_IT_Incidents
WHERE 
    Close_Time IS NOT NULL     
    AND SLA_Breached = 0         
    AND (SLA_Limit_Hours - Resolution_Hours) BETWEEN 0 AND 2
ORDER BY Time_Buffer_Remaining ASC;

select SLA_Limit_Hours,
    Resolution_Hours
    from Deloitte_IT_Incidents;
    
    

