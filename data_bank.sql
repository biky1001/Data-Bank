#-----------------------------------------------Data Bank------------------------------------------------------#
create database casestudy1;


use casestudy1;


select * from customer_nodes limit 20;
select * from customer_transactions limit 10;
select * from regions;



## 1. How many different nodes make up the Data Bank network? ##
select count(distinct node_id) as 'unique_nodes'
from customer_nodes;



## 2. How many nodes are there in each region? ##
select r.region_id, r.region_name, count(Cn.node_id) as 'total_nodes'
from customer_nodes Cn
inner join regions r
on Cn.region_id = r.region_id
group by r.region_id, r.region_name
order by r.region_id ;



## 3. How many customers are divided among the regions? ##
select r.region_id, r.region_name, count(distinct Cn.customer_id) as 'customers'
from customer_nodes Cn
inner join regions r
on Cn.region_id = r.region_id
group by r.region_id, r.region_name
order by r.region_id;



## 4. Determine the total amount of transactions for each region name. ##
select r.region_id, r.region_name, sum(Ct.txn_amount) as 'total_transactions'
from customer_transactions Ct
inner join customer_nodes Cn
on Ct.customer_id = Cn.customer_id
inner join regions r
on Cn.region_id = r.region_id
group by r.region_id, r.region_name
order by r.region_id;




## 5. How long does it take on an average to move clients to a new node? ##
select round(avg(datediff(end_date, start_date)),2) as 'avg_days'
from customer_nodes
where end_date != '9999-12-31';




## 6. What is the unique count and total amount for each transaction type? ##
select txn_type, count(txn_type) as 'unqiue_count', sum(txn_amount) as 'total_amount'
from customer_transactions
group by txn_type;




## 7. What is the average number and size of past deposits across all customers? ##
select round(count(customer_id) / (select count(distinct customer_id)        ## average customer transactions for deposit
from customer_transactions)) as 'average_deposit'
from customer_transactions
where txn_type = 'deposit';



## 8. For each month - how many Data Bank customers make more than 1 deposit and at least either 1 purchase or 1 withdrawal in a single month? ##
with transaction_count_per_month_cte as
(
select customer_id, month(txn_date) as 'txn_month',
sum(if(txn_type = 'deposit', 1, 0)) as 'deposit_count',
sum(if(txn_type = 'withdrawal', 1, 0)) as 'withdrawal_count',
sum(if(txn_type = 'purchase', 1, 0)) as 'purchase_count'
from customer_transactions
group by customer_id, txn_month)
select txn_month, count(customer_id) as 'total_customer'
from transaction_count_per_month_cte
where deposit_count > 1
and purchase_count = 1 or withdrawal_count =1
group by txn_month;