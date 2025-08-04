--This shows monthly new vs existing customers and what they purchased.
WITH customer_first_purchase AS (
  SELECT
    customer_id,
    MIN(order_date) AS first_order_date
  FROM `dataset.sales_data`
  GROUP BY customer_id
  ),

orders_new_existing AS (
  SELECT
    s.order_id,
    s.customer_id,
    s.order_date
    DATE_TRUNC(s.order_date, MONTH) AS order_month,
    s.total_amount,
    CASE
      WHEN s.order_date = a.first_order_date THEN 'new'
      ELSE 'existing'
      END AS customer_type
  FROM `dataset.sales_data`s
  LEFT JOIN customer_first_purchase a
  ON s.customer_id = a.customer_id
  ),

products_new AS (
   SELECT
    p.product_id,
    p.product_name,
    p.category,
    a.order_id,
    SUM(a.quantity * a.unit_price) AS total_revenue,
  FROM `dataset.products` p
  LEFT JOIN `dataset.order_items` a
  ON p.product_id = a.product_id
  GROUP BY
  p.product_id,
  p.product_name,
  p.category,
  a.order_id
  ),
  
joined_w_products AS (
  SELECT
  o.order_month,
  o.customer_id,
  o.customer_type,
  oi.product_id,
  p.product_name,
  p.category,
  oi.quantity,
  oi.unit_price,
  oi.quantity * oi.unit_price) AS unit_total_price
FROM orders_new_existing o
LEFT JOIN `dataset.order_items` oi
ON o.order_id = oi.order_id
LEFT JOIN products_new p
ON o.order_id = p.order_id
)

SELECT
  order_month,
  customer_id,
  customer_type,
  product_id,
  product_name,
  category,
  COUNT(DISTINCT customer_id) AS customer_count,
  SUM(quantity) AS total_quantity,
  ROUND(SUM(unit_total_price),2) AS total_revenue,
FROM joint_w_products
GROUP BY
  order_month,
  customer_id,
  customer_type,
  product_id,
  product_name,
  category
ORDER BY
  order_month,
  customer_type,
  total_revenue DESC;
