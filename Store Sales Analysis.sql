use [STORES SALES]

select * from Storesalesdata

-----------------------------FEATURE ENGINEERING-------------------------------------



---ADDITION OF THE TIME OF THE DAY
SELECT time,
    CASE
        WHEN CAST(time AS time) BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN CAST(time AS time) BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_of_day
FROM storesalesdata;

-- Add a new column
ALTER TABLE storesalesdata
ADD time_of_day VARCHAR(20);


-- Update the new column based on the time categorization
UPDATE storesalesdata
SET time_of_day = CASE
                        WHEN CAST(time AS time) BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
                        WHEN CAST(time AS time) BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
                        ELSE 'Evening'
                  END


---ADDITION OF THE DAY(of the week)

SELECT date, DATENAME(dw, date) AS day_name
FROM storesalesdata;


--SELECT date, LEFT(DATENAME(dw, date), 3) AS day_name FROM storesalesdata;

ALTER TABLE storesalesdata
ADD day_name VARCHAR(20);


UPDATE storesalesdata
SET day_name =DATENAME(dw, date)



---ADDITION OF THE MONTH(of the week)

SELECT date, DATENAME(month, date) AS month_name
FROM storesalesdata;


ALTER TABLE storesalesdata
ADD month_name VARCHAR(20);

UPDATE storesalesdata
set month_name=DATENAME(month, date);



------------------------------------GENERAL ANALYSIS-----------------------------------

-- How many unique cities does the data have?
select distinct(city) from storesalesdata;


--In which city is each branch?
select distinct(city), branch from storesalesdata;



------------------------------------PRODUCT BASED ANALYSIS-----------------------------------

--1. How many unique product lines does the data have?
select distinct(product_line) 
from storesalesdata

--2. What is the most selling product line
select product_line , count(product_line) as ttl_sales
from storesalesdata
group by product_line
order by ttl_sales DESC


--3. What is the most selling product line
select sum(quantity) as selling_numbers, product_line
from storesalesdata
group by product_line
order by selling_numbers DESC;


----4. What is the total revenue by month
select  month_name , round(sum(total),2) as avg_revenue
from storesalesdata
group by month_name
order by avg_revenue DESC


-- 5. What month had the largest COGS?(cost of goods sold)
select  month_name , round(sum(cogs),2) as ttl_cogs
from storesalesdata
group by month_name
order by ttl_cogs DESC


--6. What product line had the largest revenue?
select  product_line , round(sum(total),2) as ttl_revenue
from storesalesdata
group by product_line
order by ttl_revenue DESC


-- 7. What is the city with the largest revenue?
select city,round(sum(total),2) as ttl_revenue
from storesalesdata
group by city
order by ttl_revenue DESC

--8.-- What product line had the largest VAT?
select product_line,avg(tax_5) as avg_vat
from storesalesdata
group by product_line
order by avg_vat  DESC

--9.Fetch each product line and add a column to those product line showing "average", "below average and 'above average' accordingly 
--lets find the avg_sales for each product line which is the average quantity sold

SELECT 
	AVG(quantity) AS avg_qnty
FROM storesalesdata;

SELECT product_line,
CASE WHEN AVG(quantity) > 6 THEN 'good' ELSE 'bad' END AS remark
FROM storesalesdata
GROUP BY product_line;


--10. Which branch sold more products than average product sold?
select branch,  SUM(quantity) as amt_sold
from storesalesdata
group by branch
having sum(quantity)>(select avg(quantity) from storesalesdata)
order by amt_sold DESC


--11. What is the most common product line by gender?

 SELECT
    product_line,
    sum(CASE WHEN Gender = 'Female' THEN 1 ELSE 0 END) AS Female,
    sum(CASE WHEN Gender = 'Male' THEN 1 ELSE 0 END) AS Male
FROM
    storesalesdata
GROUP BY
    product_line;

--second way of doing the same thing
	
select product_line, gender, count(gender) as ttl_count
from storesalesdata
group by product_line, gender
order by ttl_count DESC


-- 12. What is the average rating of each product line
select product_line, round(avg(rating),2) as avg_rating
from storesalesdata
group by product_line
order by avg_rating DESC



------------------------------------CUSTOMER BASED ANALYSIS-----------------------------------

-- 1.How many unique customer types does the data have?
select distinct(customer_type) from storesalesdata


--2.How many unique payment methods does the data have?
select distinct(payment)
from storesalesdata


-- 3. What is the most common customer type?
select customer_type, count(customer_type) as ttl_customer_type
from storesalesdata
group by customer_type
order by ttl_customer_type DESC


--4. Which customer type buys the most?
select customer_type, sum(quantity) as ttl_count
from storesalesdata
group by customer_type
order by ttl_count DESC


-- 5. What is the gender of most of the customers as per the customer_type?
 SELECT
    customer_type,
    sum(CASE WHEN Gender = 'Female' THEN 1 ELSE 0 END) AS Female,
    sum(CASE WHEN Gender = 'Male' THEN 1 ELSE 0 END) AS Male
FROM
    storesalesdata
GROUP BY
    customer_type;


-- 6. What is the gender of most of the customers?
SELECT gender,COUNT(*) as gender_cnt
FROM storesalesdata
GROUP BY gender
ORDER BY gender_cnt DESC;


--7. What is the gender distribution per branch?
SELECT
    branch,
    sum(CASE WHEN Gender = 'Female' THEN 1 ELSE 0 END) AS Female,
    sum(CASE WHEN Gender = 'Male' THEN 1 ELSE 0 END) AS Male
FROM
    storesalesdata
GROUP BY
    branch;


-- 8.Which time of the day do customers give most ratings?
select time_of_day, count(time_of_day) as most_ratings 
from storesalesdata
group by time_of_day
order by most_ratings DESC

--9. Which day of the week has the best avg ratings?

select day_name, round(avg(rating),2) as avg_rating
from storesalesdata
group by day_name
order by avg_rating DESC


--10. Which day of the week has the best average ratings per branch?
select branch,time_of_day,round(avg(rating),2) as ratings
from storesalesdata
group by branch, time_of_day
order by branch,time_of_day,ratings

---(another way to do it)

SELECT
branch,
ROUND(AVG(CASE WHEN time_of_day = 'Morning' THEN rating END), 2) AS Morning,
ROUND(AVG(CASE WHEN time_of_day = 'Afternoon' THEN rating END), 2) AS Afternoon,
ROUND(AVG(CASE WHEN time_of_day = 'Evening' THEN rating END), 2) AS Evening
FROM
    storesalesdata
GROUP BY
    branch;



------------------------------------SALES BASED ANALYSIS-----------------------------------

--1. Number of sales made in each time of the day per weekday 
SELECT branch,day_name,
SUM(CASE WHEN time_of_day = 'Morning' THEN quantity ELSE 0 END) AS Morning,
SUM(CASE WHEN time_of_day = 'Afternoon' THEN quantity ELSE 0 END) AS Afternoon,
SUM(CASE WHEN time_of_day = 'Evening' THEN quantity ELSE 0 END) AS Evening
FROM
storesalesdata
group by branch,day_name
order by branch 

--2.Sales for each branch for each day of the week
select branch,day_name, count(quantity) as sales
from storesalesdata
group by branch, day_name
order by branch, sales DESC



--3. Which of the customer types brings the most revenue?
select customer_type, ROUND(sum(total),2) as ttl_revenue
from storesalesdata
group by customer_type
order by ttl_revenue DESC


-- 4. Which city has the largest tax/VAT percent?
select city, ROUND(avg(tax_5),2) as avg_tax
from storesalesdata
group by city
order by avg_tax DESC


--5. Which customer type pays the most in VAT?
select customer_type, ROUND(avg(tax_5),2) as avg_tax
from storesalesdata
group by customer_type
order by avg_tax DESC



