/*View all products */

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


