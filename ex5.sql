/* create database */

drop database if exists `lectia_5`;
create database `lectia_5`;

/* make created database active */

use `lectia_5`;

/* create table */

drop table if exists `users`;
create table `users`(
	`id` serial primary key,
	`name` varchar(100),
	`created_at` varchar(20),
	`updated_at` varchar(20)
);

/* insert values into table */

insert into `users` (`name`)
values
('User1'),
('User2'),
('User3'),
('User4'),
('User5'),
('User6'),
('User7'),
('User8'),
('User9');

/* fill empty values */

update `users`
	set `created_at` = now(),
		`updated_at` = now()
	where `created_at` is null or `updated_at` is null;

/* create new table*/

drop table if exists `users_new`;
create table `users_new`(
	`id` serial primary key,
	`name` varchar(100),
	`created_at` datetime,
	`updated_at` datetime
);

/* insert records into new table*/

insert into `users_new` (`name`, `created_at`, `updated_at`)
select
	`name`,
	str_to_date(`created_at`, '%Y-%m-%d %H:%i:%s') as created_at,
	str_to_date(`updated_at`, '%Y-%m-%d %H:%i:%s') as updated_at
from `users`;

/* drop incorrect table */

drop table `users`;

/* put correct table to right place, rename*/

rename table `users_new` to `users`;

/*******************************************************************************************/
/*******************************************************************************************/
/*******************************************************************************************/
/*******************************************************************************************/

/* create table */

drop table if exists `storehouses_products`;
create table `storehouses_products`(
	`id` serial primary key,
	`name` varchar(100),
	`value` decimal(10, 3) not null default 0
);

/* insert records into table */

insert into `storehouses_products` (`name`, `value`)
values
	('item 1', 1),
	('item 2', 2),
	('item 3', 3.48),
	('item 4', 0),
	('item 5', 4),
	('item 6', 0),
	('item 7', 1.34),
	('item 8', 1.02),
	('item 9', 7);

select
	`id`,
	`name`,
	`value`,
	(case
		when value = 0 then 1
		else 0
	end) as value_group
from
	`storehouses_products`
order by value_group, value;
	
	
	
	
	
	


