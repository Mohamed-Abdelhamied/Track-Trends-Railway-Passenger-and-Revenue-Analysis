-- 1. Total Number of Trips by Journey Date
SELECT COUNT([transaction_id]) AS trip_count, [month] 
FROM date 
JOIN [dbo].[fact_railway] ON [dbo].[fact_railway].journey_date_id = date.full_date
GROUP BY [month];

-- 2. Total Number of Trips by Purchase Date
SELECT COUNT([transaction_id]) AS trip_count, [month] 
FROM date 
JOIN [dbo].[fact_railway] ON [dbo].[fact_railway].[purchase_date_id] = date.full_date
GROUP BY [month];

-- 3. Average Delay Time per Station per Month
SELECT D.[month], DepartureStation.station AS DepartureStation, ArrivalStation.station AS ArrivalStation,
AVG(DATEDIFF(MINUTE, Scheduled.full_time, Actual.full_time)) AS avg_delay_minutes
FROM fact_railway F
JOIN time Actual ON F.actual_arrival_time_id = Actual.full_time
JOIN time Scheduled ON F.arrival_time_id = Scheduled.full_time
JOIN station ArrivalStation ON F.arrival_station_id = ArrivalStation.station_id
JOIN station DepartureStation ON F.departure_station_id = DepartureStation.station_id
JOIN date D ON F.journey_date_id = D.full_date
WHERE DATEDIFF(MINUTE, Scheduled.full_time, Actual.full_time) > 0
GROUP BY D.[month], DepartureStation.station, ArrivalStation.station
ORDER BY D.[month], avg_delay_minutes DESC;


-- 4. Average Journey Time per Station per Month
SELECT D.[month], DepartureStation.station AS departure_station, ArrivalStation.station AS arrival_station,
AVG(DATEDIFF(MINUTE, Departure.full_time, ActualArrival.full_time)) AS avg_journey_minutes
FROM fact_railway F
JOIN time ActualArrival ON F.actual_arrival_time_id = ActualArrival.full_time
JOIN time Departure ON F.departure_time_id = Departure.full_time
JOIN station ArrivalStation ON F.arrival_station_id = ArrivalStation.station_id
JOIN station DepartureStation ON F.departure_station_id = DepartureStation.station_id
JOIN date D ON F.journey_date_id = D.full_date
WHERE DATEDIFF(MINUTE, Departure.full_time, ActualArrival.full_time) > 0
GROUP BY D.[month], DepartureStation.station, ArrivalStation.station
ORDER BY D.[month], avg_journey_minutes DESC;

-- 5. Delayed Trips Count per Station
SELECT S.station AS arrival_station,d.station as departure_station, COUNT(*) AS delay_count
FROM fact_railway F
JOIN [dbo].[journey] j ON j.journey_id = F.journey_id
JOIN station S ON F.arrival_station_id = S.station_id
JOIN station d ON f.[departure_station_id] = d.station_id
WHERE journey_status = 'delayed'
GROUP BY S.station ,d.station
ORDER BY delay_count DESC;

-- 6. Canceled Trips Count per Station
SELECT S.station AS arrival_station,d.station as departure_station, COUNT(*) AS delay_count
FROM fact_railway F
JOIN [dbo].[journey] j ON j.journey_id = F.journey_id
JOIN station S ON F.arrival_station_id = S.station_id
JOIN station d ON f.[departure_station_id] = d.station_id
WHERE journey_status = 'cancelled'
GROUP BY S.station ,d.station
ORDER BY delay_count DESC;
-- 7. Journey Status Count (Delayed and Canceled Trips)
SELECT J.journey_status, COUNT(*) AS journey_count
FROM fact_railway F
JOIN journey J ON F.journey_id = J.journey_id
GROUP BY J.journey_status


-- 8. Count of Trips by Delay Reason
SELECT J.[reason_for_delay], COUNT(*) AS delay_count
FROM fact_railway F
JOIN journey J ON F.journey_id = J.journey_id and  J.journey_status ='delayed'
GROUP BY [reason_for_delay];

-- 9. Passenger Count by Purchase Type and Payment Method
SELECT p.[purchase_type], p.[payment_method], COUNT([Transaction_ID]) AS passenger_count
FROM fact_railway F
JOIN [dbo].[payment] p ON F.[payment_id] = p.[payment_id]
GROUP BY p.[purchase_type], p.[payment_method]
ORDER BY passenger_count DESC;

-- 10. Passenger Count by Ticket Type and Class
SELECT t.[ticket_type], t.[ticket_class], t.[railcard], COUNT([Transaction_ID]) AS passenger_count
FROM fact_railway F
JOIN [dbo].[ticket] t ON F.[ticket_id] = t.[ticket_id]
GROUP BY t.[ticket_type], t.[ticket_class], t.[railcard]
ORDER BY passenger_count DESC;

-- 11. Revenue and Passenger Count per Departure and Arrival Station
SELECT 
S.station AS arrival_station, SD.station AS departure_station, 
 sum(F.price) AS sum_ticket_price,  COUNT(F.Transaction_ID) AS passenger_count
FROM fact_railway F
JOIN station SD ON F.departure_station_id = SD.station_id
JOIN station S ON F.arrival_station_id = S.station_id
GROUP BY S.station, SD.station
order by passenger_count desc;


-- 12. Average Ticket Price per Station Pair
SELECT S.station AS arrival_station, SD.station AS departure_station, AVG(F.price) AS avg_ticket_price
FROM fact_railway F
JOIN station SD ON F.departure_station_id = SD.station_id
JOIN station S ON F.arrival_station_id = S.station_id
GROUP BY S.station, SD.station
ORDER BY avg_ticket_price DESC;

-- 13. Total Revenue and Passenger Count by Purchase Type and Payment Method
SELECT p.purchase_type, p.payment_method, SUM(F.price) AS total_revenue, COUNT(F.transaction_id) AS passenger_count
FROM fact_railway F
JOIN payment p ON F.payment_id = p.payment_id
GROUP BY p.purchase_type, p.payment_method
ORDER BY total_revenue DESC;

-- 14. Revenue Lost Due to Refunded Journeys
SELECT J.refund_request, SUM(F.price) AS refunded_revenue
FROM fact_railway F
JOIN journey J ON F.journey_id = J.journey_id
WHERE J.refund_request = 'refunded'
GROUP BY J.refund_request;
-- 15. Revenue Lost Due to Refunded Journeys per Departure and Arrival Station
SELECT 
    DepartureStation.station AS DepartureStation, 
    ArrivalStation.station AS ArrivalStation, 
    J.journey_id, 
    J.refund_request, 
    SUM(F.price) AS refunded_revenue
FROM fact_railway F
JOIN journey J ON F.journey_id = J.journey_id
JOIN station DepartureStation ON F.departure_station_id = DepartureStation.station_id
JOIN station ArrivalStation ON F.arrival_station_id = ArrivalStation.station_id
WHERE J.refund_request = 'refunded'
GROUP BY 
    DepartureStation.station, 
    ArrivalStation.station, 
    J.journey_id, 
    J.refund_request
ORDER BY DepartureStation.station, ArrivalStation.station, J.journey_id;

-- 16. Total Monthly Revenue
SELECT D.[month], SUM(F.price) AS monthly_revenue
FROM fact_railway F
JOIN date D ON F.journey_date_id = D.full_date
GROUP BY D.[month]
ORDER BY [month];

-- Monthly Revenue per Departure and Arrival Station
SELECT 
  D.[month], 
  DepartureStation.station AS departure_station,
  ArrivalStation.station AS arrival_station,
  SUM(F.price) AS monthly_revenue
FROM fact_railway F
JOIN date D ON F.journey_date_id = D.full_date
JOIN station DepartureStation ON F.departure_station_id = DepartureStation.station_id
JOIN station ArrivalStation ON F.arrival_station_id = ArrivalStation.station_id
GROUP BY D.[month], DepartureStation.station, ArrivalStation.station
ORDER BY D.[month], monthly_revenue DESC;
