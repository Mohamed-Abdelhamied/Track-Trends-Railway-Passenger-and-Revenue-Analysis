


SELECT COLUMN_NAME  
FROM INFORMATION_SCHEMA.COLUMNS  
WHERE TABLE_NAME = 'railway'; 


-- Update empty values in "Reason for Delay" column to 'On Time'  
UPDATE railway  
SET Reason_for_Delay = 'On Time'  
WHERE TRIM(Reason_for_Delay) = '';  

-- Update values in [Refund Request] column to 'not-refunded' if they are 'no'  
UPDATE railway  
SET Refund_Request = 'not-refunded'  
WHERE TRIM(Refund_Request) = 'no';  

-- Update values in [Refund Request] column to 'refunded' if they are 'yes'  
UPDATE railway  
SET Refund_Request = 'refunded'  
WHERE TRIM(Refund_Request) = 'yes';  

-- Standardize values in the [Reason for Delay] column for similar categories  
UPDATE railway  
SET Reason_for_Delay =  
 CASE  
 WHEN Reason_for_Delay IN ('Weather', 'Weather Conditions') THEN 'Weather'  
 WHEN Reason_for_Delay IN ('Staffing', 'Staff Shortage') THEN 'Staffing'  
 ELSE Reason_for_Delay 
  END;  

-- Calculate the average price for each combination of [Railcard], [Ticket_Type], and [Ticket_Class], sorted by price  
SELECT Railcard, Ticket_Type, Ticket_Class, Departure_Station, Arrival_Destination, 
       AVG(Price) AS Avg_Price
FROM railway
GROUP BY Railcard, Ticket_Type, Ticket_Class, Departure_Station, Arrival_Destination
ORDER BY Railcard, Ticket_Type, Ticket_Class, Avg_Price DESC;

--is query categorizes the Railcard column by replacing 'None' with 'No Discount'.
UPDATE [dbo].[railway]
SET Railcard = 
    CASE 
        WHEN Railcard = 'None' THEN 'No Discount'
        ELSE Railcard
    END;

-- 6. عرض الرحلات غير الملغاة التي بها حالة غير متطابقة بين الوقت المتوقع والفعلي
SELECT 
    [Transaction_ID],  
    [Arrival_Time],  
    [Actual_Arrival_Time],  
    journey_status,  
    CASE 
        WHEN actual_arrival_time > [Arrival_Time] THEN 'Delayed'
        ELSE 'On Time'
    END AS calculated_status,  
    CASE 
        WHEN journey_status = 
            CASE 
                WHEN actual_arrival_time > [Arrival_Time] THEN 'Delayed'
                ELSE 'On Time'
            END 
        THEN 'Status Matches'
        ELSE 'Status Mismatch'
    END AS status_check  
FROM 
    [dbo].[railway]
WHERE 
    journey_status <> 'Cancelled'  
    AND journey_status <> 
        CASE 
            WHEN actual_arrival_time > [Arrival_Time] THEN 'Delayed'
            ELSE 'On Time'
        END;

		-- 9. عرض الرحلات التي حالتها 'Delayed' ولكن وقت الوصول الفعلي يساوي المجدول
SELECT 
    J.[journey_status], 
    F.[arrival_time_id], 
    F.[actual_arrival_time_id]
FROM 
    [dbo].[fact_railway] F
JOIN 
    [dbo].[journey] J ON F.journey_id = J.journey_id
WHERE 
    F.[actual_arrival_time_id] = F.[arrival_time_id]
    AND J.[journey_status] = 'Delayed';

	-- 10. تحديث حالة الرحلات من 'Delayed' إلى 'On Time' في حالة عدم وجود تأخير فعلي
UPDATE J
SET J.journey_status = 'On Time'
FROM [dbo].[fact_railway] F
JOIN [dbo].[journey] J ON F.journey_id = J.journey_id
WHERE 
    F.actual_arrival_time_id = F.arrival_time_id
    AND J.journey_status = 'Delayed';
