
use portfolio;
create table sales
(customer_id varchar(1),order_date date,product_id integer);
create table members
(customer_id varchar(1),join_date date);
create table menu
(product_id integer,product_name varchar(5),price integer);

insert into sales values
('A', '2021-01-01', '1'),
('A', '2021-01-01', '2'),
('A', '2021-01-07', '2'),
('A', '2021-01-10', '3'),
('A', '2021-01-11', '3'),
('A', '2021-01-11', '3'),
('B', '2021-01-01', '2'),
('B', '2021-01-02', '2'),
('B', '2021-01-04', '1'),
('B', '2021-01-11', '1'),
('B', '2021-01-16', '3'),
('B', '2021-02-01', '3'),
('C', '2021-01-01', '3'),
('C', '2021-01-01', '3'),
('C', '2021-01-07', '3');
select*from sales;

insert into menu values
('1', 'sushi', '10'),
('2', 'curry', '15'),
('3', 'ramen', '12');

insert into members values 
('A', '2021-01-07'),
('B', '2021-01-09');

---What is the total amount each customer spent at the restaurant?
create view total_amonut_spent as
select sales.customer_id,sum(menu.price) as total_spent
from sales left join menu
on sales.product_id=menu.product_id
group by sales.customer_id;

---How many days has each customer visited the restaurant?'''
create view total_days_visited as
select customer_id,count(order_date) as days_visited
from sales
group by customer_id;

---What was the first item from the menu purchased by each customer?
with earlier as(
select customer_id,min(order_date) as m_date
from sales
group by customer_id)
select distinct(sales.customer_id),menu.product_name,sales.order_date
from sales left join menu on sales.product_id=menu.product_id
join earlier on sales.order_date=earlier.m_date and sales.customer_id=earlier.customer_id;

---What is the most purchased item on the menu and how many times was it purchased by all customers?
create view most_purchased as 
with m_pro as(
select customer_id,product_id,count(product_id) as purchase_count
from sales group by customer_id,product_id),
c_max as(
select customer_id,max(purchase_count) as m_p_count
from m_pro group by customer_id)
select m_pro.customer_id,m_pro.purchase_count,menu.product_name
from m_pro join	c_max on m_pro.customer_id=c_max.customer_id and m_pro.purchase_count=c_max.m_p_count
join menu on menu.product_id=m_pro.product_id
order by m_pro.customer_id;

---Which item was the most popular for each customer?
create view popular_by_customer as
with popular_item as(
select customer_id,product_id,count(product_id) as max_item
from sales
group by customer_id,product_id),
max_item as(
select sales.customer_id,max(popular_item.max_item) as most_item
from sales join popular_item on sales.customer_id=popular_item.customer_id
group by sales.customer_id)
select popular_item.customer_id,menu.product_name,popular_item.max_item
from popular_item join max_item on popular_item.customer_id=max_item.customer_id and popular_item.max_item=max_item.most_item
join menu on popular_item.product_id=menu.product_id;
order by popular_item.customer_id;

---Which item was purchased first by the customer after they became a member?
with first_order_customer as(
select sales.customer_id,min(sales.order_date) as first_order
from sales join members on sales.customer_id=members.customer_id
where sales.order_date>=members.join_date
 group by customer_id)
 select first_order_customer.customer_id,first_order_customer.first_order,menu.product_name
 from first_order_customer join sales on first_order_customer.customer_id=sales.customer_id and first_order_customer.first_order=sales.order_date
 join menu on menu.product_id=sales.product_id;
 
 ---Which item was purchased just before the customer became a member?
 with last_order as (
 select sales.customer_id,max(sales.order_date) as last_order_ordered
 from sales join members on sales.customer_id=members.customer_id
 where sales.order_date<=members.join_date
 group by sales.customer_id)
 select last_order.customer_id,last_order.last_order_ordered,menu.product_name
 from last_order join sales on last_order.customer_id=sales.customer_id and last_order.last_order_ordered=sales.order_date
 join menu on menu.product_id=sales.product_id;
 
 ---What is the total items and amount spent for each member before they became a member?
  select sales.customer_id,count(sales.product_id) as items_bought,sum(menu.price) as amount_spent
 from sales join members on sales.customer_id=members.customer_id
 join menu on sales.product_id=menu.product_id
 where sales.order_date<=members.join_date
 group by sales.customer_id
 order by sales.customer_id;
 
 
 create view amount_before as 
 select sales.customer_id,count(sales.product_id) as items_bought,sum(menu.price) as amount_spent
 from sales join members on sales.customer_id=members.customer_id
 join menu on sales.product_id=menu.product_id
 where sales.order_date<=members.join_date
 group by sales.customer_id;
 order by sales.customer_id;
 