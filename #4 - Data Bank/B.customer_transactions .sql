/*---------------------------
	Case Study Questions
-----------------------------*/

-- B. Customer Transactions

-- 1. What is the unique count and total amount for each transaction type?
-- 2. What is the average total historical deposit counts and amounts for all customers?
-- 3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
-- 4. What is the closing balance for each customer at the end of the month?
-- 5. What is the percentage of customers who increase their closing balance by more than 5%?


-- 1. What is the unique count and total amount for each transaction type?

select txn_type
	, sum(txn_amount) as total_amount
from data_bank.customer_transactions
group by 1;


-- 2. What is the average total historical deposit counts and amounts for all customers?

with cte as (
	select customer_id
		, avg(txn_amount) as avg_amount
		, count(*) as txn
	from data_bank.customer_transactions
	where txn_type = 'deposit'
	group by 1
	)
select round(avg(avg_amount),2) as avg_deposit_amount
	, round(avg(txn)) as avg_txn_count
from cte;


-- 3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

with cte as (
	select to_char(txn_date::date, 'month') as mth
		, customer_id
		, sum(case when txn_type = 'deposit' then 1 else 0 end) as deposit
		, sum(case when txn_type != 'deposit' then 1 else 0 end) as purchase_or_withdrawal
	from data_bank.customer_transactions
	group by 1,2
	having sum(case when txn_type = 'deposit' then 1 else 0 end) > 1
		and sum(case when txn_type != 'deposit' then 1 else 0 end) = 1
	)
select mth
	, count(customer_id) as customers
from cte
group by 1; 


-- 4. What is the closing balance for each customer at the end of the month?

with cte as (
    select customer_id
        , txn_date
        , txn_type
        , txn_amount
        , extract(month from txn_date) as txn_month
		, sum(case when txn_type = 'deposit' then txn_amount else -txn_amount end) 
			over (partition by customer_id order by txn_date) as balance
        , row_number() over (partition by customer_id, extract(month from txn_date) order by txn_date desc) as rn
    from data_bank.customer_transactions
	)
select customer_id
    , txn_month
	, balance as closing_balance
from cte
where rn = 1;


-- 5. What is the percentage of customers who increase their closing balance by more than 5%?

