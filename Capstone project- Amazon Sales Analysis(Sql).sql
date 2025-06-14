  ####### Capstone Proect: Amazon Sales Analysis ######

-- 1 Overview of Dataset --
-- The data consists of sales record of three cities/branch in Myanmar 
-- which are Naypyitaw, Yangon, Mandalay which took place in first quarter of year 2019 --
-- the data consists of 1000 rows and 17 columns --


-- 2. Objective of Project --
-- The major aim of this project is to gain insight into the sales data of Amazon --
-- and to understand the different factors that affect sales of the different branches --
#-------------------------------------------------------------------------------------------------------#
-- 3. Approach ; [a. Data Wrangling]
-- step.1]. Create Database and Use It

CREATE DATABASE IF NOT EXISTS amazon;
USE amazon;

-- step.2. Create a table and insert the data.
select * from amazon 
limit 5;

-- Step.3.checking null values and datatypes of columns -
DESCRIBE amazon;

select count(*) as count_of_null_values from amazon 
where null;


-- b.  Feature Engineering --
-- adding new columns timeofday, dayname, monthname by extracting values from date and time column --
-- this will help to analyse sales based on month, day of week, time of day --- 

-- step1 ; add New Columns if Not Exists
ALTER TABLE amazon
ADD COLUMN  timeofday VARCHAR(20) AFTER Time,
ADD COLUMN  dayname VARCHAR(20) AFTER Date,
ADD COLUMN monthname VARCHAR(20) AFTER dayname;

-- step;2. Update 'timeofday' Column Based on Time of Day
SET SQL_SAFE_UPDATES = 0;
UPDATE amazon
SET timeofday =
CASE
  WHEN TIME(Time) >= '00:00:00' AND TIME(Time) < '12:00:00' THEN 'Morning'
  WHEN TIME(Time) >= '12:00:00' AND TIME(Time) < '18:00:00' THEN 'Afternoon'
  ELSE 'Evening'
END;

-- step;3 . Update 'dayname' Column (Extract Day Name)
UPDATE amazon
SET dayname = 
CASE DAYOFWEEK(Date)
    WHEN 1 THEN 'Sun'
    WHEN 2 THEN 'Mon'
    WHEN 3 THEN 'Tue'
    WHEN 4 THEN 'Wed'
    WHEN 5 THEN 'Thu'
    WHEN 6 THEN 'Fri'
    WHEN 7 THEN 'Sat'
END;

-- step;4. Update 'monthname' Column (Extract Month Name)
UPDATE amazon
SET monthname =
CASE MONTH(Date)
    WHEN 1 THEN 'Jan'
    WHEN 2 THEN 'Feb'
    WHEN 3 THEN 'Mar'
    WHEN 4 THEN 'Apr'
    WHEN 5 THEN 'May'
    WHEN 6 THEN 'Jun'
    WHEN 7 THEN 'Jul'
    WHEN 8 THEN 'Aug'
    WHEN 9 THEN 'Sep'
    WHEN 10 THEN 'Oct'
    WHEN 11 THEN 'Nov'
    WHEN 12 THEN 'Dec'
END;
select * from amazon limit 2;
-- Step 5. Check Data
SELECT Date, Time, timeofday, dayname, monthname FROM amazon LIMIT 5;

-- c. Exploratory Data Analysis[EDA] --
-- step.1] Creating new table named Amazon Sales_ table by adding correct column names, datatypes, constraints while copying values from demo table Amazon --

-- step. 1  Renaming col
ALTER TABLE amazon 
CHANGE COLUMN `Invoice ID` `Invoice_id` VARCHAR(30);

ALTER TABLE amazon 
CHANGE COLUMN `Customer type` `Customer_type` VARCHAR(30);

ALTER TABLE amazon 
CHANGE COLUMN `Product line` `Product_line` VARCHAR(100);


ALTER TABLE amazon 
CHANGE COLUMN `Tax 5%` `VAT` FLOAT;

ALTER TABLE amazon 
CHANGE COLUMN `Gross margin percentage` `Gross_margin_percentage` FLOAT;

ALTER TABLE amazon 
CHANGE COLUMN `Gross income` `Gross_income` DECIMAL(10,2);

ALTER TABLE amazon 
CHANGE COLUMN `Payment` `Payment_method` VARCHAR(20);

select * from amazon limit 61;
-- step.2 . Create 'amazon_sales_table' Table
CREATE TABLE IF NOT EXISTS amazon_sales_table (
    Invoice_id VARCHAR(30) PRIMARY KEY NOT NULL,
    Branch VARCHAR(5) NOT NULL,
    City VARCHAR(30) NOT NULL,
    Customer_type VARCHAR(30) NOT NULL,
    Gender VARCHAR(10) NOT NULL,
    Product_line VARCHAR(100) NOT NULL,
    Unit_price DECIMAL(10,2) NOT NULL,
    Quantity INT NOT NULL,
    VAT FLOAT NOT NULL,
    Total DECIMAL(10,2) NOT NULL,
    Date DATE NOT NULL,
    Time TIME NOT NULL,
    Payment_method VARCHAR(20) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    Gross_margin_percentage FLOAT NOT NULL,
    Gross_income DECIMAL(10,2) NOT NULL,
    Rating DECIMAL(3,1) NOT NULL,
    timeofday VARCHAR(20) NOT NULL,
    dayname VARCHAR(20) NOT NULL,
    monthname VARCHAR(20) NOT NULL
);

-- step.3 Inssert the values in the amazon sales table
INSERT INTO amazon_sales_table (
    Invoice_id, Branch, City, Customer_type, Gender, Product_line, 
    Unit_price, Quantity, VAT, Total, Date, Time, Payment_method, 
    Cogs, Gross_margin_percentage, Gross_income, Rating, 
    timeofday, dayname, monthname
)
SELECT 
    Invoice_id, Branch, City, Customer_type, Gender, Product_line, 
    Unit_price, Quantity, VAT, Total, Date, Time, Payment_method, 
    Cogs, Gross_margin_percentage, Gross_income, Rating, 
    timeofday, dayname, monthname
FROM amazon;
select * from amazon;
select * from amazon_sales_table;

describe amazon_sales_table;


-- step.3 Checking size of table, count of null values, unique values  in columns --

select count(*) as total_columns from information_schema.columns
where table_name ='amazon_sales_table'; # col-20

select count(*) as total_rows from amazon_sales_table; # rows-1000

select count(*) as null_values from amazon_sales_table where null; # null values- 0

create view count_unique_values as
(select count(distinct Invoice_id) Invoice_id, count(distinct Branch) Branch, count(distinct City) City, count(distinct Customer_type) Customer_type,
count(distinct Gender) Gender, count(distinct Product_line) Product_line, count(distinct Unit_price) Unit_price, count(distinct Quantity) Quantity,
count(distinct VAT) VAT, count(distinct Total) Total, count(distinct Date) Date, count(distinct Time) Time, count(distinct Payment_method) Payment_method,
count(distinct cogs) cogs, count(distinct Gross_margin_percentage) Gross_margin_percentage, count(distinct Gross_income) Gross_income, count(distinct Rating) Rating,
count(distinct timeofday) timeofday, count(distinct dayname) dayname, count(distinct monthname) monthname from amazon_sales_table);

select * from count_unique_values; 

-- step.4. checking unique values in each categorical column -- 
select distinct(Branch) Branch from amazon_sales_table; # Branches -3
select distinct(City) City from amazon_sales_table; # cities- 3
select distinct(Customer_type) Customer_type from amazon_sales_table; # customer type- 2
select distinct(Gender) Gender from amazon_sales_table; # gender type-2
select distinct(product_line) product_line from amazon_sales_table; # product line - 6
select distinct(payment_method) payment_method from amazon_sales_table; # paayment metho - 3
select distinct(timeofday) timeofday from amazon_sales_table; # timeoday - morning, afternoon, evening
select distinct(dayname) dayname from amazon_sales_table;  # daynamae - sun,mon,--------sat
select distinct(monthname) monthname from amazon_sales_table; # monthnamae - jan, feb, mar

select * from amazon_sales_table;

------------------------ ####### Answering Business Questions #####------ :
-- 1. What is the count of distinct cities in the dataset?
select count(distinct(City)) from amazon_sales_table; # count(dis city) = 3

-- 2. For each branch, what is the corresponding city?
select distinct(Branch), City from amazon_sales_table; # A-yangon , B- Naypyitaw, C- Mandalay

-- 3. What is the count of distinct product lines in the dataset?
select count(distinct(product_line)) from amazon_sales_table; # dis product line = 6

-- 4. Which payment method occurs most frequently?
select payment_method, count(*) as occurs from amazon_sales_table
 group by payment_method
 order by occurs desc;   # Ewallet occurs - 345 
 
-- 5. Which product line has the highest sales?
select product_line, sum(Quantity) as total_sales from amazon_sales_table
group by product_line
order by total_sales desc;   # Electronic accessories has highest sale - 971

#6. How much revenue is generated each month?
select monthname, sum(Total) as monthly_revenue from amazon_sales_table
group by monthname
order by monthly_revenue desc;   

#7.  which month did the cost of goods sold reach its peak?
select monthname, sum(cogs) as cost_of_goods_sold from amazon_sales_table
group by monthname
order by cost_of_goods_sold desc; # jan - 110754.16

#8. Which product line generated the highest revenue?
select product_line, sum(Quantity) as total_sales, sum(Total) as Total_Revenue from amazon_sales_table
group by product_line
order by Total_Revenue  desc;  # Food & beverages

#9. In which city was the highest revenue recorded?
select City, sum(Total) as Revenue from amazon_sales_table
group by City
order by Revenue desc; # Naypyitaw


#10. Which product line incurred the highest Value Added Tax?
select product_line, max(VAT) as Highest_VAT from amazon_sales_table
group by product_line
order by Highest_VAT Desc; # Fashion accessories

#11. For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
select product_line, sum(total) as revenue, 
case 
	when sum(total) > (select sum(total)/count(distinct(product_line)) from amazon_sales_table) then 'Good'
    else 'Bad'
end performance
from amazon_sales_table
group by product_line
order by revenue desc;

#12. Identify the branch that exceeded the average number of products sold.
select Branch, sum(Quantity) as product_sold from amazon_sales_table
group by Branch
having product_sold > (select sum(quantity)/count(distinct Branch) as avg_quantity from amazon_sales_table); # Branch - A

#13. Which product line is most frequently associated with each gender?
with new as 
(select gender, product_line, count(*) as count from amazon_sales_table
group by gender, product_line),

max_count as 
(select max(count) from new group by gender)

select * from new 
where count in (select * from max_count) LIMIT 2;  # Female- Fashion Accessories

# 14. Calculate the average rating for each product line.
select product_line, avg(Rating) as Avg_Rating from amazon_sales_table
group by product_line
order by Avg_Rating desc;

# 15. Count the sales occurrences for each time of day on every weekday.
select dayname, timeofday, count(*)  as sales_occurrence from amazon_sales_table 
group by dayname, timeofday
order by field(dayname, 'Sun', 'Mon', 'Tues', 'Wed', 'Thurs', 'Fri', 'Sat'), 
field(timeofday, 'Morning', 'Afternoon', 'Evening');

#16. Identify the customer type contributing the highest revenue.
select Customer_type, sum(Total) as Revenue from amazon_sales_table
group by Customer_type
order by Revenue desc;  # Member


#17. Determine the city with the highest VAT percentage.
select City, max(VAT)as VAT from amazon_sales_table
group by City
order by VAT desc limit 1;  # Naypyitaw


# 18. Identify the customer type with the highest VAT payments.
select Customer_type, max(VAT) as VAT_payment from amazon_sales_table
group by Customer_type
order by VAT_payment desc; # Member

# 19. What is the count of distinct customer types in the dataset?
select count(distinct(Customer_type)) from amazon_sales_table; # 2

# 20. What is the count of distinct payment methods in the dataset?
select count(distinct(payment_method)) as count_distinct_payment from amazon_sales_table;  # 3

# 21. Which customer type occurs most frequently?
select Customer_type, count(*) as occurs from amazon_sales_table
group by Customer_type
order by occurs desc; # member - 501

# 22.Identify the customer type with the highest purchase frequency.
select Customer_type, count(*) as highest_purchase from amazon_sales_table
group by Customer_type
order by highest_purchase desc limit 1; # Member

#23. Determine the predominant gender among customers.
select Gender, count(*) as predominant_gender from amazon_sales_table
group by Gender
order by predominant_gender desc;  # Female


# 24. Examine the distribution of genders within each branch.
select Branch, Gender, count(*) as Gender_count from amazon_sales_table
group by Branch, Gender
order by Branch, Gender desc;

# 25. Identify the time of day when customers provide the most ratings.
select timeofday, count(rating) as rating_count from amazon_sales_table
group by timeofday
order by rating_count desc;  # Afternoon


# 26. Determine the time of day with the highest customer ratings for each branch.
select Branch, timeofday, max(rating) highest_rating from amazon_sales_table
group by Branch, timeofday
having highest_rating = (select max(x.max) from (select Branch, timeofday, max(rating) max from amazon_sales_table
group by Branch, timeofday) as x where x.Branch= amazon_sales_table.Branch)
order by Branch;

#27 . Identify the day of the week with the highest average ratings.
select dayname, avg(Rating) as avg_rating from amazon_sales_table
group by dayname
order by avg_Rating desc; # Monday 

# 28. Determine the day of the week with the highest average ratings for each branch.
with avg_rating as
(select Branch, dayname, avg(rating) avg_rat from amazon_sales_table
group by Branch, dayname),

max_rating as 
(select max(avg_rat) from avg_rating group by Branch)
select Branch, dayname, avg_rat as highest_avg_rat from avg_rating where avg_rat in (select * from max_rating);  # Branch-B, Monday


----------- Key Findings from Amazon Sales Dataset -------

------------------------- #### 1.  Product Analysis: ### -------------------
-- step - 1 : Highest & lowest sales & Revenue on product_line
select product_line, sum(Quantity) as sales, sum(Total) as Revenue from amazon_sales_table
group by product_line;
-- Highest Sales Product Line: Electronic Accessories (Units Sold:971) --
-- Highest Revenue Product Line: Food and Beverages ($ 56144.96)--
-- Lowest Sales Product Line: Health and Beauty (Unit Sold: 854) --
-- Lowest Revenue Product Line: Health and Beauty ($ 49193.84) --

------------------------ #### 2.  Sales Analysis: #### ----------------------
-- step 1: Revenue based on Month
select monthname as Month, sum(Total) as Revenue from amazon_sales_table
 Group by Month 
 order by Revenue desc;

-- Month With Highest Revenue: January ($ 116292.11) --
-- Month With Lowest Revenue: February ($ 97219.58) --

-- step-2 : Revenue based on City & Branch
SELECT City, Branch, SUM(Total) AS Revenue FROM amazon_sales_table
GROUP BY City, Branch
ORDER BY Revenue DESC;

-- City & Branch With Highest Revenue: Naypyitaw[C] ($ 110568.86)--
-- City & Branch With Lowest Revenue: Mandalay[B] ($ 106198.00) --


-- Step-3 :  Revenue based on Time of Day & Day of Week 
SELECT timeofday as Time_of_Day, dayname as Day_of_Week,   SUM(Total) AS Revenue FROM amazon_sales_table
GROUP BY Time_of_Day, Day_of_Week
ORDER BY Revenue DESC;

-- Peak Sales Time Of Day: Afternoon --
-- Peak Sales Day Of Week: Saturday --


---------------------#### 3.  Customer Analysis: ####-------------------------
-- step 1 : Most Predominant Gender  Customer_Type:
SELECT Gender, COUNT(*) as Count, Customer_type FROM amazon_sales_table
GROUP BY Gender, Customer_type
ORDER BY Count DESC Limit 1;

-- Most Predominant Gender: Female --
-- Most Predominant Customer_Type: Member --


-- step-2 : Highest Revenue by Gender
SELECT Gender, SUM(Total) AS Revenue FROM amazon_sales_table
GROUP BY Gender
ORDER BY Revenue DESC
LIMIT 1;

-- Highest Revenue Gender: Female ($ 167883.26) --

-- step-3: Highest Revenue by Customer_Type 
SELECT Customer_type, SUM(Total) AS Revenue FROM amazon_sales_table
GROUP BY Customer_type
ORDER BY Revenue DESC
LIMIT 1;

-- Highest Revenue Customer Type: Member ($ 164223.81) --

-- Step-4: Most Popular Product Line by Gender(male)
SELECT Product_line, COUNT(*) AS Count FROM amazon_sales_table
WHERE Gender = 'Male'
GROUP BY Product_line
ORDER BY Count DESC
LIMIT 1;

-- Most Popular Product Line (Male): Health and Beauty --

-- step-5: Most Popular Product Line by Gender(Female)
SELECT Product_line, COUNT(*) AS Count FROM amazon_sales_table
WHERE Gender = 'Female'
GROUP BY Product_line
ORDER BY Count DESC
LIMIT 1;

-- Most Popular Product Line (Female): Fashion Accessories --

-- step-6: Distribution of Members Based on Gender
SELECT Gender, COUNT(*) AS Member_Count FROM amazon_sales_table
WHERE Customer_type = 'Member'
GROUP BY Gender;

-- Distribution Of Members Based On Gender: Male(240) Female(261) --

-- step-7: Total Sales (Units) by Gender 
SELECT Gender, SUM(Quantity) AS Total_Units_Sold FROM amazon_sales_table
GROUP BY Gender;

-- Sales Male: 2641 units --
-- Sales Female: 2869 units --



