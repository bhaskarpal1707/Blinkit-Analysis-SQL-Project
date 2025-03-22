CREATE DATABASE BlinkIT_Grocery; # Creating a database
USE BlinkIT_Grocery; # Use the database 

SET SQL_SAFE_UPDATES = 0;  # Safe Mode ON Command

#Data Preprocessing:
CREATE TABLE GroceryData (
    Item_Fat_Content VARCHAR(50),
    Item_Identifier VARCHAR(50),
    Item_Type VARCHAR(50),
    Outlet_Establishment_Year INT,
    Outlet_Identifier VARCHAR(50),
    Outlet_Location_Type VARCHAR(50),
    Outlet_Size VARCHAR(50),
    Outlet_Type VARCHAR(50),
    Item_Visibility FLOAT,
    Item_Weight FLOAT,
    Total_Sales FLOAT,
    Rating FLOAT
);

ALTER TABLE GroceryData MODIFY Item_Weight FLOAT NULL;   # Allow NULL Values
ALTER TABLE GroceryData MODIFY Item_Weight DOUBLE;     # Change Data Type: If the values are too large or require more precision, change the data type to DOUBLE or DECIMAL

SELECT * FROM GroceryData;
SELECT COUNT(*) FROM GroceryData;

# Data Cleaning:
UPDATE GroceryData         
SET Item_Fat_Content =
CASE
WHEN Item_Fat_Content IN  ('LF', 'low fat') THEN 'Low Fat'
WHEN Item_Fat_Content = 'reg' THEN 'Regular'
ELSE Item_Fat_Content
END;

SELECT DISTINCT(Item_Fat_Content) FROM GroceryData; # For see the DISTINCT values

# SQL Query for KPI's:
	# 1. Total Sales:
SELECT CONCAT('Total Sales:', CAST(SUM(Total_Sales)/1000000 AS DECIMAL(10,2)), ' Million') AS Total_Sales
FROM GroceryData;  # Total Sales number is very big, so we change the number into Million

	# 2. Average Sales:
SELECT CONCAT('Average Sales', CAST(AVG(Total_Sales) AS DECIMAL(10,1)), ' USD') AS Avg_Sales
FROM GroceryData; # Average Sales number is in USD, so we change the number into USD

	# 3. Number of Items:
SELECT CONCAT('No of Items: ', COUNT(*)) AS No_Of_Items FROM GroceryData;

	# 4. Average Rating:
SELECT CONCAT('Average Rating: ', CAST(AVG(Rating) AS DECIMAL(10,2))) AS Avg_Rating
FROM GroceryData;

# SQL Query for Granular Requirements:
	# 1. Total Sales by Fat Content:
SELECT CONCAT('Total Sales by Fat Content', CAST(SUM(Total_Sales)/1000000 AS DECIMAL(10,2)), ' Million') AS Total_Sales
FROM GroceryData
WHERE Item_Fat_Content = 'Low Fat'
GROUP BY Item_Fat_Content
ORDER BY Total_Sales DESC;

SELECT 
    Item_Fat_Content,
    CONCAT('$', CAST(SUM(Total_Sales)/1000 AS DECIMAL(10,2))) AS Total_Sales,
    CONCAT(CAST(AVG(Total_Sales) AS DECIMAL(10,1)), ' USD') AS Avg_Sales,
    CONCAT(COUNT(*), ' Items') AS No_Of_Items,
    CONCAT(CAST(AVG(Rating) AS DECIMAL(10,2)), ' Stars') AS Avg_Rating
FROM 
    GroceryData
GROUP BY 
    Item_Fat_Content
ORDER BY 
    SUM(Total_Sales) DESC;

	# 2. Total Sales by Item Type:
		# All Items:
SELECT
    Item_Type,
    CONCAT('$', CAST(SUM(Total_Sales)/1000 AS DECIMAL(10,2))) AS Total_Sales,
    CONCAT(CAST(AVG(Total_Sales) AS DECIMAL(10,1)), ' USD') AS Avg_Sales,
    CONCAT('No of Items: ', COUNT(*)) AS No_Of_Items,
    CONCAT(CAST(AVG(Rating) AS DECIMAL(10,2)), ' Stars') AS Avg_Rating
FROM 
    GroceryData
GROUP BY 
    Item_Type
ORDER BY 
    SUM(Total_Sales) DESC;

		# Top & Last 5 Items:
(
    SELECT 
        Item_Type,
        CONCAT('$', CAST(IFNULL(SUM(Total_Sales), 0)/1000 AS DECIMAL(10,2))) AS Total_Sales,
        CONCAT(CAST(IFNULL(AVG(Total_Sales), 0) AS DECIMAL(10,1)), ' USD') AS Avg_Sales,
        CONCAT(COUNT(*), ' Items') AS No_Of_Items,
        CONCAT(CAST(IFNULL(AVG(Rating), 0) AS DECIMAL(10,2)), ' Stars') AS Avg_Rating
    FROM 
        GroceryData
    GROUP BY 
        Item_Type
    ORDER BY 
        IFNULL(SUM(Total_Sales), 0) DESC
    LIMIT 5
)
UNION ALL
(
    SELECT 
        Item_Type,
        CONCAT('$', CAST(IFNULL(SUM(Total_Sales), 0)/1000 AS DECIMAL(10,2))) AS Total_Sales,
        CONCAT(CAST(IFNULL(AVG(Total_Sales), 0) AS DECIMAL(10,1)), ' USD') AS Avg_Sales,
        CONCAT(COUNT(*), ' Items') AS No_Of_Items,
        CONCAT(CAST(IFNULL(AVG(Rating), 0) AS DECIMAL(10,2)), ' Stars') AS Avg_Rating
    FROM 
        GroceryData
    GROUP BY 
        Item_Type
    ORDER BY 
        IFNULL(SUM(Total_Sales), 0) ASC
    LIMIT 5
);

	# 3. Fat Content by Outlet for Total Sales:
    SELECT 
    Outlet_Location_Type,
    COALESCE(SUM(CASE WHEN Item_Fat_Content = 'Low Fat' THEN Total_Sales ELSE 0 END), 0) AS Low_Fat,
    COALESCE(SUM(CASE WHEN Item_Fat_Content = 'Regular' THEN Total_Sales ELSE 0 END), 0) AS Regular
FROM 
    GroceryData
GROUP BY 
    Outlet_Location_Type
ORDER BY 
    Outlet_Location_Type;

	 # 4. Total Sales by Outlet Establishment:
SELECT Outlet_Establishment_Year,
	CAST(SUM(Total_Sales) AS DECIMAL (10,2)) AS Total_Sales,
    CONCAT('Average Sales', CAST(AVG(Total_Sales) AS DECIMAL(10,1)), ' USD') AS Avg_Sales,
    CONCAT('No of Items: ', COUNT(*)) AS No_Of_Items,
    CONCAT('Average Rating: ', CAST(AVG(Rating) AS DECIMAL(10,2))) AS Avg_Rating
FROM GroceryData
GROUP BY Outlet_Establishment_Year
ORDER BY Total_Sales DESC;

	# 5. Percentage of Sales by Outlet Size:
SELECT 
    Outlet_Size, 
    CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
    CAST((SUM(Total_Sales) * 100.0 / SUM(SUM(Total_Sales)) OVER()) AS DECIMAL(10,2)) AS Sales_Percentage
FROM GroceryData
GROUP BY Outlet_Size
ORDER BY Total_Sales DESC;

	# 6. Sales by Outlet Location:
SELECT Outlet_Location_Type, CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales
FROM GroceryData
GROUP BY Outlet_Location_Type
ORDER BY Total_Sales DESC;
    
    # 7. All Metrics by Outlet Type:
SELECT Outlet_Type, 
CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
		CAST(AVG(Total_Sales) AS DECIMAL(10,0)) AS Avg_Sales,
		COUNT(*) AS No_Of_Items,
		CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating,
		CAST(AVG(Item_Visibility) AS DECIMAL(10,2)) AS Item_Visibility
FROM GroceryData
GROUP BY Outlet_Type
ORDER BY Total_Sales DESC;

















