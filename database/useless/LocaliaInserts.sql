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