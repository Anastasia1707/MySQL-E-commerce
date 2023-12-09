USE `final_project_1`;
  
# 1 Creating a view that shows how many items were sold in each product category using GROUP BY
CREATE OR REPLACE VIEW items_sold AS 
    SELECT product_id, price, COUNT(quantity) AS number_ordered
    FROM order_item
    GROUP BY product_id, price;
SELECT *
FROM items_sold;

# 2 Showing products with reviews using INNER JOIN to combine the review table and the items_sold view created in #1
SELECT items_sold.product_id, AVG(rating) AS ranking
FROM items_sold 
    INNER JOIN review ON items_sold.product_id = review.product_id
GROUP BY items_sold.product_id
ORDER BY ranking DESC;

# 3 Showing all products and reviews using OUTER JOIN to combine the review table and the items_sold view created in #1
SELECT items_sold.product_id, AVG(rating) AS ranking
FROM items_sold 
    LEFT OUTER JOIN review ON items_sold.product_id = review.product_id
GROUP BY items_sold.product_id
ORDER BY ranking DESC;

# 4 Showing the largest orders (amount paid is more then average amount) using subqueries
SELECT amount, orders_id, (SELECT AVG(amount) FROM payment_details) AS average_charge
FROM payment_details
WHERE amount > (SELECT AVG(amount) FROM payment_details);

# 5 Showing rating status for each product using CASE
SELECT AVG(rating) AS average_rating, product_id,
    CASE
        WHEN AVG(rating) <= 3 THEN 'Negative Review'
        WHEN AVG(rating) > 3 AND AVG(rating) <= 4 THEN 'Good Review'
        ELSE 'Positive Review'
	END AS review_status
FROM review
GROUP BY product_id
ORDER BY average_rating DESC;


# 6 Creating a FUNCTION that counts revenue by multiplying quantity and price of ordered products 

DROP FUNCTION IF EXISTS revenue;
DELIMITER //
CREATE FUNCTION revenue (q INT, p INT)
RETURNS INT
DETERMINISTIC
BEGIN
RETURN q * p;
END
//
DELIMITER ;

# Calling the FUNCTION revenue
# Showing the total revenue from selling products from the items_sold view created in #1
SELECT product_id, number_ordered, price, revenue(number_ordered, price) AS total_revenue
FROM items_sold;


# 7 Creating a TRIGGER

# adding an inventory_status column to the inventory table 
ALTER TABLE inventory
ADD COLUMN inventory_status VARCHAR(45) DEFAULT 'Enough Stock' AFTER stock;
SELECT * FROM inventory;

# creating a TRIGGER which shows if there is enough stock of a product in response to an update of inventory
DROP TRIGGER IF EXISTS low_stock;

DELIMITER //
CREATE TRIGGER low_stock
BEFORE UPDATE ON inventory
FOR EACH ROW
BEGIN
    IF (NEW.stock < 20) THEN 
        SET NEW.inventory_status = 'Low Stock'; 
	ELSE 
		SET NEW.inventory_status = 'Enough Stock';
    END IF; 
END//
DELIMITER ;

# updating stock column changes inventory_status column 
UPDATE inventory
    SET stock = 15
    WHERE id = 30;
SELECT * FROM inventory;

UPDATE inventory
    SET stock = 60
    WHERE id = 30;
SELECT * FROM inventory;

# rolling back the changes    
ALTER TABLE inventory
DROP COLUMN inventory_status;
SELECT * FROM inventory;


# 8 Creating a PROCEDURE which implements TRANSACTION. It inserts a row into order_item and checks if there is enough inventory 

DROP PROCEDURE IF EXISTS new_order_item;
DROP TRIGGER IF EXISTS low_stock;

DELIMITER //
CREATE PROCEDURE new_order_item (IN in_product_id INT, IN in_orders_id INT, IN in_quantity INT, IN in_price INT)
BEGIN
    DECLARE num_stock INT DEFAULT 0;
    START TRANSACTION;   
        INSERT INTO order_item (product_id, orders_id, quantity, price)
            VALUES (in_product_id, in_orders_id, in_quantity, in_price);    
        SELECT stock - in_quantity INTO num_stock
        FROM inventory
        WHERE product_id = in_product_id
        FOR UPDATE;
# ROLLBACK TRANSACTION if there is insufficient stock
        IF num_stock < 0 THEN
            SELECT CONCAT('product_id', in_product_id, ' has only ', num_stock + in_quantity, 
                          ' items in stock') AS `Not enough stock`;
            ROLLBACK;
# COMMIT TRANSACTION if there is sufficient stock after updating the inventory table
        ELSE 
            UPDATE inventory
                SET stock = stock - in_quantity
                WHERE product_id = in_product_id;
            COMMIT;
        END IF;
END //
DELIMITER ;

# inserting a row into the orders table as order_item table is an association table and its PK cannot be changed separately
INSERT INTO orders VALUES (61, 'November 6, 2023', 'November 8, 2023', 'delivered', 30, 30);

# calling the PROCEDURE
SELECT * FROM order_item; # - checks to see the initial quantity
SELECT * FROM inventory; # - checks to see the initial stocks
CALL new_order_item(30, 61, 1, 60);
SELECT * FROM order_item; # - checks to see the changes in quantity
SELECT * FROM inventory;  # - checks to see the changes in stocks 

# Inserting a row into orders table as order_item table is an association table and its PK cannot be changed separately
INSERT INTO orders VALUES (62, 'November 10, 2023', 'November 12, 2023', 'delivered', 30, 30);

# calling the PROCEDURE
CALL new_order_item(30, 62, 100, 60);

# deleting newly created rows in the orders table and the order_item table
DELETE FROM order_item WHERE orders_id = 61;
DELETE FROM orders WHERE id = 61;
DELETE FROM order_item WHERE orders_id = 62;
DELETE FROM orders WHERE id = 62;
# rolling back changes in inventory table
UPDATE inventory
    SET stock = 60
    WHERE id = 30;
SELECT * FROM inventory;