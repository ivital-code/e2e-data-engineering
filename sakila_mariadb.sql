-- Sakila-style MariaDB sample schema with original synthetic seed data.
-- Run against a fresh schema. This intentionally does not contain the official
-- Sakila sample dataset, views, routines, or triggers.

CREATE DATABASE IF NOT EXISTS sakila
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sakila;

-- Core tables
CREATE TABLE country (
    country_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    country VARCHAR(50) NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (country_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE city (
    city_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    city VARCHAR(50) NOT NULL,
    country_id SMALLINT UNSIGNED NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (city_id),
    KEY idx_fk_country_id (country_id),
    CONSTRAINT fk_city_country FOREIGN KEY (country_id) REFERENCES country (country_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE address (
    address_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    address VARCHAR(50) NOT NULL,
    address2 VARCHAR(50) DEFAULT NULL,
    district VARCHAR(20) NOT NULL,
    city_id SMALLINT UNSIGNED NOT NULL,
    postal_code VARCHAR(10) DEFAULT NULL,
    phone VARCHAR(20) NOT NULL,
    location GEOMETRY NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (address_id),
    KEY idx_fk_city_id (city_id),
    SPATIAL KEY idx_location (location),
    CONSTRAINT fk_address_city FOREIGN KEY (city_id) REFERENCES city (city_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE language (
    language_id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name CHAR(20) NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (language_id),
    UNIQUE KEY uq_language_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE category (
    category_id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(25) NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (category_id),
    UNIQUE KEY uq_category_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE store (
    store_id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
    manager_staff_id TINYINT UNSIGNED DEFAULT NULL,
    address_id SMALLINT UNSIGNED NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (store_id),
    UNIQUE KEY uq_store_address (address_id),
    KEY idx_store_manager (manager_staff_id),
    CONSTRAINT fk_store_address FOREIGN KEY (address_id) REFERENCES address (address_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE staff (
    staff_id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(45) NOT NULL,
    last_name VARCHAR(45) NOT NULL,
    address_id SMALLINT UNSIGNED NOT NULL,
    email VARCHAR(50) DEFAULT NULL,
    store_id TINYINT UNSIGNED NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    username VARCHAR(16) NOT NULL,
    password VARCHAR(40) DEFAULT NULL,
    picture BLOB DEFAULT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (staff_id),
    UNIQUE KEY uq_staff_username (username),
    KEY idx_staff_store_id (store_id),
    KEY idx_staff_address_id (address_id),
    CONSTRAINT fk_staff_address FOREIGN KEY (address_id) REFERENCES address (address_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_staff_store FOREIGN KEY (store_id) REFERENCES store (store_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE customer (
    customer_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    store_id TINYINT UNSIGNED NOT NULL,
    first_name VARCHAR(45) NOT NULL,
    last_name VARCHAR(45) NOT NULL,
    email VARCHAR(50) DEFAULT NULL,
    address_id SMALLINT UNSIGNED NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    create_date DATETIME NOT NULL,
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (customer_id),
    KEY idx_customer_store_id (store_id),
    KEY idx_customer_address_id (address_id),
    KEY idx_customer_name (last_name, first_name),
    CONSTRAINT fk_customer_address FOREIGN KEY (address_id) REFERENCES address (address_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_customer_store FOREIGN KEY (store_id) REFERENCES store (store_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE actor (
    actor_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(45) NOT NULL,
    last_name VARCHAR(45) NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (actor_id),
    KEY idx_actor_last_name (last_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE film (
    film_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    title VARCHAR(128) NOT NULL,
    description TEXT DEFAULT NULL,
    release_year YEAR DEFAULT NULL,
    language_id TINYINT UNSIGNED NOT NULL,
    original_language_id TINYINT UNSIGNED DEFAULT NULL,
    rental_duration TINYINT UNSIGNED NOT NULL DEFAULT 3,
    rental_rate DECIMAL(4,2) NOT NULL DEFAULT 4.99,
    length SMALLINT UNSIGNED DEFAULT NULL,
    replacement_cost DECIMAL(5,2) NOT NULL DEFAULT 19.99,
    rating ENUM('G','PG','PG-13','R','NC-17') DEFAULT 'G',
    special_features SET('Trailers','Commentaries','Deleted Scenes','Behind the Scenes') DEFAULT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (film_id),
    KEY idx_film_language_id (language_id),
    KEY idx_film_original_language_id (original_language_id),
    KEY idx_film_title (title),
    CONSTRAINT fk_film_language FOREIGN KEY (language_id) REFERENCES language (language_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_film_original_language FOREIGN KEY (original_language_id) REFERENCES language (language_id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE film_text (
    film_id SMALLINT UNSIGNED NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT DEFAULT NULL,
    PRIMARY KEY (film_id),
    FULLTEXT KEY idx_film_text_title_description (title, description),
    CONSTRAINT fk_film_text_film FOREIGN KEY (film_id) REFERENCES film (film_id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE film_actor (
    actor_id SMALLINT UNSIGNED NOT NULL,
    film_id SMALLINT UNSIGNED NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (actor_id, film_id),
    KEY idx_film_actor_film_id (film_id),
    CONSTRAINT fk_film_actor_actor FOREIGN KEY (actor_id) REFERENCES actor (actor_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_film_actor_film FOREIGN KEY (film_id) REFERENCES film (film_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE film_category (
    film_id SMALLINT UNSIGNED NOT NULL,
    category_id TINYINT UNSIGNED NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (film_id, category_id),
    KEY idx_film_category_category_id (category_id),
    CONSTRAINT fk_film_category_film FOREIGN KEY (film_id) REFERENCES film (film_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_film_category_category FOREIGN KEY (category_id) REFERENCES category (category_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE inventory (
    inventory_id MEDIUMINT UNSIGNED NOT NULL AUTO_INCREMENT,
    film_id SMALLINT UNSIGNED NOT NULL,
    store_id TINYINT UNSIGNED NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (inventory_id),
    UNIQUE KEY uq_inventory_film_store (film_id, store_id, inventory_id),
    KEY idx_inventory_store_id (store_id),
    CONSTRAINT fk_inventory_film FOREIGN KEY (film_id) REFERENCES film (film_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_store FOREIGN KEY (store_id) REFERENCES store (store_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE rental (
    rental_id INT NOT NULL AUTO_INCREMENT,
    rental_date DATETIME NOT NULL,
    inventory_id MEDIUMINT UNSIGNED NOT NULL,
    customer_id SMALLINT UNSIGNED NOT NULL,
    return_date DATETIME DEFAULT NULL,
    staff_id TINYINT UNSIGNED NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (rental_id),
    UNIQUE KEY uq_rental_date_inventory_customer (rental_date, inventory_id, customer_id),
    KEY idx_rental_inventory_id (inventory_id),
    KEY idx_rental_customer_id (customer_id),
    KEY idx_rental_staff_id (staff_id),
    CONSTRAINT fk_rental_inventory FOREIGN KEY (inventory_id) REFERENCES inventory (inventory_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_rental_customer FOREIGN KEY (customer_id) REFERENCES customer (customer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_rental_staff FOREIGN KEY (staff_id) REFERENCES staff (staff_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE payment (
    payment_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    customer_id SMALLINT UNSIGNED NOT NULL,
    staff_id TINYINT UNSIGNED NOT NULL,
    rental_id INT DEFAULT NULL,
    amount DECIMAL(5,2) NOT NULL,
    payment_date DATETIME NOT NULL,
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (payment_id),
    KEY idx_payment_customer_id (customer_id),
    KEY idx_payment_staff_id (staff_id),
    KEY idx_payment_rental_id (rental_id),
    CONSTRAINT fk_payment_customer FOREIGN KEY (customer_id) REFERENCES customer (customer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_payment_staff FOREIGN KEY (staff_id) REFERENCES staff (staff_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_payment_rental FOREIGN KEY (rental_id) REFERENCES rental (rental_id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE store
    ADD CONSTRAINT fk_store_manager FOREIGN KEY (manager_staff_id) REFERENCES staff (staff_id)
        ON UPDATE CASCADE ON DELETE SET NULL;

-- Seed rows: invented sample data, deliberately small and safe to share.
INSERT INTO country (country_id, country) VALUES
    (1, 'Exampleland'), (2, 'Sample Republic');

INSERT INTO city (city_id, city, country_id) VALUES
    (1, 'Northport', 1), (2, 'Lakeview', 1), (3, 'Westhaven', 2);

INSERT INTO address (address_id, address, address2, district, city_id, postal_code, phone, location) VALUES
    (1, '10 Market Street', NULL, 'Central', 1, '10001', '555-0101', ST_GeomFromText('POINT(-73.9857 40.7484)')),
    (2, '22 River Road', 'Apt 4', 'North', 2, '10002', '555-0102', ST_GeomFromText('POINT(-73.9772 40.7527)')),
    (3, '5 Harbor Lane', NULL, 'Coastal', 3, '20001', '555-0103', ST_GeomFromText('POINT(-122.3321 47.6062)')),
    (4, '81 Garden Avenue', NULL, 'West', 1, '10003', '555-0104', ST_GeomFromText('POINT(-73.9900 40.7400)'));

INSERT INTO language (language_id, name) VALUES (1, 'English'), (2, 'French');
INSERT INTO category (category_id, name) VALUES (1, 'Adventure'), (2, 'Comedy'), (3, 'Documentary');

-- Insert stores before staff; manager IDs are linked after both stores/staff exist.
INSERT INTO store (store_id, manager_staff_id, address_id) VALUES (1, NULL, 1), (2, NULL, 3);
INSERT INTO staff (staff_id, first_name, last_name, address_id, email, store_id, active, username)
VALUES
    (1, 'Riley', 'Morgan', 1, 'riley@example.test', 1, TRUE, 'riley'),
    (2, 'Casey', 'Taylor', 3, 'casey@example.test', 2, TRUE, 'casey');
UPDATE store SET manager_staff_id = 1 WHERE store_id = 1;
UPDATE store SET manager_staff_id = 2 WHERE store_id = 2;

INSERT INTO customer (customer_id, store_id, first_name, last_name, email, address_id, active, create_date)
VALUES
    (1, 1, 'Avery', 'Rivera', 'avery@example.test', 2, TRUE, '2025-01-10 09:00:00'),
    (2, 2, 'Jordan', 'Lee', 'jordan@example.test', 4, TRUE, '2025-01-11 10:30:00');

INSERT INTO actor (actor_id, first_name, last_name) VALUES
    (1, 'Morgan', 'Reed'), (2, 'Jamie', 'Quinn'), (3, 'Taylor', 'Brooks');

INSERT INTO film (film_id, title, description, release_year, language_id, original_language_id,
                  rental_duration, rental_rate, length, replacement_cost, rating, special_features)
VALUES
    (1, 'The Copper Compass', 'A cartographer discovers a map to a forgotten harbor.', 2022, 1, 1, 5, 2.99, 98, 18.99, 'PG', 'Trailers,Behind the Scenes'),
    (2, 'Clouds Over Northport', 'Neighbors work together to save their community cinema.', 2023, 1, NULL, 4, 3.99, 105, 21.99, 'PG-13', 'Commentaries,Trailers');

INSERT INTO film_text (film_id, title, description) VALUES
    (1, 'The Copper Compass', 'A cartographer discovers a map to a forgotten harbor.'),
    (2, 'Clouds Over Northport', 'Neighbors work together to save their community cinema.');
INSERT INTO film_actor (actor_id, film_id) VALUES (1, 1), (2, 1), (2, 2), (3, 2);
INSERT INTO film_category (film_id, category_id) VALUES (1, 1), (2, 2);
INSERT INTO inventory (inventory_id, film_id, store_id) VALUES (1, 1, 1), (2, 2, 1), (3, 1, 2), (4, 2, 2);

INSERT INTO rental (rental_id, rental_date, inventory_id, customer_id, return_date, staff_id) VALUES
    (1, '2025-02-01 14:00:00', 1, 1, '2025-02-04 12:00:00', 1),
    (2, '2025-02-02 16:30:00', 4, 2, NULL, 2);
INSERT INTO payment (payment_id, customer_id, staff_id, rental_id, amount, payment_date) VALUES
    (1, 1, 1, 1, 2.99, '2025-02-01 14:05:00'),
    (2, 2, 2, 2, 3.99, '2025-02-02 16:35:00');

-- Quick smoke-check
SELECT 'country' AS table_name, COUNT(*) AS row_count FROM country
UNION ALL SELECT 'city', COUNT(*) FROM city
UNION ALL SELECT 'address', COUNT(*) FROM address
UNION ALL SELECT 'customer', COUNT(*) FROM customer
UNION ALL SELECT 'film', COUNT(*) FROM film
UNION ALL SELECT 'rental', COUNT(*) FROM rental
UNION ALL SELECT 'payment', COUNT(*) FROM payment;
