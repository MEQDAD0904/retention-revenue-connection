Customer Retention & Revenue Growth Analysis
Overview
This project analyzes how customer behavior impacts revenue growth using the Olist Brazilian E-commerce dataset.
_________________________________________________________________________________________________________________________

The analysis began as two separate projects:
* Revenue Analysis
* Customer Behavior Analysis
However, during the investigation, it became clear that both analyses were connected and explained the same business story from different perspectives.

The final result is an integrated analytical dashboard that combines:
* Revenue Trends
* Customer Retention
* Cohort Analysis
* Product Revenue Concentration
* Reviews & Operational Metrics
The project focuses on identifying the main drivers behind revenue growth and evaluating whether that growth is sustainable.
______________________________________________________________________________________________________________________________

Business Problem

The primary objective was to understand:
What drives revenue growth, and how does customer behavior influence it?

Key business questions included:
* Is revenue growth driven by order volume or order value?
* Are customers returning after their first purchase?
* Which product categories contribute most to revenue?
* Do reviews or delivery speed affect repeat purchases?
* Is revenue concentrated within a small number of categories?
_________________________________________________________________________________________________________________________

Dataset
Dataset Used:
Olist Brazilian E-commerce Dataset

Main tables used:
* Orders
* Customers
* Payments
* Order Items
* Products
* Reviews
* Product Category Translation
________________________________________________________________________________

Tools & Technologies
* PostgreSQL
* SQL
* Python (Pandas / Matplotlib)
* Power BI
________________________________________________________________________________

Analysis Workflow:
1. Revenue Analysis
The first step was analyzing:
* Revenue Trends
* Order Volume
* Average Order Value (AOV)

Key Finding:
Revenue growth was primarily driven by increasing order volume rather than changes in AOV.

2. Customer Retention Analysis
Customer behavior analysis revealed:
* Extremely low repeat purchase behavior 
* Most customers purchased only once

Cohort Analysis
A cohort retention analysis showed a sharp drop after the first month.

Key Findings:
* Repeat Rate 3%
* One-time buyers represented the overwhelming majority of customers

3. Product Analysis
Product category analysis showed that revenue was moderately concentrated within a limited number of categories.

Key Finding:
Top 5 product categories generated 38% of total revenue.

4. Reviews & Operational Analysis
The analysis explored whether:
* Review scores
* Delivery speed
had a measurable impact on repeat purchasing behavior.

Key Findings:
* Review scores showed minimal differences between repeat and one-time customers
* Delivery speed had limited impact on customer retention
______________________________________________________________________________________________

# Dashboard pages:

1. Revenue Overview
Tracks revenue growth, order trends, and AOV behavior over time.

![overview](images/overview.png)

2. Customer Retention
Focuses on cohort analysis and repeat purchase behavior.

![retention](images/retention.png)

3. Product Analysis
Highlights revenue concentration across product categories.


![products](images/products.png)

4. Reviews & Operations
Explores customer satisfaction and delivery performance.


![reviews](images/reviews.png)
________________________________________________________________________________________________

# Key Insights:
* Revenue growth was primarily driven by order volume rather than AOV.
* Customer retention was critically low.
* Most customers purchased only once.
* Revenue was moderately concentrated within a limited number of product categories.
* Reviews and delivery speed showed limited impact on repeat behavior.
_________________________________________________________________________________________________

What I Learned:
This project significantly changed how I think about data analysis
Initially, I treated:
* revenue analysis,
* customer analysis,
* product analysis,
* and operational analysis
as separate domains.
But through the project, I realized that effective analytics comes from connecting all business metrics into one coherent narrative
The biggest takeaway was understanding that dashboards should not simply display charts — they should tell a business story.
