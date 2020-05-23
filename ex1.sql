// запуск mysql
mysql

// выполнение в mysql
DROP DATABASE IF EXISTS example;

CREATE DATABASE IF NOT EXISTS example;

USE example;

CREATE TABLE users (
	id SERIAL PRIMARY KEY COMMENT 'Первичный ключ',
	name VARCHAR(255) COMMENT 'Имя пользователя'
) COMMENT 'Таблица пользователей';

INSERT INTO users VALUES
	(DEFAULT, 'user1'),
	(DEFAULT, 'user2'),
	(DEFAULT, 'user3'),
	(DEFAULT, 'user4'),
	(DEFAULT, 'user5'),
	(DEFAULT, 'user6'),
	(DEFAULT, 'user7'),
	(DEFAULT, 'user8'),
	(DEFAULT, 'user9'),
	(DEFAULT, 'user10'),
	(DEFAULT, 'user11');

SELECT * FROM example.users;

EXIT

// выполнение из командной строки
mysqldump example > example.sql

// mysql
mysql

DROP DATABASE IF EXISTS sample;

CREATE DATABASE IF NOT EXISTS sample;

EXIT

// выполнение из командной строки
mysql sample < example.sql

// первые несколько записей таблицы
mysqldump example users --where="id<=5" > ex2.sql
