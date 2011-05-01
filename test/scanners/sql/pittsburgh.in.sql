----CS1555 - DATABASE MANAGEMENT SYSTEMS (SPRING 2011)
----DEPT. OF COMPUTER SCIENCE, UNIVERSITY OF PITTSBURGH
----ASSIGMENT #2: SQL - SAMPLE SOLUTION - PART 2
----Release: February 18, 2011

-----------------------------------------------------------
--Q4.a: List the names of all forests that have acid_level over 0.5.

prompt Q4.a 

SELECT Name 
FROM FOREST 
WHERE Acid_Level>0.5;


--------------------------

--Q4.b: Find the names of all roads in the forest whose name is “Allegheny National Forest”.
 
prompt Q4.b 
SELECT R.Name 
FROM	ROAD R, INTERSECTION I, FOREST F 
WHERE R.Road_No=I.Road_No and F.Forest_No=I.Forest_No and  
F.Name='Allegheny National Forest';

-------------------------
--Q4.c: List all the sensors along with the name of the workers who maintain them.
 
prompt Q4.c

SELECT s.Sensor_ID, w.Ssn, w.Name
from SENSOR s left outer join WORKER w on s.Maintainer = w.ssn; 

-------------------------------
--Q4.d: List all the sensors which have not been assigned a maintainer. 
prompt Q4.d

SELECT *
FROM SENSOR
WHERE Maintainer is null;

------------------------------
--Q4.e: Find the names of all forests such that no sensors in those forests reported anything between Jan 10, 2007 and Jan 11, 2007.
prompt Q4.e

SELECT Name 
FROM   FOREST
WHERE NOT EXISTS (SELECT Sensor_ID 
                  FROM SENSOR natural join REPORT 
                  WHERE (X between MBR_XMin and MBR_XMax) and (Y between MBR_YMin and MBR_YMax) 
                        and  (Report_Time between '10-JAN-07' and '11-JAN-07')
                 );

 


------------------------------
--Q4.f: List the pairs of states that share at least one forest (i.e., cover parts of the same forests).

prompt Q4.f

SELECT distinct c1.State, c2.State
FROM COVERAGE c1, COVERAGE c2
where c1.Forest_No = c2.Forest_No
     and c1.State < c2.State;

------------------------------
--Q4.g: For each forest, find its number of sensors and average temperature reported in January 2007. List them in descending order of the average temperatures.

prompt Q4.g
SELECT f.Forest_No, COUNT(distinct s.Sensor_ID) as Num_Sensors, AVG(r.Temperature) as Avg_Temp
FROM (FOREST f left outer join SENSOR s on (s.X between f.MBR_XMin and f.MBR_XMax) and (s.Y between f.MBR_YMin and f.MBR_YMax))
      left outer join (select * from Report where Report_Time between '1-JAN-07' and '31-JAN-07') r on s.Sensor_Id = r.Sensor_Id
GROUP BY f.Forest_No
ORDER BY AVG(r.Temperature) desc;

--Note that the left outer join is used instead of normal equi-join or theta-join in order to:
--+ include the forest that does not have any sensor in it
--+ include the forest whose sensors did not report anything in January 2007

-----------------------------

--Q4.h Find the states that have higher area of forest than Pennsylvania
prompt Q4.h

SELECT State
FROM coverage
GROUP BY State
HAVING sum(area) > (select sum(c.area) from State s join Coverage c on s.Abbreviation = c.State
                    where s.Name = 'Pennsylvania') ;


------------------------------------
--Q4.i: Find the states whose forests cover more than 30% of its area.

SELECT c.State 
FROM coverage c
GROUP BY c.State
HAVING sum(c.area) > 0.03* (select s.area from State s where s.Abbreviation = c.State) ;

---------------------------------
--Q4.j: Find the forest with the highest number of sensors

SELECT Forest_No
FROM Forest join Sensor  on (X between MBR_XMin and MBR_XMax) and (Y between MBR_YMin and MBR_YMax)
GROUP BY Forest_No
HAVING count(sensor_ID)  = (SELECT max(num_sensors) 
                              FROM (SELECT count(sensor_id) as num_sensors
                                    FROM Forest join Sensor on (X between MBR_XMin and MBR_XMax) and (Y between MBR_YMin and MBR_YMax)
                                    GROUP BY Forest_No)
			   );	
 



