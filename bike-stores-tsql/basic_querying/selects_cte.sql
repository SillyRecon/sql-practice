/**
Common Table Expressions
**/
/**
Using a CTE to create a temporary result set that contains the sales amounts by sales staff in 2018
**/
WITH [Sales Amounts] ([Staff], [Sales], [Year]) AS (
	SELECT s.first_name + ' ' + s.last_name, SUM(i.quantity * i.list_price * (1 - i.discount)), YEAR(o.order_date)
	FROM sales.orders o 
	INNER JOIN sales.order_items i ON i.order_id = o.order_id
	INNER JOIN sales.staffs s ON s.staff_id = o.staff_id
	GROUP BY first_name + ' ' + last_name, YEAR(order_date)
)
SELECT [Staff], [Sales]
FROM [Sales Amounts]
WHERE [Year] = 2018;
/**
Using a CTE to create a temporary result set that contains the average sales of the staff in 2018.
**/
WITH [Sales] AS (
	SELECT staff_id, COUNT(*) AS [Order Count]
	FROM sales.orders
	WHERE YEAR(order_date) = 2018
	GROUP BY staff_id
)
SELECT AVG([Order Count]) AS [Average Orders By Staff]
FROM [Sales];
/**
Using two CTEs to get the number of products and the sales for each product category.
**/
WITH [Category Counts] (category_id, category_name, product_count) AS
(
	SELECT c.category_id, c.category_name, COUNT(p.product_id)
	FROM production.products p
	INNER JOIN production.categories c ON c.category_id = p.category_id
	GROUP BY c.category_id, c.category_name
),
[Category Sales] (category_id, sales) AS
(
	SELECT p.category_id, SUM(i.quantity * i.list_price * (1 - i.discount))
	FROM sales.order_items i
	INNER JOIN production.products p ON p.product_id = i.product_id
	INNER JOIN sales.orders o ON o.order_id = i.order_id
	WHERE order_status = 4
	GROUP BY p.category_id
)
SELECT c.category_id, c.category_name, c.product_count, s.sales
FROM [Category Counts] c
INNER JOIN [Category Sales] s ON s.category_id = c.category_id
ORDER BY c.category_name;