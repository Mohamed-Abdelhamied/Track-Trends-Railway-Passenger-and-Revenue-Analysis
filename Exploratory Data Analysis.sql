-- This query calculates the total number of trips for each month based on the journey_date_id.
select count([transaction_id]) AS trip_count, [month] 
from date join [dbo].[fact_railway] on [dbo].[fact_railway].journey_date_id = date.date_id
group by [month];



-- This query calculates the total number of trips for each month based on the purchase_date_id.
select count([transaction_id]) AS trip_count, [month] 
from date join [dbo].[fact_railway] on [dbo].[fact_railway].[purchase_date_id] = date.date_id
group by [month];




-- This query calculates the average delay time in minutes for each station per month.
SELECT D.[month],station AS arrival_station,
AVG(DATEDIFF(MINUTE, Scheduled.full_time, Actual.full_time)) AS avg_delay_minutes
FROM fact_railway F
JOIN  time Actual ON F.actual_arrival_time_id = Actual.time_id
JOIN time Scheduled ON F.arrival_time_id = Scheduled.time_id
JOIN station ArrivalStation ON F.arrival_station_id = ArrivalStation.station_id
JOIN date D ON F.journey_date_id = D.date_id
WHERE DATEDIFF(MINUTE, Scheduled.full_time, Actual.full_time) > 0
GROUP BY D.[month],ArrivalStation.station
ORDER BY  D.[month],avg_delay_minutes DESC;





-- This query calculates the average journey time in minutes for each arrival station per month.
SELECT 
 D.[month],
 DepartureStation.station AS departure_station,ArrivalStation.station AS arrival_station,
AVG(DATEDIFF(MINUTE, Departure.full_time, ActualArrival.full_time)) AS avg_journey_minutes
FROM fact_railway F
JOIN time ActualArrival ON F.actual_arrival_time_id = ActualArrival.time_id
JOIN time Departure ON F.departure_time_id = Departure.time_id
JOIN  station ArrivalStation ON F.arrival_station_id = ArrivalStation.station_id
JOIN station DepartureStation ON F.departure_station_id = DepartureStation.station_id
JOIN date D ON F.journey_date_id = D.date_id
WHERE DATEDIFF(MINUTE, Departure.full_time, ActualArrival.full_time) > 0
GROUP BY D.[month],DepartureStation.station, ArrivalStation.station
ORDER BY D.[month],avg_journey_minutes DESC;




-- This query calculates the count of delayed trips for each station.
SELECT S.station AS arrival_station, COUNT(*) AS delay_count
FROM fact_railway F
JOIN [dbo].[journey] j on j.journey_id=f.journey_id
JOIN station S ON F.arrival_station_id = S.station_id
WHERE journey_status='delayed'
GROUP BY S.station
ORDER BY delay_count DESC;


-- This query calculates the count of canceled trips for each station.
SELECT [Departure_Station],[Arrival_Destination], COUNT(*) AS delay_count
FROM [dbo].[Canceled_railway_trips]
GROUP BY [Arrival_Destination],[Departure_Station]
ORDER BY delay_count DESC;




-- This query calculates the journey status counts for delayed and canceled trips.
SELECT J.journey_status,COUNT(*) AS journey_count 
FROM fact_railway F
JOIN journey J ON F.journey_id = J.journey_id 
GROUP BY J.journey_status
UNION ALL
SELECT journey_status, COUNT(*) AS journey_count 
FROM [dbo].[Canceled_railway_trips]
GROUP BY journey_status;




-- This query calculates the count of trips based on the reason for delay.
SELECT J.[reason_for_delay], COUNT(*) AS delay_count 
FROM fact_railway F
JOIN journey J ON F.journey_id = J.journey_id 
GROUP BY [reason_for_delay];




-- This query calculates the count of canceled trips based on the reason for cancellation.
SELECT [reason_for_Cancelled],COUNT(*) AS delay_count 
FROM Canceled_railway_trips
GROUP BY [reason_for_Cancelled];




-- This query calculates the count of delayed trips for each date.
SELECT D.full_date, COUNT(*) AS status_count
FROM fact_railway F
JOIN journey J ON F.journey_id = J.journey_id
JOIN  [dbo].[date] D ON F.journey_date_id = D.date_id  
WHERE J.journey_status IN ('Delayed') 
GROUP BY  D.full_date
ORDER BY status_count DESC;




-- This query calculates the count of delayed trips for each hour and period.
SELECT [hour],[period], COUNT(*) AS status_count
FROM fact_railway F
JOIN time T ON F.arrival_time_id = T.time_id  
JOIN journey J ON F.journey_id = J.journey_id
GROUP BY T.[hour],[period]
ORDER BY status_count DESC;



-- This query calculates the count of delayed or canceled trips by date.
SELECT D.full_date, COUNT(*) AS status_count
FROM fact_railway F
JOIN journey J ON F.journey_id = J.journey_id
JOIN [dbo].[date] D ON F.journey_date_id = D.date_id  
WHERE J.journey_status IN ('Delayed')  
GROUP BY D.full_date
UNION ALL
SELECT 
    [Date_of_Journey], COUNT(*) AS status_count
FROM [dbo].[Canceled_railway_trips] C  
GROUP BY [Date_of_Journey]
ORDER BY status_count DESC;



-- This query calculates the passenger count based on purchase type and payment method.
SELECT p.[purchase_type], p.[payment_method], COUNT([Transaction_ID]) AS passenger_count
FROM fact_railway F
JOIN [dbo].[payment] p ON F.[payment_id] = p.[payment_id]  
GROUP BY p.[purchase_type], p.[payment_method]
ORDER BY passenger_count DESC;



-- This query calculates the passenger count based on ticket type and class.
SELECT t.[ticket_type], t.[ticket_class], t.[railcard], COUNT([Transaction_ID]) AS passenger_count
FROM fact_railway F
JOIN [dbo].[ticket] t ON F.[ticket_id] = t.[ticket_id]
GROUP BY t.[ticket_type], t.[ticket_class], t.[railcard]
ORDER BY passenger_count DESC;




-- This query calculates the passenger count for each arrival station.
SELECT s.[station], COUNT([Transaction_ID]) AS passenger_count
FROM fact_railway F
JOIN [dbo].[station] s ON f.[arrival_station_id] = s.[station_id]
GROUP BY [station] 
ORDER BY passenger_count DESC;




-- This query calculates the passenger count for each departure station.
SELECT s.[station], COUNT([Transaction_ID]) AS passenger_count
FROM fact_railway F
JOIN [dbo].[station] s ON f.[departure_station_id] = s.[station_id]
GROUP BY [station] 
ORDER BY passenger_count DESC;




-- This query calculates the passenger count based on railcard and arrival station.
SELECT s.station,sa.station , t.[railcard], COUNT([Transaction_ID]) AS passenger_count
FROM fact_railway F
JOIN [dbo].[ticket] t ON F.[ticket_id] = t.[ticket_id] 
JOIN [dbo].[station] s ON f.[departure_station_id] = s.[station_id]
JOIN [dbo].[station] sa ON f.[arrival_station_id] = sa.[station_id]
GROUP BY s.station,sa.station, [railcard]
ORDER BY passenger_count DESC;



-- This query calculates the passenger count for each hour based on arrival time.
SELECT t.[hour], COUNT([Transaction_ID]) AS passenger_count
FROM fact_railway F
JOIN time t ON f.[arrival_time_id] = t.[time_id]
GROUP BY t.[hour]
ORDER BY passenger_count DESC;



-- This query calculates the passenger count based on purchase type.
SELECT purchase_type, COUNT([Transaction_ID]) AS passenger_count
FROM fact_railway F
JOIN [dbo].[payment] p ON f.[payment_id] = p.payment_id
GROUP BY purchase_type;




-- This query calculates the passenger count based on payment method.
SELECT [payment_method], COUNT([Transaction_ID]) AS passenger_count
FROM fact_railway F
JOIN [dbo].[payment] p ON f.[payment_id] = p.payment_id
GROUP BY [payment_method];



-- This query calculates the passenger count based on ticket type and class.
SELECT [ticket_type], [ticket_class], COUNT([Transaction_ID]) AS passenger_count
FROM [dbo].[ticket] T
JOIN [dbo].[fact_railway] F ON f.ticket_id = t.ticket_id
GROUP BY [ticket_type], [ticket_class];



-- This query calculates the passenger count based on railcard.
SELECT railcard, COUNT([Transaction_ID]) AS passenger_count
FROM [dbo].[ticket] T
JOIN [dbo].[fact_railway] F ON f.ticket_id = t.ticket_id
GROUP BY [railcard];




-- This query calculates the passenger count based on ticket type and railcard.
SELECT [ticket_type], [railcard], COUNT([Transaction_ID]) AS passenger_count
FROM [dbo].[ticket] T
JOIN [dbo].[fact_railway] F ON f.ticket_id = t.ticket_id
GROUP BY [ticket_type], [railcard];



-- This query calculates the total revenue and passenger count for each departure and arrival station.
SELECT DS.station AS departure_station, xS.station AS arrival_station, SUM(F.price) AS total_revenue, COUNT([Transaction_ID]) AS passenger_count   
FROM fact_railway F
JOIN station DS ON F.departure_station_id = DS.station_id  
JOIN station xS ON F.arrival_station_id = xS.station_id    
GROUP BY DS.station, xS.station
ORDER BY total_revenue DESC;





-- هذا الاستعلام يقوم بحساب متوسط التأخير (بالدقائق) في وصول القطارات
-- لكل محطة وصول ومحطة مغادرة خلال كل شهر،
SELECT D.[month],ar.station AS arrival_station, de.station AS departure_station,
 AVG(DATEDIFF(MINUTE, scheduled_time.full_time, actual_time.full_time)) AS avg_delay_minutes
FROM fact_railway F
JOIN time scheduled_time ON F.arrival_time_id = scheduled_time.time_id
JOIN time actual_time ON F.actual_arrival_time_id = actual_time.time_id
JOIN station ar ON F.arrival_station_id = ar.station_id
JOIN station de ON F.departure_station_id = de.station_id
JOIN date D ON F.journey_date_id = D.date_id
WHERE DATEDIFF(MINUTE, scheduled_time.full_time, actual_time.full_time) > 0
GROUP BY D.[month], ar.station, de.station
ORDER BY D.[month],avg_delay_minutes DESC;



-- This query calculates the average journey time in minutes for each departure and arrival station per month.
SELECT 
    D.[month], 
    DS.station AS departure_station, 
    AS_.station AS arrival_station, 
    AVG(DATEDIFF(MINUTE, DEP.full_time, ARR.full_time)) AS avg_journey_minutes
FROM fact_railway F
JOIN time DEP ON F.departure_time_id = DEP.time_id
JOIN time ARR ON F.actual_arrival_time_id = ARR.time_id
JOIN station DS ON F.departure_station_id = DS.station_id
JOIN station AS_ ON F.arrival_station_id = AS_.station_id
JOIN date D ON F.journey_date_id = D.date_id
WHERE DATEDIFF(MINUTE, DEP.full_time, ARR.full_time) > 0
GROUP BY D.[month], DS.station, AS_.station
ORDER BY D.[month], avg_journey_minutes DESC;



-- هذا الاستعلام لحساب عدد الرحلات المتأخرة أو الملغاة في كل يوم
SELECT 
    D.full_date,  
    COUNT(*) AS status_count
FROM fact_railway F
JOIN journey J ON F.journey_id = J.journey_id
JOIN [dbo].[date] D ON F.journey_date_id = D.date_id  
WHERE J.journey_status IN ('Delayed')  
GROUP BY D.full_date
UNION ALL
SELECT 
    [Date_of_Journey], COUNT(*) AS status_count
FROM [dbo].[Canceled_railway_trips] C  
GROUP BY [Date_of_Journey]
ORDER BY status_count DESC;



-- هذا الاستعلام يعرض عدد الطلبات حسب حالة الاسترداد من جدول الرحلات الفعلية
SELECT 
   [refund_request],  
    COUNT(*) AS status_count
FROM fact_railway F
JOIN journey J ON F.journey_id = J.journey_id
GROUP BY [refund_request];



-- هذا الاستعلام يعرض عدد الطلبات حسب حالة الاسترداد من جدول الرحلات الملغاة
SELECT 
    [refund_request], COUNT(*) AS status_count
FROM [dbo].[Canceled_railway_trips]  
GROUP BY [refund_request]
ORDER BY status_count DESC;



-- هذا الاستعلام يعرض أسباب التأخير وعدد مرات حدوث كل سبب من جدول الرحلات الملغاة
SELECT 
    [Reason_for_Cancelled],
    COUNT(*) AS delay_count
FROM [dbo].[Canceled_railway_trips] 
GROUP BY [Reason_for_Cancelled]
ORDER BY delay_count DESC;



-- هذا الاستعلام يعرض أسباب التأخير للرحلات التي تم رد قيمتها فقط من جدول الرحلات الملغاة
SELECT 
    [Reason_for_Cancelled],
    COUNT(*) AS delay_count
FROM [dbo].[Canceled_railway_trips] 
where [Refund_Request] = 'refunded'
GROUP BY [Reason_for_Cancelled]
ORDER BY delay_count DESC;



-- هذا الاستعلام يعرض أسباب التأخير للرحلات التي تم رد قيمتها فقط من جدول الرحلات الفعلية
SELECT 
    J.reason_for_delay,
    COUNT(*) AS delay_count
FROM fact_railway F
JOIN journey J ON F.journey_id = J.journey_id
WHERE J.refund_request = 'refunded'
GROUP BY J.reason_for_delay
ORDER BY delay_count DESC;


-- This query calculates the total revenue and the number of passengers 
SELECT  DS.station AS departure_station,  AS_.station AS arrival_station, 
SUM(F.price) AS total_revenue, COUNT(F.transaction_id) AS passenger_count
FROM fact_railway F
JOIN station DS ON F.departure_station_id = DS.station_id
JOIN station AS_ ON F.arrival_station_id = AS_.station_id
GROUP BY  DS.station, AS_.station
ORDER BY  total_revenue DESC;


	-- This query calculates the average ticket price and total number of tickets sold for each combination of ticket type and ticket class.
SELECT t.ticket_type, t.ticket_class, AVG(F.price) AS avg_ticket_price, 
COUNT(F.transaction_id) AS total_tickets
FROM fact_railway F
JOIN  ticket t ON F.ticket_id = t.ticket_id
GROUP BY  t.ticket_type, t.ticket_class
ORDER BY avg_ticket_price DESC;

-- This query calculates the total revenue and number of passengers based on the purchase type and payment method used.
SELECT 
 p.purchase_type, 
 p.payment_method, 
SUM(F.price) AS total_revenue, 
COUNT(F.transaction_id) AS passenger_count
FROM  fact_railway F
JOIN payment p ON F.payment_id = p.payment_id
GROUP BY p.purchase_type, p.payment_method
ORDER BY total_revenue DESC;

-- This query calculates the average ticket trip .
SELECT 
 S.station AS arrival_station,SD.station AS departure_station, 
 AVG(F.price) AS avg_ticket_price
FROM fact_railway F
JOIN station SD ON F.departure_station_id = SD.station_id
JOIN station S ON F.arrival_station_id = S.station_id
GROUP BY S.station,SD.station
ORDER BY avg_ticket_price DESC;


--  the revenue lost due to refunded journeys.
SELECT  J.refund_request,  SUM(F.price) AS refunded_revenue
FROM  fact_railway F
JOIN journey J ON F.journey_id = J.journey_id
WHERE  J.refund_request = 'refunded'
GROUP BY  J.refund_request;


--  the revenue lost due to refunded journeys from Canceled_railway_trips.
SELECT  refund_request,  SUM(price) AS refunded_revenue
FROM  [dbo].[Canceled_railway_trips]

WHERE  refund_request = 'refunded'
GROUP BY  refund_request;


-- This query calculates the total revenue generated during different hours of the day.
SELECT T.[hour], SUM(F.price) AS revenue_by_hour
FROM fact_railway F
JOIN  time T ON F.arrival_time_id = T.time_id
GROUP BY T.[hour]
ORDER BY revenue_by_hour DESC;


-- This query calculates the total monthly revenue.
SELECT  D.[month], SUM(F.price) AS monthly_revenue
FROM fact_railway F
JOIN date D ON F.journey_date_id = D.date_id
GROUP BY  D.[month]
ORDER BY monthly_revenue;



