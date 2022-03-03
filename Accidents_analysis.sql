/*Number of accidents by type*/
SELECT  Type_of_Accidents, 
		COUNT(ID) AS Number_of_Accidents INTO acc_by_type 
FROM accidents
GROUP BY Type_of_Accidents;

SELECT * 
FROM acc_by_type
ORDER BY Number_of_Accidents DESC;
/**/

/*Top 10 municipalities by number of accidents*/
SELECT  TOP 10 Municipality, 
		COUNT(ID) AS Number_of_Accidents INTO acc_by_municipality
FROM accidents
GROUP BY Municipality
ORDER BY Number_of_Accidents DESC;

SELECT * 
FROM acc_by_municipality
ORDER BY Number_of_Accidents DESC;
/**/

/*Number of accidents by participants*/
SELECT  Participants, 
		COUNT(ID) AS Number_of_Accidents INTO acc_by_participants
FROM accidents
GROUP BY Participants;

SELECT *
FROM acc_by_participants
ORDER BY Number_of_Accidents DESC;
/**/

/*Number of accidents by month*/
SELECT  DATENAME(month, Date_and_Time) AS Month , 
		COUNT(ID) AS Number_of_Accidents INTO acc_by_month
FROM accidents
GROUP BY DATENAME(month, Date_and_Time)

SELECT * FROM acc_by_month
ORDER BY Number_of_Accidents DESC
/**/

/*Number of accidents by day*/
SELECT  DATENAME(weekday, Date_and_Time) AS Day , 
		COUNT(ID) AS Number_of_Accidents 
INTO acc_by_day
FROM accidents
GROUP BY DATENAME(weekday, Date_and_Time);

SELECT *
FROM acc_by_day
ORDER BY Number_of_Accidents  DESC;
/**/


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
/**/



SELECT DATENAME(weekday, Date_and_Time) AS Day, (CASE
           WHEN (((DATEPART(DW,Date_and_Time ) - 1 ) + @@DATEFIRST ) % 7) IN (0,6)
           THEN 'Weekend'
           ELSE 'Weekday'
       END) AS is_weekend_day
FROM accidents