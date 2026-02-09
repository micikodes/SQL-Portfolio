-- 1. Customer Location: List all order_ids along with the customer_city where the order was placed. (Join ordersand customers)
SELECT
order_id,
customer_city
FROM
olist_orders_dataset
JOIN olist_customers_dataset ON olist_orders_dataset.customer_id = olist_customers_dataset.customer_id;


-- 2. Product Descriptions: Show the order_id and the English product_category_name for every item sold. (Join order_items and product_category_name_translation)
SELECT
	orders.order_id, 
	products.product_category_name
FROM
	olist_orders_dataset AS orders
	JOIN olist_order_items_dataset AS items ON orders.order_id = items.order_id
	JOIN olist_products_dataset AS products ON items.product_id = products.product_id;


-- 3.  Display the seller_id and the seller_city for every item in the order_items table. (Join order_items and sellers)
SELECT
	items.seller_id,
	sellers.seller_city
FROM
	olist_order_items_dataset AS items
	JOIN olist_sellers_dataset AS sellers ON items.seller_id = sellers.seller_id;



-- 4. Revenue by City: Calculate the total price of all items sold, grouped by customer_city.
SELECT
	SUM(payments.payment_value),
	customer_city
FROM
	olist_order_payments_dataset AS payments
	JOIN olist_orders_dataset AS orders ON payments.order_id = orders.order_id
	JOIN olist_customers_dataset AS customers ON orders.customer_id = customers.customer_id
GROUP BY
	customer_city;


-- 5. Popular Categories: Find the top 5 product categories that have the highest number of items sold.
SELECT
	translation.product_category_name_english,
	COUNT(orders.order_id)
FROM
	olist_products_dataset AS products
	JOIN olist_order_items_dataset AS items ON products.product_id = items.product_id
	JOIN olist_orders_dataset AS orders ON orders.order_id = items.order_id
	JOIN product_category_name_translation AS translation ON products.product_category_name = translation.product_category_name
GROUP BY
	translation.product_category_name_english
ORDER BY
	COUNT(orders.order_id)
LIMIT
	5;

-- 6. Payment Diversity: List all orders that used more than one type of payment (e.g., Credit Card and Voucher). (Join orders and order_payments, then use HAVING)
SELECT COUNT(payment_type), order_id FROM olist_order_payments_dataset
GROUP BY order_id
HAVING COUNT(payment_type) > 1;

-- 7. Unfinished Business (Left Join): List all customers who have never placed an order. (Hint: Use a LEFT JOIN from customers to orders and look for NULL order IDs)
SELECT
	customers.customer_unique_id
FROM
	olist_customers_dataset AS customers
	LEFT JOIN olist_orders_dataset AS orders ON customers.customer_id = orders.customer_id
	WHERE order_id IS NULL;


-- 8. The "Triple Threat" Join: Find the total amount spent by each customer, showing their customer_unique_id and the sum of payment_value. (Requires joining customers → orders → order_payments)
SELECT
	customers.customer_unique_id,
	SUM(payments.payment_value)
FROM
	olist_customers_dataset AS customers
	JOIN olist_orders_dataset AS orders ON customers.customer_id = orders.customer_id
	JOIN olist_order_payments_dataset AS payments ON orders.order_id = payments.order_id
GROUP BY
	customers.customer_unique_id;


-- 9. Delivery Performance: Calculate the average delivery time (difference between order_purchase_timestamp and order_delivered_customer_date) for each product category.
SELECT
	translation.product_category_name_english,
	ROUND(AVG(DATEDIFF(orders.order_delivered_customer_date, orders.order_purchase_timestamp))) AS average_delivery_time_days
FROM
	olist_products_dataset AS products
	JOIN olist_order_items_dataset AS items ON products.product_id = items.product_id
	JOIN olist_orders_dataset AS orders ON items.order_id = orders.order_id
	JOIN product_category_name_translation AS translation ON products.product_category_name = translation.product_category_name
GROUP BY
	translation.product_category_name_english;


-- 10. The VIP List: Identify the top 3 sellers who have generated the most revenue in the "Electronics" category. (Requires joining sellers → order_items → products)
SELECT
	sellers.seller_id,
	sellers.seller_city,
	SUM(payments.payment_value)
FROM
	olist_sellers_dataset AS sellers
	JOIN olist_order_items_dataset AS items ON sellers.seller_id = items.seller_id
	JOIN olist_products_dataset AS products ON items.product_id = products.product_id
	JOIN olist_order_payments_dataset AS payments ON items.order_id = payments.order_id
	JOIN product_category_name_translation AS translation ON products.product_category_name = translation.product_category_name
WHERE
	translation.product_category_name_english = 'electronics'
GROUP BY
	sellers.seller_id,
	sellers.seller_city
ORDER BY
	SUM(payments.payment_value) DESC
LIMIT
	3;
