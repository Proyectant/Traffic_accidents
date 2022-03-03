
/*MERGING ALL TABLES INTO NEW ONE CALLED all_accidents*/
SELECT * INTO all_accidents FROM( 
SELECT * FROM [dbo].[nez-opendata-2015]
UNION ALL
SELECT * FROM [dbo].[nez-opendata-2016]
UNION ALL
SELECT * FROM [dbo].[nez-opendata-2017]
UNION ALL
SELECT * FROM [dbo].[nez-opendata-2018]
UNION ALL
SELECT * FROM [dbo].[nez-opendata-2019-20200125]
UNION ALL
SELECT * FROM [dbo].[nez-opendata-2020-20210125]
UNION ALL 
SELECT * FROM [dbo].[nez-opendata-2021-20220125]) temp
/**/


ALTER TABLE all_accidents ADD Type_of_Accidents AS (
CASE all_accidents.VRSTA_NEZGODE
WHEN "Sa mat.stetom" THEN "With material damage"
WHEN "Sa poginulim" THEN "With death"
WHEN "Sa povredjenim" THEN "With injuries"
) Temp;




/*RENAMING COLUMNS*/
EXEC sp_rename 'all_accidents.OPŠTINA', 'Municipality', 'COLUMN';
EXEC sp_rename 'all_accidents.POLICIJSKA_UPRAVA', 'Police Department', 'COLUMN';
EXEC sp_rename 'all_accidents.DATUM_I_VREME', 'Date and Time', 'COLUMN';
EXEC sp_rename 'all_accidents.VRSTA_NEZGODE', 'Type of Accidents', 'COLUMN';
EXEC sp_rename 'all_accidents.OPIS_NEZGODE', 'Description', 'COLUMN';
EXEC sp_rename 'all_accidents.LONGITUDE', 'Longitude', 'COLUMN';
EXEC sp_rename 'all_accidents.LATITUDE', 'Latitude', 'COLUMN';
/**/



DROP TABLE all_accidents
SELECT * FROM all_accidents