use lapt_op;

-- DATA CLEANING
select * from laptop;

-- Create a copy of table

CREATE TABLE laptops_backup LIKE laptop;

INSERT INTO laptops_backup
SELECT * FROM laptop;

select * from laptops_backup;

-- check memory consumption for reference

select DATA_LENGTH/1024 from information_schema.TABLES
where TABLE_SCHEMA = 'lapt_op'
AND TABLE_NAME = 'laptops_backup';

-- the given dataset size is 256KB, run the above query
-- Drop null value rows
select * from laptop
where Company is NULL AND TypeName is NULL AND Inches is NULL AND ScreenResolution is NULL AND Cpu IS NULL
AND Ram is NULL AND Memory is NULL AND Gpu IS NULL AND OpSys IS NULL AND Weight IS NULL AND Price is NULL;

-- no null rows in the dataset
-- clean RAM change col data type

alter table laptop modify column inches DECIMAL(10,1);

select * from laptop;
-- replace function usage
with cte as 
(select *,replace(Ram,'GB','') from laptop)

select * from cte;
-- 
select distinct(OpSys) from laptop;

-- mac
-- windows
-- linux
-- no os
-- android/chrome (others)

-- Filter the os
-- Suppose if there is a Windows 7 and Windows 10, then both of them should be classified as 'Windows'
select OpSys,
(CASE 
WHEN OpSys LIKE '%mac%' THEN 'macos'
WHEN OpSys LIKE  '%windows%' THEN 'windows'
WHEN OpSys LIKE '%linux%' THEN 'linux'
WHEN OpSys LIKE '%No OS%' THEN 'not available'
ELSE 'Other'
END )as 'OS'
 from laptop;

-- how to update the laptop columns using update and set

/* 
UPDATE laptop
SET OpSys = (CASE 
WHEN OpSys LIKE '%mac%' THEN 'macos'
WHEN OpSys LIKE  '%windows%' THEN 'windows'
WHEN OpSys LIKE '%linux%' THEN 'linux'
WHEN OpSys LIKE '%No OS%' THEN 'not available'
ELSE 'Other'
END )
*/

-- data cleaning on GPU
select Gpu from laptop;

-- Create new columns gpu brand , name of the graphics card
with cte as
(select *,substring_index(Gpu,' ',1) 'gpu_brand'
 from laptop)
 
 select Gpu,gpu_brand,replace(Gpu,gpu_brand,'') from cte;
 
 -- create new columns from cpu -> cpu brand , cpu_name , cpu speed
 
 select cpu from laptop;
 with cte as 
 (select *,substring_index(cpu,' ',1) as 'cpu_brand', substring_index(cpu,' ',-1) as 'cpu_speed',
 replace(cpu,substring_index(cpu,' ',-1),'') as 'cpu_name'
 from laptop)
 
 select cpu,cpu_brand,cpu_speed,replace(cpu_name,substring_index(cpu_name,' ',1),'') from cte;
 
 -- create new columns from ScreenResolution
 -- 3 columns as  -> resolution_width , resolution_height , touchscreen
 
select ScreenResolution,
substring_index(substring_index(ScreenResolution,' ',-1),'x',1) as 'resolution_width',
substring_index(substring_index(ScreenResolution,' ',-1),'x',-1) as 'resolution_height',
CASE
WHEN ScreenResolution LIKE '%Touchscreen%' THEN 1 ELSE 0 END AS 'Touchscreen'
from laptop;

-- 
 with cte as 
 (select *,substring_index(cpu,' ',1) as 'cpu_brand', substring_index(cpu,' ',-1) as 'cpu_speed',
 replace(cpu,substring_index(cpu,' ',-1),'') as 'cpu_name'
 from laptop)
 
 select cpu,cpu_brand,cpu_speed,replace(cpu_name,substring_index(cpu_name,' ',1),'') as 'cp name' from cte;
 
 --  DATA PREPROCESSING ON memory column
 
 -- select Memory from laptop;
 -- break into 3 columns
 -- type,primary storage,secondary storage
 -- HDD 1024 0
 -- SSD 0 256
 -- Hybrid 256 256
 
 with memry AS
 (select memory,
 CASE 
 WHEN Memory LIKE '%HDD%' THEN 'HDD' 
 WHEN Memory LIKE '%SSD%' THEN 'SSD'
 WHEN Memory LIKE '%Hybrid%' THEN 'Hybrid'
 WHEN Memory LIKE '%Flash Storage%' THEN 'Flash Storage'
 WHEN Memory LIKE '%SSD%' AND MEMORY LIKE '%HDD%' THEN 'Hybrid'
 WHEN Memory LIKE '%Flash Storage%' AND MEMORY LIKE '%HDD%' THEN 'Hybrid'
 ELSE NULL
 END AS 'memory_type',
 regexp_substr(substring_index(Memory,'+',1),'[0-9]+') 'primary_storage',
 CASE WHEN MEMORY LIKE '%+%' THEN  regexp_substr(substring_index(Memory,'+',1),'[0-9]+') ELSE 0 END
 as 'secondary_storage'
 from laptop)
 
 select memory,memory_type,primary_storage,
 CASE WHEN primary_storage <=2 THEN primary_storage*1024 else primary_storage END 'prim',
 secondary_storage,
 CASE WHEN secondary_storage <=2 THEN secondary_storage*1024 else secondary_storage END 'sec'
 from memry;
 
 -- NOW READY TO PERFORM EDA
 
 -- Univaritate analysis - either nurmerical or categorical columns
 /* if numerical column, then a different kind of analyis 
 -- bivariate analysis 
 Numerical vs Numerical
 Categorical vs Categorical
 Numerical vs Categorical
 */
 
 -- Steps to be performed
 
 /*initially the data is present in the database
 then we fetch queries using SQL
 then create a datawarehouse
 then use pandas for EDA
 */
 
  -- 1.head and tail
 
 select * from laptop
 order by 'Unnamed: 0' ASC LIMIT 5;
 
 select * from laptop
 order by 'Unnamed: 0' DESC LIMIT 5;
 
  select * from laptop
 order by rand() DESC LIMIT 5;
 
 -- q2. numerical cols.
 /*min,max,quartiles all four,std,variance */
 
/* select 
 count(price),min(price),max(price),std(price),avg(price),
percentile_cont(0.25) within group(order by price) over() as 'q1',
percentile_cont(0.50) within group(order by price) over() as 'q2',
percentile_cont(0.75) within group(order by price) over() as 'q3' 
 from laptop
 order by 'Unnamed: 0';
*/

-- q2. missing values

select count(price)
from laptop
where price is null;

-- q3. histogram

/*buckets
we create buckets of bins as below
0-25K 26K-50K 51K-75K 76K-100K >100K
 */

select t.buckets,COUNT(*) from
(select price,
CASE 
   when price BETWEEN 0 AND 25000 THEN '0-25K'
   when price BETWEEN 25001 AND 50000 THEN '25-50K'
   when price BETWEEN 50001 AND 75000 THEN '50-75K'
   when price BETWEEN 75001 AND 100000 THEN '75-100K'
   when price > 100000 THEN '>100K'
END AS 'buckets'
from laptop) t
group by t.buckets;

/*run the above query the ouput table that you will get copy it and paste in an
Excel sheet, and use functions of histogram, you will get the histogram chart*/

-- 2# categorical columns

select Company,count(Company)
from laptop
group by Company;

-- No missing values are there in the dataset, hance no queries written

/* BIVARIATE ANALYSIS 
1.8  number analysis on two columns
2. scatterplot
3. corelations
*/

-- scatterplot

-- cpu_speed vs price

 with cte as 
 (select *,substring_index(cpu,' ',1) as 'cpu_brand', substring_index(cpu,' ',-1) as 'cpu_speed',
 replace(cpu,substring_index(cpu,' ',-1),'') as 'cpu_name'
 from laptop)
 
select replace(cpu_speed,'GHz',''),price from cte; 

-- correlation

/* categorical-categorical
contigency table
Company   Touchscreen   Not Touchscreen
Apple        12              23
Samsung      23              17
Microsoft     4              12

in the above table the company apple has 12 touchscreen laptops and 23 non touchscreen laptops
so we have to create a table like that
*/

with cte as
(select *,
substring_index(substring_index(ScreenResolution,' ',-1),'x',1) as 'resolution_width',
substring_index(substring_index(ScreenResolution,' ',-1),'x',-1) as 'resolution_height',
CASE
WHEN ScreenResolution LIKE '%Touchscreen%' THEN 1 ELSE 0 END AS 'Touchscreen'
from laptop)

select Company,
SUM(CASE WHEN Touchscreen=1 THEN 1 ELSE 0 END) AS 'YES_TSCREEN',
SUM(CASE WHEN Touchscreen=0 THEN 1 ELSE 0 END) AS 'NO_TSCREEN'
from cte
GROUP BY Company;

/*numerical - categorical
company vs Price
*/

select company,min(price),max(price),avg(price),std(price)
from laptop
group by Company;

-- Feature Engineering 
/*Calculating ppi
(resolution_width * resolution_width + resolution_height * resolution_height) ** 0.5/inches 
*/

with cte AS
(select Inches,
substring_index(substring_index(ScreenResolution,' ',-1),'x',1) as 'resolution_width',
substring_index(substring_index(ScreenResolution,' ',-1),'x',-1) as 'resolution_height'
from laptop)

select 
resolution_width,resolution_height,
round(sqrt((resolution_width * resolution_width + resolution_height * resolution_height))/Inches,2) 'ppi' from cte;

/* feature engineering
SCREEN SIZE BRACKET
*/

select inches,
CASE 
WHEN ntile(3) OVER(ORDER BY inches)=1 THEN 'LOW'
WHEN ntile(3) OVER(ORDER BY inches)=2 THEN 'MEDIUM'
ELSE 'HIGH' END AS 'NTILE'
from laptop;

/*ONE HOT ENCODING 
gpu_brand   intel  nvidia amd

intel        1       0     0
amd          0       0     1
nvidia       0       1     0

One Hot Encoding converts categorical features and transforms them into a one-hot numerical feature.
*/

with cte as
(select *,substring_index(Gpu,' ',1) 'gpu_brand'
 from laptop)
 
 select Gpu,gpu_brand,
 CASE WHEN gpu_brand = 'Intel' THEN 1 ELSE 0 END 'Intel',
 CASE WHEN gpu_brand = 'AMD' THEN 1 ELSE 0 END 'AMD',
 CASE WHEN gpu_brand = 'Nvidia' THEN 1 ELSE 0 END 'Nvidia'
 from cte;
 
 
 
 







 
 
 
 
 
 
 
 
