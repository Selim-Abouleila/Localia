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