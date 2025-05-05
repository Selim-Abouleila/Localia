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
    FROM product
    WHERE id_produit = p_id_produit;

    -- Insert new order
    INSERT INTO commande(Order_date, Status, id_client, id_panier)
    VALUES (NOW(), 'Paid', p_id_client, p_id_panier);

    -- Get last inserted order ID
    SET new_commande_id = LAST_INSERT_ID();

    -- Insert into Involves (this triggers the Bought procedure automatically)
    INSERT INTO involves(id_commande, id_produit, quantity, price)
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
    IF (SELECT stock FROM inventory WHERE id_produit = p_id_produit) >= p_quantite THEN
        -- Décrémente le stock
        UPDATE inventory
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
    FROM inventory
    WHERE id_produit = p_id_produit;

    RETURN stock_val;
END //

DELIMITER ;


