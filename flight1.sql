use flight_study;

SELECT * FROM flight;

-- q1.find the month name in which the most flights have departed
select monthname(Date_of_Journey),COUNT(*) as 'total_flights'
from flight
group by monthname(Date_of_Journey)
order by total_flights desc LIMIT 1;

-- q2.which week day has most costly flights
select DAYNAME(Date_of_Journey) as wkday,AVG(Price) as wkprice
from  flight
group by wkday
order by wkprice DESC LIMIT 1;

-- q3 find number of indigo flights per month

select monthname(Date_of_Journey) 'month',COUNT(*) 'total' from flight
 where Airline='indigo'
 group by month
 order by 'total' DESC;
 
 -- q4. find list of all flights that depart between 10am to 2pm from Banglore to Delhi
 
 select * from flight
 where Source = 'Banglore' and Destination = 'New Delhi'
 and (Dep_Time > '10:00:00' and Dep_Time < '14:00:00');
 
 -- q5. find the number of flights departing on weekends from Bangalore
 
 select COUNT(*) from flight 
 where Source = 'Banglore' and DAYNAME(Date_of_Journey) in ('Saturday','Sunday');

 -- q6. Calculate the average duration of flights between all city pairs. The answer should In xh ym format
 
SELECT Source,Destination,TIME_FORMAT(SEC_TO_TIME(AVG(Duration)*60),'%hh:%im') FROM flight
GROUP BY Source,Destination;
 
 
 -- q7. Find quarter wise number of flights for each airline
 
 with ct as 
 (select *,str_to_date(concat(Date_of_Journey,' ',Dep_Time),'%Y-%m-%d %H:%i') as 'depart' from flight)
 
 select Airline,quarter(depart),count(*)
 from ct 
 group by Airline,quarter(depart);
 
 -- q8. find the longest flight distance(between cities in terms of time) in India
 
SELECT Source,Destination,TIME_FORMAT(SEC_TO_TIME(AVG(Duration)*60),'%hh:%im')  AS  total_time
FROM flight
GROUP BY Source,Destination
ORDER BY total_time DESC;

-- q9. average time duration of flights that have 1 stop vs more than 1 stop

with temp_table as
(select *,
case 
when Total_Stops='non-stop' THEN 'non-stop'
else 'with stop'
end 'temp'
from flight)

select temp, TIME_FORMAT(SEC_TO_TIME(AVG(Duration)*60),'%kh %im'),AVG(Price)
from temp_table
group by temp;

-- q10. find all Air India flights ina gven data range originating from 'Delhi'

-- '1 st jan' to '1st Mar' 
 
with ct as 
(select *,str_to_date(concat(Date_of_Journey,' ',Dep_Time),'%Y-%m-%d %H:%i') as 'depart' from flight)
 
 select * from ct
 where source = 'Delhi'
 and 
 date(depart) BETWEEN '2019-01-01' AND '2019-03-01';
 
 -- q11. Find the longest flight of each airline
 select airline,
 MAX(Duration) from
 flight
 group by airline;
 
 -- q12. Find all the pair of cities having average time duration > 3 hours
SELECT Source,Destination,TIME_FORMAT(SEC_TO_TIME(AVG(Duration)*60),'%kh %im') 
FROM flight
GROUP BY Source,Destination;

-- q13. Make a weekday vs time grid showing frequency of flights from Banglore and Delhi

/*     00-6am      6am -12pm      12pm - 6pm       6pm - 12am
Mon     23
tue
Wed
Thur
Fri
Sat
Sun

23 represent 23 no. of flight move from Bangalore to Delhi in 12am-6am midnight to morning duration
 */
 with ct as 
(select *,str_to_date(concat(Date_of_Journey,' ',Dep_Time),'%Y-%m-%d %H:%i') as 'depart' from flight)

 select dayname(depart),
 SUM(CASE WHEN HOUR(depart) BETWEEN 0 AND 5 THEN 1 ELSE 0 END) AS '12PM-6AM',
 SUM(CASE WHEN HOUR(depart) BETWEEN 6 AND 11 THEN 1 ELSE 0 END) AS '6AM-12PM',
 SUM(CASE WHEN HOUR(depart) BETWEEN 12 AND 17 THEN 1 ELSE 0 END) AS '12PM-6PM',
 SUM(CASE WHEN HOUR(depart) BETWEEN 18 AND 23 THEN 1 ELSE 0 END) AS '6PM-12AM'
 from ct
 where source='Banglore' and destination='New Delhi'
 group by dayname(depart);
 
 -- q14. Make a weekday vs time grid showing avg flight price from Banglore and Delhi
 
  with ct as 
(select *,str_to_date(concat(Date_of_Journey,' ',Dep_Time),'%Y-%m-%d %H:%i') as 'depart' from flight)

 select dayname(depart),
 AVG(CASE WHEN HOUR(depart) BETWEEN 0 AND 5 THEN Price ELSE NULL END) AS '12PM-6AM',
 avg(CASE WHEN HOUR(depart) BETWEEN 6 AND 11 THEN Price ELSE NULL END) AS '6AM-12PM',
 avg(CASE WHEN HOUR(depart) BETWEEN 12 AND 17 THEN Price ELSE NULL END) AS '12PM-6PM',
 avg(CASE WHEN HOUR(depart) BETWEEN 18 AND 23 THEN Price ELSE NULL END) AS '6PM-12AM'
 from ct
 where source='Banglore' and destination='New Delhi'
 group by dayname(depart);
 
 -- q15. Calculate the arrival time for all the flights by adding the duration to the departure time
 
 with c2 as
 (select *,str_to_date(concat(Date_of_Journey,' ',Dep_Time),'%Y-%m-%d %H:%i') as 'depart',
 replace(substring_index(duration,' ',1),'h','')*60 + 
 CASE WHEN substring_index(duration,' ',-1) = SUBSTRING_INDEX(duration,' ',1) THEN 0 
 ELSE replace(substring_index(duration,' ',-1),'m','') END 'MINS'
 from flight
 ) 

select depart,MINS,TIME(ARRIVAL) 'ARRIVALTIME',DATE(ARRIVAL) 'ARRIVALDATE' FROM
(select depart,MINS,date_add(depart,INTERVAL MINS MINUTE) 'ARRIVAL' from c2) t1;


-- 11:40:00 + 785/60-> 13 HR 5 MIN = 00:45:00
/*select Duration,
replace(substring_index(duration,' ',1),'h','')*60 + 
CASE WHEN substring_index(duration,' ',-1) = SUBSTRING_INDEX(duration,' ',1) THEN 0 
ELSE replace(substring_index(duration,' ',-1),'m','') END 'MINS'
 from ct;*/
 
 
 