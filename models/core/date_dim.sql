{{
    config(
        materialized = "table"
    )
}}


WITH Digits AS (
    SELECT 0 AS generated_number
    UNION ALL
    SELECT 1
),
Unioned AS (
    SELECT 
        p0.generated_number * POWER(2, 0)  + p1.generated_number * POWER(2, 1)  +
        p2.generated_number * POWER(2, 2)  + p3.generated_number * POWER(2, 3)  +
        p4.generated_number * POWER(2, 4)  + p5.generated_number * POWER(2, 5)  +
        p6.generated_number * POWER(2, 6)  + p7.generated_number * POWER(2, 7)  +
        p8.generated_number * POWER(2, 8)  + p9.generated_number * POWER(2, 9)  +
        p10.generated_number * POWER(2, 10) + p11.generated_number * POWER(2, 11) +
        p12.generated_number * POWER(2, 12) + p13.generated_number * POWER(2, 13) +
        p14.generated_number * POWER(2, 14) + 1 AS generated_number
    FROM Digits p0
    CROSS JOIN Digits p1
    CROSS JOIN Digits p2
    CROSS JOIN Digits p3
    CROSS JOIN Digits p4
    CROSS JOIN Digits p5
    CROSS JOIN Digits p6
    CROSS JOIN Digits p7
    CROSS JOIN Digits p8
    CROSS JOIN Digits p9
    CROSS JOIN Digits p10
    CROSS JOIN Digits p11
    CROSS JOIN Digits p12
    CROSS JOIN Digits p13
    CROSS JOIN Digits p14
),
Unioned_filtered as (
SELECT *
FROM Unioned
WHERE generated_number <= 18597
),

DateSeries AS (
    SELECT 
        DATEADD(DAY, ROW_NUMBER() OVER (ORDER BY generated_number) - 1, CAST(CONVERT(DATE, '01/01/2000', 101) AS DATETIME2(6))) AS date_day
    FROM Unioned_filtered
),

FilteredDates AS (
    SELECT *
    FROM DateSeries
    WHERE date_day <= CONVERT(DATE, '12/01/2050', 101)
)
,
final_date as (
    SELECT
        FORMAT(CAST(date_day AS DATETIME2), 'MM/dd/yyyy') as date_day
    FROM FilteredDates
)
SELECT
    {{ dbt_utils.generate_surrogate_key(['date_day']) }} as Date_SK
    ,date_day as date_day
    ,YEAR(date_day) as Year
    ,MONTH(date_day) as Month
    ,DAY(date_day) as DayOfMonth
    ,DATENAME(month, date_day) AS MonthName
    ,DATENAME(dw, date_day) as DayOfWeek
FROM final_date

