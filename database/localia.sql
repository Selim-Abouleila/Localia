-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1
-- Généré le : dim. 27 avr. 2025 à 16:28
-- Version du serveur : 8.0.36
-- Version de PHP : 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `localia`
--

DELIMITER $$
--
-- Procédures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `Bought` (IN `p_id_produit` INT, IN `p_quantite` INT)   BEGIN
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
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `PurchaseProduct` (IN `p_id_client` INT, IN `p_id_panier` INT, IN `p_id_produit` INT, IN `p_quantity` INT)   BEGIN
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
END$$

--
-- Fonctions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `GetStock` (`p_id_produit` INT) RETURNS INT DETERMINISTIC READS SQL DATA BEGIN
    DECLARE stock_val INT;

    SELECT stock INTO stock_val
    FROM Inventory
    WHERE id_produit = p_id_produit;

    RETURN stock_val;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `client`
--

CREATE TABLE `client` (
  `id_client` int NOT NULL,
  `username` varchar(50) DEFAULT NULL,
  `password` varchar(200) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL,
  `role` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `client`
--

INSERT INTO `client` (`id_client`, `username`, `password`, `email`, `role`) VALUES
(1, 'Sulpice Alban', '$2b$10$9DiurL0kpZ0FA906pzmtFeLjWtZGhGyIdafJX2YSqIDMoyTfkBRIa', 'albansulpice@gmail.com', 'admin'),
(2, 'Sulpice Enea', '$2b$10$nWabC7noHXXaTekIzOMeku6ehUdvYADunkXUyLjnUIA9g0.xyGwSm', 'eneasulpice2406@gmail.com', 'client'),
(3, 'Sulpice Arnaud', '$2b$10$MDhnzv5sVFxKu9wYaCasKud8eTKq8AwFaSSknjbxWn0rIkDRp98h6', 'arnaudsulpice@gmail.com', 'client'),
(4, 'Claire Leopoldes', '$2b$10$ZC2lWPlSsoQbIrG5UB/jfe3TCafmeW6hcC4nEoI/bC/a12fd1GZvu', 'cl.leopoldes@gmail.com', 'client'),
(5, 'yael chabloz', '$2b$10$JPOGQCcUUQtc1.crTO6cq.wjuqON.lNPmGdK4w3LcQekPPO4c1WPC', 'yaelchabloz97439@gmail.com', 'admin');

--
-- Déclencheurs `client`
--
DELIMITER $$
CREATE TRIGGER `trg_after_client_insert` AFTER INSERT ON `client` FOR EACH ROW BEGIN
    INSERT INTO Log(message)
    VALUES (CONCAT('New client registered: ', NEW.username, ' (Email: ', NEW.email, ')'));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_create_panier_for_new_client` AFTER INSERT ON `client` FOR EACH ROW BEGIN
    INSERT INTO Panier(id_client, creation_date)
    VALUES (NEW.id_client, NOW());
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `commande`
--

CREATE TABLE `commande` (
  `id_commande` int NOT NULL,
  `Order_date` datetime DEFAULT NULL,
  `Status` varchar(50) DEFAULT NULL,
  `id_client` int DEFAULT NULL,
  `id_panier` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `commande`
--

INSERT INTO `commande` (`id_commande`, `Order_date`, `Status`, `id_client`, `id_panier`) VALUES
(6, '2025-04-24 19:25:42', 'validée', 1, 1),
(7, '2025-04-24 19:29:32', 'validée', 1, 1),
(8, '2025-04-24 19:29:55', 'en attente', 1, 1),
(9, '2025-04-24 19:43:54', 'en attente', 2, 2),
(10, '2025-04-24 20:00:23', 'en attente', 3, 3),
(11, '2025-04-25 14:20:36', 'en attente', 4, 4),
(12, '2025-04-27 14:07:37', 'en attente', 1, 1);

--
-- Déclencheurs `commande`
--
DELIMITER $$
CREATE TRIGGER `trg_after_order_insert` AFTER INSERT ON `commande` FOR EACH ROW BEGIN
    INSERT INTO Log(message)
    VALUES (CONCAT('New order placed (ID: ', NEW.id_commande, ') by client ID: ', NEW.id_client));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `has`
--

CREATE TABLE `has` (
  `id_panier` int NOT NULL,
  `id_produit` int NOT NULL,
  `quantity` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `inventory`
--

CREATE TABLE `inventory` (
  `id_inventory` int NOT NULL,
  `stock` int DEFAULT NULL,
  `id_produit` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `inventory`
--

INSERT INTO `inventory` (`id_inventory`, `stock`, `id_produit`) VALUES
(1, 50, 1),
(2, 24, 2),
(3, 18, 3),
(5, 5, 5),
(6, 10, 6),
(7, 40, 7);

-- --------------------------------------------------------

--
-- Structure de la table `involves`
--

CREATE TABLE `involves` (
  `id_commande` int NOT NULL,
  `id_produit` int NOT NULL,
  `quantity` int DEFAULT NULL,
  `price` decimal(15,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `involves`
--

INSERT INTO `involves` (`id_commande`, `id_produit`, `quantity`, `price`) VALUES
(6, 2, 1, 30.00),
(7, 2, 2, 30.00),
(8, 1, 1, 25.00),
(9, 2, 1, 30.00),
(10, 3, 1, 20.00),
(11, 2, 2, 30.00),
(12, 3, 1, 20.00);

--
-- Déclencheurs `involves`
--
DELIMITER $$
CREATE TRIGGER `trg_auto_decrement_stock` AFTER INSERT ON `involves` FOR EACH ROW BEGIN
    CALL Bought(NEW.id_produit, NEW.quantity);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `likes`
--

CREATE TABLE `likes` (
  `id_client` int NOT NULL,
  `id_produit` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `log`
--

CREATE TABLE `log` (
  `id_log` int NOT NULL,
  `message` text,
  `log_date` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `log`
--

INSERT INTO `log` (`id_log`, `message`, `log_date`) VALUES
(1, 'New client registered: Sulpice Alban (Email: albansulpice@gmail.com)', '2025-04-24 16:27:14'),
(2, 'New order placed (ID: 1) by client ID: 1', '2025-04-24 18:46:42'),
(3, 'New order placed (ID: 2) by client ID: 1', '2025-04-24 18:47:43'),
(4, 'New order placed (ID: 3) by client ID: 1', '2025-04-24 18:57:47'),
(5, 'New order placed (ID: 4) by client ID: 1', '2025-04-24 19:21:34'),
(6, 'New order placed (ID: 5) by client ID: 1', '2025-04-24 19:23:15'),
(7, 'New order placed (ID: 6) by client ID: 1', '2025-04-24 19:25:42'),
(8, 'New order placed (ID: 7) by client ID: 1', '2025-04-24 19:29:32'),
(9, 'New order placed (ID: 8) by client ID: 1', '2025-04-24 19:29:55'),
(10, 'New client registered: Sulpice Enea (Email: eneasulpice2406@gmail.com)', '2025-04-24 19:43:06'),
(11, 'New order placed (ID: 9) by client ID: 2', '2025-04-24 19:43:54'),
(12, 'New client registered: Sulpice Arnaud (Email: arnaudsulpice@gmail.com)', '2025-04-24 19:59:30'),
(13, 'New order placed (ID: 10) by client ID: 3', '2025-04-24 20:00:23'),
(14, 'New client registered: Claire Leopoldes (Email: cl.leopoldes@gmail.com)', '2025-04-25 14:18:48'),
(15, 'New order placed (ID: 11) by client ID: 4', '2025-04-25 14:20:36'),
(16, 'New order placed (ID: 12) by client ID: 1', '2025-04-27 14:07:37'),
(17, 'New client registered: yael chabloz (Email: yaelchabloz97439@gmail.com)', '2025-04-27 14:22:52'),
(18, 'New product added: Oak chair', '2025-04-27 15:04:38'),
(19, 'New product added: Organic solom shirt', '2025-04-27 15:07:36');

-- --------------------------------------------------------

--
-- Structure de la table `panier`
--

CREATE TABLE `panier` (
  `id_panier` int NOT NULL,
  `id_client` int DEFAULT NULL,
  `creation_date` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `panier`
--

INSERT INTO `panier` (`id_panier`, `id_client`, `creation_date`) VALUES
(1, 1, '2025-04-24 16:27:14'),
(2, 2, '2025-04-24 19:43:06'),
(3, 3, '2025-04-24 19:59:30'),
(4, 4, '2025-04-25 14:18:48'),
(5, 5, '2025-04-27 14:22:52');

-- --------------------------------------------------------

--
-- Structure de la table `product`
--

CREATE TABLE `product` (
  `id_produit` int NOT NULL,
  `product_name` varchar(50) DEFAULT NULL,
  `product_description` varchar(200) DEFAULT NULL,
  `product_type` varchar(50) DEFAULT NULL,
  `price` decimal(15,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `product`
--

INSERT INTO `product` (`id_produit`, `product_name`, `product_description`, `product_type`, `price`) VALUES
(1, 'Organic Cotton T-Shirt', 'T-shirt doux et confortable fabriqué en coton biologique 100%.', 'textile', 25.00),
(2, 'Hemp Tote Bag', 'Sac fourre-tout durable et spacieux en tissu de chanvre écologique.', 'textile', 30.00),
(3, 'Reclaimed Wood Picture Frame', 'Cadre photo rustique fabriqué à la main en bois récupéré.', 'decor', 20.00),
(5, 'Oak Dining Table', 'Belle table de salle à manger en chêne issu de sources durables.', 'furniture', 500.00),
(6, 'Bamboo Bookshelf', 'Étagère robuste et élégante fabriquée en bambou renouvelable.', 'furniture', 150.00),
(7, 'Oak chair', 'Chaise en chêne clair.', 'furniture', 12.00);

--
-- Déclencheurs `product`
--
DELIMITER $$
CREATE TRIGGER `trg_after_product_insert` AFTER INSERT ON `product` FOR EACH ROW BEGIN
    INSERT INTO Log(message)
    VALUES (CONCAT('New product added: ', NEW.product_name));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `view_all_clients`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `view_all_clients` (
`id_client` int
,`username` varchar(50)
,`password` varchar(200)
,`email` varchar(50)
,`role` varchar(50)
);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `view_all_commandes`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `view_all_commandes` (
`id_commande` int
,`Order_date` datetime
,`Status` varchar(50)
,`id_client` int
,`id_panier` int
,`username` varchar(50)
,`creation_date` datetime
);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `view_all_products`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `view_all_products` (
`id_produit` int
,`product_name` varchar(50)
,`product_description` varchar(200)
,`product_type` varchar(50)
,`price` decimal(15,2)
);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `view_client_likes`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `view_client_likes` (
`id_client` int
,`username` varchar(50)
,`product_name` varchar(50)
);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `view_inventory`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `view_inventory` (
`id_inventory` int
,`stock` int
,`id_produit` int
,`product_name` varchar(50)
,`product_type` varchar(50)
,`price` decimal(15,2)
);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `view_logs`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `view_logs` (
`id_log` int
,`message` text
,`log_date` datetime
);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `view_panier_products`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `view_panier_products` (
`id_panier` int
,`username` varchar(50)
,`product_name` varchar(50)
,`quantity` int
);

-- --------------------------------------------------------

--
-- Structure de la vue `view_all_clients`
--
DROP TABLE IF EXISTS `view_all_clients`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_all_clients`  AS SELECT `client`.`id_client` AS `id_client`, `client`.`username` AS `username`, `client`.`password` AS `password`, `client`.`email` AS `email`, `client`.`role` AS `role` FROM `client` ;

-- --------------------------------------------------------

--
-- Structure de la vue `view_all_commandes`
--
DROP TABLE IF EXISTS `view_all_commandes`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_all_commandes`  AS SELECT `co`.`id_commande` AS `id_commande`, `co`.`Order_date` AS `Order_date`, `co`.`Status` AS `Status`, `co`.`id_client` AS `id_client`, `co`.`id_panier` AS `id_panier`, `c`.`username` AS `username`, `pa`.`creation_date` AS `creation_date` FROM ((`commande` `co` join `client` `c` on((`co`.`id_client` = `c`.`id_client`))) join `panier` `pa` on((`co`.`id_panier` = `pa`.`id_panier`))) ;

-- --------------------------------------------------------

--
-- Structure de la vue `view_all_products`
--
DROP TABLE IF EXISTS `view_all_products`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_all_products`  AS SELECT `product`.`id_produit` AS `id_produit`, `product`.`product_name` AS `product_name`, `product`.`product_description` AS `product_description`, `product`.`product_type` AS `product_type`, `product`.`price` AS `price` FROM `product` ;

-- --------------------------------------------------------

--
-- Structure de la vue `view_client_likes`
--
DROP TABLE IF EXISTS `view_client_likes`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_client_likes`  AS SELECT `l`.`id_client` AS `id_client`, `c`.`username` AS `username`, `p`.`product_name` AS `product_name` FROM ((`likes` `l` join `client` `c` on((`l`.`id_client` = `c`.`id_client`))) join `product` `p` on((`l`.`id_produit` = `p`.`id_produit`))) ;

-- --------------------------------------------------------

--
-- Structure de la vue `view_inventory`
--
DROP TABLE IF EXISTS `view_inventory`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_inventory`  AS SELECT `i`.`id_inventory` AS `id_inventory`, `i`.`stock` AS `stock`, `p`.`id_produit` AS `id_produit`, `p`.`product_name` AS `product_name`, `p`.`product_type` AS `product_type`, `p`.`price` AS `price` FROM (`inventory` `i` join `product` `p` on((`i`.`id_produit` = `p`.`id_produit`))) ;

-- --------------------------------------------------------

--
-- Structure de la vue `view_logs`
--
DROP TABLE IF EXISTS `view_logs`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_logs`  AS SELECT `log`.`id_log` AS `id_log`, `log`.`message` AS `message`, `log`.`log_date` AS `log_date` FROM `log` ORDER BY `log`.`log_date` DESC ;

-- --------------------------------------------------------

--
-- Structure de la vue `view_panier_products`
--
DROP TABLE IF EXISTS `view_panier_products`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_panier_products`  AS SELECT `pa`.`id_panier` AS `id_panier`, `c`.`username` AS `username`, `p`.`product_name` AS `product_name`, `h`.`quantity` AS `quantity` FROM (((`has` `h` join `panier` `pa` on((`h`.`id_panier` = `pa`.`id_panier`))) join `product` `p` on((`h`.`id_produit` = `p`.`id_produit`))) join `client` `c` on((`pa`.`id_client` = `c`.`id_client`))) ;

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `client`
--
ALTER TABLE `client`
  ADD PRIMARY KEY (`id_client`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Index pour la table `commande`
--
ALTER TABLE `commande`
  ADD PRIMARY KEY (`id_commande`),
  ADD KEY `id_client` (`id_client`),
  ADD KEY `id_panier` (`id_panier`);

--
-- Index pour la table `has`
--
ALTER TABLE `has`
  ADD PRIMARY KEY (`id_panier`,`id_produit`),
  ADD KEY `id_produit` (`id_produit`);

--
-- Index pour la table `inventory`
--
ALTER TABLE `inventory`
  ADD PRIMARY KEY (`id_inventory`),
  ADD KEY `id_produit` (`id_produit`);

--
-- Index pour la table `involves`
--
ALTER TABLE `involves`
  ADD PRIMARY KEY (`id_commande`,`id_produit`),
  ADD KEY `id_produit` (`id_produit`);

--
-- Index pour la table `likes`
--
ALTER TABLE `likes`
  ADD PRIMARY KEY (`id_client`,`id_produit`),
  ADD KEY `id_produit` (`id_produit`);

--
-- Index pour la table `log`
--
ALTER TABLE `log`
  ADD PRIMARY KEY (`id_log`);

--
-- Index pour la table `panier`
--
ALTER TABLE `panier`
  ADD PRIMARY KEY (`id_panier`),
  ADD KEY `id_client` (`id_client`);

--
-- Index pour la table `product`
--
ALTER TABLE `product`
  ADD PRIMARY KEY (`id_produit`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `client`
--
ALTER TABLE `client`
  MODIFY `id_client` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT pour la table `commande`
--
ALTER TABLE `commande`
  MODIFY `id_commande` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT pour la table `inventory`
--
ALTER TABLE `inventory`
  MODIFY `id_inventory` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT pour la table `log`
--
ALTER TABLE `log`
  MODIFY `id_log` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT pour la table `panier`
--
ALTER TABLE `panier`
  MODIFY `id_panier` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT pour la table `product`
--
ALTER TABLE `product`
  MODIFY `id_produit` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `commande`
--
ALTER TABLE `commande`
  ADD CONSTRAINT `commande_ibfk_1` FOREIGN KEY (`id_client`) REFERENCES `client` (`id_client`),
  ADD CONSTRAINT `commande_ibfk_2` FOREIGN KEY (`id_panier`) REFERENCES `panier` (`id_panier`);

--
-- Contraintes pour la table `has`
--
ALTER TABLE `has`
  ADD CONSTRAINT `has_ibfk_1` FOREIGN KEY (`id_panier`) REFERENCES `panier` (`id_panier`),
  ADD CONSTRAINT `has_ibfk_2` FOREIGN KEY (`id_produit`) REFERENCES `product` (`id_produit`);

--
-- Contraintes pour la table `inventory`
--
ALTER TABLE `inventory`
  ADD CONSTRAINT `inventory_ibfk_1` FOREIGN KEY (`id_produit`) REFERENCES `product` (`id_produit`);

--
-- Contraintes pour la table `involves`
--
ALTER TABLE `involves`
  ADD CONSTRAINT `involves_ibfk_1` FOREIGN KEY (`id_commande`) REFERENCES `commande` (`id_commande`),
  ADD CONSTRAINT `involves_ibfk_2` FOREIGN KEY (`id_produit`) REFERENCES `product` (`id_produit`);

--
-- Contraintes pour la table `likes`
--
ALTER TABLE `likes`
  ADD CONSTRAINT `likes_ibfk_1` FOREIGN KEY (`id_client`) REFERENCES `client` (`id_client`),
  ADD CONSTRAINT `likes_ibfk_2` FOREIGN KEY (`id_produit`) REFERENCES `product` (`id_produit`);

--
-- Contraintes pour la table `panier`
--
ALTER TABLE `panier`
  ADD CONSTRAINT `panier_ibfk_1` FOREIGN KEY (`id_client`) REFERENCES `client` (`id_client`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
