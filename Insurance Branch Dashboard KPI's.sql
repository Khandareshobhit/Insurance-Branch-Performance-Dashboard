USE insurance_db;

##### KPI'S FOR BRANCH PERFORMANCE DASHBOARD

-- 1) No of Invoice by Account Executive

SELECT `Account Executive`, 
		COUNT(invoice_number) AS "Count_of_Invoice"
FROM Invoice
GROUP BY `Account Executive`
ORDER BY Count_of_Invoice DESC ;

-- 2) Yearly Meeting Count

SELECT  
		YEAR(meeting_date) AS Meeting_year, 
		COUNT(global_attendees) As Meeting_Count
FROM meeting
GROUP BY Meeting_year;

-- 3) Cross Sell, renewal & New --Target, Achieve, New Target

SELECT
	(SELECT SUM(`Cross sell bugdet`) FROM individual_budget) AS Target,
    
	(   ROUND(
		(SELECT SUM(Amount) FROM brokerage WHERE income_class = "Cross Sell") 
        + 
        (SELECT SUM(Amount) FROM fees WHERE income_class = "Cross Sell"),0)
	) AS Achieved,
    
    GREATEST(
		(SELECT SUM(`Cross sell bugdet`) FROM individual_budget)
		 -
		 (   ROUND(
			(SELECT SUM(Amount) FROM brokerage WHERE income_class = "Cross Sell") 
			+ 
			(SELECT SUM(Amount) FROM fees WHERE income_class = "Cross Sell"),0)
		 ),0
	) AS New

UNION ALL

SELECT
	(SELECT SUM(`New Budget`) FROM individual_budget) AS Target,
    
	(   ROUND(
		(SELECT SUM(Amount) FROM brokerage WHERE income_class = "New") 
        + 
        (SELECT SUM(Amount) FROM fees WHERE income_class = "New"),0)
	) AS Achieved,
    
    GREATEST(
		(SELECT SUM(`New Budget`) FROM individual_budget)
		 -
		 (   ROUND(
			(SELECT SUM(Amount) FROM brokerage WHERE income_class = "New") 
			+ 
			(SELECT SUM(Amount) FROM fees WHERE income_class = "New"),0)
		 ),0
	) AS New
    
UNION ALL

SELECT
	(SELECT SUM(`Renewal Budget`) FROM individual_budget) AS Target,
    
	(   ROUND(
		(SELECT SUM(Amount) FROM brokerage WHERE income_class = "Renewal") 
        + 
        (SELECT SUM(Amount) FROM fees WHERE income_class = "Renewal"),0)
	) AS Achieved,
    
    ( GREATEST(
					(SELECT SUM(`Renewal Budget`) FROM individual_budget)
					 -
					 (   ROUND(
						(SELECT SUM(Amount) FROM brokerage WHERE income_class = "Renewal") 
						+ 
						(SELECT SUM(Amount) FROM fees WHERE income_class = "Renewal"),0)
					 ),0
			  )
	) AS New;
    
-- 4) Stage Funnel by Revenue

SELECT stage, SUM(revenue_amount) AS revenue_amount
FROM opportunity
GROUP BY stage ;

-- 5) No of meetings By Account Exe

SELECT `Account Executive`, COUNT(global_attendees) AS Count_Meetings
FROM meeting
GROUP BY `Account Executive`;

-- 6) Open Opportunity Top-5 by Revenue

SELECT 
	opportunity_name, 
    stage, 
    revenue_amount 
FROM opportunity
WHERE stage IN ("Qualify Opportunity" ,"Propose Solution")
ORDER BY revenue_amount DESC
LIMIT 5;

-- 7) Open Opportunities

SELECT COUNT(stage) AS Open_Opportunities
FROM opportunity
WHERE stage IN ("Qualify Opportunity" ,"Propose Solution");

-- 8) Closed Opportunities

SELECT COUNT(stage) AS Closed_Opportunities
FROM opportunity
WHERE stage NOT IN ("Qualify Opportunity" ,"Propose Solution");

-- 9) Total Opportunities

SELECT COUNT(stage) AS Total_Opportunities
FROM opportunity;

-- 10) Conversion ratio

SELECT
		CONCAT(
				ROUND(
						((SELECT COUNT(stage)
						FROM opportunity
						WHERE stage NOT IN ("Qualify Opportunity" ,"Propose Solution"))
						/
						(SELECT COUNT(stage) FROM opportunity)) *100
					,2 )
			   ,"%")
 AS Conversion_Ratio;

-- 11) Total Target

SELECT
	(SELECT SUM(`New Budget`) FROM individual_budget)
	+ 
    (SELECT SUM(`Cross sell bugdet`) FROM individual_budget) 
	+ 
    (SELECT SUM(`Renewal Budget`) FROM individual_budget) AS TOTAL_TARGET;

-- 12) Total Revenue (Brokerage + Fees)	

SELECT
	(SELECT SUM(AMOUNT) FROM BROKERAGE)
	+
	(SELECT SUM(AMOUNT) FROM FEES) AS Total_Revenue;
    
-- 13) Invoice sales

SELECT SUM(amount) AS Invoice_sales
FROM Invoice ;

-- 14) Percentage of Achievement

SELECT
CONCAT(
	ROUND(
		 (SELECT
			(SELECT SUM(AMOUNT) FROM BROKERAGE)
			+
			(SELECT SUM(AMOUNT) FROM FEES)
            +
            (SELECT SUM(AMOUNT) FROM INVOICE)
		)    
		/
		(SELECT
			(SELECT SUM(`New Budget`) FROM individual_budget)
			+ 
			(SELECT SUM(`Cross sell bugdet`) FROM individual_budget) 
			+ 
			(SELECT SUM(`Renewal Budget`) FROM individual_budget)
		) * 100
		,2)
   ,"%") AS Percentage_of_Achievement;



