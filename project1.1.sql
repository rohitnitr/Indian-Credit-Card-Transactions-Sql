
SELECT City, SUM(Amount) AS TotalSpends, (SUM(Amount) * 100.0 / (SELECT SUM(Amount) FROM creditbanking.customer)) AS PercentageContribution
FROM creditbanking.customer
GROUP BY City
ORDER BY TotalSpends DESC
LIMIT 5;



UPDATE creditbanking.customer
SET Date = DATE_FORMAT(STR_TO_DATE(Date, '%d-%b-%y'), '%Y-%m-%d');


select * from creditbanking.customer;

SELECT `Card Type`, 
       CASE `Month`
           WHEN 1 THEN 'Jan'
           WHEN 2 THEN 'Feb'
           WHEN 3 THEN 'Mar'
           WHEN 4 THEN 'Apr'
           WHEN 5 THEN 'May'
           WHEN 6 THEN 'Jun'
           WHEN 7 THEN 'Jul'
           WHEN 8 THEN 'Aug'
           WHEN 9 THEN 'Sep'
           WHEN 10 THEN 'Oct'
           WHEN 11 THEN 'Nov'
           WHEN 12 THEN 'Dec'
       END AS `Month`,
       `TotalSpent`
FROM (
  SELECT `Card Type`, 
         MONTH(`Date`) AS `Month`, 
         SUM(`Amount`) AS `TotalSpent`
  FROM `creditbanking`.`customer`
  GROUP BY `Card Type`, `Month`
) AS subquery
WHERE (`Card Type`, `TotalSpent`) IN (
  SELECT `Card Type`, MAX(`TotalSpent`)
  FROM (
    SELECT `Card Type`, 
           MONTH(`Date`) AS `Month`, 
           SUM(`Amount`) AS `TotalSpent`
    FROM `creditbanking`.`customer`
    GROUP BY `Card Type`, `Month`
  ) AS max_subquery
  GROUP BY `Card Type`
)
ORDER BY FIELD(`Card Type`, 'Signature', 'Silver', 'Platinum', 'Gold');




SELECT City, (SUM(CASE WHEN `Card Type` = 'Gold' THEN Amount ELSE 0 END) / SUM(Amount)) * 100 AS percentage_spend
FROM creditbanking.customer
GROUP BY City
HAVING percentage_spend > 0
ORDER BY percentage_spend ASC
LIMIT 1;


SELECT
  City,
  MAX(`Exp Type`) AS highest_expense_type,
  MIN(`Exp Type`) AS lowest_expense_type
FROM creditbanking.customer
GROUP BY City;



SELECT
  `Exp Type`,
  CONCAT(ROUND((SUM(CASE WHEN Gender = 'F' THEN Amount ELSE 0 END) / SUM(Amount)) * 100, 2), '%') AS female_percentage
FROM creditbanking.customer
GROUP BY `Exp Type`;





SELECT
  `Card Type`,
  `Exp Type`,
  (SUM(Amount) - LAG(SUM(Amount)) OVER (PARTITION BY `Card Type`, `Exp Type` ORDER BY `Date`)) AS growth
FROM creditbanking.customer
WHERE DATE_FORMAT(Date, '%b-%Y') = 'Jan-2014'
GROUP BY `Card Type`, `Exp Type`, `Date`
ORDER BY growth DESC
LIMIT 1;




SELECT
  City,
  SUM(Amount) / COUNT(*) AS spend_transaction_ratio
FROM
  creditbanking.customer
WHERE
  DAYOFWEEK(Date) IN (1, 7) -- Filter for weekends (Sunday = 1, Saturday = 7)
GROUP BY
  City
ORDER BY
  spend_transaction_ratio DESC
LIMIT 1;






SELECT
  City,
  DATEDIFF(MIN(Date), MIN(first_transaction_date)) AS days_to_500th_transaction
FROM (
  SELECT
    City,
    Date,
    MIN(Date) OVER (PARTITION BY City) AS first_transaction_date,
    ROW_NUMBER() OVER (PARTITION BY City ORDER BY Date) AS transaction_count
  FROM
    creditbanking.customer
) AS subquery
WHERE
  transaction_count = 500
GROUP BY
  City
ORDER BY
  days_to_500th_transaction ASC
LIMIT 1;

