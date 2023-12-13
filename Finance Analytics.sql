-- Finance Analytics
#Gross Sales Report: Monthly Product Transactions

	SELECT 
    	    s.date, 
            s.product_code, 
            p.product, 
            p.variant, 
            s.sold_quantity, 
            g.gross_price,
            ROUND(s.sold_quantity*g.gross_price,2) as gross_price_total
	FROM fact_sales_monthly s
	JOIN dim_product p
            ON s.product_code=p.product_code
	JOIN fact_gross_price g
            ON g.fiscal_year=get_fy(s.date)
    	AND g.product_code=s.product_code
	WHERE 
    	    customer_code=90002002 AND 
            get_fy(s.date)=2021     
	LIMIT 1000000;
# Gross Sales Report: Total Sales Amount

-- Generate monthly gross sales report for Croma India for all the years
	SELECT 
            s.date, 
    	    SUM(ROUND(s.sold_quantity*g.gross_price,2)) as monthly_sales
	FROM fact_sales_monthly s
	JOIN fact_gross_price g
        ON g.fiscal_year=get_fy(s.date) AND g.product_code=s.product_code
	WHERE 
             customer_code=90002002
	GROUP BY date;

# Stored Procedures: Monthly Gross Sales Report

-- Generate monthly gross sales report for any customer using stored procedure
	
DELIMITER $
CREATE PROCEDURE `get_monthly_gross_sales_for_customer`(
    in_customer_codes TEXT
)
BEGIN
    SELECT 
        s.date, 
        SUM(ROUND(s.sold_quantity * g.gross_price, 2)) AS monthly_sales
    FROM fact_sales_monthly s
    JOIN fact_gross_price g
        ON g.fiscal_year = get_fy(s.date)
        AND g.product_code = s.product_code
    WHERE FIND_IN_SET(s.customer_code, in_customer_codes) > 0
    GROUP BY s.date
    ORDER BY s.date DESC;
END$
DELIMITER ;
CALL `get_monthly_gross_sales_for_customer`("90002002");



#Stored Procedure: Market Badge

--  Write a stored proc that can retrieve market badge. i.e. if total sold quantity > 5 million that market is considered "Gold" else "Silver"
	DELIMITER $
    CREATE PROCEDURE `get_market_badge`(
        	IN in_market VARCHAR(45),
        	IN in_fiscal_year YEAR,
        	OUT out_level VARCHAR(45)
	)
	BEGIN
             DECLARE qty INT DEFAULT 0;
    	     # Default market is India
    	     IF in_market = "" THEN
                  SET in_market="India";
             END IF;
    	     # Retrieve total sold quantity for a given market in a given year
             SELECT 
                  SUM(s.sold_quantity) INTO qty
             FROM fact_sales_monthly s
             JOIN dim_customer c
             ON s.customer_code=c.customer_code
             WHERE 
                  get_fiscal_year(s.date)=in_fiscal_year AND
                  c.market=in_market;
             # Determine Gold vs Silver status
             IF qty > 5000000 THEN
                  SET out_level = 'Gold';
             ELSE
                  SET out_level = 'Silver';
             END IF;
	END$
	DELIMITER ;
    SET @out_badge = '0';
	CALL gdb0041.get_market_badge('India', 2021, @out_badge);
	SELECT @out_badge;














































