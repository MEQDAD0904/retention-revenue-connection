SQL Analysis Framework — Customer Retention & Revenue Growth Project
Overview :
This document contains the SQL queries used throughout the project analysis.
The analysis focuses on:
* Revenue Growth
* Customer Retention
* Cohort Analysis
* Product Revenue Concentration
* Reviews & Customer Satisfaction
* Operational Metrics
_________________________________________________________________________
  
Dataset:
Olist Brazilian E-commerce Dataset
Database:
PostgreSQL
__________________________________________________________________________
1. Revenue Analysis
1.1 Revenue, Orders, and AOV Trend
Purpose:
* Understand overall revenue growth
* Compare revenue behavior against order volume and AOV
* Identify the main driver behind revenue growth

#sql query
SELECT

    DATE_TRUNC(
        'month',
        o.order_purchase_timestamp
    )::date AS month,

    COUNT(DISTINCT o.order_id) AS orders,

    ROUND(
        SUM(p.payment_value)::numeric,
        2
    ) AS revenue,

    ROUND(
        (
            SUM(p.payment_value)
            /
            COUNT(DISTINCT o.order_id)
        )::numeric,
        2
    ) AS aov

FROM orders o

JOIN payments p
    ON o.order_id = p.order_id

WHERE o.order_status = 'delivered'

GROUP BY 1
ORDER BY 1;

_______________________________________________________________

2. Customer Retention Analysis
2.1 Customer Lifetime Table
Purpose:
Classify customers into:
* One-time customers
* Repeat customers
* Calculate customer revenue
* Use as the base table for retention analysis

#sql query
WITH customer_lifetime AS (

    SELECT

        c.customer_unique_id,

        COUNT(DISTINCT o.order_id) AS total_orders,

        SUM(p.payment_value) AS revenue,

        MIN(
            DATE_TRUNC(
                'month',
                o.order_purchase_timestamp
            )
        )::date AS first_month

    FROM orders o

    JOIN customers c
        ON o.customer_id = c.customer_id

    JOIN payments p
        ON o.order_id = p.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY 1
)

SELECT

    first_month AS month,

    customer_unique_id,

    total_orders,

    CASE
        WHEN total_orders = 1 THEN 'One-time'
        ELSE 'Repeat'
    END AS customer_type,

    ROUND(revenue::numeric,2) AS revenue

FROM customer_lifetime;

______________________________________________________________

2.2 Repeat Rate
Purpose:
* Measure customer retention behavior
* Identify the percentage of customers who made more than one purchase

#sql query
WITH customer_orders AS (

    SELECT

        c.customer_unique_id,

        COUNT(DISTINCT o.order_id) AS total_orders

    FROM orders o

    JOIN customers c
        ON o.customer_id = c.customer_id

    WHERE o.order_status = 'delivered'

    GROUP BY 1
)

SELECT

    COUNT(
        CASE
            WHEN total_orders > 1
            THEN 1
        END
    ) AS repeat_customers,

    COUNT(*) AS total_customers,

    ROUND(
        (
            COUNT(
                CASE
                    WHEN total_orders > 1
                    THEN 1
                END
            )::numeric
            /
            COUNT(*)
        ) * 100,
        2
    ) AS repeat_rate_percentage

FROM customer_orders;

______________________________________________________________________________

2.3 Cohort Analysis
Purpose:
* Track customer retention across months
* Analyze how customer activity declines over time

#sql query
WITH cohort AS (

    SELECT

        c.customer_unique_id,

        MIN(
            DATE_TRUNC(
                'month',
                o.order_purchase_timestamp
            )
        )::date AS cohort_month

    FROM orders o

    JOIN customers c
        ON o.customer_id = c.customer_id

    WHERE o.order_status = 'delivered'

    GROUP BY 1
),

customer_orders AS (

    SELECT

        c.customer_unique_id,

        DATE_TRUNC(
            'month',
            o.order_purchase_timestamp
        )::date AS order_month

    FROM orders o

    JOIN customers c
        ON o.customer_id = c.customer_id

    WHERE o.order_status = 'delivered'
),

cohort_data AS (

    SELECT

        co.cohort_month,

        cu.order_month,

        (
            EXTRACT(YEAR FROM age(cu.order_month, co.cohort_month)) * 12
            +
            EXTRACT(MONTH FROM age(cu.order_month, co.cohort_month))
        ) AS month_index,

        cu.customer_unique_id

    FROM customer_orders cu

    JOIN cohort co
        ON cu.customer_unique_id = co.customer_unique_id
)

SELECT

    cohort_month,

    COUNT(
        DISTINCT CASE WHEN month_index = 0 THEN customer_unique_id END
    ) AS month_0,

    COUNT(
        DISTINCT CASE WHEN month_index = 1 THEN customer_unique_id END
    ) AS month_1,

    COUNT(
        DISTINCT CASE WHEN month_index = 2 THEN customer_unique_id END
    ) AS month_2,

    COUNT(
        DISTINCT CASE WHEN month_index = 3 THEN customer_unique_id END
    ) AS month_3,

    COUNT(
        DISTINCT CASE WHEN month_index = 4 THEN customer_unique_id END
    ) AS month_4

FROM cohort_data

GROUP BY 1
ORDER BY 1;

________________________________________________________________________________

2.4 Average Revenue Per Customer Type
Purpose:
Compare customer value between:
* One-time customers
* Repeat customers

#sql query
WITH customer_lifetime AS (

    SELECT

        c.customer_unique_id,

        COUNT(DISTINCT o.order_id) AS total_orders,

        SUM(p.payment_value) AS revenue

    FROM orders o

    JOIN customers c
        ON o.customer_id = c.customer_id

    JOIN payments p
        ON o.order_id = p.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY 1
)

SELECT

    CASE
        WHEN total_orders = 1 THEN 'One-time'
        ELSE 'Repeat'
    END AS customer_type,

    COUNT(*) AS customers,

    ROUND(
        AVG(revenue)::numeric,
        2
    ) AS avg_customer_revenue

FROM customer_lifetime

GROUP BY 1;

_________________________________________________________________________________

3. Product Analysis
3.1 Revenue Contribution by Product Category
Purpose:
* Identify the categories generating the most revenue
* Detect revenue concentration

#sql query
SELECT

    p.product_category_name,

    ROUND(
        SUM(pay.payment_value)::numeric,
        2
    ) AS revenue,

    COUNT(DISTINCT o.order_id) AS orders

FROM orders o

JOIN order_items oi
    ON o.order_id = oi.order_id

JOIN products p
    ON oi.product_id = p.product_id

JOIN payments pay
    ON o.order_id = pay.order_id

WHERE o.order_status = 'delivered'

GROUP BY 1
ORDER BY revenue DESC;

______________________________________________________________________

3.2 Top 5 Categories Contribution
Purpose:
* Measure how much revenue is generated by the top categories

#sql query
WITH category_revenue AS (

    SELECT

        p.product_category_name,

        SUM(pay.payment_value) AS revenue

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    JOIN products p
        ON oi.product_id = p.product_id

    JOIN payments pay
        ON o.order_id = pay.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY 1
),

total_revenue AS (

    SELECT
        SUM(revenue) AS total_rev
    FROM category_revenue
),

top5 AS (

    SELECT *
    FROM category_revenue
    ORDER BY revenue DESC
    LIMIT 5
)

SELECT

    ROUND(SUM(t.revenue)::numeric,2) AS top5_revenue,

    ROUND(
        (
            (
                SUM(t.revenue)
                /
                MAX(tr.total_rev)
            ) * 100
        )::numeric,
        2
    ) AS top5_revenue_percentage

FROM top5 t
CROSS JOIN total_revenue tr;

______________________________________________________________________________

3.3 Product Pareto Analysis
Purpose:
* Evaluate product revenue concentration
* Determine how many products generate most of the revenue

#sql query
WITH product_revenue AS (

    SELECT

        oi.product_id,

        SUM(pay.payment_value) AS revenue

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    JOIN payments pay
        ON o.order_id = pay.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY 1
),

total_revenue AS (

    SELECT
        SUM(revenue) AS total_rev
    FROM product_revenue
),

top_products AS (

    SELECT *
    FROM product_revenue
    ORDER BY revenue DESC
    LIMIT 100
)

SELECT

    COUNT(*) AS top_products,

    ROUND(SUM(revenue)::numeric,2) AS revenue,

    ROUND(
        (
            (
                SUM(revenue)
                /
                MAX(total_rev)
            ) * 100
        )::numeric,
        2
    ) AS revenue_percentage

FROM top_products
CROSS JOIN total_revenue;

______________________________________________________________

4. Reviews Analysis
4.1 Reviews by Customer Type
Purpose:
Compare review scores between:
* One-time customers
* Repeat customers

#sql query
WITH customer_type AS (

    SELECT

        c.customer_unique_id,

        CASE
            WHEN COUNT(DISTINCT o.order_id) = 1 THEN 'One-time'
            ELSE 'Repeat'
        END AS customer_type

    FROM orders o

    JOIN customers c
        ON o.customer_id = c.customer_id

    WHERE o.order_status = 'delivered'

    GROUP BY 1
)

SELECT

    ct.customer_type,

    ROUND(
        AVG(r.review_score)::numeric,
        2
    ) AS avg_review

FROM orders o

JOIN customers c
    ON o.customer_id = c.customer_id

JOIN reviews r
    ON o.order_id = r.order_id

JOIN customer_type ct
    ON c.customer_unique_id = ct.customer_unique_id

GROUP BY 1;

____________________________________________________________________________

4.2 Revenue vs Reviews by Category
Purpose:
* Evaluate whether higher-rated categories generate higher revenue

#sql query
WITH category_revenue AS (

    SELECT

        p.product_category_name,

        SUM(pay.payment_value) AS revenue

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    JOIN products p
        ON oi.product_id = p.product_id

    JOIN payments pay
        ON o.order_id = pay.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY 1
),

top_categories AS (

    SELECT product_category_name
    FROM category_revenue
    ORDER BY revenue DESC
    LIMIT 10
)

SELECT

    DATE_TRUNC(
        'month',
        o.order_purchase_timestamp
    )::date AS month,

    CASE

        WHEN p.product_category_name IN (
            SELECT product_category_name
            FROM top_categories
        )

        THEN p.product_category_name

        ELSE 'Others'

    END AS category_group,

    ROUND(
        SUM(pay.payment_value)::numeric,
        2
    ) AS revenue,

    ROUND(
        AVG(r.review_score)::numeric,
        2
    ) AS avg_review,

    COUNT(DISTINCT o.order_id) AS orders

FROM orders o

JOIN order_items oi
    ON o.order_id = oi.order_id

JOIN products p
    ON oi.product_id = p.product_id

JOIN payments pay
    ON o.order_id = pay.order_id

LEFT JOIN reviews r
    ON o.order_id = r.order_id

WHERE o.order_status = 'delivered'

GROUP BY 1,2
ORDER BY revenue DESC;

_____________________________________________________________

5. Delivery Analysis
5.1 Delivery Speed vs Repeat Behavior
Purpose:
Evaluate whether delivery speed affects customer retention

#sql query
WITH customer_orders AS (

    SELECT

        c.customer_unique_id,

        COUNT(DISTINCT o.order_id) AS total_orders,

        AVG(
            DATE_PART(
                'day',
                o.order_delivered_customer_date
                -
                o.order_purchase_timestamp
            )
        ) AS delivery_days

    FROM orders o

    JOIN customers c
        ON o.customer_id = c.customer_id

    WHERE
        o.order_status = 'delivered'
        AND o.order_delivered_customer_date IS NOT NULL

    GROUP BY 1
)

SELECT

    CASE
        WHEN delivery_days <= 7 THEN 'Fast'
        WHEN delivery_days <= 14 THEN 'Medium'
        ELSE 'Slow'
    END AS delivery_group,

    COUNT(*) AS customers,

    ROUND(
        AVG(total_orders)::numeric,
        3
    ) AS avg_orders

FROM customer_orders

GROUP BY 1
ORDER BY avg_orders DESC;

_____________________________________________________________________

Final Business Insights:
Key Findings:
* Revenue growth was primarily driven by increasing order volume rather than changes in AOV.
* Customer retention was critically low.
* Most customers purchased only once.
* Revenue was moderately concentrated within a limited number of product categories.
* Reviews and delivery speed showed limited impact on repeat behavior.


