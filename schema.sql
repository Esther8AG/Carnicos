DROP DATABASE IF EXISTS carnicos_pos;
CREATE DATABASE carnicos_pos CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE carnicos_pos;

CREATE TABLE users (id INT AUTO_INCREMENT PRIMARY KEY, username VARCHAR(60) NOT NULL UNIQUE, password_hash VARCHAR(255) NOT NULL, role ENUM('admin','cashier') NOT NULL DEFAULT 'cashier', active BOOLEAN NOT NULL DEFAULT TRUE, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE products (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(120) NOT NULL, price DECIMAL(12,2) NOT NULL, stock INT NOT NULL DEFAULT 0, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP);
CREATE TABLE sales (id BIGINT AUTO_INCREMENT PRIMARY KEY, user_id INT NULL, total DECIMAL(12,2) NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, CONSTRAINT fk_sales_user FOREIGN KEY(user_id) REFERENCES users(id));
CREATE TABLE sale_items (id BIGINT AUTO_INCREMENT PRIMARY KEY, sale_id BIGINT NOT NULL, product_id INT NOT NULL, quantity INT NOT NULL, unit_price DECIMAL(12,2) NOT NULL, subtotal DECIMAL(12,2) GENERATED ALWAYS AS (quantity*unit_price) STORED, FOREIGN KEY(sale_id) REFERENCES sales(id), FOREIGN KEY(product_id) REFERENCES products(id));
CREATE TABLE product_audit (id BIGINT AUTO_INCREMENT PRIMARY KEY, product_id INT NOT NULL, action ENUM('PRICE_CHANGE','DELETE') NOT NULL, old_price DECIMAL(12,2), new_price DECIMAL(12,2), old_name VARCHAR(120), changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, changed_by VARCHAR(128) NOT NULL);

DELIMITER $$
CREATE FUNCTION fn_sale_total(p_sale_id BIGINT) RETURNS DECIMAL(12,2) DETERMINISTIC READS SQL DATA BEGIN DECLARE result DECIMAL(12,2); SELECT COALESCE(SUM(subtotal),0) INTO result FROM sale_items WHERE sale_id=p_sale_id; RETURN result; END$$
CREATE TRIGGER trg_products_before_insert BEFORE INSERT ON products FOR EACH ROW BEGIN IF NEW.price<0 OR NEW.stock<0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Precio y existencias no pueden ser negativos'; END IF; END$$
CREATE TRIGGER trg_products_before_update BEFORE UPDATE ON products FOR EACH ROW BEGIN IF NEW.price<0 OR NEW.stock<0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Precio y existencias no pueden ser negativos'; END IF; END$$
CREATE TRIGGER trg_products_after_update AFTER UPDATE ON products FOR EACH ROW BEGIN IF NOT(OLD.price<=>NEW.price) THEN INSERT INTO product_audit(product_id,action,old_price,new_price,old_name,changed_by) VALUES(OLD.id,'PRICE_CHANGE',OLD.price,NEW.price,OLD.name,CURRENT_USER()); END IF; END$$
CREATE TRIGGER trg_products_after_delete AFTER DELETE ON products FOR EACH ROW BEGIN INSERT INTO product_audit(product_id,action,old_price,old_name,changed_by) VALUES(OLD.id,'DELETE',OLD.price,OLD.name,CURRENT_USER()); END$$
DELIMITER ;

INSERT INTO products(name,price,stock) VALUES ('Carne molida',18000,20),('Pechuga de pollo',16000,16),('Costilla de cerdo',22000,12),('Chorizo artesanal',14000,25);
