--Monthly KPI Dashboard: Total Revenue, Order Count, AOV(Average Order Value)
WITH order_detail AS (
  SELECT
    a.order_id,
    b.order_date,
    DATE_TRUNC(b.order_date, MONTH) AS order_month,
    a.quantity,
    a.unit_price,
    a.quantity * a.unit_price AS unit_total,
  FROM `dataset.order_items` a
  LEFT JOIN `dataset.oders`b
  ON a.order_id = b.order_id
  WHERE b.status IN ('Completed', 'Shipped') --This will exclude any cancelled orders
),

monthly_kpi AS (
  SELECT
    order_month,
    COUNT(DISTINCT order_id) AS total_order_count,
    ROUND(SUM(unit_total),2) AS total_revenue,
    ROUND(SUM(unit_total)/ COUNT(DISTINCT order_id),2) AS avg_order_value
  FROM order_detail
  GROUP BY order_month)

SELECT
  order_month,
  total_order_count,
  total_revenue,
  avg_order_value
FROM monthly_kpi
ORDER BY order_month;
