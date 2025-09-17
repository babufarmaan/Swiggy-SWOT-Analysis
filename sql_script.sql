create database if not exists swiggy;
use swiggy;
select * from swiggy;
-- changing the name of column
alter table swiggy
rename column `Avg ratings` to `Avg_rating`;
alter table swiggy
rename column `Total ratings` to `Total_rating`;
alter table swiggy
rename column `Delivery time` to `Delivery_time`;
-- Strengths
-- 1.Which cities have the highest percentage of restaurants rated above 4.0?
with Total_Restaurants as(
select count(*) Total from swiggy
where Avg_rating > 4.0
),
Total_restaurants_in_each_city as(
select city , count(restaurant) as TotalRestaurantCity from swiggy
where Avg_rating > 4.0
group by city
)
select c.city , round((c.TotalRestaurantCity/t.total)*100,2) as Percentage from Total_restaurants_in_each_city c
join Total_Restaurants t
on 1 = 1
ORDER BY Percentage DESC;
-- 2.Which areas consistently deliver food in the shortest average time?
select Area ,city ,round(avg(delivery_time),2) as Avg_time from swiggy
group by area,city
order by avg_time;
-- 3.Which restaurants have both high ratings (≥4.5) and a large number of total ratings?
select Restaurant,city, sum(total_rating) as total_rating from swiggy
where avg_rating >= 4.5
group by restaurant,city
order by total_rating desc;
-- Weaknesses
-- 1.Which restaurants have ratings below 3.0 but still receive a high number of total ratings?
select Restaurant,sum(total_rating) as overall_rating from swiggy
where avg_rating <3.0
group by restaurant
order by overall_rating desc;
-- 2.Which areas have the longest delivery times on average?
select Area , city,avg(delivery_time) as Avg_time from swiggy
group by area , city
order by avg_time desc;
-- 3.Which cities have the lowest average restaurant ratings overall?
select city , round(avg(avg_rating),2) as total_avgRating from swiggy
group by city
order by total_avgRating;
-- Opportunities
-- 1.Which price ranges have the highest concentration of restaurants, and how do their ratings compare?
select 
	case when price <200 then '<200'
    when price between 200 and 499 then '200-499'
    when price between 500 and 999 then '500-999'
    else '1000+'
    end as price_range,
    count(*) as concentration,
    round(avg(avg_rating),2) as avg_rating
    from swiggy
    group by price_range
    order by concentration desc;
-- 2.Which cities show potential for premium restaurants (higher average prices but fewer options)?
select city , round(avg(price),2) avg_price from swiggy
group by city 
order by avg_price desc;
-- 3.Which areas have many restaurants but relatively few highly rated ones (opportunity to improve quality)?
select * from swiggy;
SELECT Area, City,
       count(*) AS total_restaurants,
       sum(CASE WHEN Avg_rating >= 4.0 THEN 1 ELSE 0 END) AS high_rated_restaurants,
       round(100.0 * sum(CASE WHEN Avg_rating >= 4.0 THEN 1 ELSE 0 END) / count(*), 2) AS pct_high_rated
FROM swiggy
GROUP BY Area, City
HAVING total_restaurants >= 20  
ORDER BY pct_high_rated ASC;
-- Threats
-- 1.Which cities have a high percentage of low-rated restaurants (<3.0)?
select city,
		round(100*sum(case when avg_rating < 3.0 then 1 else 0 end)/count(*),2) as pct_low_ratted
from swiggy
group by city
order by pct_low_ratted;
-- 2.Which areas combine high order volume with long delivery times (risk of customer churn)?
select area, city , count(*) total_orders,round(avg(delivery_time),2) avg_time from swiggy
group by area, city
having total_orders >50
order by total_orders desc , avg_time desc;
-- 3.Which cities are heavily dependent on just a few restaurants with very high order volumes (risk if they leave)?
select * from swiggy;
SELECT City,
       Restaurant,
       COUNT(*) AS Total_Orders,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(PARTITION BY City),2) AS Pct_Contribution
FROM swiggy
GROUP BY City, Restaurant  
ORDER BY City, Pct_Contribution DESC;
 