/*---------------------------
	Case Study Questions
-----------------------------*/

-- A. Customer Nodes Exploration

-- 1. How many unique nodes are there on the Data Bank system?
-- 2. What is the number of nodes per region?
-- 3. How many customers are allocated to each region?
-- 4. How many days on average are customers reallocated to a different node?
-- 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?


-- 1. How many unique nodes are there on the Data Bank system?

select count(distinct node_id) as unique_node
from data_bank.customer_nodes;


-- 2. What is the number of nodes per region?

select region_name 
	, count(distinct node_id) as unique_node
from data_bank.customer_nodes as cn
	join data_bank.regions as r on cn.region_id = r.region_id
group by 1;


-- 3. How many customers are allocated to each region?

select region_name 
	, count(distinct customer_id) as unique_customers
from data_bank.customer_nodes as cn
	join data_bank.regions as r on cn.region_id = r.region_id
group by 1;


-- 4. How many days on average are customers reallocated to a different node?

with cte as (
	select customer_id
		, node_id
		, sum(end_date::date - start_date::date) as difference
	from data_bank.customer_nodes 
	where end_date != '9999-12-31'
	group by 1, 2
	)
select round(avg(difference)) as avg_days_in_node
from cte;
	
	
-- 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

with cte as (
	select cn.customer_id
		, cn.node_id
		, r.region_name
		, sum(end_date::date - start_date::date) as difference
	from data_bank.customer_nodes as cn
		join data_bank.regions as r on cn.region_id = r.region_id
	where end_date != '9999-12-31'
	group by 1, 2, 3
	)
select region_name
	, round(avg(difference)) as avg_days_in_node
	, percentile_cont(0.5) within group (order by difference) as median
	, round(percentile_cont(0.80) within group (order by difference)) as perc_80
	, round(percentile_cont(0.95) within group (order by difference)) as perc_95
from cte
group by 1;
