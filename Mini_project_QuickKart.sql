

create database Quickkart; # creating the database

use quickkart; # selecting the database

# creating the customer table

create table customer (
	customer_id integer primary key,
    customer_name varchar (100) Not Null,
    email varchar(100) Unique,
    city varchar(100)
);

# create Product table

create table Product (
	product_id integer primary key,
	product_name varchar(100) not null,
	price decimal(10,2) check (price >0)
);

# create Orders table

create table Orders (
	order_id	integer primary key,
	customer_id	integer not null,
	product_id	integer not null,
	quantity	integer check (quantity>0),
	order_date	date not null
);

# create Temporary table to store invalid data

create table temp_orders (
	Temp_id		integer primary key,
	order_id	integer,
	customer_id	integer,
	product_id	integer,
	quantity	integer,
	order_date	date
    );
    
# Inserting sample data
# customers
insert into Customer
(customer_id, customer_name, email, city)
values
(101, 'Anu', 'anu@gmail.com', 'India'),
(102, 'Ben', 'ravi@gmail.com', 'Japan'),
(103, 'Lui', 'priya@gmail.com', 'China'),
(104, 'Chu', 'john@gmail.com', 'Korea')
;

# Products

insert into Product
(product_id, product_name, price)
values
(201, 'Laptop', 899.99),
(202, 'Mouse', 19.50),
(203, 'Keyboard', 45.00),
(204, 'Monitor', 199.99),
(205, 'Headphones', 59.99)
;

# Temporary orders (collecting all the data including missing, invalid, null)

insert into Temp_Orders
(Temp_id, order_id, customer_id, product_id, quantity, order_date)
VALUES
(1, 5001, 101, 201, 1, '2026-11-01'),
(2, 5002, 102, 202, 2, '2026-11-02'),
(3, 5002, 101, 203, 1, '2026-11-02'),
(4, 5003, 999, 204, 1, '2026-11-03'),
(5, 5004, 103, 205, -2, '2026-11-03'),
(6, 5005, NULL, 202, 1, '2026-11-04'),
(7, 5006, 104, 999, 1, '2026-11-04')
;

# data quality investigation
# Finding missing customer references

select t.customer_id, t.order_id, c.customer_name
from temp_orders t 
left join customer c 
	on t.customer_id = c.customer_id
	where c.customer_id is null
	and t.customer_id is not null;
    
# Finding duplicate orders

select order_id, count(*) as occurrence_count
from temp_orders
group by order_id
having count(*) > 1;

# Finding missing customers IDs
select temp_id, order_id
from temp_orders
where customer_id is null;

# checking invalid product references

select t.temp_id, t.order_id, t.product_id
from  temp_orders t
left join product p 
  on t.product_id = p.product_id
where p.product_id is null and t.product_id is not null;

# checking for invalid quantities (negative, zero, missing)

select temp_id, quantity, order_id
from temp_orders
where quantity <= 0 or quantity is null;

### QuickKart Data Quality Report

select order_id, 'Duplicate Order' as issue
from temp_orders
where order_id = 5002
union all
select order_id, 'Invalid Quantity' as issue
from temp_orders
where quantity <= 0;


# combinig all (invalid quantities and duplicaate orders)

select 'Duplicate Order' as issue_type, Temp_id, order_id,
    'Order ID appears more than once' as issue_details
from temp_orders
where order_id in ( select order_id
    from temp_orders
    group by order_id
    having count(*) > 1
)
union all
select 'Invalid Quantity' as issue_type, Temp_id, order_id,
    'Quantity must be greater than zero' as issue_details
from temp_orders
where quantity <= 0 or quantity is null;