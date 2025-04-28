/*Explample d'utilisation pour visioner les produits*/
SELECT * FROM view_all_products;

/*Explample d'utilisation pour visioner les logs*/
SELECT * FROM view_logs;

/*Prodecure pour decrementer un produit apres achat*/



/* (id_client, id_panier, id_produit, p_quantity) */
CALL PurchaseProduct(1, 1, 2, 1);

SELECT * FROM view_inventory;

SELECT * FROM view_all_clients;

INSERT INTO Client(username, password, email, role)
VALUES ('user2', 'pass456', 'user2@example.com', 'user');



/*Get stock de l'id du produit*/
SELECT * FROM Commande;
SELECT GetStock(2);
