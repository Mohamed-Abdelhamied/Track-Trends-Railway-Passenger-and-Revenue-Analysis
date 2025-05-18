-- إنشاء قاعدة البيانات railway
CREATE DATABASE railway;

-- إنشاء جدول journey لتخزين معلومات الرحلات
CREATE TABLE journey (
    journey_id INT IDENTITY(1,1) PRIMARY KEY,    
    journey_status VARCHAR(50) NULL,        
    reason_for_delay VARCHAR(50) NULL,       
    refund_request VARCHAR(50) NULL          
);

-- إنشاء جدول station لتخزين محطات القطارات
CREATE TABLE station (
    station_id INT IDENTITY(1,1) PRIMARY KEY,  
    station VARCHAR(200) NOT NULL               
);
-- إنشاء جدول date لتخزين تواريخ الرحلات
CREATE TABLE date (
    full_date DATE  PRIMARY KEY,                        
    year INT,                                
    month INT,                               
    day INT,                                 
    week_day VARCHAR(20)                     
);

-- إنشاء جدول time لتخزين أوقات الرحلات
CREATE TABLE time (
     
    full_time TIME PRIMARY KEY,                           
    hour INT,                                 
    minute INT,                               
    period VARCHAR(50)                       
);

-- إنشاء جدول payment لتخزين معلومات الدفع
CREATE TABLE payment (
    payment_id INT IDENTITY(1,1) PRIMARY KEY,  
    purchase_type VARCHAR(50),                 
    payment_method VARCHAR(50)                 
);

-- إنشاء جدول ticket لتخزين معلومات التذاكر
CREATE TABLE ticket (
    ticket_id INT IDENTITY(1,1) PRIMARY KEY,   
    ticket_type VARCHAR(50),                   
    ticket_class VARCHAR(50),                  
    railcard VARCHAR(50)                     
);

-- إنشاء جدول fact_railway لتخزين بيانات المعاملات المتعلقة بالسكك الحديدية
CREATE TABLE fact_railway (
    [Transaction_ID] VARCHAR(100) PRIMARY KEY,
    ticket_id INT,
    payment_id INT,
    departure_station_id INT,
    arrival_station_id INT,
    journey_id INT,
    purchase_date_id DATE,
    journey_date_id DATE,
    purchase_time_id TIME,
    departure_time_id TIME,
    arrival_time_id TIME,
    actual_arrival_time_id TIME,
	price int,

    FOREIGN KEY (ticket_id) REFERENCES dbo.ticket(ticket_id),
    FOREIGN KEY (payment_id) REFERENCES dbo.payment(payment_id),
    FOREIGN KEY (departure_station_id) REFERENCES dbo.station(station_id),
    FOREIGN KEY (arrival_station_id) REFERENCES dbo.station(station_id),
    FOREIGN KEY (journey_id) REFERENCES dbo.journey(journey_id),
    FOREIGN KEY (purchase_date_id) REFERENCES dbo.date(full_date),
    FOREIGN KEY (journey_date_id) REFERENCES dbo.date(full_date),
    FOREIGN KEY (purchase_time_id) REFERENCES dbo.time(full_time),
    FOREIGN KEY (departure_time_id) REFERENCES dbo.time(full_time),
    FOREIGN KEY (arrival_time_id) REFERENCES dbo.time(full_time),
    FOREIGN KEY (actual_arrival_time_id) REFERENCES dbo.time(full_time)
);

select * from railway


select * from railway
-- إدخال بيانات مميزة إلى جدول dim_date بناءً على تاريخ الشراء
INSERT INTO [dbo].[date] (full_date, year, month, day, week_day)
SELECT DISTINCT 
    Date_of_Purchase AS full_date,           
    YEAR(Date_of_Purchase) AS year,          
    MONTH(Date_of_Purchase) AS month,        
    DAY(Date_of_Purchase) AS day,            
    DATENAME(WEEKDAY, Date_of_Purchase) AS week_day  
FROM railway
WHERE Date_of_Purchase IS NOT NULL;

-- إدخال بيانات مميزة إلى جدول dim_date بناءً على تاريخ الرحلة
INSERT INTO [dbo].[date] (full_date, year, month, day, week_day)
SELECT DISTINCT 
    r.Date_of_Journey AS full_date,            
    YEAR(r.Date_of_Journey) AS year,           
    MONTH(r.Date_of_Journey) AS month,         
    DAY(r.Date_of_Journey) AS day,             
    DATENAME(WEEKDAY, r.Date_of_Journey) AS week_day  
FROM railway r
WHERE r.Date_of_Journey IS NOT NULL
  AND NOT EXISTS (
        SELECT 1 
        FROM [dbo].[date] d
        WHERE d.full_date = r.Date_of_Journey
    );

-- عرض البيانات في جدول dim_date
SELECT * FROM [dbo].[dim_date];


ALTER TABLE railway.dbo.journey
DROP CONSTRAINT PK_journey_id;

-- إدخال بيانات مميزة إلى جدول dim_journey بناءً على معلومات الرحلة
INSERT INTO dbo.journey (journey_status, reason_for_delay, refund_request)
SELECT DISTINCT 
    journey_status,                         
    reason_for_delay,                       
    refund_request                           
FROM railway;

-- عرض البيانات في جدول dim_journey
SELECT * FROM [dbo].[dim_journey];

-- إدخال بيانات مميزة إلى جدول dim_payment بناءً على نوع الدفع وطريقة الدفع
INSERT INTO dbo.payment (purchase_type, payment_method)
SELECT DISTINCT 
    purchase_type,                        
    payment_method                         
FROM railway;

-- عرض البيانات في جدول dim_payment
SELECT * FROM [dbo].payment;

-- إدخال بيانات مميزة إلى جدول dim_station بناءً على محطات الوصول والمغادرة
INSERT INTO dbo.station (station)
SELECT DISTINCT Arrival_Destination FROM railway
WHERE Arrival_Destination IS NOT NULL

UNION 

SELECT DISTINCT Departure_Station FROM railway
WHERE Departure_Station IS NOT NULL;

-- عرض البيانات في جدول dim_station
SELECT * FROM [dbo].station;

-- إدخال بيانات مميزة إلى جدول dim_ticket بناءً على معلومات التذاكر
INSERT INTO dbo.ticket (ticket_type, ticket_class, railcard)
SELECT DISTINCT ticket_type, ticket_class, railcard 
FROM railway;

-- عرض البيانات في جدول dim_ticket
SELECT * FROM [dbo].ticket;

-- تحديث جدول fact_railway بناءً على تاريخ الشراء في جدول dim_date
UPDATE f
SET f.[purchase_date_id] = d.full_date
FROM [fact_railway] f
JOIN railway r ON f.transaction_id = r.transaction_id   
JOIN [dbo].date d ON r.Date_of_Purchase = d.full_date
WHERE r.Date_of_Purchase IS NOT NULL;

-- تحديث جدول fact_railway بناءً على تاريخ الرحلة في جدول dim_date
UPDATE f
SET f.[journey_date_id] = d.full_date
FROM [fact_railway] f
JOIN railway r ON f.transaction_id = r.transaction_id  
JOIN [dbo].date d ON r.[Date_of_Journey] = d.full_date
WHERE r.[Date_of_Journey] IS NOT NULL;

-- إدخال بيانات مميزة إلى جدول fact_railway بناءً على معرف المعاملة
INSERT INTO [fact_railway] (transaction_id)
SELECT transaction_id FROM [dbo].[railway]
WHERE transaction_id IS NOT NULL;

select * from [fact_railway]
-- تحديث جدول fact_railway بناءً على وقت المغادرة في جدول dim_time
UPDATE f
SET f.[departure_time_id] = t.full_time
FROM [fact_railway] f
JOIN railway r ON f.transaction_id = r.transaction_id 
JOIN [dbo].time t ON CAST(r.[departure_time] AS TIME) = t.full_time
WHERE r.[departure_time] IS NOT NULL;

-- تحديث جدول fact_railway بناءً على وقت الشراء في جدول dim_time
UPDATE f
SET f.[purchase_time_id] = t.full_time
FROM [fact_railway] f
JOIN railway r ON f.transaction_id = r.transaction_id  
JOIN [dbo].time t ON CAST(r.[Time_of_Purchase] AS TIME) = t.full_time
WHERE r.[Time_of_Purchase] IS NOT NULL;

-- تحديث جدول fact_railway بناءً على وقت الوصول الفعلي في جدول dim_time
UPDATE f
SET f.[actual_arrival_time_id] = t.full_time
FROM [fact_railway] f
JOIN railway r ON f.transaction_id = r.Transaction_ID
JOIN [dbo].time t ON CAST(r.[Actual_Arrival_Time] AS TIME) = t.full_time
WHERE r.[Actual_Arrival_Time] IS NOT NULL;

-- تحديث جدول fact_railway بناءً على السعر في جدول railway
UPDATE f
SET f.price = r.price
FROM [fact_railway] f
JOIN [railway] r ON f.transaction_id = r.transaction_id
WHERE r.price IS NOT NULL;



-- تحديث جدول fact_railway بناءً على معرف الرحلة في جدول dim_journey
UPDATE f
SET f.journey_id = j.journey_id
FROM [fact_railway] f
JOIN [railway] r ON f.transaction_id = r.transaction_id
JOIN journey j 
    ON r.journey_status = j.journey_status 
    AND r.reason_for_delay = j.reason_for_delay
    AND r.refund_request = j.refund_request
WHERE j.journey_id IS NOT NULL;

-- تحديث جدول fact_railway بناءً على معرف الرحلة في جدول dim_journey
UPDATE f
SET f.journey_id = j.journey_id
FROM [fact_railway] f
JOIN [railway] r ON f.transaction_id = r.transaction_id
JOIN journey j 
    ON r.reason_for_delay = j.reason_for_delay and r.[journey_status]=j.[journey_status] and r.[refund_request]=j.[refund_request]
WHERE j.journey_id IS NOT NULL;

-- تحديث جدول fact_railway بناءً على معرف محطة المغادرة في جدول dim_station
UPDATE f
SET f.[departure_station_id] = s.station_id
FROM [fact_railway] f
JOIN [railway] r ON f.transaction_id = r.transaction_id
JOIN station s 
    ON r.[Departure_Station] = s.station
WHERE s.station_id IS NOT null

UPDATE f
SET f.[arrival_station_id] = s.station_id
FROM [fact_railway] f
JOIN [railway] r ON f.transaction_id = r.transaction_id
JOIN station s 
    ON r.[Arrival_Destination] = s.station
WHERE s.station_id IS NOT null


select * from [dbo].[fact_railway]


-- إضافة وقت الوصول الفعلي إلى جدول time بدون تكرار
INSERT INTO time (full_time, hour, minute, period)
SELECT DISTINCT 
    CAST(Actual_Arrival_Time AS TIME) AS full_time,
    DATEPART(HOUR, Actual_Arrival_Time) AS hour,
    DATEPART(MINUTE, Actual_Arrival_Time) AS minute,
    CASE
        WHEN DATEPART(HOUR, Actual_Arrival_Time) < 12 THEN 'AM'
        ELSE 'PM'
    END AS period
FROM railway f
WHERE Actual_Arrival_Time IS NOT NULL
AND NOT EXISTS (
    SELECT 1 
    FROM time t 
    WHERE t.full_time = CAST(f.Actual_Arrival_Time AS TIME)
);

-- إضافة وقت الوصول إلى جدول time بدون تكرار
INSERT INTO time (full_time, hour, minute, period)
SELECT DISTINCT 
    CAST(Arrival_Time AS TIME) AS full_time,
    DATEPART(HOUR, Arrival_Time) AS hour,
    DATEPART(MINUTE, Arrival_Time) AS minute,
    CASE
        WHEN DATEPART(HOUR, Arrival_Time) < 12 THEN 'AM'
        ELSE 'PM'
    END AS period
FROM railway f
WHERE Arrival_Time IS NOT NULL
AND NOT EXISTS (
    SELECT 1 
    FROM time t 
    WHERE t.full_time = CAST(f.Arrival_Time AS TIME)
);

-- إضافة وقت المغادرة إلى جدول time بدون تكرار
INSERT INTO time (full_time, hour, minute, period)
SELECT DISTINCT 
    CAST(Departure_Time AS TIME) AS full_time,
    DATEPART(HOUR, Departure_Time) AS hour,
    DATEPART(MINUTE, Departure_Time) AS minute,
    CASE
        WHEN DATEPART(HOUR, Departure_Time) < 12 THEN 'AM'
        ELSE 'PM'
    END AS period
FROM railway f
WHERE Departure_Time IS NOT NULL
AND NOT EXISTS (
    SELECT 1 
    FROM time t 
    WHERE t.full_time = CAST(f.Departure_Time AS TIME)
);

-- إضافة وقت الشراء إلى جدول time بدون تكرار
INSERT INTO time (full_time, hour, minute, period)
SELECT DISTINCT 
    CAST(Time_of_Purchase AS TIME) AS full_time,
    DATEPART(HOUR, Time_of_Purchase) AS hour,
    DATEPART(MINUTE, Time_of_Purchase) AS minute,
    CASE
        WHEN DATEPART(HOUR, Time_of_Purchase) < 12 THEN 'AM'
        ELSE 'PM'
    END AS period
FROM railway f
WHERE Time_of_Purchase IS NOT NULL
AND NOT EXISTS (
    SELECT 1 
    FROM time t 
    WHERE t.full_time = CAST(f.Time_of_Purchase AS TIME)
);


UPDATE f
SET f.purchase_time_id = t.[Time_of_Purchase]
FROM fact_railway f
JOIN [dbo].[railway]t ON f.[Transaction_ID] = t.[Transaction_ID]
WHERE t.Time_of_Purchase IS NOT NULL;


UPDATE f
SET f.[departure_time_id] = t.[Departure_Time]
FROM fact_railway f
JOIN [dbo].[railway]t ON f.[Transaction_ID] = t.[Transaction_ID]
WHERE t.[Departure_Time] IS NOT NULL;

UPDATE f
SET f.[arrival_time_id] = t.[Arrival_Time]
FROM fact_railway f
JOIN [dbo].[railway]t ON f.[Transaction_ID] = t.[Transaction_ID]
WHERE t.[Arrival_Time] IS NOT NULL;


UPDATE f
SET f.[actual_arrival_time_id] = t.[Actual_Arrival_Time]
FROM fact_railway f
JOIN [dbo].[railway]t ON f.[Transaction_ID] = t.[Transaction_ID]
WHERE t.[Actual_Arrival_Time] IS NOT NULL;



select * from [dbo].[fact_railway]


UPDATE f
SET f.payment_id = t.payment_id
FROM fact_railway f
JOIN railway r ON f.transaction_id = r.transaction_id
JOIN [dbo].[payment] t ON r.payment_method = t.payment_method
                      AND r.purchase_type = t.purchase_type
WHERE t.payment_id IS NOT NULL;











