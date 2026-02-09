-- 1. The Classic Inner Join: List every product name (product_id) and its category, but only for products that actually have a category assigned
SELECT
	product_id,
	product_category_name
FROM
	olist_products_dataset
WHERE
	product_category_name IS NOT NULL;

-- 2. The Multiple Inner Join: Show the customer_city, the order_status, and the price for every item sold. (Standard "everything matches" query).
SELECT
	customers.customer_city,
	orders.order_status,
	items.price
FROM
	olist_customers_dataset AS customers
	JOIN olist_orders_dataset AS orders ON customers.customer_id = orders.customer_id
	JOIN olist_order_items_dataset AS items ON orders.order_id = items.order_id;

-- 3. The Left Join (The "Ghost" Products): Find all products in the products table that have never been sold.
SELECT
	products.product_id,
	products.product_category_name
FROM
	olist_products_dataset AS products
	LEFT JOIN olist_order_items_dataset AS items ON products.product_id = items.product_id
WHERE
	items.order_id IS NULL;

-- 4. The Right Join (Orphaned Translations): Use a RIGHT JOIN to find if there are any English category names in the translation table that don't actually exist in the products table.
SELECT
	products.product_category_name
FROM
	olist_products_dataset AS products
	RIGHT JOIN product_category_name_translation AS translation ON products.product_category_name = translation.product_category_name
WHERE
	products.product_category_name IS NULL;

-- 5. Double Left Join: List all customers, their orders, and their reviews. Ensure customers who haven't ordered anything andorders that haven't been reviewed are still included.
SELECT
	customers.customer_unique_id,
	orders.order_id,
	reviews.review_comment_message
FROM
	olist_customers_dataset AS customers
	LEFT JOIN olist_orders_dataset AS orders ON customers.customer_id = orders.customer_id
	LEFT JOIN olist_order_reviews_dataset AS reviews ON orders.order_id = reviews.order_id;

--  6. The Self Join (Shipping Twins): Find pairs of different sellers who are located in the exact same city. (Hint: Join sellers to itself on seller_city).
SELECT
	a.seller_id,
	b.seller_id
FROM
	olist_sellers_dataset AS a
	JOIN olist_sellers_dataset AS b ON a.seller_city = b.seller_city
WHERE
	a.seller_id < b.seller_id;

-- 7. The Cross Join (Market Potential): Create a list of every possible combination of customer_city and product_category. (This is used for "Market Basket" analysis to see where certain products aren'tbeing sold yet).
SELECT
	cities.customer_city,
	products.product_category_name
FROM
	(
		SELECT DISTINCT
			customer_city
		FROM
			olist_customers_dataset
	) AS cities
	CROSS JOIN (
		SELECT DISTINCT
			product_category_name
		FROM
			olist_products_dataset
	) AS products
ORDER BY
	cities.customer_city
LIMIT
	100; 
	
-- 8.  Anti-Join (The Security Audit): Find all order_ids in the orders table that do not have a corresponding entry in the payments table. (Useful for finding technical glitches where an order was created but no payment record exists). 
SELECT
	orders.order_id
FROM
	olist_orders_dataset AS orders
	LEFT JOIN olist_order_payments_dataset AS payments ON orders.order_id = payments.order_id
	WHERE payments.order_id IS NULL OR payments.order_id = '';
	
-- 9. The Exclusive Left Join: Identify customers who have placed orders, but only in cities where there are no registered sellers.
SELECT
	customers.customer_city, customers.customer_id
FROM
	olist_customers_dataset AS customers JOIN olist_orders_dataset AS orders ON customers.customer_id = orders.customer_id
	LEFT JOIN olist_sellers_dataset AS sellers ON customers.customer_city = sellers.seller_city
	WHERE sellers.seller_city IS NULL;

-- 10. Find orders where the payment_value is actually less than the price of the items.
SELECT 
    orders.order_id, 
    SUM(items.price + items.freight_value) AS total_order_cost, 
    SUM(payments.payment_value) AS total_paid
FROM olist_orders_dataset AS orders
JOIN olist_order_items_dataset AS items ON orders.order_id = items.order_id
JOIN olist_order_payments_dataset AS payments ON orders.order_id = payments.order_id
GROUP BY orders.order_id
HAVING total_paid < total_order_cost
LIMIT 10;	