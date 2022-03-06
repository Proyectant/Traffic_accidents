CREATE DATABASE Traffic_Accidents;
/*** IMPORT CSV FILE All_Accidents.csv INTO TABLE accidents ***/
/*** MAKE COLUMN Date_and_Time type datetime and allow nulles on Longitude and Latitude columns ***/

DROP DATABASE Traffic_Accidents

/*Number of accidents by type*/
SELECT  Type_of_Accidents, 
		COUNT(ID) AS Number_of_Accidents INTO acc_by_type 
FROM accidents
GROUP BY Type_of_Accidents;

SELECT * 
FROM acc_by_type
ORDER BY Number_of_Accidents DESC;
/*-------------------------------------------------*/

/*Top 10 municipalities by number of accidents*/
SELECT  TOP 10 Municipality, 
		COUNT(ID) AS Number_of_Accidents INTO acc_by_municipality
FROM accidents
GROUP BY Municipality
ORDER BY Number_of_Accidents DESC;

SELECT * 
FROM acc_by_municipality
ORDER BY Number_of_Accidents DESC;
/*-------------------------------------------------*/

/*Number of accidents by participants*/
SELECT  Participants, 
		COUNT(ID) AS Number_of_Accidents INTO acc_by_participants
FROM accidents
GROUP BY Participants;

SELECT *
FROM acc_by_participants
ORDER BY Number_of_Accidents DESC;
/*-------------------------------------------------*/

/*Number of accidents by month*/
SELECT  DATENAME(month, Date_and_Time) AS Month , 
		COUNT(ID) AS Number_of_Accidents INTO acc_by_month
FROM accidents
GROUP BY DATENAME(month, Date_and_Time)

SELECT * FROM acc_by_month
ORDER BY Number_of_Accidents DESC
/*-------------------------------------------------*/

/*Number of accidents by day*/
SELECT  DATENAME(weekday, Date_and_Time) AS Day , 
		COUNT(ID) AS Number_of_Accidents 
INTO acc_by_day
FROM accidents
GROUP BY DATENAME(weekday, Date_and_Time);

SELECT *
FROM acc_by_day
ORDER BY Number_of_Accidents  DESC;
/*-------------------------------------------------*/


/*Increase/Decrease of number of accidents through years*/
WITH temp AS
(
SELECT  DATENAME(year, Date_and_Time) as Year, 
		COUNT(ID) Number_of_accidents, 
		LAG(COUNT(ID)) OVER ( ORDER BY DATENAME(year, Date_and_Time) ) AS Acc_from_last_year,
		COUNT(ID) - LAG(COUNT(ID)) OVER ( ORDER BY DATENAME(year, Date_and_Time) ) AS Difference,
		(COUNT(ID)*100)/LAG(COUNT(ID)) OVER ( ORDER BY DATENAME(year, Date_and_Time) ) AS InPercent
FROM accidents
GROUP BY DATENAME(year, Date_and_Time)
)
SELECT Year,
		Number_of_accidents,
		Acc_from_last_year,
		CAST(CAST(Difference*100 AS DECIMAL(10,2))/Acc_from_last_year AS DECIMAL(10,2)) AS InPercent
INTO acc_through_years
FROM temp;

SELECT *
FROM acc_through_years;
/*-------------------------------------------------*/


/*Number of accidents by part of week (weekday/weekend)*/
WITH temp1 AS(
SELECT DATENAME(weekday, Date_and_Time) AS Day, 
	   (CASE
           WHEN (((DATEPART(DW,Date_and_Time ) - 1 ) + @@DATEFIRST ) % 7) IN (0,6)
           THEN 'Weekend'
           ELSE 'Weekday'
       END) AS is_weekend_day,
	   COUNT(ID) OVER (PARTITION BY DATENAME(weekday, Date_and_Time)) AS acc_by_day
FROM accidents
),
temp2 AS(
SELECT 
		is_weekend_day AS Weekpart,
		SUM(acc_by_day) OVER (PARTITION BY is_weekend_day ORDER BY is_weekend_day) AS Number_of_Accidents
FROM temp1
GROUP BY is_weekend_day,acc_by_day
)
SELECT  Weekpart, 
		Number_of_Accidents,
		CAST(CAST(Number_of_Accidents*100 AS DECIMAL(10,2))/SUM(Number_of_Accidents) OVER () AS DECIMAL(10,2)) AS InPercent
INTO acc_by_weekpart
FROM temp2
GROUP BY Weekpart,Number_of_Accidents;

SELECT * 
FROM acc_by_weekpart;
/*-------------------------------------------------*/



/* Increase/Decrease of number of accidents by type through years*/
WITH temp AS
(
SELECT  DATENAME(year, Date_and_Time) as Year, 
		Type_of_Accidents,
		COUNT(ID) Number_of_accidents, 
		LAG(COUNT(ID)) OVER ( ORDER BY Type_of_Accidents, DATENAME(year, Date_and_Time) ) AS Acc_from_last_year,
		COUNT(ID) - LAG(COUNT(ID)) OVER ( ORDER BY Type_of_Accidents, DATENAME(year, Date_and_Time) ) AS Difference,
		(COUNT(ID)*100)/LAG(COUNT(ID)) OVER ( ORDER BY Type_of_Accidents, DATENAME(year, Date_and_Time) ) AS InPercent
FROM accidents
WHERE Type_of_Accidents = 'With material damage'
GROUP BY  Type_of_Accidents, DATENAME(year, Date_and_Time)
),
temp2 AS
(
SELECT  DATENAME(year, Date_and_Time) as Year, 
		Type_of_Accidents,
		COUNT(ID) Number_of_accidents, 
		LAG(COUNT(ID)) OVER ( ORDER BY Type_of_Accidents, DATENAME(year, Date_and_Time) ) AS Acc_from_last_year,
		COUNT(ID) - LAG(COUNT(ID)) OVER ( ORDER BY Type_of_Accidents, DATENAME(year, Date_and_Time) ) AS Difference,
		(COUNT(ID)*100)/LAG(COUNT(ID)) OVER ( ORDER BY Type_of_Accidents, DATENAME(year, Date_and_Time) ) AS InPercent
FROM accidents
WHERE Type_of_Accidents = 'With injuries'
GROUP BY  Type_of_Accidents, DATENAME(year, Date_and_Time)
),
temp3 AS
(
SELECT  DATENAME(year, Date_and_Time) as Year, 
		Type_of_Accidents,
		COUNT(ID) Number_of_accidents, 
		LAG(COUNT(ID)) OVER ( ORDER BY Type_of_Accidents, DATENAME(year, Date_and_Time) ) AS Acc_from_last_year,
		COUNT(ID) - LAG(COUNT(ID)) OVER ( ORDER BY Type_of_Accidents, DATENAME(year, Date_and_Time) ) AS Difference,
		(COUNT(ID)*100)/LAG(COUNT(ID)) OVER ( ORDER BY Type_of_Accidents, DATENAME(year, Date_and_Time) ) AS InPercent
FROM accidents
WHERE Type_of_Accidents = 'With death'
GROUP BY  Type_of_Accidents, DATENAME(year, Date_and_Time)
)
SELECT temp.Year, 
		temp.Type_of_Accidents AS WithDamage, 
		temp.Number_of_accidents AS Number_of_accidents_damage, 
		CAST(CAST(temp.Difference*100 AS DECIMAL(10,2))/temp.Acc_from_last_year AS DECIMAL(10,2)) AS InPercentDamage, 
		temp2.Type_of_Accidents AS WithInjuries, 
		temp2.Number_of_accidents AS Number_of_accidents_injuries,
		CAST(CAST(temp2.Difference*100 AS DECIMAL(10,2))/temp2.Acc_from_last_year AS DECIMAL(10,2)) AS InPercentInjuries, 
		temp3.Type_of_Accidents AS WithDeath, 
		temp3.Number_of_accidents AS Number_of_accidents_death,
		CAST(CAST(temp3.Difference*100 AS DECIMAL(10,2))/temp3.Acc_from_last_year AS DECIMAL(10,2)) AS InPercentDeath
INTO acc_by_type_through_years
FROM temp
INNER JOIN temp2 ON temp.Year=temp2.Year
INNER JOIN temp3 ON temp.Year=temp3.Year
ORDER BY temp.Year;

SELECT * 
FROM acc_by_type_through_years;
/*-------------------------------------------------*/


/* Accidents by Season and Months*/
SELECT  DATENAME(month, Date_and_Time) AS Month, 
		CASE  
		WHEN (DATEPART(m,Date_and_Time)=1 OR DATEPART(m,Date_and_Time)=12 OR DATEPART(m,Date_and_Time)=2) THEN 'Winter'
		WHEN (DATEPART(m,Date_and_Time)=3 OR DATEPART(m,Date_and_Time)=4 OR DATEPART(m,Date_and_Time)=5) THEN 'Spring'
		WHEN (DATEPART(m,Date_and_Time)=6 OR DATEPART(m,Date_and_Time)=7 OR DATEPART(m,Date_and_Time)=8) THEN 'Summer'
		ELSE 'Autumn'
		END AS Season,
		COUNT(ID) AS Number_of_accidents
INTO acc_by_season_and_month
FROM accidents
GROUP BY  DATENAME(month, Date_and_Time),DATEPART(m, Date_and_Time);

SELECT *
FROM acc_by_season_and_month;

/*-------------------------------------------------*/


/*Number of accidents by part of day*/
WITH temp AS (
SELECT CASE  
		WHEN (DATEPART(hh,Date_and_Time)<=6) THEN 'Night'
		WHEN (DATEPART(hh,Date_and_Time)>=6 AND DATEPART(hh,Date_and_Time)<12) THEN 'Morning'
		WHEN (DATEPART(hh,Date_and_Time)>=12 AND DATEPART(hh,Date_and_Time)<18) THEN 'Afternoon'
		ELSE 'Evening'
		END AS Part_of_day,
		COUNT(ID) AS Number_of_Accidents
FROM accidents
GROUP BY DATEPART(hh,Date_and_Time)),
temp2 AS(
SELECT Part_of_day,
	   SUM(Number_of_Accidents) OVER (PARTITION BY Part_of_day) AS Number_of_accidents
FROM temp
GROUP BY Number_of_accidents,Part_of_day
)
SELECT  Part_of_day,
		Number_of_accidents
INTO acc_by_part_of_day
FROM temp2
GROUP BY Part_of_day, Number_of_accidents;


SELECT *
FROM acc_by_part_of_day
ORDER BY Number_of_accidents DESC;
/*-------------------------------------------------*/

