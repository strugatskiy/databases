DROP DATABASE IF EXISTS vk;
CREATE DATABASE vk;
USE vk;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id SERIAL PRIMARY KEY, -- SERIAL = BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE
    firstname VARCHAR(50),
    lastname VARCHAR(50) COMMENT 'Фамиль', -- COMMENT на случай, если имя неочевидное
    email VARCHAR(120) UNIQUE,
    phone BIGINT, 
    INDEX users_phone_idx(phone), -- как выбирать индексы?
    INDEX users_firstname_lastname_idx(firstname, lastname)
);

DROP TABLE IF EXISTS `profiles`;
CREATE TABLE `profiles` (
	user_id SERIAL PRIMARY KEY,
    gender CHAR(1),
    birthday DATE,
	photo_id BIGINT UNSIGNED NULL,
    created_at DATETIME DEFAULT NOW(),
    hometown VARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES users(id) -- что за зверь в целом?
    	ON UPDATE CASCADE -- как это работает? Какие варианты?
    	ON DELETE restrict -- как это работает? Какие варианты?
    -- , FOREIGN KEY (photo_id) REFERENCES media(id) -- пока рано, т.к. таблицы media еще нет
);

DROP TABLE IF EXISTS messages;
CREATE TABLE messages (
	id SERIAL PRIMARY KEY,
	from_user_id BIGINT UNSIGNED NOT NULL,
    to_user_id BIGINT UNSIGNED NOT NULL,
    body TEXT,
    created_at DATETIME DEFAULT NOW(), -- можно будет даже не упоминать это поле при вставке
    INDEX messages_from_user_id (from_user_id),
    INDEX messages_to_user_id (to_user_id),
    FOREIGN KEY (from_user_id) REFERENCES users(id),
    FOREIGN KEY (to_user_id) REFERENCES users(id)
);

/* я бы изменил таблицу friend_requests
 * может быть и встречный френд реквест и анфренд только с одной стороны
 */

DROP TABLE IF EXISTS friend_requests;
CREATE TABLE friend_requests (
	-- id SERIAL PRIMARY KEY, -- изменили на композитный ключ (initiator_user_id, target_user_id)
	initiator_user_id BIGINT UNSIGNED NOT NULL,
    target_user_id BIGINT UNSIGNED NOT NULL,
    -- `status` TINYINT UNSIGNED,
    `status` ENUM('requested', 'approved', 'unfriended', 'declined'),
    -- `status` TINYINT UNSIGNED, -- в этом случае в коде хранили бы цифирный enum (0, 1, 2, 3...)
	requested_at DATETIME DEFAULT NOW(),
	confirmed_at DATETIME,
	
    PRIMARY KEY (initiator_user_id, target_user_id),
	INDEX (initiator_user_id), -- потому что обычно будем искать друзей конкретного пользователя
    INDEX (target_user_id),
    FOREIGN KEY (initiator_user_id) REFERENCES users(id),
    FOREIGN KEY (target_user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS communities;
CREATE TABLE communities(
	id SERIAL PRIMARY KEY,
	name VARCHAR(150),

	INDEX communities_name_idx(name)
);

DROP TABLE IF EXISTS users_communities;
CREATE TABLE users_communities(
	user_id BIGINT UNSIGNED NOT NULL,
	community_id BIGINT UNSIGNED NOT NULL,
  
	PRIMARY KEY (user_id, community_id), -- чтобы не было 2 записей о пользователе и сообществе
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (community_id) REFERENCES communities(id)
);

DROP TABLE IF EXISTS media_types;
CREATE TABLE media_types(
	id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

    -- записей мало, поэтому индекс будет лишним (замедлит работу)!
);

DROP TABLE IF EXISTS media;
CREATE TABLE media(
	id SERIAL PRIMARY KEY,
    media_type_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
  	body text,
    filename VARCHAR(255),
    size INT,
	metadata JSON,
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX (user_id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (media_type_id) REFERENCES media_types(id)
);

DROP TABLE IF EXISTS likes;
CREATE TABLE likes(
	id SERIAL PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    media_id BIGINT UNSIGNED NOT NULL,
    created_at DATETIME DEFAULT NOW(),
    
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (media_id) REFERENCES media(id)

    -- PRIMARY KEY (user_id, media_id) – можно было и так вместо id в качестве PK
  	-- слишком увлекаться индексами тоже опасно, рациональнее их добавлять по мере необходимости (напр., провисают по времени какие-то запросы)  

/* намеренно забыли, чтобы увидеть нехватку в ER-диаграмме
    , FOREIGN KEY (user_id) REFERENCES users(id)
    , FOREIGN KEY (media_id) REFERENCES media(id)
*/
);

DROP TABLE IF EXISTS `photo_albums`;
CREATE TABLE `photo_albums` (
	`id` SERIAL,
	`name` varchar(255) DEFAULT NULL,
    `user_id` BIGINT UNSIGNED DEFAULT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id),
  	PRIMARY KEY (`id`)
);

DROP TABLE IF EXISTS `photos`;
CREATE TABLE `photos` (
	id SERIAL PRIMARY KEY,
	`album_id` BIGINT unsigned NOT NULL,
	`media_id` BIGINT unsigned NOT NULL,

	FOREIGN KEY (album_id) REFERENCES photo_albums(id),
    FOREIGN KEY (media_id) REFERENCES media(id)
);

DROP TABLE IF EXISTS posts;
CREATE TABLE posts(
	id SERIAL PRIMARY KEY,
	user_id BIGINT UNSIGNED NOT NULL,
	body TEXT,
	created_at DATETIME DEFAULT NOW(),
	
	INDEX posts_user_id (user_id),
	FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS posts_likes;
CREATE TABLE posts_likes(
	id SERIAL PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    post_id BIGINT UNSIGNED NOT NULL,
    created_at DATETIME DEFAULT NOW(),
    
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (post_id) REFERENCES posts(id)
);


DROP TABLE IF EXISTS users_likes;
CREATE TABLE users_likes(
	id SERIAL PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    target_user_id BIGINT UNSIGNED NOT NULL,
    created_at DATETIME DEFAULT NOW(),
    
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (target_user_id) REFERENCES users(id)
);

/*----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------*/

INSERT INTO `users`
	(`id`	,`firstname`, `lastname`, `email`	, `phone`)
VALUES
	('1'	,'Ivan'		,'Ivanov'	,'111@111'	,'11'),
	('2'	,'Petr'		,'Petrov'	,'222@222'	,'22'),
	('3'	,'Sidor'	,'Sidorov'	,'333@333'	,'33'),
	('4'	,'Svetlana'	,'Ivanova'	,'444@444'	,'44'),
	('5'	,'Tatiana'	,'Petrova'	,'555@555'	,'55');

INSERT INTO `profiles`
	(`user_id`	, `gender`	, `birthday`	, `hometown`)
VALUES
	('1'		, 'M'		, '1981-01-01'	, 'Moscow'),
	('2'		, 'M'		, '1982-02-02'	, 'St. Petersburg'),
	('3'		, 'M'		, '1983-03-03'	, 'Tver'),
	('4'		, 'F'		, '1983-03-03'	, 'Zimbabwe'),
	('5'		, 'F'		, '1983-03-03'	, 'Urugvay');

INSERT INTO `messages`
	(`from_user_id`	, `to_user_id`	, `body`)
VALUES
	('1'			, '2'			, '111222'),
	('1'			, '3'			, '111333'),
	('1'			, '4'			, '111444'),
	('1'			, '5'			, '111555'),
	('1'			, '4'			, '111444-2'),
	('1'			, '5'			, '111555-2'),
	('2'			, '1'			, '222111'),
	('2'			, '3'			, '222333'),
	('2'			, '4'			, '222444'),
	('2'			, '5'			, '222555'),
	('3'			, '1'			, '333111'),
	('3'			, '1'			, '333111-2'),
	('3'			, '1'			, '333111-3'),
	('3'			, '2'			, '333222'),
	('3'			, '4'			, '333444'),
	('3'			, '5'			, '333555'),
	('4'			, '1'			, '444111'),
	('4'			, '2'			, '444222'),
	('4'			, '3'			, '444333'),
	('4'			, '5'			, '444222'),
	('5'			, '1'			, '555111'),
	('5'			, '2'			, '555222'),
	('5'			, '3'			, '555333'),
	('5'			, '4'			, '555444');

INSERT INTO `friend_requests`
	(`initiator_user_id`, `target_user_id`	, `status`)
VALUES
	('1'				, '2'				, 'requested'),
	('1'				, '3'				, 'approved'),
	('1'				, '4'				, 'approved'),
	('1'				, '5'				, 'approved'),
	('2'				, '1'				, 'requested'),
	('2'				, '3'				, 'declined'),
	('2'				, '4'				, 'approved'),
	('2'				, '5'				, 'declined'),
	('3'				, '1'				, 'approved'),
	('3'				, '2'				, 'requested'),
	('3'				, '4'				, 'declined'),
	('3'				, '5'				, 'approved'),
	('4'				, '1'				, 'approved'),
	('4'				, '2'				, 'declined'),
	('4'				, '3'				, 'requested'),
	('4'				, '5'				, 'declined'),
	('5'				, '1'				, 'approved'),
	('5'				, '2'				, 'declined'),
	('5'				, '3'				, 'approved'),
	('5'				, '4'				, 'requested');

INSERT INTO `communities`
	(`id`	, `name`)
VALUES
	('1'	, 'group1'),
	('2'	, 'group2'),
	('3'	, 'group3'),
	('4'	, 'group4'),
	('5'	, 'group5'),
	('6'	, 'group6'),
	('7'	, 'group7'),
	('8'	, 'group8'),
	('9'	, 'group9');

INSERT INTO `users_communities`
	(`user_id`	, `community_id`)
VALUES
	('1'		, '2'),
	('1'		, '5'),
	('1'		, '8'),
	('2'		, '2'),
	('2'		, '7'),
	('2'		, '4'),
	('2'		, '3'),
	('3'		, '3'),
	('3'		, '8');
	
INSERT INTO `media_types`
	(`id`	, `name`)
VALUES
	('1'	, 'media type 1'),
	('2'	, 'media type 2'),
	('3'	, 'media type 3'),
	('4'	, 'media type 4'),
	('5'	, 'media type 5');

INSERT INTO `media`
	(`id`	, `media_type_id`	, `user_id`)
VALUES
	('1'	, '1'				, '1'),
	('2'	, '3'				, '2'),
	('3'	, '5'				, '3'),
	('4'	, '2'				, '1'),
	('5'	, '4'				, '2'),
	('6'	, '1'				, '3'),
	('7'	, '2'				, '1'),
	('8'	, '3'				, '2'),
	('9'	, '4'				, '3');
	
INSERT INTO `likes`
	(`id`	, `user_id`	, `media_id`)
VALUES
	('1'	, '1'		, '1'),
	('2'	, '2'		, '3'),
	('3'	, '3'		, '5'),
	('4'	, '2'		, '8'),
	('5'	, '1'		, '9');
	
INSERT INTO `photo_albums`
	(`id`	, `name`	, `user_id`)
VALUES
	('1'	, 'album_1'	, '1'),
	('2'	, 'album_2'	, '2'),
	('3'	, 'album_3'	, '3'),
	('4'	, 'album_4'	, '1'),
	('5'	, 'album_5'	, '2'),
	('6'	, 'album_6'	, '3'),
	('7'	, 'album_7'	, '1'),
	('8'	, 'album_8'	, '2'),
	('9'	, 'album_9'	, '3');

INSERT INTO `photos`
	(`id`	, `album_id`, `media_id`)
VALUES
	('1'	, '1'		, '1'),
	('2'	, '2'		, '2'),
	('3'	, '2'		, '3'),
	('4'	, '3'		, '2'),
	('5'	, '3'		, '4'),
	('6'	, '3'		, '1'),
	('7'	, '4'		, '5'),
	('8'	, '4'		, '1'),
	('9'	, '4'		, '2');

INSERT INTO `posts`
	(`id`, `user_id`, `body`)
VALUES
	('1', '1', 'boby 1'),
	('2', '2', 'boby 2'),
	('3', '3', 'boby 3'),
	('4', '1', 'boby 4'),
	('5', '2', 'boby 5'),
	('6', '3', 'boby 6'),
	('7', '1', 'boby 7'),
	('8', '2', 'boby 8'),
	('9', '3', 'boby 9');

INSERT INTO `posts_likes`
	(`id`	, `user_id`	, `post_id`)
VALUES
	('1'	, '1'	, '1'),
	('2'	, '2'	, '2'),
	('3'	, '3'	, '3'),
	('4'	, '1'	, '4'),
	('5'	, '2'	, '8'),
	('6'	, '3'	, '4'),
	('7'	, '1'	, '2'),
	('8'	, '2'	, '5'),
	('9'	, '3'	, '2');

INSERT INTO `users_likes`
	(`user_id`	, `target_user_id`)
VALUES
	('1'		, '2'),
	('1'		, '3'),
	('2'		, '5'),
	('2'		, '4'),
	('3'		, '2'),
	('3'		, '1'),
	('3'		, '5'),
	('4'		, '1'),
	('5'		, '1');

/********************************************************************************************************************************************/
/********************************************************************************************************************************************/

/*САМЫЙ ОБЩИТЕЛЬНЫЙ ДРУГ У ПОЛЬЗОВАТЕЛЯ 1 */

/* 'friend' = status 'approved' */


SELECT
	user_id,
	SUM(posts) AS posts
FROM
	(SELECT
		to_user_id as user_id,
		COUNT(*) as posts
	FROM
		messages
	WHERE
		(from_user_id = 1
		AND to_user_id IN
			(SELECT
				initiator_user_id as user_id
			FROM
				friend_requests
			WHERE
				target_user_id = 1
				AND status = 'approved'
			
			UNION
			
			SELECT
				target_user_id as user_id
			FROM
				friend_requests
			WHERE
				initiator_user_id = 1
				AND status = 'approved'))
	GROUP BY user_id
	
	UNION
	
	SELECT
		from_user_id as user_id,
		COUNT(*) as posts
	FROM
		messages
	WHERE
		(to_user_id = 1
		AND from_user_id IN
			(SELECT
				initiator_user_id as user_id
			FROM
				friend_requests
			WHERE
				target_user_id = 1
				AND status = 'approved'
			
			UNION
			
			SELECT
				target_user_id as user_id
			FROM
				friend_requests
			WHERE
				initiator_user_id = 1
				AND status = 'approved'))
	GROUP BY user_id) AS post_count
GROUP BY post_count.user_id
ORDER BY posts DESC
LIMIT 1;


/*******************************************************************************************************************************************************/
/*******************************************************************************************************************************************************/

/* КОЛИЧЕСТВО ЛАЙКОВ САМЫХ МОЛОДЫХ */


SELECT
	COUNT(*)
FROM
	users_likes
JOIN
	(SELECT
		user_id
	FROM profiles
	ORDER BY birthday DESC
	LIMIT 10) TT
ON users_likes.target_user_id = TT.user_id;


/*******************************************************************************************************************************************************/
/*******************************************************************************************************************************************************/

/* КТО БОЛЬШЕ ПОСТАВИЛ ЛАЙКОВ */


SELECT
	gender,
	COUNT(*)
FROM
	users_likes
JOIN
	(SELECT
		user_id,
		gender
	FROM profiles) TT
ON users_likes.user_id = TT.user_id
GROUP BY
	gender;


/*******************************************************************************************************************************************************/
/*******************************************************************************************************************************************************/

/* НАИМЕНЬШАЯ АКТИВНОСТЬ */
/* задание не точное - что значит "наименьшая активность"? */
/* поэтому определим по наименьшему количеству сообщений */


SELECT
	from_user_id AS user_id,
	COUNT(*) AS user_msg
FROM messages
GROUP BY from_user_id
ORDER BY user_msg
LIMIT 10;

