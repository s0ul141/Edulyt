-- Test Query
SELECT * FROM credit_card_transaction.`credit card transactions - project - 2`;
/*
1. Write a query to print top 5 cities with highest spends and their percentage contribution of total credit
card spends.
*/
SELECT City, SUM(Amount) as TotalSpends,(SUM(Amount) / (SELECT SUM(Amount) 
FROM credit_card_transaction.`credit card transactions - project - 2`) * 100) 
as PercentageContribution
FROM credit_card_transaction.`credit card transactions - project - 2`
GROUP BY City
ORDER BY TotalSpends DESC
LIMIT 5;

/*
2. Write a query to print highest spend month and amount spent in that month for each card type.
*/
SELECT 
    Card_Type, 
    DATE_FORMAT(STR_TO_DATE(Date, '%d-%b-%y'), '%Y-%m') as Month, 
    SUM(Amount) as TotalSpends
FROM `credit_card_transaction`.`credit card transactions - project - 2`
GROUP BY Card_Type, Month
ORDER BY TotalSpends DESC;
/*
3. Write a query to print the transaction details (all columns from the table) for each card type when it
reaches a cumulative of 1000000 total spends (We should have 4 rows in the o/p one for each card type).
*/
SELECT Card_Type, SUM(Amount) as Total_Amount
FROM `credit_card_transaction`.`credit card transactions - project - 2`
GROUP BY Card_Type
HAVING Total_Amount > 1000000;

/*
4. Write a query to find city which had lowest percentage spend for gold card type.
*/
SELECT City, (SUM(Amount) / (SELECT SUM(Amount) 
FROM `credit_card_transaction`.`credit card transactions - project - 2` WHERE Card_Type = 'Gold') * 100) as PercentageSpend
FROM `credit_card_transaction`.`credit card transactions - project - 2`
WHERE Card_Type = 'Gold'
GROUP BY City
ORDER BY PercentageSpend ASC
LIMIT 1;

/*
5. Write a query to print 3 columns: city, highest_expense_type , lowest_expense_type (example format :
Delhi , bills, Fuel).
*/
SELECT 
    HighExp.City, 
    HighExp.Exp_Type as Highest_Expense_Type, 
    LowExp.Exp_Type as Lowest_Expense_Type
FROM (
    SELECT 
        City, 
        Exp_Type, 
        RANK() OVER (PARTITION BY City ORDER BY SUM(Amount) DESC) as 'Rank'
    FROM `credit_card_transaction`.`credit card transactions - project - 2`
    GROUP BY City, Exp_Type
) as HighExp
JOIN (
    SELECT 
        City, 
        Exp_Type, 
        RANK() OVER (PARTITION BY City ORDER BY SUM(Amount)) as 'Rank'
    FROM `credit_card_transaction`.`credit card transactions - project - 2`
    GROUP BY City, Exp_Type
) as LowExp ON HighExp.City = LowExp.City
WHERE HighExp.Rank = 1 AND LowExp.Rank = 1;

/*
6. Write a query to find percentage contribution of spends by females for each expense type.
*/
SELECT 
    Exp_Type, 
    SUM(Amount) as Female_Spend,
    (SUM(Amount) / (SELECT SUM(Amount) FROM `credit_card_transaction`.`credit card transactions - project - 2` WHERE Gender = 'Female')) * 100 as Percentage_Contribution
FROM 
    `credit_card_transaction`.`credit card transactions - project - 2`
WHERE 
    Gender = 'Female'
GROUP BY 
    Exp_Type;

/*
7. Which card and expense type combination saw highest month over month growth in Jan-2014.
*/
SELECT 
    Jan_2014.Card_Type, 
    Jan_2014.Exp_Type, 
    ((Jan_2014.Jan_Spend - IFNULL(Dec_2013.Dec_Spend, 0)) / IFNULL(Dec_2013.Dec_Spend, 0)) * 100 as Growth_Percentage
FROM 
(
    SELECT Card_Type, Exp_Type, SUM(Amount) as Dec_Spend
    FROM `credit_card_transaction`.`credit card transactions - project - 2`
    WHERE YEAR(Date) = 2013 AND MONTH(Date) = 12
    GROUP BY Card_Type, Exp_Type
) as Dec_2013
RIGHT JOIN 
(
    SELECT Card_Type, Exp_Type, SUM(Amount) as Jan_Spend
    FROM `credit_card_transaction`.`credit card transactions - project - 2`
    WHERE YEAR(Date) = 2014 AND MONTH(Date) = 1
    GROUP BY Card_Type, Exp_Type
) as Jan_2014 ON Dec_2013.Card_Type = Jan_2014.Card_Type AND Dec_2013.Exp_Type = Jan_2014.Exp_Type
ORDER BY 
    Growth_Percentage DESC
LIMIT 1;

/*
8. During weekends which city has highest total spend to total no of transaction’s ratio?
*/
SELECT 
    City, 
    SUM(Amount) / COUNT(*) as Spend_Transaction_Ratio
FROM 
    `credit_card_transaction`.`credit card transactions - project - 2`
WHERE 
    DAYOFWEEK(Date) IN (1, 7)
GROUP BY 
    City
ORDER BY 
    Spend_Transaction_Ratio DESC
LIMIT 1;

/*
9. Which city took least number of days to reach its 500th transaction after first transaction in that city?
*/
SELECT 
    City, 
    DATEDIFF(MAX(Date), MIN(Date)) as Days_to_500_Transactions
FROM 
(
    SELECT 
        City, 
        Date, 
        ROW_NUMBER() OVER (PARTITION BY City ORDER BY Date) as Transaction_Number
    FROM 
        `credit_card_transaction`.`credit card transactions - project - 2`
) as Transactions
WHERE 
    Transaction_Number = 500
GROUP BY 
    City
ORDER BY 
    Days_to_500_Transactions
LIMIT 1;
