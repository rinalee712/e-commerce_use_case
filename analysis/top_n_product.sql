-- Top N products by revenue within each category
WITH product_sales AS (
  SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(a.quantity * a.unit_price) AS total_revenue,
  FROM `dataset.products` p
  LEFT JOIN `dataset.order_items` a
  ON p.product_id = a.product_id
  GROUP BY
  p.product_id,
  p.product_name,
  p.category
  ),

top_n AS (
  SELECT *,
  RANK() OVER (PARTITION BY category ORDER BY total_revenue DESC) AS top_n_prod
  FROM product_sales)

SELECT
  product_id,
  product_name,
  category,
  total_revenue,
  top_n_prod
FROM top_n
-- WHERE top_n_prod <=5 you can use this WHERE clause to filter TOP N items
ORDER BY category, top_n_prod;
