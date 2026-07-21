create database Hospitality;

-- KPI 1: TOTAL REVENUE --
select 
      round(sum(revenue_generated),2) as total_revenue
      from fact_bookings;
      
      
-- KPI 2: OCCUPANCY RATE -- 
select sum(successful_bookings) as occupied_rooms,
sum(capacity) as available_capacity,
round(sum(successful_bookings) / sum(capacity) * 100,2) as occupancy_rete_pct
from fact_aggregated_bookings;



-- KPI 3: CANCELLATION RATE --
select count(*) as total_bookings,
sum(case when booking_status = 'cancellled' then 1 else 0 end) as cancelled_bookings,
round(sum(case when booking_status = 'cancelled' then 1 else 0 end) / count(*) * 100,2) as cancelled_rate_pct
from fact_bookings;


-- KPI 4: TOTAL BOOKINGS --
select 
count(booking_id) as total_bookings
from fact_bookings;


-- KPI 5: UTILIZED CAPACITY --
select 
h.property_name,h.city,
sum(f.successful_bookings) as occupied_rooms,
sum(f.capacity) as available_capacity,
round(sum(f.successful_bookings) / sum(f.capacity) * 100,2) as utilized_capacity_pct
from fact_aggregated_bookings f
join dim_hotels h on f.property_id = h.property_id
group by h.property_name,h.city
order by utilized_capacity_pct desc;


-- KPI 6: TREND ANALYSIS (monthly revenue,bookings and occupancy) -- 
select 
date_format(check_in_date,'%b %Y') as month,
count(booking_id) as total_bookings,
round(sum(revenue_realized),2) as total_revenue
from fact_bookings
group by date_format(check_in_date,'%Y-%m'), date_format(check_in_date,'%b %Y')
order by date_format(check_in_date,'%Y-%m');

-- monthly occupancy --
SELECT
    d.`mmm yy` AS Month,
    SUM(fa.successful_bookings) AS Successful_Bookings,
    SUM(fa.capacity) AS Total_Capacity,
    ROUND(
        SUM(fa.successful_bookings) * 100.0 /
        SUM(fa.capacity),
        2
    ) AS Occupancy_Rate
FROM fact_aggregated_bookings fa
JOIN dim_date d
    ON fa.check_in_date = d.date
GROUP BY d.`mmm yy`
ORDER BY MIN(d.date);



-- KPI 7: WEEKDAY & WEEKEND REVENUE AND BOOKINGS --
select 
d.day_type,count(fb.booking_id) as total_bookings,
round(sum(fb.revenue_realized),2) as total_revenue
from fact_bookings fb
join dim_date d on date(fb.check_in_date) = str_to_date(d.`date`, '%d-%b-%y')
group by d.day_type;


-- KPI 8: REVENUE BY LOCATION & HOTELS --
select 
h.city,h.property_name,count(fb.booking_id) as total_bookings,
round(sum(fb.revenue_realized),2) as total_revenue
from fact_bookings fb
join dim_hotels h on fb.property_id = h.property_id
group by h.city, h.property_name
order by h.city,total_revenue desc;


-- KPI 9: CLASS WISE REVENUE --
select 
r.room_class,count(fb.booking_id) as total_bookings,
round(sum(fb.revenue_realized),2) as total_revenue
from fact_bookings fb
join  dim_rooms r on fb.room_category = r.room_id
group by r.room_class
order by total_revenue desc;


-- KPI 10: CHECKED OUT / CANCELLED / NO SHO
SELECT
    booking_status,
    COUNT(*) AS total_bookings,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM fact_bookings
WHERE booking_status IN ('Checked Out', 'Cancelled', 'No Show')
GROUP BY booking_status
ORDER BY total_bookings DESC;


-- KPI 11a: weekly revenue & bookings volume --
select d.`week no` as week,
min(date(fb.check_in_date)) as week_start,
count(fb.booking_id) as total_bookings,
round(sum(fb.revenue_realized),2) as total_revenue
from fact_bookings fb
join dim_date d on date(fb.check_in_date) = str_to_date(d.`date`,'%d-%b-%y')
group by d.`week no`
order by min(date(fb.check_in_date));

-- KPI 11b: Weekly occupancy --
select 
d.`week no` as week,
sum(f.successful_bookings) as occupied_rooms,
sum(f.capacity) as available_capacity,
round(sum(f.successful_bookings) / sum(f.capacity) * 100,2) as occupancy_rate_pct
from fact_aggregated_bookings f
join dim_date d on str_to_date(f.check_in_date,'%d-%b-%y') = str_to_date(d.`date`,'%d-%b%y')
group by d.`week no`
order by min(str_to_date(f.check_in_date,'%d-%b-%y'))