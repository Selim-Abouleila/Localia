-- Start of LocaliaTables.sql
-- Create the database
CREATE DATABASE localia;

-- Use the database
USE localia;

-- Create the Client table
CREATE TABLE Client (
    id_client INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50),
    password VARCHAR(200),
    email VARCHAR(50) UNIQUE,
    role VARCHAR(50)
);


-- Create the Product table
CREATE TABLE Product (
    id_produit INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(50),
    product_description VARCHAR(200),
    product_type VARCHAR(50),
    price DECIMAL(15,2)
);

-- Create the Panier (Cart) table
CREATE TABLE Panier (
    id_panier INT AUTO_INCREMENT PRIMARY KEY,
    id_client INT,
    creation_date DATETIME,
    FOREIGN KEY (id_client) REFERENCES Client(id_client)
);

-- Create the Commande (Order) table
CREATE TABLE Commande (
    id_commande INT AUTO_INCREMENT PRIMARY KEY,
    Order_date DATETIME,
    Status VARCHAR(50),
    id_client INT,
    id_panier INT,
    FOREIGN KEY (id_client) REFERENCES Client(id_client),
    FOREIGN KEY (id_panier) REFERENCES Panier(id_panier)
);

-- Create the Likes table (junction table for Client and Product)
CREATE TABLE Likes (
    id_client INT,
    id_produit INT,
    PRIMARY KEY (id_client, id_produit),
    FOREIGN KEY (id_client) REFERENCES Client(id_client),
    FOREIGN KEY (id_produit) REFERENCES Product(id_produit)
);

-- Create the Has table (junction table for Panier and Product)
CREATE TABLE Has (
    id_panier INT,
    id_produit INT,
    quantity INT,
    PRIMARY KEY (id_panier, id_produit),
    FOREIGN KEY (id_panier) REFERENCES Panier(id_panier),
    FOREIGN KEY (id_produit) REFERENCES Product(id_produit)
);

-- Create the Involves table (junction table for Commande and Product)
CREATE TABLE Involves (
    id_commande INT,
    id_produit INT,
    quantity INT,
    price DECIMAL(15,2),
    PRIMARY KEY (id_commande, id_produit),
    FOREIGN KEY (id_commande) REFERENCES Commande(id_commande),
    FOREIGN KEY (id_produit) REFERENCES Product(id_produit)
);

-- Create the Inventory table
CREATE TABLE Inventory (
    id_inventory INT AUTO_INCREMENT PRIMARY KEY,
    stock INT,
    id_produit INT,
    FOREIGN KEY (id_produit) REFERENCES Product(id_produit)
);

SHOW TRIGGERS;




-- Start of LocaliaVues.sql
/*View all products */

CREATE VIEW view_inventory AS
SELECT 
    i.id_inventory,
    i.stock,
    p.id_produit,
    p.product_name,
    p.product_type,
    p.price
FROM Inventory i
JOIN Product p ON i.id_produit = p.id_produit;

CREATE VIEW view_logs AS
SELECT 
    id_log,
    message,
    log_date
FROM Log
ORDER BY log_date DESC;

CREATE OR REPLACE VIEW view_all_products AS
SELECT 
    id_produit,
    product_name,
    product_description,
    product_type,
    price
FROM Product;

/*View all clients */

CREATE VIEW view_all_clients AS
SELECT * FROM Client;

/*View panier */

CREATE VIEW view_panier_products AS
SELECT pa.id_panier, c.username, p.product_name, h.quantity
FROM Has h
JOIN Panier pa ON h.id_panier = pa.id_panier
JOIN Product p ON h.id_produit = p.id_produit
JOIN Client c ON pa.id_client = c.id_client;

/*View all orders */

CREATE VIEW view_all_commandes AS
SELECT co.*, c.username, pa.creation_date
FROM Commande co
JOIN Client c ON co.id_client = c.id_client
JOIN Panier pa ON co.id_panier = pa.id_panier;

/*View all likes */
CREATE VIEW view_client_likes AS
SELECT l.id_client, c.username, p.product_name
FROM Likes l
JOIN Client c ON l.id_client = c.id_client
JOIN Product p ON l.id_produit = p.id_produit;




-- Start of LocaliaTriggers.sql
DELIMITER //

CREATE TRIGGER trg_auto_decrement_stock
AFTER INSERT ON Involves
FOR EACH ROW
BEGIN
    CALL Bought(NEW.id_produit, NEW.quantity);
END //

DELIMITER ;



DELIMITER //


CREATE TRIGGER trg_after_product_insert
AFTER INSERT ON Product
FOR EACH ROW
BEGIN
    INSERT INTO Log(message)
    VALUES (CONCAT('New product added: ', NEW.product_name));
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER trg_after_order_insert
AFTER INSERT ON Commande
FOR EACH ROW
BEGIN
    INSERT INTO Log(message)
    VALUES (CONCAT('New order placed (ID: ', NEW.id_commande, ') by client ID: ', NEW.id_client));
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER trg_after_client_insert
AFTER INSERT ON Client
FOR EACH ROW
BEGIN
    INSERT INTO Log(message)
    VALUES (CONCAT('New client registered: ', NEW.username, ' (Email: ', NEW.email, ')'));
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER trg_create_panier_for_new_client
AFTER INSERT ON Client
FOR EACH ROW
BEGIN
    INSERT INTO Panier(id_client, creation_date)
    VALUES (NEW.id_client, NOW());
END //

DELIMITER ;



-- Start of LocaliaProcedures.sql
DELIMITER //

CREATE PROCEDURE PurchaseProduct(
    IN p_id_client INT,
    IN p_id_panier INT,
    IN p_id_produit INT,
    IN p_quantity INT
)
BEGIN
    DECLARE product_price DECIMAL(15,2);
    DECLARE new_commande_id INT;

    -- Get product price
    SELECT price INTO product_price
    FROM Product
    WHERE id_produit = p_id_produit;

    -- Insert new order
    INSERT INTO Commande(Order_date, Status, id_client, id_panier)
    VALUES (NOW(), 'Paid', p_id_client, p_id_panier);

    -- Get last inserted order ID
    SET new_commande_id = LAST_INSERT_ID();

    -- Insert into Involves (this triggers the Bought procedure automatically)
    INSERT INTO Involves(id_commande, id_produit, quantity, price)
    VALUES (new_commande_id, p_id_produit, p_quantity, product_price);
END //

DELIMITER ;




DELIMITER //

CREATE PROCEDURE Bought(
    IN p_id_produit INT,
    IN p_quantite INT
)
BEGIN
    -- Vérifie si le stock est suffisant
    IF (SELECT stock FROM Inventory WHERE id_produit = p_id_produit) >= p_quantite THEN
        -- Décrémente le stock
        UPDATE Inventory
        SET stock = stock - p_quantite
        WHERE id_produit = p_id_produit;
    ELSE
        -- Lève une erreur personnalisée
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock insuffisant pour ce produit.';
    END IF;
END //

DELIMITER ;


DELIMITER //

CREATE FUNCTION GetStock(p_id_produit INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE stock_val INT;

    SELECT stock INTO stock_val
    FROM Inventory
    WHERE id_produit = p_id_produit;

    RETURN stock_val;
END //

DELIMITER ;




-- Start of LocaliaInserts.sql
-- Insertion d'un T-shirt en coton biologique
INSERT INTO Product (product_name, product_description, product_type, price)
VALUES ('Organic Cotton T-Shirt', 'T-shirt doux et confortable fabriqué en coton biologique 100%.', 'textile', 25.00);
INSERT INTO Inventory (stock, id_produit)
VALUES (50, LAST_INSERT_ID());

-- Insertion d'un sac fourre-tout en chanvre
INSERT INTO Product (product_name, product_description, product_type, price)
VALUES ('Hemp Tote Bag', 'Sac fourre-tout durable et spacieux en tissu de chanvre écologique.', 'textile', 30.00);
INSERT INTO Inventory (stock, id_produit)
VALUES (30, LAST_INSERT_ID());

-- Insertion d'un cadre photo en bois récupéré
INSERT INTO Product (product_name, product_description, product_type, price)
VALUES ('Reclaimed Wood Picture Frame', 'Cadre photo rustique fabriqué à la main en bois récupéré.', 'decor', 20.00);
INSERT INTO Inventory (stock, id_produit)
VALUES (20, LAST_INSERT_ID());

-- Insertion d'un vase en verre recyclé
INSERT INTO Product (product_name, product_description, product_type, price)
VALUES ('Recycled Glass Vase', 'Vase élégant fabriqué à partir de verre 100% recyclé.', 'decor', 35.00);
INSERT INTO Inventory (stock, id_produit)
VALUES (15, LAST_INSERT_ID());

-- Insertion d'une table de salle à manger en chêne durable
INSERT INTO Product (product_name, product_description, product_type, price)
VALUES ('Oak Dining Table', 'Belle table de salle à manger en chêne issu de sources durables.', 'furniture', 500.00);
INSERT INTO Inventory (stock, id_produit)
VALUES (5, LAST_INSERT_ID());

-- Insertion d'une étagère en bambou
INSERT INTO Product (product_name, product_description, product_type, price)
VALUES ('Bamboo Bookshelf', 'Étagère robuste et élégante fabriquée en bambou renouvelable.', 'furniture', 150.00);
INSERT INTO Inventory (stock, id_produit)
VALUES (10, LAST_INSERT_ID());

-- Start of LocaliaLogs.sql
CREATE TABLE Log (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    message TEXT,
    log_date DATETIME DEFAULT CURRENT_TIMESTAMP
);


