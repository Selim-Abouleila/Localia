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

